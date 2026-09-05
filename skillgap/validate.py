"""
Validation harness. Run this BEFORE building anything on top of the engine.

It answers, per kind of text, which matching method works better and at what
parameters. Both are decided by measurement here, not by picking a number that
looks reasonable.

Two labeled sets, because two kinds of text:

    labeled_postings.csv   job postings -> what the market demands
    labeled_courses.csv    course catalog entries -> what a student acquired

They are swept separately and reported separately. If their optima disagree,
that disagreement is the finding; each domain keeps its own parameters rather
than being averaged into one compromise that fits neither.

On a passing run this writes config.json, which is where the rest of the engine
reads its matching parameters from. On a failing run it writes nothing, so
nothing downstream can accidentally run on parameters that never passed.

Usage:
    python validate.py
"""

import csv
import sys
from datetime import date
from pathlib import Path

import numpy as np

from skillgap import Embedder, Taxonomy, split_chunks, save_config

MODEL = "intfloat/multilingual-e5-base"
POSTINGS_CSV = "labeled_postings.csv"
COURSES_CSV = "labeled_courses.csv"
SKILL_SEP = ";"

# Column holding the text to match. Both CSVs share a structure; only this
# column is named for its domain.
TEXT_COLUMNS = ("posting_text", "course_text", "text")

# The gate from the project spec. Below this, stop and fix the model or taxonomy.
MIN_F1 = 0.60

# Display grid only. The reported argmax is NOT taken from this list -- see
# exact_argmax(). A grid can only find a peak it happens to land on, and an
# earlier version of this file missed the true optimum at 0.885 because the
# grid stepped 0.88 -> 0.89.
DISPLAY_THRESHOLDS = [0.70, 0.75, 0.80, 0.82, 0.84, 0.85, 0.86,
                      0.87, 0.88, 0.89, 0.90, 0.91, 0.92, 0.94]

# Margins tried for the chunk-centric matcher. 0.0 keeps top-1 but demands no
# separation; higher values demand the winning skill clearly beat the runner-up.
DISPLAY_MARGINS = [0.00, 0.01, 0.02, 0.03, 0.05, 0.08]

# A winning plateau narrower than this is fitted to the sample, not the task.
MIN_PLATEAU = 0.01

# Phrases that avoid the taxonomy's exact wording. If these miss, the model
# is doing keyword matching in disguise, not semantics.
SYNONYM_PROBES = [
    ("Experience writing queries against relational databases", "sql"),
    ("Must be proficient with spreadsheets and pivot tables", "excel"),
    ("Protect systems against network intrusion and threats", "cybersecurity"),
    ("Strong verbal and written skills for client presentations", "communication"),
    ("Preparing balance sheets and year-end financial statements", "financial_reporting"),
]


# --------------------------------------------------------------------------
# Labeled data
# --------------------------------------------------------------------------

def load_labeled(path: str, valid_ids: set[str]) -> tuple[list, int]:
    """
    Read a hand-labeled set. Returns (rows, pending_count).

    A row with text but no skill_ids is treated as not yet labeled and skipped,
    not as an error -- that is what an unfilled template row looks like, and
    the count is reported so a forgotten row cannot hide.

    Every skill_id is checked against the taxonomy. A typo in a label silently
    becomes a false negative for a skill that does not exist, which would
    quietly drag down recall and look like a model problem, so that IS an error.
    """
    f = Path(path)
    if not f.exists():
        return [], 0

    rows, bad, pending = [], [], 0
    # utf-8-sig so the file round-trips through Excel without mangling Arabic.
    with f.open(encoding="utf-8-sig", newline="") as fh:
        reader = csv.DictReader(fh)
        cols = reader.fieldnames or []
        text_col = next((c for c in TEXT_COLUMNS if c in cols), None)
        if text_col is None:
            sys.exit(f"{path}: no text column. Expected one of {TEXT_COLUMNS}, "
                     f"found {cols}.")

        for lineno, row in enumerate(reader, start=2):
            text = (row.get(text_col) or "").strip()
            raw = (row.get("skill_ids") or "").strip()
            if not text and not raw:
                continue  # blank scaffold row
            if text and not raw:
                pending += 1
                continue  # written, not yet labeled
            ids = {s.strip() for s in raw.split(SKILL_SEP) if s.strip()}
            unknown = ids - valid_ids
            if unknown:
                bad.append(f"  line {lineno}: unknown skill_id(s) {sorted(unknown)}")
            elif not text:
                bad.append(f"  line {lineno}: has skill_ids but no {text_col}")
            else:
                rows.append((text, ids))

    if bad:
        sys.exit(f"{path} has problems:\n" + "\n".join(bad) +
                 f"\n\nvalid skill_ids: {sorted(valid_ids)}")
    return rows, pending


# --------------------------------------------------------------------------
# Scoring
# --------------------------------------------------------------------------

def precompute(tax: Taxonomy, labeled) -> list[tuple[np.ndarray, set[str]]]:
    """
    Encode every text once and keep its (chunks x skills) score matrix.

    Every parameter combination below is a different way of reading these same
    matrices, so the model runs once instead of once per sweep point. That is
    what makes an exhaustive sweep affordable.
    """
    return [(tax.skill_scores(split_chunks(text)), truth) for text, truth in labeled]


def predict_skill_centric(scores: np.ndarray, ids: list[str], th: float) -> set[str]:
    """Mirror of Taxonomy.match: a skill fires if ANY chunk clears the bar."""
    if scores.shape[0] == 0:
        return set()
    return {ids[i] for i in np.flatnonzero(scores.max(axis=0) >= th)}


def predict_chunk_top1(scores: np.ndarray, ids: list[str],
                       th: float, margin: float) -> set[str]:
    """Mirror of Taxonomy.match_chunk_top1: each chunk votes for one skill."""
    if scores.shape[0] == 0:
        return set()
    order = np.argsort(-scores, axis=1)
    top, second = order[:, 0], order[:, 1]
    rows = np.arange(scores.shape[0])
    top_s = scores[rows, top]
    keep = (top_s >= th) & ((top_s - scores[rows, second]) >= margin)
    return {ids[i] for i in top[keep]}


def prf(pre, labeled_scores, ids):
    """Micro-averaged precision/recall/F1 over one labeled set."""
    tp = fp = fn = 0
    for scores, truth in labeled_scores:
        found = pre(scores, ids)
        tp += len(found & truth)
        fp += len(found - truth)
        fn += len(truth - found)
    prec = tp / (tp + fp) if tp + fp else 0.0
    rec = tp / (tp + fn) if tp + fn else 0.0
    f1 = 2 * prec * rec / (prec + rec) if prec + rec else 0.0
    return tp, fp, fn, prec, rec, f1


def candidate_thresholds(labeled_scores) -> np.ndarray:
    """
    Every threshold at which the outcome can possibly change.

    Matching uses `score >= threshold`, so F1 is a step function of the
    threshold whose only breakpoints are the observed scores themselves.
    Evaluating exactly at those values finds the true argmax; a fixed grid can
    only find a peak it happens to step on.
    """
    vals = np.unique(np.concatenate([s.ravel() for s, _ in labeled_scores if s.size]))
    mids = (vals[:-1] + vals[1:]) / 2.0
    return np.unique(np.concatenate([vals, mids]))


def exact_argmax(labeled_scores, ids, method: str, margins=(0.0,)) -> dict:
    """
    Exhaustive search over every distinct decision boundary.

    Selection is by (F1, then plateau width), and the width term is not a
    tiebreaker detail -- it is the point. On a small labeled set the global
    argmax is often a spike two thousandths wide that exists because one
    text's score happens to fall there. A configuration holding the same F1
    across a wide band of thresholds is measuring something real; one that
    needs a hairline window is measuring this particular sample.
    """
    cands = candidate_thresholds(labeled_scores)
    best = None
    for margin in margins:
        results = []
        for th in cands:
            if method == "skill_centric":
                pre = lambda s, i, t=th: predict_skill_centric(s, i, t)
            else:
                pre = lambda s, i, t=th, m=margin: predict_chunk_top1(s, i, t, m)
            results.append((float(th),) + prf(pre, labeled_scores, ids))

        top_f1 = max(r[6] for r in results)
        runs, run = [], []
        for r in results:
            if r[6] >= top_f1 - 1e-12:
                run.append(r)
            elif run:
                runs.append(run); run = []
        if run:
            runs.append(run)

        widest = max(runs, key=lambda r: (r[-1][0] - r[0][0], len(r)))
        lo, hi = widest[0][0], widest[-1][0]
        chosen = (lo + hi) / 2.0
        row = min(widest, key=lambda r: abs(r[0] - chosen))
        cand = {"method": method, "threshold": float(chosen), "margin": float(margin),
                "tp": row[1], "fp": row[2], "fn": row[3],
                "precision": row[4], "recall": row[5], "f1": row[6],
                "plateau": (lo, hi), "width": hi - lo}
        if best is None or (cand["f1"], cand["width"]) > (best["f1"], best["width"]):
            best = cand
    return best


# --------------------------------------------------------------------------
# Report
# --------------------------------------------------------------------------

def report_spread(labeled_scores, ids) -> dict:
    """
    Describe the similarity distribution. Observation, not a gate.

    An earlier version of this file demanded a spread > 0.5 and flagged
    anything narrower as broken. That target came from watching GloVe
    word-averaging fail, and it is the wrong yardstick for this model class: a
    contrastively-trained sentence transformer puts almost all pairs in a high,
    narrow cosine band by construction. What matters is not how wide the band
    is, but whether the correct skill separates from the rest inside it.
    """
    allv = np.concatenate([s.ravel() for s, _ in labeled_scores if s.size])
    q = np.percentile(allv, [1, 25, 50, 75, 99])
    pos, neg = [], []
    for scores, truth in labeled_scores:
        for i, sid in enumerate(ids):
            (pos if sid in truth else neg).append(scores[:, i].max())
    pos, neg = np.array(pos), np.array(neg)
    return {"min": float(allv.min()), "max": float(allv.max()),
            "spread": float(allv.max() - allv.min()),
            "p1": q[0], "p25": q[1], "p50": q[2], "p75": q[3], "p99": q[4],
            "pos_mean": float(pos.mean()), "neg_mean": float(neg.mean()),
            "separation": float(pos.mean() - neg.mean())}


def sweep_domain(label: str, ls, ids) -> dict:
    """Print both methods' tables for one domain and return the winner."""
    print(f"\n{'=' * 70}")
    print(f"DOMAIN: {label}   ({len(ls)} texts, "
          f"{sum(len(t) for _, t in ls)} ground-truth labels)")
    print("=" * 70)

    sp = report_spread(ls, ids)
    print(f"similarity  range {sp['min']:.3f}-{sp['max']:.3f} (spread {sp['spread']:.3f})"
          f"  |  correct {sp['pos_mean']:.3f} vs other {sp['neg_mean']:.3f}"
          f"  ->  separation {sp['separation']:.3f}")

    print(f"\nMethod A: skill-centric (any chunk clears the threshold)")
    print(f"{'thresh':<9}{'TP':<5}{'FP':<5}{'FN':<5}{'prec':<8}{'rec':<8}{'F1':<8}")
    for th in DISPLAY_THRESHOLDS:
        r = prf(lambda s, i, t=th: predict_skill_centric(s, i, t), ls, ids)
        print(f"{th:<9}{r[0]:<5}{r[1]:<5}{r[2]:<5}{r[3]:<8.2f}{r[4]:<8.2f}{r[5]:<8.2f}")

    print(f"\nMethod B: chunk-centric top-1 (F1 at each threshold x margin)")
    print("  m\\th   " + "".join(f"{th:<7}" for th in DISPLAY_THRESHOLDS))
    for m in DISPLAY_MARGINS:
        cells = "".join(
            f"{prf(lambda s, i, t=th, mm=m: predict_chunk_top1(s, i, t, mm), ls, ids)[5]:<7.2f}"
            for th in DISPLAY_THRESHOLDS)
        print(f"  {m:<6.2f} " + cells)

    a = exact_argmax(ls, ids, "skill_centric")
    b = exact_argmax(ls, ids, "chunk_top1", DISPLAY_MARGINS)
    print("\nExact argmax (every decision boundary; F1 then plateau width):")
    for r in (a, b):
        lo, hi = r["plateau"]
        extra = f", m={r['margin']:.2f}" if r["method"] == "chunk_top1" else ""
        print(f"  {r['method']:<14} F1={r['f1']:.3f} P={r['precision']:.2f} "
              f"R={r['recall']:.2f}  TP={r['tp']} FP={r['fp']} FN={r['fn']}  "
              f"th={r['threshold']:.4f}{extra}  plateau {lo:.4f}-{hi:.4f} "
              f"(width {r['width']:.4f})")

    best = max((a, b), key=lambda r: (r["f1"], r["width"]))
    print(f"  -> {label} winner: {best['method']} (F1={best['f1']:.3f})")
    if abs(a["f1"] - b["f1"]) < 1e-12:
        print("     methods tied on F1; plateau width decided it")
    elif abs(a["f1"] - b["f1"]) < 0.02:
        print("     F1 decided it, but by under 0.02 -- at this sample size that")
        print("     is not a reliable margin; treat the winner as provisional")
    if best["width"] < MIN_PLATEAU:
        print(f"     WARNING: plateau only {best['width']:.4f} wide -- fitted to "
              f"this sample, treat as provisional")
    return best


def section(best: dict, n_texts: int, n_labels: int, validated: bool,
            inherited_from: str | None = None) -> dict:
    """
    One domain's entry in config.json.

    An inherited section carries the parameters but NOT the scores. Copying the
    donor domain's F1 across would put a number in the record that was never
    measured on this kind of text, and that number would eventually be quoted.
    """
    out = {
        "match_method": best["method"],
        "match_threshold": round(best["threshold"], 4),
        "match_margin": round(best["margin"], 4),
        "validated": validated,
    }
    if inherited_from:
        out.update({
            "inherited_from": inherited_from,
            "note": f"parameters copied from '{inherited_from}'; never measured "
                    f"on this domain's text. Label its CSV and re-run.",
            "best_f1": None, "precision": None, "recall": None,
            "labeled_texts": 0, "labeled_skill_mentions": 0,
        })
    else:
        out.update({
            "best_f1": round(best["f1"], 4),
            "precision": round(best["precision"], 4),
            "recall": round(best["recall"], 4),
            "threshold_plateau": [round(best["plateau"][0], 4),
                                  round(best["plateau"][1], 4)],
            "threshold_plateau_width": round(best["width"], 4),
            "labeled_texts": n_texts,
            "labeled_skill_mentions": n_labels,
        })
    return out


def main():
    print(f"loading {MODEL} ...")
    tax = Taxonomy("taxonomy.json", Embedder(MODEL))
    ids = [s.id for s in tax.skills]
    valid = set(ids)
    print(f"taxonomy: {len(ids)} skills")

    postings, p_pending = load_labeled(POSTINGS_CSV, valid)
    courses, c_pending = load_labeled(COURSES_CSV, valid)
    print(f"{POSTINGS_CSV}: {len(postings)} labeled, {p_pending} awaiting labels")
    print(f"{COURSES_CSV}: {len(courses)} labeled, {c_pending} awaiting labels")

    if not postings:
        sys.exit(f"\n{POSTINGS_CSV} has no labeled rows. Fill in posting_text and "
                 f"skill_ids (separated by '{SKILL_SEP}') before running.")
    if len(postings) < 20:
        print(f"  NOTE: the spec asks for 20-30 postings. At {len(postings)} the "
              f"numbers below move a lot when any single label flips.")

    print("\n=== Synonym probes ===")
    print("The expected skill must rank FIRST, not merely appear.")
    n_pass = 0
    for text, expected in SYNONYM_PROBES:
        hits = sorted(tax.match([text], threshold=0.0).items(), key=lambda kv: -kv[1])[:3]
        rank = next((i for i, (s, _) in enumerate(hits) if s == expected), None)
        n_pass += rank == 0
        print(f"  {'PASS' if rank == 0 else 'FAIL'}  expect={expected:<20} "
              f"got={[(s, round(v,2)) for s, v in hits]}")
    print(f"  {n_pass}/{len(SYNONYM_PROBES)} pass")

    p_best = sweep_domain("postings", precompute(tax, postings), ids)
    c_best = sweep_domain("courses", precompute(tax, courses), ids) if courses else None

    print(f"\n{'=' * 70}")
    print("COMPARISON")
    print("=" * 70)
    if c_best is None:
        print(f"  courses: no labeled rows in {COURSES_CSV}, sweep skipped.")
        print("  Course parameters will be INHERITED from postings and marked")
        print("  unvalidated. Postings bullets carry one requirement each while")
        print("  catalog entries pack several into a sentence, so there is no")
        print("  reason to assume the same parameters suit both. Label the")
        print("  course CSV and re-run to find out.")
    else:
        rows = [("postings", p_best), ("courses", c_best)]
        print(f"  {'domain':<12}{'method':<16}{'thresh':<10}{'margin':<9}{'F1':<8}{'width'}")
        for name, r in rows:
            print(f"  {name:<12}{r['method']:<16}{r['threshold']:<10.4f}"
                  f"{r['margin']:<9.2f}{r['f1']:<8.3f}{r['width']:.4f}")
        diffs = []
        if p_best["method"] != c_best["method"]:
            diffs.append(f"method ({p_best['method']} vs {c_best['method']})")
        if abs(p_best["threshold"] - c_best["threshold"]) > 0.01:
            diffs.append(f"threshold ({p_best['threshold']:.4f} vs "
                         f"{c_best['threshold']:.4f})")
        if abs(p_best["margin"] - c_best["margin"]) > 1e-9:
            diffs.append(f"margin ({p_best['margin']:.2f} vs {c_best['margin']:.2f})")
        if diffs:
            print("\n  THE TWO DOMAINS DISAGREE on: " + "; ".join(diffs) + ".")
            print("  Each keeps its own parameters. Do not collapse these into one")
            print("  number -- the disagreement is a property of the text, not noise")
            print("  to be averaged away.")
        else:
            print("\n  Both domains agree on method, threshold and margin.")

    gate = min([p_best["f1"]] + ([c_best["f1"]] if c_best else []))
    if gate < MIN_F1:
        print(f"\nSTOP. Best F1 {gate:.2f} is under the {MIN_F1} gate.")
        print("config.json was NOT written, so nothing else will run.")
        print("These tables belong in your evaluation chapter either way.")
        sys.exit(1)

    payload = {
        "model": MODEL,
        "validated_on": date.today().isoformat(),
        "taxonomy_skills": len(ids),
        "synonym_probes_passed": f"{n_pass}/{len(SYNONYM_PROBES)}",
        "postings": section(p_best, len(postings),
                            sum(len(t) for _, t in postings), True),
        "courses": (section(c_best, len(courses),
                            sum(len(t) for _, t in courses), True)
                    if c_best else
                    section(p_best, 0, 0, False, inherited_from="postings")),
    }
    save_config(payload)
    print(f"\nwrote config.json")
    print("These tables belong in your evaluation chapter.")


if __name__ == "__main__":
    main()

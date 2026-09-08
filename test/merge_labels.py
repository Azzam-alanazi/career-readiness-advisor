"""
Merge hand-written labels from manual_validation.csv into the corpus, and
report how far they agree with the AI baseline.

Dry run by default: it validates, prints the comparison, and changes nothing.
Pass --write to apply.

    python merge_labels.py            # check and report
    python merge_labels.py --write    # apply

Agreement treats YOUR labels as the reference and the AI's as the prediction:

    precision = |manual & ai| / |ai|     of what the AI proposed, how much you kept
    recall    = |manual & ai| / |manual| of what you found, how much the AI got
    jaccard   = |manual & ai| / |manual | ai|

That direction matters. A high AI precision with low recall means it is
cautious; the reverse means it over-tags. Reading them the other way round
inverts the conclusion.
"""

import argparse
import csv
import json
import shutil
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
CORPUS = HERE / "labeled_postings.csv"
MANUAL = HERE / "manual_validation.csv"
HOLDOUT = HERE / "holdout" / "ai_labels_manual_validation.csv"
TAXONOMY = HERE.parent / "skillgap" / "taxonomy.json"
SEP = ";"


def read(path: Path) -> list[dict]:
    if not path.exists():
        sys.exit(f"missing: {path}")
    with path.open(encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f))


def ids(raw: str) -> set[str]:
    return {s.strip() for s in (raw or "").split(SEP) if s.strip()}


def prf(manual: set[str], ai: set[str]) -> tuple[float, float, float]:
    hit = manual & ai
    p = len(hit) / len(ai) if ai else 0.0
    r = len(hit) / len(manual) if manual else 0.0
    j = len(hit) / len(manual | ai) if (manual | ai) else 0.0
    return p, r, j


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--write", action="store_true",
                    help="apply the merge (default is a dry run)")
    args = ap.parse_args()

    tax = {s["id"]: s["en"] for s in
           json.loads(TAXONOMY.read_text(encoding="utf-8"))["skills"]}
    manual, corpus, hold = read(MANUAL), read(CORPUS), read(HOLDOUT)
    ai_by_id = {r["id"]: r for r in hold}

    # ---- refuse on anything unlabelled ----------------------------------
    blank = [r["id"] for r in manual if not (r.get("skill_ids") or "").strip()]
    if blank:
        sys.exit(f"{len(blank)} of {len(manual)} postings are still unlabelled: "
                 f"{', '.join(blank)}\nNothing was changed. Label every row first "
                 f"-- a partial merge would silently become a partial ground truth.")

    # ---- validate before touching anything ------------------------------
    problems = []
    for r in manual:
        unknown = sorted(ids(r["skill_ids"]) - set(tax))
        if unknown:
            problems.append(f"  id {r['id']}: unknown skill id(s) {unknown}")
        if r["id"] not in {c["id"] for c in corpus}:
            problems.append(f"  id {r['id']}: not present in {CORPUS.name}")
        if r["id"] not in ai_by_id:
            problems.append(f"  id {r['id']}: no AI baseline to compare against")
    if problems:
        sys.exit("cannot merge:\n" + "\n".join(problems) +
                 f"\n\nvalid ids are SK01..SK90 (see skillgap/TAXONOMY_REFERENCE.md)")

    occupied = [r["id"] for r in corpus
                if r["id"] in {m["id"] for m in manual}
                and (r.get("skill_ids") or "").strip()]

    # ---- agreement -------------------------------------------------------
    print(f"{len(manual)} postings labelled, compared against the AI baseline\n")
    print(f"{'id':<5}{'career':<24}{'manual':<8}{'ai':<6}{'shared':<8}"
          f"{'prec':<7}{'rec':<7}{'jacc':<7}")
    tot_hit = tot_manual = tot_ai = 0
    macro = []
    for r in manual:
        m, a = ids(r["skill_ids"]), ids(ai_by_id[r["id"]]["ai_skill_ids"])
        p, rc, j = prf(m, a)
        macro.append((p, rc, j))
        tot_hit += len(m & a); tot_manual += len(m); tot_ai += len(a)
        print(f"{r['id']:<5}{r['career'][:22]:<24}{len(m):<8}{len(a):<6}"
              f"{len(m & a):<8}{p:<7.2f}{rc:<7.2f}{j:<7.2f}")

    mp = tot_hit / tot_ai if tot_ai else 0.0
    mr = tot_hit / tot_manual if tot_manual else 0.0
    mj = tot_hit / (tot_manual + tot_ai - tot_hit) if (tot_manual + tot_ai) else 0.0
    print(f"\n{'micro (pooled)':<37}{tot_manual:<8}{tot_ai:<6}{tot_hit:<8}"
          f"{mp:<7.2f}{mr:<7.2f}{mj:<7.2f}")
    n = len(macro)
    print(f"{'macro (mean of per-posting)':<37}{'':<8}{'':<6}{'':<8}"
          f"{sum(x[0] for x in macro)/n:<7.2f}{sum(x[1] for x in macro)/n:<7.2f}"
          f"{sum(x[2] for x in macro)/n:<7.2f}")
    print("\nMicro pools every label, so long postings weigh more; macro treats each")
    print("posting equally. A wide gap between them means agreement depends on length.")

    # ---- where they disagree --------------------------------------------
    print("\n=== disagreements ===")
    for r in manual:
        m, a = ids(r["skill_ids"]), ids(ai_by_id[r["id"]]["ai_skill_ids"])
        only_m, only_a = sorted(m - a), sorted(a - m)
        if not (only_m or only_a):
            print(f"\nid {r['id']}: exact agreement")
            continue
        print(f"\nid {r['id']} ({r['career']})")
        for sid in only_m:
            print(f"   you only : {sid}  {tax[sid]}")
        for sid in only_a:
            print(f"   AI only  : {sid}  {tax.get(sid, '(not in taxonomy)')}")

    # ---- apply ------------------------------------------------------------
    if not args.write:
        print(f"\nDRY RUN -- nothing written.")
        if occupied:
            print(f"NOTE: {CORPUS.name} already has labels on id(s) "
                  f"{', '.join(occupied)}; --write would overwrite them.")
        print(f"Re-run with --write to merge these labels into {CORPUS.name}.")
        return

    by_id = {r["id"]: r["skill_ids"] for r in manual}
    fields = list(corpus[0].keys())
    for r in corpus:
        if r["id"] in by_id:
            r["skill_ids"] = by_id[r["id"]]

    shutil.copy2(CORPUS, str(CORPUS) + ".bak")
    # Written in place rather than via a temp-and-replace: OneDrive holds a
    # handle on this directory that permits writes but refuses deletes, so
    # os.replace() fails here. The .bak above is the rollback.
    with CORPUS.open("w", newline="", encoding="utf-8-sig") as f:
        w = csv.DictWriter(f, fieldnames=fields, quoting=csv.QUOTE_ALL)
        w.writeheader()
        for r in corpus:
            w.writerow({k: r.get(k, "") for k in fields})

    done = sum(1 for r in corpus if (r.get("skill_ids") or "").strip())
    print(f"\nmerged {len(by_id)} labelled postings into {CORPUS.name} "
          f"({done} of {len(corpus)} rows now carry labels)")
    print(f"backup: {CORPUS.name}.bak")
    print("\nvalidate.py reads this file. It needs 20-30 labelled postings for the")
    print("sweep to mean anything -- five is a spot check on the AI, not a gate.")


if __name__ == "__main__":
    main()

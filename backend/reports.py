"""
Read-only reports over the engine state the API serves.

    python -m backend.reports min-demand
    python -m backend.reports course-reach
    python -m backend.reports course-reach --explain

Nothing here changes what the API serves. Both reports read the EngineState the
API builds at startup -- from cache, so the model is not loaded -- and call the
same engine functions with one input varied. --explain is the exception: it
re-runs course extraction chunk by chunk to show why each course maps to what it
does, and that needs the model.
"""
from __future__ import annotations

import argparse
import inspect
import sys
from dataclasses import dataclass

import numpy as np

from backend import engine
from backend.engine import EngineState, build_state, sg

# The spec's definition-of-done scenario, as run end to end in Phase 3 and by
# app/tool/contract_check.dart.
SCENARIO_CAREER = "Business Analyst"
SCENARIO_COURSES = ["IS 201", "IS 210", "IS 230", "IS 240", "IS 250", "BUS 210"]

# 0.10 to 0.50 in steps of 0.05. Rounded so 0.3 is 0.3 and not
# 0.30000000000000004: analyze_gap compares with >=, and demand shares sit
# exactly on values such as 0.2 (1 of 5 postings).
SWEEP = [round(0.10 + 0.05 * i, 2) for i in range(9)]

# Read from the engine rather than restated, so this report cannot drift from it.
ENGINE_DEFAULT = inspect.signature(sg.analyze_gap).parameters["min_demand"].default

SHORT = {"Business Analyst": "BA", "Data Analyst": "DA", "ERP Consultant": "ERP",
         "IT Support Specialist": "ITS", "Software Developer": "SD"}


# --------------------------------------------------------------------------
# min_demand
# --------------------------------------------------------------------------

def min_postings(min_demand: float, posting_count: int) -> int:
    """
    Fewest postings a skill must appear in to clear min_demand, using the same
    k / n and >= that build_career_profile and analyze_gap use. Demand is always
    a whole number of postings over the career's count, so min_demand is really a
    posting count -- and the same value means a different count per career.
    Returns posting_count + 1 when no skill can clear it.
    """
    for k in range(1, posting_count + 1):
        if k / posting_count >= min_demand:
            return k
    return posting_count + 1


@dataclass(frozen=True)
class SweepRow:
    min_demand: float
    min_postings: int
    counted: int            # skills that clear min_demand: readiness divides by these
    covered: list[str]
    missing: int
    closable: int           # missing skills that some catalog course maps to
    readiness: float
    ceiling: float          # readiness had the student taken every catalog course


def sweep_min_demand(state: EngineState, career: str, courses: list[str],
                     values: list[float]) -> list[SweepRow]:
    profile = state.profiles[career]
    acquired = state.acquired(courses)
    everything = state.acquired(list(state.courses))
    rows = []
    for md in values:
        gap = sg.analyze_gap(profile, acquired, min_demand=md)
        rows.append(SweepRow(
            min_demand=md,
            min_postings=min_postings(md, profile.posting_count),
            counted=len(gap.covered) + len(gap.missing),
            covered=[s for s, _ in gap.covered],
            missing=len(gap.missing),
            closable=sum(1 for s, _ in gap.missing if s in everything),
            readiness=gap.readiness,
            ceiling=sg.analyze_gap(profile, everything, min_demand=md).readiness,
        ))
    return rows


def check_matches_api(state: EngineState, career: str, courses: list[str]) -> None:
    """The sweep's row at the engine default must be exactly what the API serves."""
    served = state.gap(career, courses)
    swept = sg.analyze_gap(state.profiles[career], state.acquired(courses),
                           min_demand=ENGINE_DEFAULT)
    if served != swept:
        raise AssertionError("the API no longer uses the engine default min_demand; "
                             "this sweep does not describe what it serves")


def unseen_outcomes(state: EngineState, values: list[float]) -> list[float]:
    """
    min_demand values between the sweep's ends, to the nearest 0.001, whose
    outcome in any career matches none of the sweep's rows. Empty means the
    table is complete: no value in between behaves differently from a row shown.
    """
    counts = [p.posting_count for _, p in sorted(state.profiles.items())]

    def outcome(md: float) -> tuple[int, ...]:
        return tuple(min_postings(md, n) for n in counts)

    shown = {outcome(v) for v in values}
    lo, hi = round(min(values) * 1000), round(max(values) * 1000)
    return [x / 1000 for x in range(lo, hi + 1) if outcome(x / 1000) not in shown]


# --------------------------------------------------------------------------
# Course reach
# --------------------------------------------------------------------------

@dataclass(frozen=True)
class Reach:
    skill: str
    courses: list[str]                      # catalog courses that map to it
    demand: dict[str, tuple[int, int]]      # career -> (postings naming it, postings)

    def most_postings(self) -> int:
        return max((k for k, _ in self.demand.values()), default=0)


def course_reach(state: EngineState) -> list[Reach]:
    """Every taxonomy skill, in taxonomy order, with the courses that reach it."""
    by_skill: dict[str, list[str]] = {}
    for code, course in state.courses.items():
        for s in course.skills:
            by_skill.setdefault(s, []).append(code)
    out = []
    for sid in state.skills:
        demand = {career: (round(p.demand[sid] * p.posting_count), p.posting_count)
                  for career, p in sorted(state.profiles.items()) if sid in p.demand}
        out.append(Reach(sid, by_skill.get(sid, []), demand))
    return out


@dataclass(frozen=True)
class ChunkVote:
    chunk: str
    top: str
    top_score: float
    runner_up: str
    lead: float
    voted: bool
    reason: str


def explain_courses(state: EngineState, paths: engine.Paths | None = None,
                    embedder_factory=None) -> list[tuple[str, list[ChunkVote]]]:
    """
    Re-run course extraction one chunk at a time and record why each chunk did
    or did not vote. Checked against the served course map, so an explanation
    that disagrees with what the API serves raises instead of printing. `paths`
    must be the ones `state` was built from.
    """
    params = state.course_params
    if params["method"] != "chunk_top1":
        raise SystemExit(f"--explain describes chunk_top1; courses use {params['method']}")
    paths = paths or engine.Paths()
    tax = sg.Taxonomy(str(paths.taxonomy), (embedder_factory or sg.Embedder)(state.model))
    out = []
    for row in engine._read_csv(paths.courses):
        code = row["course_code"]
        chunks = sg.split_chunks(row["course_text"].strip())
        votes = []
        for chunk, scores in zip(chunks, tax.skill_scores(chunks)):
            order = np.argsort(-scores)
            top, second = int(order[0]), int(order[1])
            score, lead = float(scores[top]), float(scores[top]) - float(scores[second])
            if score < params["threshold"]:
                voted, reason = False, f"below threshold {params['threshold']}"
            elif lead < params["margin"]:
                voted, reason = False, f"lead under margin {params['margin']}"
            else:
                voted, reason = True, "voted"
            votes.append(ChunkVote(chunk, tax.skills[top].id, score,
                                   tax.skills[second].id, lead, voted, reason))
        explained = {v.top for v in votes if v.voted}
        if explained != set(state.courses[code].skills) or \
                explained != set(tax.match_auto(chunks, params)):
            raise AssertionError(f"{code}: explanation {sorted(explained)} disagrees "
                                 f"with the served map {list(state.courses[code].skills)}")
        out.append((code, votes))
    return out


# --------------------------------------------------------------------------
# Rendering
# --------------------------------------------------------------------------

def _table(headers: list[str], rows: list[list[object]]) -> str:
    lines = ["| " + " | ".join(headers) + " |", "|" + "|".join("---" for _ in headers) + "|"]
    lines += ["| " + " | ".join(str(c) for c in r) + " |" for r in rows]
    return "\n".join(lines)


def _pct(x: float) -> str:
    return f"{x * 100:.1f}%"


def render_min_demand(state: EngineState) -> str:
    check_matches_api(state, SCENARIO_CAREER, SCENARIO_COURSES)
    unseen = unseen_outcomes(state, SWEEP)
    if unseen:
        raise AssertionError(f"min_demand values {unseen[:5]} give outcomes no row shows")

    name = lambda s: state.skills[s]["en"]  # noqa: E731
    profile = state.profiles[SCENARIO_CAREER]
    n = profile.posting_count
    rows = sweep_min_demand(state, SCENARIO_CAREER, SCENARIO_COURSES, SWEEP)
    scenario = _table(
        ["min_demand", "skill must appear in", "skills counted", "covered", "missing",
         "missing any course could close", "readiness",
         f"readiness with all {len(state.courses)} courses", "covered skills"],
        [[f"{r.min_demand:.2f}" + (" (current)" if r.min_demand == ENGINE_DEFAULT else ""),
          f"≥ {r.min_postings} of {n} postings", r.counted, len(r.covered), r.missing,
          r.closable, _pct(r.readiness), _pct(r.ceiling),
          ", ".join(name(s) for s in r.covered) or "none"] for r in rows])

    careers = sorted(state.profiles)
    per_career = _table(
        ["min_demand"] + [f"{c} ({state.profiles[c].posting_count})" for c in careers],
        [[f"{md:.2f}"] + [
            f"≥ {min_postings(md, state.profiles[c].posting_count)} · "
            f"{sum(1 for w in state.profiles[c].demand.values() if w >= md)} skills"
            for c in careers] for md in SWEEP])

    return "\n".join([
        f"## min_demand sweep: {SCENARIO_CAREER}, {n} postings",
        f"Completed courses: {', '.join(SCENARIO_COURSES)}.",
        "",
        scenario,
        "",
        "### The same values in every career: minimum postings · skills counted",
        "",
        per_career,
        "",
        f"check: the row at the engine default ({ENGINE_DEFAULT}) is what the API serves: ok",
        f"check: every min_demand from {SWEEP[0]:.2f} to {SWEEP[-1]:.2f} behaves like "
        "a row above, in every career: ok",
    ])


def render_course_reach(state: EngineState) -> str:
    reach = course_reach(state)
    skill = lambda s: state.skills[s]  # noqa: E731

    def demand(r: Reach) -> str:
        return ", ".join(f"{SHORT.get(c, c)} {k}/{n}" for c, (k, n) in r.demand.items()) or "none"

    reached = [r for r in reach if r.courses]
    unreached = sorted((r for r in reach if not r.courses),
                       key=lambda r: (-r.most_postings(),
                                      -sum(k for k, _ in r.demand.values()), r.skill))
    tiers = [
        ("named by 2+ postings in at least one career", lambda r: r.most_postings() >= 2),
        ("named by a single posting, in any career", lambda r: r.most_postings() == 1),
        ("named by no posting in any career", lambda r: r.most_postings() == 0),
    ]
    out = [
        f"## Course reach: {len(reached)} of {len(reach)} skills reachable "
        f"from {len(state.courses)} catalog courses",
        "",
        "### Reachable",
        "",
        _table(["skill", "name", "category", "reached by", "demanded by (postings)"],
               [[r.skill, skill(r.skill)["en"], skill(r.skill)["category"],
                 ", ".join(r.courses), demand(r)] for r in reached]),
        "",
        f"### Not reachable: {len(unreached)}",
    ]
    for title, keep in tiers:
        group = [r for r in unreached if keep(r)]
        out += ["", f"#### {title}: {len(group)}", "",
                _table(["skill", "name", "category", "demanded by (postings)"],
                       [[r.skill, skill(r.skill)["en"], skill(r.skill)["category"], demand(r)]
                        for r in group])]
    empty = [c for c, course in state.courses.items() if not course.skills]
    out += ["", f"Courses that map to no skill: {', '.join(empty) or 'none'}.",
            "Career codes: " + ", ".join(f"{v} {k}" for k, v in SHORT.items()) + "."]
    return "\n".join(out)


def render_explain(state: EngineState) -> str:
    name = lambda s: state.skills[s]["en"]  # noqa: E731
    explained = explain_courses(state)
    p = state.course_params
    out = ["## Why each course maps to what it does",
           f"Courses use {p['method']}, threshold {p['threshold']}, margin {p['margin']}, "
           f"validated on courses: {p['validated']}. Each chunk votes for at most one skill.",
           ""]
    for code, votes in explained:
        course = state.courses[code]
        got = ", ".join(f"{s} {name(s)}" for s in course.skills) or "nothing"
        out.append(f"**{code} {course.name}** ({len(votes)} chunks): {got}")
        for v in votes:
            text = v.chunk if len(v.chunk) <= 70 else v.chunk[:67] + "..."
            out.append(f"- \"{text}\" -> {v.top} {name(v.top)} {v.top_score:.3f}, "
                       f"lead {v.lead:+.3f} over {v.runner_up} {name(v.runner_up)}: {v.reason}")
        out.append("")

    all_votes = [v for _, votes in explained for v in votes]
    reached = {s for c in state.courses.values() for s in c.skills}
    dropped = sorted({v.top for v in all_votes if not v.voted} - reached)
    out += [
        f"Chunks: {len(all_votes)}, so under chunk_top1 the catalog can reach at most "
        f"{len(all_votes)} skills. Voted: {sum(v.voted for v in all_votes)}. "
        f"Below threshold: {sum(v.reason.startswith('below') for v in all_votes)}. "
        f"Lead under margin: {sum(v.reason.startswith('lead') for v in all_votes)}.",
        "",
        "Unreachable skills that some chunk ranked first, but the gate then dropped: "
        + (", ".join(f"{s} {name(s)}" for s in dropped) or "none") + ".",
    ]
    return "\n".join(out)


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description="Read-only reports over the served engine state.")
    sub = ap.add_subparsers(dest="report", required=True)
    sub.add_parser("min-demand", help="sweep min_demand for the definition-of-done scenario")
    cr = sub.add_parser("course-reach", help="which skills the course catalog can reach")
    cr.add_argument("--explain", action="store_true",
                    help="show, chunk by chunk, why each course maps as it does (loads the model)")
    args = ap.parse_args(argv)
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")

    state = build_state()
    if args.report == "min-demand":
        print(render_min_demand(state))
    else:
        print(render_course_reach(state))
        if args.explain:
            print()
            print(render_explain(state))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

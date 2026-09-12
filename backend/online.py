"""
Online courses for skills no university course teaches.

Hand-curated in skillgap/online_courses.csv, one row per skill and course:

    skill_id,provider,course_title,url,is_free

A row with only its skill_id filled is a placeholder still waiting for a course,
and is skipped. Every other row is checked, and any problem stops startup: an
unknown skill id would otherwise sit in the file and silently never be offered,
which is the failure validate.py refuses for labels.

    python -m backend.online status   # what is filled in, what is still missing
    python -m backend.online sync     # match the placeholder rows to the gap skills

`sync` adds a placeholder for each new gap skill and drops placeholders for
skills that stopped being gaps. A row with any course detail filled in is never
touched, so it is safe to run after the catalog, the labels or the postings
change.
"""
from __future__ import annotations

import argparse
import csv
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from .engine import EngineState

COLUMNS = ("skill_id", "provider", "course_title", "url", "is_free")
_YES = {"yes", "y", "true", "1"}
_NO = {"no", "n", "false", "0"}


class OnlineCoursesError(ValueError):
    """online_courses.csv has rows the service cannot serve."""


@dataclass(frozen=True)
class OnlineCourse:
    provider: str
    title: str
    url: str
    is_free: bool
    skills: tuple[str, ...]      # every skill the file lists this course under


@dataclass(frozen=True)
class OnlineCatalog:
    courses: tuple[OnlineCourse, ...] = ()
    placeholders: int = 0        # rows with a skill id and no course yet


def load_online_courses(path: Path, valid_ids: set[str]) -> OnlineCatalog:
    """
    Read and check the file. No file means no online courses rather than an
    error: the feature stays empty until someone fills it in.

    Rows are grouped by URL, so one course listed under several skills is one
    course that closes all of them. Problems are collected and raised together,
    each with its line number, so a single run shows everything to fix.
    """
    if not path.exists():
        return OnlineCatalog()
    with path.open(encoding="utf-8-sig", newline="") as f:
        reader = csv.DictReader(f)
        absent = [c for c in COLUMNS if c not in (reader.fieldnames or [])]
        if absent:
            raise OnlineCoursesError(f"{path}: missing column(s) {', '.join(absent)}; "
                                     f"expected {', '.join(COLUMNS)}")
        rows = list(reader)

    problems: list[str] = []
    placeholders = 0
    by_url: dict[str, dict] = {}
    for lineno, row in enumerate(rows, start=2):
        cell = {c: (row.get(c) or "").strip() for c in COLUMNS}
        sid = cell["skill_id"]
        course = {c: cell[c] for c in COLUMNS[1:]}
        if not sid and not any(course.values()):
            continue                                        # blank line
        if not sid:
            problems.append(f"line {lineno}: a course with no skill_id")
            continue
        if sid not in valid_ids:
            problems.append(f"line {lineno}: unknown skill_id {sid!r}")
            continue
        if not any(course.values()):
            placeholders += 1                               # waiting for a course
            continue
        empty = [c for c, v in course.items() if not v]
        if empty:
            problems.append(f"line {lineno} ({sid}): partly filled; empty {', '.join(empty)}")
            continue
        url, free = course["url"], course["is_free"].lower()
        if not url.lower().startswith(("http://", "https://")):
            problems.append(f"line {lineno} ({sid}): url {url!r} does not start with "
                            f"http:// or https://")
            continue
        if free not in _YES | _NO:
            problems.append(f"line {lineno} ({sid}): is_free {course['is_free']!r} "
                            f"is not yes or no")
            continue
        meta = {"provider": course["provider"], "title": course["course_title"],
                "is_free": free in _YES}
        entry = by_url.setdefault(url, {**meta, "skills": [], "line": lineno})
        if any(entry[k] != v for k, v in meta.items()):
            problems.append(f"line {lineno} ({sid}): {url} is also on line {entry['line']} "
                            f"with a different provider, title or is_free")
            continue
        if sid not in entry["skills"]:
            entry["skills"].append(sid)

    if problems:
        raise OnlineCoursesError(
            f"{path} has {len(problems)} problem(s):\n"
            + "\n".join(f"  {p}" for p in problems)
            + "\n\nSkill ids are the SK codes in skillgap/TAXONOMY_REFERENCE.md; "
              "is_free takes yes/no, true/false or 1/0.")
    return OnlineCatalog(
        courses=tuple(OnlineCourse(e["provider"], e["title"], url, e["is_free"],
                                   tuple(e["skills"]))
                      for url, e in by_url.items()),
        placeholders=placeholders)


# --------------------------------------------------------------------------
# Which skills need a row
# --------------------------------------------------------------------------

def gap_skills(state: EngineState) -> list[str]:
    """
    Skills some career counts as a gap, at the engine's min_demand, that no
    university course teaches: the only skills an online course is ever offered
    for. A skill a catalog course teaches always gets that course instead.
    """
    taught = {s for c in state.courses.values() for s in c.skills}
    gaps = {s for career in state.profiles for s, _ in state.gap(career, []).missing}
    return sorted(gaps - taught)


def _rows(path: Path) -> list[dict[str, str]]:
    if not path.exists():
        return []
    with path.open(encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f))


def _filled(row: dict[str, str]) -> bool:
    return any((row.get(c) or "").strip() for c in COLUMNS[1:])


def sync(path: Path, skill_ids: list[str]) -> tuple[list[str], list[str]]:
    """
    Match the placeholder rows to `skill_ids`: add one for each id with no row,
    drop placeholder-only rows whose skill is no longer listed. A row with any
    course detail filled in is never touched. Returns (added, removed).
    """
    wanted = set(skill_ids)
    rows = _rows(path)
    keep = [r for r in rows if _filled(r) or (r.get("skill_id") or "").strip() in wanted]
    removed = [(r.get("skill_id") or "").strip() for r in rows
               if not _filled(r) and (r.get("skill_id") or "").strip() not in wanted]
    have = {(r.get("skill_id") or "").strip() for r in keep}
    added = [s for s in skill_ids if s not in have]
    if not added and not removed:
        return [], []

    if removed or not path.exists():
        # Rewrite with the file's own columns, so nothing a person added is lost.
        # Written in place: OneDrive refuses the delete a rename-over needs.
        with path.open(encoding="utf-8-sig", newline="") if path.exists() else open(
                __file__, encoding="utf-8") as probe:
            fields = (csv.DictReader(probe).fieldnames if path.exists() else None) or list(COLUMNS)
        with path.open("w", encoding="utf-8-sig", newline="") as f:
            w = csv.DictWriter(f, fieldnames=fields, extrasaction="ignore")
            w.writeheader()
            w.writerows(keep)
            w.writerows({"skill_id": s} for s in added)
        return added, removed

    # Only additions: append, so filled rows keep their exact bytes. No BOM
    # mid-file, so Excel keeps reading it as UTF-8.
    ends_open = not path.read_bytes().endswith(b"\n")
    with path.open("a", encoding="utf-8", newline="") as f:
        if ends_open:
            f.write("\r\n")
        w = csv.writer(f)
        for s in added:
            w.writerow([s, "", "", "", ""])
    return added, removed


def status(state: EngineState, path: Path) -> str:
    gaps = set(gap_skills(state))
    listed = {(r.get("skill_id") or "").strip() for r in _rows(path)}
    filled = {s for c in state.online.courses for s in c.skills}
    taught = {s for c in state.courses.values() for s in c.skills}
    name = lambda s: f"{s} {state.skills[s]['en']}"  # noqa: E731
    no_row = sorted(gaps - listed)
    unused = sorted(filled & taught)
    lines = [
        f"{path}",
        f"gap skills no university course teaches: {len(gaps)}",
        f"  with an online course filled in: {len(gaps & filled)}",
        f"  placeholder only: {len((gaps & listed) - filled)}",
        f"  no row at all: {len(no_row)}" + (" -- run sync" if no_row else ""),
        f"online courses filled in: {len(state.online.courses)}",
    ]
    if no_row:
        lines.append("  missing rows: " + ", ".join(name(s) for s in no_row))
    if unused:
        lines.append("filled in for skills a university course now teaches, so never offered: "
                     + ", ".join(name(s) for s in unused))
    return "\n".join(lines)


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description="Online courses for skills no university course teaches.")
    ap.add_argument("command", choices=["status", "sync"])
    args = ap.parse_args(argv)
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")

    from .engine import Paths, build_state
    paths = Paths()
    state = build_state(paths)
    if args.command == "sync":
        added, removed = sync(paths.online_courses, gap_skills(state))
        print(f"added {len(added)} placeholder row(s)" + (": " + ", ".join(added) if added else ""))
        print(f"removed {len(removed)} placeholder row(s) for skills no longer a gap"
              + (": " + ", ".join(removed) if removed else ""))
    print(status(state, paths.online_courses))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

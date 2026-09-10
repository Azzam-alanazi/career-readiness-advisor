"""
Load the skill-gap engine once and serve everything from memory.

Startup does all the expensive work: loading the embedding model, embedding the
taxonomy, building a demand profile for each career, and mapping every catalog
course to skills. Requests only read the results. Nothing is embedded per
request, so the model is never reloaded (spec item 12).

Profiles and the course map are also persisted to disk (spec item 6), under a key
that hashes everything able to change them: taxonomy, matching config, posting
text, course text, model name, and the engine source itself. A restart with
unchanged inputs skips extraction and never loads the model. Any change produces
a new key, so a stale profile cannot be served -- the same rule StaleConfigError
enforces for matching parameters.

Chunking matches validate.py exactly: extraction runs on posting_text as stored,
" | " separators included, because that is the text the matching parameters were
measured on. Chunking it differently would apply the parameters outside the
conditions they were validated under.
"""
from __future__ import annotations

import csv
import hashlib
import json
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Callable

REPO = Path(__file__).resolve().parent.parent
ENGINE_DIR = REPO / "skillgap"
if str(ENGINE_DIR) not in sys.path:
    sys.path.insert(0, str(ENGINE_DIR))

import skillgap as sg  # noqa: E402  (needs the path insert above)

# Bump when the cache layout changes, so old files are ignored rather than misread.
CACHE_VERSION = 1


@dataclass(frozen=True)
class Paths:
    """Every input the engine reads. Tests point these at small fixtures."""
    taxonomy: Path = ENGINE_DIR / "taxonomy.json"
    config: Path = ENGINE_DIR / "config.json"
    postings: Path = REPO / "test" / "labeled_postings.csv"
    courses: Path = ENGINE_DIR / "labeled_courses.csv"
    cache_dir: Path = REPO / "backend" / ".cache"


@dataclass(frozen=True)
class Course:
    code: str
    name: str
    skills: tuple[str, ...]


class SkillNames:
    """The one method sg.recommend() needs from a Taxonomy, without the model."""

    def __init__(self, skills: dict[str, dict[str, str]]) -> None:
        self._skills = skills

    def name(self, skill_id: str) -> str:
        return self._skills.get(skill_id, {}).get("en", skill_id)


@dataclass
class EngineState:
    skills: dict[str, dict[str, str]]        # id -> {en, ar, category}
    profiles: dict[str, sg.CareerProfile]    # career -> demand profile
    courses: dict[str, Course]               # course code -> course
    posting_params: dict[str, Any]
    course_params: dict[str, Any]
    config: dict[str, Any]
    model: str
    cache_key: str
    built_from_cache: bool

    def careers(self) -> list[tuple[str, int]]:
        return sorted((c, p.posting_count) for c, p in self.profiles.items())

    def acquired(self, course_codes: list[str]) -> set[str]:
        out: set[str] = set()
        for code in course_codes:
            out |= set(self.courses[code].skills)
        return out

    def gap(self, career: str, course_codes: list[str]) -> sg.GapResult:
        # min_demand stays at the engine default (0.15). That value has never
        # been validated -- see CHANGELOG -- and changing it here would hide the
        # fact behind an API layer.
        return sg.analyze_gap(self.profiles[career], self.acquired(course_codes))

    def recommendations(self, gap: sg.GapResult, completed: list[str],
                        limit: int) -> list[tuple[Course, list[str], float]]:
        done = set(completed)
        catalog = {code: list(c.skills)
                   for code, c in self.courses.items() if code not in done}
        missing = dict(gap.missing)
        out = []
        for r in sg.recommend(gap, catalog, SkillNames(self.skills), limit=limit):
            course = self.courses[r["course"]]
            # recommend() reports English names only; recover the ids so the
            # client can render either language.
            closes = sorted((s for s in course.skills if s in missing),
                            key=lambda s: -missing[s])
            out.append((course, closes, r["value"]))
        return out

    def validation(self) -> dict[str, Any]:
        return {
            "gate_passed": bool(self.posting_params["gate_passed"]),
            "best_f1": self.posting_params.get("best_f1"),
            "gate_min_f1": self.config.get("gate_min_f1"),
            "course_mapping_validated": bool(self.course_params["validated"]),
        }


def _read_csv(path: Path) -> list[dict[str, str]]:
    with path.open(encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f))


def _course_name(text: str) -> str:
    """Catalog entries lead with the title: 'Database Management Systems. ...'."""
    head = text.split(". ", 1)[0].strip()
    return head or text[:60].strip()


def _cache_key(paths: Paths, postings: list[dict], course_rows: list[dict],
               model: str) -> str:
    h = hashlib.sha256()
    h.update(f"v{CACHE_VERSION}|{model}".encode())
    for p in (paths.taxonomy, paths.config, ENGINE_DIR / "skillgap.py"):
        h.update(p.read_bytes())
    # Only the fields extraction reads. Relabelling a posting's skill_ids does
    # not change its demand profile, so it must not invalidate the cache.
    for r in postings:
        h.update(f"\x1f{r['id']}\x1f{r['career']}\x1f{r['posting_text']}".encode())
    for r in course_rows:
        h.update(f"\x1e{r['course_code']}\x1e{r['course_text']}".encode())
    return h.hexdigest()


def _load_cache(path: Path, key: str):
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (FileNotFoundError, json.JSONDecodeError):
        return None                 # absent or half-written: rebuild
    if data.get("key") != key:
        return None
    profiles = {c: sg.CareerProfile(career=c, posting_count=v["posting_count"],
                                    demand=v["demand"])
                for c, v in data["profiles"].items()}
    courses = {code: Course(code, v["name"], tuple(v["skills"]))
               for code, v in data["courses"].items()}
    return profiles, courses


def _save_cache(path: Path, key: str, profiles: dict, courses: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    # Written directly rather than via temp-and-rename: OneDrive refuses the
    # delete a rename-over needs. A torn write just fails to parse next time
    # and triggers a rebuild, so atomicity buys nothing here.
    path.write_text(json.dumps({
        "key": key,
        "profiles": {c: {"posting_count": p.posting_count, "demand": p.demand}
                     for c, p in profiles.items()},
        "courses": {code: {"name": c.name, "skills": list(c.skills)}
                    for code, c in courses.items()},
    }, ensure_ascii=False, indent=1), encoding="utf-8")


def build_state(paths: Paths | None = None,
                embedder_factory: Callable[[str], Any] | None = None) -> EngineState:
    """
    Build everything the API serves. Raises StaleConfigError if config.json was
    swept against a different taxonomy -- better no service than one applying
    parameters measured against another label set.
    """
    paths = paths or Paths()
    config = json.loads(paths.config.read_text(encoding="utf-8"))
    posting_params = sg.load_match_params("postings", str(paths.config), str(paths.taxonomy))
    course_params = sg.load_match_params("courses", str(paths.config), str(paths.taxonomy))
    model = config["model"]

    skills = {s["id"]: {"en": s["en"], "ar": s["ar"], "category": s["category"]}
              for s in json.loads(paths.taxonomy.read_text(encoding="utf-8"))["skills"]}
    postings = _read_csv(paths.postings)
    course_rows = _read_csv(paths.courses)

    key = _cache_key(paths, postings, course_rows, model)
    cache_file = paths.cache_dir / f"engine-{key[:20]}.json"
    cached = _load_cache(cache_file, key)

    if cached is not None:
        profiles, courses = cached
        from_cache = True
    else:
        embedder = (embedder_factory or sg.Embedder)(model)
        tax = sg.Taxonomy(str(paths.taxonomy), embedder)

        by_career: dict[str, list[str]] = {}
        for r in postings:
            by_career.setdefault(r["career"], []).append(r["posting_text"].strip())
        profiles = {career: sg.build_career_profile(career, texts, tax, posting_params)
                    for career, texts in sorted(by_career.items())}

        courses = {}
        for r in course_rows:
            found = sg.skills_from_courses([r["course_text"].strip()], tax, course_params)
            courses[r["course_code"]] = Course(
                r["course_code"], _course_name(r["course_text"]), tuple(sorted(found)))

        _save_cache(cache_file, key, profiles, courses)
        from_cache = False

    return EngineState(skills=skills, profiles=profiles, courses=courses,
                       posting_params=posting_params, course_params=course_params,
                       config=config, model=model, cache_key=key,
                       built_from_cache=from_cache)

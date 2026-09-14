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

Course-to-skill mapping reads the hand labels in labeled_courses.csv wherever a
course has them: labels are ground truth. Extraction maps only the unlabelled
courses, and still runs on every course so it can be measured against the
labels. Labels and online courses sit outside the cache -- nothing about them is
embedded -- so they are read on every start: a change needs a restart, not a
rebuild.

A student's skills are the union of what their completed courses teach and what
they report holding from outside coursework. The two are kept apart all the way
to the response, so the academic-record claim is never blurred with an
unverified one.

The department's curriculum view reads the same two things: the served course
mapping and the career profiles. A skill counts as demanded there exactly when a
student's gap would count it, so the two views can never disagree about what
the postings ask for.

Chunking matches validate.py exactly: extraction runs on posting_text as stored,
" | " separators included, because that is the text the matching parameters were
measured on. Chunking it differently would apply the parameters outside the
conditions they were validated under.
"""
from __future__ import annotations

import csv
import hashlib
import inspect
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
from validate import NO_SKILLS, SKILL_SEP  # noqa: E402  the label format validate.py measures against

from .online import OnlineCatalog, OnlineCourse, load_online_courses  # noqa: E402

# Bump when the cache layout changes, so old files are ignored rather than misread.
CACHE_VERSION = 1

# The engine's own default, read rather than restated, so the curriculum view
# counts a skill as demanded exactly when a student's gap does.
MIN_DEMAND: float = inspect.signature(sg.analyze_gap).parameters["min_demand"].default


def min_postings(posting_count: int, min_demand: float = MIN_DEMAND) -> int:
    """
    The fewest of a career's postings that must name a skill for it to count as
    demanded. min_demand is a share, so this grows with the sample: at 0.15 it is
    1 posting of 5 or 6, and 2 of 10 or 11. Computed with the same comparison
    analyze_gap makes, so the two cannot disagree at a boundary.
    """
    return next((k for k in range(1, posting_count + 1)
                 if k / posting_count >= min_demand), posting_count)


@dataclass(frozen=True)
class Paths:
    """Every input the engine reads. Tests point these at small fixtures."""
    taxonomy: Path = ENGINE_DIR / "taxonomy.json"
    config: Path = ENGINE_DIR / "config.json"
    postings: Path = REPO / "test" / "labeled_postings.csv"
    courses: Path = ENGINE_DIR / "labeled_courses.csv"
    online_courses: Path = ENGINE_DIR / "online_courses.csv"
    cache_dir: Path = REPO / "backend" / ".cache"


@dataclass(frozen=True)
class Course:
    code: str
    name: str
    skills: tuple[str, ...]
    mapped_by: str = "extraction"          # "labels" where the course is hand-labelled


class CourseLabelsError(ValueError):
    """labeled_courses.csv has labels the service cannot serve."""


@dataclass(frozen=True)
class Suggestions:
    """For every missing skill: where to learn it, grouped by course."""
    university: list[tuple[Course, list[str], float]]         # course, skills it closes, value
    online: list[tuple[OnlineCourse, list[str], float]]
    uncovered: list[str]        # missing skills neither source covers, by demand


@dataclass(frozen=True)
class SourcedGap:
    """A gap that knows where each covered skill came from."""
    combined: sg.GapResult               # courses and self-reported skills together
    from_courses: sg.GapResult           # the academic record alone
    course_skills: frozenset[str]        # everything the completed courses teach

    def source(self, skill_id: str) -> str:
        # The academic record wins: a skill a completed course teaches counts as
        # "courses" even when the student also reported it.
        return "courses" if skill_id in self.course_skills else "self_reported"


@dataclass(frozen=True)
class CareerCoverage:
    """How many of one career's demanded skills some catalog course teaches."""
    career: str
    posting_count: int
    demanded: int
    taught: int
    min_postings: int           # postings a skill needs to count, at MIN_DEMAND

    @property
    def coverage(self) -> float:
        return self.taught / self.demanded if self.demanded else 0.0


@dataclass(frozen=True)
class CurriculumGap:
    """The catalog against the postings, for one career or every career."""
    careers: tuple[str, ...]                      # the scope
    posting_count: int                            # postings in the scope
    demanded: dict[str, int]                      # demanded skill -> postings in scope naming it
    demanded_by: dict[str, tuple[str, ...]]       # demanded skill -> careers counting it
    taught: frozenset[str]                        # the demanded skills some course teaches
    uncovered: list[str]                          # demanded, taught by no course; by demand
    not_asked: list[tuple[str, tuple[str, ...]]]  # taught, named by no posting in scope; courses
    # Named by some posting in scope, demanded in no career of it: in neither
    # list above. (skill, postings naming it, careers naming it, courses teaching it)
    below_threshold: list[tuple[str, int, tuple[str, ...], tuple[str, ...]]]
    per_career: list[CareerCoverage]              # every career, whatever the scope

    @property
    def coverage(self) -> float:
        return len(self.taught) / len(self.demanded) if self.demanded else 0.0


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
    courses: dict[str, Course]               # course code -> served mapping
    extracted: dict[str, tuple[str, ...]]    # course code -> what extraction found
    online: OnlineCatalog                    # hand-curated, never embedded
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

    def gap(self, career: str, course_codes: list[str],
            self_reported: list[str] | tuple = ()) -> sg.GapResult:
        # min_demand stays at the engine default (0.15). That value has never
        # been validated -- see CHANGELOG -- and changing it here would hide the
        # fact behind an API layer.
        acquired = self.acquired(course_codes) | set(self_reported)
        return sg.analyze_gap(self.profiles[career], acquired)

    def gap_by_source(self, career: str, course_codes: list[str],
                      self_reported: list[str] | tuple) -> SourcedGap:
        """The gap with both sources counted, and again with the courses alone."""
        return SourcedGap(combined=self.gap(career, course_codes, self_reported),
                          from_courses=self.gap(career, course_codes),
                          course_skills=frozenset(self.acquired(course_codes)))

    def recommendations(self, gap: sg.GapResult, completed: list[str],
                        limit: int | None = None) -> Suggestions:
        """
        For each missing skill: the university courses that teach it if any
        does, otherwise the online courses listed for it. A university course
        counts toward the degree, so it always wins; an online course is offered
        only for a skill nothing in the catalog teaches. A missing skill neither
        covers is returned as uncovered rather than dropped.

        Both lists are grouped by course and ranked by the total demand of the
        gaps each closes. `limit` caps each list on its own; None returns all.
        """
        missing = dict(gap.missing)
        done = set(completed)
        catalog = {code: list(c.skills)
                   for code, c in self.courses.items() if code not in done}
        university = []
        for r in sg.recommend(gap, catalog, SkillNames(self.skills), limit=len(catalog)):
            course = self.courses[r["course"]]
            # recommend() reports English names only; recover the ids so the
            # client can render either language.
            closes = sorted((s for s in course.skills if s in missing),
                            key=lambda s: -missing[s])
            university.append((course, closes, r["value"]))

        # A missing skill is never taught by a completed course (the student
        # would have it), so "taught by any course" means "an untaken course
        # teaches it" and the university list above already closes it.
        taught = {s for c in self.courses.values() for s in c.skills}
        online = []
        for oc in self.online.courses:
            closes = sorted((s for s in oc.skills if s in missing and s not in taught),
                            key=lambda s: -missing[s])
            if closes:
                online.append((oc, closes, round(sum(missing[s] for s in closes), 3)))
        online.sort(key=lambda t: -t[2])          # stable: file order breaks ties

        covered = {s for _, closes, _ in university + online for s in closes}
        uncovered = [s for s, _ in gap.missing if s not in covered]
        if limit is not None:
            university, online = university[:limit], online[:limit]
        return Suggestions(university, online, uncovered)

    def demanded(self, career: str) -> dict[str, float]:
        """A career's demanded skills, by demand: exactly those a student's gap counts."""
        return dict(self.gap(career, []).missing)

    def taught_by(self) -> dict[str, tuple[str, ...]]:
        """Every skill some catalog course teaches, with those courses' codes."""
        out: dict[str, list[str]] = {}
        for code in sorted(self.courses):
            for s in self.courses[code].skills:
                out.setdefault(s, []).append(code)
        return {s: tuple(codes) for s, codes in out.items()}

    def curriculum(self, career: str | None = None) -> CurriculumGap:
        """
        The department's view: the catalog, as the served course mapping (the
        hand labels), against the postings, for one career or all of them.

        A skill is demanded when a student's gap would count it: at MIN_DEMAND
        in some career in scope. Across careers the postings are pooled, so a
        skill's weight is the share of every posting in scope that names it. A
        taught skill is "not asked" only when no posting in scope names it at all.

        A skill some posting names, but too few to reach MIN_DEMAND in any career
        in scope, is neither demanded nor unasked. It is listed on its own, so
        the threshold never drops a skill out of sight.
        """
        scope = (career,) if career is not None else tuple(sorted(self.profiles))
        taught = self.taught_by()
        rank = {s: i for i, s in enumerate(self.skills)}

        demanded_by: dict[str, list[str]] = {}
        named_by: dict[str, list[str]] = {}
        for c in scope:
            for s in self.profiles[c].demand:
                named_by.setdefault(s, []).append(c)
            for s in self.demanded(c):
                demanded_by.setdefault(s, []).append(c)

        def postings_naming(skill: str) -> int:
            # A profile's demand is count / postings, so this recovers the count.
            return sum(round(self.profiles[c].demand.get(skill, 0.0)
                             * self.profiles[c].posting_count) for c in scope)

        demanded = {s: postings_naming(s) for s in demanded_by}
        below = {s: postings_naming(s) for s in named_by if s not in demanded_by}
        per_career = []
        for c, p in sorted(self.profiles.items()):
            d = self.demanded(c)
            per_career.append(CareerCoverage(c, p.posting_count, len(d),
                                             sum(s in taught for s in d),
                                             min_postings(p.posting_count)))
        return CurriculumGap(
            careers=scope,
            posting_count=sum(self.profiles[c].posting_count for c in scope),
            demanded=demanded,
            demanded_by={s: tuple(cs) for s, cs in demanded_by.items()},
            taught=frozenset(s for s in demanded if s in taught),
            uncovered=sorted((s for s in demanded if s not in taught),
                             key=lambda s: (-demanded[s], rank[s])),
            not_asked=[(s, taught[s]) for s in sorted(taught, key=rank.__getitem__)
                       if s not in named_by],
            below_threshold=[(s, below[s], tuple(named_by[s]), taught.get(s, ()))
                             for s in sorted(below, key=lambda s: (-below[s], rank[s]))],
            per_career=per_career)

    def validation(self) -> dict[str, Any]:
        return {
            "gate_passed": bool(self.posting_params["gate_passed"]),
            "best_f1": self.posting_params.get("best_f1"),
            "gate_min_f1": self.config.get("gate_min_f1"),
            # Hand labels are ground truth, so the course mapping counts as
            # checked only when every course is labelled. Extraction, however its
            # parameters measured, is an estimate for each course it maps.
            "course_mapping_validated": bool(self.courses) and all(
                c.mapped_by == "labels" for c in self.courses.values()),
        }


def _read_csv(path: Path) -> list[dict[str, str]]:
    with path.open(encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f))


def _course_name(row: dict[str, str]) -> str:
    """The official title where the catalog has one, else the text before '. '."""
    title = (row.get("course_title") or "").strip()
    if title:
        return title
    head = row["course_text"].split(". ", 1)[0].strip()
    return head or row["course_text"][:60].strip()


def _course_labels(rows: list[dict[str, str]], valid_ids: set[str],
                   path: Path) -> dict[str, tuple[str, ...]]:
    """
    Hand labels by course code, in the format validate.py measures against: SK
    ids separated by ';', NONE for "labelled, teaches none of them", blank for
    "not labelled yet". An unknown id stops startup, as it stops validate.py.
    """
    labels: dict[str, tuple[str, ...]] = {}
    problems = []
    for lineno, row in enumerate(rows, start=2):
        raw = (row.get("skill_ids") or "").strip()
        if not raw:
            continue
        ids = (set() if raw.upper() == NO_SKILLS
               else {s.strip() for s in raw.split(SKILL_SEP) if s.strip()})
        unknown = sorted(ids - valid_ids)
        if unknown:
            problems.append(f"  line {lineno} ({row['course_code']}): "
                            f"unknown skill_id(s) {unknown}")
            continue
        labels[row["course_code"]] = tuple(sorted(ids))
    if problems:
        raise CourseLabelsError(
            f"{path} has labels that are not in the taxonomy:\n" + "\n".join(problems)
            + "\n\nSkill ids are the SK codes in skillgap/TAXONOMY_REFERENCE.md.")
    return labels


def _cache_key(paths: Paths, postings: list[dict], course_rows: list[dict],
               model: str) -> str:
    h = hashlib.sha256()
    h.update(f"v{CACHE_VERSION}|{model}".encode())
    for p in (paths.taxonomy, paths.config, ENGINE_DIR / "skillgap.py"):
        h.update(p.read_bytes())
    # Only the fields extraction reads. Relabelling a posting or a course does
    # not change what extraction finds, so it must not invalidate the cache.
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
    extracted = {code: tuple(v["skills"]) for code, v in data["courses"].items()}
    return profiles, extracted


def _save_cache(path: Path, key: str, profiles: dict,
                extracted: dict[str, tuple[str, ...]], names: dict[str, str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    # Written directly rather than via temp-and-rename: OneDrive refuses the
    # delete a rename-over needs. A torn write just fails to parse next time
    # and triggers a rebuild, so atomicity buys nothing here.
    path.write_text(json.dumps({
        "key": key,
        "profiles": {c: {"posting_count": p.posting_count, "demand": p.demand}
                     for c, p in profiles.items()},
        "courses": {code: {"name": names[code], "skills": list(skills)}
                    for code, skills in extracted.items()},
    }, ensure_ascii=False, indent=1), encoding="utf-8")


def build_state(paths: Paths | None = None,
                embedder_factory: Callable[[str], Any] | None = None) -> EngineState:
    """
    Build everything the API serves. Fails before any model work on a config
    swept against a different taxonomy (StaleConfigError), on course labels or
    online courses naming skills the taxonomy lacks (CourseLabelsError,
    OnlineCoursesError): better no service than one quietly serving around them.
    """
    paths = paths or Paths()
    config = json.loads(paths.config.read_text(encoding="utf-8"))
    posting_params = sg.load_match_params("postings", str(paths.config), str(paths.taxonomy))
    course_params = sg.load_match_params("courses", str(paths.config), str(paths.taxonomy))
    model = config["model"]

    skills = {s["id"]: {"en": s["en"], "ar": s["ar"], "category": s["category"]}
              for s in json.loads(paths.taxonomy.read_text(encoding="utf-8"))["skills"]}
    online = load_online_courses(paths.online_courses, set(skills))
    postings = _read_csv(paths.postings)
    course_rows = _read_csv(paths.courses)
    labels = _course_labels(course_rows, set(skills), paths.courses)
    names = {r["course_code"]: _course_name(r) for r in course_rows}

    key = _cache_key(paths, postings, course_rows, model)
    cache_file = paths.cache_dir / f"engine-{key[:20]}.json"
    cached = _load_cache(cache_file, key)

    if cached is not None:
        profiles, extracted = cached
        from_cache = True
    else:
        embedder = (embedder_factory or sg.Embedder)(model)
        tax = sg.Taxonomy(str(paths.taxonomy), embedder)

        by_career: dict[str, list[str]] = {}
        for r in postings:
            by_career.setdefault(r["career"], []).append(r["posting_text"].strip())
        profiles = {career: sg.build_career_profile(career, texts, tax, posting_params)
                    for career, texts in sorted(by_career.items())}

        extracted = {
            r["course_code"]: tuple(sorted(sg.skills_from_courses(
                [r["course_text"].strip()], tax, course_params)))
            for r in course_rows}
        _save_cache(cache_file, key, profiles, extracted, names)
        from_cache = False

    courses = {code: (Course(code, names[code], labels[code], "labels") if code in labels
                      else Course(code, names[code], extracted[code]))
               for code in names}

    return EngineState(skills=skills, profiles=profiles, courses=courses,
                       extracted=extracted, online=online,
                       posting_params=posting_params, course_params=course_params,
                       config=config, model=model, cache_key=key,
                       built_from_cache=from_cache)

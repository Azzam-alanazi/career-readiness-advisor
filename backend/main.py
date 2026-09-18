"""
FastAPI service over the skill-gap engine (spec Phase 3).

Run from the repo root, with the project virtualenv active:

    python -m uvicorn backend.main:app --reload

Every response that reports a readiness figure carries a `validation` block.
The matcher closed Phase 0 on a failed gate in both domains, and that fact
travels with the data it qualifies, so the app can show it beside the numbers
instead of leaving it in a changelog.

The app keeps the student's profile on the device and sends it with each
request to POST /gap and POST /recommendations, which store nothing. The
stored-profile endpoints under /profiles remain for scripted use.
"""
import math
from contextlib import asynccontextmanager
from pathlib import Path
from typing import Callable

from fastapi import FastAPI, HTTPException, Query, Request

from . import schemas as S
from .engine import MIN_DEMAND, REPO, EngineState, build_state
from .store import ProfileStore

DEFAULT_DB = REPO / "backend" / "data" / "profiles.sqlite3"


def percent(share: float) -> int:
    """
    A share as a whole percentage, halves rounded up, as the app displays them.
    Python's round() goes to the even neighbour, so a readiness of exactly 12.5%
    came back as 12 while the app, formatting the same share, showed 13.

    The share is a ratio of float demand weights, so an exact half can arrive a
    hair below it: 6 of 16 postings' weight is 0.37499999999999994, not 0.375.
    Rounding that noise away first keeps it at 38, which is also what the app
    shows from the 4-decimal `readiness` it is sent.
    """
    return math.floor(round(share * 100, 9) + 0.5)


def create_app(state_factory: Callable[[], EngineState] = build_state,
               db_path: Path = DEFAULT_DB) -> FastAPI:

    @asynccontextmanager
    async def lifespan(app: FastAPI):
        # All the expensive work happens here, once per process. A
        # StaleConfigError or OnlineCoursesError from the engine stops startup:
        # better no service than one applying parameters measured against
        # another taxonomy, or quietly skipping courses it could not read.
        app.state.engine = state_factory()
        app.state.store = ProfileStore(db_path)
        yield

    app = FastAPI(title="Career-Readiness Skill-Gap API", version="0.5.0",
                  lifespan=lifespan)

    def engine(request: Request) -> EngineState:
        return request.app.state.engine

    def store(request: Request) -> ProfileStore:
        return request.app.state.store

    def validation(eng: EngineState) -> S.ValidationInfo:
        v = eng.validation()
        if v["gate_passed"]:
            note = "Skill matching passed its validation gate."
        else:
            note = (f"Skill matching did not pass its validation gate (best F1 "
                    f"{v['best_f1']} against a {v['gate_min_f1']} floor). These "
                    f"figures are best-measured output, not validated output.")
        by_extraction = sum(c.mapped_by == "extraction" for c in eng.courses.values())
        if by_extraction:
            note += (f" {by_extraction} of {len(eng.courses)} courses are mapped to "
                     f"skills by extraction, not by hand labels.")
        return S.ValidationInfo(**v, note=note)

    def skill_entry(eng: EngineState, sid: str, demand: float) -> S.SkillEntry:
        meta = eng.skills.get(sid, {"en": sid, "ar": sid, "category": ""})
        return S.SkillEntry(id=sid, en=meta["en"], ar=meta["ar"],
                            category=meta["category"], demand=round(demand, 4),
                            demand_percent=percent(demand))

    def checked(eng: EngineState, career: str, courses: list[str],
                skills: list[str]) -> tuple[list[str], list[str]]:
        """The courses and skills without repeats, or a 422 naming what is unknown."""
        if career not in eng.profiles:
            raise HTTPException(422, detail={"error": "unknown career", "career": career,
                                             "known": [c for c, _ in eng.careers()]})
        codes = list(dict.fromkeys(courses))   # dedupe, keep order
        unknown = [c for c in codes if c not in eng.courses]
        if unknown:
            raise HTTPException(422, detail={"error": "unknown course codes",
                                             "unknown": unknown})
        reported = list(dict.fromkeys(skills))
        unknown = [s for s in reported if s not in eng.skills]
        if unknown:
            raise HTTPException(422, detail={"error": "unknown skill ids",
                                             "unknown": unknown})
        return codes, reported

    def gap_out(eng: EngineState, career: str, courses: list[str], reported: list[str],
                profile_id: str | None = None) -> S.GapOut:
        g = eng.gap_by_source(career, courses, reported)
        covered = [(s, w, g.source(s)) for s, w in g.combined.covered]
        return S.GapOut(
            profile_id=profile_id, career=career,
            readiness=round(g.combined.readiness, 4),
            readiness_percent=percent(g.combined.readiness),
            readiness_from_courses=round(g.from_courses.readiness, 4),
            readiness_from_courses_percent=percent(g.from_courses.readiness),
            covered=[S.CoveredSkill(**skill_entry(eng, s, w).model_dump(), source=src)
                     for s, w, src in covered],
            covered_from_courses=[skill_entry(eng, s, w)
                                  for s, w, src in covered if src == "courses"],
            covered_self_reported=[skill_entry(eng, s, w)
                                   for s, w, src in covered if src == "self_reported"],
            missing=[skill_entry(eng, s, w) for s, w in g.combined.missing],
            validation=validation(eng))

    def recommendations_out(eng: EngineState, career: str, courses: list[str],
                            reported: list[str], limit: int | None,
                            profile_id: str | None = None) -> S.RecommendationsOut:
        # Skills the student reports having are not gaps, so nothing is
        # suggested for them.
        g = eng.gap(career, courses, reported)
        missing = dict(g.missing)

        def refs(ids: list[str]) -> list[S.SkillRef]:
            return [S.SkillRef(id=s, en=eng.skills[s]["en"], ar=eng.skills[s]["ar"],
                               demand_percent=percent(missing[s]))
                    for s in ids]

        found = eng.recommendations(g, courses, limit)
        recs: list[S.Recommendation] = [
            S.UniversityRecommendation(code=c.code, name=c.name, closes=refs(closes),
                                       value=round(value, 4))
            for c, closes, value in found.university]
        recs += [
            S.OnlineRecommendation(provider=o.provider, title=o.title, url=o.url,
                                   is_free=o.is_free, closes=refs(closes),
                                   value=round(value, 4))
            for o, closes, value in found.online]
        return S.RecommendationsOut(profile_id=profile_id, career=career,
                                    recommendations=recs,
                                    uncovered=refs(found.uncovered),
                                    validation=validation(eng))

    def load_profile(request: Request, profile_id: str) -> tuple[EngineState, dict]:
        prof = store(request).get(profile_id)
        if prof is None:
            raise HTTPException(404, detail=f"no profile {profile_id!r}")
        eng = engine(request)
        # A career, course or skill dropped from the corpus, catalog or taxonomy
        # after the profile was saved simply stops counting; it is not an error
        # the student can fix. When the first career goes, the next one still
        # served takes its place. Only a profile left with no career at all
        # cannot be read.
        careers = [c for c in (prof["career"], *prof["other_careers"])
                   if c in eng.profiles]
        if not careers:
            raise HTTPException(409, detail=(f"career {prof['career']!r} is no "
                                             f"longer in the posting corpus"))
        prof["career"], prof["other_careers"] = careers[0], careers[1:]
        prof["completed_courses"] = [c for c in prof["completed_courses"]
                                     if c in eng.courses]
        prof["self_reported_skills"] = [s for s in prof["self_reported_skills"]
                                        if s in eng.skills]
        return eng, prof

    def profile_out(prof: dict) -> S.ProfileOut:
        return S.ProfileOut(**prof, careers=[prof["career"], *prof["other_careers"]])

    def target_career(prof: dict, career: str | None) -> str:
        """The career to read a profile against: its first, or another it names."""
        if career is None:
            return prof["career"]
        careers = [prof["career"], *prof["other_careers"]]
        if career not in careers:
            raise HTTPException(422, detail={"error": "career not in this profile",
                                             "career": career, "careers": careers})
        return career

    career_query = Query(None, description="One of the profile's careers; its first "
                                           "when omitted")
    limit_query = Query(None, ge=1, le=50,
                        description="Cap on each list, university and online; all when "
                                    "omitted")

    @app.get("/health", response_model=S.HealthOut)
    def health(request: Request) -> S.HealthOut:
        eng = engine(request)
        return S.HealthOut(status="ok", model=eng.model,
                           taxonomy_skills=len(eng.skills),
                           careers=len(eng.profiles), courses=len(eng.courses),
                           online_courses=len(eng.online.courses),
                           online_placeholders=eng.online.placeholders,
                           built_from_cache=eng.built_from_cache,
                           validation=validation(eng))

    @app.get("/careers", response_model=list[S.CareerOut])
    def careers(request: Request) -> list[S.CareerOut]:
        return [S.CareerOut(name=c, posting_count=n)
                for c, n in engine(request).careers()]

    @app.get("/courses", response_model=list[S.CourseOut])
    def courses(request: Request) -> list[S.CourseOut]:
        eng = engine(request)
        return [S.CourseOut(code=c.code, name=c.name, skill_count=len(c.skills),
                            skills=list(c.skills), mapped_by=c.mapped_by, track=c.track)
                for c in sorted(eng.courses.values(), key=lambda c: c.code)]

    @app.get("/skills", response_model=list[S.SkillOut])
    def skills(request: Request) -> list[S.SkillOut]:
        return [S.SkillOut(id=sid, **meta) for sid, meta in engine(request).skills.items()]

    # ---- a profile sent with the request: what the app uses --------------------

    @app.post("/gap", response_model=S.GapOut)
    def gap_for(body: S.StudentIn, request: Request) -> S.GapOut:
        """The gap for a profile sent with the request. Nothing is stored."""
        eng = engine(request)
        codes, reported = checked(eng, body.career, body.completed_courses,
                                  body.self_reported_skills)
        return gap_out(eng, body.career, codes, reported)

    @app.post("/recommendations", response_model=S.RecommendationsOut)
    def recommendations_for(body: S.StudentIn, request: Request,
                            limit: int | None = limit_query) -> S.RecommendationsOut:
        """Suggestions for a profile sent with the request. Nothing is stored."""
        eng = engine(request)
        codes, reported = checked(eng, body.career, body.completed_courses,
                                  body.self_reported_skills)
        return recommendations_out(eng, body.career, codes, reported, limit)

    # ---- stored profiles: kept for scripted use --------------------------------

    @app.post("/profiles", response_model=S.ProfileOut, status_code=201)
    def create_profile(body: S.ProfileIn, request: Request) -> S.ProfileOut:
        eng = engine(request)
        codes, reported = checked(eng, body.career, body.completed_courses,
                                  body.self_reported_skills)
        others = [c for c in dict.fromkeys(body.other_careers) if c != body.career]
        unknown = [c for c in others if c not in eng.profiles]
        if unknown:
            raise HTTPException(422, detail={"error": "unknown careers",
                                             "unknown": unknown,
                                             "known": [c for c, _ in eng.careers()]})
        return profile_out(store(request).create(body.career, body.major, codes,
                                                 reported, others))

    @app.get("/profiles/{profile_id}", response_model=S.ProfileOut)
    def get_profile(profile_id: str, request: Request) -> S.ProfileOut:
        prof = store(request).get(profile_id)
        if prof is None:
            raise HTTPException(404, detail=f"no profile {profile_id!r}")
        return profile_out(prof)

    @app.get("/profiles/{profile_id}/gap", response_model=S.GapOut)
    def gap(profile_id: str, request: Request,
            career: str | None = career_query) -> S.GapOut:
        eng, prof = load_profile(request, profile_id)
        return gap_out(eng, target_career(prof, career), prof["completed_courses"],
                       prof["self_reported_skills"], profile_id)

    @app.get("/profiles/{profile_id}/recommendations",
             response_model=S.RecommendationsOut)
    def recommendations(profile_id: str, request: Request,
                        career: str | None = career_query,
                        limit: int | None = limit_query) -> S.RecommendationsOut:
        eng, prof = load_profile(request, profile_id)
        return recommendations_out(eng, target_career(prof, career),
                                   prof["completed_courses"], prof["self_reported_skills"],
                                   limit, profile_id)

    # ---- the department's view --------------------------------------------------

    def sample_note(eng: EngineState) -> str:
        per = sorted(p.posting_count for p in eng.profiles.values())
        if not per:
            return "Based on no job postings: there is nothing to compare the catalog with."
        spread = f"{per[0]}" if per[0] == per[-1] else f"{per[0]} to {per[-1]}"
        return (f"Based on {sum(per)} job postings, {spread} per career. At this size "
                f"the gaps are indicative: a skill one or two postings mention can "
                f"appear or vanish with the next few. They should not drive curriculum "
                f"decisions on their own.")

    @app.get("/curriculum/gap", response_model=S.CurriculumGapOut)
    def curriculum_gap(request: Request,
                       career: str | None = Query(
                           None, description="One career's view; every career's when "
                                             "omitted")) -> S.CurriculumGapOut:
        eng = engine(request)
        if career is not None and career not in eng.profiles:
            raise HTTPException(422, detail={"error": "unknown career", "career": career,
                                             "known": [c for c, _ in eng.careers()]})
        cg = eng.curriculum(career)
        n = cg.posting_count
        return S.CurriculumGapOut(
            career=career, posting_count=n, min_demand=MIN_DEMAND,
            demanded=len(cg.demanded), taught=len(cg.taught),
            coverage=round(cg.coverage, 4), coverage_percent=percent(cg.coverage),
            uncovered=[S.CurriculumSkill(id=s, **eng.skills[s], postings=cg.demanded[s],
                                         demand=round(cg.demanded[s] / n, 4),
                                         demand_percent=percent(cg.demanded[s] / n),
                                         careers=list(cg.demanded_by[s]))
                       for s in cg.uncovered],
            not_asked=[S.TaughtSkill(id=s, **eng.skills[s], courses=list(codes))
                       for s, codes in cg.not_asked],
            below_threshold=[S.BelowThresholdSkill(id=s, **eng.skills[s], postings=count,
                                                   careers=list(careers),
                                                   courses=list(codes))
                             for s, count, careers, codes in cg.below_threshold],
            per_career=[S.CareerCoverageOut(career=c.career, posting_count=c.posting_count,
                                            demanded=c.demanded, taught=c.taught,
                                            coverage=round(c.coverage, 4),
                                            coverage_percent=percent(c.coverage),
                                            min_postings=c.min_postings)
                        for c in cg.per_career],
            sample_note=sample_note(eng),
            validation=validation(eng))

    return app


app = create_app()

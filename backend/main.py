"""
FastAPI service over the skill-gap engine (spec Phase 3).

Run from the repo root, with the project virtualenv active:

    python -m uvicorn backend.main:app --reload

Every response that reports a readiness figure carries a `validation` block.
The matcher closed Phase 0 on a failed gate -- best F1 0.503 against a 0.60
floor -- and that fact travels with the data it qualifies, so the app can show it
beside the numbers instead of leaving it in a changelog.
"""
from contextlib import asynccontextmanager
from pathlib import Path
from typing import Callable

from fastapi import FastAPI, HTTPException, Query, Request

from . import schemas as S
from .engine import REPO, EngineState, build_state
from .store import ProfileStore

DEFAULT_DB = REPO / "backend" / "data" / "profiles.sqlite3"


def create_app(state_factory: Callable[[], EngineState] = build_state,
               db_path: Path = DEFAULT_DB) -> FastAPI:

    @asynccontextmanager
    async def lifespan(app: FastAPI):
        # All the expensive work happens here, once per process. A
        # StaleConfigError from the engine stops startup: better no service
        # than one applying parameters measured against another taxonomy.
        app.state.engine = state_factory()
        app.state.store = ProfileStore(db_path)
        yield

    app = FastAPI(title="Career-Readiness Skill-Gap API", version="0.1.0",
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
        if not v["course_mapping_validated"]:
            note += (" Course-to-skill mapping has never been measured against "
                     "labelled courses.")
        return S.ValidationInfo(**v, note=note)

    def skill_entry(eng: EngineState, sid: str, demand: float) -> S.SkillEntry:
        meta = eng.skills.get(sid, {"en": sid, "ar": sid, "category": ""})
        return S.SkillEntry(id=sid, en=meta["en"], ar=meta["ar"],
                            category=meta["category"], demand=round(demand, 4),
                            demand_percent=round(demand * 100))

    def load_profile(request: Request, profile_id: str) -> tuple[EngineState, dict]:
        prof = store(request).get(profile_id)
        if prof is None:
            raise HTTPException(404, detail=f"no profile {profile_id!r}")
        eng = engine(request)
        if prof["career"] not in eng.profiles:
            raise HTTPException(409, detail=(f"career {prof['career']!r} is no "
                                             f"longer in the posting corpus"))
        # A course dropped from the catalog after the profile was saved simply
        # stops counting; it is not an error the student can fix.
        prof["completed_courses"] = [c for c in prof["completed_courses"]
                                     if c in eng.courses]
        return eng, prof

    @app.get("/health", response_model=S.HealthOut)
    def health(request: Request) -> S.HealthOut:
        eng = engine(request)
        return S.HealthOut(status="ok", model=eng.model,
                           taxonomy_skills=len(eng.skills),
                           careers=len(eng.profiles), courses=len(eng.courses),
                           built_from_cache=eng.built_from_cache,
                           validation=validation(eng))

    @app.get("/careers", response_model=list[S.CareerOut])
    def careers(request: Request) -> list[S.CareerOut]:
        return [S.CareerOut(name=c, posting_count=n)
                for c, n in engine(request).careers()]

    @app.get("/courses", response_model=list[S.CourseOut])
    def courses(request: Request) -> list[S.CourseOut]:
        eng = engine(request)
        return [S.CourseOut(code=c.code, name=c.name, skill_count=len(c.skills))
                for c in sorted(eng.courses.values(), key=lambda c: c.code)]

    @app.post("/profiles", response_model=S.ProfileOut, status_code=201)
    def create_profile(body: S.ProfileIn, request: Request) -> S.ProfileOut:
        eng = engine(request)
        if body.career not in eng.profiles:
            raise HTTPException(422, detail={"error": "unknown career",
                                             "career": body.career,
                                             "known": [c for c, _ in eng.careers()]})
        codes = list(dict.fromkeys(body.completed_courses))   # dedupe, keep order
        unknown = [c for c in codes if c not in eng.courses]
        if unknown:
            raise HTTPException(422, detail={"error": "unknown course codes",
                                             "unknown": unknown})
        return S.ProfileOut(**store(request).create(body.career, body.major, codes))

    @app.get("/profiles/{profile_id}", response_model=S.ProfileOut)
    def get_profile(profile_id: str, request: Request) -> S.ProfileOut:
        prof = store(request).get(profile_id)
        if prof is None:
            raise HTTPException(404, detail=f"no profile {profile_id!r}")
        return S.ProfileOut(**prof)

    @app.get("/profiles/{profile_id}/gap", response_model=S.GapOut)
    def gap(profile_id: str, request: Request) -> S.GapOut:
        eng, prof = load_profile(request, profile_id)
        g = eng.gap(prof["career"], prof["completed_courses"])
        return S.GapOut(profile_id=profile_id, career=prof["career"],
                        readiness=round(g.readiness, 4),
                        readiness_percent=round(g.readiness * 100),
                        covered=[skill_entry(eng, s, w) for s, w in g.covered],
                        missing=[skill_entry(eng, s, w) for s, w in g.missing],
                        validation=validation(eng))

    @app.get("/profiles/{profile_id}/recommendations",
             response_model=S.RecommendationsOut)
    def recommendations(profile_id: str, request: Request,
                        limit: int = Query(3, ge=1, le=20)) -> S.RecommendationsOut:
        eng, prof = load_profile(request, profile_id)
        g = eng.gap(prof["career"], prof["completed_courses"])
        missing = dict(g.missing)
        recs = []
        for course, closes, value in eng.recommendations(
                g, prof["completed_courses"], limit):
            refs = [S.SkillRef(id=s, en=eng.skills[s]["en"], ar=eng.skills[s]["ar"],
                               demand_percent=round(missing[s] * 100))
                    for s in closes]
            recs.append(S.RecommendationOut(code=course.code, name=course.name,
                                            closes=refs, value=round(value, 4)))
        return S.RecommendationsOut(profile_id=profile_id, career=prof["career"],
                                    recommendations=recs,
                                    validation=validation(eng))

    return app


app = create_app()

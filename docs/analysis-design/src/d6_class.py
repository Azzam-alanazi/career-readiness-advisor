"""Section 6: class diagrams."""
from uml import Canvas, QUIET, F_INTERFACE, F_ENUM, F_EXTERNAL

UTIL = "#F1ECF9"


def _assoc(c, pts, label=None, at=None, mult_a=None, mult_b=None, start=None, end="open",
           anchor="middle", dash=None):
    c.path(pts, start=start, end=end, dash=dash)
    if label:
        c.text(at[0], at[1], label, size=11, fill=QUIET, anchor=anchor, halo=True)
    if mult_a:
        (x, y), t = mult_a
        c.text(x, y, t, size=11, anchor="middle", halo=True)
    if mult_b:
        (x, y), t = mult_b
        c.text(x, y, t, size=11, anchor="middle", halo=True)


def engine_core() -> Canvas:
    c = Canvas(1400, 760,
               "Class diagram: the skill-gap engine (skillgap/skillgap.py)",
               "The matcher, the taxonomy it embeds, and the two results the service reads: a "
               "career's demand profile and a student's gap.")
    c.package(24, 76, 1352, 664, "skillgap.py")
    emb = c.class_box(48, 140, "Embedder", [
        "+ model: SentenceTransformer",
        "+ prefix: str = \"query: \"",
    ], ["+ encode(texts: list[str]): ndarray"])
    tax = c.class_box(470, 140, "Taxonomy", [
        "+ skills: list[Skill]",
        "+ embedder: Embedder",
        "- _label_vecs: ndarray   (en + ar labels)",
        "- _owner: ndarray",
    ], [
        "+ match(chunks, threshold): dict[str, float]",
        "+ skill_scores(chunks): ndarray",
        "+ match_chunk_top1(chunks, threshold, margin)",
        "+ match_auto(chunks, params): dict[str, float]",
        "+ name(skill_id): str",
    ])
    skill = c.class_box(1010, 140, "Skill", [
        "+ id: str", "+ en: str", "+ ar: str", "+ category: str",
    ], stereo="«dataclass»")
    err = c.class_box(1010, 330, "StaleConfigError", [], [], stereo="«exception»")
    rt = c.class_box(1210, 330, "RuntimeError", [], [], head_fill=F_EXTERNAL)
    prof = c.class_box(48, 470, "CareerProfile", [
        "+ career: str", "+ posting_count: int", "+ demand: dict[str, float]",
    ], ["+ top(n = 10): list[(str, float)]"], stereo="«dataclass»")
    gap = c.class_box(330, 470, "GapResult", [
        "+ career: str", "+ readiness: float  (0..1)",
        "+ covered: list[(str, float)]", "+ missing: list[(str, float)]",
    ], stereo="«dataclass»")
    util = c.class_box(700, 450, "skillgap", [], [
        "+ split_chunks(text, min_len = 15): list[str]",
        "+ load_match_params(domain, path, taxonomy_path): dict",
        "+ build_career_profile(career, postings, tax, params): CareerProfile",
        "+ skills_from_courses(texts, tax, params): set[str]",
        "+ analyze_gap(profile, acquired, min_demand = 0.15): GapResult",
        "+ recommend(gap, catalog, tax, limit = 5): list[dict]",
        "+ cosine_matrix(a, b): ndarray",
    ], stereo="«utility» module functions", head_fill=UTIL)

    _assoc(c, [(tax.x, 200), (emb.right, 200)], label="embeds with", at=((tax.x + emb.right) / 2, 192),
           mult_b=((emb.right + 16, 216), "1"))
    _assoc(c, [(tax.right, 200), (skill.x, 200)], start="diamond", end="open",
           mult_b=((skill.x - 18, 216), "91"))
    c.text((tax.right + skill.x) / 2, 192, "skills", size=11, fill=QUIET, anchor="middle")
    c.path([(err.right, err.cy), (rt.x, err.cy)], end="hollow")
    c.path([(util.x + 60, util.y), (util.x + 60, tax.bottom)], end="open", dash="6 4",
           label="«use»", label_at=(util.x + 66, (util.y + tax.bottom) / 2), label_anchor="start")
    c.path([(util.x, util.y + 90), (gap.right, util.y + 90)], end="open", dash="6 4",
           label="«create»", label_at=((util.x + gap.right) / 2, util.y + 82))
    c.path([(util.x + 20, util.bottom), (util.x + 20, 700), (prof.cx, 700), (prof.cx, prof.bottom)],
           end="open", dash="6 4", label="«create»", label_at=(util.x - 120, 694))
    c.path([(util.right - 80, util.y), (util.right - 80, err.bottom + 30), (err.cx, err.bottom + 30),
            (err.cx, err.bottom)], end="open", dash="6 4")
    c.text(util.right - 74, err.bottom + 50, "«throw» on a stale config", size=11, fill=QUIET)
    return c


def service() -> Canvas:
    c = Canvas(1580, 1120,
               "Class diagram: the service holds one EngineState and builds every answer from it",
               "backend/engine.py, online.py and main.py. Diamonds are composition; dashed "
               "arrows are dependencies. Grey classes come from skillgap.py.")
    paths = c.class_box(24, 84, "Paths", [
        "+ taxonomy: Path", "+ config: Path", "+ postings: Path", "+ courses: Path",
        "+ online_courses: Path", "+ cache_dir: Path",
    ], stereo="«dataclass, frozen»")
    build = c.class_box(300, 84, "engine", [], [
        "+ build_state(paths?, embedder_factory?): EngineState",
        "+ min_postings(posting_count, min_demand = 0.15): int",
        "- _extract(postings, course_rows, tax, …): (profiles, extracted)",
        "- _cache_key(paths, postings, course_rows, model): str",
        "- _load_cache(path, key) · _save_cache(path, key, …)",
    ], stereo="«utility» module functions", head_fill=UTIL)
    api = c.class_box(1010, 84, "main.py", [
        "+ app: FastAPI", "+ app.state.engine: EngineState",
    ], [
        "+ create_app(state_factory = build_state): FastAPI",
        "+ percent(share: float): int   (halves round up)",
        "GET /health · /careers · /courses · /skills",
        "GET /curriculum/gap(career?)",
        "POST /gap(StudentIn) · POST /recommendations(StudentIn, limit?)",
    ], stereo="«FastAPI app»", head_fill=UTIL)

    eng = c.class_box(560, 400, "EngineState", [
        "+ skills: dict[str, {en, ar, category}]",
        "+ profiles: dict[str, CareerProfile]",
        "+ courses: dict[str, Course]",
        "+ extracted: dict[str, tuple[str]]",
        "+ online: OnlineCatalog",
        "+ posting_params · course_params · config: dict",
        "+ model: str · cache_key: str",
        "+ built_from_cache: bool",
    ], [
        "+ careers(): list[(str, int)]",
        "+ acquired(course_codes): set[str]",
        "+ gap(career, course_codes, self_reported = ()): GapResult",
        "+ gap_by_source(career, course_codes, self_reported): SourcedGap",
        "+ recommendations(gap, completed, limit?): Suggestions",
        "+ demanded(career): dict[str, float]",
        "+ taught_by(): dict[str, tuple[str]]",
        "+ curriculum(career?): CurriculumGap",
        "+ validation(): dict",
    ], stereo="«dataclass»")
    course = c.class_box(24, 400, "Course", [
        "+ code: str", "+ name: str", "+ skills: tuple[str]",
        "+ mapped_by: str = \"extraction\"", "+ track: str = \"\"",
    ], stereo="«dataclass, frozen»")
    prof = c.class_box(24, 640, "CareerProfile", ["+ career · posting_count · demand"],
                       head_fill=F_EXTERNAL)
    gres = c.class_box(24, 790, "GapResult", ["+ career · readiness · covered · missing"],
                       head_fill=F_EXTERNAL)
    cat = c.class_box(1150, 400, "OnlineCatalog", [
        "+ courses: tuple[OnlineCourse]", "+ placeholders: int",
    ], stereo="«dataclass, frozen»")
    oc = c.class_box(1150, 560, "OnlineCourse", [
        "+ provider: str", "+ title: str", "+ url: str", "+ is_free: bool",
        "+ skills: tuple[str]",
    ], stereo="«dataclass, frozen»")
    onl = c.class_box(1150, 760, "online", [], [
        "+ load_online_courses(path, valid_ids): OnlineCatalog",
        "+ sync(path, skill_ids) · status(state, path)",
    ], stereo="«utility» module functions", head_fill=UTIL)

    sg = c.class_box(300, 930, "SourcedGap", [
        "+ combined: GapResult", "+ from_courses: GapResult", "+ course_skills: frozenset[str]",
    ], ["+ source(skill_id): str"], stereo="«dataclass, frozen»")
    sug = c.class_box(600, 930, "Suggestions", [
        "+ university: list[(Course, closes, value)]",
        "+ online: list[(OnlineCourse, closes, value)]",
        "+ uncovered: list[str]",
    ], stereo="«dataclass, frozen»")
    cg = c.class_box(950, 930, "CurriculumGap", [
        "+ careers · posting_count · demanded · taught",
        "+ uncovered · not_asked · below_threshold",
        "+ per_career: list[CareerCoverage]",
    ], ["+ coverage: float  «property»"], stereo="«dataclass, frozen»")
    cc = c.class_box(1300, 930, "CareerCoverage", [
        "+ career · posting_count",
        "+ demanded · taught · min_postings",
    ], ["+ coverage: float  «property»"], stereo="«dataclass, frozen»")
    names = c.class_box(24, 960, "SkillNames", ["- _skills: dict"], ["+ name(skill_id): str"])
    oerr = c.class_box(1340, 640, "OnlineCoursesError", [], [], stereo="«exception»")
    c.path([(oerr.cx, onl.y), (oerr.cx, oerr.bottom)], end="open", dash="6 4")
    c.text(oerr.cx + 6, (onl.y + oerr.bottom) / 2 + 4, "«throw»", size=11, fill=QUIET)

    # composition: what an EngineState holds
    _assoc(c, [(eng.x, eng.y + 60), (course.right, eng.y + 60)], start="diamond", end="open",
           mult_b=((course.right + 16, eng.y + 76), "33"))
    c.text((eng.x + course.right) / 2, eng.y + 52, "courses", size=11, fill=QUIET, anchor="middle")
    _assoc(c, [(eng.x, eng.y + 260), (300, eng.y + 260), (300, prof.cy), (prof.right, prof.cy)],
           start="diamond", end="open", mult_b=((prof.right + 14, prof.cy + 16), "8"))
    c.text(306, eng.y + 252, "profiles", size=11, fill=QUIET)
    _assoc(c, [(eng.right, cat.y + 30), (cat.x, cat.y + 30)], start="diamond", end="open",
           mult_b=((cat.x - 12, cat.y + 46), "1"))
    c.text((eng.right + cat.x) / 2, cat.y + 22, "online", size=11, fill=QUIET, anchor="middle")
    _assoc(c, [(cat.cx, cat.bottom), (cat.cx, oc.y)], start="diamond", end="open",
           mult_b=((cat.cx + 20, oc.y - 6), "28"))
    # dependencies
    dep = dict(end="open", dash="6 4")
    c.path([(eng.x + 40, build.bottom), (eng.x + 40, eng.y)], **dep, label="«create»",
           label_at=(eng.x + 46, (build.bottom + eng.y) / 2), label_anchor="start")
    lerr = c.class_box(300, 300, "CourseLabelsError", [], [], stereo="«exception»")
    c.path([(lerr.cx, build.bottom), (lerr.cx, lerr.y)], **dep, label="«throw»",
           label_at=(lerr.cx + 6, (build.bottom + lerr.y) / 2 + 4), label_anchor="start")
    c.path([(build.x, 150), (paths.right, 150)], **dep, label="«read»",
           label_at=((build.x + paths.right) / 2, 142))
    c.path([(api.x + 60, api.bottom), (api.x + 60, 360), (eng.right - 60, 360), (eng.right - 60, eng.y)],
           **dep, label="«use» app.state.engine", label_at=(api.x + 66, 380), label_anchor="start")
    c.path([(oc.cx, onl.y), (oc.cx, oc.bottom)], **dep, label="«create»",
           label_at=(oc.cx + 6, (onl.y + oc.bottom) / 2 + 4), label_anchor="start")
    c.path([(sg.cx, sg.y), (sg.cx, eng.bottom + 30), (eng.x + 60, eng.bottom + 30),
            (eng.x + 60, eng.bottom)], start="open", dash="6 4")
    c.path([(sug.cx, sug.y), (sug.cx, eng.bottom)], start="open", dash="6 4")
    c.text(sug.cx + 6, (sug.y + eng.bottom) / 2, "«create»", size=11, fill=QUIET)
    c.path([(cg.cx, cg.y), (cg.cx, eng.bottom + 30), (eng.right - 60, eng.bottom + 30),
            (eng.right - 60, eng.bottom)], start="open", dash="6 4")
    _assoc(c, [(cg.right, cg.cy), (cc.x, cg.cy)], start="diamond", end="open",
           mult_b=((cc.x - 12, cg.cy + 16), "8"))
    c.path([(sg.x, sg.y + 50), (gres.right + 30, sg.y + 50), (gres.right + 30, gres.cy),
            (gres.right, gres.cy)], end="open")
    c.text(gres.right + 36, gres.cy - 8, "2", size=11)
    c.text(names.x, names.y - 10, "passed to skillgap.recommend()", size=11, fill=QUIET)
    return c


def dtos() -> Canvas:
    c = Canvas(1560, 1010,
               "Class diagram: the API's request and response objects (backend/schemas.py)",
               "Pydantic models. Every response that carries a figure also carries ValidationInfo, "
               "so the app can show the failed quality gate beside it.")
    sin = c.class_box(24, 84, "StudentIn", [
        "+ career: str  (≤ 200 chars)",
        "+ completed_courses: list[str]  (≤ 200)",
        "+ self_reported_skills: list[str]  (≤ 200)",
    ], stereo="«request»", head_fill="#EAF5EA")
    cout = c.class_box(330, 84, "CareerOut", ["+ name: str", "+ posting_count: int"])
    health = c.class_box(550, 84, "HealthOut", [
        "+ status: str", "+ model: str", "+ taxonomy_skills: int", "+ careers: int",
        "+ courses: int", "+ online_courses: int", "+ online_placeholders: int",
        "+ built_from_cache: bool", "+ validation: ValidationInfo",
    ], w=200)
    sout = c.class_box(900, 84, "SkillOut", ["+ id, en, ar, category: str"])
    crs = c.class_box(1130, 84, "CourseOut", [
        "+ code: str", "+ name: str", "+ skill_count: int", "+ skills: list[str]",
        "+ mapped_by: \"labels\" | \"extraction\"", "+ track: str",
    ])
    gap = c.class_box(24, 320, "GapOut", [
        "+ career: str", "+ readiness: float", "+ readiness_percent: int",
        "+ readiness_from_courses: float", "+ readiness_from_courses_percent: int",
        "+ covered: list[CoveredSkill]", "+ covered_from_courses: list[SkillEntry]",
        "+ covered_self_reported: list[SkillEntry]", "+ missing: list[SkillEntry]",
        "+ validation: ValidationInfo",
    ])
    val = c.class_box(545, 470, "ValidationInfo", [
        "+ gate_passed: bool", "+ best_f1: float | None", "+ gate_min_f1: float | None",
        "+ course_mapping_validated: bool", "+ note: str",
    ], w=210, head_fill=F_ENUM)
    recs = c.class_box(1000, 320, "RecommendationsOut", [
        "+ career: str", "+ recommendations: list[Recommendation]",
        "+ uncovered: list[SkillRef]", "+ validation: ValidationInfo",
    ])
    rec = c.class_box(1330, 330, "Recommendation", ["discriminator: source"], stereo="«union»",
                      w=200)
    uni = c.class_box(1120, 520, "UniversityRecommendation", [
        "+ source = \"university\"", "+ code: str", "+ name: str",
        "+ closes: list[SkillRef]", "+ value: float",
    ])
    onl = c.class_box(1340, 520, "OnlineRecommendation", [
        "+ source = \"online\"", "+ provider: str", "+ title: str", "+ url: str",
        "+ is_free: bool", "+ closes: list[SkillRef]", "+ value: float",
    ], w=196)
    sref = c.class_box(1240, 830, "SkillRef", ["+ id, en, ar: str", "+ demand_percent: int"])
    se = c.class_box(24, 600, "SkillEntry", [
        "+ id, en, ar, category: str", "+ demand: float", "+ demand_percent: int",
    ])
    cov = c.class_box(270, 600, "CoveredSkill", ["+ source: \"courses\" |", "  \"self_reported\""])
    cgo = c.class_box(505, 680, "CurriculumGapOut", [
        "+ career: str | None", "+ posting_count: int", "+ min_demand: float",
        "+ demanded: int", "+ taught: int", "+ coverage: float", "+ coverage_percent: int",
        "+ uncovered: list[CurriculumSkill]", "+ not_asked: list[TaughtSkill]",
        "+ below_threshold: list[BelowThresholdSkill]", "+ per_career: list[CareerCoverageOut]",
        "+ sample_note: str", "+ validation: ValidationInfo",
    ], w=290)
    csk = c.class_box(24, 740, "CurriculumSkill", [
        "+ id, en, ar, category: str", "+ postings: int", "+ demand: float",
        "+ demand_percent: int", "+ careers: list[str]",
    ])
    tsk = c.class_box(24, 880, "TaughtSkill", ["+ id, en, ar, category: str", "+ courses: list[str]"])
    bts = c.class_box(830, 680, "BelowThresholdSkill", [
        "+ id, en, ar, category: str", "+ postings: int", "+ careers: list[str]",
        "+ courses: list[str]",
    ])
    cco = c.class_box(830, 820, "CareerCoverageOut", [
        "+ career: str", "+ posting_count: int", "+ demanded · taught: int",
        "+ coverage: float", "+ coverage_percent: int", "+ min_postings: int",
    ])

    comp = dict(start="diamond", end="open")
    c.path([(health.cx, health.bottom), (health.cx, val.y)], **comp)
    c.path([(gap.right, 480), (val.x, 480)], **comp)
    c.path([(recs.x, 400), (850, 400), (850, 520), (val.right, 520)], **comp)
    c.path([(cgo.cx, cgo.y), (cgo.cx, val.bottom)], **comp)
    c.text(cgo.cx + 8, cgo.y - 30, "every response carries one", size=11, fill=QUIET)
    c.path([(recs.right, 360), (rec.x, 360)], **comp)
    c.text(recs.right + 8, 376, "0..*", size=11)
    # the union's two members
    bus_y = 490
    c.path([(uni.cx, uni.y), (uni.cx, bus_y), (rec.cx, bus_y), (rec.cx, rec.bottom)], end="hollow")
    c.path([(onl.cx, onl.y), (onl.cx, bus_y), (rec.cx, bus_y)])
    c.path([(onl.cx, onl.bottom), (onl.cx, sref.cy), (sref.right, sref.cy)], **comp)
    c.path([(uni.cx, uni.bottom), (uni.cx, sref.y - 20), (sref.cx - 20, sref.y - 20), (sref.cx - 20, sref.y)],
           **comp)
    c.text(uni.cx + 8, uni.bottom + 16, "closes 1..*", size=11, fill=QUIET)
    c.path([(recs.x + 60, recs.bottom), (recs.x + 60, sref.cy + 10), (sref.x, sref.cy + 10)], **comp)
    c.text(recs.x + 66, recs.bottom + 16, "uncovered 0..*", size=11, fill=QUIET)
    # gap entries
    c.path([(80, gap.bottom), (80, se.y)], **comp)
    c.lines(88, gap.bottom + 16, ["covered_from_courses,", "covered_self_reported,", "missing"],
            size=11, fill=QUIET, lh=13)
    c.path([(cov.x, cov.y + 40), (se.right, cov.y + 40)], end="hollow")
    c.path([(gap.right, 505), (cov.cx, 505), (cov.cx, cov.y)], **comp)
    # curriculum parts
    c.path([(cgo.x, csk.cy), (csk.right, csk.cy)], **comp)
    c.path([(cgo.x, tsk.cy), (tsk.right, tsk.cy)], **comp)
    c.path([(cgo.right, bts.cy), (bts.x, bts.cy)], **comp)
    c.path([(cgo.right, cco.cy), (cco.x, cco.cy)], **comp)
    return c


ALL = [("6a_class_engine", engine_core), ("6b_class_service", service), ("6c_class_api", dtos)]

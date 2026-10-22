"""Section 1, the UML model: component, deployment and package diagrams."""
from uml import Canvas, F_EXTERNAL, F_STORE, QUIET


def component() -> Canvas:
    c = Canvas(1560, 990,
               "Component diagram: the app reaches the engine only through a stateless REST API",
               "Career Readiness Advisor, as built on 17 October 2026. Dashed arrows are "
               "dependencies («use», «create», «read», «write»).")
    use = dict(end="open", dash="6 4")

    # ---- the iPhone app -----------------------------------------------------
    c.package(24, 80, 456, 790, "iPhone app (Flutter 3, Cupertino UI)", stereo="«device»")
    x, w = 46, 412
    screens = c.component(x, 134, w, ["Presentation"], [
        "HomeShell: CupertinoTabScaffold, a stack per tab",
        "OnboardingScreen · SkillsScreen · DashboardScreen",
        "ReadinessScreen · PlanningScreen · SettingsScreen",
        "RecommendationsScreen · CurriculumScreen",
    ])
    state = c.component(x, screens.bottom + 34, w, ["State (Riverpod 3)"], [
        "SavedProfile · OnboardingController · LocaleController",
        "CurriculumScope · servedProfileProvider",
        "catalog, gap, suggestion and curriculum providers",
    ])
    domain = c.component(x, state.bottom + 34, w, ["Domain models (freezed)"], [
        "StudentProfile · GapQuery · GapReport · SkillEntry",
        "Recommendation (university | online) · CurriculumGap",
        "Career · Course · Skill · ValidationInfo · ServedIds",
    ])
    data = c.component(x, domain.bottom + 34, w, ["Data access"], [
        "CatalogRepository · GapRepository",
        "RecommendationsRepository · CurriculumRepository",
        "ApiClient: HTTP + JSON, UTF-8, 15 s timeout",
    ])
    store = c.component(x, data.bottom + 34, 196, ["ProfileStore"], [
        "PrefsProfileStore over",
        "shared_preferences",
        "saves and loads the profile",
        "and the language",
    ])
    prefs = c.artifact(266, store.y + 14, 192, ["NSUserDefaults"],
                       ["student_profile (JSON)", "language: en | ar", "on this device only"],
                       stereo="«store»", fill=F_STORE)
    c.path([store.right_at(0.5), (prefs.x, store.cy)], **use)

    c.path([screens.bottom_at(0.5), state.top_at(0.5)], **use, label="«use»",
           label_at=(screens.cx + 10, screens.bottom + 21), label_anchor="start")
    c.path([state.bottom_at(0.5), domain.top_at(0.5)], **use, label="«use»",
           label_at=(state.cx + 10, state.bottom + 21), label_anchor="start")
    c.path([state.left_at(0.4), (34, state.y + state.h * 0.4), (34, data.cy), data.left_at(0.5)],
           **use)
    c.path([state.left_at(0.7), (40, state.y + state.h * 0.7), (40, store.cy), store.left_at(0.5)],
           **use)
    c.path([data.top_at(0.5), domain.bottom_at(0.5)], **use, label="«create»",
           label_at=(data.cx + 10, domain.bottom + 21), label_anchor="start")

    # ---- the API ------------------------------------------------------------
    c.package(590, 80, 470, 560, "Skill-gap API (FastAPI, Python)", stereo="«server»")
    ax, aw = 612, 426
    rest = c.component(ax, 134, aw, ["REST endpoints (main.py)"], [
        "GET /health · /careers · /courses · /skills",
        "GET /curriculum/gap[?career=]",
        "POST /gap · POST /recommendations: store nothing",
        "422 on unknown ids; percentages round halves up",
    ])
    schemas = c.component(ax, rest.bottom + 22, aw, ["Schemas (schemas.py, Pydantic)"], [
        "StudentIn · GapOut · RecommendationsOut",
        "CurriculumGapOut · ValidationInfo beside every figure",
    ])
    eng = c.component(ax, schemas.bottom + 22, aw, ["EngineState (engine.py)"], [
        "build_state() once per process; cache keyed by SHA-256",
        "gap · gap_by_source · recommendations · curriculum",
    ])
    online = c.component(ax, eng.bottom + 22, 205, ["Online catalog"], [
        "online.py", "load · sync · status",
    ])
    reports = c.component(ax + 221, eng.bottom + 22, 205, ["Reports (CLI)"], [
        "reports.py", "min-demand · course reach",
    ])
    c.path([rest.bottom_at(0.2), schemas.top_at(0.2)], **use)
    c.path([schemas.bottom_at(0.2), eng.top_at(0.2)], **use)
    c.path([eng.bottom_at(0.22), (eng.x + eng.w * 0.22, online.y)], **use)
    c.path([reports.top_at(0.5), (reports.cx, eng.bottom)], **use)

    # the app's data access calls the REST endpoints
    c.path([data.right_at(0.5), (535, data.cy), (535, rest.y + 46), (rest.x, rest.y + 46)],
           **use)
    c.text(529, (data.cy + rest.y + 46) / 2, "HTTP + JSON, port 8000 (REST)", size=11.5,
           anchor="middle", fill=QUIET, rotate=-90)

    # ---- the engine ---------------------------------------------------------
    c.package(1100, 80, 436, 330, "Skill-gap engine (skillgap/)")
    ex, ew = 1122, 392
    matcher = c.component(ex, 134, ew, ["Skill matcher (skillgap.py)"], [
        "Embedder: multilingual-e5-base, 'query: ' prefix",
        "Taxonomy: English + Arabic labels embedded",
        "chunk_top1 (postings) · skill_centric (courses)",
        "build_career_profile · analyze_gap · recommend",
    ])
    validate = c.component(ex, matcher.bottom + 22, ew, ["Validation harness (validate.py)"], [
        "threshold sweep against the hand labels",
        "gate F1 ≥ 0.60: measured 0.504, failed",
    ])
    c.path([validate.top_at(0.3), (validate.x + validate.w * 0.3, matcher.bottom)], **use)
    c.path([eng.right_at(0.4), (1072, eng.y + eng.h * 0.4), (1072, matcher.cy),
            matcher.left_at(0.5)], **use)

    # ---- outside systems and offline tools ---------------------------------
    hf = c.system_actor(1122, 440, ["Hugging Face Hub", "intfloat/multilingual-e5-base"], w=250)
    c.path([hf.top_at(0.5), (hf.cx, 410)], **use)
    c.text(hf.cx + 8, 431, "«download» on a cache miss", size=11, fill=QUIET)
    c.package(1100, 520, 436, 120, "Data preparation (test/)")
    collect = c.component(1122, 562, 220, ["collect_postings.py"], [], stereo="«script»")
    c.component(1354, 562, 160, ["merge_labels.py"], [], stereo="«script»")
    jsearch = c.system_actor(1360, 668, ["JSearch API", "(job aggregator)"], w=176)
    c.path([collect.bottom_at(0.85), (collect.x + collect.w * 0.85, 654), (jsearch.cx, 654),
            jsearch.top_at(0.5)], **use)
    c.text(jsearch.cx - 8, 666, "HTTPS", size=11, fill=QUIET, anchor="end")
    browser = c.system_actor(24, 896, ["Web browser (Safari)", "online course pages"], w=210)
    c.path([screens.left_at(0.85), (14, screens.y + screens.h * 0.85), (14, 884),
            (browser.cx, 884), browser.top_at(0.5)], **use)
    c.text(browser.right + 12, browser.cy + 4, "the suggestions screen opens a course link",
           size=11, fill=QUIET)

    # ---- data files -----------------------------------------------------------
    c.package(590, 740, 946, 150, "Data files (read at start-up)")
    files = [
        ("taxonomy.json", ["91 skills, 8 categories", "English + Arabic names"]),
        ("config.json", ["matching parameters", "gate_passed: false"]),
        ("labeled_postings", ["82 postings, 8 careers", "15 hand-labelled"]),
        ("labeled_courses", ["33 Shaqra IS courses", "hand labels + track"]),
        ("online_courses", ["47 rows, 28 courses", "for untaught skills"]),
        ("engine cache", [".cache/engine-<key>", "profiles + course skills"]),
    ]
    boxes = []
    fx = 608
    for name, body in files:
        boxes.append(c.artifact(fx, 790, 142, [name], body, fill=F_STORE))
        fx += 154
    _tax, cfg, posts, _courses, _onl, _cache = boxes

    gap_x = (online.right + reports.x) / 2
    c.path([(gap_x, eng.bottom), (gap_x, 762)], **use)
    c.text(gap_x + 6, 700, "«read»", size=11, fill=QUIET)
    c.path([validate.left_at(0.75), (1084, validate.y + validate.h * 0.75), (1084, 704),
            (cfg.x + cfg.w * 0.8, 704), (cfg.x + cfg.w * 0.8, 790)], **use)
    c.text(1078, 698, "«write»", size=11, fill=QUIET, anchor="end")
    c.path([collect.bottom_at(0.3), (collect.x + collect.w * 0.3, 724),
            (posts.x + posts.w * 0.6, 724), (posts.x + posts.w * 0.6, 790)], **use)
    c.text(collect.x + collect.w * 0.3 + 6, 716, "«write»", size=11, fill=QUIET)
    return c


def deployment() -> Canvas:
    c = Canvas(1440, 650,
               "Deployment diagram: one phone, one server process, and three outside services",
               "Nodes are 3-D boxes; lines between nodes are communication paths, labelled "
               "with their protocol.")
    phone = c.node(24, 90, 380, 380, ["iPhone or iOS Simulator"], stereo="«device»")
    c.node(46, 170, 320, 170, ["Flutter engine (Dart AOT)"],
           stereo="«executionEnvironment»", fill="#FFFFFF")
    c.artifact(66, 236, 280, ["Runner.app"], ["career_readiness: screens, state, models",
                                               "English + Arabic, right to left"])
    c.artifact(46, 360, 320, ["NSUserDefaults (shared_preferences)"],
               ["student_profile: careers, courses, skills, plan", "language: en | ar"],
               stereo="«store»", fill=F_STORE)

    server = c.node(600, 90, 470, 470, ["Development machine (Windows 11)"], stereo="«device»")
    c.node(622, 170, 410, 270, ["Python 3 + Uvicorn, port 8000"],
           stereo="«executionEnvironment»", fill="#FFFFFF")
    c.artifact(642, 238, 370, ["backend (FastAPI app)"],
               ["main.py · schemas.py · engine.py · online.py",
                "EngineState held in memory for the process"])
    c.artifact(642, 336, 370, ["skillgap engine"],
               ["skillgap.py · validate.py · sentence-transformers",
                "loads the model only when the cache misses"])
    c.artifact(622, 460, 196, ["data files"], ["taxonomy.json · config.json",
                                               "postings, courses, online"],
               stereo="«folder»", fill=F_STORE)
    c.artifact(832, 460, 200, ["backend/.cache"], ["engine-<key>.json",
                                                   "profiles + course skills"],
               stereo="«folder»", fill=F_STORE)

    hf = c.node(1180, 90, 236, 96, ["Hugging Face Hub"], stereo="«external»", fill=F_EXTERNAL)
    c.text(1190, 174, "intfloat/multilingual-e5-base", size=11.5, fill=QUIET)
    js = c.node(1180, 250, 236, 96, ["JSearch API"], stereo="«external»", fill=F_EXTERNAL)
    c.text(1190, 334, "job postings, Saudi Arabia", size=11.5, fill=QUIET)
    prov = c.node(1180, 410, 236, 120, ["Online course providers"], stereo="«external»",
                  fill=F_EXTERNAL)
    c.lines(1190, 494, ["Coursera · Microsoft Learn ·", "Cisco · SAP · and 8 more"],
            size=11.5, fill=QUIET)

    mid = (phone.right + 12 + server.x) / 2
    c.path([(phone.right + 12, 230), (server.x, 230)])
    c.lines(mid, 206, ["«HTTP» JSON", "port 8000"], size=11.5, anchor="middle", lh=14)
    c.lines(mid, 254, ["simulator: 127.0.0.1", "iPhone: the machine's", "LAN address, set with",
                       "API_BASE_URL"], size=10.5, anchor="middle", fill=QUIET, lh=14)
    rmid = (server.right + 12 + hf.x) / 2
    c.path([(server.right + 12, 140), (hf.x, 140)])
    c.text(rmid, 132, "«HTTPS»", size=11.5, anchor="middle")
    c.text(rmid, 158, "first build", size=10.5, anchor="middle", fill=QUIET)
    c.path([(server.right, 300), (js.x, 300)])
    c.text(rmid, 292, "«HTTPS»", size=11.5, anchor="middle")
    c.text(rmid, 318, "collection runs", size=10.5, anchor="middle", fill=QUIET)
    c.path([(phone.cx, phone.bottom), (phone.cx, 610), (1298, 610), (1298, prov.bottom)])
    c.text(760, 602, "«HTTPS» the phone's browser opens a suggested online course", size=11.5,
           anchor="middle")
    return c


def packages() -> Canvas:
    c = Canvas(1200, 580,
               "Package diagram: the app is split by feature, each over a shared core",
               "Each feature keeps only the layers it needs. «import» lists the other "
               "features whose code it uses.")
    c.package(24, 76, 1152, 320, "lib/features")
    feats = [
        ("onboarding", "data · domain · presentation", "gap, profile"),
        ("profile", "data · domain · presentation", "onboarding"),
        ("home", "presentation", "gap, planning, profile, settings"),
        ("gap", "data · domain · presentation", "onboarding, planning, profile,", "recommendations"),
        ("planning", "domain · presentation", "gap, onboarding, profile"),
        ("recommendations", "data · domain · presentation", "gap, onboarding, profile"),
        ("settings", "presentation", "onboarding, profile"),
        ("curriculum", "data · domain · presentation", "gap, onboarding"),
    ]
    w, h = 268, 112
    for i, f in enumerate(feats):
        col, row = i % 4, i // 4
        x, y = 44 + col * (w + 16), 120 + row * (h + 22)
        c.package(x, y, w, h, f[0], fill="#FFFFFF")
        c.text(x + 12, y + 46, "layers: " + f[1], size=11.5)
        c.text(x + 12, y + 70, "«import»", size=11, fill=QUIET)
        c.lines(x + 12, y + 88, list(f[2:]), size=11.5, lh=15)
    c.package(24, 438, 1152, 120, "lib/core")
    c.lines(44, 488, [
        "api: ApiClient, apiBaseUrl · domain: ValidationInfo · locale: LocaleController · "
        "theme: Cupertino colours and type",
        "widgets: AppPage, Section, QualityBanner, ReadinessRing, ShareBar · l10n: career, "
        "category and track names · links · format",
    ], size=12, lh=18)
    c.text(44, 540, "lib/l10n: app_en.arb, app_ar.arb and the generated AppLocalizations",
           size=12, fill=QUIET)
    c.path([(600, 396), (600, 438)], end="open", dash="6 4", label="«import»",
           label_at=(610, 423), label_anchor="start")
    return c


ALL = [("1a_component", component), ("1b_deployment", deployment), ("1c_packages", packages)]

"""Section 4: sequence diagrams."""
from uml import Canvas, LINE, QUIET, INK, text_width


class Seq:
    """
    Lays a sequence diagram out top to bottom. Calls record what to draw; draw()
    paints it in z-order: frames, lifelines, activation bars, then messages, so
    an arrow always lands on the edge of the bar it calls.
    """

    def __init__(self, c: Canvas, parts, y0=84, step=34):
        self.c, self.step = c, step
        self.x = {}
        self.heads = []
        bottom = 0
        for key, x, lines, kind in parts:
            self.x[key] = x
            self.heads.append((key, x, lines, kind))
            h = 92 if kind == "actor" else len(lines) * 14.5 + 14
            bottom = max(bottom, y0 + h)
        self.y0 = y0
        self.head_bottom = bottom
        self.y = bottom + 30
        self.msgs, self.acts, self.frames, self.notes, self.texts = [], [], [], [], []
        self.open_acts = {}

    # ---- recording ----------------------------------------------------------

    def gap(self, dy=12):
        self.y += dy

    def on(self, key, y=None):
        self.open_acts.setdefault(key, []).append(self.y - 6 if y is None else y)

    def off(self, key, y=None):
        start = self.open_acts[key].pop()
        depth = len(self.open_acts[key])
        self.acts.append((key, start, (self.y - 14) if y is None else y, depth))

    def msg(self, a, b, label, kind="sync", lines=None, dy=None, activate=False,
            deactivate=False):
        labels = lines or [label]
        self.y += (len(labels) - 1) * 13
        self.msgs.append(("msg", a, b, self.y, labels, kind))
        if activate:
            self.on(b, self.y - 2)
        if deactivate:
            self.off(a, self.y + 2)
        self.y += dy or self.step

    def self_msg(self, a, label, lines=None, dy=None, left=False):
        labels = lines or [label]
        self.msgs.append(("self", a, a, self.y, labels, "left" if left else "sync"))
        self.y += max(dy or 0, 22 + len(labels) * 13 + 12)

    def frame(self, tag, guard, left, right, pad=70):
        f = {"tag": tag, "guard": guard, "x1": self.x[left] - pad, "x2": self.x[right] + pad,
             "y1": self.y - 8, "elses": []}
        self.frames.append(f)
        self.y += 40
        return f

    def els(self, f, guard):
        f["elses"].append((self.y - 4, guard))
        self.y += 36

    def end(self, f):
        f["y2"] = self.y - 6
        self.y += 18

    def note(self, key, lines, dx=14, w=None):
        self.notes.append((self.x[key] + dx, self.y - 4, lines, w))
        self.y += len(lines) * 15.5 + 22

    # ---- painting -----------------------------------------------------------

    def _active(self, key, y):
        return [a for a in self.acts if a[0] == key and a[1] <= y <= a[2]]

    def _edge(self, key, y, toward_right):
        acts = self._active(key, y)
        if not acts:
            return self.x[key]
        depth = max(a[3] for a in acts)
        x = self.x[key] + depth * 6
        return x + 5 if toward_right else x - 5

    def draw(self, bottom=None):
        c = self.c
        end_y = bottom or self.y + 10
        for f in self.frames:
            c.frame(f["x1"], f["y1"], f["x2"] - f["x1"], f["y2"] - f["y1"], f["tag"], f["guard"],
                    labels=False)
            for y, guard in f["elses"]:
                c.line(f["x1"], y, f["x2"], y, dash="6 4", sw=1)
        for key, x, lines, kind in self.heads:
            box = c.lifeline_head(x, self.y0, lines, kind)
            top = box.bottom + (20 if kind == "actor" else 0)
            c.line(x, top, x, end_y, dash="5 5", sw=1)
        for key, y1, y2, depth in sorted(self.acts, key=lambda a: a[3]):
            c.activation(self.x[key], y1, y2, depth)
        for kind_, a, b, y, labels, kind in self.msgs:
            if kind_ == "self":
                acts = self._active(a, y)
                depth = max((d for *_, d in acts), default=-1)
                cx = self.x[a] + (depth + 1) * 6 if acts else self.x[a] - 5
                c.self_message(cx, y, None, label_lines=labels, left=(kind == "left"))
                continue
            right = self.x[b] > self.x[a]
            x1 = self._edge(a, y, right)
            x2 = self._edge(b, y, not right)
            c.message(x1, x2, y, None, kind=kind, label_lines=labels)
        for x, y, lines, w in self.notes:
            c.note(x, y, lines, w=w)
        for f in self.frames:
            c.frame_tag(f["x1"], f["y1"], f["tag"], f["guard"])
            for y, guard in f["elses"]:
                c.text(f["x1"] + 10, y + 15, guard, size=11.5, fill=QUIET, halo=True)


def onboarding() -> Canvas:
    c = Canvas(1500, 1250,
               "Sequence diagram: onboarding saves the profile on the device, never on the server",
               "Synchronous calls have filled heads; replies are dashed. Activation bars show "
               "which object is working.")
    s = Seq(c, [
        ("st", 70, ["Student"], "actor"),
        ("ui", 245, ["Onboarding + Skills", "screens"], "object"),
        ("ctl", 445, ["OnboardingController", "Notifier"], "object"),
        ("cat", 640, ["catalog providers", "careers · courses · skills"], "object"),
        ("repo", 845, ["CatalogRepository", "+ ApiClient"], "object"),
        ("api", 1030, ["Skill-gap API", "FastAPI"], "external"),
        ("sp", 1215, ["SavedProfile", "Notifier"], "object"),
        ("ps", 1400, ["PrefsProfileStore", "shared_preferences"], "object"),
    ])
    s.msg("st", "ui", "open the app (no profile saved)", activate=True)
    s.msg("ui", "cat", "watch(careersProvider, coursesProvider)", activate=True)
    s.msg("cat", "repo", "careers(), courses()", activate=True)
    s.msg("repo", "api", "GET /careers, GET /courses", activate=True)
    s.msg("api", "repo", "[CareerOut], [CourseOut]", kind="reply", deactivate=True)
    s.msg("repo", "cat", "List<Career>, List<Course>", kind="reply", deactivate=True)
    s.msg("cat", "ui", "AsyncData: the profile form", kind="reply", deactivate=True)
    f = s.frame("loop", "[choosing careers and courses]", "st", "ctl", pad=50)
    s.msg("st", "ui", "tap a career, a course,", lines=["tap a career, a course,",
                                                          "select all shown, a level"])
    s.msg("ui", "ctl", "toggleCareer · toggleCourse · selectCourses", activate=True)
    s.self_msg("ctl", "state = state.copyWith(...)", lines=["new OnboardingState", "(max 3 careers)"])
    s.off("ctl")
    s.end(f)
    s.msg("st", "ui", "tap “Next: other skills”")
    s.msg("ui", "cat", "watch(skillsProvider)", activate=True)
    s.msg("cat", "api", "GET /skills", lines=["GET /skills (through", "CatalogRepository)"])
    s.msg("api", "cat", "[SkillOut]", kind="reply")
    s.msg("cat", "ui", "AsyncData: the skill list", kind="reply", deactivate=True)
    s.msg("st", "ui", "tick self-taught skills", lines=["tick self-taught skills", "(optional)"])
    s.msg("ui", "ctl", "toggleSkill(id)")
    s.msg("st", "ui", "tap “See my readiness”")
    s.msg("ui", "ctl", "finish()", activate=True)
    s.msg("ctl", "sp", "save(StudentProfile)", lines=["save(StudentProfile:", "lists sorted, blank major = null)"],
          activate=True)
    s.msg("sp", "ps", "save(profile)", activate=True)
    s.self_msg("ps", "setString", lines=["setString('student_profile',", "JSON)"], left=True)
    f = s.frame("alt", "[written]", "st", "ps", pad=50)
    s.msg("ps", "sp", "ok", kind="reply", deactivate=True)
    s.self_msg("sp", "state = profile")
    s.msg("sp", "ctl", "done", kind="reply", deactivate=True)
    s.self_msg("ctl", "reset()")
    s.msg("ctl", "ui", "true", kind="reply")
    s.self_msg("ui", "popUntil", lines=["popUntil(first): the student", "tab now shows the dashboard"])
    s.els(f, "[the write failed]")
    s.msg("ps", "ctl", "StateError", kind="reply", lines=["StateError: the profile could not be written"])
    s.self_msg("ctl", "error", lines=["state.error = e;", "the draft is kept"])
    s.msg("ctl", "ui", "false", kind="reply", deactivate=True)
    s.msg("ui", "st", "“could not be saved on this device”", kind="reply", deactivate=True)
    s.end(f)
    s.draw()
    c.h = s.y + 30
    return c


def readiness() -> Canvas:
    c = Canvas(1560, 1180,
               "Sequence diagram: home asks POST /gap for the main career and shows three gaps",
               "The profile travels in the request; the API reads it twice (both sources, then "
               "courses alone) and stores nothing.")
    s = Seq(c, [
        ("st", 70, ["Student"], "actor"),
        ("ui", 235, ["DashboardScreen"], "object"),
        ("sp", 420, ["servedProfileProvider"], "object"),
        ("gp", 610, ["gapReportProvider", "family<GapReport, GapQuery>"], "object"),
        ("repo", 800, ["GapRepository", "+ ApiClient"], "object"),
        ("api", 985, ["main.py", "POST /gap"], "external"),
        ("eng", 1170, ["EngineState"], "external"),
        ("sg", 1380, ["skillgap", "analyze_gap()"], "external"),
    ])
    s.msg("st", "ui", "open the app (profile saved)", activate=True)
    s.msg("ui", "sp", "watch()", activate=True)
    s.self_msg("sp", "restrict", lines=["restrictProfile(saved): drop ids the", "API no longer serves (ServedIds,",
                                        "from GET /careers, /courses, /skills)"])
    s.msg("sp", "ui", "StudentProfile", kind="reply", deactivate=True)
    s.self_msg("ui", "gapQueryFor", lines=["gapQueryFor(profile):", "main career, sorted ids"])
    s.msg("ui", "gp", "watch(gapReportProvider(query))", activate=True)
    s.msg("gp", "repo", "fetch(servedQuery(query))", activate=True)
    s.msg("repo", "api", "POST /gap", lines=["POST /gap {career, completed_courses,",
                                             "self_reported_skills}"], activate=True)
    s.self_msg("api", "checked", lines=["checked(): dedupe;", "422 on an unknown id"])
    s.msg("api", "eng", "gap_by_source(career, codes, reported)", lines=["gap_by_source(career,", "codes, reported)"],
          activate=True)
    s.msg("eng", "sg", "analyze_gap(profile, courses ∪ reported)", lines=["analyze_gap(profile,", "courses ∪ reported)"],
          activate=True)
    s.msg("sg", "eng", "GapResult (combined)", kind="reply", deactivate=True)
    s.msg("eng", "sg", "analyze_gap(profile, course skills)", lines=["analyze_gap(profile,", "course skills)"],
          activate=True)
    s.msg("sg", "eng", "GapResult (courses only)", kind="reply", deactivate=True)
    s.msg("eng", "api", "SourcedGap", kind="reply", deactivate=True)
    s.self_msg("api", "gap_out", lines=["gap_out(): tag sources,", "percent(), validation()"])
    s.msg("api", "repo", "200 GapOut (JSON)", kind="reply", deactivate=True)
    s.msg("repo", "gp", "GapReport.fromJson(...)", kind="reply", deactivate=True)
    s.msg("gp", "ui", "AsyncData(report)", kind="reply", deactivate=True)
    s.msg("ui", "st", "quality flag, readiness, top three gaps", kind="reply")
    f = s.frame("opt", "[courses are planned]", "st", "api", pad=50)
    s.msg("ui", "gp", "watch(gapReportProvider(withPlanned))", lines=["watch(gapReportProvider(", "query with planned courses))"])
    s.msg("gp", "api", "POST /gap (completed + planned)", lines=["POST /gap with completed", "+ planned courses"])
    s.msg("api", "gp", "projected GapOut", kind="reply")
    s.msg("gp", "ui", "now and projected, side by side", kind="reply")
    s.end(f)
    f = s.frame("break", "[the API is unreachable or answers non-2xx]", "st", "repo", pad=50)
    s.msg("repo", "gp", "ApiException", kind="reply")
    s.msg("gp", "ui", "AsyncError", kind="reply")
    s.msg("ui", "st", "error with “Try again” (retryGap)", kind="reply", deactivate=True)
    s.end(f)
    s.draw()
    c.h = s.y + 30
    return c


def suggestions() -> Canvas:
    c = Canvas(1560, 1060,
               "Sequence diagram: suggestions put university courses first and online courses after",
               "An online course is offered only for a gap that no catalog course teaches.")
    s = Seq(c, [
        ("st", 70, ["Student"], "actor"),
        ("rd", 225, ["ReadinessScreen"], "object"),
        ("ui", 400, ["Recommendations", "Screen"], "object"),
        ("rp", 580, ["recommendationsProvider"], "object"),
        ("repo", 770, ["Recommendations", "Repository"], "object"),
        ("api", 950, ["main.py", "POST /recommendations"], "external"),
        ("eng", 1140, ["EngineState"], "external"),
        ("sg", 1310, ["skillgap", "recommend()"], "external"),
        ("br", 1470, ["Web browser"], "external"),
    ])
    s.msg("st", "rd", "tap “Suggested courses”", activate=True)
    s.msg("rd", "ui", "push(career: focus)", kind="create", activate=True)
    s.msg("ui", "rp", "watch(recommendationsProvider(query))", lines=["watch(recommendationsProvider", "(query))"],
          activate=True)
    s.msg("rp", "repo", "fetch(query)", activate=True)
    s.msg("repo", "api", "POST /recommendations", lines=["POST /recommendations", "{career, courses, skills}"],
          activate=True)
    s.msg("api", "eng", "gap(career, codes, reported)", activate=True)
    s.msg("eng", "api", "GapResult", kind="reply", deactivate=True)
    s.msg("api", "eng", "recommendations(gap, codes)", activate=True)
    s.msg("eng", "sg", "recommend(gap, untaken catalog)", lines=["recommend(gap,", "untaken catalog)"],
          activate=True)
    s.msg("sg", "eng", "courses ranked by demand closed", lines=["courses ranked by the", "demand they close"],
          kind="reply", deactivate=True)
    s.self_msg("eng", "online", lines=["online courses for gaps no", "catalog course teaches;",
                                       "the rest are uncovered"])
    s.msg("eng", "api", "Suggestions", kind="reply", deactivate=True)
    s.msg("api", "repo", "RecommendationsOut", lines=["200 RecommendationsOut:", "university, online, uncovered"],
          kind="reply", deactivate=True)
    s.msg("repo", "rp", "RecommendationsReport", kind="reply", deactivate=True)
    s.msg("rp", "ui", "AsyncData(report)", kind="reply", deactivate=True)
    s.msg("ui", "st", "cards: counts toward the degree or not", lines=["university cards (count toward the degree),",
                                                                       "online cards (do not), uncovered skills"],
          kind="reply")
    f = s.frame("opt", "[the student taps an online course]", "st", "br", pad=50)
    s.msg("st", "ui", "tap the course card")
    s.msg("ui", "br", "launchUrl(url, externalApplication)", lines=["launchUrl(url,", "externalApplication)"])
    s.els(f, "[nothing could open the link]")
    s.msg("ui", "st", "toast: “The link could not be opened.”", kind="reply")
    s.end(f)
    s.off("ui")
    s.off("rd")
    s.draw()
    c.h = s.y + 30
    return c


def planning() -> Canvas:
    c = Canvas(1300, 980,
               "Sequence diagram: a planned course is shown at once, saved, then projected",
               "togglePlanned() sets the new plan before the write finishes, so a second tap "
               "builds on the first.")
    s = Seq(c, [
        ("st", 70, ["Student"], "actor"),
        ("ui", 260, ["PlanningScreen"], "object"),
        ("sp", 480, ["SavedProfile", "Notifier"], "object"),
        ("ps", 700, ["PrefsProfileStore"], "object"),
        ("gp", 920, ["gapReportProvider"], "object"),
        ("api", 1150, ["Skill-gap API", "POST /gap"], "external"),
    ])
    s.msg("st", "ui", "tick a course", activate=True)
    s.msg("ui", "sp", "togglePlanned(code)", activate=True)
    s.self_msg("sp", "state", lines=["before = state; state = after", "(the plan shows at once)"])
    s.msg("sp", "ps", "save(after)", activate=True)
    f = s.frame("alt", "[the write failed]", "st", "ps", pad=50)
    s.msg("ps", "sp", "error", kind="reply")
    s.self_msg("sp", "rollback", lines=["if state is still after:", "state = before; rethrow"])
    s.msg("sp", "ui", "error", kind="reply")
    s.msg("ui", "st", "toast: could not be saved", kind="reply")
    s.els(f, "[written]")
    s.msg("ps", "sp", "ok", kind="reply", deactivate=True)
    s.msg("sp", "ui", "done", kind="reply", deactivate=True)
    s.end(f)
    s.msg("ui", "gp", "watch(gapQueryFor(profile, withPlanned))", lines=["watch(gapQueryFor(profile,", "withPlanned: true))"],
          activate=True)
    s.msg("gp", "api", "POST /gap: completed + planned", lines=["POST /gap: completed", "+ planned courses"],
          activate=True)
    s.msg("api", "gp", "projected GapOut", kind="reply", deactivate=True)
    s.msg("gp", "ui", "AsyncData(projected)", kind="reply", deactivate=True)
    s.self_msg("ui", "plan", lines=["gapsClosedByPlan(planned, now):", "each gap counted once"])
    s.msg("ui", "st", "now and projected, +N points", lines=["“31% now, 53% with 3 planned”,",
                                                           "+N points, the gaps it closes"],
          kind="reply", deactivate=True)
    s.draw()
    c.h = s.y + 30
    return c


def department() -> Canvas:
    c = Canvas(1460, 1010,
               "Sequence diagram: the department tab reads the catalog against the postings",
               "Built the first time the tab opens; a career pill narrows the same request to "
               "one career.")
    s = Seq(c, [
        ("st", 70, ["Department", "staff"], "actor"),
        ("sh", 230, ["HomeShell", "CupertinoTabScaffold"], "object"),
        ("ui", 420, ["CurriculumScreen"], "object"),
        ("sc", 590, ["CurriculumScope"], "object"),
        ("gp", 770, ["curriculumGapProvider"], "object"),
        ("repo", 960, ["Curriculum", "Repository"], "object"),
        ("api", 1135, ["main.py", "GET /curriculum/gap"], "external"),
        ("eng", 1320, ["EngineState"], "external"),
    ])
    s.msg("st", "sh", "tap the “Department” tab", activate=True)
    s.msg("sh", "ui", "build (first open only)", kind="create", activate=True)
    s.self_msg("ui", "careers", lines=["careersProvider (GET /careers):", "sample caveat with posting counts"])
    s.msg("ui", "sc", "watch()", activate=True)
    s.msg("sc", "ui", "null: every career", kind="reply", deactivate=True)
    s.msg("ui", "gp", "watch(curriculumGapProvider(null))", lines=["watch(curriculum", "GapProvider(null))"],
          activate=True)
    s.msg("gp", "repo", "fetch(null)", activate=True)
    s.msg("repo", "api", "GET /curriculum/gap", activate=True)
    s.msg("api", "eng", "curriculum(None)", activate=True)
    s.self_msg("eng", "work", lines=["demanded at min_demand 0.15,", "taught_by(), uncovered,",
                                     "below threshold, not asked,", "coverage per career"], left=True)
    s.msg("eng", "api", "CurriculumGap", kind="reply", deactivate=True)
    s.msg("api", "repo", "CurriculumGapOut", lines=["200 CurriculumGapOut +", "sample_note + validation"],
          kind="reply", deactivate=True)
    s.msg("repo", "gp", "CurriculumGap", kind="reply", deactivate=True)
    s.msg("gp", "ui", "AsyncData(gap)", kind="reply", deactivate=True)
    s.msg("ui", "st", "coverage, gaps by demand, below threshold", lines=["coverage, uncovered skills by demand,",
                                                                          "below threshold, not asked, per career"],
          kind="reply")
    f = s.frame("opt", "[staff pick one career]", "st", "api", pad=50)
    s.msg("st", "ui", "tap a career pill")
    s.msg("ui", "sc", "select(career)")
    s.msg("ui", "gp", "watch(curriculumGapProvider(career))", lines=["watch(curriculum", "GapProvider(career))"])
    s.msg("gp", "api", "GET /curriculum/gap?career=…", lines=["GET /curriculum/gap", "?career=…"])
    s.msg("api", "gp", "that career's view", kind="reply")
    s.msg("gp", "ui", "AsyncData", kind="reply")
    s.msg("ui", "st", "one career's coverage and gaps", kind="reply")
    s.end(f)
    s.off("ui")
    s.off("sh")
    s.draw()
    c.h = s.y + 30
    return c


def startup() -> Canvas:
    c = Canvas(1540, 1110,
               "Sequence diagram: server start-up builds EngineState once, from the cache when it can",
               "The model is created only when no cache file matches the key; a warm restart "
               "never loads it.")
    s = Seq(c, [
        ("op", 70, ["Researcher"], "actor"),
        ("uv", 220, ["Uvicorn"], "external"),
        ("app", 380, ["FastAPI app", "lifespan()"], "object"),
        ("bs", 560, ["engine", "build_state()"], "object"),
        ("sg", 750, ["skillgap", "module"], "object"),
        ("on", 930, ["online", "load_online_courses()"], "object"),
        ("ca", 1100, ["cache file", "engine-<key>.json"], "external"),
        ("em", 1270, ["Embedder", "SentenceTransformer"], "object"),
        ("hf", 1440, ["Hugging Face", "Hub"], "external"),
    ])
    s.msg("op", "uv", "python -m uvicorn backend.main:app", lines=["python -m uvicorn", "backend.main:app"],
          activate=True)
    s.msg("uv", "app", "start lifespan", activate=True)
    s.msg("app", "bs", "state_factory()", activate=True)
    s.msg("bs", "sg", "load_match_params(postings, courses)", lines=["load_match_params(", "\"postings\", \"courses\")"],
          activate=True)
    s.msg("sg", "bs", "params (StaleConfigError if stale)", lines=["params, or StaleConfigError", "when swept on another taxonomy"],
          kind="reply", deactivate=True)
    s.msg("bs", "on", "load_online_courses(path, skill ids)", lines=["load_online_courses(", "path, skill ids)"],
          activate=True)
    s.msg("on", "bs", "OnlineCatalog (28 courses)", kind="reply", deactivate=True)
    s.self_msg("bs", "csv", lines=["read postings + courses;", "_course_labels(); _cache_key()"])
    s.msg("bs", "ca", "_load_cache(key)", activate=True)
    f = s.frame("alt", "[the file exists and its key matches]", "op", "hf", pad=50)
    s.msg("ca", "bs", "profiles, extracted course skills", lines=["career profiles, extracted", "course skills"],
          kind="reply", deactivate=True)
    s.els(f, "[miss: absent, half-written or another key]")
    s.msg("bs", "em", "Embedder(model)", kind="create", activate=True)
    s.msg("em", "hf", "download multilingual-e5-base", lines=["download multilingual-e5-base", "(first time only)"])
    s.msg("em", "bs", "embedder", kind="reply", deactivate=True)
    s.msg("bs", "sg", "Taxonomy(path, embedder)", lines=["Taxonomy(path, embedder):", "embed en + ar labels"],
          activate=True)
    s.msg("sg", "em", "encode(labels)", activate=True)
    s.msg("em", "sg", "vectors", kind="reply", deactivate=True)
    s.msg("sg", "bs", "taxonomy", kind="reply", deactivate=True)
    s.msg("bs", "sg", "_extract(): build_career_profile ×8, skills_from_courses ×33",
          lines=["_extract(): build_career_profile", "per career; skills_from_courses", "per course"],
          activate=True)
    s.msg("sg", "bs", "profiles, extracted", kind="reply", deactivate=True)
    s.msg("bs", "ca", "_save_cache(key, ...)", activate=True)
    s.off("ca")
    s.end(f)
    s.self_msg("bs", "courses", lines=["courses: hand labels where", "present, else extraction; tracks"])
    s.msg("bs", "app", "EngineState", kind="reply", deactivate=True)
    s.self_msg("app", "store", lines=["app.state.engine = state"])
    s.msg("app", "uv", "yield: ready", kind="reply", deactivate=True)
    s.msg("uv", "op", "Application startup complete", kind="reply")
    s.off("uv")
    s.draw()
    c.h = s.y + 30
    return c


ALL = [("4a_sequence_onboarding", onboarding), ("4b_sequence_readiness", readiness),
       ("4c_sequence_suggestions", suggestions), ("4d_sequence_planning", planning),
       ("4e_sequence_department", department), ("4f_sequence_startup", startup)]

"""Section 6, continued: the Flutter app's class diagrams."""
from uml import Canvas, QUIET, F_INTERFACE, F_ENUM, F_EXTERNAL

UTIL = "#F1ECF9"


def app_domain() -> Canvas:
    c = Canvas(1600, 1150,
               "Class diagram: the app's domain model (lib/features/*/domain, freezed)",
               "Immutable models decoded from the API's snake_case JSON. StudentProfile is the "
               "only one the app writes, and it stays on the phone.")
    fz = "«freezed»"
    prof = c.class_box(24, 84, "StudentProfile", [
        "+ careers: List<String>  (1..3, first = main)",
        "+ completedCourses: List<String>",
        "+ selfReportedSkills: List<String>",
        "+ plannedCourses: List<String>",
        "+ major: String?",
    ], ["+ primaryCareer: String  «getter»", "+ fromJson(json) · toJson()"], stereo=fz,
        head_fill="#EAF5EA")
    query = c.class_box(380, 84, "GapQuery", [
        "+ career: String", "+ completedCourses: List<String>",
        "+ selfReportedSkills: List<String>",
    ], ["gapQueryFor(profile, {career?,", "  withPlanned = false}): GapQuery"], stereo=fz)
    report = c.class_box(720, 84, "GapReport", [
        "+ career: String", "+ readiness: double", "+ readinessPercent: int",
        "+ readinessFromCourses: double", "+ readinessFromCoursesPercent: int",
        "+ covered: List<SkillEntry>", "+ coveredFromCourses: List<SkillEntry>",
        "+ coveredSelfReported: List<SkillEntry>", "+ missing: List<SkillEntry>",
        "+ validation: ValidationInfo",
    ], stereo=fz)
    entry = c.class_box(1090, 84, "SkillEntry", [
        "+ id, en, ar, category: String", "+ demand: double", "+ demandPercent: int",
        "+ source: String?",
    ], ["+ nameFor(languageCode): String"], stereo=fz)
    val = c.class_box(1360, 84, "ValidationInfo", [
        "+ gatePassed: bool", "+ bestF1: double?", "+ gateMinF1: double?",
        "+ courseMappingValidated: bool", "+ note: String",
    ], stereo=fz, head_fill=F_ENUM)

    onb = c.class_box(24, 420, "OnboardingState", [
        "+ major: String", "+ careers: List<String>", "+ courses: Set<String>",
        "+ selfReported: Set<String>", "+ editing: bool", "+ submitting: bool",
        "+ error: Object?", "+ revision: int", "+ maxCareers = 3  «static»",
    ], ["+ canSubmit: bool  «getter»"], stereo=fz)
    served = c.class_box(380, 420, "ServedIds", [
        "+ careers: Set<String>", "+ courses: Set<String>", "+ skills: Set<String>",
    ], ["+ restrictQuery(query): GapQuery", "+ restrictProfile(profile): StudentProfile"])
    nserved = c.class_box(470, 650, "CareerNotServed", ["+ career: String"], stereo="«exception»")
    recs = c.class_box(720, 420, "RecommendationsReport", [
        "+ career: String", "+ recommendations: List<Recommendation>",
        "+ uncovered: List<SkillRef>", "+ validation: ValidationInfo",
    ], ["+ university: List<…>  «getter»", "+ online: List<…>  «getter»"], stereo=fz)
    rec = c.class_box(1150, 420, "Recommendation", [], [
        "+ countsTowardDegree: bool  «getter»", "+ fromJson: union on source",
    ], stereo="«sealed, freezed»", italic_name=True)
    uni = c.class_box(1000, 640, "UniversityRecommendation", [
        "+ code: String", "+ name: String", "+ closes: List<SkillRef>", "+ value: double",
    ])
    onl = c.class_box(1240, 640, "OnlineRecommendation", [
        "+ provider: String", "+ title: String", "+ url: String", "+ isFree: bool",
        "+ closes: List<SkillRef>", "+ value: double",
    ])
    sref = c.class_box(1170, 880, "SkillRef", ["+ id, en, ar: String", "+ demandPercent: int"],
                       ["+ nameFor(languageCode)"], stereo=fz)

    career = c.class_box(24, 800, "Career", ["+ name: String", "+ postingCount: int"], stereo=fz)
    course = c.class_box(200, 800, "Course", [
        "+ code: String", "+ name: String", "+ skillCount: int", "+ skills: List<String>",
        "+ track: String",
    ], stereo=fz)
    skill = c.class_box(420, 800, "Skill", ["+ id, en, ar, category: String"],
                        ["+ nameFor(languageCode)"], stereo=fz)
    c.class_box(670, 800, "plan · course_groups · skill_groups", [], [
        "+ gapsClosedBy(course, now): List<SkillEntry>",
        "+ gapsClosedByPlan(planned, now): Set<String>",
        "+ groupCourses(catalog, query): List<CourseGroup>",
        "+ courseMatches(course, query): bool",
        "+ courseLevel(course): int?",
        "+ codesUpToLevel(catalog, level): Set<String>",
        "+ groupSkills(skills, query): List<SkillGroup>",
        "+ skillsFromCourses(catalog, codes): Set<String>",
    ], stereo="«utility» domain functions", head_fill=UTIL, w=292)

    cg = c.class_box(24, 1000, "CurriculumGap", [
        "+ career: String? · postingCount · minDemand",
        "+ demanded · taught · coverage · coveragePercent",
        "+ validation: ValidationInfo",
    ], stereo=fz)
    parts = [("CurriculumSkill", 400), ("TaughtSkill", 580), ("BelowThresholdSkill", 730),
             ("CareerCoverage", 940)]
    boxes = [c.class_box(x, 1070, n, [], [], stereo=fz) for n, x in parts]

    dep = dict(end="open", dash="6 4")
    comp = dict(start="diamond", end="open")
    c.path([(prof.right, 150), (query.x, 150)], **dep, label="«derive»",
           label_at=((prof.right + query.x) / 2, 142))
    c.path([(report.right, 150), (entry.x, 150)], **comp)
    c.text(report.right + 6, 168, "4 lists", size=11, fill=QUIET)
    c.path([(report.right - 40, report.y), (report.right - 40, 72), (val.cx, 72), (val.cx, val.y)],
           **comp)
    c.path([(recs.right - 30, recs.y), (recs.right - 30, 340), (val.cx + 20, 340),
            (val.cx + 20, val.bottom)], **comp)
    c.text(val.cx + 12, 330, "every report carries one", size=11, fill=QUIET, anchor="end")
    c.path([(onb.cx, onb.y), (onb.cx, prof.bottom)], **dep, label="«finish() saves as»",
           label_at=(onb.cx + 6, (onb.y + prof.bottom) / 2), label_anchor="start")
    c.path([(served.cx, served.y), (served.cx, query.bottom)], **dep, label="«restrict»",
           label_at=(served.cx + 6, (served.y + query.bottom) / 2 + 20), label_anchor="start")
    c.path([(served.x, served.y + 30), (340, served.y + 30), (340, prof.y + 120),
            (prof.right, prof.y + 120)], **dep)
    c.path([(nserved.cx, served.bottom), (nserved.cx, nserved.y)], **dep, label="«throw»",
           label_at=(nserved.cx + 6, (served.bottom + nserved.y) / 2 + 4), label_anchor="start")
    bus = 772
    c.path([(served.x + 30, served.bottom), (served.x + 30, bus)])
    c.path([(career.cx, bus), (skill.cx, bus)])
    for b in (career, course, skill):
        c.path([(b.cx, bus), (b.cx, b.y)], end="open", dash="6 4")
    c.text(served.x + 36, bus - 8, "«ids from»", size=11, fill=QUIET)
    c.path([(recs.right, 460), (rec.x, 460)], **comp)
    c.text(recs.right + 6, 476, "0..*", size=11)
    c.path([(uni.cx, uni.y), (uni.cx, 610), (rec.cx, 610), (rec.cx, rec.bottom)], end="hollow")
    c.path([(onl.cx, onl.y), (onl.cx, 610), (rec.cx, 610)])
    c.path([(onl.x + 40, onl.bottom), (onl.x + 40, sref.y)], **comp)
    c.path([(uni.cx, uni.bottom), (uni.cx, sref.y + 30), (sref.x, sref.y + 30)], **comp)
    c.text(uni.cx + 6, uni.bottom + 16, "closes 1..*", size=11, fill=QUIET)
    c.path([(985, recs.bottom), (985, sref.bottom - 14), (sref.x, sref.bottom - 14)], **comp)
    c.text(991, recs.bottom + 16, "uncovered", size=11, fill=QUIET)
    c.path([(cg.right, 1045), (boxes[-1].cx, 1045)], start="diamond")
    for b in boxes:
        c.path([(b.cx, 1045), (b.cx, b.y)], end="open")
    return c


def app_layers() -> Canvas:
    c = Canvas(1600, 1110,
               "Class diagram: screens watch Riverpod state, which reads through repositories",
               "Three layers; each depends only on the one below. Screens are shown by name; "
               "their navigation is in the activity and sequence diagrams.")
    c.package(24, 76, 1552, 224, "Presentation (screens)")
    row_a = [("CareerReadinessApp", "«CupertinoApp»"), ("HomeShell", "«CupertinoTabScaffold»"),
             ("StudentRoot", "«ConsumerWidget»"), ("OnboardingScreen", "«ConsumerWidget»"),
             ("SkillsScreen", "«ConsumerStatefulWidget»"), ("DashboardScreen", "«ConsumerWidget»")]
    row_b = [("ReadinessScreen", "«ConsumerStatefulWidget»"),
             ("PlanningScreen", "«ConsumerStatefulWidget»"),
             ("RecommendationsScreen", "«ConsumerWidget»"), ("SettingsScreen", "«ConsumerWidget»"),
             ("CurriculumScreen", "«ConsumerWidget»")]
    a_boxes, x = [], 44
    for n, st in row_a:
        a_boxes.append(c.class_box(x, 120, n, [], [], stereo=st, w=200))
        x += 252
    x = 44
    for n, st in row_b:
        c.class_box(x, 220, n, [], [], stereo=st, w=200)
        x += 252
    app_, shell, root, onbs, _skills, dash = a_boxes
    c.path([(app_.right, app_.cy), (shell.x, shell.cy)], start="diamond", end="open")
    c.path([(shell.right, shell.cy), (root.x, shell.cy)], start="diamond", end="open")
    c.text(shell.right + 6, shell.cy - 8, "tab 1", size=10.5, fill=QUIET)
    c.path([(root.right, root.cy), (onbs.x, root.cy)], end="open", dash="6 4")
    c.text(root.right + 6, root.cy - 8, "no profile", size=10.5, fill=QUIET)
    c.path([(root.cx, root.bottom), (root.cx, 204), (dash.cx, 204), (dash.cx, dash.bottom)],
           end="open", dash="6 4")
    c.text(root.cx + 8, 200, "profile saved", size=10.5, fill=QUIET)
    c.text(1306, 250, "HomeShell's tab 2", size=10.5, fill=QUIET)

    c.package(24, 330, 1552, 320, "State (Riverpod 3)")
    prov = c.class_box(44, 380, "providers", [], [
        "careersProvider · coursesProvider · skillsProvider: FutureProvider<List<…>>",
        "servedIdsProvider: FutureProvider<ServedIds>",
        "gapReportProvider: FutureProvider.autoDispose.family<GapReport, GapQuery>",
        "recommendationsProvider: …family<RecommendationsReport, GapQuery>",
        "curriculumGapProvider: …family<CurriculumGap, String?>",
        "servedProfileProvider: Provider<StudentProfile?>",
        "apiClientProvider · *RepositoryProvider · linkOpenerProvider: Provider",
    ], stereo="«top-level providers»", head_fill=UTIL, w=520)
    saved = c.class_box(600, 380, "SavedProfile", [], [
        "+ build(): StudentProfile?", "+ save(profile): Future<void>",
        "+ togglePlanned(code): Future<void>", "+ clear(): Future<void>",
    ], stereo="«Notifier<StudentProfile?>»", w=250)
    ctl = c.class_box(890, 380, "OnboardingController", [], [
        "+ startEditing(profile)", "+ setMajor(value)", "+ toggleCareer(career)",
        "+ toggleCourse(code)", "+ selectCourses(codes)", "+ setCourses(codes)",
        "+ toggleSkill(id)", "+ finish(): Future<bool>", "+ reset()",
    ], stereo="«Notifier<OnboardingState>»", w=230)
    loc = c.class_box(1160, 380, "LocaleController", [], [
        "+ build(): Locale", "+ toggle()", "+ set(locale)",
    ], stereo="«Notifier<Locale>»", w=180)
    c.class_box(1370, 380, "CurriculumScope", [], [
        "+ build(): String?", "+ select(career?)",
    ], stereo="«Notifier<String?>»", w=180)
    c.path([(ctl.x, 450), (saved.right, 450)], end="open")

    c.package(24, 680, 1552, 410, "Data access")
    cat = c.class_box(44, 730, "CatalogRepository", [], [
        "+ careers(): Future<List<Career>>", "+ courses(): Future<List<Course>>",
        "+ skills(): Future<List<Skill>>",
    ])
    gap = c.class_box(300, 730, "GapRepository", [], ["+ fetch(query): Future<GapReport>"])
    rr = c.class_box(540, 730, "RecommendationsRepository", [], [
        "+ fetch(query): Future<RecommendationsReport>"])
    cr = c.class_box(830, 730, "CurriculumRepository", [], [
        "+ fetch(career?): Future<CurriculumGap>"])
    api = c.class_box(380, 900, "ApiClient", [
        "+ baseUrl: String", "- _http: http.Client", "- _timeout = 15 s  «static»",
    ], ["+ get(path): Future<dynamic>", "+ post(path, body): Future<dynamic>", "+ close()"])
    exc = c.class_box(720, 920, "ApiException", ["+ message: String", "+ statusCode: int?"],
                      ["+ unreachable: bool  «getter»"], stereo="«exception»")
    http = c.class_box(44, 940, "http.Client", [], [], stereo="«package:http»",
                       head_fill=F_EXTERNAL)
    ps = c.class_box(1110, 730, "ProfileStore", [], [
        "+ load(): StudentProfile?", "+ save(profile): Future<void>", "+ clear(): Future<void>",
        "+ language(): String?", "+ saveLanguage(code): Future<void>",
    ], stereo="«interface»", head_fill=F_INTERFACE, italic_name=True)
    pps = c.class_box(1110, 940, "PrefsProfileStore", [
        "- _prefs: SharedPreferences", "+ profileKey = \"student_profile\"",
        "+ languageKey = \"language\"",
    ], w=229)
    sp = c.class_box(1390, 960, "SharedPreferences", [], [], stereo="«package»",
                     head_fill=F_EXTERNAL)

    c.path([(800, 300), (800, 330)], end="open", dash="6 4")
    c.text(808, 322, "«watch / read»", size=11, fill=QUIET)
    c.path([(prov.cx, prov.bottom), (prov.cx, 700)])
    c.path([(cat.cx, 700), (cr.cx, 700)])
    for b in (cat, gap, rr, cr):
        c.path([(b.cx, 700), (b.cx, b.y)], end="open")
    for b in (cat, gap, rr, cr):
        c.path([(b.cx, b.bottom), (b.cx, 875)])
    c.path([(cat.cx, 875), (cr.cx, 875)])
    c.path([(api.cx, 875), (api.cx, api.y)], end="open")
    c.text(api.cx + 6, 892, "_api", size=11, fill=QUIET)
    c.path([(api.right, exc.cy), (exc.x, exc.cy)], end="open", dash="6 4", label="«throw»",
           label_at=((api.right + exc.x) / 2, exc.cy - 8))
    c.path([(api.x, http.cy), (http.right, http.cy)], end="open")
    c.path([(saved.cx, saved.bottom), (saved.cx, 662), (1200, 662), (1200, ps.y)], end="open")
    c.path([(loc.cx, loc.bottom), (loc.cx, ps.y)], end="open")
    c.path([(pps.cx, pps.y), (pps.cx, ps.bottom)], end="hollow", dash="6 4")
    c.text(pps.cx + 6, (pps.y + ps.bottom) / 2 + 4, "«implements»", size=11, fill=QUIET)
    c.path([(pps.right, sp.cy), (sp.x, sp.cy)], end="open")
    c.lines(1390, 1030, ["overridden in main() with the", "phone's store; a fake in tests"],
            size=10.5, fill=QUIET, lh=14)
    return c


ALL = [("6d_class_app_domain", app_domain), ("6e_class_app_layers", app_layers)]

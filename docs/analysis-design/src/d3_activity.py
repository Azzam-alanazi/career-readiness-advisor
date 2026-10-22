"""Section 3: activity diagrams."""
from uml import Canvas, LINE, QUIET, INK


def _flow(c, pts, guard=None, at=None, anchor="start"):
    c.path(pts, end="filled")
    if guard:
        c.guard(at[0], at[1], guard, anchor=anchor)


def _connector(c, cx, cy, letter):
    c.add(f'<circle cx="{cx}" cy="{cy}" r="11" fill="#fff" stroke="{LINE}" stroke-width="1.3"/>')
    c.text(cx, cy + 4.5, letter, size=12, bold=True, anchor="middle")


def journey() -> Canvas:
    c = Canvas(1300, 1450,
               "Activity diagram: a student's journey, from first launch to the readiness reading",
               "Swimlanes show who acts. Diamonds are decisions and merges; guards are in "
               "square brackets. Connector A joins the two ends of the loop back to home.")
    S, A, P = c.lanes(24, 76, [340, 540, 372], 1350,
                      ["Student", "iPhone app", "Skill-gap API"])

    st = c.start(A, 135)
    a1 = c.action(A, 190, ["Read the saved profile", "from the device"])
    _flow(c, [(A, st.bottom), (A, a1.y)])
    d1 = c.decision(A, 262)
    _flow(c, [(A, a1.bottom), (A, d1.y)])

    a2 = c.action(500, 335, ["Show the profile form", "(careers and courses from the API)"])
    _flow(c, [(d1.x, d1.cy), (500, d1.cy), (500, a2.y)], "[no profile]", (494, 256), "end")
    s1 = c.action(S, 405, ["Choose 1 to 3 careers", "and type a major"])
    _flow(c, [(a2.x, a2.cy), (S, a2.cy), (S, s1.y)])
    s2 = c.action(S, 475, ["Tick completed courses"])
    _flow(c, [(S, s1.bottom), (S, s2.y)])
    s3 = c.action(S, 545, ["Tick self-taught skills", "(optional)"])
    _flow(c, [(S, s2.bottom), (S, s3.y)])
    s4 = c.action(S, 620, ["Tap “See my readiness”"])
    _flow(c, [(S, s3.bottom), (S, s4.y)])
    a4 = c.action(500, 620, ["Save the profile", "on the device"])
    _flow(c, [(s4.right, s4.cy), (a4.x, a4.cy)])
    d2 = c.decision(500, 695)
    _flow(c, [(500, a4.bottom), (500, d2.y)])
    _flow(c, [(d2.x, d2.cy), (S, d2.cy), (S, s4.bottom)], "[not saved]",
          (S + 10, 714))

    m1 = c.decision(A, 770)
    _flow(c, [(500, d2.bottom), (500, m1.cy), (m1.x, m1.cy)], "[saved]", (506, 728))
    _flow(c, [(A, d1.bottom), (A, m1.y)], "[profile saved]", (A + 8, 300))
    _connector(c, 740, 770, "A")
    _flow(c, [(729, 770), (m1.right, m1.cy)])

    a5 = c.action(A, 835, ["Show the home dashboard"])
    _flow(c, [(A, m1.bottom), (A, a5.y)])
    a6 = c.action(A, 905, ["Send the profile to POST /gap"])
    _flow(c, [(A, a5.bottom), (A, a6.y)])
    p1 = c.action(P, 905, ["Check the ids, read the gap", "from both sources, attach", "the validation flag"])
    _flow(c, [(a6.right, a6.cy), (p1.x, p1.cy)])
    a7 = c.action(A, 990, ["Show readiness, the top three", "gaps and the quality flag"])
    _flow(c, [(P, p1.bottom), (P, a7.cy), (a7.right, a7.cy)])
    d3 = c.decision(S, 1065)
    _flow(c, [(a7.x, a7.cy), (S, a7.cy), (S, d3.y)])

    opts = [
        (1125, ["Show full readiness and", "compare careers"], "[full readiness]"),
        (1190, ["Show the plan and", "its projection"], "[plan courses]"),
        (1255, ["Show suggested courses", "(POST /recommendations)"], "[suggestions]"),
        (1320, ["Settings: edit the profile,", "switch language or delete"], "[settings]"),
    ]
    c.path([(d3.right, d3.cy), (300, d3.cy), (300, 1320)])
    boxes = []
    for y, lines, guard in opts:
        b = c.action(A, y, lines, w=230)
        boxes.append(b)
        _flow(c, [(300, y), (b.x, y)], guard, (b.x - 8, y - 6), "end")
    for b in boxes:
        c.path([(b.right, b.cy), (840, b.cy)])
    c.path([(840, boxes[0].cy), (840, 1380)], end="filled")
    _connector(c, 840, 1392, "A")
    nb = c.note(930, 1290, ["After a delete, the student", "tab opens on onboarding", "again: [no profile]."],
                w=200)
    c.path([(nb.x, boxes[3].cy), (boxes[3].right, boxes[3].cy)], dash="3 3", sw=1)
    end = c.end(S, 1400)
    _flow(c, [(S, d3.bottom), (S, end.y)], "[done]", (S + 8, 1360))
    return c


def gap_analysis() -> Canvas:
    c = Canvas(1100, 1130,
               "Activity diagram: how POST /gap turns a profile into a readiness reading",
               "One request, on the server. Nothing is stored; an unknown id ends the request "
               "with HTTP 422.")
    X, E = 380, 800
    st = c.start(X, 100)
    b1 = c.action(X, 150, ["Receive StudentIn: career,", "completed_courses, self_reported_skills"])
    _flow(c, [(X, st.bottom), (X, b1.y)])

    def check(y, label_no, err_lines, prev_bottom, guard_yes="[known]"):
        d = c.decision(X, y)
        _flow(c, [(X, prev_bottom), (X, d.y)])
        e = c.action(E, y, err_lines, fill="#FCE8E6")
        _flow(c, [(d.right, y), (e.x, y)], label_no, ((d.right + e.x) / 2, y - 8), "middle")
        f = c.end(E + e.w / 2 + 34, y)
        _flow(c, [(e.right, y), (f.x, y)])
        return d

    d1 = check(222, "[unknown career]", ["422: unknown career,", "with the known careers"],
               b1.bottom)
    b2 = c.action(X, 292, ["Drop repeated course codes and", "skill ids, keeping their order"])
    _flow(c, [(X, d1.bottom), (X, b2.y)], "[known]", (X + 8, d1.bottom + 14))
    d2 = check(362, "[a code not in the catalog]", ["422: unknown course codes"], b2.bottom)
    d3 = check(432, "[an id not in the taxonomy]", ["422: unknown skill ids"], d2.bottom)
    c.guard(X + 8, d2.bottom + 14, "[all known]")
    b3 = c.action(X, 502, ["Course skills = the union of the skills", "each completed course teaches"])
    _flow(c, [(X, d3.bottom), (X, b3.y)], "[all known]", (X + 8, d3.bottom + 14))

    fork = c.bar(X, 562, w=380)
    _flow(c, [(X, b3.bottom), (X, fork.y)])
    b4 = c.action(250, 628, ["Acquired = course skills", "∪ self-reported skills"])
    _flow(c, [(250, fork.bottom), (250, b4.y)])
    b5 = c.action(250, 708, ["analyze_gap(profile, acquired)", "→ the combined reading"])
    _flow(c, [(250, b4.bottom), (250, b5.y)])
    b6 = c.action(520, 668, ["analyze_gap(profile, course skills)", "→ the courses-only reading"])
    _flow(c, [(520, fork.bottom), (520, b6.y)])
    join = c.bar(X, 772, w=380)
    _flow(c, [(250, b5.bottom), (250, join.y)])
    _flow(c, [(520, b6.bottom), (520, join.y)])
    note = c.note(700, 600, ["analyze_gap(profile, held skills):",
                             "1. keep the skills with demand ≥ 0.15",
                             "2. total = the sum of their demand weights",
                             "3. covered = kept skills the student holds",
                             "4. readiness = demand of covered ÷ total",
                             "5. covered and missing, highest demand first"], w=330)
    c.path([(note.x, note.cy), (b6.right, b6.cy)], dash="3 3", sw=1)

    b7 = c.action(X, 832, ["Tag each covered skill “courses” when a completed",
                           "course teaches it, otherwise “self_reported”"])
    _flow(c, [(X, join.bottom), (X, b7.y)])
    b8 = c.action(X, 902, ["Round each share to a whole percent, halves up"])
    _flow(c, [(X, b7.bottom), (X, b8.y)])
    b9 = c.action(X, 967, ["Attach the validation block:",
                           "gate_passed false, best F1 0.504 against 0.60"])
    _flow(c, [(X, b8.bottom), (X, b9.y)])
    b10 = c.action(X, 1037, ["Return GapOut; store nothing"])
    _flow(c, [(X, b9.bottom), (X, b10.y)])
    end = c.end(X, 1092)
    _flow(c, [(X, b10.bottom), (X, end.y)])
    return c


def startup() -> Canvas:
    c = Canvas(1120, 1330,
               "Activity diagram: engine start-up loads the model only when the cache misses",
               "build_state(), run once per server process before the first request. Any "
               "bad input stops start-up rather than serving around it.")
    X, E = 400, 840
    st = c.start(X, 100)
    c1 = c.action(X, 155, ["Read config.json and the matching", "parameters for postings and courses"])
    _flow(c, [(X, st.bottom), (X, c1.y)])

    def check(y, prev_bottom, guard_no, err):
        d = c.decision(X, y)
        _flow(c, [(X, prev_bottom), (X, d.y)])
        e = c.action(E, y, err, fill="#FCE8E6")
        _flow(c, [(d.right, y), (e.x, y)], guard_no, ((d.right + e.x) / 2, y - 8), "middle")
        f = c.end(e.right + 34, y)
        _flow(c, [(e.right, y), (f.x, y)])
        return d

    d1 = check(227, c1.bottom, "[swept on another taxonomy]",
               ["StaleConfigError:", "the service does not start"])
    c2 = c.action(X, 297, ["Read taxonomy.json: 91 skills,", "English and Arabic names"])
    _flow(c, [(X, d1.bottom), (X, c2.y)], "[current]", (X + 8, d1.bottom + 14))
    c3 = c.action(X, 362, ["Load online_courses.csv"])
    _flow(c, [(X, c2.bottom), (X, c3.y)])
    d2 = check(427, c3.bottom, "[a row is unreadable]", ["OnlineCoursesError"])
    c4 = c.action(X, 497, ["Read the 82 postings and the 33 catalog", "courses with their hand labels"])
    _flow(c, [(X, d2.bottom), (X, c4.y)], "[valid]", (X + 8, d2.bottom + 14))
    d3 = check(567, c4.bottom, "[a label names an unknown skill]", ["CourseLabelsError"])
    c5 = c.action(X, 637, ["Hash every input into the cache key: taxonomy,",
                           "config, engine source, texts and model name"])
    _flow(c, [(X, d3.bottom), (X, c5.y)], "[valid]", (X + 8, d3.bottom + 14))
    d4 = c.decision(X, 707)
    _flow(c, [(X, c5.bottom), (X, d4.y)])

    hit = c.action(E, 707, ["Load career profiles and course", "skills from engine-<key>.json"])
    _flow(c, [(d4.right, 707), (hit.x, 707)], "[cache file for this key]",
          ((d4.right + hit.x) / 2, 699), "middle")

    region = c.rect(150, 744, 500, 440, fill="none", rx=14, dash="7 4", sw=1.2)
    c.text(166, 762, "model work, only on a cache miss", size=11.5, fill=QUIET, italic=True)
    c7 = c.action(X, 795, ["Load multilingual-e5-base and embed every", "skill's English and Arabic labels"])
    _flow(c, [(X, d4.bottom), (X, c7.y)], "[miss]", (X - 8, d4.bottom + 14), "end")
    loop = c.rect(180, 840, 440, 205, fill="none", rx=10, dash="3 3", sw=1)
    c.text(194, 858, "«iterative» for each career", size=11, fill=QUIET)
    c8 = c.action(X, 885, ["Split each posting into chunks"])
    _flow(c, [(X, c7.bottom), (X, c8.y)])
    c9 = c.action(X, 950, ["Match each chunk to at most one skill",
                           "(chunk_top1, threshold 0.814, margin 0.01)"])
    _flow(c, [(X, c8.bottom), (X, c9.y)])
    c10 = c.action(X, 1012, ["Demand = postings naming the skill ÷ postings"])
    _flow(c, [(X, c9.bottom), (X, c10.y)])
    c11 = c.action(X, 1080, ["Map each course title to skills",
                             "(skill_centric, threshold 0.894)"])
    _flow(c, [(X, c10.bottom), (X, c11.y)])
    c12 = c.action(X, 1145, ["Write engine-<key>.json"])
    _flow(c, [(X, c11.bottom), (X, c12.y)])

    m1 = c.decision(X, 1215)
    _flow(c, [(X, c12.bottom), (X, m1.y)])
    _flow(c, [(E, hit.bottom), (E, 1215), (m1.right, 1215)])
    c13 = c.action(X, 1275, ["Each course's skills: its hand labels when labelled,",
                             "otherwise extraction; add its track"])
    _flow(c, [(X, m1.bottom), (X, c13.y)])
    end = c.end(X + 330, c13.cy)
    _flow(c, [(c13.right, c13.cy), (end.x, end.cy)])
    c.text(end.right + 10, c13.cy + 4, "EngineState ready: serve requests", size=11.5,
           fill=INK)
    return c


def planning() -> Canvas:
    c = Canvas(1200, 880,
               "Activity diagram: what-if planning saves at once and asks for a projection",
               "The plan is shown before the save finishes, so two quick taps never lose the "
               "first. A failed save puts the plan back.")
    S, A, P = c.lanes(24, 76, [330, 500, 322], 784, ["Student", "iPhone app", "Skill-gap API"])

    st = c.start(S, 130)
    s1 = c.action(S, 180, ["Open “Plan courses”"])
    _flow(c, [(S, st.bottom), (S, s1.y)])
    a1 = c.action(A, 180, ["Load the catalog and", "today's reading"])
    _flow(c, [(s1.right, s1.cy), (a1.x, a1.cy)])
    p1 = c.action(P, 180, ["GET /courses", "POST /gap"])
    _flow(c, [(a1.right, a1.cy), (p1.x, p1.cy)])
    a2 = c.action(A, 255, ["List the untaken courses by track,", "each with the gaps it closes"])
    _flow(c, [(P, p1.bottom), (P, a2.cy), (a2.right, a2.cy)])
    m0 = c.decision(S, 300)
    _flow(c, [(a2.x, a2.cy), (S, a2.cy), (S, m0.y)])
    s2 = c.action(S, 360, ["Tick or untick a course"])
    _flow(c, [(S, m0.bottom), (S, s2.y)])
    a3 = c.action(A, 360, ["Show the new plan at once"])
    _flow(c, [(s2.right, s2.cy), (a3.x, a3.cy)])
    a4 = c.action(A, 425, ["Save the profile on the device"])
    _flow(c, [(A, a3.bottom), (A, a4.y)])
    d1 = c.decision(A, 490)
    _flow(c, [(A, a4.bottom), (A, d1.y)])
    a5 = c.action(450, 490, ["Put the plan back;", "show a message"], fill="#FCE8E6")
    _flow(c, [(d1.x, d1.cy), (a5.right, a5.cy)], "[not saved]", (d1.x - 6, d1.cy - 22), "end")
    m3 = c.decision(70, 490)
    _flow(c, [(a5.x, a5.cy), (m3.right, m3.cy)])
    _flow(c, [(70, m3.y), (70, 300), (m0.x, 300)])

    d2 = c.decision(A, 560)
    _flow(c, [(A, d1.bottom), (A, d2.y)], "[saved]", (A + 8, d1.bottom + 16))
    p2 = c.action(P, 560, ["POST /gap with completed", "and planned courses"])
    _flow(c, [(d2.right, d2.cy), (p2.x, p2.cy)], "[a course is planned]",
          ((d2.right + p2.x) / 2, d2.cy - 8), "middle")
    a6 = c.action(470, 640, ["Show today's figure only"])
    _flow(c, [(d2.x, d2.cy), (470, d2.cy), (470, a6.y)], "[plan empty]", (464, d2.cy - 8), "end")
    a7 = c.action(712, 640, ["Show now and projected side by", "side, the points gained and the",
                             "gaps the plan closes, each once"], w=236)
    _flow(c, [(P, p2.bottom), (P, a7.cy), (a7.right, a7.cy)])
    m2 = c.decision(A, 720)
    _flow(c, [(470, a6.bottom), (470, m2.cy), (m2.x, m2.cy)])
    _flow(c, [(712, a7.bottom), (712, m2.cy), (m2.right, m2.cy)])
    d3 = c.decision(S, 770)
    _flow(c, [(A, m2.bottom), (A, 770), (d3.right, 770)])
    _flow(c, [(d3.x, d3.cy), (70, d3.cy), (70, m3.bottom)], "[plan more]", (80, d3.cy - 8))
    end = c.end(S, 835)
    _flow(c, [(S, d3.bottom), (S, end.y)], "[done]", (S + 8, d3.bottom + 18))
    return c


ALL = [("3a_activity_journey", journey), ("3b_activity_gap", gap_analysis),
       ("3c_activity_startup", startup), ("3d_activity_planning", planning)]

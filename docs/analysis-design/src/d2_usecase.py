"""Section 2: use case diagrams."""
from uml import Canvas, QUIET


def _assoc(c, a, b):
    c.path([a, b], sw=1.2)


def _dep(c, a, b, label, at=None, anchor="middle"):
    c.path([a, b], end="open", dash="6 4", label=label, label_at=at, label_anchor=anchor,
           label_size=11)


def app() -> Canvas:
    c = Canvas(1500, 1120,
               "Use case diagram: what students and department staff do with the app",
               "Solid lines associate an actor with a use case. Dashed arrows are «include» "
               "(always part of it) and «extend» (optional, under a condition).")
    c.rect(250, 84, 1000, 950, fill="none", sw=1.4)
    c.text(750, 108, "Career Readiness Advisor (iOS app + skill-gap API)", size=14, bold=True,
           anchor="middle")

    student = c.actor(110, 420, "Student")
    staff = c.actor(1390, 740, "Department staff", lines=["Department", "staff"])
    user = c.actor(110, 880, "App user", lines=["App user"])
    browser = c.system_actor(1296, 560, ["Web browser"], w=150)

    a1 = c.usecase(430, 150, ["Create profile", "(first launch)"])
    a6 = c.usecase(430, 250, ["Edit profile"])
    a2 = c.usecase(430, 370, ["View home dashboard"])
    a3 = c.usecase(430, 470, ["View full readiness"])
    a4 = c.usecase(430, 590, ["Plan courses", "(what-if)"])
    a5 = c.usecase(430, 700, ["View suggested courses"])
    a7 = c.usecase(430, 810, ["Delete profile"])
    lang = c.usecase(760, 975, ["Change language", "(English or Arabic, RTL)"])

    b1 = c.usecase(760, 200, ["Fill in profile form"])
    b3 = c.usecase(760, 470, ["Compare careers", "side by side"])
    b5 = c.usecase(760, 590, ["See projected readiness and", "the gaps each course closes"])
    b6 = c.usecase(760, 700, ["Open an online course"])
    b7 = c.usecase(760, 810, ["Confirm deletion"])

    c1 = c.usecase(1080, 112, ["Choose 1 to 3 target careers"])
    c2 = c.usecase(1080, 182, ["Select completed courses"])
    c3 = c.usecase(1080, 252, ["Report self-taught skills"])
    c4 = c.usecase(760, 300, ["Enter major"])
    note = c.note(980, 330, ["While selecting courses:", "· search by code or title,",
                             "  Arabic-Indic digits too", "· select all shown",
                             "· this level and below", "· review, clear and undo"], w=200)
    c.path([(c2.right, c2.cy), (1232, c2.cy), (1232, note.y + 40), (note.right, note.y + 40)],
           dash="3 3", sw=1)

    d1 = c.usecase(1080, 770, ["View curriculum gaps", "and coverage"])
    d2 = c.usecase(1080, 880, ["Filter by one career"])

    # actors to use cases
    sx = student.right + 2
    for uc in (a1, a6, a2, a3, a4, a5, a7):
        _assoc(c, (sx, student.y + 34), (uc.x + 4, uc.cy))
    _assoc(c, (staff.x - 2, staff.y + 34), (d1.right, d1.cy))
    _assoc(c, (user.right + 2, user.y + 34), (lang.x + 2, lang.cy))
    _assoc(c, (b6.right, b6.cy), (browser.x, browser.cy))

    # generalisation: both kinds of user are app users
    c.path([(110, 530), (110, 876)], end="hollow")
    c.path([(staff.cx, 850), (staff.cx, 1080), (150, 1080), (150, 940), (user.right + 4, 940)],
           end="hollow")

    # include and extend
    _dep(c, (a1.right, a1.cy), (b1.x + 6, b1.cy - 8), "«include»", at=(600, 160))
    _dep(c, (a6.right, a6.cy), (b1.x + 6, b1.cy + 8), "«include»", at=(600, 250))
    _dep(c, (b1.right - 6, b1.cy - 10), (c1.x + 6, c1.cy + 6), "«include»", at=(900, 140))
    _dep(c, (b1.right, b1.cy - 2), (c2.x, c2.cy + 4), "«include»", at=(918, 182))
    _dep(c, (c3.x, c3.cy - 4), (b1.right - 2, b1.cy + 6), "«extend»", at=(930, 262))
    _dep(c, (c4.cx, c4.y), (b1.cx, b1.bottom), "«extend»", at=(768, 256), anchor="start")
    _dep(c, (b3.x, b3.cy), (a3.right, a3.cy), "«extend»", at=(588, 464))
    c.text(588, 490, "[2 or 3 careers]", size=10.5, anchor="middle", fill=QUIET)
    _dep(c, (a4.right, a4.cy), (b5.x, b5.cy), "«include»", at=(586, 584))
    _dep(c, (b6.x, b6.cy), (a5.right, a5.cy), "«extend»", at=(590, 694))
    _dep(c, (a7.right, a7.cy), (b7.x, b7.cy), "«include»", at=(590, 804))
    _dep(c, (d2.cx, d2.y), (d1.cx, d1.bottom), "«extend»", at=(1090, 832), anchor="start")
    return c


def data_prep() -> Canvas:
    c = Canvas(1440, 950,
               "Use case diagram: how the researcher prepares the data the engine serves",
               "Offline tools in test/, skillgap/, backend/ and app/tool/. None of them runs "
               "inside the app.")
    c.rect(250, 80, 920, 840, fill="none", sw=1.4)
    c.text(710, 104, "Data preparation and engine tools", size=14, bold=True, anchor="middle")

    res = c.actor(110, 420, "Researcher", lines=["Researcher", "(project author)"])
    jsearch = c.system_actor(1230, 128, ["JSearch API"], w=170)
    hf = c.system_actor(1230, 622, ["Hugging Face Hub", "multilingual-e5-base"], w=190)

    e1 = c.usecase(470, 150, ["Collect job postings", "(collect_postings.py)"])
    e2 = c.usecase(470, 250, ["Hand-label postings", "(evaluation set of 15)"])
    e3 = c.usecase(470, 350, ["Label catalog courses", "(33 Shaqra courses)"])
    e4 = c.usecase(470, 450, ["Curate online courses", "(online_courses.csv)"])
    e5 = c.usecase(470, 550, ["Run the validation sweep", "(validate.py)"])
    e6 = c.usecase(470, 650, ["Start the API and build", "career profiles"])
    e7 = c.usecase(470, 750, ["Run reports", "(min-demand, course reach)"])
    e8 = c.usecase(470, 850, ["Check the API contract", "(contract_check.dart)"])

    f1 = c.usecase(900, 150, ["Screen postings and", "record the excluded ones"])
    f2 = c.usecase(900, 250, ["Merge labels into", "the corpus"])
    f4 = c.usecase(900, 450, ["Sync placeholder rows", "with the gap skills"])
    f5 = c.usecase(900, 550, ["Write config.json with", "gate_passed"])
    f6 = c.usecase(900, 650, ["Embed texts with", "the model"])

    rx = res.right + 2
    for uc in (e1, e2, e3, e4, e5, e6, e7, e8):
        c.path([(rx, res.y + 34), (uc.x + 4, uc.cy)])
    c.path([(f1.right, f1.cy), (jsearch.x, jsearch.cy)])
    c.path([(f6.right, f6.cy), (hf.x, hf.cy)])

    _dep(c, (e1.right, e1.cy), (f1.x, f1.cy), "«include»", at=(675, 144))
    _dep(c, (e2.right, e2.cy), (f2.x, f2.cy), "«include»", at=(675, 244))
    _dep(c, (f4.x, f4.cy), (e4.right, e4.cy), "«extend»", at=(675, 444))
    _dep(c, (e5.right, e5.cy), (f5.x, f5.cy), "«include»", at=(675, 544))
    _dep(c, (e5.right - 20, e5.bottom - 6), (f6.x + 30, f6.y + 6), "«include»", at=(712, 592),
         anchor="start")
    _dep(c, (f6.x, f6.cy), (e6.right, e6.cy), "«extend»", at=(675, 644))
    c.text(675, 670, "[cache miss]", size=10.5, anchor="middle", fill=QUIET)
    return c


ALL = [("2a_usecase_app", app), ("2b_usecase_data", data_prep)]

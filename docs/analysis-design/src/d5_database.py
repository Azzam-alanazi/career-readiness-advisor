"""Section 5: the data stores, drawn as a database diagram."""
from uml import Canvas, QUIET, F_STORE, F_EXTERNAL

NB = "  "


def _ry(box, i, sub=True):
    """The y of row i's centre in a table drawn by Canvas.table."""
    head = 26 + (14 if sub else 0)
    return box.y + head + 4 + (i + 1) * 17.5 - 9


def stores() -> Canvas:
    c = Canvas(1560, 1010,
               "Database diagram: no database server; the data lives in files and on the phone",
               "PK identifies a row, FK points at another store, UQ is unique. Crow's feet give "
               "cardinality: a ring is zero, a bar is one, a fork is many.")
    postings = c.table(24, 84, "labeled_postings.csv", [
        ("PK", "id", "integer"),
        ("", "career", "8 careers"),
        ("", "job_title", ""),
        ("", "lang", "en | ar"),
        ("", "posting_text", "full description"),
        ("FK", "skill_ids", "→ taxonomy.id, ';' list"),
        ("", "employer", ""),
        ("", "city", ""),
        ("", "source", "LinkedIn, BeBee, Bayt…"),
        ("UQ", "url", "no duplicates"),
        ("", "onet_soc", ""),
    ], subtitle="test/ · 82 rows · 15 hand-labelled", w=340)
    config = c.table(600, 84, "config.json", [
        ("", "model", "multilingual-e5-base"),
        ("", "taxonomy_skills", "91: must match"),
        ("", "gate_passed", "false"),
        ("", "gate_min_f1", "0.60"),
        ("", "postings.*", "chunk_top1, 0.814, F1 0.504"),
        ("", "courses.*", "skill_centric, 0.894, F1 0.373"),
    ], subtitle="skillgap/ · one document, written by validate.py", w=340, head_fill=F_STORE)
    courses = c.table(1180, 84, "labeled_courses.csv", [
        ("", "id", ""),
        ("PK", "course_code", "e.g. CIT 201"),
        ("", "course_title", ""),
        ("", "track", "college | core | elective_*"),
        ("", "lang", "en"),
        ("", "course_text", "the title"),
        ("FK", "skill_ids", "→ taxonomy.id; NONE for 9"),
    ], subtitle="skillgap/ · 33 Shaqra IS courses", w=320)
    tax = c.table(640, 400, "taxonomy.json · skills[]", [
        ("PK", "id", "SK01 … SK91"),
        ("", "en", "English name"),
        ("", "ar", "Arabic name"),
        ("", "category", "8 categories"),
    ], subtitle="skillgap/ · 91 rows", w=260)
    online = c.table(1180, 330, "online_courses.csv", [
        ("PK FK", "skill_id", "→ taxonomy.id"),
        ("PK", "url", "one course, many skills"),
        ("", "provider", "12 providers"),
        ("", "course_title", ""),
        ("", "is_free", "yes | no"),
    ], subtitle="skillgap/ · 47 rows, 28 courses", w=320)
    cexcl = c.table(1180, 540, "labeled_courses_excluded.csv", [
        ("PK", "course_code", ""),
        ("", "course_title, track", ""),
        ("", "basis", ""),
        ("", "reason", "why it is left out"),
    ], subtitle="skillgap/ · 15 rows", w=320, head_fill="#EEF0F3")
    cache = c.table(560, 620, "engine-<key>.json", [
        ("PK", "key", "SHA-256 of every input"),
        ("", "profiles[career]", "8 careers"),
        ("", NB + ".posting_count", "10 or 11"),
        ("FK", NB + ".demand[skill_id]", "share 0..1 → taxonomy.id"),
        ("FK", "courses[course_code]", "→ labeled_courses"),
        ("", NB + ".name, .skills[]", "what extraction found"),
    ], subtitle="backend/.cache/ · rebuilt when the key changes", w=340, head_fill=F_STORE)
    pexcl = c.table(24, 780, "labeled_postings_excluded.csv", [
        ("PK", "id", ""),
        ("", "the 11 posting columns", ""),
        ("", "excluded_reason", "country, remote, too short"),
        ("", "excluded_on", "date"),
    ], subtitle="test/ · 28 rows screened out", w=340, head_fill="#EEF0F3")
    device = c.table(1100, 790, "shared_preferences", [
        ("PK", "student_profile", "JSON, one per device"),
        ("FK", NB + "careers[1..3]", "→ a posting career"),
        ("FK", NB + "completed_courses[]", "→ course_code"),
        ("FK", NB + "planned_courses[]", "→ course_code"),
        ("FK", NB + "self_reported_skills[]", "→ taxonomy.id"),
        ("", NB + "major", "optional"),
        ("PK", "language", "en | ar"),
    ], subtitle="on the iPhone (NSUserDefaults) · key-value", w=400, head_fill="#EAF5EA")

    # skills: postings and courses name many skills; a skill is named by many
    y1 = _ry(postings, 5)
    c.path([(postings.right, y1), (520, y1), (520, _ry(tax, 0)), (tax.x, _ry(tax, 0))],
           start="cf-zmany", end="cf-zmany")
    c.text(528, y1 - 6, "skill_ids → id (hand labels)", size=10.5, fill=QUIET)
    y2 = _ry(courses, 6)
    c.path([(courses.x, y2), (980, y2), (980, _ry(tax, 1)), (tax.right, _ry(tax, 1))],
           start="cf-zmany", end="cf-zmany")
    c.text(988, y2 - 6, "skill_ids → id", size=10.5, fill=QUIET)
    y3 = _ry(online, 0)
    c.path([(online.x, y3), (1010, y3), (1010, _ry(tax, 3)), (tax.right, _ry(tax, 3))],
           start="cf-many", end="cf-one")
    c.text(1018, y3 - 6, "skill_id → id", size=10.5, fill=QUIET)
    # demand weights per skill
    c.path([(tax.cx, cache.y), (tax.cx, tax.bottom)], start="cf-zmany", end="cf-one")
    c.text(tax.cx + 8, (tax.bottom + cache.y) / 2 + 4, "demand[skill_id] → id", size=10.5,
           fill=QUIET)
    # profiles are built from each career's postings
    px = postings.x + postings.w * 0.8
    c.path([(px, postings.bottom), (px, _ry(cache, 1)), (cache.x, _ry(cache, 1))],
           start="cf-many", end="cf-one")
    c.text(px + 8, _ry(cache, 1) - 6, "a career's postings → its profile", size=10.5, fill=QUIET)
    # course skills extracted per catalog course
    yc = _ry(cache, 4)
    c.path([(cache.right, yc), (1530, yc), (1530, _ry(courses, 1)), (courses.right, _ry(courses, 1))],
           start="cf-one", end="cf-one")
    c.text(cache.right + 8, yc - 6, "one entry per catalog course", size=10.5, fill=QUIET)
    # the config is measured against this taxonomy
    c.path([(config.cx, config.bottom), (config.cx, tax.y)], end="open", dash="6 4")
    c.text(config.cx + 8, (config.bottom + tax.y) / 2, "«measured on» 91 skills;",
           size=10.5, fill=QUIET)
    c.text(config.cx + 8, (config.bottom + tax.y) / 2 + 14, "a mismatch stops start-up",
           size=10.5, fill=QUIET)

    c.note(560, 820, ["The server stores nothing about students.",
                      "profiles.sqlite3 and the /profiles endpoints",
                      "were removed on 1 October 2026.",
                      "",
                      "The phone's ids are references by value:",
                      "the API checks them on every request (422),",
                      "and the app drops ids it no longer serves."], w=330)
    return c


ALL = [("5_database_stores", stores)]

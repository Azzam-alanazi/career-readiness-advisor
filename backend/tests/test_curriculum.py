"""The department's view: the whole catalog against the postings, not one student."""
import pytest

from backend.tests.world import COURSES, write_world

# IS230 labelled SQL. BUS210 labelled NONE, though extraction would read
# communication into its text: the view must use the labels. IS210 is left to
# extraction (python). IS320 labelled ERP.
LABELLED = [(*COURSES[0], "SQ"), (*COURSES[1], "NONE"), COURSES[2], (*COURSES[3], "ER")]


@pytest.fixture
def dept(make_client, tmp_path):
    with make_client(write_world(tmp_path / "dept", courses=LABELLED)) as c:
        yield c


def view(client, career=None) -> dict:
    r = client.get("/curriculum/gap", params={} if career is None else {"career": career})
    assert r.status_code == 200, r.text
    return r.json()


def uncovered(v: dict) -> list[tuple]:
    return [(s["id"], s["postings"], s["demand_percent"], s["careers"]) for s in v["uncovered"]]


# ---- one career ---------------------------------------------------------------------

def test_one_career_lists_the_demanded_skills_no_course_teaches(dept):
    # Analyst: SQL in 2/2 postings, communication in 1/2. IS230 teaches SQL;
    # BUS210 is labelled as teaching nothing.
    v = view(dept, "Analyst")
    assert (v["career"], v["posting_count"]) == ("Analyst", 2)
    assert (v["demanded"], v["taught"], v["coverage"], v["coverage_percent"]) == (2, 1, 0.5, 50)
    assert uncovered(v) == [("CM", 1, 50, ["Analyst"])]
    assert v["uncovered"][0]["ar"] == "مهارات التواصل"


def test_taught_skills_no_posting_asks_for_come_with_their_courses(dept):
    assert [(s["id"], s["courses"]) for s in view(dept, "Analyst")["not_asked"]] == [
        ("PY", ["IS210"]), ("ER", ["IS320"])]
    # Developer postings ask for python, so only ERP is left unasked.
    assert [(s["id"], s["courses"]) for s in view(dept, "Developer")["not_asked"]] == [
        ("ER", ["IS320"])]


# ---- every career -------------------------------------------------------------------

def test_all_careers_pool_every_posting(dept):
    v = view(dept)
    assert (v["career"], v["posting_count"]) == (None, 4)
    # Demanded: SQL (3 of 4 postings), python (2), communication (1). Taught:
    # SQL and python.
    assert (v["demanded"], v["taught"], v["coverage"], v["coverage_percent"]) == (
        3, 2, 0.6667, 67)
    assert uncovered(v) == [("CM", 1, 25, ["Analyst"])]
    assert [s["id"] for s in v["not_asked"]] == ["ER"]


def test_uncovered_skills_rank_by_their_share_of_every_posting(make_client, tmp_path):
    with make_client(write_world(tmp_path / "erp", courses=[(*COURSES[3], "ER")])) as c:
        v = view(c)
    assert uncovered(v) == [("SQ", 3, 75, ["Analyst", "Developer"]),
                            ("PY", 2, 50, ["Developer"]),
                            ("CM", 1, 25, ["Analyst"])]
    assert [s["demand"] for s in v["uncovered"]] == [0.75, 0.5, 0.25]
    assert (v["taught"], v["coverage"], v["coverage_percent"]) == (0, 0.0, 0)


def test_every_careers_coverage_comes_with_any_scope(dept):
    expected = [{"career": "Analyst", "posting_count": 2, "demanded": 2, "taught": 1,
                 "coverage": 0.5, "coverage_percent": 50},
                {"career": "Developer", "posting_count": 2, "demanded": 2, "taught": 2,
                 "coverage": 1.0, "coverage_percent": 100}]
    for scope in (None, "Analyst", "Developer"):
        assert view(dept, scope)["per_career"] == expected
    assert view(dept, "Developer")["coverage"] == 1.0


# ---- the same numbers the student view uses -----------------------------------------

def test_a_careers_gaps_are_what_a_student_with_every_course_still_misses(dept):
    every = [code for code, *_ in LABELLED]
    for career in ("Analyst", "Developer"):
        prof = dept.post("/profiles", json={"career": career, "completed_courses": every}).json()
        missing = {s["id"] for s in dept.get(f"/profiles/{prof['id']}/gap").json()["missing"]}
        assert missing == {s["id"] for s in view(dept, career)["uncovered"]}


def test_an_unknown_career_is_rejected_by_name(dept):
    r = dept.get("/curriculum/gap", params={"career": "Astronaut"})
    assert r.status_code == 422
    assert r.json()["detail"]["career"] == "Astronaut"


def test_the_view_says_how_small_the_sample_is_and_carries_the_quality_flag(dept):
    v = view(dept)
    assert "4 job postings, 2 per career" in v["sample_note"]
    assert "should not drive curriculum decisions on their own" in v["sample_note"]
    assert v["min_demand"] == 0.15
    assert v["validation"]["gate_passed"] is False

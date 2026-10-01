"""Online courses: the fallback for skills no university course teaches."""
import csv
import json

import pytest

from backend.engine import Paths, build_state
from backend.online import (COLUMNS, OnlineCatalog, OnlineCoursesError, gap_skills,
                            load_online_courses, sync)
from backend.tests.world import COURSES, write_world

# The fixture world without Business Communication: nothing in the catalog
# teaches communication any more, so it is a gap only an online course can fill.
NO_BUS210 = [c for c in COURSES if c[0] != "BUS210"]
SPEAKING = ("CM", "Example Academy", "Speaking with confidence",
            "https://example.com/speaking", "yes")
SQL_ONLINE = ("SQ", "Example Academy", "SQL basics", "https://example.com/sql", "no")


def recommendations(client, career, **params) -> dict:
    r = client.post("/recommendations", params=params, json={"career": career})
    assert r.status_code == 200, r.text
    return r.json()


def csv_file(tmp_path, *rows):
    path = tmp_path / "online.csv"
    with path.open("w", newline="", encoding="utf-8-sig") as f:
        w = csv.writer(f)
        w.writerow(COLUMNS)
        w.writerows(rows)
    return path


# ---- the recommendation rule -----------------------------------------------------

def test_online_courses_only_for_skills_no_university_course_teaches(make_client, tmp_path):
    paths = write_world(tmp_path / "w", courses=NO_BUS210, online=[SPEAKING, SQL_ONLINE])
    with make_client(paths=paths) as c:
        body = recommendations(c, "Analyst")
    recs = body["recommendations"]
    # SQL is taught by IS230, so its online course is never offered.
    # Communication is taught by nothing in the catalog, so it gets one.
    assert [(r["source"], [s["id"] for s in r["closes"]]) for r in recs] == [
        ("university", ["SQ"]), ("online", ["CM"])]
    online = recs[1]
    assert (online["provider"], online["title"], online["url"], online["is_free"]) == (
        "Example Academy", "Speaking with confidence", "https://example.com/speaking", True)
    assert online["closes"][0]["ar"] == "مهارات التواصل"
    assert body["uncovered"] == []


def test_a_gap_neither_source_covers_is_listed_not_dropped(make_client, tmp_path):
    paths = write_world(tmp_path / "w", courses=NO_BUS210)
    with make_client(paths=paths) as c:
        body = recommendations(c, "Analyst")
    assert [r["code"] for r in body["recommendations"]] == ["IS230"]
    assert [(s["id"], s["demand_percent"]) for s in body["uncovered"]] == [("CM", 50)]


def test_limit_caps_each_list_on_its_own(make_client, tmp_path):
    second = ("CM", "Example Academy", "Presenting data", "https://example.com/present", "no")
    paths = write_world(tmp_path / "w", courses=NO_BUS210, online=[SPEAKING, second])
    with make_client(paths=paths) as c:
        everything = recommendations(c, "Analyst")["recommendations"]
        capped = recommendations(c, "Analyst", limit=1)["recommendations"]
    assert [r["source"] for r in everything] == ["university", "online", "online"]
    assert [r["source"] for r in capped] == ["university", "online"]


def test_health_counts_filled_courses_and_placeholders(make_client, tmp_path):
    paths = write_world(tmp_path / "w", online=[SPEAKING, ("PY", "", "", "", "")])
    with make_client(paths=paths) as c:
        body = c.get("/health").json()
    assert (body["online_courses"], body["online_placeholders"]) == (1, 1)


# ---- which skills need a row -----------------------------------------------------

def test_gap_skills_are_the_demanded_skills_no_university_course_teaches(tmp_path, embedder):
    assert gap_skills(build_state(write_world(tmp_path / "all"), embedder)) == []
    assert gap_skills(build_state(write_world(tmp_path / "some", courses=NO_BUS210),
                                  embedder)) == ["CM"]


def test_sync_matches_placeholders_to_the_gaps_and_never_touches_a_filled_row(tmp_path):
    path = tmp_path / "online.csv"
    assert sync(path, ["CM", "PY"]) == (["CM", "PY"], [])       # creates the file
    filled = path.read_text(encoding="utf-8-sig").replace(
        "CM,,,,", "CM,Example Academy,Speaking,https://example.com/s,yes")
    path.write_text(filled, encoding="utf-8-sig")

    assert sync(path, ["CM", "PY", "SQ"]) == (["SQ"], [])
    assert sync(path, ["CM", "PY", "SQ"]) == ([], [])
    # Neither CM nor PY is a gap any more. PY's placeholder goes; CM's row has a
    # course filled in, so it stays.
    assert sync(path, ["SQ"]) == ([], ["PY"])
    catalog = load_online_courses(path, {"CM", "PY", "SQ"})
    assert [(c.title, c.skills) for c in catalog.courses] == [("Speaking", ("CM",))]
    assert catalog.placeholders == 1


def test_sync_on_an_empty_file_writes_the_header_the_loader_needs(tmp_path):
    path = tmp_path / "online.csv"
    path.write_bytes(b"")
    assert sync(path, ["CM", "PY"]) == (["CM", "PY"], [])
    catalog = load_online_courses(path, {"CM", "PY"})
    assert (list(catalog.courses), catalog.placeholders) == ([], 2)


# ---- the loader fails loudly ------------------------------------------------------

def test_unknown_skill_id_fails_loudly_with_its_line(tmp_path):
    path = csv_file(tmp_path, ("SK01", "", "", "", ""),
                    ("SK999", "Example Academy", "A", "https://example.com/a", "yes"))
    with pytest.raises(OnlineCoursesError, match=r"line 3: unknown skill_id 'SK999'"):
        load_online_courses(path, {"SK01"})


def test_an_unknown_id_on_a_placeholder_fails_too(tmp_path):
    with pytest.raises(OnlineCoursesError, match="unknown skill_id 'SK9'"):
        load_online_courses(csv_file(tmp_path, ("SK9", "", "", "", "")), {"SK01"})


def test_every_problem_is_reported_in_one_go(tmp_path):
    path = csv_file(
        tmp_path,
        ("SK01", "Example Academy", "", "https://example.com/a", "yes"),    # partly filled
        ("SK01", "Example Academy", "A", "example.com/a", "yes"),           # no scheme
        ("SK01", "Example Academy", "A", "https://example.com/a", "maybe"), # not yes/no
        ("", "Example Academy", "A", "https://example.com/a", "yes"),       # no skill id
    )
    with pytest.raises(OnlineCoursesError) as err:
        load_online_courses(path, {"SK01"})
    for line in (2, 3, 4, 5):
        assert f"line {line}" in str(err.value)


def test_one_course_listed_under_two_skills_is_one_course(tmp_path):
    path = csv_file(tmp_path,
                    ("SK01", "Example Academy", "A", "https://example.com/a", "TRUE"),
                    ("SK02", "Example Academy", "A", "https://example.com/a", "true"),
                    ("SK03", "", "", "", ""))
    catalog = load_online_courses(path, {"SK01", "SK02", "SK03"})
    assert [(c.url, c.skills, c.is_free) for c in catalog.courses] == [
        ("https://example.com/a", ("SK01", "SK02"), True)]
    assert catalog.placeholders == 1


def test_one_url_with_two_different_descriptions_is_an_error(tmp_path):
    path = csv_file(tmp_path,
                    ("SK01", "Example Academy", "A", "https://example.com/a", "yes"),
                    ("SK02", "Example Academy", "A", "https://example.com/a", "no"))
    with pytest.raises(OnlineCoursesError, match="also on line 2"):
        load_online_courses(path, {"SK01", "SK02"})


def test_a_missing_column_is_an_error(tmp_path):
    path = tmp_path / "online.csv"
    path.write_text("skill_id,provider,course_title,url\nSK01,,,\n", encoding="utf-8")
    with pytest.raises(OnlineCoursesError, match="missing column"):
        load_online_courses(path, {"SK01"})


def test_no_file_means_no_online_courses(tmp_path):
    assert load_online_courses(tmp_path / "absent.csv", {"SK01"}) == OnlineCatalog()


def test_bad_online_courses_refuse_startup_before_the_model_loads(tmp_path, embedder):
    paths = write_world(tmp_path / "w",
                        online=[("SK999", "Example Academy", "A", "https://example.com/a", "yes")])
    with pytest.raises(OnlineCoursesError):
        build_state(paths, embedder)
    assert embedder.instances == 0


def test_the_shipped_file_loads_with_every_row_filled_in():
    paths = Paths()
    ids = {s["id"] for s in json.loads(paths.taxonomy.read_text(encoding="utf-8"))["skills"]}
    catalog = load_online_courses(paths.online_courses, ids)
    assert catalog.placeholders == 0
    assert sum(len(c.skills) for c in catalog.courses) == 47

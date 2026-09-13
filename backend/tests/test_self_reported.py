"""Self-reported skills: counted with course skills, and always reported apart."""
import sqlite3

import pytest

from backend.store import ProfileStore


def create(client, career, courses, skills=()) -> dict:
    r = client.post("/profiles", json={"career": career, "completed_courses": courses,
                                       "self_reported_skills": list(skills)})
    assert r.status_code == 201, r.text
    return r.json()


def gap(client, profile) -> dict:
    return client.get(f"/profiles/{profile['id']}/gap").json()


# ---- the profile -------------------------------------------------------------------

def test_self_reported_skills_are_stored_without_duplicates(client):
    prof = create(client, "Analyst", ["IS230"], ["CM", "CM", "PY"])
    assert prof["self_reported_skills"] == ["CM", "PY"]
    assert client.get(f"/profiles/{prof['id']}").json()["self_reported_skills"] == ["CM", "PY"]


def test_they_are_optional(client):
    r = client.post("/profiles", json={"career": "Analyst", "completed_courses": ["IS230"]})
    assert r.status_code == 201 and r.json()["self_reported_skills"] == []


def test_an_unknown_skill_id_is_rejected_by_name(client):
    r = client.post("/profiles", json={"career": "Analyst", "self_reported_skills": ["CM", "XX"]})
    assert r.status_code == 422
    assert r.json()["detail"]["unknown"] == ["XX"]


# ---- readiness and provenance ------------------------------------------------------

def test_readiness_counts_both_sources_and_reports_them_apart(client):
    # Analyst: SQL in 2/2 postings, communication in 1/2. IS230 teaches SQL; the
    # student reports communication.
    g = gap(client, create(client, "Analyst", ["IS230"], ["CM"]))
    assert (g["readiness"], g["readiness_percent"]) == (1.0, 100)
    assert g["readiness_from_courses"] == pytest.approx(2 / 3, abs=1e-4)
    assert g["readiness_from_courses_percent"] == 67
    assert [(s["id"], s["source"]) for s in g["covered"]] == [
        ("SQ", "courses"), ("CM", "self_reported")]
    assert [s["id"] for s in g["covered_from_courses"]] == ["SQ"]
    assert [s["id"] for s in g["covered_self_reported"]] == ["CM"]
    assert g["missing"] == []


def test_a_skill_a_completed_course_teaches_counts_as_from_courses(client):
    g = gap(client, create(client, "Analyst", ["IS230"], ["SQ"]))
    assert [(s["id"], s["source"]) for s in g["covered"]] == [("SQ", "courses")]
    assert g["covered_self_reported"] == []
    assert g["readiness"] == g["readiness_from_courses"]


def test_a_skill_the_career_does_not_ask_for_changes_nothing(client):
    g = gap(client, create(client, "Analyst", ["IS230"], ["ER"]))
    assert g["covered_self_reported"] == []
    assert g["readiness"] == g["readiness_from_courses"]


def test_without_self_reported_skills_both_readings_agree(client):
    g = gap(client, create(client, "Developer", ["IS210"]))
    assert g["readiness"] == g["readiness_from_courses"]
    assert [s["source"] for s in g["covered"]] == ["courses"]


def test_suggestions_skip_skills_the_student_reports(client):
    prof = create(client, "Analyst", [], ["CM"])
    recs = client.get(f"/profiles/{prof['id']}/recommendations").json()["recommendations"]
    assert [r["code"] for r in recs] == ["IS230"]


# ---- what the app needs to offer the choice -----------------------------------------

def test_skills_are_listed_for_choosing(client):
    skills = client.get("/skills").json()
    assert [s["id"] for s in skills] == ["SQ", "CM", "PY", "ER"]
    assert skills[1] == {"id": "CM", "en": "communication presentation",
                         "ar": "مهارات التواصل", "category": "professional"}


def test_courses_list_the_skills_they_teach(client):
    got = {c["code"]: c["skills"] for c in client.get("/courses").json()}
    assert got == {"IS230": ["SQ"], "BUS210": ["CM"], "IS210": ["PY"], "IS320": ["ER"]}


# ---- storage ------------------------------------------------------------------------

def test_profiles_saved_before_self_reported_skills_still_load(tmp_path):
    db = tmp_path / "old.sqlite3"
    con = sqlite3.connect(db)
    con.execute("CREATE TABLE profiles (id TEXT PRIMARY KEY, career TEXT NOT NULL, "
                "major TEXT, completed_courses TEXT NOT NULL, created_at TEXT NOT NULL)")
    con.execute("INSERT INTO profiles VALUES "
                "('old1', 'Analyst', NULL, '[\"IS230\"]', '2026-09-10T00:00:00+00:00')")
    con.commit()
    con.close()

    store = ProfileStore(db)
    assert store.get("old1")["self_reported_skills"] == []
    new = store.create("Analyst", None, [], ["CM"])
    assert store.get(new["id"])["self_reported_skills"] == ["CM"]

"""Self-reported skills: counted with course skills, and always reported apart."""
import pytest


def gap(client, career, courses, skills=()) -> dict:
    r = client.post("/gap", json={"career": career, "completed_courses": courses,
                                  "self_reported_skills": list(skills)})
    assert r.status_code == 200, r.text
    return r.json()


# ---- the profile -------------------------------------------------------------------

def test_a_repeated_skill_counts_once(client):
    g = gap(client, "Analyst", ["IS230"], ["CM", "CM"])
    assert [s["id"] for s in g["covered_self_reported"]] == ["CM"]
    assert g == gap(client, "Analyst", ["IS230"], ["CM"])


def test_they_are_optional(client):
    r = client.post("/gap", json={"career": "Analyst", "completed_courses": ["IS230"]})
    assert r.status_code == 200 and r.json()["covered_self_reported"] == []


def test_an_unknown_skill_id_is_rejected_by_name(client):
    r = client.post("/gap", json={"career": "Analyst", "self_reported_skills": ["CM", "XX"]})
    assert r.status_code == 422
    assert r.json()["detail"]["unknown"] == ["XX"]


# ---- readiness and provenance ------------------------------------------------------

def test_readiness_counts_both_sources_and_reports_them_apart(client):
    # Analyst: SQL in 2/2 postings, communication in 1/2. IS230 teaches SQL; the
    # student reports communication.
    g = gap(client, "Analyst", ["IS230"], ["CM"])
    assert (g["readiness"], g["readiness_percent"]) == (1.0, 100)
    assert g["readiness_from_courses"] == pytest.approx(2 / 3, abs=1e-4)
    assert g["readiness_from_courses_percent"] == 67
    assert [(s["id"], s["source"]) for s in g["covered"]] == [
        ("SQ", "courses"), ("CM", "self_reported")]
    assert [s["id"] for s in g["covered_from_courses"]] == ["SQ"]
    assert [s["id"] for s in g["covered_self_reported"]] == ["CM"]
    assert g["missing"] == []


def test_a_skill_a_completed_course_teaches_counts_as_from_courses(client):
    g = gap(client, "Analyst", ["IS230"], ["SQ"])
    assert [(s["id"], s["source"]) for s in g["covered"]] == [("SQ", "courses")]
    assert g["covered_self_reported"] == []
    assert g["readiness"] == g["readiness_from_courses"]


def test_a_skill_the_career_does_not_ask_for_changes_nothing(client):
    g = gap(client, "Analyst", ["IS230"], ["ER"])
    assert g["covered_self_reported"] == []
    assert g["readiness"] == g["readiness_from_courses"]


def test_without_self_reported_skills_both_readings_agree(client):
    g = gap(client, "Developer", ["IS210"])
    assert g["readiness"] == g["readiness_from_courses"]
    assert [s["source"] for s in g["covered"]] == ["courses"]


def test_suggestions_skip_skills_the_student_reports(client):
    recs = client.post("/recommendations", json={"career": "Analyst",
                                                 "self_reported_skills": ["CM"]}
                       ).json()["recommendations"]
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


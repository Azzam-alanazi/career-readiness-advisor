"""Up to three target careers on one profile, each read against the same record."""
import sqlite3

from backend.store import ProfileStore


def create(client, **body) -> dict:
    r = client.post("/profiles", json=body)
    assert r.status_code == 201, r.text
    return r.json()


# ---- the profile -------------------------------------------------------------------

def test_other_careers_are_stored_after_the_first(client):
    prof = create(client, career="Analyst", other_careers=["Developer"])
    assert (prof["career"], prof["other_careers"], prof["careers"]) == (
        "Analyst", ["Developer"], ["Analyst", "Developer"])
    assert client.get(f"/profiles/{prof['id']}").json()["careers"] == ["Analyst", "Developer"]


def test_they_are_optional_and_repeats_are_dropped(client):
    assert create(client, career="Analyst")["careers"] == ["Analyst"]
    assert create(client, career="Analyst",
                  other_careers=["Developer", "Developer"])["other_careers"] == ["Developer"]
    assert create(client, career="Analyst",
                  other_careers=["Analyst", "Developer"])["other_careers"] == ["Developer"]


def test_an_unknown_career_is_rejected_by_name(client):
    r = client.post("/profiles", json={"career": "Analyst", "other_careers": ["Astronaut"]})
    assert r.status_code == 422
    assert r.json()["detail"]["unknown"] == ["Astronaut"]


def test_no_more_than_three_careers_in_all(client):
    r = client.post("/profiles", json={"career": "Analyst",
                                       "other_careers": ["Developer", "Developer", "Analyst"]})
    assert r.status_code == 422


# ---- reading the profile against one of its careers ---------------------------------

def test_each_career_reads_the_same_record(client):
    # IS230 teaches SQL: all of Analyst's top skill, half of Developer's second.
    both = create(client, career="Analyst", completed_courses=["IS230"],
                  other_careers=["Developer"])
    alone = create(client, career="Developer", completed_courses=["IS230"])
    mine = client.get(f"/profiles/{both['id']}/gap", params={"career": "Developer"}).json()
    theirs = client.get(f"/profiles/{alone['id']}/gap").json()
    assert mine["career"] == "Developer"
    for key in ("readiness", "readiness_from_courses", "covered", "missing"):
        assert mine[key] == theirs[key]


def test_the_first_career_is_the_default(client):
    prof = create(client, career="Analyst", completed_courses=["IS230"],
                  other_careers=["Developer"])
    assert client.get(f"/profiles/{prof['id']}/gap").json()["career"] == "Analyst"


def test_suggestions_follow_the_career_asked_for(client):
    prof = create(client, career="Analyst", other_careers=["Developer"])
    recs = client.get(f"/profiles/{prof['id']}/recommendations",
                      params={"career": "Developer"}).json()
    assert recs["career"] == "Developer"
    assert {r["code"] for r in recs["recommendations"]} == {"IS210", "IS230"}


def test_a_career_the_profile_does_not_name_is_refused(client):
    prof = create(client, career="Analyst")
    for path in ("gap", "recommendations"):
        r = client.get(f"/profiles/{prof['id']}/{path}", params={"career": "Developer"})
        assert r.status_code == 422
        assert r.json()["detail"]["careers"] == ["Analyst"]


# ---- storage ------------------------------------------------------------------------

def test_a_stored_career_that_left_the_corpus_is_ignored(client, tmp_path):
    # Written straight to the store the app reads, as a profile saved before the
    # career was dropped from the postings would be.
    old = ProfileStore(tmp_path / "profiles.sqlite3").create(
        "Analyst", None, [], (), ["Retired"])
    assert client.get(f"/profiles/{old['id']}/gap").json()["career"] == "Analyst"
    r = client.get(f"/profiles/{old['id']}/gap", params={"career": "Retired"})
    assert r.status_code == 422 and r.json()["detail"]["careers"] == ["Analyst"]


def test_profiles_saved_before_other_careers_still_load(tmp_path):
    db = tmp_path / "old.sqlite3"
    con = sqlite3.connect(db)
    con.execute("CREATE TABLE profiles (id TEXT PRIMARY KEY, career TEXT NOT NULL, "
                "major TEXT, completed_courses TEXT NOT NULL, created_at TEXT NOT NULL, "
                "self_reported_skills TEXT NOT NULL DEFAULT '[]')")
    con.execute("INSERT INTO profiles (id, career, major, completed_courses, created_at) "
                "VALUES ('old1', 'Analyst', NULL, '[]', '2026-09-13T00:00:00+00:00')")
    con.commit()
    con.close()

    store = ProfileStore(db)
    assert store.get("old1")["other_careers"] == []
    new = store.create("Analyst", None, [], (), ["Developer"])
    assert store.get(new["id"])["other_careers"] == ["Developer"]

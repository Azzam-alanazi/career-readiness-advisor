"""The app keeps the profile on the device; these endpoints read it and store nothing."""
import sqlite3


def stored_rows(tmp_path) -> int:
    con = sqlite3.connect(tmp_path / "profiles.sqlite3")
    try:
        return con.execute("SELECT COUNT(*) FROM profiles").fetchone()[0]
    finally:
        con.close()


def test_a_gap_for_a_profile_sent_with_the_request_matches_a_stored_one(client):
    body = {"career": "Analyst", "completed_courses": ["IS230"], "self_reported_skills": ["CM"]}
    stateless = client.post("/gap", json=body)
    assert stateless.status_code == 200, stateless.text
    stored = client.post("/profiles", json=body).json()
    via_store = client.get(f"/profiles/{stored['id']}/gap").json()
    got = stateless.json()
    assert got["profile_id"] is None and via_store["profile_id"] == stored["id"]
    for key in ("career", "readiness", "readiness_from_courses", "covered",
                "covered_from_courses", "covered_self_reported", "missing", "validation"):
        assert got[key] == via_store[key]


def test_suggestions_for_a_profile_sent_with_the_request(client):
    # Analyst, no courses, communication reported: only SQL is missing.
    recs = client.post("/recommendations",
                       json={"career": "Analyst", "self_reported_skills": ["CM"]}).json()
    assert (recs["profile_id"], recs["career"]) == (None, "Analyst")
    assert [r["code"] for r in recs["recommendations"]] == ["IS230"]


def test_nothing_is_stored(client, tmp_path):
    assert client.post("/gap", json={"career": "Analyst",
                                     "completed_courses": ["IS230"]}).status_code == 200
    assert client.post("/recommendations", json={"career": "Developer"}).status_code == 200
    assert stored_rows(tmp_path) == 0


def test_unknown_values_are_refused_by_name(client):
    r = client.post("/gap", json={"career": "Astronaut"})
    assert r.status_code == 422 and r.json()["detail"]["career"] == "Astronaut"
    r = client.post("/gap", json={"career": "Analyst", "completed_courses": ["XX999"]})
    assert r.status_code == 422 and r.json()["detail"]["unknown"] == ["XX999"]
    r = client.post("/recommendations", json={"career": "Analyst", "self_reported_skills": ["ZZ"]})
    assert r.status_code == 422 and r.json()["detail"]["unknown"] == ["ZZ"]


def test_percentages_round_halves_up_like_the_app():
    from backend.main import percent
    # 0.125 is exact in binary, so this is a true half: Python's round() gives 12.
    assert (percent(0.125), percent(0.135), percent(0.5), percent(1 / 3)) == (13, 14, 50, 33)


def test_a_half_that_float_arithmetic_leaves_just_short_still_rounds_up():
    from backend.main import percent  # first: it puts skillgap/ on the path
    import skillgap as sg
    # Readiness as the engine computes it, for a career of 11 postings whose three
    # skills are named by 6, 7 and 3 of them, the first covered: 6/16 is exactly
    # 37.5%, but the float division lands on 0.37499999999999994.
    profile = sg.CareerProfile("X", 11, {"A": 6 / 11, "B": 7 / 11, "C": 3 / 11})
    share = sg.analyze_gap(profile, {"A"}).readiness
    assert share < 0.375
    assert percent(share) == 38
    # And a figure genuinely below a half still rounds down.
    assert percent(0.3749) == 37


def test_a_request_cannot_carry_an_unbounded_list(client):
    from backend.schemas import MAX_IDS
    many = [f"XX{i}" for i in range(MAX_IDS + 1)]
    for path in ("/gap", "/recommendations"):
        for field in ("completed_courses", "self_reported_skills"):
            assert client.post(path, json={"career": "Analyst", field: many}).status_code == 422
    r = client.post("/profiles", json={"career": "Analyst", "major": "x" * 10_000})
    assert r.status_code == 422


def test_a_request_cannot_carry_an_unbounded_id(client):
    # Each id is named back in a 422 when it is unknown, so each is capped too.
    from backend.schemas import MAX_TEXT
    long = "X" * (MAX_TEXT + 1)
    for body in ({"career": long},
                 {"career": "Analyst", "completed_courses": [long]},
                 {"career": "Analyst", "self_reported_skills": [long]}):
        assert client.post("/gap", json=body).status_code == 422
    r = client.post("/profiles", json={"career": "Analyst", "other_careers": [long]})
    assert r.status_code == 422


def test_a_repeated_course_counts_once(client):
    once = client.post("/gap", json={"career": "Analyst", "completed_courses": ["IS230"]}).json()
    twice = client.post("/gap", json={"career": "Analyst",
                                      "completed_courses": ["IS230", "IS230"]}).json()
    assert once == twice

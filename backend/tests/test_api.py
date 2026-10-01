"""API behaviour against the four-skill fixture world in world.py."""
import json

import pytest

from backend.engine import build_state, sg
from backend.tests.world import make_config, write_world


def gap(client, career, courses) -> dict:
    r = client.post("/gap", json={"career": career, "completed_courses": courses})
    assert r.status_code == 200, r.text
    return r.json()


def recommendations(client, career, courses, **params):
    return client.post("/recommendations", params=params,
                       json={"career": career, "completed_courses": courses})


# ---- the failed gate travels with the data ---------------------------------

def test_health_carries_the_failed_gate(client):
    body = client.get("/health").json()
    assert body["status"] == "ok"
    assert (body["taxonomy_skills"], body["careers"], body["courses"]) == (4, 2, 4)
    assert (body["online_courses"], body["online_placeholders"]) == (0, 0)
    v = body["validation"]
    assert v["gate_passed"] is False
    assert (v["best_f1"], v["gate_min_f1"]) == (0.503, 0.6)
    assert v["course_mapping_validated"] is False
    assert "did not pass" in v["note"]


def test_every_readiness_figure_is_qualified(client):
    assert gap(client, "Analyst", ["IS230"])["validation"]["gate_passed"] is False
    recs = recommendations(client, "Analyst", ["IS230"]).json()
    assert recs["validation"]["gate_passed"] is False


# ---- catalogue ---------------------------------------------------------------

def test_careers_list_posting_counts(client):
    assert client.get("/careers").json() == [
        {"name": "Analyst", "posting_count": 2},
        {"name": "Developer", "posting_count": 2},
    ]


def test_courses_parse_titles_and_map_skills(client):
    got = {c["code"]: c for c in client.get("/courses").json()}
    assert set(got) == {"IS230", "BUS210", "IS210", "IS320"}
    assert got["IS230"]["name"] == "Database Design"
    assert all(c["skill_count"] == 1 for c in got.values())


# ---- the profile sent with a request ---------------------------------------------

def test_unknown_career_is_rejected(client):
    r = client.post("/gap", json={"career": "Astronaut", "completed_courses": []})
    assert r.status_code == 422
    assert r.json()["detail"]["known"] == ["Analyst", "Developer"]


def test_unknown_course_is_named(client):
    r = client.post("/gap", json={"career": "Analyst",
                                  "completed_courses": ["IS230", "XX999"]})
    assert r.status_code == 422
    assert r.json()["detail"]["unknown"] == ["XX999"]


def test_the_service_stores_no_profiles(client):
    # The profile lives on the device and comes with each request.
    assert client.post("/profiles", json={"career": "Analyst"}).status_code in (404, 405)
    assert client.get("/profiles/x/gap").status_code == 404


# ---- gap analysis ----------------------------------------------------------------

def test_readiness_is_demand_weighted(client):
    # Analyst: SQL in 2/2 postings, communication in 1/2. IS230 teaches SQL only,
    # so readiness is 1.0 / (1.0 + 0.5) -- not 1 skill of 2.
    g = gap(client, "Analyst", ["IS230"])
    assert g["readiness"] == pytest.approx(2 / 3, abs=1e-4)
    assert g["readiness_percent"] == 67
    assert [s["id"] for s in g["covered"]] == ["SQ"]
    assert [(s["id"], s["demand_percent"]) for s in g["missing"]] == [("CM", 50)]


def test_missing_skills_ranked_by_demand(client):
    g = gap(client, "Developer", [])
    assert g["readiness"] == 0
    assert [(s["id"], s["demand_percent"]) for s in g["missing"]] == [
        ("PY", 100), ("SQ", 50)]


def test_skills_carry_both_languages(client):
    top = gap(client, "Developer", [])["missing"][0]
    assert (top["en"], top["ar"]) == ("python programming", "برمجة بايثون")


# ---- recommendations -------------------------------------------------------------

def test_recommendations_close_highest_value_gaps_first(client):
    body = recommendations(client, "Developer", []).json()
    recs = body["recommendations"]
    assert [(r["source"], r["code"], [s["id"] for s in r["closes"]]) for r in recs] == [
        ("university", "IS210", ["PY"]), ("university", "IS230", ["SQ"])]
    assert recs[0]["value"] > recs[1]["value"]
    assert recs[0]["closes"][0]["ar"] == "برمجة بايثون"
    assert body["uncovered"] == []


def test_recommendation_limit(client):
    recs = recommendations(client, "Developer", [], limit=1).json()
    assert [r["code"] for r in recs["recommendations"]] == ["IS210"]
    assert recommendations(client, "Developer", [], limit=0).status_code == 422


def test_completed_course_never_recommended(client):
    recs = recommendations(client, "Analyst", ["IS230"]).json()["recommendations"]
    assert [r["code"] for r in recs] == ["BUS210"]


# ---- spec items 6 and 12: nothing recomputed per request ---------------------------

def test_model_loads_once_not_per_request(client, embedder):
    for _ in range(5):
        gap(client, "Analyst", ["IS230"])
        recommendations(client, "Analyst", ["IS230"])
    assert embedder.instances == 1


def test_warm_restart_never_loads_the_model(world, embedder):
    first = build_state(world, embedder)
    second = build_state(world, embedder)
    assert (first.built_from_cache, second.built_from_cache) == (False, True)
    assert embedder.instances == 1
    assert second.profiles["Analyst"].demand == first.profiles["Analyst"].demand
    assert second.courses == first.courses


def test_changed_config_invalidates_the_cache(world, embedder):
    build_state(world, embedder)
    world.config.write_text(json.dumps(make_config(threshold=0.40)), encoding="utf-8")
    rebuilt = build_state(world, embedder)
    assert rebuilt.built_from_cache is False
    assert embedder.instances == 2


def test_changed_posting_text_invalidates_the_cache_and_relabelling_does_not(world, embedder):
    import csv

    def rewrite(change):
        with world.postings.open(encoding="utf-8-sig", newline="") as f:
            rows = list(csv.DictReader(f))
        change(rows[0])
        with world.postings.open("w", encoding="utf-8-sig", newline="") as f:
            w = csv.DictWriter(f, fieldnames=list(rows[0]))
            w.writeheader()
            w.writerows(rows)

    build_state(world, embedder)
    # A label is not something extraction reads.
    rewrite(lambda r: r.update(skill_ids="SQ"))
    assert build_state(world, embedder).built_from_cache is True
    rewrite(lambda r: r.update(posting_text=r["posting_text"] + " | Also Python."))
    assert build_state(world, embedder).built_from_cache is False


def test_changing_how_the_service_extracts_invalidates_the_cache(world, embedder, monkeypatch):
    from backend import engine
    first = build_state(world, embedder)
    original = engine._extract

    def extract_another_way(*args):     # other source, same result
        return original(*args)

    monkeypatch.setattr(engine, "_extract", extract_another_way)
    rebuilt = build_state(world, embedder)
    assert rebuilt.built_from_cache is False and rebuilt.cache_key != first.cache_key
    assert rebuilt.profiles == first.profiles and rebuilt.courses == first.courses


def test_stale_config_refuses_startup_before_loading_anything(tmp_path, embedder):
    paths = write_world(tmp_path / "stale", make_config(taxonomy_skills=19))
    with pytest.raises(sg.StaleConfigError):
        build_state(paths, embedder)
    assert embedder.instances == 0

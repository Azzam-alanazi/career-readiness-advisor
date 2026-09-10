"""Engine behaviour the API depends on (spec: pytest for the engine)."""
import pytest

from backend.engine import sg
from backend.tests.world import make_config, write_world


def test_loader_exposes_the_failed_gate(world):
    p = sg.load_match_params("postings", str(world.config), str(world.taxonomy))
    assert p["gate_passed"] is False
    assert p["best_f1"] == 0.503
    assert p["validated"] is True


def test_config_without_gate_field_reads_as_passed(tmp_path):
    # Only passing runs wrote config.json before the field existed.
    cfg = make_config()
    del cfg["gate_passed"]
    paths = write_world(tmp_path / "old", cfg)
    p = sg.load_match_params("postings", str(paths.config), str(paths.taxonomy))
    assert p["gate_passed"] is True


def test_stale_config_is_refused(tmp_path):
    paths = write_world(tmp_path / "stale", make_config(taxonomy_skills=5))
    with pytest.raises(sg.StaleConfigError):
        sg.load_match_params("postings", str(paths.config), str(paths.taxonomy))


def test_readiness_weights_by_demand_and_drops_rare_skills():
    profile = sg.CareerProfile(career="X", posting_count=10,
                               demand={"a": 0.9, "b": 0.1, "c": 0.5})
    g = sg.analyze_gap(profile, acquired={"c"})
    # b sits under the default min_demand of 0.15 and is ignored entirely.
    assert g.readiness == pytest.approx(0.5 / 1.4)
    assert [s for s, _ in g.missing] == ["a"]
    assert [s for s, _ in g.covered] == ["c"]


def test_recommend_ranks_by_demand_closed():
    profile = sg.CareerProfile(career="X", posting_count=4,
                               demand={"a": 1.0, "b": 0.5})
    g = sg.analyze_gap(profile, acquired=set())
    names = type("Names", (), {"name": lambda self, s: s})()
    recs = sg.recommend(g, {"C1": ["b"], "C2": ["a", "b"], "C3": ["z"]}, names)
    assert [r["course"] for r in recs] == ["C2", "C1"]     # C3 closes nothing
    assert recs[0]["value"] == pytest.approx(1.5)

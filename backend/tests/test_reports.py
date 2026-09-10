"""Reports over the fixture world. The real-data output is recorded in the CHANGELOG."""
from types import SimpleNamespace

import pytest

from backend.engine import build_state
from backend.reports import (SWEEP, check_matches_api, course_reach, explain_courses,
                             min_postings, sweep_min_demand, unseen_outcomes)
from backend.tests.world import make_config, write_world


@pytest.mark.parametrize("min_demand, postings, expected", [
    (0.15, 6, 1),   # 1/6 = 0.167 clears it: the current default admits one posting
    (0.20, 6, 2),
    (0.20, 5, 1),   # 1/5 is exactly 0.20, and >= admits it
    (0.35, 6, 3),
    (0.50, 6, 3),   # 3/6 is exactly 0.50
    (0.45, 5, 3),
    (1.01, 5, 6),   # nothing can clear it
])
def test_min_postings_is_the_posting_count_min_demand_implies(min_demand, postings, expected):
    assert min_postings(min_demand, postings) == expected


def test_sweep_follows_analyze_gap(world, embedder):
    state = build_state(world, embedder)
    # Analyst: SQL in 2/2 postings, communication in 1/2. BUS210 teaches communication.
    low, high = sweep_min_demand(state, "Analyst", ["BUS210"], [0.15, 0.6])
    assert (low.counted, low.covered, low.missing, low.closable) == (2, ["CM"], 1, 1)
    assert low.readiness == pytest.approx(0.5 / 1.5)
    assert low.ceiling == pytest.approx(1.0)
    # Communication drops below 0.6 and takes the student's only coverage with it.
    assert (high.counted, high.covered, high.missing) == (1, [], 1)
    assert high.readiness == 0.0
    assert high.ceiling == pytest.approx(1.0)


def test_sweep_row_at_the_default_is_what_the_api_serves(world, embedder):
    check_matches_api(build_state(world, embedder), "Analyst", ["BUS210"])


def test_unseen_outcomes_finds_values_the_table_skips():
    state = SimpleNamespace(profiles={"X": SimpleNamespace(posting_count=6)})
    # 0.10 needs 1 posting and 0.50 needs 3; every value needing 2 is unshown.
    unseen = unseen_outcomes(state, [0.10, 0.50])
    assert (unseen[0], unseen[-1]) == (0.167, 0.333)
    assert unseen_outcomes(state, SWEEP) == []


def test_course_reach_lists_courses_and_demand(world, embedder):
    reach = {r.skill: r for r in course_reach(build_state(world, embedder))}
    assert list(reach) == ["SQ", "CM", "PY", "ER"]        # taxonomy order
    assert reach["SQ"].courses == ["IS230"]
    assert reach["SQ"].demand == {"Analyst": (2, 2), "Developer": (1, 2)}
    assert reach["ER"].demand == {} and reach["ER"].most_postings() == 0


def test_explain_reproduces_the_served_course_map(tmp_path, embedder):
    config = make_config()
    for domain in ("postings", "courses"):
        config[domain]["match_method"] = "chunk_top1"
    paths = write_world(tmp_path / "w", config)
    state = build_state(paths, embedder)
    # explain_courses raises if its account disagrees with the served map, so
    # getting a result at all is half the test.
    explained = dict(explain_courses(state, paths=paths, embedder_factory=embedder))
    title, body = explained["IS230"]
    # The title shares no word with any label, so it cannot vote.
    assert (title.chunk, title.voted, title.reason) == ("Database Design.", False,
                                                        "below threshold 0.45")
    assert (body.top, body.voted) == ("SQ", True)


def test_explain_refuses_a_matcher_it_does_not_describe(world, embedder):
    with pytest.raises(SystemExit):
        explain_courses(build_state(world, embedder), paths=world, embedder_factory=embedder)

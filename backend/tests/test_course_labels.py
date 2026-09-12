"""Hand labels are the served course mapping wherever they exist."""
import pytest

from backend.engine import CourseLabelsError, build_state
from backend.tests.world import COURSES, write_world


def labelled(code: str, labels: str) -> list[tuple[str, ...]]:
    """The fixture catalog with one course hand-labelled."""
    return [(*c, labels) if c[0] == code else c for c in COURSES]


def test_labels_replace_extraction_for_the_courses_they_cover(tmp_path, embedder):
    # Extraction reads communication from BUS210's text; the label says SQL.
    state = build_state(write_world(tmp_path / "w", courses=labelled("BUS210", "SQ")),
                        embedder)
    assert (state.courses["BUS210"].skills, state.courses["BUS210"].mapped_by) == (
        ("SQ",), "labels")
    # Extraction still runs on a labelled course, so it can be measured.
    assert state.extracted["BUS210"] == ("CM",)
    assert (state.courses["IS230"].skills, state.courses["IS230"].mapped_by) == (
        ("SQ",), "extraction")


def test_none_labels_a_course_with_no_skills(tmp_path, embedder):
    state = build_state(write_world(tmp_path / "w", courses=labelled("IS320", "NONE")),
                        embedder)
    assert (state.courses["IS320"].skills, state.courses["IS320"].mapped_by) == ((), "labels")


def test_relabelling_needs_a_restart_not_a_rebuild(tmp_path, embedder):
    paths = write_world(tmp_path / "w")
    assert build_state(paths, embedder).courses["IS320"].mapped_by == "extraction"
    write_world(tmp_path / "w", courses=labelled("IS320", "NONE"))
    again = build_state(paths, embedder)
    assert again.built_from_cache and again.courses["IS320"].mapped_by == "labels"
    assert embedder.instances == 1


def test_an_unknown_label_refuses_startup_before_the_model_loads(tmp_path, embedder):
    paths = write_world(tmp_path / "w", courses=labelled("IS320", "ER;XX"))
    with pytest.raises(CourseLabelsError, match=r"IS320.*'XX'"):
        build_state(paths, embedder)
    assert embedder.instances == 0


def test_mapping_counts_as_checked_only_when_every_course_is_labelled(make_client, tmp_path):
    every = [(*c, label) for c, label in zip(COURSES, ["SQ", "CM", "PY", "ER"])]
    with make_client(paths=write_world(tmp_path / "all", courses=every)) as c:
        assert c.get("/health").json()["validation"]["course_mapping_validated"] is True
        assert {x["mapped_by"] for x in c.get("/courses").json()} == {"labels"}

    with make_client(paths=write_world(tmp_path / "one", courses=labelled("IS230", "SQ"))) as c:
        v = c.get("/health").json()["validation"]
        courses = {x["code"]: x["mapped_by"] for x in c.get("/courses").json()}
    assert v["course_mapping_validated"] is False
    assert "3 of 4 courses are mapped to skills by extraction" in v["note"]
    assert courses["IS230"] == "labels" and courses["IS320"] == "extraction"

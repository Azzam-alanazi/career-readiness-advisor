"""validate.py: how it reads hand labels, and what a run writes."""
import csv
import json
import sys

from backend.engine import ENGINE_DIR  # noqa: F401  (puts skillgap/ on sys.path)
from backend.tests.world import COURSES, POSTINGS, SKILLS, FakeEmbedder

import validate  # noqa: E402  skillgap/validate.py

COURSE_HEADER = ["id", "course_code", "lang", "course_text", "skill_ids"]


def _write(path, header, rows):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8-sig") as f:
        w = csv.writer(f)
        w.writerow(header)
        w.writerows(rows)


def test_none_labels_a_course_with_no_skills_and_blank_stays_pending(tmp_path):
    path = tmp_path / "courses.csv"
    _write(path, COURSE_HEADER, [
        ["1", "MKT 301", "en", "Digital Marketing. Campaign planning.", "NONE"],
        ["2", "IS 210", "en", "Programming Fundamentals. Python.", "SK24;SK25"],
        ["3", "IS 201", "en", "Introduction to Information Systems.", ""],
    ])
    rows, pending = validate.load_labeled(str(path), {"SK24", "SK25"})
    assert rows == [("Digital Marketing. Campaign planning.", set()),
                    ("Programming Fundamentals. Python.", {"SK24", "SK25"})]
    assert pending == 1, "a blank cell still means not labelled yet"


def test_a_failed_gate_still_writes_config_marked_failed(tmp_path, monkeypatch):
    # Phase 0 closed on a failed gate, so every real run fails it. Refusing to
    # write after a taxonomy change left config.json stale and the app unable to
    # start, so the failure is recorded in the data instead.
    root = tmp_path / "skillgap"
    root.mkdir()
    (root / "taxonomy.json").write_text(
        json.dumps({"skills": SKILLS}, ensure_ascii=False), encoding="utf-8")
    # Every text labelled with the ERP skill, which only one course mentions,
    # so F1 stays well under the 0.60 floor in both domains.
    _write(tmp_path / "test" / "labeled_postings.csv",
           ["id", "career", "posting_text", "skill_ids"],
           [[pid, career, text, "ER"] for pid, career, text in POSTINGS])
    _write(root / "labeled_courses.csv", COURSE_HEADER,
           [[i, code, "en", text, "ER"] for i, (code, text) in enumerate(COURSES, 1)])
    monkeypatch.chdir(root)
    monkeypatch.setattr(validate, "Embedder", FakeEmbedder)
    monkeypatch.setattr(sys, "argv", ["validate.py"])          # no flag

    validate.main()

    cfg = json.loads((root / "config.json").read_text(encoding="utf-8"))
    assert cfg["gate_passed"] is False
    assert cfg["gate_best_f1"] < validate.MIN_F1
    assert cfg["taxonomy_skills"] == len(SKILLS)
    assert cfg["postings"]["validated"] and cfg["courses"]["validated"]


def test_threshold_keeps_enough_decimals_to_stay_on_its_plateau():
    # The course measurement of 2026-09-11. Rounded to four decimals, 0.8146
    # fell below a plateau 0.0000157 wide and let one more chunk vote.
    narrow = {"threshold": 0.814647912979126,
              "plateau": (0.8146400451660156, 0.8146557807922363)}
    wide = {"threshold": 0.81395, "plateau": (0.8130, 0.8149)}
    assert validate.threshold_decimals(narrow) == 5
    assert round(narrow["threshold"], 5) == 0.81465
    assert validate.threshold_decimals(wide) == 4


def test_a_text_with_no_chunks_is_reported_and_still_counted():
    # Shaqra titles "E-business" and "Data Mining" are too short to form a
    # chunk, and once crashed the sweep's spread report.
    import numpy as np
    import pytest
    ids = ["A", "B"]
    scored = [(np.array([[0.9, 0.2]], dtype=np.float32), {"A"}),
              (np.zeros((0, 2), dtype=np.float32), {"B"})]
    spread = validate.report_spread(scored, ids)
    assert (spread["pos_mean"], spread["neg_mean"]) == (pytest.approx(0.9), pytest.approx(0.2))
    tp, fp, fn = validate.prf(lambda s, i: validate.predict_skill_centric(s, i, 0.5),
                              scored, ids)[:3]
    assert (tp, fp, fn) == (1, 0, 1), "the unchunked text's label is a miss"

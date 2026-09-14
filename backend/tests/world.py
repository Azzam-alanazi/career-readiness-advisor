"""
A four-skill world and a stand-in embedder, shared by the test modules.

The suite never loads the real 1 GB model. FakeEmbedder maps text to a
bag-of-words vector: texts sharing words are similar, unrelated texts are
orthogonal. That is enough to drive every code path deterministically, offline,
in seconds -- and its arithmetic is simple enough to check by hand, which the
expected values in test_api.py rely on.
"""
import csv
import json
import re
from pathlib import Path

import numpy as np

from backend.engine import Paths
from backend.online import COLUMNS as ONLINE_COLUMNS


class FakeEmbedder:
    """Counts its own construction, so tests can prove the model loads once."""
    instances = 0
    DIM = 4096

    def __init__(self, model_name: str) -> None:
        type(self).instances += 1
        self.model_name = model_name
        # Per-instance vocabulary rather than hashing: no collisions, so no
        # spurious similarity between unrelated words. Labels and chunks go
        # through the same instance, so their slots agree.
        self._vocab: dict[str, int] = {}

    def encode(self, texts: list[str]) -> np.ndarray:
        out = np.zeros((len(texts), self.DIM), dtype=np.float32)
        for i, text in enumerate(texts):
            for word in re.findall(r"\w+", text.lower()):
                out[i, self._vocab.setdefault(word, len(self._vocab))] += 1.0
        norms = np.linalg.norm(out, axis=1, keepdims=True)
        norms[norms == 0] = 1.0
        return out / norms


SKILLS = [
    {"id": "SQ", "en": "SQL databases", "ar": "قواعد البيانات", "category": "data"},
    {"id": "CM", "en": "communication presentation", "ar": "مهارات التواصل",
     "category": "professional"},
    {"id": "PY", "en": "python programming", "ar": "برمجة بايثون",
     "category": "software_development"},
    {"id": "ER", "en": "erp systems", "ar": "أنظمة تخطيط الموارد", "category": "erp"},
]

# Demand this produces at a 0.45 threshold:
#   Analyst   -- SQL in 2/2 postings, communication in 1/2
#   Developer -- python in 2/2 postings, SQL in 1/2
POSTINGS = [
    ("1", "Analyst", "Write SQL queries against databases daily. "
                     "Strong communication and presentation required."),
    ("2", "Analyst", "Maintain SQL databases for reporting."),
    ("3", "Developer", "Build python programming tools for automation."),
    ("4", "Developer", "Python programming and SQL databases experience."),
]

# Each teaches exactly one skill.
COURSES = [
    ("IS230", "Database Design. Relational SQL databases and normalization."),
    ("BUS210", "Business Communication. Professional communication and "
               "presentation delivery."),
    ("IS210", "Programming Fundamentals. Python programming for beginners."),
    ("IS320", "Enterprise Systems. ERP systems configuration and rollout."),
]


def make_config(taxonomy_skills: int = 4, threshold: float = 0.45,
                gate_passed: bool = False) -> dict:
    section = {"match_method": "skill_centric", "match_threshold": threshold,
               "match_margin": 0.0}
    return {
        "model": "fake-embedder",
        "validated_on": "2026-09-10",
        "taxonomy_skills": taxonomy_skills,
        "synonym_probes_passed": "0/0",
        "gate_passed": gate_passed,
        "gate_min_f1": 0.6,
        "gate_best_f1": 0.503,
        "postings": {**section, "validated": True, "best_f1": 0.503},
        "courses": {**section, "validated": False, "inherited_from": "postings",
                    "best_f1": None},
    }


def write_world(root: Path, config: dict | None = None,
                courses: list[tuple[str, ...]] | None = None,
                online: list[tuple[str, ...]] | None = None,
                postings: list[tuple[str, str, str]] | None = None) -> Paths:
    """
    Write the fixture world. `courses` replaces the catalog, as (code, text),
    (code, text, labels) or (code, text, labels, track); `online` writes an
    online_courses.csv with those rows.
    Without it the world has no such file, so no test ever reads the real one.
    `postings` replaces the postings, as (id, career, text).
    """
    root.mkdir(parents=True, exist_ok=True)
    (root / "taxonomy.json").write_text(
        json.dumps({"skills": SKILLS}, ensure_ascii=False), encoding="utf-8")
    (root / "config.json").write_text(
        json.dumps(config or make_config()), encoding="utf-8")
    with (root / "postings.csv").open("w", newline="", encoding="utf-8-sig") as f:
        w = csv.writer(f)
        w.writerow(["id", "career", "posting_text", "skill_ids"])
        for pid, career, text in POSTINGS if postings is None else postings:
            w.writerow([pid, career, text, ""])
    with (root / "courses.csv").open("w", newline="", encoding="utf-8-sig") as f:
        w = csv.writer(f)
        w.writerow(["id", "course_code", "lang", "course_text", "skill_ids", "track"])
        for i, (code, text, *extra) in enumerate(COURSES if courses is None else courses, 1):
            labels = extra[0] if extra else ""
            track = extra[1] if len(extra) > 1 else ""
            w.writerow([i, code, "en", text, labels, track])
    if online is not None:
        with (root / "online_courses.csv").open("w", newline="", encoding="utf-8-sig") as f:
            w = csv.writer(f)
            w.writerow(ONLINE_COLUMNS)
            w.writerows(online)
    return Paths(taxonomy=root / "taxonomy.json", config=root / "config.json",
                 postings=root / "postings.csv", courses=root / "courses.csv",
                 online_courses=root / "online_courses.csv",
                 cache_dir=root / "cache")

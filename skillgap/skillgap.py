"""
Skill-gap engine: embedding-based extraction and analysis.

Pipeline:
  job description text -> split into chunks -> embed each chunk
  -> cosine similarity against embedded skill taxonomy
  -> skills above threshold are "required by this posting"

Because the embedding model is multilingual, an Arabic chunk can match an
English skill label and vice versa. No translation step needed.
"""

import json
import re
from collections import Counter
from dataclasses import dataclass, field

import numpy as np


# --------------------------------------------------------------------------
# Configuration
# --------------------------------------------------------------------------

CONFIG_PATH = "config.json"


# Job postings and course descriptions are different kinds of text -- postings
# list one requirement per bullet, catalog entries pack several skills into one
# sentence -- so each gets its own validated parameters rather than sharing one
# number that was only ever measured on postings.
DOMAINS = ("postings", "courses")


def load_match_params(domain: str = "postings", path: str = CONFIG_PATH) -> dict:
    """
    Read the validated matching configuration for one text domain.

    Returns method, threshold, margin, and whether that domain was actually
    measured. `validated` False means the parameters were inherited from
    another domain because no labeled data existed yet -- usable, but the
    caller should say so rather than present the output as measured.

    There is deliberately no fallback default. The old hardcoded 0.80 scored
    precision 0.20 on the labeled set, so a caller that cannot state validated
    parameters should fail rather than quietly produce noise.
    """
    if domain not in DOMAINS:
        raise ValueError(f"unknown domain {domain!r}; expected one of {DOMAINS}")
    try:
        with open(path, encoding="utf-8") as f:
            cfg = json.load(f)
    except FileNotFoundError:
        raise FileNotFoundError(
            f"{path} not found. Run validate.py first -- it sweeps the matching "
            "parameters against the labeled sets and writes the winners here."
        ) from None

    section = cfg.get(domain)
    if section is None:
        raise KeyError(
            f"{path} has no '{domain}' section. Re-run validate.py; if it "
            f"skipped that domain, its labeled CSV has no labeled rows yet.")
    return {
        "method": section["match_method"],
        "threshold": float(section["match_threshold"]),
        "margin": float(section.get("match_margin", 0.0)),
        "validated": bool(section.get("validated", False)),
    }


def save_config(payload: dict, path: str = CONFIG_PATH) -> None:
    """Write the validated configuration. Called by validate.py, not the engine."""
    with open(path, "w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2, ensure_ascii=False)
        f.write("\n")


# --------------------------------------------------------------------------
# Text preparation
# --------------------------------------------------------------------------

def split_chunks(text: str, min_len: int = 15) -> list[str]:
    """
    Split a job description into short units (bullets, sentences).

    This matters: embedding a whole 500-word posting produces one diluted
    vector that matches nothing well. Chunking keeps each vector focused on
    a single requirement.
    """
    parts = re.split(r"[\n\r]+|(?<=[.!?؟])\s+|[•\-\u2022]\s*", text)
    return [p.strip() for p in parts if len(p.strip()) >= min_len]


# --------------------------------------------------------------------------
# Embedding backend
# --------------------------------------------------------------------------

# E5 models are trained with an instruction prefix on every input; without one
# the vectors sit off-distribution. The model card specifies "query: " on both
# sides for symmetric similarity -- comparing a text chunk to a skill label is
# symmetric -- and reserves "query: "/"passage: " for asymmetric retrieval.
# Measured on the labeled set: query/query F1 0.84, no prefix 0.80,
# query/passage 0.75. See CHANGELOG.md for the full three-config sweep.
E5_PREFIX = "query: "


class Embedder:
    """
    Wraps a multilingual sentence-transformer model.

    Skill labels and text chunks both go through the same prefix, which is what
    the symmetric setup calls for. Pass prefix="" to reproduce the unprefixed
    baseline.
    """

    def __init__(self, model_name: str = "intfloat/multilingual-e5-base",
                 prefix: str = E5_PREFIX):
        from sentence_transformers import SentenceTransformer
        self.model = SentenceTransformer(model_name)
        self.prefix = prefix

    def encode(self, texts: list[str]) -> np.ndarray:
        vecs = self.model.encode([self.prefix + t for t in texts],
                                 normalize_embeddings=True)
        return np.asarray(vecs, dtype=np.float32)


def cosine_matrix(a: np.ndarray, b: np.ndarray) -> np.ndarray:
    """Pairwise cosine similarity. Assumes both are L2-normalized."""
    return a @ b.T


# --------------------------------------------------------------------------
# Taxonomy
# --------------------------------------------------------------------------

@dataclass
class Skill:
    id: str
    en: str
    ar: str
    category: str


class Taxonomy:
    def __init__(self, path: str, embedder):
        with open(path, encoding="utf-8") as f:
            raw = json.load(f)["skills"]
        self.skills = [Skill(**s) for s in raw]
        self.embedder = embedder

        # Embed both language labels per skill; a chunk matching either counts.
        labels, owner = [], []
        for i, s in enumerate(self.skills):
            labels += [s.en, s.ar]
            owner += [i, i]
        self._label_vecs = embedder.encode(labels)
        self._owner = np.array(owner)

    def match(self, chunks: list[str], threshold: float) -> dict[str, float]:
        """
        Return {skill_id: best_similarity} for skills present in the chunks.

        Threshold is the main tuning knob and is required: too low and every
        posting appears to need every skill, too high and real matches get
        dropped. Get the value from load_threshold(), which reads what
        validate.py measured against the hand-labeled set.
        """
        if not chunks:
            return {}
        chunk_vecs = self.embedder.encode(chunks)
        sims = cosine_matrix(chunk_vecs, self._label_vecs)  # (chunks, labels)

        best: dict[str, float] = {}
        for label_idx in range(sims.shape[1]):
            score = float(sims[:, label_idx].max())
            if score >= threshold:
                skill = self.skills[self._owner[label_idx]]
                if score > best.get(skill.id, 0.0):
                    best[skill.id] = score
        return best

    def skill_scores(self, chunks: list[str]) -> np.ndarray:
        """
        (n_chunks, n_skills) similarity matrix, max-pooled over each skill's
        language labels so an Arabic and an English label for the same skill
        compete as one entry rather than against each other.

        Both matchers below are views over this one matrix. Exposed separately
        so validate.py can encode once and then sweep parameters for free.
        """
        if not chunks:
            return np.zeros((0, len(self.skills)), dtype=np.float32)
        sims = cosine_matrix(self.embedder.encode(chunks), self._label_vecs)
        out = np.empty((sims.shape[0], len(self.skills)), dtype=np.float32)
        for i in range(len(self.skills)):
            out[:, i] = sims[:, self._owner == i].max(axis=1)
        return out

    def match_chunk_top1(self, chunks: list[str], threshold: float,
                         margin: float) -> dict[str, float]:
        """
        Chunk-centric alternative to match(). Each chunk votes for at most one
        skill: its top-1, and only if that skill beats the runner-up by at
        least `margin`.

        The difference that matters: match() asks "does any chunk look like
        this skill?" and answers independently per skill, so one broad chunk
        can trip several skills at once. This asks "what is this chunk about?"
        and forces the skills to compete, so an ambiguous chunk that is not
        clearly about anything votes for nothing.

        margin=0.0 is still not the same as match(): it keeps the top-1 rule.
        Which method wins is an empirical question -- see validate.py.
        """
        scores = self.skill_scores(chunks)
        best: dict[str, float] = {}
        for row in scores:
            order = np.argsort(-row)
            top, second = int(order[0]), int(order[1])
            gap = float(row[top]) - float(row[second])
            if float(row[top]) >= threshold and gap >= margin:
                sid = self.skills[top].id
                if float(row[top]) > best.get(sid, 0.0):
                    best[sid] = float(row[top])
        return best

    def match_auto(self, chunks: list[str], params: dict) -> dict[str, float]:
        """
        Dispatch to whichever matcher validate.py selected.

        Both methods stay available and directly callable; this only routes to
        the one that won on the labeled data. Take params from
        load_match_params().
        """
        method = params["method"]
        if method == "skill_centric":
            return self.match(chunks, params["threshold"])
        if method == "chunk_top1":
            return self.match_chunk_top1(chunks, params["threshold"],
                                         params["margin"])
        raise ValueError(
            f"unknown match method {method!r} in config.json; expected "
            f"'skill_centric' or 'chunk_top1'")

    def name(self, skill_id: str) -> str:
        for s in self.skills:
            if s.id == skill_id:
                return s.en
        return skill_id


# --------------------------------------------------------------------------
# Career profile: what the market actually demands
# --------------------------------------------------------------------------

@dataclass
class CareerProfile:
    career: str
    posting_count: int
    demand: dict[str, float] = field(default_factory=dict)  # skill_id -> 0..1

    def top(self, n: int = 10) -> list[tuple[str, float]]:
        return sorted(self.demand.items(), key=lambda kv: -kv[1])[:n]


def build_career_profile(career: str, postings: list[str], tax: Taxonomy,
                         params: dict) -> CareerProfile:
    """
    Aggregate skills across postings for one career.

    Demand weight = fraction of postings mentioning the skill. A skill in 90%
    of postings matters far more than one in 10%, and this is what makes the
    final recommendations ranked rather than an unordered checklist.
    """
    counts = Counter()
    for text in postings:
        found = tax.match_auto(split_chunks(text), params)
        counts.update(found.keys())

    n = max(len(postings), 1)
    demand = {sid: c / n for sid, c in counts.items()}
    return CareerProfile(career=career, posting_count=len(postings), demand=demand)


# --------------------------------------------------------------------------
# Student side
# --------------------------------------------------------------------------

def skills_from_courses(course_descriptions: list[str], tax: Taxonomy,
                        params: dict) -> set[str]:
    """Same extraction, applied to course catalog text instead of job text."""
    acquired = set()
    for desc in course_descriptions:
        acquired |= set(tax.match_auto(split_chunks(desc), params).keys())
    return acquired


@dataclass
class GapResult:
    career: str
    readiness: float                  # 0..1, demand-weighted coverage
    covered: list[tuple[str, float]]
    missing: list[tuple[str, float]]


def analyze_gap(profile: CareerProfile, acquired: set[str],
                min_demand: float = 0.15) -> GapResult:
    """
    Compare what the market wants against what the student has.

    Readiness is demand-weighted, not a raw count: missing a skill that 90% of
    postings ask for hurts far more than missing a niche one.
    """
    relevant = {s: w for s, w in profile.demand.items() if w >= min_demand}
    total = sum(relevant.values()) or 1.0

    covered = [(s, w) for s, w in relevant.items() if s in acquired]
    missing = [(s, w) for s, w in relevant.items() if s not in acquired]

    readiness = sum(w for _, w in covered) / total
    return GapResult(
        career=profile.career,
        readiness=readiness,
        covered=sorted(covered, key=lambda kv: -kv[1]),
        missing=sorted(missing, key=lambda kv: -kv[1]),
    )


# --------------------------------------------------------------------------
# Recommendations
# --------------------------------------------------------------------------

def recommend(gap: GapResult, catalog: dict[str, list[str]], tax: Taxonomy,
              limit: int = 5) -> list[dict]:
    """
    Map missing skills back to courses that teach them.

    catalog: {course_name: [skill_id, ...]}  (built once via skills_from_courses)
    Courses are ranked by the total market demand of the gaps they close.
    """
    missing = dict(gap.missing)
    scored = []
    for course, taught in catalog.items():
        closes = [s for s in taught if s in missing]
        if closes:
            scored.append({
                "course": course,
                "closes": [tax.name(s) for s in closes],
                "value": round(sum(missing[s] for s in closes), 3),
            })
    scored.sort(key=lambda r: -r["value"])
    return scored[:limit]

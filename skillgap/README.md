# Skill-Gap Engine — Embedding-Based Matching

ML core of the career-readiness system: extracts skills from job postings and
course descriptions, then computes a demand-weighted gap.

## Run

Dependencies live in a virtualenv at `C:\Users\azzam\.venvs\skillgap`, which is
**outside this repo on purpose** — torch alone is ~2.5 GB and this project sits
in a OneDrive-synced folder. Activate it first, every new terminal:

```bash
C:\Users\azzam\.venvs\skillgap\Scripts\activate.bat
```

```bash
python validate.py    # DO THIS FIRST — writes config.json
python demo.py
```

Without activating, bare `python` is the Windows Store interpreter, which has
none of these packages and fails with `ModuleNotFoundError: No module named
'sentence_transformers'`. To call it without activating, use the full path:
`C:\Users\azzam\.venvs\skillgap\Scripts\python.exe validate.py`.

To rebuild the environment from scratch:

```bash
python -m venv C:\Users\azzam\.venvs\skillgap && C:\Users\azzam\.venvs\skillgap\Scripts\python.exe -m pip install -r requirements.txt
```

First run downloads the model (~1GB), then works offline on CPU.

`validate.py` compares both matching methods against two labeled sets —
`labeled_postings.csv` and `labeled_courses.csv` — and writes the winning
method, threshold, and margin **per domain** to `config.json`. The engine has no
defaults, so `demo.py` will not run until that file exists. If best F1 comes in
under 0.60, `validate.py` writes nothing and exits non-zero — the gate enforces
itself.

## Test status — read this

**Plumbing: verified.** Chunking, demand aggregation, gap math, and ranking all
run correctly end to end.

**Semantic matching: verified** as of 2026-09-01, with the real model. The
numbers previously in this section came from a GloVe word-averaging fallback,
not from `multilingual-e5-base`. Both are shown here because the contrast is the
point:

| check | GloVe fallback | multilingual-e5-base |
|---|---|---|
| precision at best | 0.31 – 0.38 | 1.00 |
| best F1 | not reached | **0.90** |
| "network intrusion and threats" | ranked HR ops **above** cybersecurity | cybersecurity first; HR ops does not place |
| "spreadsheets and pivot tables" | never surfaced Excel | Excel first |
| aggregated demand | every skill came out at 100% | spreads 33–67% across postings |
| synonym probes | — | 5/5 pass |

Mean-centering the GloVe vectors widened their spread (0.47 → 0.59) but rankings
stayed wrong, so that was never a calibration problem. Averaging word vectors
destroys phrase meaning.

**Caveat on the current numbers.** They rest on 3 labeled postings and 11
ground-truth labels — expand to 20–30 before quoting them anywhere.

`validate.py` compares two matching methods and picks the winner on F1, then on
how wide the winning threshold plateau is. Width is not a tiebreaker nicety: on
a small labeled set the top F1 is often a spike a couple of thousandths wide
that exists because one posting's score happens to land there. Chunk-centric
matching currently wins on postings — same F1 as skill-centric, over a plateau
70× wider. See `CHANGELOG.md` for both sweeps.

**The lesson worth putting in your report:** the embedding model is not a config
detail, it is the project. Word-averaging (GloVe, word2vec, fastText) will not
work. You need a sentence transformer trained with a contrastive objective,
because that is what spreads similarities across a usable range.

## How it works

```
job posting text
  → split into chunks (bullets, sentences)
  → embed each chunk
  → cosine similarity against embedded skill taxonomy
  → chunks above threshold → skills required by that posting

across N postings → demand weight per skill (fraction of postings)
same extraction on course descriptions → skills the student acquired
difference, weighted by demand → the gap
gap mapped back to courses → ranked recommendations
```

## Four decisions to defend

**1. Chunking before embedding.** Embedding a whole 500-word posting gives one
diluted vector that matches nothing. Splitting into bullets keeps each vector
focused on one requirement.

**2. Multilingual model, no translation step.** `multilingual-e5-base` puts
Arabic and English in one shared vector space, so an Arabic posting matches an
English skill label directly. A translation stage would add error for no gain.

**3. Demand weighting, not counting.** A skill in 90% of postings matters more
than one in 10%. Readiness is the demand-weighted fraction the student holds.

**4. Embeddings over a trained classifier.** A custom NER model needs 500–1000
hand-labeled postings. Embeddings need none, generalize to skills you never
wrote rules for, and the similarity score is inspectable when a match is wrong.

## Tuning

`validate.py` sweeps the threshold and reports precision/recall/F1 against the
hand-labeled set in `labeled_postings.csv`. Three postings ship in it — add rows
until you have 20–30 before trusting the output. One posting per row; put the
skill ids in `skill_ids` separated by `;`. Unknown ids are a hard error, so a
typo cannot silently become a false negative.

Two labeled sets are swept, not one. Job postings and course catalog entries
are different kinds of text — posting bullets carry one requirement each, while
catalog sentences pack several skills into one clause — so each gets its own
validated parameters. If the two disagree, `validate.py` reports the
disagreement and keeps both; it does not average them into a compromise that
fits neither. A domain with no labels yet inherits the other's parameters,
marked `"validated": false` with its scores left `null`.

Within each domain, two matching methods are swept:

- **skill-centric** (`Taxonomy.match`) — a skill fires if *any* chunk clears the
  threshold. Each skill is judged independently, so one broad chunk can trip
  several at once.
- **chunk-centric** (`Taxonomy.match_chunk_top1`) — each chunk votes for its
  top-1 skill only, and only if that skill beats the runner-up by a margin.
  Skills compete, so an ambiguous chunk votes for nothing.

Both stay callable. The sweep picks between them on F1, then on how wide the
winning threshold plateau is, and writes the result to `config.json` —
`match_method`, `match_threshold`, `match_margin`, under a `postings` or
`courses` key. That file is the only place the engine reads matching parameters
from, via `load_match_params(domain)`. There are no defaults: the old hardcoded
0.80 scored precision 0.20, which is exactly the kind of thing that should never
happen quietly.

Threshold search is exact, not grid-based. Matching is `score >= threshold`, so
F1 is a step function whose breakpoints are the observed scores; the sweep
evaluates at those and at the midpoints between them. The printed table is a
readable display grid, not the search space.

## Known limitations

- Starter taxonomy has 19 skills. Real coverage needs ESCO or O*NET as the
  backbone (verify licensing and Arabic coverage yourself).
- Course-to-skill mapping is only as good as the course descriptions.
  `labeled_courses.csv` now measures it, but only once you fill it in — until
  then course extraction runs on parameters inherited from postings.
- `accounting` and `financial_reporting` are adjacent by design after the split
  and score within ~0.01 of each other on finance text. Fine for skill-centric
  matching, but chunk-centric may drop such chunks on the margin rule.
- No technical-writing skill exists. "Write a technical report documenting the
  findings" lands on `problem_solving`; `communication` is labelled for
  presentation, not written documentation.
- Soft skills match loosely because they are phrased so many ways. Consider a
  higher threshold for that category, not a lower one.

## Files

| File | Purpose |
|---|---|
| `validate.py` | Threshold sweep and sanity checks — run first |
| `labeled_postings.csv` | Hand-labeled job postings — you fill this in |
| `labeled_courses.csv` | Hand-labeled course catalog entries — you fill this in |
| `config.json` | Generated by `validate.py`. The validated threshold plus its evidence. Do not hand-edit |
| `skillgap.py` | Engine: extraction, profiling, gap analysis, recommendations |
| `demo.py` | End-to-end example, mixed Arabic/English |
| `taxonomy.json` | Starter skill taxonomy, bilingual labels |
| `CHANGELOG.md` | What changed when, and the measurements behind each decision |

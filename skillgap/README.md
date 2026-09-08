# Skill-Gap Engine — Embedding-Based Matching

ML core of the career-readiness system: extracts skills from job postings and
course descriptions, then computes a demand-weighted gap.

## Current state — read this first

**The engine will not run right now, on purpose.** `config.json` records
parameters swept against the 19-entry starter taxonomy; `taxonomy.json` now has
90 entries. `load_match_params()` raises `StaleConfigError` rather than applying
them.

That guard exists because the silent version was worse. Before it, `demo.py` ran
to completion against the 90-entry taxonomy and reported **0% readiness with two
skills detected** — no crash, no warning. The cause is measurable: a denser
taxonomy packs neighbouring skills closer together, so the median gap between a
chunk's top-1 and top-2 skill halves, and a margin tuned on 19 skills discards
almost everything on 90.

| taxonomy | chunks clearing threshold | also clearing `margin=0.03` | median top1−top2 gap |
|---|---|---|---|
| 19-entry | 218 / 301 | 66 | 0.0145 |
| 90-entry | 234 / 301 | **30** | 0.0075 |

Clearing it needs a sweep against the current taxonomy, which needs labels. The
labels are the blocker, not the code.

## Where things stand in Phase 0

| | |
|---|---|
| Validation gate | **not yet closed** — the recorded F1 0.900 was measured on 3 postings / 11 labels against the old 19-entry taxonomy |
| Taxonomy | 90 entries, `SK01`–`SK90`, English + Arabic, 8 categories |
| Postings collected | 27, five careers, no duplicates, **5 hand-labelled** |
| Postings excluded | 19, each with a recorded reason |
| Courses | 16 catalog entries, **0 labelled** |
| Next step | label `../test/manual_batch2.csv` (10 postings, two per career), merge, then re-sweep |

The 0.900 was measured against the 19-entry taxonomy on the three rows now in
`archive/labeled_postings_starter19.csv`. It does not describe the current
system, and it is the only F1 the project has.

The gate closes at **15 hand-labelled postings** — lowered from 20–30 because
AI-assisted labelling was measured against hand annotation and rejected
(Jaccard 0.61), so every label is hand-written. 5 are done, 10 are drawn and
waiting in `../test/manual_batch2.csv`.

## Run

Dependencies live in a virtualenv at `C:\Users\azzam\.venvs\skillgap`, which is
**outside this repo on purpose** — torch alone is ~2.5 GB and this project sits
in a OneDrive-synced folder. Activate it first, every new terminal:

```bash
C:\Users\azzam\.venvs\skillgap\Scripts\activate.bat
```

```bash
python validate.py    # sweeps parameters, writes config.json
python demo.py        # end-to-end example
```

Without activating, bare `python` is the Windows Store interpreter, which has
none of these packages and fails with `ModuleNotFoundError: No module named
'sentence_transformers'`.

To rebuild the environment:

```bash
python -m venv C:\Users\azzam\.venvs\skillgap && C:\Users\azzam\.venvs\skillgap\Scripts\python.exe -m pip install -r requirements.txt
```

`requirements.txt` pins every version the recorded results were produced with.
First run downloads the model (~1GB), then works offline on CPU.

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
English skill label directly. **Unvalidated on the market side:** the collected
sample is 27 English postings and 0 Arabic. The evidence for this decision is
the taxonomy's Arabic labels plus one Arabic posting in the archived starter
set — not real Arabic market data.

**3. Demand weighting, not counting.** A skill in 90% of postings matters more
than one in 10%. Readiness is the demand-weighted fraction the student holds.

**4. Embeddings over a trained classifier.** A custom NER model needs 500–1000
hand-labeled postings. Embeddings need none, generalize to skills you never
wrote rules for, and the similarity score is inspectable when a match is wrong.

## The model matters more than any parameter

Numbers previously in this section came from a GloVe word-averaging fallback,
not from `multilingual-e5-base`. The contrast is the point:

| check | GloVe fallback | multilingual-e5-base (19-entry taxonomy) |
|---|---|---|
| precision at best | 0.31 – 0.38 | 1.00 |
| best F1 | not reached | 0.90 |
| "network intrusion and threats" | ranked HR ops **above** cybersecurity | cybersecurity first |
| "spreadsheets and pivot tables" | never surfaced Excel | Excel first |
| synonym probes | — | 5/5 pass |

Mean-centering the GloVe vectors widened their spread (0.47 → 0.59) but rankings
stayed wrong, so that was never a calibration problem. Averaging word vectors
destroys phrase meaning. **The lesson for the report:** the embedding model is
not a config detail, it is the project. You need a sentence transformer trained
with a contrastive objective.

E5 also needs its instruction prefix. Measured on the labeled set: `"query: "`
on both sides F1 0.84, no prefix 0.80, `"query: "`/`"passage: "` 0.75. The
symmetric form won, which is what the model card specifies for similarity.

## Tuning

Two labeled sets are swept, not one — postings and course catalog entries are
different kinds of text, so each gets its own parameters. If they disagree,
`validate.py` reports the disagreement and keeps both. A domain with no labels
inherits the other's parameters, marked `"validated": false` with scores `null`.

Within each domain, two matching methods:

- **skill-centric** (`Taxonomy.match`) — a skill fires if *any* chunk clears the
  threshold. Skills are judged independently, so one broad chunk can trip several.
- **chunk-centric** (`Taxonomy.match_chunk_top1`) — each chunk votes for its
  top-1 skill only, and only if it beats the runner-up by a margin. Skills
  compete, so an ambiguous chunk votes for nothing.

Both stay callable. The sweep picks on F1, then on how wide the winning
threshold plateau is. Width is not a tiebreaker nicety: on a small labeled set
the top F1 is often a spike a couple of thousandths wide that exists because one
posting's score lands there.

Threshold search is exact, not grid-based. Matching is `score >= threshold`, so
F1 is a step function whose breakpoints are the observed scores; the sweep
evaluates at those and at the midpoints between them. The printed table is a
readable display grid, not the search space.

Results land in `config.json` — `match_method`, `match_threshold`,
`match_margin`, under a `postings` or `courses` key — read via
`load_match_params(domain)`. There are no defaults: the old hardcoded 0.80
scored precision 0.20.

## Labelling

Put `SK`-codes in the labels column, separated by `;` — e.g. `SK01;SK17;SK85`.
`TAXONOMY_REFERENCE.md` lists all 90 grouped by category. Unknown ids are a hard
error, so a typo cannot silently become a false negative.

`validate.py` accepts labels in `skill_ids`, `taxonomy_skill_ids` or `labels`,
preferring whichever column actually has values.

## Known limitations

- **Every recorded F1 rests on 3 postings and 11 labels**, against the previous
  taxonomy. The gate now closes at 15 hand-labelled postings; 5 are done. Even at
  15, one label flipping moves F1 by roughly two points.
- **AI-assisted labelling was measured and rejected** as ground truth: Jaccard
  0.61 against hand annotation, with errors that track an upstream career
  mislabel rather than the advert text. See `CHANGELOG.md`. The AI labels in
  `../test/holdout/` are a comparison baseline, not truth.
- **No spreadsheet or Excel skill exists** in the 90-entry taxonomy, despite
  Excel appearing in Data Analyst postings. The old Excel synonym probe was
  dropped rather than repointed, because pointing it at "Data analysis" would
  turn a coverage gap into a passing test.
- **No technical-writing skill.** "Write a technical report documenting the
  findings" has nowhere correct to land.
- **Course extraction has never been measured.** `labeled_courses.csv` exists to
  fix that; until it is filled in, course parameters are inherited from postings
  and marked unvalidated.
- **`SK01 Requirements analysis` and `SK02 Requirements elicitation`** — and
  several other near-synonym pairs — sit within ~0.01 of each other. That is the
  mechanism behind the margin collapse described at the top.
- **The sample is English-only.** This survived a corrected filter (see
  `CHANGELOG.md`), so it reflects the market on these boards rather than a
  collection artefact, but cross-lingual matching stays untested.
- **Unvalidated constants.** `split_chunks(min_len=15)` decides what becomes a
  chunk at all and was never justified anywhere; `analyze_gap(min_demand=0.15)`
  was flagged as a magic number and never swept.

## Files

| File | Purpose |
|---|---|
| `skillgap.py` | Engine: extraction, profiling, gap analysis, recommendations |
| `validate.py` | Parameter sweep and sanity checks |
| `demo.py` | End-to-end example |
| `taxonomy.json` | 90-entry skill taxonomy, bilingual — the live one |
| `real_skill_taxonomy_90.csv` | Source the taxonomy was built from |
| `TAXONOMY_REFERENCE.md` | Printable sheet, grouped by category, for labelling |
| `taxonomy_starter_19.json` | The 19-entry taxonomy every recorded F1 was measured against |
| `labeled_courses.csv` | Hand-labeled course entries — you fill this in |
| `config.json` | Generated by `validate.py`. Do not hand-edit |
| `CHANGELOG.md` | What changed when, and the measurements behind each decision |
| `archive/` | Superseded data kept for provenance |
| `../test/labeled_postings.csv` | The collected corpus — what `validate.py` reads |
| `../test/manual_validation.csv` | 5 postings drawn for hand-labelling |
| `../test/labeled_postings_excluded.csv` | Rejected postings, each with a reason |
| `../test/raw_responses/` | Cached API payloads — evidence for the sampling findings |

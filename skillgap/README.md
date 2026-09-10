# Skill-Gap Engine — Embedding-Based Matching

ML core of the career-readiness system: extracts skills from job postings and
course descriptions, then computes a demand-weighted gap.

## Current state — read this first

**Phase 0 is closed with the validation gate FAILED in both domains** —
postings F1 0.504 and courses F1 0.514, against a 0.60 floor. The engine runs,
but its output is best-measured, not validated. `config.json` records
`gate_passed: false`, `load_match_params()` returns it, and anything presenting
results must say so.

| | |
|---|---|
| Validation gate | **FAILED, closed** — postings F1 0.504 (precision 0.62, recall 0.43) on 15 hand-labelled postings, 199 labels; courses F1 0.514 (precision 0.63, recall 0.43) on 16 hand-labelled courses, 44 labels |
| Final parameters | postings `chunk_top1`, threshold 0.8140, margin 0.01, plateau 0.0018 wide; courses `chunk_top1`, threshold 0.81465, margin 0.00, plateau 0.000016 wide — both provisional |
| Separation | postings **0.021** (0.075 on the 19-entry taxonomy); courses 0.052 |
| Taxonomy | 91 entries, `SK01`–`SK91`, English + Arabic, 8 categories — `SK91` Java programming added 2026-09-11 |
| Postings | 27 collected, 15 hand-labelled; 19 excluded, each with a recorded reason |
| Courses | 16 catalog entries, all hand-labelled, 2 of them `NONE` |

**Why it failed: granularity.** A 90-entry taxonomy packs neighbouring skills
closer together than this model can separate. The median similarity of two
*unrelated* skills, 0.834, sits above the operating threshold, and 43 pairs
exceed 0.92. Twenty-five of those 43 are pairs the hand labels keep apart —
Frontend/Backend, Python/PHP, Linux/Windows — so human annotation distinguishes
what the model cannot. Merging only the pairs the labels never separate stops at
85 entries; the merge lever is exhausted. The full diagnosis is in
`CHANGELOG.md`.

`StaleConfigError` still guards the other failure mode: parameters swept
against one taxonomy are refused if a different one is loaded. Before that
guard, stale parameters produced **0% readiness with two skills detected** and
no error at all.

The earlier F1 0.900 was measured on 3 postings against the 19-entry taxonomy
(`archive/labeled_postings_starter19.csv`). It does not describe this system.

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
inherits parameters from the other, marked `"validated": false` with scores
`null`. Unlabelled courses inherit postings' best `skill_centric` result rather
than the overall winner, on the reasoning that `chunk_top1` starves a catalog
sentence naming several skills. Measured on 16 labelled courses, that did not
hold: `chunk_top1` won on course text, and the inherited `skill_centric`
threshold over-matched, scoring F1 0.228 against the labels where inheriting the
posting winner scored 0.475. The rule is dormant while courses are labelled.

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
`TAXONOMY_REFERENCE.md` lists all 91 grouped by category. Write `NONE` for a text
that involves none of them; a blank cell means "not labelled yet" and is skipped.
Unknown ids are a hard error, so a typo cannot silently become a false negative.

`validate.py` accepts labels in `skill_ids`, `taxonomy_skill_ids` or `labels`,
preferring whichever column actually has values.

## Known limitations

- **The matcher failed its gate in both domains.** Postings F1 0.504 on 15
  hand-labelled postings, courses F1 0.514 on 16 courses, against a 0.60 floor,
  with winning plateaus 0.0018 and 0.000016 wide. At these sizes one label
  flipping moves F1 by two points or more.
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
- **Course extraction rests on 16 labelled courses**, labelled by one person
  after the model's course mappings had been shown, so those labels are not
  blind the way the posting labels were. `chunk_top1` won on course text by
  under 0.02 F1 over `skill_centric`, on a plateau 0.000016 wide.
- **`SK01 Requirements analysis` and `SK02 Requirements elicitation`** — and
  several other near-synonym pairs — sit within ~0.01 of each other. Pairs like
  these are why separation fell to 0.021; the diagnosis is in `CHANGELOG.md`.
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
| `taxonomy.json` | 91-entry skill taxonomy, bilingual — the live one: the 90 built from `real_skill_taxonomy_90.csv`, plus `SK91` Java programming |
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

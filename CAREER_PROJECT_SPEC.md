# AI Career-Readiness Advisor — Spec

## What this is
A mobile app that compares a student's academic record against real job market
demand and produces a personalized skill-gap report with concrete
recommendations: which electives to take, which certifications to pursue, which
skills to self-study before graduating.

Solo Information Systems capstone, one semester. Prioritize a working vertical
slice over breadth. A polished demo for five careers beats a half-finished one
for fifty.

## Stack
- **Frontend:** Flutter (mobile-first, Android primary), Riverpod for state
- **Backend:** Python + FastAPI, wrapping the existing skill-gap engine
- **ML:** `sentence-transformers` with `intfloat/multilingual-e5-base`
- **Storage:** SQLite locally; Postgres only if it becomes necessary

## Existing code — do not rewrite
`skillgap/` already contains the ML engine. It works and its design decisions
are deliberate. Read it before touching it.

| File | Role |
|---|---|
| `skillgap.py` | Extraction, career profiling, gap analysis, recommendations |
| `taxonomy.json` | Skill taxonomy with English + Arabic labels |
| `validate.py` | Threshold sweep and sanity checks |
| `demo.py` | End-to-end usage example |

Four decisions in that engine that must not be quietly reversed:
1. **Chunk before embedding.** Embedding a whole posting produces one diluted
   vector that matches nothing. Do not "simplify" this away.
2. **No translation step.** The model is multilingual; Arabic text matches
   English skill labels directly. Still the design, and not reversed — but as
   of 2026-09-05 it is **unvalidated on the market side**: the collected
   posting sample is 25 English, 0 Arabic (see *Sampling: language* below).
   The claim is only evidenced on the taxonomy's Arabic labels and a single
   Arabic posting in the earlier hand-labeled set.
3. **Demand weighting, not counting.** Readiness is weighted by how often each
   skill appears across postings.
4. **Submissions of new skills go in the taxonomy**, not as hardcoded keywords.

## Phase 0 — validation gate (do this before anything else)

The embedding model is not a config detail; it is the project. A previous test
with word-averaging embeddings produced precision of 0.31 and ranked "HR
operations" above "cybersecurity" for a network-security phrase.

1. Run `validate.py` with `multilingual-e5-base`
2. Hand-label **15 postings** in `test/labeled_postings.csv`
3. Re-run the sweep; pick the threshold with best F1
4. **If best F1 < 0.6, stop.** Fix the model or taxonomy. Do not build on noise.

Record the precision/recall table. It goes in the evaluation chapter.

Nothing in Phase 1+ starts until this passes.

### Why 15 and not 20–30

The original 20–30 assumed labelling could be shared with a model. It cannot:
AI-assisted labelling was measured against hand annotation on five postings and
reached **Jaccard 0.61** (precision 0.77, recall 0.74) — close enough to look
usable, far enough off to be wrong in ways that matter. It is documented in
`skillgap/CHANGELOG.md` and rejected as ground truth. So every label is hand-written,
and the budget is a person's afternoon rather than a pipeline's throughput.

15 is what that budget buys at roughly 15–20 minutes per posting, and it is
three per career across the five target careers — enough that no career rests on
a single posting. It is chosen for reachability, and the cost is real and should
be stated in the evaluation chapter rather than buried: at 15 postings a single
label flipping still moves F1 by roughly two points, confidence intervals on any
reported figure are wide, and the sweep can overfit a threshold to this specific
sample. The plateau-width criterion in `validate.py` exists to blunt that, not to
remove it.

**15 is a floor, not a target.** Label more when there is time; the numbers only
get more trustworthy. What must not happen is closing the gate on fewer, or
topping up the set with machine labels to reach the count.

## Phase 1 — data
5. CSV ingestion for curated Saudi job postings (columns: career_category,
   job_title, company, location, source_site, posting_url, full_description)
6. Build career profiles from the postings; persist them so they aren't
   recomputed on every request
7. Target careers to start: Business Analyst, Data Analyst, ERP Consultant,
   IT Support Specialist, Software Developer

   Narrowed to roles an Information Systems graduate is actually hired into.
   The earlier list (Marketing Specialist, Accountant, HR Officer) spanned the
   whole business school and left taxonomy entries such as `erp` and
   `networking` with no career that would plausibly demand them.

No scraping. Postings are collected manually — that is a deliberate choice for
legal and reliability reasons, and it is defensible in the report.

### Sampling: language

**There is no language stratification requirement.** An earlier collection plan
targeted roughly a third Arabic, a third English, a third mixed. That target is
dropped, and the sample is taken as the market presents it.

Why: the collected set is **25 English, 0 Arabic**. Saudi IS and technology
vacancies on the aggregators reachable through the JSearch API — LinkedIn,
Indeed, BeBee, JobLeads, Naukrigulf, Jooble, GulfTalent, Bayt — are posted
overwhelmingly in English, including by Saudi employers hiring for Saudi
offices. Row 24 is a Riyadh university posting under an Arabic employer name
(جامعة دار العلوم) with an entirely English description. Holding a one-third
Arabic quota would mean either discarding real English postings to rebalance,
or sourcing Arabic ones from elsewhere and comparing across two different
collection processes. Both distort the demand weights, which are the actual
output of Phase 1.

**This finding survived a corrected filter, which is what makes it worth
stating.** The first collection screened on `job_country` alone, and that field
is null for a large share of this endpoint's results — so roughly half of every
result set was being discarded, non-randomly and by publisher. Those discarded
listings carried Arabic *location* strings ("الرياض • عبر GulfTalent"), which
made them the obvious place for Arabic postings to have been hiding. The filter
was fixed to fall back to `job_location`, which re-admitted **47 previously
rejected postings — every one of them in English**. Across all 98 cached
listings, not one description contains a single Arabic character. The
English-only result is a property of the market on these boards, not an
artefact of the filter.

This is a limitation to state in the evaluation chapter, not a defect to
engineer around: **cross-lingual matching is untested against real Arabic
postings**, and Arabic recall was already the weakest measured axis.

**This does not touch item 16 or the definition of done.** Bilingual UI with
working RTL is a localization requirement about the app's interface and is
unaffected by what language the market posts jobs in. A student reads the app in
Arabic regardless of which language the underlying posting was written in.

## Phase 2 — academic side
8. Course catalog ingestion (course code, name, description, credits)
9. Course-to-skill mapping via the same extraction path
10. Hand-correction interface for bad mappings — thin catalog descriptions
    produce thin mappings, and this needs a human in the loop

## Phase 3 — API
11. FastAPI service exposing: list careers, submit student profile, get gap
    analysis, get recommendations
12. Cache embeddings and career profiles at startup; do not reload the model
    per request

## Phase 4 — app
13. Onboarding: major, completed courses, target career
14. Readiness screen: score, covered skills, missing skills ranked by demand
15. Recommendations screen: courses and certifications that close the gaps
16. Arabic + English with working RTL (`flutter_localizations`)

## Conventions
- Feature-first: `lib/features/{onboarding,profile,gap,recommendations}/`
- Each feature: `data/`, `domain/`, `presentation/`
- Models via `freezed` + `json_serializable`
- No business logic in widgets
- Backend: type hints throughout, `pytest` for the engine

## Non-goals
- Live scraping of job boards
- Web or desktop builds
- Integration with university student records
- Training a custom NER model

## Definition of done for the demo
A student picks "Business Analyst," enters six completed courses, and gets a
readiness percentage, a ranked list of missing skills with the percentage of
postings requiring each, and three recommended courses that close the highest-
value gaps. Works in both Arabic and English.

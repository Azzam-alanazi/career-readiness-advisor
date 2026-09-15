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
   posting sample was 25 English, 0 Arabic, and since 2026-09-14 is 80
   English, 2 Arabic; neither Arabic posting is labelled (see *Sampling:
   language* below). The claim is only evidenced on the taxonomy's Arabic
   labels and a single Arabic posting in the earlier hand-labeled set.
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

Nothing in Phase 1+ starts until this passes. — *Superseded: the gate did not
pass, and Phase 0 was closed by decision. See the closure below.*

### Status: CLOSED — gate FAILED in both domains

**Phase 0 is closed and does not reopen.** This departs from step 4 knowingly:
fixing the taxonomy was attempted and the lever is exhausted, and the failure is
carried forward as data rather than hidden. It closed on 2026-09-10 with the
posting domain measured. On 2026-09-11 the course domain was measured as well,
against 16 hand-labelled catalog entries, and the closure stands on both.

**Result.** Both domains fall short of the 0.60 floor, on the 91-entry taxonomy.

| domain | hand-labelled | winner | threshold / margin | F1 | precision / recall | plateau |
|---|---|---|---|---|---|---|
| postings | 15 postings, 199 labels | `chunk_top1` | 0.8140 / 0.01 | **0.504** | 0.62 / 0.43 | 0.0018 wide |
| courses, placeholder catalog (2026-09-11) | 16 courses, 44 labels | `chunk_top1` | 0.81465 / 0.00 | 0.514 | 0.63 / 0.43 | 0.000016 wide |
| courses, Shaqra titles (2026-09-12) | 33 courses, 75 labels | `skill_centric` | 0.8940 | **0.373** | 0.70 / 0.25 | 0.0002 wide |

**Re-measured on the real catalog, 2026-09-12.** Once all 33 Shaqra courses were
hand-labelled, the course domain was measured again on their titles, the only
text there is. `skill_centric` won, 0.373 against `chunk_top1`'s 0.273, on a
plateau 0.0002 wide, so this winner is provisional too. It is now the lower
figure and the gate figure `config.json` records. It qualifies nothing the app
serves while every course is labelled, because the served course skills are the
labels themselves. The placeholder row is kept as history.

**Evaluation set versus product data.** F1 is measured on the 15 hand-labelled
postings, and on those only. Career profiles are built on every collected
posting: 27 at first, then 52, then **82 since 2026-09-14**, when three careers
were added. The 55 added that day are product data, unlabelled and outside
every F1 figure, and `validate.py` was not re-run for them. All 15 evaluation
postings come from the original five careers, so the matcher is unmeasured on
the three new ones. More postings change the demand weights, not the measured
quality of the matcher.

**Both winners are provisional.** The plateau is the range of thresholds that
holds the best F1; at 0.0018 and 0.000016 wide (0.0000 at four decimals), each
optimum is fitted to its own sample. The course threshold is stored to five
decimals because four put it below a plateau that narrow. On courses,
`chunk_top1` also beat `skill_centric` (F1 0.500) by less than 0.02, which at
this sample size is not a reliable margin. The posting
figure was 0.503 on the 90-entry taxonomy; adding SK91 Java programming moved it
to 0.504 by removing one false positive.

**Final configuration.** `skillgap/config.json` holds both domains' measured
parameters with `validated: true` and **`gate_passed: false`**. `validate.py` now
always writes it and records a failed gate in the data instead of refusing to
write: after a taxonomy change, a refused write leaves a config that
`StaleConfigError` rejects, and the app cannot start at all. The failure lives in
the data every consumer loads — `load_match_params()` returns `gate_passed`, and
the API returns it alongside every readiness figure — not only in this document.

**Finding — taxonomy granularity.** Moving from the 19-entry starter taxonomy to
90 entries collapsed separation, the margin by which the correct skill stands
above the rest, from **0.075 to 0.021** on postings. The median similarity
between two *unrelated* skills (0.834) now sits above the operating threshold
(0.814), and 43 pairs exceed 0.92. Course text separates better, at **0.052** on
the placeholder descriptions and 0.043 on bare Shaqra titles, and neither clears
the floor.

**Finding — the SQL probe fails.** Five of six synonym probes pass. "Experience
writing queries against relational databases" ranks SK16 Database management
first (0.85) and SK17 SQL second (0.84): two neighbouring skills 0.01 apart, the
confusion the granularity finding describes.

**Finding — human annotation distinguishes what the model cannot.** Of those 43
confusable pairs, **25 are separated by the hand labels**: the annotator applies
one without the other. Frontend/Backend development (0.966), Python/PHP (0.941)
and Linux/Windows administration (0.938) are all pairs the model cannot tell
apart and a person reading the advert can. Merging them would raise the metric
by deleting distinctions the ground truth actually contains. Merging only the
pairs the labels never separate stops at 85 entries; getting any lower requires
chaining through unused skills into groups such as Software testing + IT
security + Middleware. The merge lever is exhausted: simulated through the real
sweep, no merge policy scored above the unmerged taxonomy — including an upper
bound that merged every pair above 0.92 while ignoring the labels — and
separation fell as entries were merged.

**Downstream consequence.** Readiness figures are the engine's best measured
output, not validated output, and must be presented that way — in the
evaluation chapter and in the app.

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

   Extended on 2026-09-14 with Database Administrator, Cybersecurity Analyst
   and IT Project Manager. These are IS roles too, added as product data: 10
   postings each, none hand-labelled.

   Narrowed to roles an Information Systems graduate is actually hired into.
   The earlier list (Marketing Specialist, Accountant, HR Officer) spanned the
   whole business school and left taxonomy entries such as `erp` and
   `networking` with no career that would plausibly demand them.

No scraping. Postings are collected manually — that is a deliberate choice for
legal and reliability reasons, and it is defensible in the report.

### Status: 52 postings, 2026-09-14

**Profiles are built on 52 postings; F1 is measured on 15.** A second collection
added five postings per career, screened by the same rules as the first:
Business Analyst 11, Data Analyst 10, ERP Consultant 11, IT Support Specialist
10, Software Developer 10. The 15 hand-labelled postings remain the whole
evaluation set, three or four per career (two for Data Analyst). The new 25 are
unlabelled product data. At 10 or 11 postings per career, `min_demand` 0.15 now
takes two postings to count a skill as demanded, where 5 or 6 postings let a
single one do it. The before-and-after figures are in `skillgap/CHANGELOG.md`.

**82 postings, eight careers, later on 2026-09-14.** Three careers were added
with 10 postings each: Database Administrator, Cybersecurity Analyst and IT
Project Manager. None of them is labelled. The evaluation set is still the same
15 postings from the original five careers.

**`min_demand` is a share, so its meaning moved with the sample.** At 0.15 it
asked for 1 posting per career at 5 or 6 postings, and it asks for 2 at 10 or
11. It would ask for 3 at 20. Figures before and after 2026-09-14 therefore
count "demanded" differently. The curriculum view now states the threshold in
postings, and lists the skills it leaves out.

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

**Update, 2026-09-14.** The second collection brought the set to 52: 51 English,
1 Arabic. The Arabic one (id 55) is a Data Analyst advert from a Riyadh medical
group on Bayt.com. It is unlabelled, so it enters the Data Analyst profile
through a matcher never measured on a real Arabic posting. It confirms the
market finding, one Arabic posting in 52, rather than changing it. The three
careers added later that day brought a second, an IT Project Manager advert in
Al Khobar: 80 English and 2 Arabic across 82 postings.

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

### Status: the real catalog, 2026-09-12

Item 8: the catalog is the real Shaqra IS catalog, official codes and titles: 33
of its 48 courses, with the 15 left out recorded, each with its reason, in
`skillgap/labeled_courses_excluded.csv`. Descriptions are not available, so the
course text is the title alone. There is no `credits` column.

Item 9: a course's skills come from its hand labels where it has them, and from
extraction otherwise. Labels are ground truth, and extraction is what gets
measured against them. All 33 Shaqra courses are labelled (75 labels, 9 courses
marked `NONE`), so every served mapping is a label: 39 of 91 skills reached.
Extraction on the titles, measured against those labels, scores F1 0.373 at its
best (`skill_centric`, threshold 0.894). It would map only a course added
without labels.

Item 10: no correction interface yet. Labelling a course in
`labeled_courses.csv` is the correction for now: it replaces extraction for that
course on the next start.

## Phase 3 — API
11. FastAPI service exposing: list careers, submit student profile, get gap
    analysis, get recommendations
12. Cache embeddings and career profiles at startup; do not reload the model
    per request

### Status: BUILT 2026-09-10 — `backend/`

Items 11 and 12 are implemented, and with them Phase 1 item 6. Career profiles
and course-to-skill maps are built once and persisted under a key that hashes
every input, so they are never recomputed per request and a changed input can
never be served stale. What is cached is the result of embedding rather than the
vectors, because no request needs a vector; the model is used only to build
profiles, and a warm restart does not load it at all.

Every readiness figure the API returns carries the Phase 0 validation status,
`gate_passed: false`, so the app can show the failed gate beside the numbers it
qualifies.

Verified on real data with the definition-of-done scenario (Business Analyst,
six completed courses): readiness percentage, missing skills ranked with posting
shares, three recommendations, bilingual skill names; a warm restart takes 0.0 s
from cache and a request about 3 ms. **The mechanics meet the definition of
done; the numbers do not yet mean much.** Readiness came out at 5% for a student
who took Systems Analysis and Design, because course mapping yields only 0–2
skills per course — four courses map to none — and `min_demand=0.15` admits any
skill seen in one of six postings. Both are recorded in `skillgap/CHANGELOG.md`
as the next decisions.

## Phase 4 — app
13. Onboarding: major, completed courses, target career
14. Readiness screen: score, covered skills, missing skills ranked by demand
15. Recommendations screen: courses and certifications that close the gaps
16. Arabic + English with working RTL (`flutter_localizations`)

### Status: BUILT 2026-09-10 — `app/`

Items 13–16 are implemented against the Phase 3 backend: Riverpod state,
freezed models, feature-first under `lib/features/`. Both the readiness and the
suggestions screens show the Phase 0 quality flag in the student's language,
and suggested courses are presented as suggestions, not verdicts.

Item 16 is met as a **bilingual interface** — full Arabic UI with right-to-left
layout, and Arabic skill names from the taxonomy's hand-written labels. It is
not a demonstration of cross-lingual matching: no Arabic text is matched
anywhere in this flow, and every posting is English. Engine decision 2 remains
as untested as the Phase 0 closure records.

Item 15's certifications side arrived on 2026-09-12 as online courses. For a
missing skill no university course teaches, the suggestions screen offers an
online course from `skillgap/online_courses.csv`, marked as not counting toward
the degree; university courses are marked as counting. The file is hand-curated,
and its 53 rows started empty. It was filled in on 2026-09-13: 43 rows over 24
courses, one row for every skill some career counts as a gap that no university
course teaches. A sweep of every career through the API leaves no missing skill
without either a university or an online course.

Self-reported skills arrived on 2026-09-13 as an optional second onboarding
step, after course selection. Beside their completed courses, students can tick
taxonomy skills they hold from outside coursework: self-study, certifications,
work experience. The list is searchable, grouped by taxonomy category, and starts
with nothing ticked. Skills the chosen courses already teach are marked as such
and cannot be ticked. Acquired skills are the union of the two sources, and each
covered skill keeps its provenance. Where a course teaches a skill the student
also claims, the course gets the credit. The gap response gives readiness on both
sources and on the courses alone, and splits covered skills into
`covered_from_courses` and `covered_self_reported`. The readiness screen shows
them apart. Whenever the two figures differ, it gives the courses-only figure
beside the combined one, so a student defending the figure to an employer knows
which part the academic record supports. Self-reported skills are unverified. The
skills step says so once, and no other screen repeats it. They touch no mapping,
validation figure or cache. They are one student's word, and count only in that
student's readiness.

Multi-career comparison arrived on 2026-09-14. A student can choose up to three
target careers during onboarding. With two or three, the readiness screen shows
them side by side, each with its score, its covered and missing counts, and its
posting count. It marks the closest, but only when the scores differ as shown.
Tapping one switches the details and the suggestions to it. The profiles already
existed, so the backend only stores the extra careers and reads a profile against
any one of them. Each reading equals a profile targeting that career alone. A
note under the comparison says each score rests on a handful of postings, so a
few points apart is not a real difference.

Course selection was reworked on 2026-09-14, as presentation only:
- search by code or title, including Arabic-Indic digits
- "select all shown" on the filtered list
- the catalog's own tracks as collapsible sections with selected counts
- "this level and below" shortcuts
- a persistent selected count, with review and an undoable clear

The one backend change is that `/courses` now also returns each course's
catalog track, read from `labeled_courses.csv`. No course's skills changed.

**Profile persistence, 2026-09-15.** The student's profile — target careers,
completed courses, self-reported skills and major — and the language preference
are saved on the device with `shared_preferences`. The first launch shows
onboarding, and every later launch opens straight on the profile. Settings edits
the profile, switches language, and deletes the profile after asking.

**Local-only is deliberate.** Nothing about the student is stored on a server,
and there is no account, which is consistent with the non-goal of integrating
university student records. To keep it that way, the app no longer creates a
server-side profile. It sends the profile with each request to `POST /gap` and
`POST /recommendations`, which compute the figures and store nothing. The
stored-profile endpoints under `/profiles` stay in the API for scripted use; the
app does not call them. Accounts, and sync across devices, are future work.
Checking this found a small rounding bug. The API's percentages rounded halves
to even, so 12.5% read 12 while the app showed 13%. Halves now round up in both.

**What-if planning, 2026-09-15.** Alongside completed courses, a student can
mark courses as planned, on a planning screen reached from readiness.
- **The projection** is the same readiness calculation with completed and
  planned courses together. The backend is unchanged: the app sends both as
  taken. It stands beside today's figure — "31% now, 48% if you take your 3
  planned courses" — on the planning and readiness screens.
- **It is explainable.** Every course not yet taken lists the current gaps it
  would close, most in demand first, from the catalog's own course-to-skill
  mapping. The plan's total counts a gap once even when two courses close it.
  The contract check confirms the projection adds exactly those gaps.
- **Planned courses persist with the profile,** on the device. Marking one as
  completed takes it off the plan.

**Home dashboard, 2026-09-15.** Once a profile is saved, the student tab opens
on a home screen:
- readiness for the main career, with the plan's projection beside it when
  courses are planned
- the three most-demanded gaps
- the quality flag in short form, its headline and the failed gate; the full
  flag is on the readiness view
- entry points to planning, the full readiness view, and settings

Onboarding runs only while no profile is saved. The planning screen is reached
from home as well as from readiness.

Verified headlessly by 59 tests and `flutter analyze`, and by a contract check
that runs the definition-of-done scenario against the live backend through the
app's own models, then repeats it with self-reported skills. The Android
toolchain is now installed and a debug APK builds. These checks have not
launched the app on a device or an emulator.

## Department view — curriculum gaps
17. For one career or across all five: the skills postings demand that no
    course teaches, ranked by demand; the skills the curriculum teaches that no
    posting asks for; and coverage, the share of demanded skills taught
18. Computed from the served course mapping (the hand labels) and the career
    profiles already built from the 27 postings; no new data
19. A separate screen in the app's main navigation, not part of student
    onboarding: a different audience
20. The sample-size caveat on that screen: at n=27 postings the gaps are
    indicative and should not drive curriculum decisions on their own
21. Bilingual, with working RTL

### Status: BUILT 2026-09-13 — `GET /curriculum/gap`, `app/lib/features/curriculum/`

Items 17–21 are implemented. A skill counts as demanded exactly when a student's
gap would count it: at the engine's `min_demand` (0.15) in some career in scope.
With 5 or 6 postings per career, that meant any skill a single posting named. At
10 or 11 postings per career since 2026-09-14 it takes two, and a skill named by
one posting in every career is in neither of the view's main lists. Since
2026-09-14 the view lists such skills on their own and states the threshold in
postings, so nothing drops out of sight. Across
careers the postings are pooled, so a skill's weight is its share of all of them. Coverage counts skills, not
demand: each demanded skill counts once. For one career, the uncovered skills
are exactly what a student who took every catalog course would still be missing.

On the first 27 postings, the catalog taught 33 of the 76 skills they asked for:
43% coverage, from 37% (IT Support Specialist) to 50% (Data Analyst) by career.
The 43 uncovered skills are the same 43 that `online_courses.csv` fills. The most
demanded are CI/CD (10 of 27 postings), Communication (9), and Stakeholder
management, User acceptance testing and Quality assurance (7 each). Six taught
skills are named by no posting. Most are generic where the postings are
specific: Programming, Data modelling and Database management are taught, while
postings name particular languages and tools. Figures and the comparison with
the posting hand labels are in `skillgap/CHANGELOG.md`.

**Rebuilt on 52 postings, 2026-09-14.** The catalog teaches 32 of the 66 skills
the postings now ask for: 48% coverage, from 38% (IT Support Specialist) to 67%
(Data Analyst). Most of that rise is the threshold dropping skills named by a
single posting, not a change in the catalog. The 34 uncovered skills are led by
CI/CD (18 of 52 postings), then Communication and Stakeholder management (14
each). Two taught skills are named by no posting: Network administration and
Java programming. F1 behind these figures is still the 0.504 measured on 15
postings.

**Eight careers, 82 postings, 2026-09-14.** Across eight careers, the catalog
teaches 33 of the 75 skills the postings ask for: 44% coverage. The new careers
read Database Administrator 50%, Cybersecurity Analyst 44% and IT Project
Manager 40%. 14 skills are named by some posting but by fewer than the 2 a
career needs. The coverage card now states that threshold, and a section lists
those 14 skills with the courses that teach them. They used to be dropped
without a word.

The app reaches the view from a bottom navigation bar, beside the student flow
and never inside it. Each tab keeps its own navigation stack, so opening the
department view never interrupts a half-finished onboarding. The screen opens
with the sample-size caveat, using the real posting counts in the reader's
language, in the same card style as the student-facing quality flag. The quality
flag follows, because the demand side is extraction from a matcher that failed
its gate. Verified by 80 backend tests, 33 app tests, and the contract check
against the live backend.

## Conventions
- Feature-first: `lib/features/{onboarding,profile,gap,recommendations,curriculum}/`
- Each feature: `data/`, `domain/`, `presentation/`
- Models via `freezed` + `json_serializable`
- No business logic in widgets
- Backend: type hints throughout, `pytest` for the engine

## Non-goals
- Live scraping of job boards
- Web or desktop builds
- Integration with university student records
- Accounts, sync, or any server-side copy of a student's profile: the profile
  stays on the device (see Phase 4). Accounts are future work
- Training a custom NER model

## Definition of done for the demo
A student picks "Business Analyst," enters six completed courses, and gets a
readiness percentage, a ranked list of missing skills with the percentage of
postings requiring each, and three recommended courses that close the highest-
value gaps. Works in both Arabic and English.

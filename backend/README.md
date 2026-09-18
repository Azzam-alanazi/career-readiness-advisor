# Backend — skill-gap API (Phase 3)

FastAPI service over the engine in `../skillgap/`. It loads the model, embeds the
taxonomy, and builds every career profile and course map once at startup.
Requests only read the results.

## Status — read this first

The matcher behind every figure this API returns **failed its Phase 0
validation gate**: best F1 0.504 against a 0.60 floor. The API runs anyway, by
decision, and says so in the data. `/health`, every gap response and every
recommendation response carry a `validation` block with `gate_passed: false`
and a plain-language note. Show it to users next to the numbers it qualifies.

F1 is measured on the 15 hand-labelled postings. The career profiles the API
serves are built on every collected posting: 82 across eight careers since
2026-09-14, 10 or 11 per career. The three careers added then have no labelled
posting at all. The extra postings change demand, not the measured quality of the
matcher.

Every course in the catalog, the real Shaqra IS catalog, is hand-labelled. The
skills the API credits for a course are its labels, so the block's
`course_mapping_validated` is true. Course extraction, measured against those
labels on the course titles, falls short too, at F1 0.373: the lower of the two
figures and the gate figure in `config.json`. `best_f1` in the block stays the
posting figure, 0.504, because extraction maps no served course while every
course is labelled. A course added without labels would be mapped by extraction,
and 0.373 is the figure that would qualify it.

## Run

From the repo root, with the project virtualenv active:

```bash
python -m pip install -r backend/requirements.txt
```

```bash
C:/Users/azzam/.venvs/skillgap/Scripts/python.exe -m uvicorn backend.main:app --port 8000
```

To reach it from a phone on the same network rather than the emulator, add
`--host 0.0.0.0`. That exposes it to the whole network, so only on one you
trust.

The first start builds career profiles and course maps with the real model and
caches them in `backend/.cache/`. Later starts with unchanged inputs read the
cache and never load the model. Interactive docs: http://127.0.0.1:8000/docs

## Endpoints

| method | path | returns |
|---|---|---|
| GET | `/health` | model, counts, online courses filled in and still waiting, cache status, validation |
| GET | `/careers` | careers with their posting counts |
| GET | `/courses` | catalog: code, official title, the skill ids it teaches and how many, whether they come from hand labels or extraction, and the catalog `track` (college, core, an elective track) for grouping on screen |
| GET | `/skills` | the taxonomy, in its order: id, English and Arabic names, category. These are the skills a student can self-report |
| POST | `/gap` | the gap for a profile sent in the body — `career`, `completed_courses`, `self_reported_skills` — in the same shape as `/profiles/{id}/gap`, with `profile_id` null. Stores nothing. This is what the app calls |
| POST | `/recommendations` | suggestions for a profile sent in the body, in the same shape as `/profiles/{id}/recommendations`. Stores nothing. Optional `limit` |
| POST | `/profiles` | kept for scripted use, not called by the app: create a stored student profile: `career`, `completed_courses` (codes), optional `major`, optional `self_reported_skills` (taxonomy ids), optional `other_careers` (up to two more, to compare side by side). The response lists all of them as `careers`, first first |
| GET | `/profiles/{id}` | the stored profile |
| GET | `/profiles/{id}/gap` | for `career`, one of the profile's (its first when omitted): readiness % from all acquired skills and `readiness_from_courses` from the courses alone; covered skills, each with its `source`, also split into `covered_from_courses` and `covered_self_reported`; missing skills ranked by demand |
| GET | `/profiles/{id}/recommendations` | for every missing skill, a university course if the catalog teaches it, otherwise an online course, each marked by `source`; skills with neither listed as `uncovered`. Optional `career` as for the gap; optional `limit` caps each list |
| GET | `/curriculum/gap` | the department's view, for one `career` or all when omitted: demanded skills no course teaches, ranked by their share of postings, with the careers asking; taught skills no posting names, with their courses; skills named by too few postings to count (`below_threshold`), with their courses; coverage (taught / demanded) for the scope and for every career, with the postings a skill needs there (`min_postings`); `sample_note` on how few postings this rests on |

Unknown careers, course codes and skill ids are rejected with a 422 naming the
offending value, and so is a `career` the profile does not name. A request may
carry at most 200 course codes and 200 skill ids, and no id, `career` or `major`
longer than 200 characters. Skill entries carry both `en` and `ar`. Course names are English only,
because the catalog is.

## Design decisions

- **Hand labels first.** A course's skills come from its labels in
  `labeled_courses.csv` wherever it has them; extraction maps only the
  unlabelled courses, and still runs on every course so it can be measured
  against the labels. An unknown skill id in a label stops startup. Labels are
  read on every start, so relabelling needs a restart, not a rebuild.
- **Nothing is embedded per request.** Students pick courses from the catalog,
  so the model is needed only to build profiles, never to answer a request
  (spec item 12).
- **Profiles persist, keyed by their inputs** (spec item 6). The cache key hashes
  the taxonomy, config, posting text, course text, model name and engine source,
  and the source of the service's own extraction step (`_extract`), so other
  serving code in `engine.py` can change without a rebuild, and that step cannot.
  Relabelling a posting does not invalidate it; changing anything extraction reads
  does. A stale profile cannot be served.
- **Startup refuses a stale config.** A `StaleConfigError` from the engine stops
  the service, rather than letting it apply parameters measured against a
  different taxonomy.
- **Chunking matches `validate.py`.** Extraction runs on the stored posting text,
  `" | "` separators included, because that is the text the parameters were
  measured on.
- **Self-reported skills stay apart from the academic record.** A profile may
  list taxonomy skills the student holds from outside coursework. They join the
  course skills for readiness. Every covered skill carries its `source`, either
  `courses` or `self_reported`, and a course outranks a claim for the same skill.
  `readiness_from_courses` keeps the academic-record figure visible beside the
  combined one. Self-reported skills are unverified, so they reach nothing else:
  no mapping, validation figure or cache key. A stored skill that later leaves
  the taxonomy is ignored rather than failing the profile.
- **The student's profile lives on the device.** The app keeps it locally and
  sends it with each request to `POST /gap` and `POST /recommendations`, which
  validate it exactly as `POST /profiles` does, compute the same figures, and
  store nothing. No student data accumulates on the server, and there is no
  account. The `/profiles` endpoints remain for scripted clients.
- **Several careers, one record.** A profile names up to three careers: `career`
  and up to two `other_careers`. The gap and suggestions for any of them come
  from the same courses and self-reported skills, computed exactly as for a
  profile targeting that career alone. Nothing new is computed to compare them:
  the client asks for each career's gap. A stored career that later leaves the
  posting corpus is dropped, as a dropped course is; when it was the first, the
  next one still served takes its place. Only a profile left with no career is
  refused (409).
- **The curriculum view reuses the student view's numbers.** It reads the served
  course mapping (the hand labels) and the career profiles, nothing new. A skill
  is demanded exactly when a student's gap would count it, at the engine's
  `min_demand`, so a career's uncovered skills are what a student with every
  course would still miss. Across careers the postings are pooled. Coverage
  counts skills, not demand. `sample_note` and the `validation` block travel with
  it: 82 postings, 10 or 11 per career, is too few for these gaps to drive a
  curriculum decision on
  their own.
- **SQLite with a TRUNCATE journal.** The repo sits in OneDrive, which can refuse
  the journal deletes SQLite's default mode relies on. A profiles table from
  before self-reported skills or compared careers gains those columns in place
  on the next start.
- **Engine defaults pass through untouched.** `analyze_gap`'s `min_demand=0.15`
  has never been validated. The API uses it as-is rather than burying a second
  unvalidated number in the service layer. It is a share of a career's postings,
  so its meaning in postings moves with the sample: 1 posting at 5 or 6 per
  career, 2 at 10 or 11. The curriculum view reports that number
  (`min_postings`) and lists the skills it leaves out (`below_threshold`).

## Tests

```bash
python -m pytest
```

110 tests, offline, a few seconds. A stand-in bag-of-words embedder replaces
the 1 GB model, over a four-skill fixture world small enough that every expected
value can be checked by hand.

Covered: the failed gate reaching every response; demand-weighted readiness and
ranking; bilingual names; rejection of unknown careers, courses and profiles;
profiles surviving a restart; the model loading once and never per request; a
warm restart skipping the model entirely; cache invalidation on a config change;
startup refusing a stale config or a bad online-courses file before any model
work; hand labels overriding extraction, and relabelling without a rebuild;
online courses offered only where no university course teaches the skill;
self-reported skills stored deduplicated, validated, counted in readiness but
reported apart, with a course outranking a claim for the same skill; an old
profiles table migrated in place; the stateless endpoints reading exactly as a
stored profile does and storing nothing; up to three careers per profile, each read
exactly as a profile targeting it alone, and a career the profile does not name
refused; the curriculum view reading the labels, pooling
postings across careers, ranking by demand, and agreeing with what a student
with every course still misses, and listing the skills too few postings name
rather than dropping them; percentages rounding a half up even when float
arithmetic leaves it a hair short; request size caps; a stored profile whose
first career left the corpus read against the next; `sync` on an empty
online-courses file writing the header the loader needs; an empty posting corpus
answered, not a server error; and the reports below.

## Online courses

For a missing skill no catalog course teaches, the recommendations fall back to
an online course from `../skillgap/online_courses.csv`, hand-curated, one row per
skill and course:

```
skill_id,provider,course_title,url,is_free
```

A row with only its `skill_id` is a placeholder still waiting for a course. Every
other row is checked at startup. An unknown skill id, a partly filled row, a web
address that is not http(s), or an `is_free` that is not yes or no stops the
service, listing each problem with its line number: the same refusal the label
loader makes. Nothing about online courses is embedded, so a change needs a
restart, not a cache rebuild.

```bash
python -m backend.online status
```

```bash
python -m backend.online sync
```

`status` shows how many gap skills have an online course filled in. `sync`
matches the placeholder rows to the current gap skills, for after the catalog,
the labels or the postings change: it adds a row for each new gap skill and
drops placeholders for skills that stopped being gaps. A row with a course
filled in is never touched.

## Reports

Read-only. They change nothing the API serves.

```bash
python -m backend.reports min-demand
```

```bash
python -m backend.reports course-reach --explain
```

- `min-demand` sweeps `min_demand` from 0.10 to 0.50 for the definition-of-done
  scenario: readiness, skills counted, covered and missing, and readiness had
  every catalog course been taken, plus the posting count each value implies
  per career. It checks that its row at the engine default is exactly what the
  API serves, and that no value between its rows behaves differently.
- `course-reach` lists what each catalog course maps to, and which of the
  taxonomy's skills any course reaches, with each skill's demand per career.
  `--explain` loads the model and shows, chunk by chunk, what each sentence gave
  its course — every skill at or over the threshold under `skill_centric`, at
  most one vote under `chunk_top1` — or why it gave nothing; it raises if that
  account disagrees with the extraction the engine cached. Where courses are
  hand-labelled, `course-reach` also scores extraction against the labels.

Results, dated, are in `../skillgap/CHANGELOG.md`.

## Verified end to end

The spec's definition-of-done scenario, against the real model and data —
Business Analyst, six completed courses:

- a readiness percentage, missing skills ranked with the share of postings
  needing each, three recommended courses, skill names in English and Arabic
- cold start 34.7 s; warm start 0.0 s from cache; about 3 ms per request
- profiles survive a restart

**The mechanics work; the numbers are not yet credible.** Readiness came out at
5% for a student with Systems Analysis and Design, because course mapping yields
0–2 skills per course — four courses map to none, IT Project Management among
them — and `min_demand=0.15` admits any skill seen in one of six postings. The
API serves the engine faithfully; both causes live upstream and are recorded in
`../skillgap/CHANGELOG.md`.

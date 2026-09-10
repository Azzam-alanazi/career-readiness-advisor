# Backend — skill-gap API (Phase 3)

FastAPI service over the engine in `../skillgap/`. It loads the model, embeds the
taxonomy, and builds every career profile and course map once at startup.
Requests only read the results.

## Status — read this first

The matcher behind every figure this API returns **failed its Phase 0
validation gate**: best F1 0.503 against a 0.60 floor. The API runs anyway, by
decision, and says so in the data. `/health`, every gap response and every
recommendation response carry a `validation` block with `gate_passed: false`
and a plain-language note. Show it to users next to the numbers it qualifies.

Course-to-skill mapping has also never been measured against labelled courses,
and the same block says so.

## Run

From the repo root, with the project virtualenv active:

```bash
python -m pip install -r backend/requirements.txt
```

```bash
python -m uvicorn backend.main:app --reload
```

The first start builds career profiles and course maps with the real model and
caches them in `backend/.cache/`. Later starts with unchanged inputs read the
cache and never load the model. Interactive docs: http://127.0.0.1:8000/docs

## Endpoints

| method | path | returns |
|---|---|---|
| GET | `/health` | model, counts, cache status, validation |
| GET | `/careers` | careers with their posting counts |
| GET | `/courses` | catalog: code, name, number of skills mapped |
| POST | `/profiles` | create a student profile — `career`, `completed_courses` (codes), optional `major` |
| GET | `/profiles/{id}` | the stored profile |
| GET | `/profiles/{id}/gap` | readiness %, covered skills, missing skills ranked by demand |
| GET | `/profiles/{id}/recommendations?limit=3` | courses ranked by the demand of the gaps they close |

Unknown careers and course codes are rejected with a 422 naming the offending
value. Skill entries carry both `en` and `ar`. Course names are English only,
because the catalog is.

## Design decisions

- **Nothing is embedded per request.** Students pick courses from the catalog,
  so the model is needed only to build profiles, never to answer a request
  (spec item 12).
- **Profiles persist, keyed by their inputs** (spec item 6). The cache key hashes
  the taxonomy, config, posting text, course text, model name and engine source.
  Relabelling a posting does not invalidate it; changing anything extraction reads
  does. A stale profile cannot be served.
- **Startup refuses a stale config.** A `StaleConfigError` from the engine stops
  the service, rather than letting it apply parameters measured against a
  different taxonomy.
- **Chunking matches `validate.py`.** Extraction runs on the stored posting text,
  `" | "` separators included, because that is the text the parameters were
  measured on.
- **SQLite with a TRUNCATE journal.** The repo sits in OneDrive, which can refuse
  the journal deletes SQLite's default mode relies on.
- **Engine defaults pass through untouched.** `analyze_gap`'s `min_demand=0.15`
  has never been validated. The API uses it as-is rather than burying a second
  unvalidated number in the service layer.

## Tests

```bash
python -m pytest
```

37 tests, offline, a few seconds. A stand-in bag-of-words embedder replaces
the 1 GB model, over a four-skill fixture world small enough that every expected
value can be checked by hand.

Covered: the failed gate reaching every response; demand-weighted readiness and
ranking; bilingual names; rejection of unknown careers, courses and profiles;
profiles surviving a restart; the model loading once and never per request; a
warm restart skipping the model entirely; cache invalidation on a config change;
startup refusing a stale config before any model work; and the reports below.

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
- `course-reach` lists which of the taxonomy's skills any catalog course maps
  to, with each skill's demand per career. `--explain` loads the model and
  shows, chunk by chunk, what each course sentence voted for or why it was
  dropped; it raises if that account disagrees with the served map.

Results as of 2026-09-10 are in `../skillgap/CHANGELOG.md`.

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

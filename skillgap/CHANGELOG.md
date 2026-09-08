# Changelog — skill-gap engine

Running record of what changed, when, and why. Phase 0 (validation gate) only.
Nothing from Phase 1+ has been started.

---

## 2026-09-08 — Manual validation sample: stratified draw, merge tool

### Changed — the sample is drawn three times, and the reasons are worth keeping

**Draw 1** (seed 20260905, ids 3, 7, 18, 22, 25) was retired because the script
printed each posting's AI label count — 10, 10, 10, 12, 19. Knowing roughly how
many skills to expect anchors a manual pass, and anchoring is not something a
labeller can decide not to do. Those five are excluded from every later draw
rather than merely re-randomised; re-drawing one would carry the anchor back in.

**Draw 2** (seed 20260908, ids 4, 5, 11, 14, 39) was a plain random draw over
the remaining 11. It landed on Business Analyst ×3 and ERP Consultant ×2 — two
careers out of five, when four were available. Valid random, poor coverage for
validating a system whose whole output is a cross-career comparison.

**Draw 3** (seed 202609083) is stratified: one posting from each reachable
career, plus one extra from whichever stratum had the most left afterwards.

| | BA | Data Analyst | ERP | IT Support | SW Dev |
|---|---|---|---|---|---|
| corpus (27) | 6 | 5 | 6 | 5 | 5 |
| has an AI baseline (16) | 5 | 1 | 3 | 2 | 5 |
| eligible, draw 1 excluded (11) | 4 | **0** | 3 | 1 | 3 |
| **draw 3** | **2** | 0 | **1** | **1** | **1** |

Ids **4, 5, 12, 16, 19**. The extra went to Business Analyst, which had 3 left
against ERP's 2 and Software Developer's 2 after the first pass. Ties break on
career name so the draw reproduces from the seed alone.

Draw 2's counts were never printed, so its postings stayed eligible and two of
them (4, 5) survive into draw 3. All three draws are archived side by side under
`test/archive/` and `test/holdout/archive/`.

### Coverage limitation — Data Analyst cannot be validated

**Data Analyst has no reachable posting and draw 3 does not cover it.** The
career holds 5 postings, but only one of them (id 7) carries an AI baseline, and
id 7 was in draw 1. Excluding draw 1 therefore empties the stratum. There is no
way to draw a Data Analyst posting that is both comparable against the baseline
and unanchored.

This is recorded rather than worked around, because both workarounds are worse
than the gap. Re-admitting id 7 reintroduces a known anchor into the one place
the project measures itself honestly. Drawing an unbaselined Data Analyst
posting gives something to label but nothing to compare it against, which is not
validation. The manual-versus-AI agreement figures will describe four careers of
five, and the evaluation chapter should say so.

The root cause is upstream: the AI labelling pass ran against the pre-repair
collection, and 4 of the 5 Data Analyst postings then in the set were later
excluded as aggregator summaries. Closing the gap needs a baseline pass over the
current corpus, not a different draw.

### Note — id 16's baseline predates its career correction

Id 16 sits in draw 3 as Software Developer. Its AI labels were generated when it
was still filed under IT Support Specialist — the aggregator's slug said
`it-support-specialist` while the advert was plainly a Web Developer role. The
posting text is identical; only the career label moved. If the labelling pass
used career as context, that baseline was produced under the wrong one, which
would show up as disagreement attributable to the pipeline rather than to
judgement. Worth remembering when reading id 16's row in the comparison.

### Added — `test/merge_labels.py`

Writes hand labels from `manual_validation.csv` into the corpus and reports
agreement against the held-out AI baseline.

- Dry run by default; `--write` applies. Verified the dry run leaves the corpus
  at zero labelled rows.
- **Refuses while any of the five is blank**, naming which. A partial merge would
  quietly become a partial ground truth.
- Rejects unknown skill ids before touching anything — caught both `SK999` and a
  lowercased `sk17` in testing.
- Per-posting precision, recall and Jaccard, plus micro and macro overall, then
  the disagreements listed by skill name.
- Backs up to `.bak` and writes in place. `os.replace()` fails here: OneDrive
  holds a handle on `test/` that permits writes but refuses deletes, which is
  also what broke the first archive attempt.

Direction is stated in the file and matters: **your labels are the reference,
the AI's are the prediction.** Precision is "of what the AI proposed, how much
you kept"; recall is "of what you found, how much the AI got". Read the other way
round, the conclusion inverts.

Exercised end to end against throwaway copies with fabricated labels — every
branch, then confirmed the real files were untouched.

### Fixed — the eligible pool was joined on the wrong key

Postings were matched to the AI baseline by id. The recovered posting is id 39
in the corpus and id 2 in the baseline, so an id join dropped it silently and
the pool was one short. Matching is now by canonical URL. Id 39 became eligible
and was drawn into draw 2.

---

## 2026-09-08 — Repo recovery: provenance, guards, lost data

Follows an audit of the repo. No parameters changed, nothing relabelled, and
`validate.py` was deliberately **not** re-run — `config.json` still holds the
figures swept on 2026-09-05.

### Recovered — posting id 2, which had vanished without a record

Original id 2 (Client of MENA Consultant, Naukrigulf, 1090 chars) was in
neither `labeled_postings.csv` nor `labeled_postings_excluded.csv`, and its URL
appeared nowhere in the repo.

It was released from the excluded file when the floor moved 1200 → 1000, on the
assumption collection would re-fetch it. Collection never did: Business Analyst
was already at target, so the top-up skipped that career entirely. The row fell
between the two steps and left no exclusion record — the one failure mode the
excluded file exists to prevent.

Rebuilt from `raw_responses/business_analyst_p0.json` rather than from a CSV
copy, so it carries what the API actually returned, including the `job_title`
(*"Business Analyst (SAP Engagement)"*) that the original row predated. Verified
against `screen()` before restoring: it passes the current 900-char rule. Given
a fresh id (**39**), never a recycled one.

All 25 original postings are now in one file or the other. Business Analyst sits
at 6, as does ERP Consultant.

### Added — provenance for the taxonomy and the validation baseline

Both lived only in `~/Downloads` and could not be rebuilt from the repo:

| file | what it is |
|---|---|
| `skillgap/real_skill_taxonomy_90.csv` | source `taxonomy.json` was generated from |
| `test/labeled_postings_esco_taxonomy.csv` | AI-generated labels; the baseline the 5 manual labels get compared against |

Verified the committed source still regenerates the live taxonomy: same 90 ids,
same English labels.

### Added — `test/raw_responses/` is now committed, not ignored

18 cached payloads, 888 KB. They are the sole evidence for claims published in
`CAREER_PROJECT_SPEC.md` and this file: the 47 re-admitted postings, the 85-of-158
null `job_country` count, and *"across all 98 cached listings, not one Arabic
character"* — which is what makes the English-only finding a property of the
market rather than of the filter. Ignoring them left those claims unverifiable
by anyone cloning the repo, and re-running collection would neither reproduce the
same result set nor be free.

Scanned before committing: the API key travels in a request header and appears
in no response body. The only matches for credential-ish words are job text
("authorization roles", "token expiry"). The echoed `parameters` block carries
the query and country, no key.

Worth noting from those payloads: the request parameters record
`"language": "ar"`. The endpoint was asked for Arabic and returned English
anyway — further support for the English-only finding.

### Added — ids for the 9 excluded rows that had none

Collection-time rejects were written with an empty `id`, so they could not be
referenced or joined. Now **40–48**, continuing past every id either file has
used. No existing id was touched and no collisions exist.

### Added — `StaleConfigError`, the guard for the audit's worst finding

`load_match_params()` now refuses parameters swept against a different taxonomy
than the one loaded, comparing `config.json`'s `taxonomy_skills` against
`taxonomy.json`.

The failure it prevents had already happened. With `config.json` holding
parameters from the 19-entry taxonomy and `taxonomy.json` swapped to 90 entries,
`demo.py` ran to completion and reported **0% readiness with two skills
detected**. No crash, no warning. Measured cause, over 301 real chunks:

| taxonomy | clear threshold | also clear `margin=0.03` | median top1−top2 gap | gaps < 0.03 |
|---|---|---|---|---|
| 19-entry | 218 | 66 | 0.0145 | 77% |
| 90-entry | 234 | **30** | 0.0075 | **90%** |

A denser taxonomy packs near-synonyms closer — `SK01 Requirements analysis`
against `SK02 Requirements elicitation` — so a margin measured on 19 skills
discards ~87% of qualifying chunks on 90. A threshold and a margin are only
meaningful relative to the label set they were swept over.

`demo.py` now raises instead of printing a plausible zero.

### Changed — the two `labeled_postings.csv` files no longer collide

`skillgap/labeled_postings.csv` (the 19-taxonomy starter scaffold, 3 labelled
rows using ids that no longer exist) is now
`skillgap/archive/labeled_postings_starter19.csv`, with an `archive/README.md`
explaining why it is kept: **every F1 in this changelog was measured on those
three rows**, so the evaluation chapter is not reproducible without them. It also
holds the only Arabic posting collected anywhere in the project.

`validate.py`'s `POSTINGS_CSV` now points at `../test/labeled_postings.csv`, the
real corpus. **The 5 postings being hand-labelled are in
`../test/manual_validation.csv`**, so those labels need merging into the corpus —
or that one constant repointing — before a sweep will see them.

### Changed — `requirements.txt` completed and pinned

`requests` and `python-dotenv` were imported by `collect_postings.py` and
declared nowhere. `transformers` was unlisted despite the stack depending on its
major version. Everything is now pinned to the versions the recorded results were
produced with: sentence-transformers 6.0.1, transformers 5.16.1, torch 2.13.0,
numpy 2.5.2, scipy 1.16.3, requests 2.34.2, python-dotenv 1.2.3.

### Rewritten — `README.md`

It described a system that no longer exists: "Starter taxonomy has 19 skills",
Known Limitations discussing `accounting`, `powerbi`, `problem_solving` and
other ids absent from the current taxonomy, and an F1 table presented as current.

The rewrite leads with the fact that the engine will not run and why, states that
every recorded F1 rests on 3 postings and 11 labels, and adds the two constants
nobody has justified: `split_chunks(min_len=15)`, which decides what becomes a
chunk at all and appears in no session note, and `analyze_gap(min_demand=0.15)`,
flagged as a magic number in session 2 and never swept.

### Still open

- **No labels anywhere.** 27 postings and 16 courses collected, zero labelled.
  Phase 0's gate was measured on 3 postings, against the spec's 20–30.
- `config.json` is stale by design until a sweep runs against the 90-entry
  taxonomy. The guard makes that loud instead of silent.
- Business Analyst and ERP Consultant hold 6 postings, the others 5.
- Whether the archived starter set should be remapped onto SK-codes or retired.

---

## 2026-09-05 — Phase 0 collection closed: truncation check

### Added — `looks_truncated()`, independent of length

Some publishers store a clipped copy of the advert, cut at a fixed size. Length
cannot find these: the JobLeads Data Analyst posting is **1087 characters** and
still stops at "Advanced knowledge of SQL, ETL and data". Whatever requirements
followed the cut are gone, so its skills are missing for a reason that has
nothing to do with the employer.

Missing punctuation alone is not evidence — plenty of complete adverts end on a
bullet ("• Regulatory and Compliance Requirements Analysis"), a field ("Work
Location: In person"), or a keyword list. The ending also has to read as
mid-clause. Three signals, each requiring no terminal punctuation first:

1. trailing comma, colon, semicolon or slash;
2. ending on a function word — "…with opportunities for", "…Python/R are";
3. a coordinating conjunction in the final two words — "SQL, ETL **and** data"
   is waiting for another item, while "the Saudi **and** Egyptian employment
   laws" is finished.

Scraper footers (`#J-…-Ljbffr`) are stripped first, since they sit *after* the
cut and would otherwise hide it.

Validated on 15 hand-picked cases (all correct) and on every ending in both
files. It flags **one** row in the kept set and two already-excluded ones:

| id | file | ending |
|---|---|---|
| **37** | kept → now excluded | `…related roles. • Advanced knowledge of SQL, ETL and data` |
| 10 | already excluded | `…1,400 SAR per month with opportunities for` |
| — | already excluded | `…proficiency in SQL and Python/R are #J-18808-Ljbffr` |

No other row in either file is caught.

### Changed — `MIN_POSTING_CHARS` 1000 → 900

Required to bring row 14 back: it is 991 characters, and it is **not**
truncated — it ends "…Information Technology, or a related field." It was only
ever excluded on length. 900 sits inside the empty band between 519 and 990
that the original gap analysis identified, so it excludes every aggregator
summary while keeping row 14, and no other row falls between 900 and 1000.

With truncation now checked directly, length no longer has to serve as a proxy
for incompleteness — which is what made the earlier 1200 → 1000 → 900 argument
awkward. Each rule now does one job.

### Fixed — ids were reused across the two files

Evicting row 37 and collecting a replacement in the same pass produced **two
different vacancies under id 37**: the truncated Flyper posting in the excluded
file, and a fresh AtkinsRéalis posting in the main file. The allocator read the
highest id from the main file only, so an evicted row's id was handed straight
to the next posting collected — across the two files that are meant to join on
it.

`max_known_id()` now scans both. The AtkinsRéalis row was renumbered to 38; no
collisions remain.

### Final state — collection closed

| | |
|---|---|
| postings | **26** |
| per career | BA 5, Data Analyst 5, **ERP Consultant 6**, IT Support 5, Software Developer 5 |
| length | 991 – 6627 chars |
| chunks | 8 – 92 |
| duplicates | 0 |
| language | **26 English, 0 Arabic** — no description contains a single Arabic character |
| `skill_ids` filled | 0 — nothing has been relabelled at any point |
| excluded | 19, each with a reason |

ERP Consultant sits at 6 because row 14 returned to a career already at target.
Nothing was dropped to force it back to 5 — a surplus posting is more data, and
demand weight is a fraction computed within a career, so the extra row does not
distort comparison against the others. Say if you would rather it were trimmed.

---

## 2026-09-05 — Phase 0: final collection fix

Last collection change. The set is now stable for labelling.

### Fixed — `job_country` fallback to `job_location`

`screen()` now calls `in_saudi()`, which prefers the structured `job_country`
and falls back to the free-text `job_location` (also `job_city`, `job_state`)
only when the structured field is absent. A populated non-Saudi country stays
authoritative, so a stray city name in prose cannot talk it round.

`SAUDI_PLACES` matches Saudi cities in both scripts plus Saudi / KSA /
السعودية / المملكة. Word boundaries are not cosmetic here: **"جدة" (Jeddah) is
a substring of "المتجددة" (renewable)**, so a plain containment test reads
"الطاقة المتجددة" as a Jeddah vacancy. `\b` on the Unicode word class blocks
that; verified against that case and eight others including Dubai, Cairo and
Doha, which must not match.

**Effect on the 98 unique cached listings:**

| | passing |
|---|---|
| old rules (`job_country` only, 1200 floor) | 27 |
| corrected rules (`job_location` fallback, 1000 floor) | **74** |
| **newly passing** | **47** |

Of the 47, **45 had been rejected for a null country** and 2 for the old floor.
The filter had been discarding roughly two-thirds of every result set, and doing
it by publisher — GulfTalent, Bayt, Foundit, Monster and Parsons listings were
being dropped wholesale while LinkedIn and Indeed passed.

### Changed — `MIN_POSTING_CHARS` 1200 → 1000

A correction to what I reported last session: I said 1000 would readmit rows 14
and 2. It readmits 2 and 8, **not 14**. The lengths quoted in that table were
measured on the stored `posting_text`, where each newline has become `" | "` —
three characters instead of one — which inflates every figure. `screen()`
measures the original, and on that basis row 14 is **991 chars, nine short of
the new floor**. The empty band in original lengths is 519–990, so a floor of
900 is what would have kept row 14.

The change also has a cost worth stating: row 8 came back (now id 37) and it is
the **truncated** one, ending mid-sentence at "Advanced knowledge of SQL, ETL
and data". So 1000 readmits an incomplete posting while still excluding a
complete one. A truncation check would separate those two cases properly;
length alone cannot.

### Excluded — row 28, manual

Sparc Consulting "Analyst", flagged last session as the weakest career fit:
a generalist management-consulting role where data analysis is one bullet among
research and business development. Excluded with reason prefixed `manual:`.

Manual exclusions are **sticky** — the re-screening pass releases rows that fail
only an obsolete rule, but never a manual one, because those record a judgement
about content rather than a rule outcome.

### Fixed — rows excluded under an obsolete rule stayed blacklisted

Excluded URLs join the seen-set, so a posting rejected under a rule that was
later corrected would never be fetched again. Re-screening the excluded file
against the corrected rules **released 35 of 53 rows**, including ids 2 and 8
from the original set. The file now holds 19: 17 genuine aggregator summaries,
row 21 (remote-Americas), and row 28 (manual).

### Re-run — 25 postings, 5 per career

One new posting was needed (Data Analyst) after the release; everything else was
already at target. Total cost of this run: one career queried.

| | |
|---|---|
| postings | 25 (5 per career) |
| shortest | 1113 chars / 16 chunks |
| thinnest by chunks | id 30, 8 chunks at 1723 chars |
| duplicates | 0 |
| `skill_ids` filled | 0 — nothing relabelled |

### The language finding survives, and is now better evidenced

**Split of the new set: 25 English, 0 Arabic.** Unchanged.

This is the outcome that mattered. The corrected filter re-admitted 47 postings
that the broken one had thrown away, and the discarded pool was exactly where
Arabic postings would have been hiding — those listings carry Arabic *location*
strings ("الرياض • عبر GulfTalent"), which is why the old filter's blind spot
tracked them. Every one of the 47 is in English.

Across all 98 cached listings, **not one description contains a single Arabic
character** (maximum Arabic character share in any posting: 0.0000).

So the finding is not retracted — it is strengthened. The English-only sample is
a property of how these boards carry Saudi IS vacancies, not an artefact of a
filter. `CAREER_PROJECT_SPEC.md` records this under *Sampling: language*.

The limitation it creates is unchanged: **cross-lingual matching remains
unvalidated on the market side**, and engine decision 2 rests on the taxonomy's
Arabic labels plus one Arabic posting in the older hand-labelled set.

---

## 2026-09-05 — Phase 0: collection repair

### Length floor — set to 1200, though the data argues for ~1000

Distribution of the original 25, sorted by description length:

```
451  465  476  494  503  505  522  |  1011  1090  1113  1507  1745  1945  2694 ...
                                   ^^^ 489-char gap, nothing in between
```

The seven below 522 are exactly the seven aggregator blurbs — all from
JobLeads, Jooble or Jobrapido, all rewritten in the third person, several
carrying the scraper's own `#J-…-Ljbffr` footer, one truncated mid-sentence.
Above the gap the postings are employers' own adverts. **Any cut between 523
and 1010 excludes precisely those seven and nothing else**, which makes that
band the robust choice: the outcome does not move if the number does.

1200 was applied as specified. It additionally removes three rows the gap
argument would keep:

| id | chars | chunks | source | assessment |
|---|---|---|---|---|
| 14 | 1011 | 11 | LinkedIn | genuine employer advert, terse but complete |
| 2 | 1090 | 8 | Naukrigulf | genuine, complete |
| 8 | 1113 | 16 | JobLeads | **truncated** — ends mid-sentence at "SQL, ETL and data" |

Row 8 deserves to go on its own merits. Rows 14 and 2 are real postings lost to
a round number. **Recommendation: `MIN_POSTING_CHARS = 1000`**, which sits in
the empty band and would have kept them. It is one constant in
`collect_postings.py`, and both rows are recoverable from the excluded file.

A caveat either way: the floor counts characters, not chunks, and the two are
not tightly coupled. Row 30 survives at 1723 chars but yields only 8 chunks
because it is written as long unbroken paragraphs, while row 8 was denser per
character. Chunk count is what the engine actually matches against.

### Excluded — 11 of the original 25, with reasons

Moved to `labeled_postings_excluded.csv` (kept in full, with
`excluded_reason` and `excluded_on`; nothing deleted).

| id | career | reason |
|---|---|---|
| 2 | Business Analyst | 1090 chars, below floor |
| 6 | Data Analyst | 447 chars, below floor |
| 8 | Data Analyst | 1087 chars, below floor (also truncated) |
| 9 | Data Analyst | 472 chars, below floor |
| 10 | Data Analyst | 499 chars, below floor |
| 13 | ERP Consultant | 461 chars, below floor |
| 14 | ERP Consultant | 991 chars, below floor |
| 15 | ERP Consultant | 518 chars, below floor |
| 17 | IT Support Specialist | 490 chars, below floor |
| 20 | IT Support Specialist | 499 chars, below floor |
| **21** | Software Developer | **remote role sited outside Saudi Arabia** ("based remotely in the Americas region") |

A further 42 postings were screened out during the top-up and logged the same
way, so the excluded file now holds 53 rows.

### Career verification — checked against description text, not the query

One outright mismatch, corrected as instructed:

- **Row 16 → Software Developer** (was IT Support Specialist). BeBee's slug says
  `it-support-specialist`; the advert is unambiguously a Web Developer role —
  HTML/CSS/JavaScript/PHP, React/Angular/WordPress, no support duties at all.
  The employer's own title was never captured, which is why nothing caught it.

Everything else matched its career. Four are defensible but worth knowing about,
and none were changed:

| id | title | career | note |
|---|---|---|---|
| 5 | Senior System Analyst | Business Analyst | title differs; content is requirements engineering, BRDs, SRS — BA work |
| 19 | Senior .NET Application Support Specialist (L2/L3) | IT Support Specialist | genuinely support, but developer-weighted |
| 26 | Business Analyst / Functional Lead – D365 SCM | Business Analyst | titled BA, substance is ERP functional work |
| 27 | Senior Data Science Specialist | Data Analyst | predictive modelling and statistics — data science, adjacent not identical |
| 28 | Analyst | Data Analyst | **weakest fit** — generalist management-consulting analyst at Sparc Consulting; "collecting and analyzing data" is one bullet among research and business development |

### Added — `job_title`, captured not reconstructed

New column, populated from the API's `job_title` for all new rows (11 of 25).
Existing rows carry it empty rather than backfilled from URL slugs: the column
records what the source reported, and filling old rows with values derived from
their URLs would put inference into a field meant for source data. The slugs
remain available if backfilling is ever wanted.

This is the column whose absence let row 16 pass a full duplicate check
unnoticed.

### Changed — `is_saudi` replaced by `screen()`

`screen(job)` returns the reason a posting was rejected, or `None` to keep it.
Returning the reason rather than a boolean is what makes the excluded file
auditable. `is_saudi` remains as a thin wrapper.

It now checks the description for a role sited outside the Kingdom, not just
`job_country`. Patterns are deliberately narrow: they match "based remotely in
the Americas region" (row 21) but not "based in Riyadh or Karachi" (row 15,
kept as instructed) — a Saudi vacancy naming a second location is still a Saudi
vacancy. Verified against all 25 originals: row 21 is the only match.

### Fixed — excluded URLs were re-fetched every run

Previously excluded postings were not in the seen-set, so each run re-fetched
and re-screened the same known-bad jobs, spending quota to reach the same
verdict and appending a second identical row to the excluded file. The first
top-up produced 10 such duplicates, since removed. `excluded_urls()` now joins
the seen-set at startup; a re-run is a clean no-op.

`TARGET_PER_CAREER` also changed meaning: it is now the target for **total**
rows held per career, so each run tops up to that number and a career already
at target costs no requests.

### Open — `job_country` is null on more than half the API results

Found while auditing the exclusion reasons: 39 of the top-up rejections were
`job_country='unset'`. Across all 16 cached payloads, **85 of 158 jobs have
`job_country`, `job_city` and `job_state` all null**, while `job_location`
carries the city as text. One rejected example:

```
job_title    = 'Business Analyst (Data Warehouse And Analytics)'
job_publisher= 'GulfTalent'
job_location = 'الرياض     •  عبر GulfTalent'      <- Riyadh
job_country  = None
```

That is a Riyadh vacancy being discarded for a missing field. The behaviour
predates this session — the original `is_saudi` required `job_country in
("SA", "SAUDI ARABIA")` — but it was invisible until rejections carried
reasons. It means collection has been silently discarding over half of every
result set, non-randomly (it tracks the publisher), which is the same class of
bias as the length problem.

**Not changed**, because fixing it alters which postings are in the sample, and
the current 25 are about to be labelled. The fix would be to fall back to
parsing `job_location` when `job_country` is null. Note this also affects the
Arabic-sampling finding: `job_location` on these rows is in Arabic, so the
discarded set may not have the same language profile as the kept set.

### Current state

25 postings, exactly 5 per career, minimum 1287 chars / 8 chunks. No duplicates
(300 pairs compared, highest similarity 0.201). All `skill_ids` still blank —
nothing was relabelled.

---

## 2026-09-05 — Phase 0: 25 postings collected, duplicate check, sampling limitation

### Checked — no duplicates in the collected set

25 postings, checked for aggregator republishing (the same vacancy appearing
under several publishers with different URLs, which a URL-only check misses
entirely). Compared on employer, a title proxy, and description similarity —
TF-IDF cosine over word 1–2 grams plus 5-gram shingle Jaccard, all 300 pairs.

| check | result |
|---|---|
| identical URL | 0 pairs |
| identical `posting_text` | 0 pairs |
| employers appearing more than once | 0 |
| flagged as possible duplicates | **0** |
| highest pair similarity | **0.217** (ids 1+4) |
| mean pair similarity | 0.070 |

Republished duplicates land above 0.90; employer boilerplate lands 0.6–0.9. The
maximum here is 0.217, which is topical overlap — ids 1 and 4 are Business
Analyst roles at two different banks, sharing vocabulary, not text. **Nothing
was deleted, and nothing needs to be.**

Worth noting for when the sample grows: the CSV has **no `job_title` column**,
so the title had to be reconstructed from URL slugs (LinkedIn, JobLeads, BeBee
and Naukrigulf carry it; Indeed, Jooble and Jobrapido use opaque numeric IDs).
The Phase 1 column list in the spec does include `job_title` — adding it at
collection time would make future duplicate checks stronger and cheaper.

### Limitation — the sample is 25 English, 0 Arabic

The collection ran five English query strings (`"business analyst"`,
`"data analyst"`, `"ERP consultant"`, `"IT support specialist"`,
`"software developer"`) against JSearch with `country=sa`. Every one of the 25
results came back English, including postings from Saudi employers hiring for
Saudi offices — row 24 is a Riyadh university (جامعة دار العلوم) whose employer
name is Arabic and whose description is entirely English.

The language stratification target (roughly a third each Arabic / English /
mixed) is **dropped**, recorded in `CAREER_PROJECT_SPEC.md` under *Sampling:
language*. Enforcing the quota would mean discarding real English postings or
sourcing Arabic ones through a second, different collection process — either
one distorts the demand weights that Phase 1 exists to produce.

What this costs, stated plainly for the evaluation chapter:

- **Cross-lingual matching is now unvalidated on the market side.** Engine
  decision 2 ("no translation step") is unchanged and not reversed, but its
  evidence is the taxonomy's Arabic labels plus one Arabic posting in the older
  hand-labeled set — not real Arabic market data.
- Arabic was already the weakest measured axis: the single Arabic posting in the
  session-3 sweep produced the only false positive and one of the false
  negatives.
- `collect_postings.py` still classifies language per row (`detect_lang`), so if
  Arabic postings do appear later they are captured, not silently dropped.

The bilingual UI requirement (spec item 16, RTL via `flutter_localizations`) is
**untouched** — it concerns the app's interface, not the language of the
postings behind it, and the spec now says so explicitly so it does not get
"tidied away" later as a casualty of this change.

### Limitation — posting length varies ~10x by publisher, and not at random

Found while reading the postings. Some publishers carry the employer's full
advert; others rewrite it into a three-sentence blurb. Measured in characters
and in chunks (what the engine actually matches against):

| publisher | rows | median chars | median chunks |
|---|---|---|---|
| LinkedIn | 10 | 4127 | 53 |
| إنديد (Indeed) | 3 | 2698 | 43 |
| BeBee | 2 | 2219 | 31 |
| Naukrigulf | 1 | 1090 | 8 |
| Jobrapido | 1 | 522 | 5 |
| Jooble | 1 | 505 | 5 |
| **JobLeads** | **7** | **494** | **5** |

Nine of 25 postings yield 6 chunks or fewer; the longest yields 92. A skill has
roughly ten times more opportunity to be matched in a LinkedIn posting than in
a JobLeads summary.

This matters more than it first looks, because **the short ones are not spread
evenly across careers**. JobLeads supplies 4 of the 5 Data Analyst rows (ids 6,
8, 9, 10) while Software Developer is almost entirely full-length LinkedIn
adverts. Demand weight is the fraction of postings mentioning a skill, so Data
Analyst's profile is computed from ~500-character summaries and Software
Developer's from ~4000-character adverts. That deflates Data Analyst demand
weights relative to Software Developer for reasons that have nothing to do with
the labour market — and cross-career comparison is the product.

Options, none taken yet because this is a collection-policy decision:
prefer the full-text publisher when the same vacancy is available from several;
record `posting_text` length as a column and check demand weights against it;
or exclude summaries below a chunk threshold and state the exclusion rule.

### Not done

The 25 postings live in `test/labeled_postings.csv` with five extra columns
(`employer`, `city`, `source`, `url`, `onet_soc`) that the harness does not
read, and all 25 have `skill_ids` blank. They have **not** been promoted into
`skillgap/labeled_postings.csv`, which still holds the 3 older hand-labeled
Business Analyst rows — including the only Arabic one. Promoting is a decision
about schema and about whether that Arabic row survives, so it waits.

---

## 2026-09-01 — Phase 0, scope change: target careers narrowed to IS

### Changed — `labeled_postings.csv` regenerated for five IS-focused careers

| | before | after |
|---|---|---|
| careers | Software Developer, Business Analyst, Marketing Specialist, Accountant, HR Officer | Business Analyst, **Data Analyst**, **ERP Consultant**, **IT Support Specialist**, Software Developer |
| rows | 30 (uneven: 4–6 per career) | 25 (exactly 5 per career) |
| `lang` | pre-assigned 9 en / 9 ar / 9 mixed | blank |

Dropped: Marketing Specialist, Accountant, HR Officer. Added: Data Analyst, ERP
Consultant, IT Support Specialist.

**Why.** The old set came from the project spec's Phase 1 list, which spans the
whole business school — an accountant and an HR officer are not roles an
Information Systems graduate is typically hired into. The replacements are, and
they sit much closer to the existing taxonomy: Data Analyst exercises `sql`,
`excel`, `powerbi`, `python`; ERP Consultant exercises `erp`, `requirements`,
`process_modeling`; IT Support Specialist exercises `networking`,
`cybersecurity`, `communication`. The previous set left `erp` and `networking`
with no career that would plausibly demand them, so those taxonomy entries were
never going to be exercised by the labeled data.

Even 5 per career is a change of shape, not just of names: the old file was
uneven, so demand weights would have been computed from different denominators
per career without that being visible anywhere.

**No data was lost.** All three hand-labeled postings are Business Analyst,
which survives the new list, so they carry over untouched — text, `lang` and
`skill_ids` intact — and occupy 3 of Business Analyst's 5 slots. The dropped
careers held only blank scaffold rows, so `labeled_postings_archive.csv` was
**not** created; there was nothing to put in it. The regeneration script writes
that archive only when a labeled row's career actually disappears, and refuses
to run if a surviving career already holds more labeled rows than the per-career
quota, rather than silently discarding the excess.

**`lang` is now blank on the 22 unfilled rows**, by request. Pre-assigning a
language target commits to a distribution before knowing what postings exist;
it gets recorded per row once each posting is actually collected. This does mean
the roughly-even Arabic/English/mixed split is no longer enforced by the file —
worth watching when filling it in, since Arabic recall is the weakest measured
axis so far and an all-English set would hide that.

Nothing else changed: no engine, harness, taxonomy or config edits. `validate.py`
still loads the file cleanly and reports the same postings winner
(`chunk_top1`, F1 0.900).

---

## 2026-09-01 — Phase 0, session 4: taxonomy split, two-domain validation

### Changed — `accounting` split into two entries

| | before | after |
|---|---|---|
| `accounting` | en *"Accounting and financial reporting"* <br> ar *"المحاسبة والتقارير المالية"* | en *"Accounting and bookkeeping"* <br> ar *"المحاسبة ومسك الدفاتر"* |
| `financial_reporting` | — (new) | en *"Financial statement preparation"* <br> ar *"إعداد القوائم المالية"* |

**Why.** The old label was doing two jobs. *"Financial reporting"* means producing
financial statements, but the word *reporting* on its own is about producing
documents — and the embedding has no way to know which sense was intended, so it
scored high on both. That is how `accounting` came to sit 0.870 against
`communication` at 0.898 on *"Professional communication, presentations, report
writing"*: a 0.028 gap that failed the 0.03 margin and cost a true positive.

The split gives each sense its own entry, and both new labels avoid the bare word
*report*. The Arabic follows the same logic — *"التقارير المالية"* (financial
reports) became *"القوائم المالية"* (financial statements). Taxonomy is now 19
skills.

**Effect on the motivating case:**

| | before split | after split |
|---|---|---|
| `communication` | 0.898 | 0.898 |
| runner-up | `accounting` 0.870 | `financial_reporting` 0.840 |
| gap vs 0.03 margin | **0.028 — fails** | **0.057 — clears** |

`demo.py` recommends Technical Writing again, closing `communication`, the
highest-demand missing skill at 67%.

**The margin did not need to move.** Re-swept after the split: still
`chunk_top1`, threshold 0.8193, margin 0.03, F1 0.900, plateau width 0.1412 —
identical on every figure. The margin was never the problem; the taxonomy was.
A fifth synonym probe covering `financial_reporting` was added and passes, 5/5.

Two things the split does not fix, both visible in the check:

- *"Quarterly financial reporting to the board"* ranks `financial_reporting`
  first but only 0.009 above `accounting`. Two genuinely adjacent entries now
  compete, which is the inherent cost of splitting. Below the 0.03 margin, so
  chunk-centric drops it.
- *"Write a technical report documenting the findings"* still misses — top-1 is
  `problem_solving` at 0.831. There is no technical-writing skill in the
  taxonomy; `communication` is labelled *"Communication and presentation
  skills"*, which does not cover written documentation. A coverage gap, not a
  regression.

### Added — course text is validated separately from postings

`validate.py` now sweeps two labeled sets independently and reports both optima
rather than one number:

```
labeled_postings.csv   job postings      -> what the market demands
labeled_courses.csv    catalog entries   -> what a student acquired
```

This closes the gap flagged at the end of session 3: parameters were being
tuned on postings and then silently applied to course text, which nothing
measured. `config.json` is now nested per domain, and `load_match_params(domain)`
takes `"postings"` or `"courses"`. `build_career_profile` and
`skills_from_courses` receive their own domain's parameters.

An unlabeled domain inherits the other's parameters, marked `"validated": false`
with the scores explicitly `null` — an inherited section must not carry an F1
that was never measured on that text, because that number would eventually get
quoted. `demo.py` prints a notice when it is running on inherited parameters.

**A smoke test with throwaway labels confirms the two domains do diverge:**

| domain | method | threshold | margin | F1 | plateau width |
|---|---|---|---|---|---|
| postings | `chunk_top1` | 0.8193 | 0.03 | 0.900 | 0.1412 |
| courses *(smoke)* | `skill_centric` | 0.8770 | 0.00 | 0.865 | 0.0032 |

Different method, different threshold, different margin. Those labels were
discarded — the numbers are not evidence — but the disagreement is the expected
shape: posting bullets carry one requirement each, so forcing skills to compete
helps; catalog sentences pack several skills into one clause, so top-1 voting
throws away real content. When the domains disagree, `validate.py` says so and
keeps both rather than averaging them into a compromise fitting neither.

### Fixed

- `validate.py` printed *"plateau width decided it"* whenever two methods landed
  within 0.02 F1, including when F1 alone had decided and the winner had the
  **narrower** plateau. It now distinguishes an exact tie from a close call.

### Phase 0 closes when

`labeled_postings.csv` rows 4–30 and `labeled_courses.csv` are filled in and the
sweep has run once against them. Everything above rests on 3 postings and 11
labels and is provisional until then.

---

## 2026-09-01 — Phase 0, session 3: exact argmax, spread demoted, second matcher

### Fixed — the 0.857 vs 0.89 discrepancy

Grid resolution, nothing subtler. The experiment that reported `F1 0.857 @ 0.885`
swept in 0.005 steps; the production `THRESHOLDS` list stepped `0.88 → 0.89`, so
**0.885 was never evaluated**. `save_threshold()` was writing the argmax of a
grid that did not contain the peak.

The fix is not a finer grid. Matching is `score >= threshold`, so F1 is a step
function whose only breakpoints are the observed scores themselves. `validate.py`
now evaluates at every distinct score and the midpoints between them — 503
candidates instead of 14 — which finds the true optimum by construction. The
displayed table is still the readable coarse grid, and it is now labelled as a
display grid so nobody mistakes it for the search space again.

Doing that exposed a second problem. The true argmax for `skill_centric` is
**F1 0.900 across 0.8880–0.8900 — a window 0.002 wide**. That is not a finding
about the task, it is one posting's score landing in a convenient spot.
Selection is therefore by **(F1, then plateau width)**, and `config.json` records
`threshold_plateau_width`. A run whose winning plateau is under 0.01 wide now
prints a warning that the value is fitted to the sample.

### Changed — similarity spread is an observation, not a gate

The old `want: wide spread, ideally > 0.5` came from watching GloVe fail and is
the wrong yardstick for this model class. A contrastively-trained sentence
transformer puts nearly all pairs in a high narrow cosine band by construction;
the absolute width of that band says little. `validate.py` now reports the
distribution without a verdict — range, quartiles, and the statistic that
actually matters:

```
range      0.749 to 0.949   (spread 0.200)
quartiles  p1=0.756  p25=0.792  p50=0.810  p75=0.829  p99=0.935
correct-skill mean 0.911 vs other-skill mean 0.836  ->  separation 0.075
```

Correct skills sit 0.075 above the rest on average inside a 0.20 band. That
separation, plus the probe rankings, is what makes thresholding viable — not the
band's width. A model can have a wide spread and still rank HR ops above
cybersecurity, which is exactly what the GloVe run did.

### Added — chunk-centric matcher, alongside the existing one

`Taxonomy.match_chunk_top1(chunks, threshold, margin)`. Each chunk votes for at
most one skill: its top-1, and only if that skill beats the runner-up by
`margin`. The existing `match()` is untouched and still directly callable.

The difference in question: `match()` asks *"does any chunk look like this
skill?"* independently per skill, so one broad chunk can trip several at once.
`match_chunk_top1` asks *"what is this chunk about?"* and makes the skills
compete, so an ambiguous chunk votes for nothing.

`Taxonomy.skill_scores()` was extracted so both matchers — and the sweep — read
one cached score matrix. The sweep now encodes once and evaluates ~6000
parameter combinations for free. The fast path is checked against the real
matchers across 798 combinations; they agree exactly.

**F1 by (threshold, margin), chunk-centric:**

| m \ th | 0.70 | 0.80 | 0.84 | 0.86 | 0.87 | 0.88 | 0.89 | 0.90 | 0.92 |
|---|---|---|---|---|---|---|---|---|---|
| 0.00 | 0.78 | 0.78 | 0.82 | 0.82 | 0.82 | 0.86 | 0.84 | 0.84 | 0.78 |
| 0.01 | 0.86 | 0.86 | 0.86 | 0.86 | 0.86 | **0.90** | 0.84 | 0.84 | 0.78 |
| 0.02 | 0.86 | 0.86 | 0.86 | 0.86 | 0.86 | **0.90** | 0.84 | 0.84 | 0.78 |
| **0.03** | **0.90** | **0.90** | **0.90** | **0.90** | **0.90** | **0.90** | 0.84 | 0.84 | 0.78 |
| 0.05 | 0.84 | 0.84 | 0.84 | 0.84 | 0.84 | 0.84 | 0.78 | 0.78 | 0.71 |
| 0.08 | 0.71 | 0.71 | 0.71 | 0.71 | 0.71 | 0.71 | 0.71 | 0.71 | 0.62 |

**Exact argmax, both methods:**

| method | F1 | P | R | TP/FP/FN | threshold | plateau | width |
|---|---|---|---|---|---|---|---|
| skill_centric | 0.900 | 1.00 | 0.82 | 9/0/2 | 0.8890 | 0.8880–0.8900 | 0.0020 |
| **chunk_top1** (selected) | 0.900 | 1.00 | 0.82 | 9/0/2 | 0.8193 (m=0.03) | 0.7487–0.8900 | **0.1412** |

**Identical F1, identical confusion matrix — and a plateau 70× wider.** That is
the whole result. Chunk-centric holds F1 0.900 anywhere from 0.75 to 0.89;
skill-centric needs a two-thousandth window. The narrow-operating-window risk
flagged in session 1 is a property of the *method*, not of the model.

`config.json` gained `match_method` and `match_margin`; `load_match_params()`
and `Taxonomy.match_auto()` route the engine to whichever method won.
`build_career_profile` and `skills_from_courses` now take that params dict
instead of a bare threshold.

### Open — chunk_top1 costs a true positive on course text

The sweep decided using job postings, because those are the only labeled data.
The same parameters also govern course-description extraction, which is never
measured. At each method's own optimum, on the demo's five courses:

| course | skill_centric @0.8890 | chunk_top1 @0.8193 m=0.03 |
|---|---|---|
| Database Systems | `sql` | `sql` |
| Systems Analysis and Design | `requirements` | `requirements` |
| Business Intelligence | `powerbi` | `powerbi` |
| Business Process Management | `process_modeling` | `process_modeling` |
| **Technical Writing** | `communication` | **(nothing)** |

Agreement on 4 of 5. On the fifth, `communication` scores 0.898 against
`accounting` at 0.870 — a gap of **0.028 against a 0.03 margin**. It fails by
two thousandths.

Two things are wrong here and neither is the matcher:

1. **A taxonomy collision.** `accounting` is labelled *"Accounting and financial
   reporting"* and is competing on the phrase *"report writing"*. Fixing the
   label is likely worth more than tuning the margin.
2. **No labeled course data.** Course descriptions pack several skills into one
   sentence where posting bullets carry one each, so the top-1 rule bites
   differently — and nothing measures it.

Visible consequence in `demo.py`: `communication` is the highest-demand missing
skill at 67%, and **no recommended course closes it any more**. Technical Writing
dropped out of the recommendations entirely. Left as-is rather than quietly
overriding the sweep, but it should be resolved before Phase 2.

---

## 2026-09-01 — Phase 0, session 2: prefix fix, threshold hardening, CSV labels

### Added

| Item | File | Why |
|---|---|---|
| `E5_PREFIX = "query: "` and a `prefix` argument on `Embedder` | `skillgap.py` | E5 is trained with an instruction prefix on every input. Without one the vectors sit off-distribution. Measured: +0.04 F1 over no prefix. |
| `load_threshold()` / `save_threshold()` | `skillgap.py` | Gives callers a validated threshold to read instead of a hardcoded literal. |
| `config.json` (generated, not hand-edited) | new | Written by `validate.py` on a passing run. Records the winning threshold plus the evidence behind it: F1, precision, recall, sample size, date. |
| `labeled_postings.csv` | new | The hand-labeled set, moved out of source. Editable in Excel without touching Python. |
| `load_labeled()` with hard validation | `validate.py` | A typo'd `skill_id` used to be invisible — it would silently become a false negative for a skill that does not exist and read as a model problem. Now it is a hard error naming the line. |
| TP/FP/FN columns in the sweep output | `validate.py` | At 11 ground-truth labels the ratios alone hide how small the sample is. |
| This file | `CHANGELOG.md` | — |

### Updated

| Item | File | From → To |
|---|---|---|
| `Taxonomy.match` threshold | `skillgap.py` | `threshold: float = 0.80` → required |
| `build_career_profile` threshold | `skillgap.py` | `threshold: float = 0.80` → required |
| `skills_from_courses` threshold | `skillgap.py` | `threshold: float = 0.80` → required |
| Two hardcoded `0.80` call sites | `demo.py` | literal → `THRESHOLD = load_threshold()` |
| Labeled set source | `validate.py` | hardcoded `LABELED` list → `labeled_postings.csv` |
| Sweep grid | `validate.py` | 8 points ending at 0.90 → 14 points to 0.94, fine-grained across 0.84–0.92 |
| Test-status section | `README.md` | "semantic matching NOT verified" (GloVe-era) → measured results |

### Fixed

- **`scipy==1.16.3` pinned** in `requirements.txt`, with the reason in a comment.
  scipy 1.18.x ships `scipy/linalg/_batched_linalg`, a native DLL that Windows
  Application Control blocks outright:
  `ImportError: DLL load failed while importing _batched_linalg: An Application
  Control policy has blocked this file.` scipy arrives transitively via
  scikit-learn → sentence-transformers, so the block takes down the whole
  embedding stack, not just scipy. 1.16.3 predates that file.
- **`validate.py` no longer writes `config.json` when best F1 < 0.60** and exits
  non-zero. The gate now enforces itself rather than relying on someone reading
  the output.

### Measured — E5 prefix configurations

Same labeled set (3 postings, 11 labels), same model, same taxonomy. Only the
prefix differs. Best F1 is over a 0.005-step sweep from 0.60 to 0.98.

| Config | chunks | labels | Similarity spread | Probes | Best F1 |
|---|---|---|---|---|---|
| **(a) adopted** | `"query: "` | `"query: "` | **0.236** | 4/4 | **0.857** @ 0.885 |
| (b) | `"query: "` | `"passage: "` | 0.188 | 4/4 | 0.750 @ 0.840 |
| (c) previous | *(none)* | *(none)* | 0.208 | 4/4 | 0.800 @ 0.870 |

Config (b) is the worst of the three, which is the expected result rather than a
surprise: `query`/`passage` is for asymmetric retrieval, and comparing a text
chunk to a skill label is a symmetric comparison. The E5 model card specifies
`"query: "` on both sides for symmetric similarity.

**Caveat.** The (a)-over-(c) margin is 0.04–0.06 F1 on 11 labels — roughly one
skill flipping. (a) is adopted because it is the documented-correct usage of the
model and it wins on every axis measured, not because the margin is significant
at this sample size. Re-check once the labeled set reaches 20–30 postings.

### Gate status at end of session 2

`match_threshold = 0.89`, best F1 **0.84** (P=1.00, R=0.73), 4/4 synonym probes.
Superseded by session 3 above — that figure came from a grid that did not
contain the optimum.

---

## 2026-09-01 — Phase 0, session 1: first real validation run

First execution of `validate.py` against `intfloat/multilingual-e5-base`. The
prior README numbers were from a GloVe word-averaging fallback, not this model.

### Environment

- Dependencies installed into `C:\Users\azzam\.venvs\skillgap` — deliberately
  outside the repo, which sits in OneDrive. torch alone is ~2.5 GB and there is
  no `.gitignore` here.
- torch 2.13.0+cpu, transformers 5.16.1, sentence-transformers 6.0.1,
  numpy 2.5.2, scipy 1.16.3. CPU only.

### Result — gate passed

| | GloVe fallback (old README) | multilingual-e5-base |
|---|---|---|
| Best F1 | not reported | **0.80** @ 0.88 |
| Precision at best | 0.31 – 0.38 | 0.89 |
| Similarity spread | 0.47 (0.59 mean-centred) | 0.21 |
| "network intrusion and threats" | ranked HR ops **above** cybersecurity | cybersecurity **first** (0.87); hr_ops does not place |
| "spreadsheets and pivot tables" | never surfaced Excel | excel **first** (0.88) |
| Synonym probes | — | 4/4 pass |

Both failures the README called out are gone. The README's core claim holds:
word-averaging embeddings cannot do this task and a contrastively-trained
sentence transformer can.

### Open issues raised by this run

1. **Similarity spread of 0.21 misses `validate.py`'s own "> 0.5" target.**
   Everything lands in a high narrow band. Partly addressed by the prefix fix
   above (0.21 → 0.24), but nowhere near 0.5. Ordering is correct, so this is
   not the GloVe failure mode — but it means the usable threshold window is
   tight, and that is the real risk to manage.
2. **Sample far too small.** 3 postings / 11 labels. One label flipping moves F1
   by roughly 0.05. Phase 0 step 2 exists precisely for this.
3. **Arabic is weaker than English.** The only false positive and one false
   negative both landed on the single Arabic posting. At n=1 that is an
   observation, not a finding — needs several Arabic postings in the labeled set
   before it means anything.
4. **`analyze_gap(min_demand=0.15)` is still an unvalidated magic number.**
   Out of scope for Phase 0, but it is the same class of problem the threshold
   defaults were. Worth a sweep of its own once real postings exist.

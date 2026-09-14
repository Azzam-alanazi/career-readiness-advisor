# Career Readiness — Flutter app (Phase 4)

Android app over the FastAPI backend in `../backend/`, in English and Arabic.
Two tabs serve two audiences. The student tab has two-step onboarding
(completed courses, then any skills from outside them), a readiness report and
suggested courses. A student can target up to three careers; the readiness
screen then shows them side by side, each with its score and its covered and
missing counts, and marks the one they are closest to. The department tab has the curriculum-gap view: the course
catalog against what the job postings ask for.

## What the numbers are — read this first

The skill matcher behind every figure **failed its Phase 0 validation gate**:
best F1 0.503 against a 0.60 floor. The app says so on the readiness and the
suggestions screens, in the student's language and with the real numbers,
built from the `validation` block the API attaches to every response.
Suggested courses are labelled as suggestions, not verdicts — it is the first
thing on that screen. University and online courses are shown apart, and every
card says whether it counts toward the degree: a university course does, an
online course does not. Online courses appear only for skills no university
course teaches.

Skills a student reports from outside coursework are shown apart from those
their courses teach. Whenever the two figures differ, readiness from the courses
alone appears beside the combined figure. The skills step says once, briefly,
that these skills are self-reported and unverified.

The department view opens with its own caveat, using the real posting counts:
52 postings since 2026-09-14, 10 or 11 per career. At that size its gaps are
indicative, and they
should not drive curriculum decisions on their own. The quality flag follows,
because the demand side comes from the same matcher.

## Run

Start the backend from the repo root, with the project virtualenv active:

```bash
python -m uvicorn backend.main:app --port 8000
```

Then, from `app/`:

```bash
flutter run
```

The app looks for the backend at `http://10.0.2.2:8000`, which is the host
machine as seen from the Android emulator. For a physical device, point it at
your machine's address:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.20:8000
```

Debug builds allow plain HTTP so they can reach the local backend. Release
builds keep Android's default and require HTTPS.

Generated files — freezed, json_serializable, and the localizations — sit next
to the sources they come from. After changing a model or an ARB file:

```bash
dart run build_runner build
```

```bash
flutter gen-l10n
```

## Structure

```
lib/
  main.dart, app.dart
  home_shell.dart       the two tabs, student and department, each with its own navigation stack
  core/                 api client, locale, formatting, shared widgets
  features/
    onboarding/         careers, course catalog and skill taxonomy; the two onboarding steps
    profile/            profile draft and saved profile, current-profile state
    gap/                readiness report and screen
    recommendations/    suggested courses by source, and the screen
    curriculum/         the department's curriculum-gap view
      each one:  data/  domain/  presentation/
  l10n/                 app_en.arb, app_ar.arb, and the generated classes
```

Riverpod 3 holds state (`Notifier`, `FutureProvider`); freezed and
json_serializable make the models. Widgets render state and call controllers —
the business rules (what makes a draft submittable, how courses and skills are
sent, what start-over resets) live in `OnboardingController`, and grouping,
searching and course coverage of skills in `skill_groups.dart`, not in widgets.

## Arabic and right-to-left

Switch language from the top bar; the whole app flips to right-to-left through
`flutter_localizations`. Translated: every piece of UI text, the quality flag,
the career names, the skill category names, and the skill names. Not translated: course names, because
the catalog is English — the onboarding screen says so.

**This is bilingual display, not cross-lingual matching.** The Arabic skill
names are the taxonomy's hand-written translations in `taxonomy.json`. No
Arabic text is embedded or matched anywhere in this flow: the API embeds
nothing per request, students pick courses from a list, and every posting
behind the demand figures is in English. Cross-lingual matching remains
untested against real Arabic postings — see `../CAREER_PROJECT_SPEC.md`. The
quality flag tells Arabic readers that the demand data comes from English
postings.

## Tests

```bash
flutter test
```

37 tests, no device needed:

- **models** — parsing backend-shaped JSON (snake_case keys, the failed gate,
  a readiness of exactly 0), the gap's two sources kept apart, skill names by
  language, the skills each course teaches, the draft's wire format,
  suggestions by source, and an unknown source rejected rather than guessed
- **API client** — Arabic decoded correctly from a response with no charset,
  non-2xx and unreachable-server errors, JSON on POST
- **onboarding controller** — a career is required, courses and skills toggle,
  both are sent sorted, nothing is ticked to start, a blank major is sent as
  null, a failed save, start-over clearing everything
- **skill groups** — categories in taxonomy order, search in either language,
  the skills the chosen courses teach
- **the full flow, in English and in Arabic** — courses, then other skills, then
  readiness, then suggestions. On the skills step nothing starts ticked, skills
  the courses teach are marked and cannot be ticked, search narrows the list, and
  the unverified note appears once. Readiness is split by source, with the
  courses-only figure. A tick survives a course being added and dropped again.
  Right-to-left is checked by layout (the warning icon moves to the right of its
  heading), not just by the direction flag. Also: an unreachable backend with a
  working retry, a failed save, and start over
- **university and online courses** — each card says whether it counts toward
  the degree, in both languages; the university course comes first; a gap with
  neither is listed, not dropped; a web address stays left to right in Arabic
- **several careers** — up to three, in the order chosen, a fourth refused; the
  first is sent as the main career and the rest to compare. The comparison puts
  each score side by side with its covered and missing counts and posting
  count, marks the closest career, and shows the courses-only figure where
  self-reported skills lift a score. Tapping a career switches the details and
  the suggestions to it. In Arabic on a 360-wide phone, three columns lay out
  right to left without overflowing
- **the department view** — its own tab, fetched only when opened, with no step
  of the student flow behind it; switching tabs keeps the student where they
  were. The sample-size caveat, with the real counts, comes above every figure.
  Uncovered skills are ranked by demand, with the careers asking. Coverage is
  shown for the scope and for each career. One career can be chosen. Arabic and
  right-to-left layout are checked too

The widget tests run against fakes shaped like the backend's JSON. To check the
models against the real, running backend instead — the spec's definition-of-done
scenario, Business Analyst with six courses, then the same with two
self-reported skills, then three careers on one profile, then the department's
curriculum view for every career — start the backend and run:

```bash
dart run tool/contract_check.dart
```

## Not verified on a device

The Android toolchain is now installed and a debug APK builds
(`flutter build apk --debug`). These checks have not seen the app on a phone.

**A black screen on the emulator is the emulator image, not the app.** On
the Android 17 preview image with 16 KB pages (`sdk_gphone16k_x86_64`), the
app starts, fetches its data and builds its whole widget tree, and Flutter
reports the first frame rasterized, yet the screen stays black. It stays black
under Impeller and Skia, through a SurfaceView and a TextureView, and with
software rendering. The stock `flutter create` counter app is black on the same
image too. Use a standard API 35 or 36 x86_64 image with 4 KB pages. Everything above is verified headlessly: `flutter test`,
`flutter analyze`, and the contract check against the live backend.

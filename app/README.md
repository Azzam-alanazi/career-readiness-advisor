# Career Readiness — Flutter app (Phase 4)

Android app over the FastAPI backend in `../backend/`: onboarding, a readiness
report, and suggested courses, in English and Arabic.

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
  core/                 api client, locale, formatting, shared widgets
  features/
    onboarding/         careers and course catalog, the onboarding form
    profile/            profile draft and saved profile, current-profile state
    gap/                readiness report and screen
    recommendations/    suggested courses by source, and the screen
      each one:  data/  domain/  presentation/
  l10n/                 app_en.arb, app_ar.arb, and the generated classes
```

Riverpod 3 holds state (`Notifier`, `FutureProvider`); freezed and
json_serializable make the models. Widgets render state and call controllers —
the business rules (what makes a draft submittable, how courses are sent,
what start-over resets) live in `OnboardingController`, not in widgets.

## Arabic and right-to-left

Switch language from the top bar; the whole app flips to right-to-left through
`flutter_localizations`. Translated: every piece of UI text, the quality flag,
the career names, and the skill names. Not translated: course names, because
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

20 tests, no device needed:

- **models** — parsing backend-shaped JSON (snake_case keys, the failed gate,
  a readiness of exactly 0), skill names by language, the draft's wire format,
  suggestions by source, and an unknown source rejected rather than guessed
- **API client** — Arabic decoded correctly from a response with no charset,
  non-2xx and unreachable-server errors, JSON on POST
- **onboarding controller** — a career is required, courses toggle, courses are
  sent sorted, a blank major is sent as null, a failed save, start-over
- **the full flow, in English and in Arabic** — onboarding to readiness to
  suggestions; right-to-left checked by layout (the warning icon moves to the
  right of its heading), not just by the direction flag; an unreachable
  backend with a working retry; a failed save; start over
- **university and online courses** — each card says whether it counts toward
  the degree, in both languages; the university course comes first; a gap with
  neither is listed, not dropped; a web address stays left to right in Arabic

The widget tests run against fakes shaped like the backend's JSON. To check the
models against the real, running backend instead — the spec's definition-of-done
scenario, Business Analyst with six courses — start the backend and run:

```bash
dart run tool/contract_check.dart
```

## Not verified on a device

This machine has no Android toolchain, no Visual Studio and no Chrome, so the
app has not been launched on a phone, an emulator or a desktop window.
Everything above is verified headlessly — `flutter test`, `flutter analyze`,
and the contract check against the live backend.

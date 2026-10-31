# Career Readiness — Flutter app (Phase 4)

iPhone and Android app over the FastAPI backend in `../backend/`, in English
and Arabic, built in the iOS design language. Two tabs serve two audiences. The student tab has two-step onboarding
(completed courses, then any skills from outside them), a readiness report and
suggested courses. A student can target up to three careers; the readiness
screen then shows them side by side, each with its score and its covered and
missing counts, and marks the one they are closest to. The department tab has the curriculum-gap view: the course
catalog against what the job postings ask for.

Choosing completed courses is built for a real catalog:
- **Search** filters as you type, by code or title. Digits typed on an Arabic
  keyboard find codes too.
- **"Select all shown"** ticks every course a search leaves on screen.
- **The catalog's own tracks** — college requirements, IS core and the elective
  tracks — appear as collapsible sections, each with its selected count.
- **Level shortcuts** such as "all 200-level and below" tick a level and
  everything under it.
- **A selected count stays in view,** with review and clear (and undo) before
  moving on.

This is presentation only: a course's skills come from the same labels as
before.

**The profile is saved on the device,** with `shared_preferences`: careers,
courses, self-reported skills, major, and the language. The first launch shows
onboarding; every later launch opens straight on the home screen. Settings,
reached from home, edits the profile, switches language, or deletes the
profile after asking. Nothing about the student is stored on a server: each
request carries the profile, and the backend keeps nothing.

**Home.** Once a profile is saved, the student tab opens on a dashboard. It shows
readiness for the main career, with the plan's projection beside it, and the
three most-demanded gaps. The quality flag appears in short form. The dashboard
leads on to planning, the full readiness view, and settings. Onboarding runs
only while no profile is saved.

**What-if planning.** On the planning screen, reached from home or readiness, a student
ticks courses they plan to take. Each course not yet taken lists the gaps it
would close. The projection — the same readiness reading, with the planned
courses counted as taken — stands beside today's figure there and on the
readiness screen. The plan is saved with the profile.

## Design

The app is drawn with Flutter's Cupertino widgets, so it looks and behaves like
an iPhone app — on Android too, as one design to maintain:

- **iOS structure.** A tab bar for the two audiences, each tab with its own
  navigation stack; large collapsing titles on each tab's first screen; the back
  chevron and swipe-back on the screens pushed over it; grouped lists as in
  Settings; the course review as a sheet; deleting the profile confirmed by an
  action sheet; short messages ("Selection cleared. Undo") as a toast from the
  top of the screen.
- **Dark mode and Increase Contrast** follow the phone. Every colour is a light
  and dark pair (`lib/core/theme/app_theme.dart`).
- **Colour carries one meaning each.** Teal is the student: readiness, what they
  hold, the actions. Indigo is the job market: how often postings ask for a
  skill. Orange is a caveat about the figures. Green is degree credit and a gain.
- **The readiness ring** is the one signature element: readiness held now in
  solid teal, and what the planned courses would add in a paler teal running on
  from it. It fills once when it appears, and is simply drawn when Reduce Motion
  is on.
- **Type** is Apple's iOS ramp in the system face (SF Pro, and SF Arabic for
  Arabic, on an iPhone). Arabic is set without letter-spacing, which would pull
  joined letters apart.

The shared pieces — page, grouped section, rows, check circles, pills, tags,
notice cards, buttons, toast, ring, bars — live in `lib/core/widgets/`; screens
compose them rather than styling widgets one by one.

## What the numbers are — read this first

The skill matcher behind every figure **failed its Phase 0 validation gate**:
best F1 0.503 against a 0.60 floor. The app says so on the readiness and the
suggestions screens, in the student's language and with the real numbers,
built from the `validation` block the API attaches to every response.
Suggested courses are labelled as suggestions, not verdicts — it is the first
thing on that screen. University and online courses are shown apart, and every
card says whether it counts toward the degree: a university course does, an
online course does not. Online courses appear only for skills no university
course teaches, and each opens in the browser in one tap.

Skills a student reports from outside coursework are shown apart from those
their courses teach. Whenever the two figures differ, readiness from the courses
alone appears beside the combined figure. The skills step says once, briefly,
that these skills are self-reported and unverified.

The department view opens with its own caveat, using the real posting counts:
82 postings across eight careers since 2026-09-14, 10 or 11 per career. At that size its gaps are
indicative, and they
should not drive curriculum decisions on their own. The quality flag follows,
because the demand side comes from the same matcher. The coverage card states
how many of a career's postings a skill needs to count: two, at 10 or 11
postings. Skills named by fewer are listed in their own section rather than
dropped.

## Run

Start the backend from the repo root, with the project virtualenv active:

```bash
python -m uvicorn backend.main:app --port 8000
```

Then, from `app/`:

```bash
flutter run
```

Without being told, the app looks for the backend on port 8000 of the machine
running it: `http://10.0.2.2:8000` from the Android emulator, which is how the
emulator sees its host, and `http://127.0.0.1:8000` from the iOS simulator. For a physical phone, point it at your machine's
address on the local network:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.20:8000
```

The backend must then listen beyond the host itself: start it with
`--host 0.0.0.0`. That opens it to the whole local network, so do it only on a
network you trust.

On Android, debug builds allow plain HTTP so they can reach the local
backend; release builds keep Android's default and require HTTPS. On an iPhone,
App Transport Security does not cover connections to an IP address, so the
address above works as it is; `Info.plist` also allows `.local` host names, and
says why the app asks for local network access the first time it connects.

### On an iPhone

Building for iOS needs a Mac with Xcode; it cannot be done from Windows.

- **Simulator:** start the backend on the Mac, then `flutter run` and pick the
  simulator. It reaches the backend at `127.0.0.1`.
- **Your own iPhone:** connect it to the Mac, sign the app in Xcode with your
  Apple ID (`open ios/Runner.xcworkspace`, then Signing & Capabilities), and run
  with the Mac's address as shown above. The phone asks once for permission to
  use the local network; allow it.
- **Without a Mac:** a cloud build service with macOS machines can produce the
  iOS build; installing it on a phone then goes through TestFlight, which needs
  an Apple Developer account.

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
  main.dart, app.dart   the Cupertino app: theme, locale, the two tabs
  home_shell.dart       the tab bar, student and department, each with its own navigation stack
  core/                 api client, locale, formatting, opening links
    theme/              colours (light and dark), type ramp, radii
    widgets/            the shared iOS pieces every screen is built from
  features/
    onboarding/         careers, course catalog and skill taxonomy; the two onboarding steps
    home/               the dashboard a saved profile opens on
    profile/            the student profile, saved on the device
    planning/           what-if planning: the gaps each planned course closes
    settings/           edit the profile, language, delete
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

Switch language in Settings, or from the navigation bar during onboarding and
in the department view; the whole app flips to right-to-left through
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

67 tests, no device needed:

- **models** — parsing backend-shaped JSON (snake_case keys, the failed gate,
  a readiness of exactly 0), the gap's two sources kept apart, skill names by
  language, the skills each course teaches, the draft's wire format,
  suggestions by source, and an unknown source rejected rather than guessed
- **API client** — Arabic decoded correctly from a response with no charset,
  non-2xx and unreachable-server errors, JSON on POST
- **onboarding controller** — a career is required, courses and skills toggle,
  nothing is ticked to start. Finishing saves the profile on the device with
  its lists sorted and a blank major as none. A failed save keeps the draft.
  Editing opens the saved profile and replaces it
- **profile store** — a saved profile loads back on the next launch; an
  unreadable one means onboarding again rather than a crash; deleting the
  profile keeps the language
- **persistence and settings** — a saved profile skips onboarding, settings
  edits it and deletes it after asking, and the language is remembered across
  launches
- **home** — a saved profile opens on the dashboard: the main career's
  readiness, the top three gaps in demand order with the fourth left to the full
  view, the short quality flag, and entry points that open planning, the full
  readiness view and settings. In Arabic the layout runs right to left
- **planning** — a course closes the current gaps it teaches, in demand order,
  and a gap two planned courses close counts once. Planning saves at once, and
  an edit keeps the plan, less any course now completed. The planning screen
  hides completed courses, shows what each course closes, and puts the
  projection beside today's figure, on readiness too. In Arabic the layout runs
  right to left
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
- **course groups** — tracks in degree order with unknown ones kept last,
  courses by level then code, search by code or title ignoring case, spacing
  and digit script, levels read from the code, and per-track counts over the
  whole catalog
- **course selection** — the list grouped by track with counts, search that
  hides empty tracks, "select all shown", a level shortcut that adds without
  removing, folding a track, and the review sheet with removal. Clearing is
  undoable. In Arabic: track names, right-to-left layout, and a search typed in
  Arabic-Indic digits
- **several careers** — up to three, in the order chosen, a fourth refused; the
  first is sent as the main career and the rest to compare. The comparison puts
  each score side by side with its covered and missing counts and posting
  count, marks the closest career, and shows the courses-only figure where
  self-reported skills lift a score. Tapping a career switches the details and
  the suggestions to it. In Arabic on a 360-wide phone, three columns lay out
  right to left without overflowing
- **a profile that outlived the catalog** — the screens read the profile as the
  backend serves it: a dropped course, skill or planned course stops counting,
  a dropped main career gives way to the next, and editing starts without them.
  A profile with no career left says how to fix it, without a pointless retry. Two quick taps on the plan both count, and a
  failed write puts the plan back
- **large text** — in Arabic at twice the text size on a 360-wide phone,
  onboarding, home, planning, readiness, suggestions and the department view
  all lay out without overflowing
- **the department view** — its own tab, fetched only when opened, with no step
  of the student flow behind it; switching tabs keeps the student where they
  were. The sample-size caveat, with the real counts, comes above every figure.
  Uncovered skills are ranked by demand, with the careers asking. Coverage is
  shown for the scope and for each career. The threshold in postings is stated,
  and the skills below it are listed after the uncovered ones. One career can be
  chosen. Arabic and
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

The iOS design has been checked by rendering every screen at iPhone size, in
English and Arabic, light and dark, but not on an iPhone or the iOS simulator:
that needs a Mac.

**A black screen on the emulator is the emulator image, not the app.** On
the Android 17 preview image with 16 KB pages (`sdk_gphone16k_x86_64`), the
app starts, fetches its data and builds its whole widget tree, and Flutter
reports the first frame rasterized, yet the screen stays black. It stays black
under Impeller and Skia, through a SurfaceView and a TextureView, and with
software rendering. The stock `flutter create` counter app is black on the same
image too. Use a standard API 35 or 36 x86_64 image with 4 KB pages. Everything above is verified headlessly: `flutter test`,
`flutter analyze`, and the contract check against the live backend.

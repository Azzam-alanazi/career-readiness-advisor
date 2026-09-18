import 'package:career_readiness/app.dart';
import 'package:career_readiness/core/api/api_client.dart';
import 'package:career_readiness/core/links.dart';
import 'package:career_readiness/core/widgets/quality_banner.dart';
import 'package:career_readiness/features/curriculum/data/curriculum_repository.dart';
import 'package:career_readiness/features/curriculum/presentation/curriculum_screen.dart';
import 'package:career_readiness/features/gap/data/gap_repository.dart';
import 'package:career_readiness/features/gap/presentation/readiness_screen.dart';
import 'package:career_readiness/features/home/presentation/dashboard_screen.dart';
import 'package:career_readiness/features/settings/presentation/settings_screen.dart';
import 'package:career_readiness/features/onboarding/data/catalog_repository.dart';
import 'package:career_readiness/features/onboarding/presentation/onboarding_screen.dart';
import 'package:career_readiness/features/onboarding/presentation/skills_screen.dart';
import 'package:career_readiness/features/planning/presentation/planning_screen.dart';
import 'package:career_readiness/features/gap/domain/gap_query.dart';
import 'package:career_readiness/features/profile/data/profile_store.dart';
import 'package:career_readiness/features/profile/domain/student_profile.dart';
import 'package:career_readiness/features/recommendations/data/recommendations_repository.dart';
import 'package:career_readiness/features/recommendations/presentation/recommendations_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

class _World {
  final catalog = FakeCatalogRepository();
  final store = InMemoryProfileStore();
  final gap = FakeGapRepository();
  final recommendations = FakeRecommendationsRepository();
  final curriculum = FakeCurriculumRepository();

  /// Links the app asked the browser to open, and whether the browser obliges.
  final opened = <String>[];
  var browserAccepts = true;
}

Future<void> _pumpApp(WidgetTester tester, _World w) async {
  // Tall enough that every list item is laid out without scrolling.
  tester.view.physicalSize = const Size(1200, 3200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(ProviderScope(
    retry: noAutomaticRetry, // the same policy main.dart ships with
    overrides: [
      catalogRepositoryProvider.overrideWithValue(w.catalog),
      profileStoreProvider.overrideWithValue(w.store),
      gapRepositoryProvider.overrideWithValue(w.gap),
      recommendationsRepositoryProvider.overrideWithValue(w.recommendations),
      curriculumRepositoryProvider.overrideWithValue(w.curriculum),
      linkOpenerProvider.overrideWithValue((url) async {
        w.opened.add(url);
        return w.browserAccepts;
      }),
    ],
    child: const CareerReadinessApp(),
  ));
  await tester.pumpAndSettle();
}

Finder button(String label) => find.widgetWithText(FilledButton, label);

/// Any Material button by its label -- TextButton.icon is a subclass, which
/// find.widgetWithText's exact type match would miss.
ButtonStyleButton anyButton(WidgetTester tester, String label) =>
    tester.widget<ButtonStyleButton>(find
        .ancestor(of: find.text(label), matching: find.byWidgetPredicate((w) => w is ButtonStyleButton))
        .first);

Finder skillBoxes() => find.descendant(
    of: find.byType(SkillsScreen), matching: find.byType(CheckboxListTile));

CheckboxListTile skillBox(WidgetTester tester, String name) =>
    tester.widget<CheckboxListTile>(find.widgetWithText(CheckboxListTile, name));

const unverified =
    'These are self-reported and unverified. Your readiness shows them apart from your courses.';

void main() {
  testWidgets('English: courses, other skills, readiness, then suggestions', (tester) async {
    final w = _World();
    await _pumpApp(tester, w);

    expect(find.text('Your profile'), findsOneWidget);
    expect(tester.widget<FilledButton>(button('Next: other skills')).onPressed, isNull,
        reason: 'no career chosen yet');

    await tester.enterText(find.byType(TextFormField), '  Information Systems ');
    await tester.tap(find.text('Business Analyst'));
    await tester.tap(find.text('Systems Analysis and Design'));
    await tester.tap(find.text('Database Management Systems'));
    await tester.pump();
    expect(find.text('Completed courses (2 selected)'), findsOneWidget);

    await tester.tap(button('Next: other skills'));
    await tester.pumpAndSettle();

    // The skills step: optional, grouped by category, nothing ticked, and the
    // unverified note said once.
    expect(find.text('Other skills'), findsOneWidget);
    expect(find.text(unverified), findsOneWidget);
    expect(find.text('Business analysis and delivery'), findsOneWidget);
    expect(find.text('Professional skills'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Business analysis and delivery')).dy,
        lessThan(tester.getTopLeft(find.text('Professional skills')).dy));
    expect(find.text('Selected: 0'), findsOneWidget);
    expect(tester.widgetList<CheckboxListTile>(skillBoxes()).map((b) => b.value),
        everyElement(isFalse));

    // What the two courses teach is marked, not offered again.
    expect(find.text('From your courses'), findsNWidgets(3));
    expect(find.widgetWithText(CheckboxListTile, 'SQL'), findsNothing);
    expect(skillBoxes(), findsNWidgets(4));
    await tester.tap(find.text('SQL'));
    await tester.pump();
    expect(find.text('Selected: 0'), findsOneWidget, reason: 'a course skill cannot be ticked');

    // Search narrows the list, in place.
    await tester.enterText(find.byKey(const Key('skill-search')), 'zzz');
    await tester.pump();
    expect(find.text('No skill matches your search.'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('skill-search')), 'commun');
    await tester.pump();
    expect(find.text('SQL'), findsNothing);
    expect(find.text('Data and analytics'), findsNothing);
    expect(find.text('Professional skills'), findsOneWidget);

    await tester.tap(find.text('Communication'));
    await tester.pump();
    expect(skillBox(tester, 'Communication').value, isTrue);
    expect(find.text('Selected: 1'), findsOneWidget);

    await tester.tap(button('See my readiness'));
    await tester.pumpAndSettle();

    // Saved on the device, and read by sending that profile with the request.
    expect(
        w.store.profile,
        const StudentProfile(
          careers: ['Business Analyst'],
          completedCourses: ['IS 230', 'IS 240'],
          selfReportedSkills: ['SK85'],
          major: 'Information Systems',
        ));
    expect(w.gap.queries, [
      const GapQuery(
        career: 'Business Analyst',
        completedCourses: ['IS 230', 'IS 240'],
        selfReportedSkills: ['SK85'],
      ),
    ]);
    // Home is now the student tab's first screen, not a step to go back from.
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);
    await tester.tap(find.text('Full readiness'));
    await tester.pumpAndSettle();

    // Readiness: the combined score, the courses-only reading, and where each
    // covered skill came from.
    expect(find.text('Readiness for Business Analyst'), findsOneWidget);
    expect(find.text('10%'), findsOneWidget);
    expect(find.text('From your courses alone: 5%'), findsOneWidget);
    expect(find.text('Skills you have (2)'), findsOneWidget);
    expect(find.text('From your courses (1)'), findsOneWidget);
    expect(find.text('Self-reported (1)'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Requirements elicitation')).dy,
        lessThan(tester.getTopLeft(find.text('Self-reported (1)')).dy));
    expect(tester.getTopLeft(find.text('Self-reported (1)')).dy,
        lessThan(tester.getTopLeft(find.text('Communication')).dy));
    expect(find.text(unverified), findsNothing, reason: 'said once, on the skills step');

    // Missing skills by demand.
    expect(find.text('in 83% of postings'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Functional specifications')).dy,
        lessThan(tester.getTopLeft(find.text('Business process modelling')).dy));

    // The quality flag, with the real numbers, and the icon on the left.
    const flag = 'Estimates, not validated results';
    expect(find.text(flag), findsOneWidget);
    expect(find.textContaining('scored F1 0.503, below the 0.6'), findsOneWidget);
    expect(find.textContaining('English-language job postings'), findsOneWidget);
    expect(tester.getCenter(find.byIcon(Icons.warning_amber_rounded)).dx,
        lessThan(tester.getCenter(find.text(flag)).dx));

    await tester.tap(find.text('Suggested courses'));
    await tester.pumpAndSettle();

    expect(find.text('Suggestions, not verdicts'), findsOneWidget);
    expect(find.text('Business Process Management'), findsOneWidget);
    expect(find.text('Business process modelling · in 50% of postings'), findsOneWidget);
    expect(find.text(flag), findsOneWidget);
    // The "suggestions, not verdicts" notice sits above the courses it qualifies.
    expect(tester.getTopLeft(find.text('Suggestions, not verdicts')).dy,
        lessThan(tester.getTopLeft(find.text('Business Process Management')).dy));

    // University and online courses are told apart, section and card alike.
    expect(find.text('University courses (1)'), findsOneWidget);
    expect(find.text('Online courses (1)'), findsOneWidget);
    expect(find.text('Counts toward your degree'), findsOneWidget);
    expect(find.text("Doesn't count toward your degree"), findsOneWidget);
    expect(find.text('Writing functional specifications'), findsOneWidget);
    expect(find.text('Example Academy'), findsOneWidget);
    expect(find.text('Free'), findsOneWidget);
    expect(find.text('Functional specifications · in 83% of postings'), findsOneWidget);
    // The university course, which counts toward the degree, comes first.
    expect(tester.getTopLeft(find.text('Business Process Management')).dy,
        lessThan(tester.getTopLeft(find.text('Writing functional specifications')).dy));
    // A gap with neither is listed, not dropped.
    expect(find.text('No course listed yet (1)'), findsOneWidget);
    expect(find.text('Workshop facilitation · in 33% of postings'), findsOneWidget);
  });

  testWidgets('A skill a newly chosen course teaches is marked, and a tick survives',
      (tester) async {
    final w = _World();
    await _pumpApp(tester, w);

    await tester.tap(find.text('Business Analyst'));
    await tester.pump();
    await tester.tap(button('Next: other skills'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Business process modelling'));
    await tester.pump();
    expect(find.text('Selected: 1'), findsOneWidget);

    // Back to the courses: IS 350 teaches that skill.
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Business Process Management'));
    await tester.tap(button('Next: other skills'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(CheckboxListTile, 'Business process modelling'), findsNothing);
    expect(find.text('From your courses'), findsOneWidget);
    expect(find.text('Selected: 0'), findsOneWidget);

    // Drop the course again and the student's own tick is still there.
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Business Process Management'));
    await tester.tap(button('Next: other skills'));
    await tester.pumpAndSettle();
    expect(skillBox(tester, 'Business process modelling').value, isTrue);
    expect(find.text('Selected: 1'), findsOneWidget);
  });

  testWidgets('Arabic: right-to-left layout, Arabic labels, caveats in Arabic', (tester) async {
    final w = _World();
    await _pumpApp(tester, w);

    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle();

    expect(Directionality.of(tester.element(find.byType(OnboardingScreen))), TextDirection.rtl);
    expect(find.text('ملفك الشخصي'), findsOneWidget);
    expect(find.text('محلل أعمال'), findsOneWidget);
    // Course names stay as the catalog lists them, and the screen says so.
    expect(find.text('Systems Analysis and Design'), findsOneWidget);
    expect(find.text('مدرجة كما وردت في دليل المقررات (بالإنجليزية).'), findsOneWidget);

    await tester.tap(find.text('محلل أعمال'));
    await tester.pump();
    await tester.tap(button('التالي: مهارات أخرى'));
    await tester.pumpAndSettle();

    // The skills step, in Arabic: category headers and skill names alike.
    expect(Directionality.of(tester.element(find.byType(SkillsScreen))), TextDirection.rtl);
    expect(find.text('مهارات أخرى'), findsOneWidget);
    expect(find.text('تحليل الأعمال والتنفيذ'), findsOneWidget);
    expect(find.text('مهارات التواصل'), findsOneWidget);
    expect(find.text('Communication'), findsNothing);
    expect(find.textContaining('لا يُتحقق منها'), findsOneWidget);

    await tester.tap(button('اعرض جاهزيتي'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('الجاهزية الكاملة'));
    await tester.pumpAndSettle();

    expect(Directionality.of(tester.element(find.byType(ReadinessScreen))), TextDirection.rtl);
    expect(find.text('الجاهزية لمهنة محلل أعمال'), findsOneWidget);
    expect(find.text('المواصفات الوظيفية'), findsOneWidget);
    expect(find.text('Functional specifications'), findsNothing);
    expect(find.text('من مقرراتك (1)'), findsOneWidget);
    expect(find.text('ذكرتها بنفسك (1)'), findsOneWidget);
    expect(find.textContaining('من مقرراتك وحدها'), findsOneWidget);

    // Right-to-left is real layout, not just a flag: the warning icon now sits
    // to the right of the heading it introduces.
    const flag = 'تقديرات، وليست نتائج موثّقة';
    expect(find.text(flag), findsOneWidget);
    expect(tester.getCenter(find.byIcon(Icons.warning_amber_rounded)).dx,
        greaterThan(tester.getCenter(find.text(flag)).dx));

    await tester.tap(find.text('المقررات المقترحة'));
    await tester.pumpAndSettle();
    expect(find.text('اقتراحات، لا أحكام'), findsOneWidget);
    expect(find.text('يُحتسب ضمن متطلبات التخرج'), findsOneWidget);
    expect(find.text('لا تُحتسب ضمن متطلبات التخرج'), findsOneWidget);
    expect(find.text('مجانية'), findsOneWidget);
    // The web address stays left to right inside the right-to-left page.
    final url = find.byWidgetPredicate(
        (w) => w is SelectableText && w.data == 'https://example.com/functional-specs');
    expect(Directionality.of(tester.element(url)), TextDirection.ltr);
  });

  testWidgets('An unreachable backend offers a retry that recovers', (tester) async {
    final w = _World()..catalog.failWith = const ApiException('connection refused');
    await _pumpApp(tester, w);

    expect(find.text("Can't reach the server. Is the backend running?"), findsOneWidget);

    w.catalog.failWith = null;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Business Analyst'), findsOneWidget);
  });

  testWidgets('A failed save keeps the student on the skills step and says so', (tester) async {
    final w = _World()..store.failWith = StateError('disk full');
    await _pumpApp(tester, w);

    await tester.tap(find.text('Business Analyst'));
    await tester.pump();
    await tester.tap(button('Next: other skills'));
    await tester.pumpAndSettle();
    await tester.tap(button('See my readiness'));
    await tester.pumpAndSettle();

    expect(find.byType(ReadinessScreen), findsNothing);
    expect(find.byType(SkillsScreen), findsOneWidget);
    expect(find.text('Your profile could not be saved on this device. Try again.'),
        findsOneWidget);
  });

  testWidgets('A saved profile opens straight on home; settings edits it and deletes it',
      (tester) async {
    final w = _World()
      ..store.profile = const StudentProfile(
        careers: ['Business Analyst'],
        completedCourses: ['IS 230'],
        major: 'Information Systems',
      );
    await _pumpApp(tester, w);

    // The next launch: no onboarding, home with the saved profile read at once.
    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text('Readiness for Business Analyst'), findsOneWidget);
    expect(w.gap.queries.single,
        const GapQuery(career: 'Business Analyst', completedCourses: ['IS 230']));

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Business Analyst'), findsOneWidget);
    expect(find.text('Information Systems'), findsOneWidget);
    expect(find.text('1 completed course'), findsOneWidget);
    expect(find.text('No self-reported skills'), findsOneWidget);
    expect(find.textContaining('saved on this device only'), findsOneWidget);

    // The language can be set here too, and it is remembered.
    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle();
    expect(find.text('الإعدادات'), findsOneWidget);
    expect(w.store.lang, 'ar');
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(w.store.lang, 'en');

    // Edit: the form opens holding the saved profile.
    await tester.tap(find.text('Edit profile'));
    await tester.pumpAndSettle();
    expect(find.text('Edit your profile'), findsOneWidget);
    expect(find.text('Information Systems'), findsOneWidget);
    expect(
        tester
            .widget<CheckboxListTile>(
                find.widgetWithText(CheckboxListTile, 'Database Management Systems'))
            .value,
        isTrue);
    await tester.tap(find.text('Systems Analysis and Design'));
    await tester.tap(button('Next: other skills'));
    await tester.pumpAndSettle();
    await tester.tap(button('Save changes'));
    await tester.pumpAndSettle();

    expect(w.store.profile!.completedCourses, ['IS 230', 'IS 240']);
    expect(w.store.profile!.major, 'Information Systems');
    expect(find.text('Readiness for Business Analyst'), findsOneWidget);
    expect(find.byType(BackButton), findsNothing, reason: 'back home, not deeper in');
    expect(w.gap.queries.last.completedCourses, ['IS 230', 'IS 240']);

    // Delete: asked first; cancelling keeps everything.
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete profile'));
    await tester.pumpAndSettle();
    expect(find.text('Delete your profile?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(w.store.profile, isNotNull);

    await tester.tap(find.text('Delete profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(w.store.profile, isNull);
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('Information Systems'), findsNothing, reason: 'the form starts blank');
    expect(tester.widget<FilledButton>(button('Next: other skills')).onPressed, isNull);
  });

  testWidgets('Planning: tick a course, see the gaps it closes and the projection beside today',
      (tester) async {
    final w = _World()
      ..store.profile = const StudentProfile(
        careers: ['Business Analyst'],
        completedCourses: ['IS 230'],
      );
    await _pumpApp(tester, w);

    await tester.tap(find.text('Plan courses'));
    await tester.pumpAndSettle();
    expect(find.byType(PlanningScreen), findsOneWidget);
    expect(find.text('Tick courses below to see what they would add.'), findsOneWidget);

    // Completed courses are not offered; each other course says what it closes.
    expect(find.widgetWithText(CheckboxListTile, 'Database Management Systems'), findsNothing);
    expect(find.text('Closes: Business process modelling (in 50% of postings)'), findsOneWidget);
    expect(find.text('Closes none of your current gaps for this career.'), findsNWidgets(3));

    await tester.tap(find.text('Business Process Management'));
    await tester.pumpAndSettle();
    expect(w.store.profile!.plannedCourses, ['IS 350']);
    // The projection is the same reading with the plan counted as taken.
    expect(w.gap.queries.last,
        const GapQuery(career: 'Business Analyst', completedCourses: ['IS 230', 'IS 350']));
    expect(find.text('10%'), findsOneWidget);
    expect(find.text('26%'), findsOneWidget);
    expect(find.text('now'), findsOneWidget);
    expect(find.text('if you take your planned course'), findsOneWidget);
    expect(find.text('+16 points'), findsOneWidget);
    expect(find.text('Your plan closes 1 of your 3 gaps.'), findsOneWidget);

    // Back home: now and projected side by side there too.
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('if you take your planned course'), findsOneWidget);
    expect(tester.getTopLeft(find.text('10%')).dy, tester.getTopLeft(find.text('26%')).dy);
    expect(tester.getTopLeft(find.text('10%')).dx,
        lessThan(tester.getTopLeft(find.text('26%')).dx));

    // Taking it off the plan takes the projection away.
    await tester.tap(find.text('Plan courses'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Business Process Management'));
    await tester.pumpAndSettle();
    expect(w.store.profile!.plannedCourses, isEmpty);
    expect(find.text('26%'), findsNothing);
  });

  testWidgets('Planning in Arabic: right to left, with what each course closes', (tester) async {
    final w = _World()
      ..store.profile = const StudentProfile(
        careers: ['Business Analyst'],
        completedCourses: ['IS 230'],
        plannedCourses: ['IS 350'],
      )
      ..store.lang = 'ar';
    await _pumpApp(tester, w);

    // The projection is on home already, beside today's figure.
    expect(find.text('إذا أخذت المقرر الذي خططت له'), findsOneWidget);
    await tester.tap(find.text('خطط لمقرراتك'));
    await tester.pumpAndSettle();

    expect(Directionality.of(tester.element(find.byType(PlanningScreen))), TextDirection.rtl);
    expect(find.textContaining('يسد: نمذجة عمليات الأعمال'), findsOneWidget);
    expect(find.text('+16 نقطة'), findsOneWidget);
    // Right to left: today's figure on the right, the projection to its left.
    expect(tester.getTopLeft(find.text('الآن')).dx,
        greaterThan(tester.getTopLeft(find.text('إذا أخذت المقرر الذي خططت له')).dx));
  });

  testWidgets('Home: readiness for the main career, the top three gaps, and the ways on',
      (tester) async {
    final w = _World()
      ..store.profile = const StudentProfile(
        careers: ['Data Analyst', 'Business Analyst'],
        completedCourses: ['IS 230'],
      );
    await _pumpApp(tester, w);

    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    // The main career only: the comparison lives on the full view.
    expect(find.text('Readiness for Data Analyst'), findsOneWidget);
    expect(find.text('20%'), findsOneWidget);
    expect(w.gap.careers, ['Data Analyst']);
    expect(find.text('Your careers side by side'), findsNothing);

    // The quality flag, short: its headline and the failed gate.
    expect(find.text('Estimates, not validated results'), findsOneWidget);
    expect(find.textContaining('scored F1 0.503'), findsOneWidget);
    expect(find.textContaining('English-language job postings'), findsNothing);

    // The three most-demanded gaps, in order; the fourth waits for the full view.
    expect(find.text('Your top gaps'), findsOneWidget);
    const top = ['Python programming', 'SQL', 'Data modelling'];
    for (var i = 1; i < top.length; i++) {
      expect(tester.getTopLeft(find.text(top[i - 1])).dy,
          lessThan(tester.getTopLeft(find.text(top[i])).dy));
    }
    expect(find.text('JavaScript'), findsNothing);
    expect(find.text('No planned courses'), findsOneWidget);

    // The ways on.
    await tester.tap(find.text('Full readiness'));
    await tester.pumpAndSettle();
    expect(find.byType(ReadinessScreen), findsOneWidget);
    expect(find.text('Your careers side by side'), findsOneWidget);
    expect(find.text('JavaScript'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Plan courses'));
    await tester.pumpAndSettle();
    expect(find.byType(PlanningScreen), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, 'Settings'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
  });

  testWidgets('Home in Arabic: right to left', (tester) async {
    final w = _World()
      ..store.profile = const StudentProfile(
        careers: ['Business Analyst'],
        completedCourses: ['IS 230'],
      )
      ..store.lang = 'ar';
    await _pumpApp(tester, w);

    expect(Directionality.of(tester.element(find.byType(DashboardScreen))), TextDirection.rtl);
    expect(find.text('الرئيسية'), findsOneWidget);
    expect(find.text('أبرز فجواتك'), findsOneWidget);
    expect(find.text('المواصفات الوظيفية'), findsOneWidget);
    expect(find.text('Functional specifications'), findsNothing);
    // Right to left by layout: each way on has its icon on the right.
    const full = 'الجاهزية الكاملة';
    final entry = find.widgetWithText(ListTile, full);
    expect(
        tester.getCenter(find.descendant(of: entry, matching: find.byIcon(Icons.insights_outlined))).dx,
        greaterThan(tester.getCenter(find.text(full)).dx));
  });

  testWidgets('The language chosen is remembered for the next launch', (tester) async {
    final w = _World();
    await _pumpApp(tester, w);
    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle();
    expect(w.store.lang, 'ar');

    // Close the app, then open it again on the same device.
    await tester.pumpWidget(const SizedBox());
    await _pumpApp(tester, w);
    expect(find.text('ملفك الشخصي'), findsOneWidget);
    expect(Directionality.of(tester.element(find.byType(OnboardingScreen))), TextDirection.rtl);
  });

  testWidgets('Department: its own tab, the sample caveat first, gaps ranked by demand',
      (tester) async {
    final w = _World();
    await _pumpApp(tester, w);
    expect(w.curriculum.requested, isEmpty, reason: 'nothing is fetched until the tab opens');

    await tester.tap(find.text('Department'));
    await tester.pumpAndSettle();

    expect(find.byType(CurriculumScreen), findsOneWidget);
    expect(find.text('Curriculum gaps'), findsOneWidget);
    expect(w.curriculum.requested, [null]);

    // The sample-size caveat, with the real counts, above every figure.
    const caveat = 'Indicative only: 16 job postings';
    expect(find.text(caveat), findsOneWidget);
    expect(find.textContaining('16 job postings, 5 to 6 per career'), findsOneWidget);
    expect(find.textContaining('not as grounds on its own for changing the curriculum'),
        findsOneWidget);
    expect(tester.getTopLeft(find.text(caveat)).dy,
        lessThan(tester.getTopLeft(find.text('43%')).dy));
    expect(find.text('Estimates, not validated results'), findsOneWidget);

    // Coverage for every career together, counted in skills.
    expect(find.text('Coverage: All careers'), findsOneWidget);
    expect(find.text('43%'), findsOneWidget);
    expect(
        find.text('3 of the 7 skills that 11 job postings ask for '
            'are taught by at least one course.'),
        findsOneWidget);

    // What no course teaches, most in demand first, with the careers asking.
    expect(find.text('Asked for, not taught (4)'), findsOneWidget);
    const ranked = [
      'Functional specifications',
      'Python programming',
      'Workshop facilitation',
      'JavaScript',
    ];
    for (var i = 1; i < ranked.length; i++) {
      expect(tester.getTopLeft(find.text(ranked[i - 1])).dy,
          lessThan(tester.getTopLeft(find.text(ranked[i])).dy));
    }
    expect(find.text('in 45% of postings'), findsOneWidget);
    expect(find.text('Asked for in: Business Analyst'), findsNWidgets(2));
    expect(find.text('Asked for in: Software Developer'), findsNWidgets(2));

    // Coverage per career, and what is taught that no posting asks for.
    expect(find.text('2 of 4 demanded skills taught · 6 job postings'), findsOneWidget);
    expect(find.text('1 of 3 demanded skills taught · 5 job postings'), findsOneWidget);
    expect(find.text('33%'), findsOneWidget);
    expect(find.text('Taught, not asked for (1)'), findsOneWidget);
    expect(find.text('Network administration'), findsOneWidget);
    expect(find.text('Taught in: CIT 201 · CIT 202'), findsOneWidget);

    // What the threshold leaves out is on the screen, not silently dropped:
    // stated on the coverage card, then listed after the uncovered skills.
    expect(find.textContaining("named in at least 2 of a career's postings"), findsOneWidget);
    expect(find.textContaining('2 named by fewer are left out'), findsOneWidget);
    const below = 'Named, but below the threshold (2)';
    expect(find.text(below), findsOneWidget);
    expect(find.text('Data quality management'), findsOneWidget);
    expect(find.text('Taught in no course'), findsOneWidget);
    expect(find.text('Taught in: CIT 201 · CIS 302'), findsOneWidget);
    expect(tester.getTopLeft(find.text('JavaScript')).dy,
        lessThan(tester.getTopLeft(find.text(below)).dy));
    expect(tester.getTopLeft(find.text(below)).dy,
        lessThan(tester.getTopLeft(find.text('Coverage by career')).dy));

    // One career.
    await tester.tap(find.widgetWithText(ChoiceChip, 'Business Analyst'));
    await tester.pumpAndSettle();
    expect(w.curriculum.requested, [null, 'Business Analyst']);
    expect(find.text('Coverage: Business Analyst'), findsOneWidget);
    expect(find.text('50%'), findsNWidgets(2), reason: 'the card and the career row');
    expect(find.text('Asked for, not taught (2)'), findsOneWidget);
    expect(find.text('in 83% of postings'), findsOneWidget);
    expect(find.textContaining('Asked for in:'), findsNothing,
        reason: 'with one career chosen, which career asks goes without saying');
    expect(find.text('Taught in: IS 230'), findsOneWidget);
    expect(find.text('Named, but below the threshold (1)'), findsOneWidget);
    expect(find.textContaining('1 named by fewer are left out'), findsOneWidget);
    expect(find.text(caveat), findsOneWidget, reason: 'the caveat stays for every scope');
  });

  testWidgets('The department tab is apart from onboarding, and each keeps its place',
      (tester) async {
    final w = _World();
    await _pumpApp(tester, w);

    await tester.tap(find.text('Business Analyst'));
    await tester.pump();
    await tester.tap(button('Next: other skills'));
    await tester.pumpAndSettle();
    expect(find.byType(SkillsScreen), findsOneWidget);

    await tester.tap(find.text('Department'));
    await tester.pumpAndSettle();
    expect(find.byType(CurriculumScreen), findsOneWidget);
    expect(find.byType(SkillsScreen), findsNothing);
    expect(find.byType(BackButton), findsNothing, reason: 'not a step in the student flow');

    await tester.tap(find.text('Student'));
    await tester.pumpAndSettle();
    expect(find.byType(SkillsScreen), findsOneWidget, reason: 'the student is where they left off');
    expect(find.byType(CurriculumScreen), findsNothing);
  });

  testWidgets('Department, in Arabic: right to left, the caveat and the gaps in Arabic',
      (tester) async {
    final w = _World();
    await _pumpApp(tester, w);

    await tester.tap(find.text('Department'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle();

    expect(Directionality.of(tester.element(find.byType(CurriculumScreen))), TextDirection.rtl);
    expect(find.text('فجوات المنهج'), findsOneWidget);
    expect(find.text('القسم'), findsOneWidget);
    expect(find.text('الطالب'), findsOneWidget);

    const caveat = 'مؤشرات أولية فقط: 16 إعلانًا';
    expect(find.text(caveat), findsOneWidget);
    expect(find.textContaining('لا كسبب كافٍ وحده لتغيير المنهج'), findsOneWidget);
    // Right to left by layout: the caveat's icon sits to the right of its title.
    expect(tester.getCenter(find.byIcon(Icons.poll_outlined)).dx,
        greaterThan(tester.getCenter(find.text(caveat)).dx));

    expect(find.text('جميع المهن'), findsOneWidget);
    expect(find.text('المواصفات الوظيفية'), findsOneWidget);
    expect(find.text('Functional specifications'), findsNothing);
    expect(find.text('مطلوبة في: محلل أعمال'), findsNWidgets(2));
    expect(find.text('6 إعلانات'), findsNothing, reason: 'the count sits inside a sentence');
    expect(find.textContaining('· 6 إعلانات'), findsOneWidget);
    // Course codes stay as the catalog writes them.
    expect(find.text('تُدرَّس في: CIT 201 · CIT 202'), findsOneWidget);
    expect(find.text('مذكورة لكن دون الحد (2)'), findsOneWidget);
    expect(find.text('لا يدرّسها أي مقرر'), findsOneWidget);
    expect(find.textContaining('ما لا يقل عن 2 من إعلانات المهنة'), findsOneWidget);
    expect(find.text('تقديرات، وليست نتائج موثّقة'), findsOneWidget);
  });

  testWidgets('Courses: tracks, search, select all shown, level shortcuts, review and clear',
      (tester) async {
    final w = _World();
    await _pumpApp(tester, w);
    final search = find.byKey(const Key('course-search'));

    // Grouped by the catalog's tracks, in degree order, each with its count.
    const college = 'College requirements', core = 'IS core';
    const electives = 'Electives: business analytics';
    expect(tester.getTopLeft(find.text(college)).dy,
        lessThan(tester.getTopLeft(find.text(core)).dy));
    expect(tester.getTopLeft(find.text(core)).dy,
        lessThan(tester.getTopLeft(find.text(electives)).dy));
    expect(find.text('0 of 1 selected'), findsOneWidget);
    expect(find.text('0 of 2 selected'), findsNWidgets(2));
    expect(find.text('No courses selected'), findsOneWidget);

    // Search filters as you type, by code or title; empty tracks drop away.
    await tester.enterText(search, 'is2');
    await tester.pump();
    expect(find.text('Database Management Systems'), findsOneWidget);
    expect(find.text('Systems Analysis and Design'), findsOneWidget);
    expect(find.text('Business Process Management'), findsNothing);
    expect(find.text(college), findsNothing);

    await tester.enterText(search, 'data');
    await tester.pump();
    expect(find.text('Database Management Systems'), findsOneWidget);
    expect(find.text('Data Mining'), findsOneWidget);
    expect(find.text('Systems Analysis and Design'), findsNothing);

    // One tap selects every course shown.
    await tester.tap(find.text('Select all shown (2)'));
    await tester.pump();
    expect(find.text('Completed courses (2 selected)'), findsOneWidget);
    expect(find.text('2 courses selected'), findsOneWidget);
    expect(anyButton(tester, 'Select all shown (2)').onPressed, isNull,
        reason: 'everything shown is already chosen');

    await tester.enterText(search, 'zzz');
    await tester.pump();
    expect(find.text('No course matches your search.'), findsOneWidget);
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump();
    expect(find.text(college), findsOneWidget);

    // A level shortcut adds its level and below, keeping what was chosen.
    expect(find.text('All 300-level and below'), findsOneWidget);
    await tester.tap(find.text('All 200-level and below'));
    await tester.pump();
    expect(find.text('4 courses selected'), findsOneWidget);
    expect(find.text('1 of 1 selected'), findsOneWidget);
    expect(find.text('2 of 2 selected'), findsOneWidget);
    expect(find.text('1 of 2 selected'), findsOneWidget);

    // Folding a track hides its courses, not its count.
    await tester.tap(find.text(core));
    await tester.pump();
    expect(find.text('Systems Analysis and Design'), findsNothing);
    expect(find.text('2 of 2 selected'), findsOneWidget);
    await tester.tap(find.text(core));
    await tester.pump();
    expect(find.text('Systems Analysis and Design'), findsOneWidget);

    // Review before going on: the chosen courses by track, each removable.
    await tester.tap(find.widgetWithText(TextButton, 'Review'));
    await tester.pumpAndSettle();
    final sheet = find.byType(BottomSheet);
    expect(find.descendant(of: sheet, matching: find.text('Selected courses')), findsOneWidget);
    expect(find.descendant(of: sheet, matching: find.text(core)), findsOneWidget);
    await tester.tap(find.descendant(
        of: find.descendant(of: sheet, matching: find.widgetWithText(ListTile, 'Data Mining')),
        matching: find.byType(IconButton)));
    await tester.pump();
    expect(find.descendant(of: sheet, matching: find.text('Data Mining')), findsNothing);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('3 courses selected'), findsOneWidget);

    // Clearing is one tap, and so is taking it back.
    await tester.tap(find.widgetWithText(TextButton, 'Clear'));
    await tester.pumpAndSettle(); // let the snackbar finish sliding in
    expect(find.text('No courses selected'), findsOneWidget);
    expect(find.text('Selection cleared.'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('3 courses selected'), findsOneWidget);
    expect(find.text('Completed courses (3 selected)'), findsOneWidget);
  });

  testWidgets('Courses in Arabic: tracks in Arabic, right to left, and search takes Arabic digits',
      (tester) async {
    final w = _World();
    await _pumpApp(tester, w);
    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle();
    final search = find.byKey(const Key('course-search'));

    expect(find.text('متطلبات الكلية'), findsOneWidget);
    expect(find.text('المقررات الأساسية للتخصص'), findsOneWidget);
    expect(find.text('مقررات اختيارية: تحليلات الأعمال'), findsOneWidget);
    expect(find.text('كل المستوى 200 وما دونه'), findsOneWidget);
    expect(find.text('لم تختر أي مقرر'), findsOneWidget);
    // Right to left: the search icon sits at the field's right-hand end.
    expect(tester.getCenter(find.descendant(of: search, matching: find.byIcon(Icons.search))).dx,
        greaterThan(tester.getCenter(search).dx));

    // A code typed on an Arabic keyboard, in Arabic-Indic digits.
    await tester.enterText(search, '٢٣٠');
    await tester.pump();
    expect(find.text('Database Management Systems'), findsOneWidget);
    expect(find.text('Systems Analysis and Design'), findsNothing);
    await tester.tap(find.text('اختر كل المعروض (1)'));
    await tester.pump();
    expect(find.text('مقرر واحد مختار'), findsOneWidget);

    // Latin letters still search in the Arabic interface.
    await tester.enterText(search, 'data');
    await tester.pump();
    expect(find.text('Data Mining'), findsOneWidget);
    expect(find.text('Principles of Probabilities and Statistics'), findsNothing);
  });

  testWidgets('Two careers side by side: the closest is marked, and a tap opens its details',
      (tester) async {
    final w = _World();
    await _pumpApp(tester, w);

    await tester.tap(find.text('Business Analyst'));
    await tester.tap(find.text('Software Developer'));
    await tester.pump();
    await tester.tap(button('Next: other skills'));
    await tester.pumpAndSettle();
    await tester.tap(button('See my readiness'));
    await tester.pumpAndSettle();

    expect(w.store.profile!.careers, ['Business Analyst', 'Software Developer']);
    // Home shows the main career; the full view has both side by side.
    expect(find.text('Readiness for Business Analyst'), findsOneWidget);
    expect(find.text('Your careers side by side'), findsNothing);
    await tester.tap(find.text('Full readiness'));
    await tester.pumpAndSettle();
    expect(w.gap.careers.toSet(), {'Business Analyst', 'Software Developer'});

    // Side by side, in the order chosen, each with its score and counts.
    expect(find.text('Your careers side by side'), findsOneWidget);
    final analyst = find.text('Business Analyst');
    final developer = find.text('Software Developer');
    expect(tester.getTopLeft(analyst).dy, tester.getTopLeft(developer).dy);
    expect(tester.getCenter(analyst).dx, lessThan(tester.getCenter(developer).dx));
    Finder column(Finder title) =>
        find.ancestor(of: title, matching: find.byType(Card)).first;
    Finder inColumn(Finder title, String text) =>
        find.descendant(of: column(title), matching: find.text(text));
    expect(inColumn(analyst, '10%'), findsOneWidget);
    expect(inColumn(analyst, 'Covered: 2'), findsOneWidget);
    expect(inColumn(analyst, 'Missing: 3'), findsOneWidget);
    expect(inColumn(analyst, '6 job postings'), findsOneWidget);
    expect(inColumn(analyst, 'Courses alone: 5%'), findsOneWidget,
        reason: 'self-reported skills lift this score, so the record alone is shown too');
    expect(inColumn(developer, '35%'), findsOneWidget);
    expect(inColumn(developer, 'Covered: 3'), findsOneWidget);
    expect(inColumn(developer, 'Missing: 2'), findsOneWidget);
    expect(inColumn(developer, '5 job postings'), findsOneWidget);
    expect(find.textContaining('Closest'), findsOneWidget);
    expect(find.descendant(of: column(developer), matching: find.textContaining('Closest')),
        findsOneWidget);
    expect(find.textContaining('a few points apart is not a real difference'), findsOneWidget);

    // The details below are the first career's until another is tapped.
    expect(find.text('Readiness for Business Analyst'), findsOneWidget);
    await tester.tap(developer);
    await tester.pumpAndSettle();
    expect(find.text('Readiness for Software Developer'), findsOneWidget);
    expect(find.text('Python programming'), findsOneWidget);
    expect(find.text('35%'), findsNWidgets(2), reason: 'the column and the score card');

    // Suggestions follow the career on show.
    await tester.tap(find.text('Suggested courses'));
    await tester.pumpAndSettle();
    expect(w.recommendations.careers, ['Software Developer']);
    expect(find.text('For Software Developer'), findsOneWidget);
  });

  testWidgets('Three careers in Arabic on a phone: right to left, and nothing overflows',
      (tester) async {
    final w = _World();
    await _pumpApp(tester, w);
    // A 360 x 800 phone, where three columns are tightest.
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    await tester.pumpAndSettle();

    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle();
    const chosen = ['محلل أعمال', 'محلل بيانات', 'مطور برمجيات'];
    for (final career in chosen) {
      await tester.tap(find.text(career));
      await tester.pump();
    }
    await tester.tap(button('التالي: مهارات أخرى'));
    await tester.pumpAndSettle();
    await tester.tap(button('اعرض جاهزيتي'));
    await tester.pumpAndSettle();

    expect(w.store.profile!.careers, ['Business Analyst', 'Data Analyst', 'Software Developer']);
    final fullView = find.text('الجاهزية الكاملة');
    await tester.scrollUntilVisible(fullView, 200,
        scrollable: find
            .descendant(of: find.byType(DashboardScreen), matching: find.byType(Scrollable))
            .first);
    await tester.tap(fullView);
    await tester.pumpAndSettle();
    expect(Directionality.of(tester.element(find.byType(ReadinessScreen))), TextDirection.rtl);
    // On a phone in Arabic the quality flag fills the first screen, so the
    // comparison is reached by scrolling -- after the flag, never before it.
    final heading = find.text('مهنك جنبًا إلى جنب');
    expect(find.byType(QualityBanner), findsOneWidget);
    expect(heading, findsNothing, reason: 'below the flag, not yet built');
    await tester.scrollUntilVisible(heading, 200,
        scrollable: find
            .descendant(of: find.byType(ReadinessScreen), matching: find.byType(Scrollable))
            .first);
    await tester.pumpAndSettle();
    expect(heading, findsOneWidget);
    // Right to left: the first chosen stands rightmost.
    final xs = [for (final c in chosen) tester.getCenter(find.text(c)).dx];
    expect(xs[0], greaterThan(xs[1]));
    expect(xs[1], greaterThan(xs[2]));
    expect(find.text('متوفرة: 3'), findsOneWidget);
    expect(find.text('ناقصة: 4'), findsOneWidget);
    expect(find.textContaining('الأقرب'), findsOneWidget);
    expect(find.textContaining('فارق بضع نقاط لا يعني فرقًا حقيقيًا'), findsOneWidget);
  });


  testWidgets('A saved profile naming what the backend has since dropped still opens',
      (tester) async {
    // Saved before a catalog, taxonomy and corpus change: Retired, OLD 101,
    // OLD 202 and SK99 are no longer served, and the backend refuses a request
    // naming any of them.
    final w = _World()
      ..store.profile = const StudentProfile(
        careers: ['Retired', 'Business Analyst'],
        completedCourses: ['IS 230', 'OLD 101'],
        selfReportedSkills: ['SK85', 'SK99'],
        plannedCourses: ['IS 350', 'OLD 202'],
      );
    await _pumpApp(tester, w);

    // The main career is gone, so the next takes its place, as the backend
    // does for a stored profile. Only what is still served is sent, and the
    // plan counts the one planned course that still exists.
    expect(find.text('Readiness for Business Analyst'), findsOneWidget);
    expect(find.text('if you take your planned course'), findsOneWidget);
    expect(w.gap.queries.toSet(), {
      const GapQuery(
          career: 'Business Analyst', completedCourses: ['IS 230'], selfReportedSkills: ['SK85']),
      const GapQuery(
          career: 'Business Analyst',
          completedCourses: ['IS 230', 'IS 350'],
          selfReportedSkills: ['SK85']),
    });

    // With one career still served, there is nothing to compare it with.
    await tester.tap(find.text('Full readiness'));
    await tester.pumpAndSettle();
    expect(find.byType(ReadinessScreen), findsOneWidget);
    expect(find.text('Your careers side by side'), findsNothing);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    // Editing starts from what is still served, so nothing sits ticked unseen,
    // and saving writes the profile back without it.
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit profile'));
    await tester.pumpAndSettle();
    expect(find.text('Completed courses (1 selected)'), findsOneWidget);
    await tester.tap(button('Next: other skills'));
    await tester.pumpAndSettle();
    expect(find.text('Selected: 1'), findsOneWidget);
    await tester.tap(button('Save changes'));
    await tester.pumpAndSettle();
    expect(
        w.store.profile,
        const StudentProfile(
          careers: ['Business Analyst'],
          completedCourses: ['IS 230'],
          selfReportedSkills: ['SK85'],
          plannedCourses: ['IS 350'],
        ));
  });

  testWidgets('A profile whose every career left the postings says how to fix it',
      (tester) async {
    final w = _World()
      ..store.profile = const StudentProfile(careers: ['Retired'], completedCourses: ['IS 230']);
    await _pumpApp(tester, w);

    expect(
        find.text('A career in your profile is no longer in the job postings. '
            'Edit your profile to choose another.'),
        findsOneWidget);
    expect(w.gap.queries, isEmpty, reason: 'a request the backend would refuse is not sent');
    expect(find.text('Try again'), findsNothing, reason: 'asking again cannot bring it back');
  });

  testWidgets('An online course opens in the browser in one tap', (tester) async {
    final w = _World()
      ..store.profile =
          const StudentProfile(careers: ['Business Analyst'], completedCourses: ['IS 230']);
    await _pumpApp(tester, w);
    await tester.tap(find.text('Full readiness'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Suggested courses'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open course'));
    await tester.pump();
    expect(w.opened, ['https://example.com/functional-specs']);
    expect(find.text('The link could not be opened.'), findsNothing);

    // No browser to take it: the student is told, not left tapping.
    w.browserAccepts = false;
    await tester.tap(find.text('Open course'));
    await tester.pump();
    expect(find.text('The link could not be opened.'), findsOneWidget);
  });

  testWidgets('Arabic at twice the text size on a phone: every screen lays out',
      (tester) async {
    final w = _World();
    await _pumpApp(tester, w);
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpAndSettle();

    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle();
    // At this size most of the form is below the fold.
    for (final label in [
      'محلل أعمال',
      'مطور برمجيات',
      'Database Management Systems',
      'Systems Analysis and Design',
    ]) {
      await tester.scrollUntilVisible(find.text(label), 200,
          scrollable: find
              .descendant(of: find.byType(OnboardingScreen), matching: find.byType(Scrollable))
              .first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }
    // The review sheet, over the course list.
    await tester.tap(find.text('مراجعة'));
    await tester.pumpAndSettle();
    expect(find.text('المقررات المختارة'), findsOneWidget);
    await tester.tap(find.text('تم'));
    await tester.pumpAndSettle();
    await tester.tap(button('التالي: مهارات أخرى'));
    await tester.pumpAndSettle();
    await tester.tap(button('اعرض جاهزيتي'));
    await tester.pumpAndSettle();
    expect(find.byType(DashboardScreen), findsOneWidget);

    // In the order home lists them: the scroll only moves down.
    for (final (screen, open) in [
      (PlanningScreen, 'خطط لمقرراتك'),
      (ReadinessScreen, 'الجاهزية الكاملة'),
    ]) {
      final entry = find.text(open);
      await tester.scrollUntilVisible(entry, 200,
          scrollable: find
              .descendant(of: find.byType(DashboardScreen), matching: find.byType(Scrollable))
              .first);
      await tester.tap(entry);
      await tester.pumpAndSettle();
      expect(find.byType(screen), findsOneWidget);
      // pageBack() looks for an English "Back" tooltip; this one is in Arabic.
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
    }

    // Suggestions, from the full readiness view.
    await tester.tap(find.text('الجاهزية الكاملة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('المقررات المقترحة'));
    await tester.pumpAndSettle();
    expect(find.byType(RecommendationsScreen), findsOneWidget);

    // Settings, from the readiness view's top bar.
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('الإعدادات'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);

    // And the department's view, in its own tab.
    await tester.tap(find.text('القسم'));
    await tester.pumpAndSettle();
    expect(find.byType(CurriculumScreen), findsOneWidget);
    // Overflow is reported as an error, which fails the test on its own.
  });
}

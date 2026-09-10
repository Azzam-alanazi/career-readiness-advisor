import 'package:career_readiness/app.dart';
import 'package:career_readiness/core/api/api_client.dart';
import 'package:career_readiness/features/gap/data/gap_repository.dart';
import 'package:career_readiness/features/gap/presentation/readiness_screen.dart';
import 'package:career_readiness/features/onboarding/data/catalog_repository.dart';
import 'package:career_readiness/features/onboarding/presentation/onboarding_screen.dart';
import 'package:career_readiness/features/profile/data/profile_repository.dart';
import 'package:career_readiness/features/recommendations/data/recommendations_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

class _World {
  final catalog = FakeCatalogRepository();
  final profiles = FakeProfileRepository();
  final gap = FakeGapRepository();
  final recommendations = FakeRecommendationsRepository();
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
      profileRepositoryProvider.overrideWithValue(w.profiles),
      gapRepositoryProvider.overrideWithValue(w.gap),
      recommendationsRepositoryProvider.overrideWithValue(w.recommendations),
    ],
    child: const CareerReadinessApp(),
  ));
  await tester.pumpAndSettle();
}

Finder button(String label) => find.widgetWithText(FilledButton, label);

void main() {
  testWidgets('English: onboarding, then readiness, then suggestions', (tester) async {
    final w = _World();
    await _pumpApp(tester, w);

    expect(find.text('Your profile'), findsOneWidget);
    expect(tester.widget<FilledButton>(button('See my readiness')).onPressed, isNull,
        reason: 'no career chosen yet');

    await tester.enterText(find.byType(TextFormField), '  Information Systems ');
    await tester.tap(find.text('Business Analyst'));
    await tester.tap(find.text('Systems Analysis and Design'));
    await tester.tap(find.text('Database Management Systems'));
    await tester.pump();
    expect(find.text('Completed courses (2 selected)'), findsOneWidget);

    await tester.tap(button('See my readiness'));
    await tester.pumpAndSettle();

    final draft = w.profiles.lastDraft!;
    expect(draft.career, 'Business Analyst');
    expect(draft.completedCourses, ['IS 230', 'IS 240']);
    expect(draft.major, 'Information Systems');
    expect(w.gap.requested, ['p1']);

    // Readiness: the score, what is covered, and what is missing by demand.
    expect(find.text('Readiness for Business Analyst'), findsOneWidget);
    expect(find.text('5%'), findsOneWidget);
    expect(find.text('Requirements elicitation'), findsOneWidget);
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
    await tester.tap(button('اعرض جاهزيتي'));
    await tester.pumpAndSettle();

    expect(Directionality.of(tester.element(find.byType(ReadinessScreen))), TextDirection.rtl);
    expect(find.text('الجاهزية لمهنة محلل أعمال'), findsOneWidget);
    expect(find.text('المواصفات الوظيفية'), findsOneWidget);
    expect(find.text('Functional specifications'), findsNothing);

    // Right-to-left is real layout, not just a flag: the warning icon now sits
    // to the right of the heading it introduces.
    const flag = 'تقديرات، وليست نتائج موثّقة';
    expect(find.text(flag), findsOneWidget);
    expect(tester.getCenter(find.byIcon(Icons.warning_amber_rounded)).dx,
        greaterThan(tester.getCenter(find.text(flag)).dx));

    await tester.tap(find.text('المقررات المقترحة'));
    await tester.pumpAndSettle();
    expect(find.text('اقتراحات، لا أحكام'), findsOneWidget);
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

  testWidgets('A failed save keeps the student on onboarding and says so', (tester) async {
    final w = _World()..profiles.failWith = const ApiException('boom', statusCode: 500);
    await _pumpApp(tester, w);

    await tester.tap(find.text('Business Analyst'));
    await tester.pump();
    await tester.tap(button('See my readiness'));
    await tester.pumpAndSettle();

    expect(find.byType(ReadinessScreen), findsNothing);
    expect(find.text('Your profile could not be saved. Check the connection and try again.'),
        findsOneWidget);
  });

  testWidgets('Start over returns to a blank form', (tester) async {
    final w = _World();
    await _pumpApp(tester, w);

    await tester.enterText(find.byType(TextFormField), 'Information Systems');
    await tester.tap(find.text('Business Analyst'));
    await tester.pump();
    await tester.tap(button('See my readiness'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Suggested courses'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start over'));
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('Information Systems'), findsNothing, reason: 'the major field is rebuilt empty');
    expect(tester.widget<FilledButton>(button('See my readiness')).onPressed, isNull);
  });
}

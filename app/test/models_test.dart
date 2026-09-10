import 'package:career_readiness/features/gap/domain/gap_report.dart';
import 'package:career_readiness/features/profile/domain/profile_draft.dart';
import 'package:career_readiness/features/recommendations/domain/recommendation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  test('a gap report parses the backend shape, quality flag included', () {
    final g = GapReport.fromJson(gapJson);
    expect(g.readinessPercent, 5);
    expect(g.missing.map((s) => s.id), ['SK05', 'SK04']);
    expect(g.validation.gatePassed, isFalse);
    expect(g.validation.bestF1, 0.503);
    expect(g.validation.gateMinF1, 0.6);
    expect(g.validation.courseMappingValidated, isFalse);
  });

  test('a readiness of exactly zero still parses', () {
    // JSON has one number type, so a whole-number readiness can arrive as 0.
    final g = GapReport.fromJson({
      ...gapJson,
      'readiness': 0,
      'readiness_percent': 0,
      'covered': <dynamic>[],
    });
    expect(g.readiness, 0.0);
    expect(g.covered, isEmpty);
  });

  test('skill names follow the language, English otherwise', () {
    final s = GapReport.fromJson(gapJson).missing.first;
    expect(s.nameFor('ar'), 'المواصفات الوظيفية');
    expect(s.nameFor('en'), 'Functional specifications');
    expect(s.nameFor('fr'), 'Functional specifications');
  });

  test('recommendations parse with the skills each course closes', () {
    final r = RecommendationsReport.fromJson(recsJson);
    expect(r.recommendations.single.code, 'IS 350');
    expect(r.recommendations.single.closes.single.nameFor('ar'), 'نمذجة عمليات الأعمال');
    expect(r.validation.gatePassed, isFalse);
  });

  test('a profile draft serialises to the backend field names', () {
    const draft = ProfileDraft(career: 'Business Analyst', completedCourses: ['IS 230']);
    expect(draft.toJson(), {
      'career': 'Business Analyst',
      'completed_courses': ['IS 230'],
      'major': null,
    });
  });
}

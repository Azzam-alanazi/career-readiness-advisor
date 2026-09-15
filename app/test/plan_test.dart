import 'package:career_readiness/features/gap/domain/gap_report.dart';
import 'package:career_readiness/features/onboarding/domain/course.dart';
import 'package:career_readiness/features/planning/domain/plan.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  // Business Analyst now: missing Functional specifications (83%), Business
  // process modelling (50%) and Workshop facilitation (33%).
  final now = GapReport.fromJson(gapJson);
  final catalog = {for (final c in coursesJson.map(Course.fromJson)) c.code: c};

  Course teaching(List<String> skills) => Course.fromJson(
      {'code': 'X 100', 'name': 'X', 'skill_count': skills.length, 'skills': skills});

  test('a course closes the current gaps it teaches, most in demand first', () {
    expect(gapsClosedBy(catalog['IS 350']!, now).map((s) => s.id), ['SK04']);
    expect(gapsClosedBy(catalog['IS 230']!, now), isEmpty,
        reason: 'it teaches SQL and databases, neither a gap here');
    expect(gapsClosedBy(teaching(['SK07', 'SK05']), now).map((s) => s.id), ['SK05', 'SK07'],
        reason: 'in the order of the report: by demand');
  });

  test('a gap two planned courses close counts once', () {
    expect(gapsClosedByPlan([teaching(['SK04', 'SK05']), teaching(['SK05'])], now),
        {'SK04', 'SK05'});
    expect(gapsClosedByPlan(const [], now), isEmpty);
  });
}

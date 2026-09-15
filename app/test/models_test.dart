import 'package:career_readiness/features/curriculum/domain/curriculum_gap.dart';
import 'package:career_readiness/features/gap/domain/gap_report.dart';
import 'package:career_readiness/features/onboarding/domain/course.dart';
import 'package:career_readiness/features/onboarding/domain/skill.dart';
import 'package:career_readiness/features/gap/domain/gap_query.dart';
import 'package:career_readiness/features/profile/domain/student_profile.dart';
import 'package:career_readiness/features/recommendations/domain/recommendation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  test('a gap report parses the backend shape, quality flag included', () {
    final g = GapReport.fromJson(gapJson);
    expect(g.readinessPercent, 10);
    expect(g.missing.map((s) => s.id), ['SK05', 'SK04', 'SK07']);
    expect(g.validation.gatePassed, isFalse);
    expect(g.validation.bestF1, 0.503);
    expect(g.validation.gateMinF1, 0.6);
    expect(g.validation.courseMappingValidated, isFalse);
  });

  test('a gap report keeps the two sources apart', () {
    final g = GapReport.fromJson(gapJson);
    expect((g.readinessFromCourses, g.readinessFromCoursesPercent), (0.0526, 5));
    expect(g.covered.map((s) => (s.id, s.source)), [('SK02', 'courses'), ('SK85', 'self_reported')]);
    expect(g.coveredFromCourses.single.id, 'SK02');
    expect(g.coveredSelfReported.single.id, 'SK85');
    expect(g.missing.first.source, isNull, reason: 'a missing skill has no source');
  });

  test('a readiness of exactly zero still parses', () {
    // JSON has one number type, so a whole-number readiness can arrive as 0.
    final g = GapReport.fromJson({
      ...gapJson,
      'readiness': 0,
      'readiness_percent': 0,
      'readiness_from_courses': 0,
      'readiness_from_courses_percent': 0,
      'covered': <dynamic>[],
      'covered_from_courses': <dynamic>[],
      'covered_self_reported': <dynamic>[],
    });
    expect((g.readiness, g.readinessFromCourses), (0.0, 0.0));
    expect(g.covered, isEmpty);
  });

  test('skill names follow the language, English otherwise', () {
    final s = GapReport.fromJson(gapJson).missing.first;
    expect(s.nameFor('ar'), 'المواصفات الوظيفية');
    expect(s.nameFor('en'), 'Functional specifications');
    expect(s.nameFor('fr'), 'Functional specifications');
  });

  test('courses carry the skills they teach, and taxonomy skills parse', () {
    expect(Course.fromJson(coursesJson.first).skills, ['SK16', 'SK17']);
    expect(Course.fromJson({'code': 'X 1', 'name': 'X', 'skill_count': 0}).skills, isEmpty);
    final skill = Skill.fromJson(skillsJson.last);
    expect((skill.id, skill.category, skill.nameFor('ar')), ('SK85', 'professional', 'مهارات التواصل'));
  });

  test('recommendations parse by source, with what each closes', () {
    final r = RecommendationsReport.fromJson(recsJson);

    final university = r.university.single;
    expect((university.code, university.countsTowardDegree), ('IS 350', true));
    expect(university.closes.single.nameFor('ar'), 'نمذجة عمليات الأعمال');

    final online = r.online.single;
    expect((online.provider, online.isFree, online.countsTowardDegree),
        ('Example Academy', true, false));
    expect(online.url, 'https://example.com/functional-specs');
    expect(online.closes.single.id, 'SK05');

    expect(r.uncovered.single.id, 'SK07');
    expect(r.validation.gatePassed, isFalse);
  });

  test('an unknown recommendation source is rejected, not guessed', () {
    expect(
      () => RecommendationsReport.fromJson({
        ...recsJson,
        'recommendations': [
          {'source': 'webinar', 'closes': <dynamic>[], 'value': 0.5},
        ],
      }),
      throwsA(anything),
    );
  });

  test('a curriculum view parses, for every career and for one', () {
    final all = CurriculumGap.fromJson(curriculumAllJson);
    expect(all.career, isNull);
    expect((all.postingCount, all.demanded, all.taught, all.coveragePercent), (11, 7, 3, 43));
    expect(all.uncovered.map((s) => s.id), ['SK05', 'SK25', 'SK07', 'SK29']);
    expect((all.uncovered.first.postings, all.uncovered.first.careers.single),
        (5, 'Business Analyst'));
    expect(all.uncovered.first.nameFor('ar'), 'المواصفات الوظيفية');
    expect(all.notAsked.single.courses, ['CIT 201', 'CIT 202']);
    expect(all.perCareer.map((c) => (c.career, c.postingCount, c.coveragePercent)),
        [('Business Analyst', 6, 50), ('Software Developer', 5, 33)]);
    expect(all.validation.gatePassed, isFalse);
    expect(all.belowThreshold.map((s) => (s.id, s.postings, s.courses.length)),
        [('SK19', 1, 0), ('SK16', 1, 2)]);
    expect(all.perCareer.map((c) => c.minPostings), [2, 2]);

    expect(CurriculumGap.fromJson(curriculumAnalystJson).career, 'Business Analyst');
    // A whole-number coverage arrives as an int.
    expect(CurriculumGap.fromJson({...curriculumAllJson, 'coverage': 1}).coverage, 1.0);
  });

  test('a profile round-trips through JSON; a query goes out in the backend names', () {
    const profile = StudentProfile(
      careers: ['Business Analyst', 'Software Developer'],
      completedCourses: ['IS 240', 'IS 230'],
      selfReportedSkills: ['SK85'],
    );
    expect(StudentProfile.fromJson(profile.toJson()), profile);
    expect(gapQueryFor(profile).toJson(), {
      'career': 'Business Analyst',
      'completed_courses': ['IS 230', 'IS 240'],
      'self_reported_skills': ['SK85'],
    });
    expect(gapQueryFor(profile, 'Software Developer').career, 'Software Developer');
    // Compared by value, so one provider serves each profile content.
    expect(gapQueryFor(profile), gapQueryFor(profile.copyWith(completedCourses: ['IS 230', 'IS 240'])));
  });

  test('a report read from a profile sent with the request has no profile id', () {
    expect(GapReport.fromJson({...gapJson, 'profile_id': null}).profileId, isNull);
    expect(RecommendationsReport.fromJson({...recsJson, 'profile_id': null}).profileId, isNull);
  });
}

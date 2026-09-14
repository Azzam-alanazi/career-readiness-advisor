import 'package:career_readiness/features/onboarding/domain/course.dart';
import 'package:career_readiness/features/onboarding/domain/course_groups.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  final catalog = coursesJson.map(Course.fromJson).toList();

  List<String> codes(List<CourseGroup> groups) =>
      [for (final g in groups) for (final c in g.courses) c.code];

  Course course(String code, [String track = '']) =>
      Course.fromJson({'code': code, 'name': code, 'skill_count': 0, 'track': track});

  test('tracks come in degree order; courses by level, then code', () {
    final groups = groupCourses(catalog.reversed.toList(), '');
    expect(groups.map((g) => g.track), ['college', 'core', 'elective_analytics']);
    expect(codes(groups), ['MATH 210', 'IS 230', 'IS 240', 'IS 350', 'CIS 505']);
  });

  test('a course with a track the app does not know is kept, last', () {
    final groups = groupCourses([course('ART 101', 'fine_arts'), ...catalog], '');
    expect(groups.last.track, otherTrack);
    expect(groups.last.courses.single.code, 'ART 101');
  });

  test('search matches code or title, ignoring case, spacing and digit script', () {
    expect(codes(groupCourses(catalog, 'cis')), ['CIS 505']);
    expect(codes(groupCourses(catalog, 'IS2')), ['IS 230', 'IS 240']);
    expect(codes(groupCourses(catalog, 'is 2')), ['IS 230', 'IS 240']);
    expect(codes(groupCourses(catalog, 'DATA')), ['IS 230', 'CIS 505']);
    expect(codes(groupCourses(catalog, '  data   mining ')), ['CIS 505']);
    // Arabic-Indic and Persian digits, as an Arabic keyboard types them.
    expect(codes(groupCourses(catalog, '٢٣٠')), ['IS 230']);
    expect(codes(groupCourses(catalog, 'IS ۲۴۰')), ['IS 240']);
    expect(groupCourses(catalog, 'zzz'), isEmpty);
    expect(codes(groupCourses(catalog, '   ')).length, catalog.length);
  });

  test('levels come from the code, and a shortcut covers its level and below', () {
    expect(courseLevel(course('CIS 221')), 200);
    expect(courseLevel(course('CIS ٥٠٥')), 500);
    expect(courseLevel(course('SEMINAR')), isNull);
    expect(shortcutLevels(catalog), [200, 300], reason: 'the top level would be everything');
    expect(codesUpToLevel(catalog, 200), {'IS 230', 'IS 240', 'MATH 210'});
    expect(codesUpToLevel(catalog, 300), {'IS 230', 'IS 240', 'MATH 210', 'IS 350'});
  });

  test('track counts cover the whole catalog, whatever a search shows', () {
    final counts = trackCounts(catalog, {'IS 230', 'CIS 505'});
    expect(counts['college'], (selected: 0, total: 1));
    expect(counts['core'], (selected: 1, total: 2));
    expect(counts['elective_analytics'], (selected: 1, total: 2));
  });
}

import 'package:career_readiness/features/onboarding/domain/course.dart';
import 'package:career_readiness/features/onboarding/domain/skill.dart';
import 'package:career_readiness/features/onboarding/domain/skill_groups.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  final skills = skillsJson.map(Skill.fromJson).toList();
  final catalog = coursesJson.map(Course.fromJson).toList();

  List<String> ids(SkillGroup g) => [for (final s in g.skills) s.id];

  test('categories follow the taxonomy; skills keep the order they arrive in', () {
    final groups = groupSkills(skills.reversed.toList(), '');
    expect(groups.map((g) => g.category),
        ['business_analysis', 'data', 'software_development', 'professional']);
    expect(ids(groups.first), ['SK05', 'SK04', 'SK02']);
  });

  test('a category the app does not know goes last, not missing', () {
    final odd = Skill.fromJson(
        const {'id': 'SK99', 'en': 'Odd', 'ar': 'غريب', 'category': 'new_category'});
    final groups = groupSkills([odd, ...skills], '');
    expect(groups.last.category, 'new_category');
    expect(groups.first.category, 'business_analysis');
  });

  test('search matches either language, ignoring case and outer spaces', () {
    final sql = groupSkills(skills, '  sql ');
    expect(sql.single.category, 'data');
    expect(ids(sql.single), ['SK17']);

    final arabic = groupSkills(skills, 'التواصل');
    expect(arabic.single.category, 'professional');
    expect(ids(arabic.single), ['SK85']);

    expect(groupSkills(skills, 'zzz'), isEmpty);
  });

  test('skills from courses are the union of what the selected courses teach', () {
    expect(skillsFromCourses(catalog, {'IS 230', 'IS 240'}), {'SK16', 'SK17', 'SK02'});
    expect(skillsFromCourses(catalog, {}), isEmpty);
    expect(skillsFromCourses(catalog, {'IS 999'}), isEmpty, reason: 'unknown codes teach nothing');
  });
}

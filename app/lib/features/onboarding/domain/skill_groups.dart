import 'package:career_readiness/features/onboarding/domain/course.dart';
import 'package:career_readiness/features/onboarding/domain/skill.dart';

/// Taxonomy categories in the order the labelling reference lists them.
const categoryOrder = [
  'business_analysis',
  'data',
  'software_development',
  'infrastructure',
  'it_support',
  'security',
  'erp',
  'professional',
];

typedef SkillGroup = ({String category, List<Skill> skills});

/// Every skill the selected courses teach, by the catalog's own mapping.
Set<String> skillsFromCourses(List<Course> catalog, Set<String> selectedCodes) => {
      for (final course in catalog)
        if (selectedCodes.contains(course.code)) ...course.skills,
    };

/// The skills whose name, in either language, contains [query], grouped by
/// category. Categories follow the taxonomy's order, with any unknown ones last.
List<SkillGroup> groupSkills(List<Skill> skills, String query) {
  final q = query.trim().toLowerCase();
  final matching = q.isEmpty
      ? skills
      : skills.where((s) => s.en.toLowerCase().contains(q) || s.ar.contains(q));

  final byCategory = <String, List<Skill>>{};
  for (final skill in matching) {
    byCategory.putIfAbsent(skill.category, () => []).add(skill);
  }

  int rank(String category) {
    final i = categoryOrder.indexOf(category);
    return i < 0 ? categoryOrder.length : i;
  }

  final categories = byCategory.keys.toList()
    ..sort((a, b) {
      final byRank = rank(a).compareTo(rank(b));
      return byRank != 0 ? byRank : a.compareTo(b);
    });
  return [for (final c in categories) (category: c, skills: byCategory[c]!)];
}

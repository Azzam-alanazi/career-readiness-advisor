import 'package:career_readiness/features/gap/domain/gap_report.dart';
import 'package:career_readiness/features/gap/domain/skill_entry.dart';
import 'package:career_readiness/features/onboarding/domain/course.dart';

/// The gaps [course] would close: the skills it teaches that [now] has
/// missing, most in demand first. This is what a planned course adds to the
/// projection, course by course, from the catalog's own course-to-skill map.
List<SkillEntry> gapsClosedBy(Course course, GapReport now) =>
    [for (final s in now.missing) if (course.skills.contains(s.id)) s];

/// Every gap the planned courses close together. A gap two of them close
/// counts once, as it does in the projection.
Set<String> gapsClosedByPlan(Iterable<Course> planned, GapReport now) =>
    {for (final c in planned) ...gapsClosedBy(c, now).map((s) => s.id)};

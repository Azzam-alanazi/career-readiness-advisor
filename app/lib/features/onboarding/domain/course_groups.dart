import 'package:career_readiness/features/onboarding/domain/course.dart';

/// Catalog tracks in degree order: the college's common requirements, the IS
/// core, then the elective tracks.
const trackOrder = ['college', 'core', 'elective_analytics', 'elective_ecommerce'];

/// The group for a course whose track the app does not know: kept, last,
/// rather than dropped.
const otherTrack = '';

typedef CourseGroup = ({String track, List<Course> courses});

String trackOf(Course course) =>
    trackOrder.contains(course.track) ? course.track : otherTrack;

/// Western digits for Arabic-Indic and Persian ones, so a code typed on an
/// Arabic keyboard ("٢٢١") finds CIS 221.
String normalizeDigits(String s) => String.fromCharCodes(s.runes.map((r) => switch (r) {
      >= 0x0660 && <= 0x0669 => r - 0x0660 + 0x30,
      >= 0x06F0 && <= 0x06F9 => r - 0x06F0 + 0x30,
      _ => r,
    }));

String _codeKey(String s) => normalizeDigits(s).toLowerCase().replaceAll(RegExp(r'\s+'), '');

String _textKey(String s) =>
    normalizeDigits(s).toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();

/// Does [course] match [query], by code or by title? Case, spacing and digit
/// script are ignored: "cis221", "CIS 221" and "CIS ٢٢١" all find CIS 221.
bool courseMatches(Course course, String query) {
  final code = _codeKey(query);
  if (code.isEmpty) return true;
  return _codeKey(course.code).contains(code) ||
      _textKey(course.name).contains(_textKey(query));
}

/// The course's level from its code: CIS 221 is 200-level. Null when the code
/// carries no number.
int? courseLevel(Course course) {
  final number = RegExp(r'\d+').firstMatch(normalizeDigits(course.code));
  return number == null ? null : int.parse(number.group(0)!) ~/ 100 * 100;
}

/// Levels worth a "this level and below" shortcut: every level in the catalog
/// but the top one, which would simply be everything.
List<int> shortcutLevels(List<Course> catalog) {
  final levels = {for (final c in catalog) ?courseLevel(c)}.toList()..sort();
  return levels.length < 2 ? const [] : levels.sublist(0, levels.length - 1);
}

/// Every course at [level] or below.
Set<String> codesUpToLevel(List<Course> catalog, int level) => {
      for (final c in catalog)
        if (courseLevel(c) case final l? when l <= level) c.code,
    };

/// The catalog grouped by track in degree order, keeping only the courses that
/// match [query]. Within a track, courses run by level, then code. Tracks with
/// no match are left out.
List<CourseGroup> groupCourses(List<Course> catalog, String query) {
  final byTrack = <String, List<Course>>{};
  for (final c in catalog) {
    if (courseMatches(c, query)) byTrack.putIfAbsent(trackOf(c), () => []).add(c);
  }
  int rank(String track) =>
      track == otherTrack ? trackOrder.length : trackOrder.indexOf(track);
  int order(Course a, Course b) {
    final byLevel = (courseLevel(a) ?? 1 << 30).compareTo(courseLevel(b) ?? 1 << 30);
    return byLevel != 0 ? byLevel : a.code.compareTo(b.code);
  }

  final tracks = byTrack.keys.toList()..sort((a, b) => rank(a).compareTo(rank(b)));
  return [for (final t in tracks) (track: t, courses: byTrack[t]!..sort(order))];
}

/// Per track, how many of its courses are chosen and how many it has -- over
/// the whole catalog, whatever a search is showing.
Map<String, ({int selected, int total})> trackCounts(
    List<Course> catalog, Set<String> chosen) {
  final counts = <String, ({int selected, int total})>{};
  for (final c in catalog) {
    final track = trackOf(c);
    final now = counts[track] ?? (selected: 0, total: 0);
    counts[track] = (
      selected: now.selected + (chosen.contains(c.code) ? 1 : 0),
      total: now.total + 1,
    );
  }
  return counts;
}

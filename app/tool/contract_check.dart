// ignore_for_file: avoid_print -- a command-line check; printing is its output.

// Checks the app's models against the REAL backend.
//
// The widget tests run against fakes shaped like the backend's JSON. Those
// fakes were written by hand, so they cannot catch the backend drifting away
// from them. This runs the spec's definition-of-done scenario -- Business
// Analyst, six completed courses, readiness, three university suggestions, and
// every missing skill accounted for by a university course, an online course or
// neither -- against the live API through the app's own models, and fails
// loudly on any mismatch.
//
// With the backend running on localhost:8000:
//
//     dart run tool/contract_check.dart [base-url]
//
// It imports only the pure-Dart model files: `flutter test` blocks real HTTP,
// and anything importing Flutter cannot run under plain `dart run`.

import 'dart:convert';
import 'dart:io';

import 'package:career_readiness/features/gap/domain/gap_report.dart';
import 'package:career_readiness/features/onboarding/domain/career.dart';
import 'package:career_readiness/features/onboarding/domain/course.dart';
import 'package:career_readiness/features/profile/domain/profile.dart';
import 'package:career_readiness/features/profile/domain/profile_draft.dart';
import 'package:career_readiness/features/recommendations/domain/recommendation.dart';
import 'package:http/http.dart' as http;

// Six real Shaqra IS courses, the same scenario as backend/reports.py.
const sixCourses = ['CSC 202', 'CIT 201', 'CIT 202', 'CIS 221', 'CIS 302', 'CIS 303'];

var failures = 0;

void check(bool ok, String what) {
  print('  ${ok ? 'PASS' : 'FAIL'}  $what');
  if (!ok) failures++;
}

bool hasArabic(String s) => s.runes.any((c) => c >= 0x0600 && c <= 0x06FF);

Future<void> main(List<String> args) async {
  final base = args.isEmpty ? 'http://localhost:8000' : args.first;
  final client = http.Client();

  dynamic decode(http.Response r) {
    final text = utf8.decode(r.bodyBytes);
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw StateError('HTTP ${r.statusCode} from ${r.request?.url}: $text');
    }
    return jsonDecode(text);
  }

  Future<dynamic> get(String path) async => decode(await client.get(Uri.parse('$base$path')));

  try {
    print('backend: $base\n');

    final careers = (await get('/careers') as List)
        .map((j) => Career.fromJson(j as Map<String, dynamic>))
        .toList();
    final courses = (await get('/courses') as List)
        .map((j) => Course.fromJson(j as Map<String, dynamic>))
        .toList();
    print('catalog');
    check(careers.any((c) => c.name == 'Business Analyst'), '${careers.length} careers, Business Analyst among them');
    final codes = {for (final c in courses) c.code};
    check(sixCourses.every(codes.contains), '${courses.length} courses, all six scenario courses present');

    final draft = ProfileDraft(
      career: 'Business Analyst',
      completedCourses: sixCourses,
      major: 'Information Systems',
    );
    final profile = Profile.fromJson(decode(await client.post(
      Uri.parse('$base/profiles'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(draft.toJson()),
    )) as Map<String, dynamic>);
    print('\nprofile');
    check(profile.career == 'Business Analyst', 'created ${profile.id}');
    check(profile.completedCourses.toSet().containsAll(sixCourses), 'all six courses stored');

    final gap = GapReport.fromJson(
        await get('/profiles/${profile.id}/gap') as Map<String, dynamic>);
    print('\nreadiness');
    check(true, 'readiness ${gap.readinessPercent}% '
        '(${gap.covered.length} covered, ${gap.missing.length} missing)');
    check(gap.readinessPercent == (gap.readiness * 100).round(),
        'readiness_percent agrees with readiness');
    var ranked = true;
    for (var i = 1; i < gap.missing.length; i++) {
      if (gap.missing[i].demand > gap.missing[i - 1].demand) ranked = false;
    }
    check(ranked, 'missing skills arrive ranked by demand -- the order the UI renders');
    final skills = [...gap.covered, ...gap.missing];
    check(skills.every((s) => hasArabic(s.ar)), 'every skill carries an Arabic label');
    check(!gap.validation.gatePassed, 'quality flag present: gate_passed=false, '
        'best_f1=${gap.validation.bestF1}, floor=${gap.validation.gateMinF1}');

    final recs = RecommendationsReport.fromJson(await get(
        '/profiles/${profile.id}/recommendations') as Map<String, dynamic>);
    print('\nsuggestions');
    final missingIds = {for (final s in gap.missing) s.id};
    final university = recs.university;
    final online = recs.online;
    check(university.length >= 3, '${university.length} university courses, '
        'the top three for the definition of done:');
    for (final r in university.take(3)) {
      check(r.closes.every((s) => missingIds.contains(s.id)),
          '${r.code} ${r.name}: closes ${r.closes.map((s) => s.en).join(', ')}');
    }
    check(recs.recommendations.every((r) => r.closes.every((s) => missingIds.contains(s.id))),
        'every suggestion closes only missing skills');
    check(university.every((r) => !sixCourses.contains(r.code)),
        'no completed course is suggested');
    bool rankedByValue(List<Recommendation> rs) =>
        [for (var i = 1; i < rs.length; i++) rs[i].value <= rs[i - 1].value].every((ok) => ok);
    check(rankedByValue(university) && rankedByValue(online),
        'each source ranked by the demand it closes');
    final byUniversity = {for (final r in university) ...r.closes.map((s) => s.id)};
    final byOnline = {for (final r in online) ...r.closes.map((s) => s.id)};
    final uncovered = {for (final s in recs.uncovered) s.id};
    check(byUniversity.intersection(byOnline).isEmpty,
        'no online course for a skill a university course teaches');
    check(byUniversity.union(byOnline).union(uncovered).containsAll(missingIds) &&
            uncovered.intersection(byUniversity.union(byOnline)).isEmpty,
        'every missing skill accounted for: ${byUniversity.length} by a university course, '
        '${byOnline.length} by an online course, ${uncovered.length} with neither yet');
    check(online.every((r) => r.url.startsWith('http')),
        '${online.length} online courses, each with a web address');
    check(!recs.validation.gatePassed, 'quality flag present on suggestions too');
  } on Object catch (e) {
    print('\nFAIL  $e');
    failures++;
  } finally {
    client.close();
  }

  print(failures == 0 ? '\ncontract holds' : '\n$failures check(s) failed');
  exit(failures == 0 ? 0 : 1);
}

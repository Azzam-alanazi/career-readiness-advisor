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

import 'package:career_readiness/features/curriculum/domain/curriculum_gap.dart';
import 'package:career_readiness/features/gap/domain/gap_report.dart';
import 'package:career_readiness/features/onboarding/domain/career.dart';
import 'package:career_readiness/features/onboarding/domain/course.dart';
import 'package:career_readiness/features/onboarding/domain/skill.dart';
import 'package:career_readiness/features/onboarding/domain/skill_groups.dart';
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

    // Self-reported skills: the taxonomy the skills step offers, then the same
    // six courses plus two claimed skills -- the top missing one, and one a
    // course already teaches, which must still count as the course's.
    final taxonomy = (await get('/skills') as List)
        .map((j) => Skill.fromJson(j as Map<String, dynamic>))
        .toList();
    final taxonomyIds = {for (final s in taxonomy) s.id};
    print('\ntaxonomy');
    check(taxonomy.every((s) => hasArabic(s.ar) && categoryOrder.contains(s.category)),
        '${taxonomy.length} skills, each with an Arabic label and a known category');
    check(courses.every((c) => c.skills.every(taxonomyIds.contains)),
        'every course skill is a taxonomy skill');
    check(gap.coveredSelfReported.isEmpty &&
            gap.readinessFromCourses == gap.readiness &&
            gap.covered.every((s) => s.source == 'courses'),
        'with no self-reported skills, both readings agree');

    final unknown = await client.post(
      Uri.parse('$base/profiles'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(ProfileDraft(
        career: 'Business Analyst',
        completedCourses: sixCourses,
        selfReportedSkills: const ['SK999'],
      ).toJson()),
    );
    check(unknown.statusCode == 422, 'an unknown skill id is refused (HTTP ${unknown.statusCode})');

    final claimed = gap.missing.first;
    final alreadyTaught = gap.coveredFromCourses.first;
    final selfDraft = ProfileDraft(
      career: 'Business Analyst',
      completedCourses: sixCourses,
      major: 'Information Systems',
      selfReportedSkills: [claimed.id, alreadyTaught.id],
    );
    final selfProfile = Profile.fromJson(decode(await client.post(
      Uri.parse('$base/profiles'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(selfDraft.toJson()),
    )) as Map<String, dynamic>);
    print('\nself-reported');
    check(selfProfile.selfReportedSkills.toSet().containsAll([claimed.id, alreadyTaught.id]),
        'stored: ${claimed.en} and ${alreadyTaught.en}');

    final selfGap = GapReport.fromJson(
        await get('/profiles/${selfProfile.id}/gap') as Map<String, dynamic>);
    check(selfGap.coveredSelfReported.map((s) => s.id).toList().toString() ==
            [claimed.id].toString(),
        '${claimed.en} counts as self-reported');
    check(selfGap.covered.firstWhere((s) => s.id == alreadyTaught.id).source == 'courses',
        '${alreadyTaught.en} stays "courses": a course outranks a claim');
    check(selfGap.readinessFromCourses == gap.readiness,
        'courses-only readiness unchanged (${selfGap.readinessFromCoursesPercent}%)');
    check(selfGap.readiness > gap.readiness,
        'combined readiness rises: ${gap.readinessPercent}% -> ${selfGap.readinessPercent}%');
    final fromCourses = {for (final s in selfGap.coveredFromCourses) s.id};
    final selfReported = {for (final s in selfGap.coveredSelfReported) s.id};
    check(fromCourses.intersection(selfReported).isEmpty &&
            fromCourses.union(selfReported).length == selfGap.covered.length &&
            selfGap.covered.every((s) =>
                (s.source == 'courses' ? fromCourses : selfReported).contains(s.id)),
        'the two source lists partition covered, and agree with each skill\'s source');

    final selfRecs = RecommendationsReport.fromJson(await get(
        '/profiles/${selfProfile.id}/recommendations') as Map<String, dynamic>);
    check(selfRecs.recommendations.every((r) => r.closes.every((s) => s.id != claimed.id)) &&
            selfRecs.uncovered.every((s) => s.id != claimed.id),
        'nothing is suggested for a skill the student already reports');

    // Several careers on one profile: each, read against the same record, must
    // match a profile that targets that career alone.
    print('\ncomparison');
    Future<Profile> createProfile(ProfileDraft d) async => Profile.fromJson(decode(
          await client.post(
            Uri.parse('$base/profiles'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(d.toJson()),
          ),
        ) as Map<String, dynamic>);
    const compared = ['Business Analyst', 'Data Analyst', 'Software Developer'];
    final several = await createProfile(ProfileDraft(
      career: compared.first,
      otherCareers: compared.sublist(1),
      completedCourses: sixCourses,
    ));
    check(several.otherCareers.join(', ') == compared.sublist(1).join(', '),
        'stored with ${compared.length} careers: ${compared.join(', ')}');
    final scores = <String, int>{};
    for (final career in compared) {
      final side = GapReport.fromJson(await get(
              '/profiles/${several.id}/gap?career=${Uri.encodeComponent(career)}')
          as Map<String, dynamic>);
      final single = await createProfile(
          ProfileDraft(career: career, completedCourses: sixCourses));
      final alone = GapReport.fromJson(
          await get('/profiles/${single.id}/gap') as Map<String, dynamic>);
      scores[career] = side.readinessPercent;
      check(
          side.career == career &&
              side.readiness == alone.readiness &&
              side.covered.length == alone.covered.length &&
              side.missing.length == alone.missing.length,
          '$career: ${side.readinessPercent}%, ${side.covered.length} covered, '
          '${side.missing.length} missing -- the same as targeting it alone');
    }
    final closest = scores.entries.reduce((a, b) => b.value > a.value ? b : a);
    check(true, 'closest of the three for these six courses: ${closest.key} (${closest.value}%)');
    final notNamed = await client.get(Uri.parse(
        '$base/profiles/${several.id}/gap?career=${Uri.encodeComponent('ERP Consultant')}'));
    check(notNamed.statusCode == 422,
        'a career the profile does not name is refused (HTTP ${notNamed.statusCode})');

    // The department's view: the catalog against every posting, for one career
    // or all of them, from the same profiles and course labels.
    Future<CurriculumGap> curriculum([String? career]) async =>
        CurriculumGap.fromJson(await get(career == null
            ? '/curriculum/gap'
            : '/curriculum/gap?career=${Uri.encodeComponent(career)}') as Map<String, dynamic>);
    bool byDemand(List<CurriculumSkill> s) =>
        [for (var i = 1; i < s.length; i++) s[i].demand <= s[i - 1].demand].every((ok) => ok);
    String sortedCodes(Iterable<String> cs) => (cs.toList()..sort()).join(',');

    final whole = await curriculum();
    final totalPostings = careers.fold<int>(0, (n, c) => n + c.postingCount);
    print('\ncurriculum');
    check(whole.career == null && whole.postingCount == totalPostings,
        'every career: ${whole.postingCount} postings, the whole sample');
    check(whole.perCareer.map((c) => '${c.career}/${c.postingCount}').join(',') ==
            careers.map((c) => '${c.name}/${c.postingCount}').join(','),
        'coverage reported for each of the ${careers.length} careers, with its postings');
    check(whole.coveragePercent == (whole.taught / whole.demanded * 100).round(),
        'coverage ${whole.coveragePercent}%: ${whole.taught} of ${whole.demanded} '
        'demanded skills taught');
    check(byDemand(whole.uncovered) &&
            whole.uncovered.every((s) => s.demandPercent == (s.postings / totalPostings * 100).round()),
        '${whole.uncovered.length} uncovered, ranked by their share of all postings; top five: '
        '${whole.uncovered.take(5).map((s) => '${s.en} ${s.demandPercent}%').join(', ')}');
    final teaching = <String, List<String>>{};
    for (final c in courses) {
      for (final s in c.skills) {
        teaching.putIfAbsent(s, () => []).add(c.code);
      }
    }
    check(whole.uncovered.every((s) => !teaching.containsKey(s.id)),
        'no uncovered skill is taught by any course');
    check(
        whole.notAsked
            .every((s) => sortedCodes(teaching[s.id] ?? const []) == sortedCodes(s.courses)),
        '${whole.notAsked.length} taught skills no posting asks for, each with its courses');
    check(
        whole.belowThreshold.every((s) =>
            !whole.uncovered.any((u) => u.id == s.id) &&
            !whole.notAsked.any((n) => n.id == s.id) &&
            sortedCodes(teaching[s.id] ?? const []) == sortedCodes(s.courses)),
        '${whole.belowThreshold.length} skills named by too few postings, listed apart from '
        'both lists, each with its courses');

    final unionOfCareers = <String>{};
    for (final career in careers) {
      final one = await curriculum(career.name);
      final row = whole.perCareer.firstWhere((c) => c.career == career.name);
      unionOfCareers.addAll(one.uncovered.map((s) => s.id));
      check(one.career == career.name && one.postingCount == career.postingCount &&
              one.coverage == row.coverage && one.demanded == row.demanded &&
              byDemand(one.uncovered) &&
              one.belowThreshold.every((s) => s.postings < row.minPostings),
          '${career.name}: ${one.coveragePercent}% (${one.taught} of ${one.demanded}), '
          '${one.uncovered.length} uncovered, ${one.postingCount} postings, '
          '${one.belowThreshold.length} below the ${row.minPostings}-posting threshold');
    }
    check(unionOfCareers.length == whole.uncovered.length &&
            whole.uncovered.every((s) => unionOfCareers.contains(s.id)),
        'every-career uncovered = the union of each career\'s');

    final everyCourse = Profile.fromJson(decode(await client.post(
      Uri.parse('$base/profiles'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(ProfileDraft(
        career: 'Business Analyst',
        completedCourses: [for (final c in courses) c.code],
      ).toJson()),
    )) as Map<String, dynamic>);
    final stillMissing = {
      for (final s in GapReport.fromJson(
              await get('/profiles/${everyCourse.id}/gap') as Map<String, dynamic>)
          .missing)
        s.id,
    };
    final analyst = {for (final s in (await curriculum('Business Analyst')).uncovered) s.id};
    check(stillMissing.length == analyst.length && stillMissing.containsAll(analyst),
        'Business Analyst uncovered = what a student with all ${courses.length} courses '
        'still misses (${analyst.length})');

    final unknownCareer = await client.get(Uri.parse('$base/curriculum/gap?career=Astronaut'));
    check(unknownCareer.statusCode == 422,
        'an unknown career is refused (HTTP ${unknownCareer.statusCode})');
    check(!whole.validation.gatePassed, 'quality flag present on the curriculum view too');
  } on Object catch (e) {
    print('\nFAIL  $e');
    failures++;
  } finally {
    client.close();
  }

  print(failures == 0 ? '\ncontract holds' : '\n$failures check(s) failed');
  exit(failures == 0 ? 0 : 1);
}

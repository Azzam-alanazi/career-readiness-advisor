import 'package:career_readiness/features/profile/data/profile_store.dart';
import 'package:career_readiness/features/profile/domain/student_profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A fresh store over the device's preferences, as a new launch would open one.
Future<PrefsProfileStore> launch([Map<String, Object>? initial]) async {
  SharedPreferences.resetStatic();
  if (initial != null) SharedPreferences.setMockInitialValues(initial);
  return PrefsProfileStore(await SharedPreferences.getInstance());
}

void main() {
  const profile = StudentProfile(
    careers: ['Business Analyst', 'Data Analyst'],
    completedCourses: ['IS 230', 'IS 240'],
    selfReportedSkills: ['SK85'],
    major: 'Information Systems',
  );

  test('a saved profile loads back as it was, on the next launch too', () async {
    final store = await launch({});
    expect(store.load(), isNull, reason: 'first run: nothing saved yet');
    await store.save(profile);
    expect(store.load(), profile);
    expect((await launch()).load(), profile);
  });

  test('an unreadable or careerless profile means onboarding again, not a crash', () async {
    expect((await launch({PrefsProfileStore.profileKey: '{not json'})).load(), isNull);
    expect((await launch({PrefsProfileStore.profileKey: '{"careers": []}'})).load(), isNull);
  });

  test('a profile saved before planning existed loads with nothing planned', () async {
    final store = await launch({
      PrefsProfileStore.profileKey:
          '{"careers": ["Business Analyst"], "completed_courses": ["IS 230"], '
              '"self_reported_skills": [], "major": null}',
    });
    final loaded = store.load()!;
    expect(loaded.completedCourses, ['IS 230']);
    expect(loaded.plannedCourses, isEmpty);
  });

  test('deleting the profile keeps the language', () async {
    final store = await launch({});
    await store.save(profile);
    await store.saveLanguage('ar');
    await store.clear();
    final next = await launch();
    expect(next.load(), isNull);
    expect(next.language(), 'ar');
  });
}

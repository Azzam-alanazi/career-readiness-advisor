import 'package:career_readiness/features/onboarding/domain/onboarding_state.dart';
import 'package:career_readiness/features/onboarding/presentation/onboarding_controller.dart';
import 'package:career_readiness/features/profile/data/profile_repository.dart';
import 'package:career_readiness/features/profile/presentation/current_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  late FakeProfileRepository profiles;
  late ProviderContainer container;

  setUp(() {
    profiles = FakeProfileRepository();
    container = ProviderContainer(
      overrides: [profileRepositoryProvider.overrideWithValue(profiles)],
    );
  });

  tearDown(() => container.dispose());

  OnboardingController controller() =>
      container.read(onboardingControllerProvider.notifier);

  OnboardingState state() => container.read(onboardingControllerProvider);

  test('a career is required; courses are optional', () {
    expect(state().canSubmit, isFalse);
    controller().toggleCareer('Business Analyst');
    expect(state().canSubmit, isTrue);
  });

  test('up to three careers, kept in the order chosen', () {
    controller()
      ..toggleCareer('A')
      ..toggleCareer('B')
      ..toggleCareer('C')
      ..toggleCareer('D');
    expect(state().careers, ['A', 'B', 'C'], reason: 'a fourth waits until one is let go');

    controller().toggleCareer('B');
    expect(state().careers, ['A', 'C']);
    controller().toggleCareer('D');
    expect(state().careers, ['A', 'C', 'D']);
  });

  test('toggling a course twice removes it', () {
    controller()
      ..toggleCourse('IS 230')
      ..toggleCourse('IS 999')
      ..toggleCourse('IS 999');
    expect(state().courses, {'IS 230'});
  });

  test('no skill starts ticked; toggling a skill twice removes it', () {
    expect(state().selfReported, isEmpty);
    controller()
      ..toggleSkill('SK85')
      ..toggleSkill('SK17')
      ..toggleSkill('SK17');
    expect(state().selfReported, {'SK85'});
  });

  test('submit sends the first career as the main one and the rest to compare', () async {
    controller()
      ..toggleCareer('Software Developer')
      ..toggleCareer('Business Analyst')
      ..toggleCareer('Data Analyst');

    await controller().submit();
    expect(profiles.lastDraft!.career, 'Software Developer');
    expect(profiles.lastDraft!.otherCareers, ['Business Analyst', 'Data Analyst']);
  });

  test('submit sends self-reported skills sorted, beside the courses', () async {
    controller()
      ..toggleCareer('Business Analyst')
      ..toggleCourse('IS 230')
      ..toggleSkill('SK85')
      ..toggleSkill('SK04');

    await controller().submit();
    expect(profiles.lastDraft!.completedCourses, ['IS 230']);
    expect(profiles.lastDraft!.selfReportedSkills, ['SK04', 'SK85']);
  });

  test('submit sends sorted courses, drops a blank major, sets the profile', () async {
    controller()
      ..setMajor('   ')
      ..toggleCareer('Business Analyst')
      ..toggleCourse('IS 240')
      ..toggleCourse('IS 230');

    expect(await controller().submit(), 'p1');
    expect(profiles.lastDraft!.completedCourses, ['IS 230', 'IS 240']);
    expect(profiles.lastDraft!.selfReportedSkills, isEmpty, reason: 'skills are optional');
    expect(profiles.lastDraft!.otherCareers, isEmpty, reason: 'one career is enough');
    expect(profiles.lastDraft!.major, isNull);
    expect(container.read(currentProfileProvider), 'p1');
    expect(state().submitting, isFalse);
  });

  test('a failed submit keeps the error and sets no profile', () async {
    profiles.failWith = Exception('backend down');
    controller().toggleCareer('Business Analyst');

    expect(await controller().submit(), isNull);
    expect(state().error, isNotNull);
    expect(state().submitting, isFalse);
    expect(container.read(currentProfileProvider), isNull);
  });

  test('reset clears the draft and the current profile', () async {
    controller()
      ..toggleCareer('Business Analyst')
      ..toggleCareer('Data Analyst')
      ..toggleCourse('IS 230')
      ..toggleSkill('SK85');
    await controller().submit();
    final revision = state().revision;

    controller().reset();

    expect(state().careers, isEmpty);
    expect(state().courses, isEmpty);
    expect(state().selfReported, isEmpty);
    expect(state().revision, revision + 1);
    expect(container.read(currentProfileProvider), isNull);
  });
}

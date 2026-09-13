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

  test('a career is required; courses are optional', () {
    expect(container.read(onboardingControllerProvider).canSubmit, isFalse);
    controller().selectCareer('Business Analyst');
    expect(container.read(onboardingControllerProvider).canSubmit, isTrue);
  });

  test('toggling a course twice removes it', () {
    controller()
      ..toggleCourse('IS 230')
      ..toggleCourse('IS 999')
      ..toggleCourse('IS 999');
    expect(container.read(onboardingControllerProvider).courses, {'IS 230'});
  });

  test('no skill starts ticked; toggling a skill twice removes it', () {
    expect(container.read(onboardingControllerProvider).selfReported, isEmpty);
    controller()
      ..toggleSkill('SK85')
      ..toggleSkill('SK17')
      ..toggleSkill('SK17');
    expect(container.read(onboardingControllerProvider).selfReported, {'SK85'});
  });

  test('submit sends self-reported skills sorted, beside the courses', () async {
    controller()
      ..selectCareer('Business Analyst')
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
      ..selectCareer('Business Analyst')
      ..toggleCourse('IS 240')
      ..toggleCourse('IS 230');

    expect(await controller().submit(), 'p1');
    expect(profiles.lastDraft!.completedCourses, ['IS 230', 'IS 240']);
    expect(profiles.lastDraft!.selfReportedSkills, isEmpty, reason: 'skills are optional');
    expect(profiles.lastDraft!.major, isNull);
    expect(container.read(currentProfileProvider), 'p1');
    expect(container.read(onboardingControllerProvider).submitting, isFalse);
  });

  test('a failed submit keeps the error and sets no profile', () async {
    profiles.failWith = Exception('backend down');
    controller().selectCareer('Business Analyst');

    expect(await controller().submit(), isNull);
    expect(container.read(onboardingControllerProvider).error, isNotNull);
    expect(container.read(onboardingControllerProvider).submitting, isFalse);
    expect(container.read(currentProfileProvider), isNull);
  });

  test('reset clears the draft and the current profile', () async {
    controller()
      ..selectCareer('Business Analyst')
      ..toggleCourse('IS 230')
      ..toggleSkill('SK85');
    await controller().submit();
    final revision = container.read(onboardingControllerProvider).revision;

    controller().reset();

    final state = container.read(onboardingControllerProvider);
    expect(state.career, isNull);
    expect(state.courses, isEmpty);
    expect(state.selfReported, isEmpty);
    expect(state.revision, revision + 1);
    expect(container.read(currentProfileProvider), isNull);
  });
}

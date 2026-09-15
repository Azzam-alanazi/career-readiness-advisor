import 'package:career_readiness/features/onboarding/domain/onboarding_state.dart';
import 'package:career_readiness/features/onboarding/presentation/onboarding_controller.dart';
import 'package:career_readiness/features/profile/data/profile_store.dart';
import 'package:career_readiness/features/profile/domain/student_profile.dart';
import 'package:career_readiness/features/profile/presentation/saved_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  late InMemoryProfileStore store;
  late ProviderContainer container;

  setUp(() {
    store = InMemoryProfileStore();
    container = ProviderContainer(
      overrides: [profileStoreProvider.overrideWithValue(store)],
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

  test('bulk selection adds to what is chosen; setting replaces it', () {
    controller()
      ..toggleCourse('IS 230')
      ..selectCourses(['IS 240', 'IS 230']);
    expect(state().courses, {'IS 230', 'IS 240'});
    controller().setCourses(const {});
    expect(state().courses, isEmpty);
    controller().setCourses({'IS 350'});
    expect(state().courses, {'IS 350'});
  });

  test('no skill starts ticked; toggling a skill twice removes it', () {
    expect(state().selfReported, isEmpty);
    controller()
      ..toggleSkill('SK85')
      ..toggleSkill('SK17')
      ..toggleSkill('SK17');
    expect(state().selfReported, {'SK85'});
  });

  test('finishing saves the profile on the device, lists sorted, careers in order', () async {
    controller()
      ..setMajor('  Information Systems ')
      ..toggleCareer('Software Developer')
      ..toggleCareer('Business Analyst')
      ..toggleCourse('IS 240')
      ..toggleCourse('IS 230')
      ..toggleSkill('SK85')
      ..toggleSkill('SK04');

    expect(await controller().finish(), isTrue);
    const expected = StudentProfile(
      careers: ['Software Developer', 'Business Analyst'],
      completedCourses: ['IS 230', 'IS 240'],
      selfReportedSkills: ['SK04', 'SK85'],
      major: 'Information Systems',
    );
    expect(store.profile, expected);
    expect(container.read(savedProfileProvider), expected);
    expect(state().careers, isEmpty, reason: 'the draft has done its job');
  });

  test('a blank major is saved as none', () async {
    controller()
      ..setMajor('   ')
      ..toggleCareer('Business Analyst');
    await controller().finish();
    expect(store.profile!.major, isNull);
  });

  test('a failed save keeps the error and the draft, and saves nothing', () async {
    store.failWith = StateError('disk full');
    controller().toggleCareer('Business Analyst');

    expect(await controller().finish(), isFalse);
    expect(state().error, isNotNull);
    expect(state().submitting, isFalse);
    expect(state().careers, ['Business Analyst']);
    expect(store.profile, isNull);
    expect(container.read(savedProfileProvider), isNull);
  });

  test('editing opens the saved profile, and finishing replaces it', () async {
    await container.read(savedProfileProvider.notifier).save(const StudentProfile(
          careers: ['Business Analyst'],
          completedCourses: ['IS 230'],
          selfReportedSkills: ['SK85'],
          major: 'Information Systems',
        ));
    controller().startEditing(container.read(savedProfileProvider)!);
    expect(state().editing, isTrue);
    expect(state().major, 'Information Systems');
    expect(state().careers, ['Business Analyst']);
    expect(state().courses, {'IS 230'});
    expect(state().selfReported, {'SK85'});

    controller().toggleCourse('IS 240');
    await controller().finish();
    expect(store.profile!.completedCourses, ['IS 230', 'IS 240']);
    expect(store.profile!.selfReportedSkills, ['SK85']);
    expect(state().editing, isFalse);
  });

  test('reset clears the draft', () {
    controller()
      ..toggleCareer('Business Analyst')
      ..toggleCourse('IS 230')
      ..toggleSkill('SK85');
    final revision = state().revision;

    controller().reset();

    expect(state().careers, isEmpty);
    expect(state().courses, isEmpty);
    expect(state().selfReported, isEmpty);
    expect(state().revision, revision + 1);
  });
}

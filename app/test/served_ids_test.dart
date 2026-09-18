import 'dart:async';

import 'package:career_readiness/features/gap/domain/gap_query.dart';
import 'package:career_readiness/features/onboarding/domain/served_ids.dart';
import 'package:career_readiness/features/profile/data/profile_store.dart';
import 'package:career_readiness/features/profile/domain/student_profile.dart';
import 'package:career_readiness/features/profile/presentation/saved_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

const served = ServedIds(
  careers: {'Business Analyst', 'Data Analyst'},
  courses: {'IS 230', 'IS 240'},
  skills: {'SK17', 'SK85'},
);

/// Holds every save until the test lets it through, as a slow disk would.
class _SlowStore extends InMemoryProfileStore {
  _SlowStore({super.profile});

  final pending = <Completer<void>>[];

  @override
  Future<void> save(StudentProfile value) async {
    final gate = Completer<void>();
    pending.add(gate);
    await gate.future;
    await super.save(value);
  }
}

void main() {
  group('ServedIds', () {
    test('a query keeps only what the backend still serves', () {
      const query = GapQuery(
        career: 'Business Analyst',
        completedCourses: ['IS 230', 'OLD 101', 'IS 240'],
        selfReportedSkills: ['SK85', 'SK99'],
      );
      expect(
          served.restrictQuery(query),
          const GapQuery(
            career: 'Business Analyst',
            completedCourses: ['IS 230', 'IS 240'],
            selfReportedSkills: ['SK85'],
          ));
    });

    test('a query against a career that is gone cannot be sent', () {
      expect(() => served.restrictQuery(const GapQuery(career: 'Astronaut')),
          throwsA(isA<CareerNotServed>().having((e) => e.career, 'career', 'Astronaut')));
    });

    test('a profile keeps its order, less anything no longer served', () {
      const profile = StudentProfile(
        careers: ['Retired', 'Data Analyst', 'Business Analyst'],
        completedCourses: ['IS 230', 'OLD 101'],
        selfReportedSkills: ['SK99', 'SK17'],
        plannedCourses: ['IS 240', 'OLD 202'],
        major: 'Information Systems',
      );
      expect(
          served.restrictProfile(profile),
          const StudentProfile(
            careers: ['Data Analyst', 'Business Analyst'],
            completedCourses: ['IS 230'],
            selfReportedSkills: ['SK17'],
            plannedCourses: ['IS 240'],
            major: 'Information Systems',
          ));
    });
  });

  group('Planning a course', () {
    test('two quick taps both count, though the first is still being written', () async {
      final store = _SlowStore(profile: const StudentProfile(careers: ['Business Analyst']));
      final container = ProviderContainer(
        overrides: [profileStoreProvider.overrideWithValue(store)],
      );
      addTearDown(container.dispose);
      final saved = container.read(savedProfileProvider.notifier);

      final first = saved.togglePlanned('IS 350');
      final second = saved.togglePlanned('IS 240');
      // Shown at once, before either write finishes.
      expect(container.read(savedProfileProvider)!.plannedCourses, ['IS 240', 'IS 350']);

      for (final gate in store.pending) {
        gate.complete();
      }
      await Future.wait([first, second]);
      expect(container.read(savedProfileProvider)!.plannedCourses, ['IS 240', 'IS 350']);
      expect(store.profile!.plannedCourses, ['IS 240', 'IS 350']);
    });

    test('a failed write puts the plan back and says so', () async {
      final store = InMemoryProfileStore(
          profile: const StudentProfile(careers: ['Business Analyst']))
        ..failWith = StateError('disk full');
      final container = ProviderContainer(
        overrides: [profileStoreProvider.overrideWithValue(store)],
      );
      addTearDown(container.dispose);

      await expectLater(
          container.read(savedProfileProvider.notifier).togglePlanned('IS 350'),
          throwsStateError);
      expect(container.read(savedProfileProvider)!.plannedCourses, isEmpty);
    });
  });
}

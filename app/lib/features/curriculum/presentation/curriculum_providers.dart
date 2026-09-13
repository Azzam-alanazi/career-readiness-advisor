import 'package:career_readiness/features/curriculum/data/curriculum_repository.dart';
import 'package:career_readiness/features/curriculum/domain/curriculum_gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The career the department view is showing; null for every career.
class CurriculumScope extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? career) => state = career;
}

final curriculumScopeProvider =
    NotifierProvider<CurriculumScope, String?>(CurriculumScope.new);

final curriculumGapProvider =
    FutureProvider.autoDispose.family<CurriculumGap, String?>(
  (ref, career) => ref.watch(curriculumRepositoryProvider).fetch(career),
);

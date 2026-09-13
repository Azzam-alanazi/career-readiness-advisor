import 'package:career_readiness/core/api/api_client.dart';
import 'package:career_readiness/features/curriculum/domain/curriculum_gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CurriculumRepository {
  CurriculumRepository(this._api);

  final ApiClient _api;

  /// One career's view, or every career's when [career] is null.
  Future<CurriculumGap> fetch(String? career) async => CurriculumGap.fromJson(
        await _api.get(career == null
            ? '/curriculum/gap'
            : '/curriculum/gap?career=${Uri.encodeComponent(career)}') as Json,
      );
}

final curriculumRepositoryProvider = Provider<CurriculumRepository>(
  (ref) => CurriculumRepository(ref.watch(apiClientProvider)),
);

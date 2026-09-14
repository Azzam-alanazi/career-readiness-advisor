import 'package:career_readiness/core/api/api_client.dart';
import 'package:career_readiness/features/gap/domain/gap_report.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GapRepository {
  GapRepository(this._api);

  final ApiClient _api;

  /// The profile read against [career], one of its careers; its first when null.
  Future<GapReport> fetch(String profileId, {String? career}) async => GapReport.fromJson(
        await _api.get('/profiles/${Uri.encodeComponent(profileId)}/gap'
            '${career == null ? '' : '?career=${Uri.encodeComponent(career)}'}') as Json,
      );
}

final gapRepositoryProvider =
    Provider<GapRepository>((ref) => GapRepository(ref.watch(apiClientProvider)));

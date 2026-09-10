import 'package:career_readiness/core/api/api_client.dart';
import 'package:career_readiness/features/gap/domain/gap_report.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GapRepository {
  GapRepository(this._api);

  final ApiClient _api;

  Future<GapReport> fetch(String profileId) async => GapReport.fromJson(
        await _api.get('/profiles/${Uri.encodeComponent(profileId)}/gap') as Json,
      );
}

final gapRepositoryProvider =
    Provider<GapRepository>((ref) => GapRepository(ref.watch(apiClientProvider)));

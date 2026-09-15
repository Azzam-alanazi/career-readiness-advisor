import 'package:career_readiness/core/api/api_client.dart';
import 'package:career_readiness/features/gap/domain/gap_query.dart';
import 'package:career_readiness/features/gap/domain/gap_report.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GapRepository {
  GapRepository(this._api);

  final ApiClient _api;

  /// The gap for [query]. The profile travels in the request; the server
  /// stores nothing.
  Future<GapReport> fetch(GapQuery query) async =>
      GapReport.fromJson(await _api.post('/gap', query.toJson()) as Json);
}

final gapRepositoryProvider =
    Provider<GapRepository>((ref) => GapRepository(ref.watch(apiClientProvider)));

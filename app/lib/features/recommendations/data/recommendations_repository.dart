import 'package:career_readiness/core/api/api_client.dart';
import 'package:career_readiness/features/recommendations/domain/recommendation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecommendationsRepository {
  RecommendationsRepository(this._api);

  final ApiClient _api;

  /// Three by default: the spec's definition of done asks for three courses.
  Future<RecommendationsReport> fetch(String profileId, {int limit = 3}) async =>
      RecommendationsReport.fromJson(
        await _api.get('/profiles/${Uri.encodeComponent(profileId)}'
            '/recommendations?limit=$limit') as Json,
      );
}

final recommendationsRepositoryProvider = Provider<RecommendationsRepository>(
  (ref) => RecommendationsRepository(ref.watch(apiClientProvider)),
);

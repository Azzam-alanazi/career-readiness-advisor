import 'package:career_readiness/core/api/api_client.dart';
import 'package:career_readiness/features/recommendations/domain/recommendation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecommendationsRepository {
  RecommendationsRepository(this._api);

  final ApiClient _api;

  /// Every suggestion, not a top three: each missing skill gets a university
  /// course, an online course, or a place in `uncovered`, and the screen shows
  /// all of them.
  Future<RecommendationsReport> fetch(String profileId) async =>
      RecommendationsReport.fromJson(
        await _api.get('/profiles/${Uri.encodeComponent(profileId)}/recommendations')
            as Json,
      );
}

final recommendationsRepositoryProvider = Provider<RecommendationsRepository>(
  (ref) => RecommendationsRepository(ref.watch(apiClientProvider)),
);

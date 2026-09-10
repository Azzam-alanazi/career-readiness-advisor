import 'package:career_readiness/core/api/api_client.dart';
import 'package:career_readiness/features/profile/domain/profile.dart';
import 'package:career_readiness/features/profile/domain/profile_draft.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileRepository {
  ProfileRepository(this._api);

  final ApiClient _api;

  Future<Profile> create(ProfileDraft draft) async =>
      Profile.fromJson(await _api.post('/profiles', draft.toJson()) as Json);
}

final profileRepositoryProvider =
    Provider<ProfileRepository>((ref) => ProfileRepository(ref.watch(apiClientProvider)));

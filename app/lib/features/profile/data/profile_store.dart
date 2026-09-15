import 'dart:convert';

import 'package:career_readiness/features/profile/domain/student_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Where the student's profile and language live: this device, and only this
/// device. There is no server copy and no account.
abstract interface class ProfileStore {
  StudentProfile? load();
  Future<void> save(StudentProfile profile);
  Future<void> clear();
  String? language();
  Future<void> saveLanguage(String languageCode);
}

/// shared_preferences suits the shape: one small document of id lists, read
/// whole at launch and written whole on save. A typed store (Hive) would add
/// adapters and migrations for nothing a JSON document cannot hold.
class PrefsProfileStore implements ProfileStore {
  PrefsProfileStore(this._prefs);

  final SharedPreferences _prefs;

  static const profileKey = 'student_profile';
  static const languageKey = 'language';

  @override
  StudentProfile? load() {
    final raw = _prefs.getString(profileKey);
    if (raw == null) return null;
    try {
      final profile = StudentProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      // A profile with no career cannot be read against anything.
      return profile.careers.isEmpty ? null : profile;
    } on Object {
      // Unreadable: written by another build, or damaged. Onboarding again is
      // better than a crash on launch.
      return null;
    }
  }

  @override
  Future<void> save(StudentProfile profile) async {
    if (!await _prefs.setString(profileKey, jsonEncode(profile.toJson()))) {
      throw StateError('the profile could not be written to this device');
    }
  }

  @override
  Future<void> clear() => _prefs.remove(profileKey);

  @override
  String? language() => _prefs.getString(languageKey);

  @override
  Future<void> saveLanguage(String languageCode) =>
      _prefs.setString(languageKey, languageCode);
}

/// Overridden in main() with the device's store, and in tests with a fake.
final profileStoreProvider = Provider<ProfileStore>(
  (ref) => throw UnimplementedError('profileStoreProvider is overridden at startup'),
);

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The id of the profile this session is looking at, once onboarding saves one.
class CurrentProfile extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String id) => state = id;

  void clear() => state = null;
}

final currentProfileProvider =
    NotifierProvider<CurrentProfile, String?>(CurrentProfile.new);

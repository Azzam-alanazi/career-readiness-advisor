import 'package:career_readiness/app.dart';
import 'package:career_readiness/features/profile/data/profile_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Read before the first frame, so a returning student opens straight on
  // their profile and never sees onboarding flash past.
  final prefs = await SharedPreferences.getInstance();
  runApp(ProviderScope(
    retry: noAutomaticRetry,
    overrides: [profileStoreProvider.overrideWithValue(PrefsProfileStore(prefs))],
    child: const CareerReadinessApp(),
  ));
}

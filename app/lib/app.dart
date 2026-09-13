import 'package:career_readiness/core/locale/locale_controller.dart';
import 'package:career_readiness/home_shell.dart';
import 'package:career_readiness/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Automatic retry is off.
///
/// Riverpod 3 retries a failed provider with backoff by default, which would
/// leave a student watching a spinner while an unreachable backend is retried.
/// An error with a "try again" button is more honest. The tests use this same
/// policy, so what is tested is what ships.
Duration? noAutomaticRetry(int retryCount, Object error) => null;

class CareerReadinessApp extends ConsumerWidget {
  const CareerReadinessApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      // Switching to Arabic flips the whole tree to right-to-left: the global
      // localization delegates supply the text direction for the locale.
      locale: ref.watch(localeProvider),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: ThemeData(colorSchemeSeed: const Color(0xFF00695C)),
      home: const HomeShell(),
    );
  }
}

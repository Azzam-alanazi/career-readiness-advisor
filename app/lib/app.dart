import 'package:career_readiness/core/locale/locale_controller.dart';
import 'package:career_readiness/core/theme/app_theme.dart';
import 'package:career_readiness/home_shell.dart';
import 'package:career_readiness/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Automatic retry is off.
///
/// Riverpod 3 retries a failed provider with backoff by default, which would
/// leave a student watching a spinner while an unreachable backend is retried.
/// An error with a "try again" button is more honest. The tests use this same
/// policy, so what is tested is what ships.
Duration? noAutomaticRetry(int retryCount, Object error) => null;

/// The app is built in the iOS design language -- navigation bars, grouped
/// lists, sheets, the tab bar -- and looks the same on Android. Light and dark
/// follow the phone's setting.
class CareerReadinessApp extends ConsumerWidget {
  const CareerReadinessApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return CupertinoApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      // Switching to Arabic flips the whole tree to right-to-left: the global
      // localization delegates supply the text direction for the locale.
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: appTheme(locale),
      home: const HomeShell(),
    );
  }
}

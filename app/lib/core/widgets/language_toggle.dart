import 'package:career_readiness/core/locale/locale_controller.dart';
import 'package:career_readiness/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shows the name of the *other* language, in that language, which is what a
/// reader of either one needs to find it.
class LanguageToggle extends ConsumerWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton.icon(
      onPressed: () => ref.read(localeProvider.notifier).toggle(),
      icon: const Icon(Icons.translate),
      label: Text(AppLocalizations.of(context).switchLanguage),
    );
  }
}

import 'package:career_readiness/core/locale/locale_controller.dart';
import 'package:career_readiness/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A navigation-bar button naming the *other* language, in that language,
/// which is what a reader of either one needs to find it.
class LanguageToggle extends ConsumerWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => CupertinoButton(
        padding: EdgeInsets.zero,
        sizeStyle: CupertinoButtonSize.small,
        onPressed: () => ref.read(localeProvider.notifier).toggle(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(CupertinoIcons.globe, size: 20),
            const SizedBox(width: 4),
            Text(AppLocalizations.of(context).switchLanguage),
          ],
        ),
      );
}

import 'package:career_readiness/core/theme/app_theme.dart';
import 'package:flutter/cupertino.dart';

/// Narrow side margins, so two buttons can share a bar on a small phone with
/// their labels on one line.
const _padding = EdgeInsets.symmetric(horizontal: 10, vertical: 14);

/// The one thing a screen asks the student to do next: full width, filled.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.busy = false});

  final String label;
  final VoidCallback? onPressed;

  /// Shows a spinner in place of the label while the action runs.
  final bool busy;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: CupertinoButton.filled(
          borderRadius: AppRadius.button,
          padding: _padding,
          // A disabled button reads grey on grey, not white on grey.
          foregroundColor: onPressed == null && !busy
              ? AppColors.tertiaryLabel.resolveFrom(context)
              : null,
          onPressed: busy ? null : onPressed,
          child: busy
              ? CupertinoActivityIndicator(
                  color: CupertinoTheme.of(context).primaryContrastingColor,
                )
              : Text(label, textAlign: TextAlign.center),
        ),
      );
}

/// An action beside the primary one: the same size, on a tinted wash.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: CupertinoButton.tinted(
          borderRadius: AppRadius.button,
          padding: _padding,
          onPressed: onPressed,
          child: Text(label, textAlign: TextAlign.center),
        ),
      );
}

/// A navigation-bar button that is only an icon, named for VoiceOver.
class NavIconButton extends StatelessWidget {
  const NavIconButton({super.key, required this.icon, required this.label, required this.onPressed});

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
        label: label,
        button: true,
        excludeSemantics: true,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          sizeStyle: CupertinoButtonSize.small,
          onPressed: onPressed,
          child: Icon(icon, size: 25),
        ),
      );
}

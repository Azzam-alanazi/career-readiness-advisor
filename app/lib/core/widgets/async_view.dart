import 'package:career_readiness/core/api/api_client.dart';
import 'package:career_readiness/core/theme/app_theme.dart';
import 'package:career_readiness/features/onboarding/domain/served_ids.dart';
import 'package:career_readiness/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Loading, error-with-retry, or the data. Every screen goes through this, so
/// every screen fails the same way.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    super.key,
    required this.asyncValue,
    required this.data,
    required this.onRetry,
  });

  final AsyncValue<T> asyncValue;
  final Widget Function(T data) data;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => switch (asyncValue) {
        AsyncData(:final value) => data(value),
        AsyncError(:final error) => _ErrorPanel(error: error, onRetry: onRetry),
        _ => const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CupertinoActivityIndicator(radius: 14)),
          ),
      };
}

/// [AsyncView] as a screen's whole content: the data's slivers, or a spinner
/// or an error centred in the space below the navigation bar.
class AsyncSliver<T> extends StatelessWidget {
  const AsyncSliver({
    super.key,
    required this.asyncValue,
    required this.data,
    required this.onRetry,
  });

  final AsyncValue<T> asyncValue;

  /// Builds the content as a sliver.
  final Widget Function(T data) data;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => switch (asyncValue) {
        AsyncData(:final value) => data(value),
        AsyncError(:final error) => SliverFillRemaining(
            hasScrollBody: false,
            child: _ErrorPanel(error: error, onRetry: onRetry),
          ),
        _ => const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CupertinoActivityIndicator(radius: 14)),
          ),
      };
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final type = AppType.of(context);
    final (icon, message) = switch (error) {
      ApiException(unreachable: true) => (CupertinoIcons.wifi_slash, l.errorUnreachable),
      CareerNotServed() => (CupertinoIcons.briefcase, l.errorCareerGone),
      _ => (CupertinoIcons.exclamationmark_circle, l.errorServer),
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: AppColors.secondaryLabel.resolveFrom(context)),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center, style: type.body),
            // Asking again cannot bring back a career the postings dropped;
            // the message says what will.
            if (error is! CareerNotServed) ...[
              const SizedBox(height: 18),
              CupertinoButton.tinted(
                sizeStyle: CupertinoButtonSize.medium,
                onPressed: onRetry,
                child: Text(l.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

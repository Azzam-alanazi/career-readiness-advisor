import 'package:career_readiness/core/api/api_client.dart';
import 'package:career_readiness/features/onboarding/domain/served_ids.dart';
import 'package:career_readiness/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
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
        _ => const Center(child: CircularProgressIndicator()),
      };
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final message = switch (error) {
      ApiException(unreachable: true) => l.errorUnreachable,
      CareerNotServed() => l.errorCareerGone,
      _ => l.errorServer,
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 40),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            // Asking again cannot bring back a career the postings dropped;
            // the message says what will.
            if (error is! CareerNotServed) ...[
              const SizedBox(height: 16),
              FilledButton.tonal(onPressed: onRetry, child: Text(l.retry)),
            ],
          ],
        ),
      ),
    );
  }
}

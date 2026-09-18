import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens a web address outside the app; true when something opened it. An
/// address that does not parse, or a device with nothing to open it, is false
/// rather than an error.
typedef LinkOpener = Future<bool> Function(String url);

/// The browser, on a device. Tests override it to see what would have opened
/// without a platform plugin behind it.
final linkOpenerProvider = Provider<LinkOpener>((ref) => (url) async {
      final uri = Uri.tryParse(url);
      if (uri == null) return false;
      try {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } on Exception {
        return false;
      }
    });

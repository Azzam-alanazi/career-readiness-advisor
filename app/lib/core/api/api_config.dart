import 'package:flutter/foundation.dart';

/// Where the backend lives, when the build does not say.
///
/// The FastAPI backend runs on port 8000 of the development machine. The
/// Android emulator sees that machine as 10.0.2.2; the iOS simulator, a
/// desktop build and a browser see it as 127.0.0.1. A physical phone needs the
/// machine's address on the local network, given at build time:
///
///     flutter run --dart-define=API_BASE_URL=http://192.168.1.20:8000
///
/// On an iPhone, plain HTTP to an IP address is outside App Transport
/// Security, so no exception is needed for it.
const _override = String.fromEnvironment('API_BASE_URL');

String get apiBaseUrl {
  if (_override.isNotEmpty) return _override;
  final androidEmulator = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  return androidEmulator ? 'http://10.0.2.2:8000' : 'http://127.0.0.1:8000';
}

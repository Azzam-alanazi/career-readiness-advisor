/// Where the backend lives.
///
/// The default, 10.0.2.2, is the host machine as seen from the Android
/// emulator, where the FastAPI backend runs on port 8000. For a physical
/// device or another host, override it at build time:
///
///     flutter run --dart-define=API_BASE_URL=http://192.168.1.20:8000
const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8000',
);

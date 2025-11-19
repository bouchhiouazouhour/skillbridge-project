class AppConfig {
  // Read from --dart-define=API_URL; default uses Android emulator host mapping
  static const apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );
}

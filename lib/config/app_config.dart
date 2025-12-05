/// Application configuration
class AppConfig {
  // API Configuration
  // Use 10.0.2.2 for Android emulator to access host machine
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api',
  );

  // Application settings
  static const String appName = 'SkillBridge';
  static const String appVersion = '1.0.0';

  // File upload constraints
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB in bytes
  static const List<String> allowedFileExtensions = ['pdf', 'docx'];

  // Timeout settings
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(minutes: 2);

  // Environment detection
  static bool get isProduction => const bool.fromEnvironment('dart.vm.product');
  static bool get isDevelopment => !isProduction;
}

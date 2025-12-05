import 'package:flutter/foundation.dart' show kIsWeb;

/// Application configuration
class AppConfig {
  // API Configuration
  // Priority: 1. Compile-time environment variable, 2. Platform default
  // Usage: flutter run --dart-define=API_BASE_URL=https://your-api.com/api
  static const String _envApiBaseUrl = String.fromEnvironment('API_BASE_URL');
  
  static String get apiBaseUrl {
    // Use environment variable if provided (for production builds)
    if (_envApiBaseUrl.isNotEmpty) {
      return _envApiBaseUrl;
    }
    // Default: Use 10.0.2.2 for Android emulator, 127.0.0.1 for web/desktop
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }
    return 'http://10.0.2.2:8000/api';
  }

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

import 'package:flutter/material.dart';
import 'core/app_config.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/service_locator.dart';
import 'screens/login_screen.dart';
import 'screens/app_shell.dart';
import 'screens/splash_screen.dart';
import 'screens/register_screen.dart';

late final ApiClient _apiClient;
late final AuthService _authService;

void main() {
  _apiClient = ApiClient(AppConfig.apiBaseUrl);
  _authService = AuthService(_apiClient);
  // Expose globally for screens that aren't yet using DI/Provider
  ServiceLocator.apiClient = _apiClient;
  ServiceLocator.authService = _authService;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF6F7F9),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
    );
    return MaterialApp(
      title: 'SkillBridge',
      theme: theme,
      routes: {
        '/splash': (context) =>
            SplashScreen(api: _apiClient, auth: _authService),
        '/login': (context) => LoginScreen(auth: _authService),
        '/register': (context) => RegisterScreen(auth: _authService),
        '/app': (context) => AppShell(auth: _authService),
      },
      initialRoute: '/splash',
    );
  }
}

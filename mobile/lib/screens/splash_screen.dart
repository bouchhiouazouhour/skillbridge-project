import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';

/// SplashScreen checks for an existing auth token and routes accordingly.
class SplashScreen extends StatefulWidget {
  final ApiClient api;
  final AuthService auth;
  const SplashScreen({super.key, required this.api, required this.auth});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final token = await widget.api.getToken();
    if (!mounted) return;
    if (token == null) {
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }
    // Optionally verify token via /me
    try {
      await widget.auth.me();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/app');
      }
    } catch (_) {
      // Token invalid; clear and go to login
      await widget.api.clearToken();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            FlutterLogo(size: 72),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

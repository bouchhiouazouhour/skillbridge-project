import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skillbridge_frontend/providers/user_provider.dart';
import 'package:skillbridge_frontend/screens/auth/login_screen.dart';
import 'package:skillbridge_frontend/screens/home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Démarrage de la vérification utilisateur
    Timer(const Duration(seconds: 3), () async {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.loadUser();

      if (mounted) {
        if (userProvider.isAuthenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) =>  HomeScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: null,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E88E5), Color(0xFF43A047)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo (tu peux mettre ton image ici)
              Image.asset(
                'assets/logo.png',
                height: 120,
              ),
              const SizedBox(height: 20),
              const Text(
                'SkillBridge',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              const CircularProgressIndicator(
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

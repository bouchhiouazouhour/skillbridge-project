import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skillbridge_frontend/providers/user_provider.dart';
import 'package:skillbridge_frontend/screens/auth/login_screen.dart';
import 'package:skillbridge_frontend/screens/auth/register_screen.dart';
import 'package:skillbridge_frontend/screens/auth/splash_screen.dart';
import 'package:skillbridge_frontend/screens/home/home_screen.dart';
import 'package:skillbridge_frontend/screens/cv/cv_upload_screen.dart';
import 'package:skillbridge_frontend/screens/results/results_screen.dart';
import 'package:skillbridge_frontend/screens/dashboard/dashboard_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SkillBridge',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/cv-upload': (context) => const CVUploadScreen(), // ✅ Route manquante
        '/results': (context) => const ResultsScreen(),     // ✅ Route manquante
      },
    );
  }
}
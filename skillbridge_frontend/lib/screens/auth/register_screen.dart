import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skillbridge_frontend/core/services/api_service.dart';
import 'package:skillbridge_frontend/providers/user_provider.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  bool isLoading = false;

  void register() async {
    setState(() => isLoading = true);
    final response = await ApiService.register(
      nameCtrl.text,
      emailCtrl.text,
      passCtrl.text,
      confirmCtrl.text,
    );
    bool success = response['success'] == true && response['data'] != null;
    setState(() => isLoading = false);

    if (success) {
      final data = response['data'] as Map<String, dynamic>;
      final token = data['token'] as String?;
      final user = data['user'] as Map<String, dynamic>?;
      if (token != null && user != null) {
        if (!mounted) return;
        context.read<UserProvider>().setUser(token, user);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration successful")),
        );
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Unexpected response format")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            (response['message'] ?? 'Registration failed').toString(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 50),
                Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person_outline),
                    hintText: 'Full Name',
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email_outlined),
                    hintText: 'Email',
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.lock_outline),
                    hintText: 'Password',
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: confirmCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.lock_outline),
                    hintText: 'Confirm Password',
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: isLoading ? null : register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 60,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(isLoading ? "Loading..." : "Register"),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: const Text("Already have an account? Log in"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

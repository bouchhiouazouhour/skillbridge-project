import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/api_service.dart';
import '../../providers/user_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);

    final response = await ApiService.login(
      _emailController.text,
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (response['success'] == true && response['data'] != null) {
      final data = response['data'] as Map<String, dynamic>;
      final token = data['token'] as String?;
      final user = data['user'] as Map<String, dynamic>?;
      if (token != null && user != null) {
        if (!mounted) return;
        context.read<UserProvider>().setUser(token, user);
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unexpected response format.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text((response['message'] ?? 'Login failed').toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Bienvenue sur SkillBridge",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              CustomInputField(controller: _emailController, hintText: "Email"),
              const SizedBox(height: 10),
              CustomInputField(
                controller: _passwordController,
                hintText: "Mot de passe",
                obscureText: true,
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: _isLoading ? "Connexion..." : "Se connecter",
                onPressed: _isLoading ? null : _login,
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text("Créer un compte"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

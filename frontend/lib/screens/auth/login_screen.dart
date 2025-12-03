import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
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
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // --- Vérification : champs vides ---
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return;
    }

    // --- Vérification : email valide ---
    if (!email.contains("@") || !email.contains(".")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email invalide")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final response = await ApiService.login(email, password);

    setState(() => _isLoading = false);

    // --- En cas de succès ---
    if (response['status'] == 'success') {
      Navigator.pushReplacementNamed(context, '/home');
      return;
    }

    // --- Erreurs Laravel ---
    if (response['errors'] != null) {
      String errorMessage =
          response['errors']['email']?[0] ??
          response['errors']['password']?[0] ??
          "Identifiants incorrects";

      // --- Si mot de passe incorrect → réinitialiser ---
      if (errorMessage.toLowerCase().contains("incorrect")) {
        _passwordController.clear();

        // Optionnel : remettre le focus sur le champ password
        FocusScope.of(context).requestFocus(FocusNode());
        Future.delayed(Duration(milliseconds: 50), () {
          FocusScope.of(context).requestFocus(FocusNode());
        });
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage)));
      return;
    }

    // --- Message générique si backend renvoie message ---
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response['message'] ?? "Erreur de connexion")),
    );

    // Si c'est un message d'erreur type "password incorrect"
    if ((response['message'] ?? "").toLowerCase().contains("incorrect")) {
      _passwordController.clear();
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
              const Text("Bienvenue sur SkillBridge",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              CustomInputField(controller: _emailController, hintText: "Email", validator: (value) {  },),
              const SizedBox(height: 10),
              CustomInputField(
                controller: _passwordController,
                hintText: "Mot de passe",
                obscureText: true, validator: (value) {  },
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

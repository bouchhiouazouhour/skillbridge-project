import 'package:flutter/material.dart';
import 'package:skillbridge_frontend/screens/profile/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome to SkillBridge"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NewProfileScreen()),
              );
            },
            tooltip: "Mon Profil",
          ),
        ],
      ),
      body: const Center(child: Text("You are logged in!")),
    );
  }
}

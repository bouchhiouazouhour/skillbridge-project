import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Welcome to SkillBridge")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("You are logged in!"),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).pushNamed('/optimize'),
              child: const Text('Start now: Optimize your CV'),
            ),
          ],
        ),
      ),
    );
  }
}

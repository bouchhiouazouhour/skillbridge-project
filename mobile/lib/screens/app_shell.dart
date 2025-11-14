import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'optimize_screen.dart';
import 'tasks_screen.dart';
import 'profile_screen.dart';

/// AppShell hosts bottom navigation and switches between main feature areas.
class AppShell extends StatefulWidget {
  final AuthService auth;
  const AppShell({super.key, required this.auth});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = const [
      HomeScreenStub(),
      OptimizeScreen(),
      TasksScreen(),
      ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _screens[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            label: 'Optimize',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await widget.auth.logout();
          if (!context.mounted) return;
          // Redirect to splash so it re-validates auth token state
          Navigator.of(context).pushReplacementNamed('/splash');
        },
        label: const Text('Logout'),
        icon: const Icon(Icons.logout),
      ),
    );
  }
}

/// Wrapper for existing dashboard content so we can keep earlier HomeScreen implementation.
class HomeScreenStub extends StatelessWidget {
  const HomeScreenStub({super.key});
  @override
  Widget build(BuildContext context) => const HomeScreen();
}

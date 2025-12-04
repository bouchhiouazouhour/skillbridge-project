import 'package:flutter/material.dart';
import '../dashboard/dashboard_screen.dart';
import '../cv/cv_upload_screen.dart';
import '../results/results_screen.dart';
import '../profile/profile_screen.dart'; // ✅ Votre NewProfileScreen est ici

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key}); // ✅ Ajoutez const ici maintenant

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const CVUploadScreen(),
    const ResultsScreen(),
    const NewProfileScreen(), // ✅ Avec const
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A), // ✅ Thème sombre
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF2A2A2A), // ✅ Thème sombre
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upload_file),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: 'Results',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF4A90E2), // ✅ Bleu
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
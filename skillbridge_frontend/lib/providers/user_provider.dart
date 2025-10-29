import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _user;

  bool get isAuthenticated => _token != null;
  Map<String, dynamic>? get user => _user;
  String? get token => _token;

  void setUser(String token, Map<String, dynamic> userData) {
    _token = token;
    _user = userData;
    notifyListeners(); // 🔄 met à jour l’UI automatiquement
  }

  void logout() {
    _token = null;
    _user = null;
    notifyListeners();
  }

  Future<void> loadUser() async {
    // Ici, on récupérera plus tard les infos sauvegardées localement (SharedPreferences)
    await Future.delayed(const Duration(milliseconds: 300));
  }
}

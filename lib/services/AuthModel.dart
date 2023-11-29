import 'package:flutter/material.dart';

class AuthModel extends ChangeNotifier {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  void login() {
    // Lógica de inicio de sesión
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    // Lógica de cierre de sesión
    _isLoggedIn = false;
    notifyListeners();
  }
}

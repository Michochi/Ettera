import 'package:flutter/material.dart';
import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  String? _token;

  User? get user => _user;
  String? get token => _token;

  bool get isLoggedIn => _user != null && _token != null;

  void setUser(User user, {String? token}) {
    _user = user;
    if (token != null) {
      _token = token;
    }
    notifyListeners();
  }

  void updateUser(User user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    _token = null;
    notifyListeners();
  }
}

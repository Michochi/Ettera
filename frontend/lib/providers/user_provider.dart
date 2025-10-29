import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import '../services/socket_service.dart';
import '../services/notification_service.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  String? _token;
  bool _isInitialized = false;

  User? get user => _user;
  String? get token => _token;

  bool get isLoggedIn => _user != null && _token != null;
  bool get isInitialized => _isInitialized;

  // Initialize and load saved user data
  Future<void> loadUserFromPreferences() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userJson = prefs.getString('user_data');

      if (token != null && userJson != null) {
        _token = token;
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        _user = User.fromJson(userMap);

        // Connect to socket server
        SocketService().connect(_user!.id);

        // Initialize notifications
        NotificationService().initialize();

        _isInitialized = true;
        notifyListeners();
        print('User loaded from preferences: ${_user?.email}');
      } else {
        _isInitialized = true;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading user from preferences: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> setUser(User user, {String? token}) async {
    _user = user;
    if (token != null) {
      _token = token;
    }

    // Save to shared preferences
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_token != null) {
        await prefs.setString('auth_token', _token!);
      }
      await prefs.setString('user_data', json.encode(user.toJson()));
      print('User saved to preferences: ${user.email}');
    } catch (e) {
      print('Error saving user to preferences: $e');
    }

    // Connect to socket server
    SocketService().connect(user.id);

    // Initialize notifications
    NotificationService().initialize();

    notifyListeners();
  }

  void updateUser(User user) {
    _user = user;

    // Save updated user to preferences
    _saveUserToPreferences();

    notifyListeners();
  }

  Future<void> _saveUserToPreferences() async {
    if (_user == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', json.encode(_user!.toJson()));
    } catch (e) {
      print('Error saving updated user: $e');
    }
  }

  Future<void> clearUser() async {
    // Disconnect from socket server
    SocketService().disconnect();

    _user = null;
    _token = null;

    // Clear from shared preferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      print('User cleared from preferences');
    } catch (e) {
      print('Error clearing user from preferences: $e');
    }

    notifyListeners();
  }
}

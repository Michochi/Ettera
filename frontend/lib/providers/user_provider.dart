import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import '../services/socket_service.dart';
import '../services/notification_service.dart';
import '../services/message_service.dart';
import '../services/auth_service.dart';

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

        // Validate token by attempting to fetch profile
        final isValid = await _validateToken();

        if (!isValid) {
          // Token is invalid or user doesn't exist anymore - clear cache
          print('⚠️ Cached token invalid or user not found. Clearing cache...');
          await clearUser();
          _isInitialized = true;
          notifyListeners();
          return;
        }

        // Connect to socket server
        SocketService().connect(_user!.id);

        // Initialize notifications
        NotificationService().initialize();

        // Set up global message listener for notifications
        _setupGlobalMessageListener();

        _isInitialized = true;
        notifyListeners();
        print('✅ User loaded from preferences: ${_user?.email}');
      } else {
        _isInitialized = true;
        notifyListeners();
      }
    } catch (e) {
      print('❌ Error loading user from preferences: $e');
      // Clear cache on error
      await clearUser();
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Validate if the cached token is still valid
  Future<bool> _validateToken() async {
    if (_token == null) return false;

    try {
      final authService = AuthService();
      // Try to fetch profile - if it fails, token is invalid
      final response = await authService.updateProfile(
        token: _token!,
        name: _user!.name,
        email: _user!.email,
      );
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Token validation failed: $e');
      return false;
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

    // Set up global message listener for notifications
    _setupGlobalMessageListener();

    notifyListeners();
  }

  /// Set up global message listener for browser notifications
  void _setupGlobalMessageListener() {
    SocketService().onReceiveMessage((data) async {
      // Show notification when message is received
      final senderId = data['senderId'] as String;
      final content = data['content'] as String;

      // Try to get sender name from conversations
      try {
        if (_token != null) {
          final messageService = MessageService();
          final response = await messageService.getConversations(
            token: _token!,
          );

          if (response.statusCode == 200) {
            final conversations = response.data as List;

            // Find the sender in conversations
            final sender = conversations.firstWhere(
              (conv) => conv['userId'] == senderId,
              orElse: () => {'userName': 'Someone'},
            );

            final senderName = sender['userName'] ?? 'Someone';
            final senderPhoto = sender['userPhoto'];

            NotificationService().showMessageNotification(
              senderName: senderName,
              messagePreview: content.length > 50
                  ? '${content.substring(0, 50)}...'
                  : content,
              senderPhoto: senderPhoto,
            );

            print('📬 Message from $senderName: $content');
          }
        }
      } catch (e) {
        // Fallback if we can't get sender info
        NotificationService().showMessageNotification(
          senderName: 'New Message',
          messagePreview: content.length > 50
              ? '${content.substring(0, 50)}...'
              : content,
        );
        print('📬 Global message received: $e');
      }
    });
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

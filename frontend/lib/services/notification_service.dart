import 'dart:html' as html;
import 'package:flutter/foundation.dart';

/// Service for handling browser push notifications
/// Shows desktop notifications for matches and messages
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _permissionGranted = false;
  bool _isInitialized = false;

  /// Check if notifications are supported
  bool get isSupported {
    if (!kIsWeb) return false;
    return html.Notification.supported;
  }

  /// Check if permission is granted
  bool get permissionGranted => _permissionGranted;

  /// Initialize notification service and request permission
  Future<bool> initialize() async {
    if (_isInitialized) return _permissionGranted;

    if (!isSupported) {
      print('⚠️ Notifications not supported in this browser');
      return false;
    }

    try {
      final permission = html.Notification.permission;

      if (permission == 'granted') {
        _permissionGranted = true;
        _isInitialized = true;
        print('✅ Notification permission already granted');
        return true;
      } else if (permission == 'default') {
        // Request permission
        final result = await html.Notification.requestPermission();
        _permissionGranted = result == 'granted';
        _isInitialized = true;

        if (_permissionGranted) {
          print('✅ Notification permission granted');
          // Show welcome notification
          _showWelcomeNotification();
        } else {
          print('❌ Notification permission denied');
        }

        return _permissionGranted;
      } else {
        // Permission denied
        _permissionGranted = false;
        _isInitialized = true;
        print('❌ Notification permission denied');
        return false;
      }
    } catch (e) {
      print('❌ Error requesting notification permission: $e');
      _isInitialized = true;
      return false;
    }
  }

  /// Show welcome notification
  void _showWelcomeNotification() {
    if (!_permissionGranted || !isSupported) return;

    try {
      html.Notification(
        'Eterra Notifications Enabled! 🎉',
        body: "You'll now receive notifications for matches and messages",
        icon: '/icons/Icon-192.png',
      );
    } catch (e) {
      print('Error showing welcome notification: $e');
    }
  }

  /// Show notification for new match
  /// [userName] - Name of the user you matched with
  /// [userPhoto] - Profile photo URL (optional)
  void showMatchNotification({required String userName, String? userPhoto}) {
    if (!_permissionGranted || !isSupported) return;

    try {
      final notification = html.Notification(
        '💘 New Match!',
        body: 'You matched with $userName',
        icon: userPhoto ?? '/icons/Icon-192.png',
        tag: 'match-notification',
      );

      // Auto close after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        notification.close();
      });

      // Handle click - could navigate to matches page
      notification.onClick.listen((event) {
        try {
          html.window.location.reload();
        } catch (e) {
          print('Error focusing window: $e');
        }
        notification.close();
        // Navigate to matches page
        print('Navigate to matches page');
      });
    } catch (e) {
      print('Error showing match notification: $e');
    }
  }

  /// Show notification for new message
  /// [senderName] - Name of message sender
  /// [messagePreview] - Preview of the message content
  /// [senderPhoto] - Profile photo URL (optional)
  void showMessageNotification({
    required String senderName,
    required String messagePreview,
    String? senderPhoto,
  }) {
    if (!_permissionGranted || !isSupported) return;

    try {
      final notification = html.Notification(
        '💬 New message from $senderName',
        body: messagePreview,
        icon: senderPhoto ?? '/icons/Icon-192.png',
        tag: 'message-notification',
      );

      // Auto close after 6 seconds
      Future.delayed(const Duration(seconds: 6), () {
        notification.close();
      });

      // Handle click - focus window
      notification.onClick.listen((event) {
        notification.close();
        // Navigate to messages page
        print('Navigate to messages page');
      });
    } catch (e) {
      print('Error showing message notification: $e');
    }
  }

  /// Show notification for multiple new messages
  /// [count] - Number of unread messages
  void showMultipleMessagesNotification(int count) {
    if (!_permissionGranted || !isSupported) return;

    try {
      final notification = html.Notification(
        '💬 $count New Messages',
        body: 'You have $count unread messages',
        icon: '/icons/Icon-192.png',
        tag: 'messages-notification',
      );

      Future.delayed(const Duration(seconds: 5), () {
        notification.close();
      });

      notification.onClick.listen((event) {
        notification.close();
      });
    } catch (e) {
      print('Error showing multiple messages notification: $e');
    }
  }

  /// Show custom notification
  /// [title] - Notification title
  /// [body] - Notification body text
  /// [icon] - Icon URL (optional)
  void showCustomNotification({
    required String title,
    required String body,
    String? icon,
  }) {
    if (!_permissionGranted || !isSupported) return;

    try {
      final notification = html.Notification(
        title,
        body: body,
        icon: icon ?? '/icons/Icon-192.png',
      );

      Future.delayed(const Duration(seconds: 5), () {
        notification.close();
      });

      notification.onClick.listen((event) {
        notification.close();
      });
    } catch (e) {
      print('Error showing custom notification: $e');
    }
  }

  /// Request permission again (if denied)
  Future<bool> requestPermission() async {
    return await initialize();
  }

  /// Check current permission status
  String getPermissionStatus() {
    if (!isSupported) return 'not-supported';
    return html.Notification.permission ?? 'default';
  }
}

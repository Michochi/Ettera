import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../utils/constants.dart';

/// Singleton service for managing WebSocket connections
/// Provides real-time messaging and typing indicators
class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;

  /// Get connection status
  bool get isConnected => _isConnected;

  /// Connect to WebSocket server
  /// [userId] - The authenticated user's ID
  void connect(String userId) {
    if (_isConnected) {
      print('⚠️ Socket already connected');
      return;
    }

    try {
      _socket = IO.io(
        socketUrl, // Use constant instead of hardcoded URL
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build(),
      );

      _socket!.connect();

      _socket!.onConnect((_) {
        print('✅ Connected to socket server');
        _isConnected = true;
        _socket!.emit('join', userId);
      });

      _socket!.onDisconnect((_) {
        print('❌ Disconnected from socket server');
        _isConnected = false;
      });

      _socket!.onError((error) {
        print('❌ Socket error: $error');
      });
    } catch (e) {
      print('❌ Failed to connect socket: $e');
    }
  }

  /// Send a message to another user
  /// [senderId] - The sender's user ID
  /// [receiverId] - The receiver's user ID
  /// [content] - The message content
  void sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
  }) {
    if (!_isConnected) {
      print('⚠️ Socket not connected');
      return;
    }

    _socket!.emit('send_message', {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Listen for incoming messages
  /// [callback] - Function to call when a message is received
  void onReceiveMessage(Function(Map<String, dynamic>) callback) {
    _socket?.on('receive_message', (data) {
      callback(data);
    });
  }

  /// Remove message listener
  void offReceiveMessage() {
    _socket?.off('receive_message');
  }

  /// Send typing indicator
  /// [senderId] - The user who is typing
  /// [receiverId] - The user who should see the typing indicator
  void sendTyping({required String senderId, required String receiverId}) {
    if (!_isConnected) return;

    _socket!.emit('typing', {'senderId': senderId, 'receiverId': receiverId});
  }

  /// Send stop typing indicator
  /// [senderId] - The user who stopped typing
  /// [receiverId] - The user who should see the indicator removed
  void sendStopTyping({required String senderId, required String receiverId}) {
    if (!_isConnected) return;

    _socket!.emit('stop_typing', {
      'senderId': senderId,
      'receiverId': receiverId,
    });
  }

  /// Listen for typing indicators
  /// [callback] - Function to call when user is typing
  void onUserTyping(Function(String userId) callback) {
    _socket?.on('user_typing', (data) {
      callback(data['userId']);
    });
  }

  /// Listen for stop typing indicators
  /// [callback] - Function to call when user stops typing
  void onUserStopTyping(Function(String userId) callback) {
    _socket?.on('user_stop_typing', (data) {
      callback(data['userId']);
    });
  }

  /// Remove typing listeners
  void offTypingListeners() {
    _socket?.off('user_typing');
    _socket?.off('user_stop_typing');
  }

  /// Listen for user online status
  /// [callback] - Function to call when a user comes online
  void onUserOnline(Function(String userId) callback) {
    _socket?.on('user_online', (userId) {
      callback(userId);
    });
  }

  /// Listen for user offline status
  /// [callback] - Function to call when a user goes offline
  void onUserOffline(Function(String userId) callback) {
    _socket?.on('user_offline', (userId) {
      callback(userId);
    });
  }

  /// Remove online/offline listeners
  void offStatusListeners() {
    _socket?.off('user_online');
    _socket?.off('user_offline');
  }

  /// Listen for unmatch events
  /// [callback] - Function to call when user gets unmatched
  void onUserUnmatched(Function(String userId) callback) {
    _socket?.on('user_unmatched', (data) {
      callback(data['userId']);
    });
  }

  /// Remove unmatch listener
  void offUnmatchListener() {
    _socket?.off('user_unmatched');
  }

  /// Disconnect from socket server
  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
      print('🔌 Socket disconnected');
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../widgets/app_theme.dart';
import '../providers/user_provider.dart';
import '../models/message_model.dart';
import '../services/message_service.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String? userPhoto;
  final bool isOnline;

  const ChatScreen({
    super.key,
    required this.userId,
    required this.userName,
    this.userPhoto,
    this.isOnline = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  IO.Socket? _socket;
  bool _isUserTyping = false;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _initializeSocket();
  }

  void _initializeSocket() {
    final userProvider = context.read<UserProvider>();
    final currentUserId = userProvider.user?.id;

    debugPrint('🔧 Initializing socket...');
    debugPrint('   User ID: $currentUserId');

    if (currentUserId == null) {
      debugPrint('❌ Cannot initialize socket: User ID is null');
      return;
    }

    try {
      debugPrint('🔧 Creating socket instance...');
      // Initialize Socket.IO connection
      _socket = IO.io(
        'http://localhost:4000',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build(),
      );

      debugPrint('✅ Socket instance created');

      // Connection events
      _socket!.onConnect((_) {
        debugPrint('✅ Socket connected');
        setState(() {
          _isConnected = true;
        });

        // Join the socket with user ID
        _socket!.emit('join', currentUserId);
        debugPrint('📤 Emitted join event with userId: $currentUserId');
      });

      _socket!.onConnectError((error) {
        debugPrint('❌ Socket connection error: $error');
        setState(() {
          _isConnected = false;
        });
      });

      _socket!.onDisconnect((_) {
        debugPrint('🔌 Socket disconnected');
        setState(() {
          _isConnected = false;
        });
      });

      // Listen for incoming messages
      _socket!.on('receive_message', (data) {
        debugPrint('📥 Received message: $data');

        try {
          final newMessage = Message(
            id: data['_id'] ?? '',
            senderId: data['senderId'] ?? '',
            receiverId: data['receiverId'] ?? '',
            content: data['content'] ?? '',
            timestamp: data['createdAt'] != null
                ? DateTime.parse(data['createdAt'])
                : DateTime.now(),
            isRead: data['isRead'] ?? false,
          );

          setState(() {
            _messages.add(newMessage);
          });

          // Auto-scroll to bottom
          Future.delayed(const Duration(milliseconds: 100), () {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });

          // Mark as read if receiver is viewing chat
          if (data['senderId'] == widget.userId) {
            final messageService = MessageService();
            messageService.markAsRead(
              token: userProvider.token!,
              otherUserId: widget.userId,
            );
          }
        } catch (e) {
          debugPrint('❌ Error processing received message: $e');
        }
      });

      // Listen for typing indicator
      _socket!.on('user_typing', (data) {
        debugPrint('⌨️ User typing: $data');
        if (data['userId'] == widget.userId) {
          setState(() {
            _isUserTyping = true;
          });

          // Hide typing indicator after 3 seconds
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _isUserTyping = false;
              });
            }
          });
        }
      });

      // Listen for user online/offline status
      _socket!.on('user_online', (userId) {
        debugPrint('🟢 User online: $userId');
        // You can update UI to show online status if needed
      });

      _socket!.on('user_offline', (userId) {
        debugPrint('🔴 User offline: $userId');
        // You can update UI to show offline status if needed
      });

      // Connect to the socket server
      debugPrint('🔄 Calling socket.connect()...');
      _socket!.connect();
      debugPrint('✅ Socket.connect() called - waiting for connection...');
    } catch (e) {
      debugPrint('❌ Error initializing socket: $e');
      debugPrint('❌ Stack trace: ${StackTrace.current}');
    }
  }

  void _handleTyping() {
    if (_socket != null && _isConnected) {
      final userProvider = context.read<UserProvider>();
      _socket!.emit('typing', {
        'userId': userProvider.user?.id,
        'receiverId': widget.userId,
      });
      debugPrint('⌨️ Emitted typing event to ${widget.userId}');
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();

    // Disconnect socket
    if (_socket != null) {
      debugPrint('🔌 Disconnecting socket...');
      _socket!.disconnect();
      _socket!.dispose();
    }

    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = context.read<UserProvider>();
      if (userProvider.token == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final messageService = MessageService();
      final response = await messageService.getMessages(
        token: userProvider.token!,
        otherUserId: widget.userId,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        setState(() {
          _messages.clear();
          _messages.addAll(
            data.map((json) {
              return Message(
                id: json['_id'] ?? '',
                senderId: json['senderId'] ?? '',
                receiverId: json['receiverId'] ?? '',
                content: json['content'] ?? '',
                timestamp: json['createdAt'] != null
                    ? DateTime.parse(json['createdAt'])
                    : DateTime.now(),
                isRead: json['isRead'] ?? false,
              );
            }).toList(),
          );
        });

        // Scroll to bottom after loading
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(
              _scrollController.position.maxScrollExtent,
            );
          }
        });

        // Mark messages as read
        await messageService.markAsRead(
          token: userProvider.token!,
          otherUserId: widget.userId,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load messages: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isSending) return;

    final content = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _isSending = true;
    });

    try {
      final userProvider = context.read<UserProvider>();
      if (userProvider.token == null) {
        setState(() {
          _isSending = false;
        });
        return;
      }

      final messageService = MessageService();
      final response = await messageService.sendMessage(
        token: userProvider.token!,
        receiverId: widget.userId,
        content: content,
      );

      if (response.statusCode == 201) {
        final json = response.data;
        final newMessage = Message(
          id: json['_id'] ?? '',
          senderId: json['senderId'] ?? userProvider.user!.id,
          receiverId: json['receiverId'] ?? widget.userId,
          content: json['content'] ?? content,
          timestamp: json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
          isRead: json['isRead'] ?? false,
        );

        // Add message to local list
        setState(() {
          _messages.add(newMessage);
        });

        // Send via WebSocket for real-time delivery to receiver
        if (_socket != null && _isConnected) {
          debugPrint('\n📤 Attempting to send via WebSocket:');
          debugPrint('   Socket connected: $_isConnected');
          debugPrint('   Receiver ID: ${widget.userId}');
          debugPrint('   Sender ID: ${newMessage.senderId}');
          debugPrint('   Message content: ${newMessage.content}');

          _socket!.emit('send_message', {
            'receiverId': widget.userId,
            'message': {
              '_id': newMessage.id,
              'senderId': newMessage.senderId,
              'receiverId': newMessage.receiverId,
              'content': newMessage.content,
              'createdAt': newMessage.timestamp.toIso8601String(),
              'isRead': newMessage.isRead,
            },
          });
          debugPrint('✅ WebSocket emit completed');
        } else {
          debugPrint('❌ Cannot send via WebSocket:');
          debugPrint('   Socket null: ${_socket == null}');
          debugPrint('   Socket connected: $_isConnected');
        }

        // Scroll to bottom
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (e) {
      debugPrint('❌ Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  String _formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final currentUserId = userProvider.user?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: AppTheme.darkGray.withOpacity(0.1),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.darkGray),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: widget.userPhoto == null
                        ? LinearGradient(
                            colors: [
                              AppTheme.primaryGold.withOpacity(0.3),
                              AppTheme.primaryGold.withOpacity(0.6),
                            ],
                          )
                        : null,
                    image: widget.userPhoto != null
                        ? DecorationImage(
                            image: NetworkImage(widget.userPhoto!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: widget.userPhoto == null
                      ? Icon(
                          Icons.person,
                          size: 24,
                          color: Colors.white.withOpacity(0.8),
                        )
                      : null,
                ),
                if (widget.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Name and status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.userName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkGray,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.isOnline)
                    Text(
                      'Active now',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.videocam, color: AppTheme.primaryGold),
            onPressed: () {
              // TODO: Implement video call
            },
          ),
          IconButton(
            icon: Icon(Icons.phone, color: AppTheme.primaryGold),
            onPressed: () {
              // TODO: Implement voice call
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: AppTheme.darkGray),
            onPressed: () {
              // TODO: Show more options
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.backgroundColor,
              AppTheme.primaryGold.withOpacity(0.03),
            ],
          ),
        ),
        child: Column(
          children: [
            // Messages list
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryGold,
                      ),
                    )
                  : _messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGold.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: AppTheme.primaryGold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Start the conversation',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkGray,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Say hello to ${widget.userName}!',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.darkGray.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final isMe = message.senderId == currentUserId;
                        final showTime =
                            index == 0 ||
                            _messages[index - 1].timestamp
                                    .difference(message.timestamp)
                                    .inMinutes
                                    .abs() >
                                5;

                        return _buildMessageBubble(message, isMe, showTime);
                      },
                    ),
            ),
            // Typing indicator
            if (_isUserTyping)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Text(
                      '${widget.userName} is typing',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.darkGray.withOpacity(0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.primaryGold,
                      ),
                    ),
                  ],
                ),
              ),
            // Message input
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.darkGray.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    // Emoji/attachment button
                    IconButton(
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: AppTheme.primaryGold,
                        size: 28,
                      ),
                      onPressed: () {
                        // TODO: Show attachment options
                      },
                    ),
                    const SizedBox(width: 8),
                    // Message input field
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(
                              color: AppTheme.darkGray.withOpacity(0.5),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          maxLines: null,
                          textCapitalization: TextCapitalization.sentences,
                          onChanged: (_) => _handleTyping(),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Send button
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryGold,
                            AppTheme.primaryGold.withOpacity(0.8),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryGold.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isSending ? Icons.hourglass_empty : Icons.send,
                          color: Colors.white,
                        ),
                        onPressed: _isSending ? null : _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Message message, bool isMe, bool showTime) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (showTime)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _formatMessageTime(message.timestamp),
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.darkGray.withOpacity(0.5),
                ),
              ),
            ),
          Row(
            mainAxisAlignment: isMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: isMe
                        ? LinearGradient(
                            colors: [
                              AppTheme.primaryGold,
                              AppTheme.primaryGold.withOpacity(0.85),
                            ],
                          )
                        : null,
                    color: isMe ? null : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isMe ? 20 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isMe ? AppTheme.primaryGold : AppTheme.darkGray)
                            .withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 15,
                      color: isMe ? Colors.white : AppTheme.darkGray,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

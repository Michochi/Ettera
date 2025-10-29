import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
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

        setState(() {
          _messages.add(newMessage);
        });

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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/app_theme.dart';
import '../models/message_model.dart';
import '../services/message_service.dart';
import '../services/socket_service.dart';
import '../providers/user_provider.dart';
import '../utils/error_handler.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SocketService _socketService = SocketService();
  Timer? _typingTimer;
  bool _isTyping = false;
  bool _isOtherUserTyping = false;
  bool _isLoading = false;
  bool _isLoadingMessages = false;
  bool _isSending = false;
  List<Conversation> _conversations = [];
  List<Conversation> _filteredConversations = [];
  Conversation? _selectedConversation;
  List<Message> _messages = [];
  bool _showMobileChatView = false; // Track mobile chat view state
  bool _hasCheckedArguments = false; // Track if we've checked route arguments

  @override
  void initState() {
    super.initState();
    _loadConversations();
    _setupSocketListeners();

    // Listen for typing
    _messageController.addListener(_onTyping);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Check for route arguments only once
    if (!_hasCheckedArguments) {
      _hasCheckedArguments = true;
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args != null && args.containsKey('userId')) {
        final userId = args['userId'] as String;
        // Find the conversation with this user
        _openConversationByUserId(userId);
      }
    }
  }

  void _openConversationByUserId(String userId) {
    // Wait for conversations to load, then select the conversation
    Future.delayed(const Duration(milliseconds: 500), () {
      final conversation = _conversations.firstWhere(
        (conv) => conv.userId == userId,
        orElse: () => Conversation(
          id: userId,
          userId: userId,
          userName: 'User',
          userPhoto: null,
          lastMessage: '',
          lastMessageTime: DateTime.now(),
          unreadCount: 0,
          isOnline: false,
        ),
      );

      if (mounted) {
        setState(() {
          _selectedConversation = conversation;
          _showMobileChatView = true;
        });
        _loadMessages(userId);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    _socketService.offReceiveMessage();
    _socketService.offTypingListeners();
    super.dispose();
  }

  /// Setup socket listeners for real-time updates
  void _setupSocketListeners() {
    // Listen for incoming messages
    _socketService.onReceiveMessage((data) {
      final newMessage = Message(
        id: data['_id'] ?? '',
        senderId: data['senderId'] ?? '',
        receiverId: data['receiverId'] ?? '',
        content: data['content'] ?? '',
        timestamp: data['timestamp'] != null
            ? DateTime.parse(data['timestamp'])
            : DateTime.now(),
        isRead: false,
      );

      // Only add if it's from the current conversation
      if (_selectedConversation != null &&
          (newMessage.senderId == _selectedConversation!.userId ||
              newMessage.receiverId == _selectedConversation!.userId)) {
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

      // Refresh conversations list
      _loadConversations();
    });

    // Listen for typing indicators
    _socketService.onUserTyping((userId) {
      if (_selectedConversation != null &&
          userId == _selectedConversation!.userId) {
        setState(() {
          _isOtherUserTyping = true;
        });
      }
    });

    _socketService.onUserStopTyping((userId) {
      if (_selectedConversation != null &&
          userId == _selectedConversation!.userId) {
        setState(() {
          _isOtherUserTyping = false;
        });
      }
    });
  }

  /// Handle typing indicator
  void _onTyping() {
    if (_selectedConversation == null) return;

    final userProvider = context.read<UserProvider>();
    if (userProvider.user == null) return;

    final text = _messageController.text;

    if (text.isNotEmpty && !_isTyping) {
      _isTyping = true;
      _socketService.sendTyping(
        senderId: userProvider.user!.id,
        receiverId: _selectedConversation!.userId,
      );
    }

    // Cancel previous timer
    _typingTimer?.cancel();

    // Stop typing after 2 seconds of inactivity
    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (_isTyping) {
        _isTyping = false;
        _socketService.sendStopTyping(
          senderId: userProvider.user!.id,
          receiverId: _selectedConversation!.userId,
        );
      }
    });
  }

  Future<void> _loadMessages(String otherUserId) async {
    setState(() {
      _isLoadingMessages = true;
      _messages.clear(); // Clear messages immediately
    });

    try {
      final userProvider = context.read<UserProvider>();
      if (userProvider.token == null) {
        setState(() {
          _isLoadingMessages = false;
        });
        return;
      }

      final messageService = MessageService();
      final response = await messageService.getMessages(
        token: userProvider.token!,
        otherUserId: otherUserId,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data is List) {
          final messagesList = data.map((json) {
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
          }).toList();

          setState(() {
            _messages = messagesList;
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
            otherUserId: otherUserId,
          );
        } else {
          print('Invalid messages data type: ${data.runtimeType}');
          setState(() {
            _messages = [];
          });
        }
      } else {
        print('Error response: ${response.statusCode}');
        setState(() {
          _messages = [];
        });
      }
    } catch (e, stackTrace) {
      print('Error loading messages: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _messages = [];
      });
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, e);
        ErrorHandler.logError(
          e,
          stackTrace: stackTrace,
          context: 'Messages - Load Messages',
        );
      }
    } finally {
      setState(() {
        _isLoadingMessages = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty ||
        _isSending ||
        _selectedConversation == null)
      return;

    final content = _messageController.text.trim();
    _messageController.clear();

    // Stop typing indicator
    if (_isTyping) {
      _isTyping = false;
      final userProvider = context.read<UserProvider>();
      if (userProvider.user != null) {
        _socketService.sendStopTyping(
          senderId: userProvider.user!.id,
          receiverId: _selectedConversation!.userId,
        );
      }
    }

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
        receiverId: _selectedConversation!.userId,
        content: content,
      );

      if (response.statusCode == 201) {
        final json = response.data;
        if (json != null && json is Map) {
          final newMessage = Message(
            id: json['_id'] ?? '',
            senderId: json['senderId'] ?? userProvider.user!.id,
            receiverId: json['receiverId'] ?? _selectedConversation!.userId,
            content: json['content'] ?? content,
            timestamp: json['createdAt'] != null
                ? DateTime.parse(json['createdAt'])
                : DateTime.now(),
            isRead: json['isRead'] ?? false,
          );

          setState(() {
            _messages.add(newMessage);
          });

          // Send via WebSocket for real-time delivery
          _socketService.sendMessage(
            senderId: userProvider.user!.id,
            receiverId: _selectedConversation!.userId,
            content: content,
          );

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
        } else {
          print('Invalid response data: $json');
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.logError(e, context: 'Messages - Send Message');
      }
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  Future<void> _loadConversations() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = context.read<UserProvider>();

      // Wait for provider to be initialized
      if (!userProvider.isInitialized) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (!mounted) return;
        return _loadConversations();
      }

      if (userProvider.token == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final messageService = MessageService();
      final response = await messageService.getConversations(
        token: userProvider.token!,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = response.data;
        print('Conversations response: $data'); // Debug log
        setState(() {
          _conversations.clear();
          if (data != null && data is List) {
            print('Conversations loaded: ${data.length}'); // Debug log
            _conversations = data.map((json) {
              return Conversation(
                id: json['_id'] ?? '',
                userId: json['userId'] ?? '',
                userName: json['userName'] ?? 'Unknown',
                userPhoto: json['userPhoto'],
                lastMessage: json['lastMessage'] ?? '',
                lastMessageTime: json['lastMessageTime'] != null
                    ? DateTime.parse(json['lastMessageTime'])
                    : DateTime.now(),
                unreadCount: json['unreadCount'] ?? 0,
                isOnline: json['isOnline'] ?? false,
              );
            }).toList();
          } else {
            print('Data is null or not a List: $data');
          }
          _filteredConversations = _conversations;
        });
      } else {
        print('Error: Status ${response.statusCode}'); // Debug log
      }
    } catch (e, stackTrace) {
      print('Error loading conversations: $e'); // Debug log
      print('Stack trace: $stackTrace'); // Debug log
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, e);
        ErrorHandler.logError(
          e,
          stackTrace: stackTrace,
          context: 'Messages - Load Conversations',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterConversations(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredConversations = _conversations;
      } else {
        _filteredConversations = _conversations
            .where(
              (conv) =>
                  conv.userName.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.backgroundColor,
              AppTheme.primaryGold.withOpacity(0.05),
              AppTheme.backgroundColor,
            ],
          ),
        ),
        child: Column(
          children: [
            const CustomAppBar(),
            Expanded(
              child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
            ),
          ],
        ),
      ),
      drawer: const CustomDrawer(),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Left sidebar - Chat heads
        Container(
          width: 380,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: AppTheme.darkGray.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(2, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppTheme.darkGray.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Messages',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkGray,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Search bar
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _filterConversations,
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          hintStyle: TextStyle(
                            color: AppTheme.darkGray.withOpacity(0.5),
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppTheme.darkGray.withOpacity(0.5),
                            size: 20,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: AppTheme.darkGray.withOpacity(0.5),
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    _filterConversations('');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Conversations list
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryGold,
                        ),
                      )
                    : _filteredConversations.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: _filteredConversations.length,
                        itemBuilder: (context, index) {
                          final conversation = _filteredConversations[index];
                          final isSelected =
                              _selectedConversation?.id == conversation.id;
                          return _buildChatHead(conversation, isSelected);
                        },
                      ),
              ),
            ],
          ),
        ),
        // Right side - Chat box
        Expanded(
          child: _selectedConversation == null
              ? _buildNoChatSelected()
              : _buildChatBox(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    // If a conversation is selected, show the chat view
    if (_showMobileChatView && _selectedConversation != null) {
      return _buildMobileChatView();
    }

    // Otherwise show the conversation list
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Messages',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGray,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              // Search bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.darkGray.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterConversations,
                  decoration: InputDecoration(
                    hintText: 'Search conversations...',
                    hintStyle: TextStyle(
                      color: AppTheme.darkGray.withOpacity(0.5),
                    ),
                    prefixIcon: Icon(Icons.search, color: AppTheme.primaryGold),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: AppTheme.darkGray.withOpacity(0.5),
                            ),
                            onPressed: () {
                              _searchController.clear();
                              _filterConversations('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Conversations list
        Expanded(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryGold),
                )
              : _filteredConversations.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadConversations,
                  color: AppTheme.primaryGold,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: _filteredConversations.length,
                    itemBuilder: (context, index) {
                      final conversation = _filteredConversations[index];
                      return _buildConversationTile(conversation);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildMobileChatView() {
    final userProvider = context.read<UserProvider>();
    final currentUserId = userProvider.user?.id ?? '';

    return Column(
      children: [
        // Chat header with back button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: AppTheme.darkGray.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                // Back button
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showMobileChatView = false;
                      _selectedConversation = null;
                      _messages.clear();
                    });
                  },
                  icon: Icon(Icons.arrow_back, color: AppTheme.darkGray),
                ),
                const SizedBox(width: 8),
                // Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _selectedConversation!.userPhoto == null
                        ? LinearGradient(
                            colors: [
                              AppTheme.primaryGold.withOpacity(0.3),
                              AppTheme.primaryGold.withOpacity(0.6),
                            ],
                          )
                        : null,
                    image: _selectedConversation!.userPhoto != null
                        ? DecorationImage(
                            image: NetworkImage(
                              _selectedConversation!.userPhoto!,
                            ),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _selectedConversation!.userPhoto == null
                      ? Icon(
                          Icons.person,
                          size: 24,
                          color: Colors.white.withOpacity(0.8),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedConversation!.userName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.darkGray,
                        ),
                      ),
                      if (_selectedConversation!.isOnline)
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Active now',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.darkGray.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Messages
        Expanded(
          child: _isLoadingMessages
              ? Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryGold),
                )
              : _messages.isEmpty
              ? Center(
                  child: Text(
                    'No messages yet. Say hi! 👋',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.darkGray.withOpacity(0.5),
                    ),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final isSentByMe = message.senderId == currentUserId;
                    return _buildMessageBubble(message, isSentByMe);
                  },
                ),
        ),
        // Message input
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: AppTheme.darkGray.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
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
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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
                    onPressed: _isSending ? null : _sendMessage,
                    icon: _isSending
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryGold.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 48,
                color: AppTheme.primaryGold,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _searchController.text.isEmpty
                  ? 'No messages yet'
                  : 'No conversations found',
              style: TextStyle(
                color: AppTheme.darkGray,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isEmpty
                  ? 'Start matching to begin conversations'
                  : 'Try a different search term',
              style: TextStyle(
                color: AppTheme.darkGray.withOpacity(0.6),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            if (_searchController.text.isEmpty) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/browse');
                },
                icon: const Icon(Icons.favorite),
                label: const Text('Find Matches'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGold,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChatHead(Conversation conversation, bool isSelected) {
    return Material(
      color: isSelected
          ? AppTheme.primaryGold.withOpacity(0.1)
          : Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedConversation = conversation;
            _messages.clear();
          });
          _loadMessages(conversation.userId);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppTheme.darkGray.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // Avatar with online indicator
              Stack(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: conversation.userPhoto == null
                          ? LinearGradient(
                              colors: [
                                AppTheme.primaryGold.withOpacity(0.3),
                                AppTheme.primaryGold.withOpacity(0.6),
                              ],
                            )
                          : null,
                      image: conversation.userPhoto != null
                          ? DecorationImage(
                              image: NetworkImage(conversation.userPhoto!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: conversation.userPhoto == null
                        ? Icon(
                            Icons.person,
                            size: 28,
                            color: Colors.white.withOpacity(0.8),
                          )
                        : null,
                  ),
                  if (conversation.isOnline)
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: Container(
                        width: 14,
                        height: 14,
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
              // Message info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            conversation.userName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.darkGray,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (conversation.unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGold,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${conversation.unreadCount}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      conversation.lastMessage,
                      style: TextStyle(
                        fontSize: 14,
                        color: conversation.unreadCount > 0
                            ? AppTheme.darkGray
                            : AppTheme.darkGray.withOpacity(0.6),
                        fontWeight: conversation.unreadCount > 0
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatTimestamp(conversation.lastMessageTime),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.darkGray.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoChatSelected() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
            'Select a conversation',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a conversation from the list to start messaging',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.darkGray.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChatBox() {
    final userProvider = context.read<UserProvider>();
    final currentUserId = userProvider.user?.id ?? '';

    return Column(
      children: [
        // Chat header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: AppTheme.darkGray.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _selectedConversation!.userPhoto == null
                      ? LinearGradient(
                          colors: [
                            AppTheme.primaryGold.withOpacity(0.3),
                            AppTheme.primaryGold.withOpacity(0.6),
                          ],
                        )
                      : null,
                  image: _selectedConversation!.userPhoto != null
                      ? DecorationImage(
                          image: NetworkImage(
                            _selectedConversation!.userPhoto!,
                          ),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _selectedConversation!.userPhoto == null
                    ? Icon(
                        Icons.person,
                        size: 24,
                        color: Colors.white.withOpacity(0.8),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedConversation!.userName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkGray,
                      ),
                    ),
                    if (_selectedConversation!.isOnline)
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Active now',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.darkGray.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Messages
        Expanded(
          child: _isLoadingMessages
              ? Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryGold),
                )
              : _messages.isEmpty
              ? Center(
                  child: Text(
                    'No messages yet. Say hi! 👋',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.darkGray.withOpacity(0.5),
                    ),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
                  itemCount: _messages.length + (_isOtherUserTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Show typing indicator as last item
                    if (_isOtherUserTyping && index == _messages.length) {
                      return _buildTypingIndicator();
                    }

                    final message = _messages[index];
                    final isSentByMe = message.senderId == currentUserId;
                    return _buildMessageBubble(message, isSentByMe);
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
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
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
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
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
                  onPressed: _isSending ? null : _sendMessage,
                  icon: _isSending
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(Message message, bool isSentByMe) {
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          gradient: isSentByMe
              ? LinearGradient(
                  colors: [
                    AppTheme.primaryGold,
                    AppTheme.primaryGold.withOpacity(0.8),
                  ],
                )
              : null,
          color: isSentByMe ? null : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppTheme.darkGray.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                fontSize: 15,
                color: isSentByMe ? Colors.white : AppTheme.darkGray,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatMessageTime(message.timestamp),
              style: TextStyle(
                fontSize: 11,
                color: isSentByMe
                    ? Colors.white.withOpacity(0.8)
                    : AppTheme.darkGray.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  Widget _buildConversationTile(Conversation conversation) {
    // This is used for mobile view - navigate to chat view
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.darkGray.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() {
              _selectedConversation = conversation;
              _showMobileChatView = true;
              _messages.clear();
            });
            _loadMessages(conversation.userId);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar with online indicator
                Stack(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: conversation.userPhoto == null
                            ? LinearGradient(
                                colors: [
                                  AppTheme.primaryGold.withOpacity(0.3),
                                  AppTheme.primaryGold.withOpacity(0.6),
                                ],
                              )
                            : null,
                        image: conversation.userPhoto != null
                            ? DecorationImage(
                                image: NetworkImage(conversation.userPhoto!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: conversation.userPhoto == null
                          ? Icon(
                              Icons.person,
                              size: 32,
                              color: Colors.white.withOpacity(0.8),
                            )
                          : null,
                    ),
                    if (conversation.isOnline)
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                // Message info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              conversation.userName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.darkGray,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            _formatTimestamp(conversation.lastMessageTime),
                            style: TextStyle(
                              fontSize: 13,
                              color: conversation.unreadCount > 0
                                  ? AppTheme.primaryGold
                                  : AppTheme.darkGray.withOpacity(0.5),
                              fontWeight: conversation.unreadCount > 0
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.lastMessage,
                              style: TextStyle(
                                fontSize: 15,
                                color: conversation.unreadCount > 0
                                    ? AppTheme.darkGray
                                    : AppTheme.darkGray.withOpacity(0.6),
                                fontWeight: conversation.unreadCount > 0
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (conversation.unreadCount > 0)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGold,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${conversation.unreadCount}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build typing indicator widget
  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppTheme.darkGray.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTypingDot(0),
            const SizedBox(width: 4),
            _buildTypingDot(1),
            const SizedBox(width: 4),
            _buildTypingDot(2),
          ],
        ),
      ),
    );
  }

  /// Build animated typing dot
  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        final delay = index * 0.2;
        final animValue = (value + delay) % 1.0;
        final scale = 0.5 + (0.5 * (1 - (animValue - 0.5).abs() * 2));

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.darkGray.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
      onEnd: () {
        // Loop animation
        if (_isOtherUserTyping && mounted) {
          setState(() {});
        }
      },
    );
  }
}

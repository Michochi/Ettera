const Message = require('../models/Message');
const Match = require('../models/Match');
const User = require('../models/User');

// Helper to generate conversation ID (sorted user IDs)
const getConversationId = (userId1, userId2) => {
  return [userId1, userId2].sort().join('_');
};

// Check if two users have matched
const checkMatch = async (userId1, userId2) => {
  const match = await Match.findOne({
    $or: [
      { user1: userId1, user2: userId2 },
      { user1: userId2, user2: userId1 }
    ]
  });
  return !!match;
};

// Get all conversations for a user
exports.getConversations = async (req, res) => {
  try {
    const userId = req.userId;
    console.log('Getting conversations for user:', userId); // Debug log

    // Find all ACTIVE matches for this user
    const matches = await Match.find({
      $or: [{ user1: userId }, { user2: userId }],
      active: true // Only get active matches
    }).populate('user1 user2', 'name email photoUrl');

    console.log('Found active matches:', matches.length); // Debug log

    // Get conversation details for each match
    const conversations = await Promise.all(
      matches.map(async (match) => {
        const otherUserId = match.user1._id.toString() === userId 
          ? match.user2._id 
          : match.user1._id;
        const otherUser = match.user1._id.toString() === userId 
          ? match.user2 
          : match.user1;

        const conversationId = getConversationId(userId, otherUserId.toString());

        // Get last message
        const lastMessage = await Message.findOne({ conversationId })
          .sort({ createdAt: -1 });

        // Count unread messages
        const unreadCount = await Message.countDocuments({
          conversationId,
          receiverId: userId,
          isRead: false
        });

        return {
          _id: conversationId,
          userId: otherUserId,
          userName: otherUser.name,
          userPhoto: otherUser.photoUrl,
          lastMessage: lastMessage ? lastMessage.content : 'Start a conversation',
          lastMessageTime: lastMessage ? lastMessage.createdAt : match.createdAt,
          unreadCount,
          isOnline: false // TODO: Implement online status
        };
      })
    );

    // Sort by last message time
    conversations.sort((a, b) => 
      new Date(b.lastMessageTime) - new Date(a.lastMessageTime)
    );

    res.json(conversations);
  } catch (error) {
    console.error('Error fetching conversations:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get messages for a specific conversation
exports.getMessages = async (req, res) => {
  try {
    const userId = req.userId;
    const { otherUserId } = req.params;

    // Check if users have matched
    const hasMatched = await checkMatch(userId, otherUserId);
    if (!hasMatched) {
      return res.status(403).json({ 
        message: 'You can only message users you have matched with' 
      });
    }

    const conversationId = getConversationId(userId, otherUserId);

    // Get messages
    const messages = await Message.find({ conversationId })
      .sort({ createdAt: 1 })
      .limit(100); // Limit to last 100 messages

    // Mark messages as read
    await Message.updateMany(
      {
        conversationId,
        receiverId: userId,
        isRead: false
      },
      { isRead: true }
    );

    res.json(messages);
  } catch (error) {
    console.error('Error fetching messages:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Send a message
exports.sendMessage = async (req, res) => {
  try {
    const userId = req.userId;
    const { receiverId, content } = req.body;

    if (!content || content.trim().length === 0) {
      return res.status(400).json({ message: 'Message content is required' });
    }

    // Check if users have matched
    const hasMatched = await checkMatch(userId, receiverId);
    if (!hasMatched) {
      return res.status(403).json({ 
        message: 'You can only message users you have matched with' 
      });
    }

    const conversationId = getConversationId(userId, receiverId);

    const message = new Message({
      conversationId,
      senderId: userId,
      receiverId,
      content: content.trim(),
      isRead: false
    });

    await message.save();

    res.status(201).json(message);
  } catch (error) {
    console.error('Error sending message:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Mark messages as read
exports.markAsRead = async (req, res) => {
  try {
    const userId = req.userId;
    const { otherUserId } = req.params;

    const conversationId = getConversationId(userId, otherUserId);

    await Message.updateMany(
      {
        conversationId,
        receiverId: userId,
        isRead: false
      },
      { isRead: true }
    );

    res.json({ message: 'Messages marked as read' });
  } catch (error) {
    console.error('Error marking messages as read:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

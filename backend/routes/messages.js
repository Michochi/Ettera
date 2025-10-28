const express = require('express');
const router = express.Router();
const messageController = require('../controllers/messageController');
const { verifyToken } = require('../controllers/authController');

// All routes require authentication
router.use(verifyToken);

// Get all conversations
router.get('/conversations', messageController.getConversations);

// Get messages for a specific conversation
router.get('/:otherUserId', messageController.getMessages);

// Send a message
router.post('/send', messageController.sendMessage);

// Mark messages as read
router.put('/:otherUserId/read', messageController.markAsRead);

module.exports = router;

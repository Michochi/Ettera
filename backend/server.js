const http = require("http");
const { Server } = require("socket.io");
const app = require("./app");

const server = http.createServer(app);
const io = new Server(server, { 
  cors: { 
    origin: process.env.FRONTEND_URL || "http://localhost:51747",
    methods: ["GET", "POST"],
    credentials: true
  } 
});

// Store active users: userId -> socketId
const activeUsers = new Map();

// Make io accessible to other modules
app.set('io', io);
app.set('activeUsers', activeUsers);

io.on("connection", (socket) => {
  console.log("🟢 User connected:", socket.id);

  // User joins with their userId
  socket.on("join", (userId) => {
    console.log(`👤 User ${userId} joined with socket ${socket.id}`);
    activeUsers.set(userId, socket.id);
    socket.userId = userId;
    
    // Notify user is online
    io.emit("user_online", userId);
  });

  // Handle incoming messages
  socket.on("send_message", (data) => {
    console.log("� Message from", data.senderId, "to", data.receiverId);
    
    const receiverSocketId = activeUsers.get(data.receiverId);
    
    if (receiverSocketId) {
      // Send to specific user
      io.to(receiverSocketId).emit("receive_message", {
        senderId: data.senderId,
        receiverId: data.receiverId,
        content: data.content,
        timestamp: data.timestamp || new Date().toISOString()
      });
    }
  });

  // Handle typing indicators
  socket.on("typing", (data) => {
    const receiverSocketId = activeUsers.get(data.receiverId);
    if (receiverSocketId) {
      io.to(receiverSocketId).emit("user_typing", {
        userId: data.senderId
      });
    }
  });

  socket.on("stop_typing", (data) => {
    const receiverSocketId = activeUsers.get(data.receiverId);
    if (receiverSocketId) {
      io.to(receiverSocketId).emit("user_stop_typing", {
        userId: data.senderId
      });
    }
  });

  // Handle disconnect
  socket.on("disconnect", () => {
    console.log("�🔴 User disconnected:", socket.id);
    
    if (socket.userId) {
      activeUsers.delete(socket.userId);
      io.emit("user_offline", socket.userId);
    }
  });
});

const PORT = process.env.PORT || 4000;
server.listen(PORT, () => console.log(`Server running on port ${PORT}`));

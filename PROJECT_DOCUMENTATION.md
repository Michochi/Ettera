# Ettera - Dating Application

A full-stack dating application built with Flutter (frontend) and Node.js/Express (backend). Features include user authentication, profile management, swipe-based matching, real-time messaging, and persistent login.

## 📋 Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Setup Instructions](#setup-instructions)
- [API Documentation](#api-documentation)
- [Code Quality Standards](#code-quality-standards)
- [Contributing](#contributing)

## ✨ Features

### User Management

- ✅ User registration with email validation
- ✅ Secure authentication with JWT tokens
- ✅ Persistent login (stays logged in after refresh)
- ✅ Profile management (bio, photos, personal info)
- ✅ Age verification (18+ required)

### Matching System

- ✅ Swipe-based profile browsing
- ✅ Like/Pass functionality
- ✅ Mutual match detection
- ✅ Match list view with grid layout
- ✅ Unmatch functionality

### Messaging

- ✅ Real-time messaging between matched users
- ✅ Conversation list with unread counters
- ✅ Desktop split-screen layout (Facebook Messenger style)
- ✅ Mobile responsive with full-screen chat
- ✅ Message read receipts
- ✅ Match verification before messaging

### UI/UX

- ✅ Responsive design (mobile, tablet, desktop)
- ✅ Custom theme with gold accent colors
- ✅ Smooth animations and transitions
- ✅ Loading states and error handling
- ✅ Empty states with helpful messages

## 🛠 Tech Stack

### Frontend

- **Framework**: Flutter/Dart
- **State Management**: Provider
- **HTTP Client**: Dio
- **Local Storage**: SharedPreferences
- **UI**: Material Design with custom theming

### Backend

- **Runtime**: Node.js
- **Framework**: Express.js
- **Database**: MongoDB with Mongoose ODM
- **Authentication**: JWT (JSON Web Tokens)
- **Password Hashing**: bcrypt
- **Environment Variables**: dotenv

## 📁 Project Structure

```
Ettera/
├── backend/                 # Node.js/Express backend
│   ├── config/             # Configuration files
│   │   └── db.js          # MongoDB connection setup
│   ├── controllers/        # Request handlers
│   │   ├── authController.js       # Authentication logic
│   │   ├── matchingController.js   # Matching system logic
│   │   └── messageController.js    # Messaging logic
│   ├── models/             # Mongoose schemas
│   │   ├── User.js        # User model
│   │   ├── Profile.js     # Profile model for matching
│   │   ├── Match.js       # Match relationships
│   │   └── Message.js     # Message model
│   ├── routes/             # API route definitions
│   │   ├── auth.js        # Auth routes
│   │   ├── matching.js    # Matching routes
│   │   └── messages.js    # Message routes
│   ├── app.js             # Express app configuration
│   ├── server.js          # Server entry point
│   └── package.json       # Dependencies
│
└── frontend/               # Flutter frontend
    ├── lib/
    │   ├── main.dart      # App entry point
    │   ├── models/        # Data models
    │   │   ├── user.dart
    │   │   ├── message_model.dart
    │   │   └── profile_model.dart
    │   ├── providers/     # State management
    │   │   └── user_provider.dart
    │   ├── screens/       # UI screens
    │   │   ├── home_screen.dart
    │   │   ├── login_screen.dart
    │   │   ├── register_screen.dart
    │   │   ├── profile_screen.dart
    │   │   ├── browse_screen.dart
    │   │   ├── matches_screen.dart
    │   │   └── messages_screen.dart
    │   ├── services/      # API services
    │   │   ├── auth_service.dart
    │   │   ├── matching_service.dart
    │   │   └── message_service.dart
    │   ├── utils/         # Utility functions
    │   │   ├── constants.dart
    │   │   ├── validators.dart
    │   │   └── error_handler.dart
    │   └── widgets/       # Reusable widgets
    │       ├── custom_app_bar.dart
    │       ├── custom_drawer.dart
    │       ├── app_theme.dart
    │       └── custom_footer.dart
    ├── assets/            # Images and resources
    └── pubspec.yaml       # Flutter dependencies
```

## 🚀 Setup Instructions

### Prerequisites

- Node.js (v14 or higher)
- MongoDB (local or MongoDB Atlas)
- Flutter SDK (v3.0 or higher)
- Git

### Backend Setup

1. **Clone the repository**

   ```bash
   git clone https://github.com/Michochi/Ettera.git
   cd Ettera/backend
   ```

2. **Install dependencies**

   ```bash
   npm install
   ```

3. **Configure environment variables**

   ```bash
   cp .env.example .env
   ```

   Edit `.env` file:

   ```env
   MONGODB_URI=mongodb://localhost:27017/ettera
   JWT_SECRET=your-secret-key-here
   PORT=4000
   NODE_ENV=development
   ```

4. **Start MongoDB**

   ```bash
   # If using local MongoDB
   mongod

   # Or use MongoDB Atlas connection string in .env
   ```

5. **Run the server**

   ```bash
   # Development mode with auto-reload
   npm run dev

   # Production mode
   npm start
   ```

   Server runs on `http://localhost:4000`

### Frontend Setup

1. **Navigate to frontend directory**

   ```bash
   cd ../frontend
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure API endpoint**

   Edit `lib/utils/constants.dart`:

   ```dart
   const String apiUrl = "http://localhost:4000/api";
   ```

4. **Run the app**

   ```bash
   # For web
   flutter run -d chrome

   # For Android/iOS
   flutter run

   # For desktop
   flutter run -d windows  # or macos, linux
   ```

## 📚 API Documentation

### Base URL

```
http://localhost:4000/api
```

### Authentication Endpoints

#### Register User

```http
POST /auth/register
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "gender": "Male",
  "birthday": "1990-05-15"
}

Response (201):
{
  "message": "User registered successfully",
  "token": "jwt-token-here",
  "user": { ...user object }
}
```

#### Login

```http
POST /auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "password123"
}

Response (200):
{
  "message": "Login successful",
  "token": "jwt-token-here",
  "user": { ...user object }
}
```

#### Update Profile

```http
PUT /auth/profile
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "John Updated",
  "bio": "New bio",
  "photoUrl": "base64-or-url"
}

Response (200):
{
  "message": "Profile updated successfully",
  "user": { ...updated user object }
}
```

### Matching Endpoints

#### Get Profiles to Browse

```http
GET /matching/profiles?limit=20
Authorization: Bearer <token>

Response (200):
{
  "profiles": [
    {
      "id": "user-id",
      "name": "Jane Doe",
      "age": 25,
      "bio": "Love hiking",
      "photoUrl": "...",
      ...
    }
  ]
}
```

#### Like Profile

```http
POST /matching/like
Authorization: Bearer <token>
Content-Type: application/json

{
  "profileId": "user-id-to-like"
}

Response (200):
{
  "message": "Profile liked",
  "isMatch": true,  // if mutual like
  "match": { ...match details }
}
```

#### Get Matches

```http
GET /matching/matches
Authorization: Bearer <token>

Response (200):
{
  "matches": [
    {
      "id": "user-id",
      "name": "Jane Doe",
      "photoUrl": "...",
      ...
    }
  ]
}
```

#### Unmatch User

```http
DELETE /matching/matches/:matchId
Authorization: Bearer <token>

Response (200):
{
  "message": "Unmatched successfully"
}
```

### Messaging Endpoints

#### Get Conversations

```http
GET /messages/conversations
Authorization: Bearer <token>

Response (200):
[
  {
    "_id": "conversation-id",
    "userId": "other-user-id",
    "userName": "Jane Doe",
    "userPhoto": "...",
    "lastMessage": "Hello!",
    "lastMessageTime": "2025-10-28T10:30:00.000Z",
    "unreadCount": 2,
    "isOnline": false
  }
]
```

#### Get Messages with User

```http
GET /messages/:otherUserId
Authorization: Bearer <token>

Response (200):
[
  {
    "_id": "message-id",
    "senderId": "sender-id",
    "receiverId": "receiver-id",
    "content": "Hello!",
    "isRead": true,
    "createdAt": "2025-10-28T10:30:00.000Z"
  }
]
```

#### Send Message

```http
POST /messages/send
Authorization: Bearer <token>
Content-Type: application/json

{
  "receiverId": "user-id",
  "content": "Hello, how are you?"
}

Response (201):
{
  ...message object
}
```

## 🎯 Code Quality Standards

This project follows these code quality principles:

### 1. **Modularity**

- ✅ Separation of concerns (controllers, models, routes, services)
- ✅ Reusable components and widgets
- ✅ Single responsibility principle
- ✅ Helper functions for common operations

### 2. **Documentation**

- ✅ File-level documentation explaining purpose
- ✅ Function documentation with parameters and returns
- ✅ Inline comments for complex logic
- ✅ JSDoc/DartDoc style comments
- ✅ Example usage in documentation

### 3. **Error Handling**

- ✅ Try-catch blocks in all async operations
- ✅ Specific error messages with error codes
- ✅ User-friendly error messages
- ✅ Error logging for debugging
- ✅ Graceful degradation

### 4. **Validation**

- ✅ Input validation on both frontend and backend
- ✅ Email format validation
- ✅ Password strength requirements
- ✅ Age verification (18+)
- ✅ Required field checking

### 5. **Security**

- ✅ Password hashing with bcrypt
- ✅ JWT token authentication
- ✅ Token expiration (7 days)
- ✅ Protected routes requiring authentication
- ✅ Input sanitization

### 6. **Best Practices**

- ✅ Consistent naming conventions
- ✅ Proper indentation and formatting
- ✅ Null safety (Dart)
- ✅ Async/await for asynchronous operations
- ✅ Environment variables for sensitive data
- ✅ HTTP status codes for API responses

## 🐛 Common Issues & Solutions

### Backend Issues

**MongoDB Connection Error**

```
Solution: Check MONGODB_URI in .env file
Ensure MongoDB service is running
```

**JWT_SECRET not defined**

```
Solution: Add JWT_SECRET to .env file
```

**Port already in use**

```
Solution: Change PORT in .env or stop other process
```

### Frontend Issues

**API connection failed**

```
Solution: Check apiUrl in lib/utils/constants.dart
Ensure backend server is running
```

**Flutter pub get fails**

```
Solution: Run flutter clean && flutter pub get
```

**Persistent login not working**

```
Solution: Clear app data/cache and re-login
Check SharedPreferences permissions
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style Guidelines

- Follow existing code formatting
- Add documentation for new functions
- Include error handling
- Write meaningful commit messages
- Test before submitting PR

## 📝 License

This project is for educational purposes.

## 👥 Authors

- **Michochi** - Initial work - [GitHub](https://github.com/Michochi)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- MongoDB for the database solution
- All contributors and testers

---

**Need help?** Open an issue on GitHub or contact support@eterra.com

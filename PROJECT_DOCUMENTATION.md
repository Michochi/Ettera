# Eterra - Dating Application

## WC Launchpad Builder Round Submission

A full-stack dating application built with Flutter (frontend) and Node.js/Express (backend) for the White Cloak Launchpad Builder Round (October 27-31, 2025). This project demonstrates technical skills in system design, product development, and full-stack application development.

### Project Purpose

This application was developed as part of the WC Launchpad Builder Round challenge to create a functional dating app prototype within a five-day timeframe. The goal is to showcase:

- **Technical Skills**: Full-stack development with modern web technologies
- **System Design**: Scalable architecture and database design
- **Product Sense**: User-centric features and intuitive UI/UX
- **User Empathy**: Thoughtful user experience and accessibility
- **Execution Clarity**: Clean, well-documented, and maintainable code

### Challenge Requirements Met

✅ **User Registration & Login**: Secure authentication with email/password  
✅ **Profile Management**: Create and edit profiles with photos  
✅ **User Discovery**: Browse and swipe (drag) on profiles  
✅ **Matching System**: Mutual likes create matches  
✅ **Messaging**: Chat functionality unlocked after matching  
✅ **Match List**: View all matches with unmatch capability  
✅ **Bonus Features**: Light/dark mode UI toggle

### Tech Stack Alignment

- ✅ **Frontend**: Flutter (strongly-typed with Dart)
- ✅ **Backend**: Node.js/Express with custom APIs
- ✅ **Database**: MongoDB (persistent database)
- ✅ **Platform**: Web-first, desktop-oriented with responsive design
- ✅ **Version Control**: GitHub repository
- ✅ **Code Quality**: Modular, documented, with error handling

## 📋 Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Setup Instructions](#setup-instructions)
- [API Documentation](#api-documentation)
- [Code Quality Standards](#code-quality-standards)

## ✨ Features

### Required Features (Core MVP)

#### 1. User Registration & Login

- ✅ **New User Sign-Up**: Register using email with name, age, bio, and profile picture
- ✅ **Returning User Login**: Secure authentication with email and password
- ✅ **JWT Authentication**: Token-based security with 7-day expiration
- ✅ **Age Verification**: Ensures users are 18+ years old

#### 2. User Profile Management

- ✅ **View Profile**: Display user profile in browser
- ✅ **Edit Profile**: Update name, bio, and profile photo
- ✅ **Photo Upload**: Support for profile picture uploads
- ✅ **Personal Information**: Gender and birthday management

#### 3. User Discovery & Matching

- ✅ **Browse Profiles**: Desktop interface for profile discovery
- ✅ **Swipe Functionality**: Drag right to like, left to skip
- ✅ **Mutual Matching**: Form match when both users like each other
- ✅ **Smart Display**: Avoid showing same profile again
- ✅ **Match Detection**: Real-time notification of new matches

#### 4. Messaging / Chat

- ✅ **Match-Gated Chat**: Messaging unlocked only after matching
- ✅ **Real-Time Messaging**: Send and receive text messages
- ✅ **Conversation List**: View all active chats with unread counters
- ✅ **Desktop Layout**: Split-screen messenger interface
- ✅ **Mobile Responsive**: Full-screen chat on mobile devices
- ✅ **Message History**: Persistent message storage

#### 5. Match List

- ✅ **Display Matches**: View all current matches in grid layout
- ✅ **Unmatch Feature**: Remove matches (removes chat access)
- ✅ **Match Details**: See profile info of matched users

### Bonus Features (Implemented)

#### 6. Enhanced UI/UX

- ✅ **Light/Dark Mode Toggle**: Complete theme switching functionality
  - Theme toggle in app bar and drawer
  - Persistent theme preference with SharedPreferences
  - Adaptive colors for all screens and components
  - Theme-aware shadows and contrasts
- ✅ **Responsive Design**: Works on desktop, tablet, and mobile
- ✅ **Custom Theme**: Gold accent colors (#C4933F) with Material Design 3
- ✅ **Smooth Animations**: Transitions and loading states
- ✅ **Error Handling**: User-friendly error messages
- ✅ **Empty States**: Helpful messages when no data available
- ✅ **Loading States**: Visual feedback during operations

### Additional Features (Beyond Requirements)

- ✅ **Persistent Login**: Stay logged in after browser refresh
- ✅ **Profile Statistics**: Match and like counters on home screen
- ✅ **Navigation Drawer**: Easy access to all app sections
- ✅ **Form Validation**: Client and server-side validation
- ✅ **Password Security**: Bcrypt hashing with salt rounds
- ✅ **Input Sanitization**: Protected against common vulnerabilities

## 🛠 Tech Stack

### Frontend (Web-First, Desktop-Oriented)

- **Framework**: Flutter Web/Dart (strongly-typed language)
- **Language**: Dart (type-safe, compiled to JavaScript)
- **State Management**: Provider pattern for reactive state
- **HTTP Client**: Dio for API communication
- **Local Storage**: SharedPreferences for persistent data
- **UI Framework**: Material Design 3 with custom theming
- **Platform**: Web browser (Chrome, Firefox, Safari, Edge)
- **Responsive**: Adaptive layouts for desktop, tablet, and mobile

### Backend (Custom APIs, No BaaS)

- **Runtime**: Node.js (v14+)
- **Framework**: Express.js for RESTful APIs
- **Database**: MongoDB with Mongoose ODM (persistent storage)
- **Authentication**: JWT (JSON Web Tokens) for secure sessions
- **Password Security**: bcrypt for password hashing
- **Environment Management**: dotenv for configuration
- **API Architecture**: RESTful endpoints with proper HTTP methods
- **CORS**: Configured for cross-origin requests

### Database

- **Type**: MongoDB (NoSQL, persistent database)
- **ODM**: Mongoose for schema validation
- **Models**: User, Profile, Match, Message
- **Indexing**: Optimized queries for performance
- **Relationships**: Referenced documents for data integrity

### Development & Deployment

- **Version Control**: GitHub (public repository)
- **Code Quality**: ESLint, Prettier, Dart analyzer
- **Testing**: Manual testing and validation
- **Deployment Options**:
  - Frontend: Vercel, Netlify, or Firebase Hosting
  - Backend: Heroku, Fly.io, or Railway
  - Database: MongoDB Atlas (cloud-hosted)

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

## 📦 Deliverables

### 1. Deployed Application

- **Frontend**: Live web application accessible via URL
- **Backend**: Deployed API server with persistent database
- **Status**: Fully functional and publicly accessible

### 2. Git Repository

- **Platform**: GitHub
- **Repository**: [https://github.com/Michochi/Ettera](https://github.com/Michochi/Ettera)
- **Branch**: main
- **Access**: Public repository with full source code
- **Documentation**: README and PROJECT_DOCUMENTATION.md included

### 3. Video Demo (15 minutes max)

- **App Walkthrough**: Complete feature demonstration
- **Code Overview**: Architecture and key implementation details
- **Technical Discussion**: Challenges faced and solutions implemented
- **Future Plans**: Roadmap for enhancements and scaling

## 🎯 Technical Challenges & Solutions

### Challenges Encountered

1. **Real-Time Messaging Without BaaS**

   - **Challenge**: Implementing real-time chat without Firebase/Supabase
   - **Solution**: RESTful polling approach with efficient message fetching
   - **Future Plan**: Implement WebSocket (Socket.io) for true real-time updates

2. **Profile Swipe Mechanics on Web**

   - **Challenge**: Creating smooth drag-to-swipe on desktop browsers
   - **Solution**: Custom gesture detection with Flutter's drag controllers
   - **Future Plan**: Add animation feedback and undo functionality

3. **Theme Consistency Across Components**

   - **Challenge**: Maintaining dark/light mode across all UI elements
   - **Solution**: Centralized theme helper methods with context-aware colors
   - **Future Plan**: Add more theme customization options

4. **Image Upload & Storage**

   - **Challenge**: Handling profile photos without cloud storage service
   - **Solution**: Base64 encoding stored in MongoDB (MVP approach)
   - **Future Plan**: Integrate dedicated image storage (AWS S3, Cloudinary)

5. **State Management at Scale**
   - **Challenge**: Managing global state across multiple screens
   - **Solution**: Provider pattern with UserProvider for authentication state
   - **Future Plan**: Consider Riverpod or BLoC for more complex state

## 🏆 Project Highlights

### What Makes This Special

1. **Complete Type Safety**: Dart frontend with strong typing throughout
2. **Custom API Backend**: No BaaS dependency, full control over data
3. **Professional UI/UX**: Material Design 3 with custom theming
4. **Production-Ready Code**: Proper error handling, validation, and documentation
5. **Scalable Architecture**: Modular structure ready for growth
6. **Bonus Features**: Dark mode fully implemented across entire app
7. **Five-Day Sprint**: Functional MVP delivered within challenge timeframe

## 📧 Contact & Submission

**Developer**: Christian Micho S. Dela Cruz
**Project**: Eterra Dating Application  
**Challenge**: WC Launchpad Builder Round  
**Timeline**: October 27-31, 2025  
**Submission Deadline**: October 31, 2025, 11:59 PM

### Submission Details

- **Deployed App**: [URL to be provided]
- **Git Repository**: https://github.com/Michochi/Ettera
- **Video Demo**: [URL to be provided]

---

_This project demonstrates full-stack development capabilities, system design thinking, and rapid MVP delivery within tight deadlines. Built with attention to code quality, user experience, and scalability._

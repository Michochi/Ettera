/**
 * Authentication Controller
 * 
 * Handles user authentication operations including:
 * - User registration with profile creation
 * - User login with JWT token generation
 * - Profile updates with validation
 * - JWT token verification middleware
 * 
 * @module controllers/authController
 */

const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const User = require("../models/User");
const Profile = require("../models/Profile");

// ==================== Configuration ====================

/**
 * JWT token expiration time
 * @constant {string}
 */
const TOKEN_EXPIRY = "7d";

/**
 * Bcrypt salt rounds for password hashing
 * @constant {number}
 */
const SALT_ROUNDS = 10;

// ==================== Helper Functions ====================

/**
 * Calculates age from a given birth date
 * 
 * @param {Date} birthDate - The birth date to calculate age from
 * @returns {number} The calculated age in years
 * 
 * @example
 * const age = calculateAge(new Date('1990-05-15')); // Returns current age
 */
const calculateAge = (birthDate) => {
  const today = new Date();
  let age = today.getFullYear() - birthDate.getFullYear();
  const monthDiff = today.getMonth() - birthDate.getMonth();
  
  // Adjust age if birthday hasn't occurred this year
  if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
    age--;
  }
  
  return age;
};

/**
 * Validates required fields in request body
 * 
 * @param {Object} body - Request body object
 * @param {Array<string>} requiredFields - Array of required field names
 * @returns {Object} Validation result with isValid flag and missing fields
 * 
 * @example
 * const validation = validateRequiredFields(req.body, ['email', 'password']);
 * if (!validation.isValid) {
 *   return res.status(400).json({ message: `Missing: ${validation.missing.join(', ')}` });
 * }
 */
const validateRequiredFields = (body, requiredFields) => {
  const missing = requiredFields.filter(field => !body[field]);
  return {
    isValid: missing.length === 0,
    missing
  };
};

/**
 * Validates email format
 * 
 * @param {string} email - Email address to validate
 * @returns {boolean} True if email format is valid
 */
const isValidEmail = (email) => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};

/**
 * Generates JWT token for authenticated user
 * 
 * @param {string} userId - MongoDB user ID
 * @returns {string} JWT token
 * @throws {Error} If JWT_SECRET is not configured
 */
const generateToken = (userId) => {
  if (!process.env.JWT_SECRET) {
    throw new Error('JWT_SECRET is not configured');
  }
  return jwt.sign({ id: userId }, process.env.JWT_SECRET, { expiresIn: TOKEN_EXPIRY });
};

// ==================== Middleware ====================

/**
 * JWT Token Verification Middleware
 * 
 * Validates JWT token from Authorization header and attaches userId to request.
 * Expects token format: "Bearer <token>"
 * 
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 * 
 * @returns {void}
 * 
 * Response Codes:
 * - 401: No token provided or invalid token
 * 
 * @example
 * router.get('/protected', verifyToken, (req, res) => {
 *   // req.userId is available here
 * });
 */
exports.verifyToken = (req, res, next) => {
  try {
    // Extract token from Authorization header
    const authHeader = req.headers.authorization;
    if (!authHeader) {
      return res.status(401).json({ 
        message: "No authorization header provided",
        code: "NO_AUTH_HEADER"
      });
    }

    const token = authHeader.split(' ')[1];
    if (!token) {
      return res.status(401).json({ 
        message: "No token provided",
        code: "NO_TOKEN"
      });
    }

    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.userId = decoded.id;
    
    next();
  } catch (err) {
    // Handle specific JWT errors
    if (err.name === 'TokenExpiredError') {
      return res.status(401).json({ 
        message: "Token has expired",
        code: "TOKEN_EXPIRED"
      });
    }
    if (err.name === 'JsonWebTokenError') {
      return res.status(401).json({ 
        message: "Invalid token",
        code: "INVALID_TOKEN"
      });
    }
    
    return res.status(401).json({ 
      message: "Token verification failed",
      code: "TOKEN_VERIFICATION_FAILED",
      error: err.message
    });
  }
};

// ==================== Controller Functions ====================

/**
 * User Registration
 * 
 * Creates a new user account with encrypted password and associated profile.
 * Automatically generates JWT token for immediate login after registration.
 * 
 * @route POST /api/auth/register
 * @access Public
 * 
 * @param {Object} req - Express request object
 * @param {Object} req.body - Request body
 * @param {string} req.body.name - User's full name
 * @param {string} req.body.email - User's email address
 * @param {string} req.body.password - User's password (will be hashed)
 * @param {string} req.body.gender - User's gender (Male/Female/Other)
 * @param {string} req.body.birthday - User's birth date (ISO format)
 * 
 * @param {Object} res - Express response object
 * 
 * @returns {Object} JSON response with user data and token
 * 
 * Response Codes:
 * - 201: User created successfully
 * - 400: Validation error (missing fields, email taken, invalid format)
 * - 500: Server error
 * 
 * @example
 * POST /api/auth/register
 * {
 *   "name": "John Doe",
 *   "email": "john@example.com",
 *   "password": "securePassword123",
 *   "gender": "Male",
 *   "birthday": "1990-05-15"
 * }
 */
exports.register = async (req, res) => {
  try {
    const { name, email, password, gender, birthday } = req.body;

    // Validate required fields
    const validation = validateRequiredFields(req.body, ['name', 'email', 'password', 'gender', 'birthday']);
    if (!validation.isValid) {
      return res.status(400).json({ 
        message: "Missing required fields",
        missing: validation.missing,
        code: "MISSING_FIELDS"
      });
    }

    // Validate email format
    if (!isValidEmail(email)) {
      return res.status(400).json({ 
        message: "Invalid email format",
        code: "INVALID_EMAIL"
      });
    }

    // Validate password strength
    if (password.length < 6) {
      return res.status(400).json({ 
        message: "Password must be at least 6 characters long",
        code: "WEAK_PASSWORD"
      });
    }

    // Check if email already exists
    const existing = await User.findOne({ email });
    if (existing) {
      return res.status(400).json({ 
        message: "Email already registered",
        code: "EMAIL_EXISTS"
      });
    }

    // Validate and parse birthday
    const birthDate = new Date(birthday);
    if (isNaN(birthDate.getTime())) {
      return res.status(400).json({ 
        message: "Invalid birth date format",
        code: "INVALID_BIRTHDAY"
      });
    }

    // Calculate age and validate minimum age (18+)
    const age = calculateAge(birthDate);
    if (age < 18) {
      return res.status(400).json({ 
        message: "You must be at least 18 years old to register",
        code: "UNDERAGE"
      });
    }

    // Hash password
    const hashed = await bcrypt.hash(password, SALT_ROUNDS);
    
    // Create user
    const user = await User.create({ 
      name, 
      email, 
      password: hashed,
      gender,
      birthday: birthDate,
      age
    });

    // Create associated profile for matching system
    await Profile.create({
      userId: user._id,
      age: age,
      likedProfiles: [],
      passedProfiles: [],
      matches: [],
    });

    // Generate authentication token
    const token = generateToken(user._id);

    // Remove password from response
    const userResponse = user.toObject();
    delete userResponse.password;

    res.status(201).json({ 
      message: "User registered successfully", 
      token, 
      user: userResponse
    });
    
  } catch (err) {
    console.error('Registration error:', err);
    
    // Handle MongoDB duplicate key error
    if (err.code === 11000) {
      return res.status(400).json({ 
        message: "Email already registered",
        code: "EMAIL_EXISTS"
      });
    }
    
    // Handle validation errors
    if (err.name === 'ValidationError') {
      return res.status(400).json({ 
        message: "Validation error",
        errors: Object.values(err.errors).map(e => e.message),
        code: "VALIDATION_ERROR"
      });
    }
    
    res.status(500).json({ 
      message: "Server error during registration",
      code: "SERVER_ERROR",
      error: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
  }
};

/**
 * User Login
 * 
 * Authenticates user with email and password, returns JWT token.
 * 
 * @route POST /api/auth/login
 * @access Public
 * 
 * @param {Object} req - Express request object
 * @param {Object} req.body - Request body
 * @param {string} req.body.email - User's email
 * @param {string} req.body.password - User's password
 * 
 * @param {Object} res - Express response object
 * 
 * @returns {Object} JSON response with user data and token
 * 
 * Response Codes:
 * - 200: Login successful
 * - 400: Invalid credentials or missing fields
 * - 404: User not found
 * - 500: Server error
 * 
 * @example
 * POST /api/auth/login
 * {
 *   "email": "john@example.com",
 *   "password": "securePassword123"
 * }
 */
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validate required fields
    const validation = validateRequiredFields(req.body, ['email', 'password']);
    if (!validation.isValid) {
      return res.status(400).json({ 
        message: "Email and password are required",
        missing: validation.missing,
        code: "MISSING_FIELDS"
      });
    }

    // Find user by email
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ 
        message: "User not found",
        code: "USER_NOT_FOUND"
      });
    }

    // Verify password
    const match = await bcrypt.compare(password, user.password);
    if (!match) {
      return res.status(400).json({ 
        message: "Invalid credentials",
        code: "INVALID_CREDENTIALS"
      });
    }

    // Generate authentication token
    const token = generateToken(user._id);

    // Remove password from response
    const userResponse = user.toObject();
    delete userResponse.password;

    res.json({ 
      message: "Login successful", 
      token, 
      user: userResponse
    });
    
  } catch (err) {
    console.error('Login error:', err);
    res.status(500).json({ 
      message: "Server error during login",
      code: "SERVER_ERROR",
      error: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
  }
};

/**
 * Update User Profile
 * 
 * Updates user profile information including personal details and bio.
 * Requires authentication via JWT token.
 * 
 * @route PUT /api/auth/profile
 * @access Private (requires verifyToken middleware)
 * 
 * @param {Object} req - Express request object
 * @param {string} req.userId - User ID from JWT token (set by verifyToken middleware)
 * @param {Object} req.body - Request body with fields to update
 * @param {string} [req.body.name] - Updated name
 * @param {string} [req.body.email] - Updated email
 * @param {string} [req.body.bio] - Updated bio
 * @param {string} [req.body.photoUrl] - Updated photo URL
 * @param {string} [req.body.gender] - Updated gender
 * @param {string} [req.body.birthday] - Updated birthday (will recalculate age)
 * 
 * @param {Object} res - Express response object
 * 
 * @returns {Object} JSON response with updated user data
 * 
 * Response Codes:
 * - 200: Profile updated successfully
 * - 400: Validation error (email taken, invalid data)
 * - 404: User not found
 * - 500: Server error
 * 
 * @example
 * PUT /api/auth/profile
 * Headers: { Authorization: "Bearer <token>" }
 * {
 *   "name": "John Updated",
 *   "bio": "New bio description"
 * }
 */
exports.updateProfile = async (req, res) => {
  try {
    const { name, email, bio, photoUrl, gender, birthday } = req.body;
    const userId = req.userId;

    // Check if at least one field is provided
    if (!name && !email && bio === undefined && !photoUrl && !gender && !birthday) {
      return res.status(400).json({ 
        message: "No fields to update",
        code: "NO_UPDATE_FIELDS"
      });
    }

    // Validate email format if provided
    if (email && !isValidEmail(email)) {
      return res.status(400).json({ 
        message: "Invalid email format",
        code: "INVALID_EMAIL"
      });
    }

    // Check if email is being changed and if it's already taken
    if (email) {
      const existing = await User.findOne({ email, _id: { $ne: userId } });
      if (existing) {
        return res.status(400).json({ 
          message: "Email already in use",
          code: "EMAIL_EXISTS"
        });
      }
    }

    // Build update object with only provided fields
    const updateData = {};
    if (name) updateData.name = name;
    if (email) updateData.email = email;
    if (bio !== undefined) updateData.bio = bio; // Allow empty string
    if (photoUrl) updateData.photoUrl = photoUrl;
    if (gender) updateData.gender = gender;
    
    // Handle birthday update and recalculate age
    if (birthday) {
      const birthDate = new Date(birthday);
      
      // Validate birth date
      if (isNaN(birthDate.getTime())) {
        return res.status(400).json({ 
          message: "Invalid birth date format",
          code: "INVALID_BIRTHDAY"
        });
      }
      
      const age = calculateAge(birthDate);
      
      // Validate minimum age
      if (age < 18) {
        return res.status(400).json({ 
          message: "Age must be at least 18 years",
          code: "UNDERAGE"
        });
      }
      
      updateData.birthday = birthDate;
      updateData.age = age;
      
      // Update age in Profile collection for matching system
      await Profile.findOneAndUpdate(
        { userId },
        { age: age }
      );
    }

    // Update user document
    const user = await User.findByIdAndUpdate(
      userId,
      updateData,
      { 
        new: true, // Return updated document
        runValidators: true // Run model validators
      }
    ).select('-password'); // Exclude password from response

    if (!user) {
      return res.status(404).json({ 
        message: "User not found",
        code: "USER_NOT_FOUND"
      });
    }

    res.json({ 
      message: "Profile updated successfully", 
      user
    });
    
  } catch (err) {
    console.error('Profile update error:', err);
    
    // Handle MongoDB duplicate key error
    if (err.code === 11000) {
      return res.status(400).json({ 
        message: "Email already in use",
        code: "EMAIL_EXISTS"
      });
    }
    
    // Handle validation errors
    if (err.name === 'ValidationError') {
      return res.status(400).json({ 
        message: "Validation error",
        errors: Object.values(err.errors).map(e => e.message),
        code: "VALIDATION_ERROR"
      });
    }
    
    res.status(500).json({ 
      message: "Server error during profile update",
      code: "SERVER_ERROR",
      error: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
  }
};

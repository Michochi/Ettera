/**
 * Validation Utilities
 * 
 * Provides input validation functions for forms throughout the app.
 * 
 * Features:
 * - Email validation
 * - Password strength validation
 * - Name validation
 * - Age validation
 * - General input validation
 */

/// Validation utility class with static methods
class Validators {
  /// Private constructor to prevent instantiation
  Validators._();

  // ==================== Email Validation ====================

  /// Validates email format using regex
  ///
  /// Parameters:
  /// - [email]: Email address to validate
  ///
  /// Returns:
  /// - null if valid
  /// - Error message string if invalid
  ///
  /// Example:
  /// ```dart
  /// String? error = Validators.validateEmail('user@example.com');
  /// if (error != null) {
  ///   print('Invalid: $error');
  /// }
  /// ```
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }

    // Basic email regex pattern
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Checks if email format is valid (boolean version)
  ///
  /// Parameters:
  /// - [email]: Email address to check
  ///
  /// Returns: true if valid, false otherwise
  static bool isValidEmail(String? email) {
    return validateEmail(email) == null;
  }

  // ==================== Password Validation ====================

  /// Validates password strength
  ///
  /// Requirements:
  /// - Minimum 6 characters
  /// - Optional: Can add complexity requirements
  ///
  /// Parameters:
  /// - [password]: Password to validate
  /// - [minLength]: Minimum required length (default: 6)
  ///
  /// Returns:
  /// - null if valid
  /// - Error message string if invalid
  static String? validatePassword(String? password, {int minLength = 6}) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < minLength) {
      return 'Password must be at least $minLength characters';
    }

    // Optional: Add more complexity requirements
    // if (!password.contains(RegExp(r'[A-Z]'))) {
    //   return 'Password must contain at least one uppercase letter';
    // }

    return null;
  }

  /// Validates password confirmation matches original
  ///
  /// Parameters:
  /// - [password]: Original password
  /// - [confirmPassword]: Confirmation password
  ///
  /// Returns:
  /// - null if matching
  /// - Error message if not matching
  static String? validatePasswordMatch(
    String? password,
    String? confirmPassword,
  ) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }

    if (password != confirmPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Checks password strength level
  ///
  /// Returns strength score:
  /// - 0: Weak (< 6 chars)
  /// - 1: Fair (6-8 chars)
  /// - 2: Good (9+ chars with numbers)
  /// - 3: Strong (9+ chars with numbers and special chars)
  static int getPasswordStrength(String? password) {
    if (password == null || password.isEmpty) return 0;
    if (password.length < 6) return 0;
    if (password.length < 9) return 1;

    int score = 2;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    return score;
  }

  // ==================== Name Validation ====================

  /// Validates name field
  ///
  /// Parameters:
  /// - [name]: Name to validate
  /// - [minLength]: Minimum required length (default: 2)
  /// - [maxLength]: Maximum allowed length (default: 50)
  ///
  /// Returns:
  /// - null if valid
  /// - Error message string if invalid
  static String? validateName(
    String? name, {
    int minLength = 2,
    int maxLength = 50,
  }) {
    if (name == null || name.isEmpty) {
      return 'Name is required';
    }

    if (name.trim().length < minLength) {
      return 'Name must be at least $minLength characters';
    }

    if (name.length > maxLength) {
      return 'Name must not exceed $maxLength characters';
    }

    // Check for invalid characters (only letters, spaces, hyphens, apostrophes)
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(name)) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }

    return null;
  }

  // ==================== Age Validation ====================

  /// Validates age meets minimum requirement
  ///
  /// Parameters:
  /// - [birthday]: Date of birth
  /// - [minAge]: Minimum required age (default: 18)
  ///
  /// Returns:
  /// - null if valid
  /// - Error message string if invalid
  static String? validateAge(DateTime? birthday, {int minAge = 18}) {
    if (birthday == null) {
      return 'Birthday is required';
    }

    final today = DateTime.now();
    int age = today.year - birthday.year;

    // Adjust age if birthday hasn't occurred this year
    if (today.month < birthday.month ||
        (today.month == birthday.month && today.day < birthday.day)) {
      age--;
    }

    if (age < minAge) {
      return 'You must be at least $minAge years old';
    }

    // Check if date is in the future
    if (birthday.isAfter(today)) {
      return 'Birthday cannot be in the future';
    }

    // Check if age is reasonable (e.g., not over 120)
    if (age > 120) {
      return 'Please enter a valid birthday';
    }

    return null;
  }

  /// Calculates age from birthday
  ///
  /// Parameters:
  /// - [birthday]: Date of birth
  ///
  /// Returns calculated age in years
  static int calculateAge(DateTime birthday) {
    final today = DateTime.now();
    int age = today.year - birthday.year;

    if (today.month < birthday.month ||
        (today.month == birthday.month && today.day < birthday.day)) {
      age--;
    }

    return age;
  }

  // ==================== General Input Validation ====================

  /// Validates required field is not empty
  ///
  /// Parameters:
  /// - [value]: Value to check
  /// - [fieldName]: Name of field for error message
  ///
  /// Returns:
  /// - null if valid
  /// - Error message if invalid
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates text length is within range
  ///
  /// Parameters:
  /// - [value]: Text to validate
  /// - [minLength]: Minimum required length
  /// - [maxLength]: Maximum allowed length
  /// - [fieldName]: Name of field for error message
  ///
  /// Returns:
  /// - null if valid
  /// - Error message if invalid
  static String? validateLength(
    String? value,
    int minLength,
    int maxLength,
    String fieldName,
  ) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }

    if (value.length > maxLength) {
      return '$fieldName must not exceed $maxLength characters';
    }

    return null;
  }

  /// Validates bio/description field
  ///
  /// Parameters:
  /// - [bio]: Bio text to validate
  /// - [maxLength]: Maximum allowed length (default: 500)
  ///
  /// Returns:
  /// - null if valid
  /// - Error message if invalid
  static String? validateBio(String? bio, {int maxLength = 500}) {
    // Bio is optional, so null/empty is valid
    if (bio == null || bio.isEmpty) {
      return null;
    }

    if (bio.length > maxLength) {
      return 'Bio must not exceed $maxLength characters';
    }

    return null;
  }

  // ==================== Dropdown/Selection Validation ====================

  /// Validates a selection has been made
  ///
  /// Parameters:
  /// - [value]: Selected value
  /// - [fieldName]: Name of field for error message
  ///
  /// Returns:
  /// - null if valid
  /// - Error message if invalid
  static String? validateSelection(dynamic value, String fieldName) {
    if (value == null) {
      return 'Please select a $fieldName';
    }
    return null;
  }
}

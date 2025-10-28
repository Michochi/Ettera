/**
 * Error Handler Utility
 * 
 * Provides centralized error handling and user-friendly error messages
 * for the Ettera dating app.
 * 
 * Usage:
 * ```dart
 * try {
 *   await apiCall();
 * } catch (e) {
 *   ErrorHandler.showErrorSnackBar(context, e);
 * }
 * ```
 */

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

/// Centralized error handling utility class
class ErrorHandler {
  /// Private constructor to prevent instantiation
  ErrorHandler._();

  /// Maximum length for error messages displayed to users
  static const int _maxMessageLength = 200;

  /// Extracts user-friendly error message from various error types
  ///
  /// Handles:
  /// - DioException (network errors)
  /// - String errors
  /// - General exceptions
  ///
  /// Parameters:
  /// - [error]: The error object to parse
  ///
  /// Returns user-friendly error message string
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    }

    if (error is String) {
      return error.length > _maxMessageLength
          ? '${error.substring(0, _maxMessageLength)}...'
          : error;
    }

    if (error is Exception) {
      final message = error.toString().replaceFirst('Exception: ', '');
      return message.length > _maxMessageLength
          ? '${message.substring(0, _maxMessageLength)}...'
          : message;
    }

    return 'An unexpected error occurred';
  }

  /// Handles Dio-specific errors and returns appropriate messages
  ///
  /// Parameters:
  /// - [error]: DioException object
  ///
  /// Returns user-friendly error message
  static String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';

      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';

      case DioExceptionType.receiveTimeout:
        return 'Server response timeout. Please try again.';

      case DioExceptionType.badResponse:
        return _handleBadResponse(error);

      case DioExceptionType.cancel:
        return 'Request was cancelled';

      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';

      case DioExceptionType.unknown:
        return 'Network error. Please check your connection.';

      default:
        return 'An error occurred. Please try again.';
    }
  }

  /// Handles bad HTTP response errors
  ///
  /// Parameters:
  /// - [error]: DioException with response data
  ///
  /// Returns specific error message from server or generic message
  static String _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    // Try to extract message from response
    if (data is Map<String, dynamic>) {
      if (data.containsKey('message')) {
        return data['message'];
      }
      if (data.containsKey('error')) {
        return data['error'];
      }
    }

    // Return message based on status code
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Unauthorized. Please log in again.';
      case 403:
        return 'Access forbidden. You don\'t have permission.';
      case 404:
        return 'Resource not found.';
      case 409:
        return 'Conflict. This resource already exists.';
      case 422:
        return 'Validation error. Please check your input.';
      case 429:
        return 'Too many requests. Please slow down.';
      case 500:
        return 'Server error. Please try again later.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return 'Error occurred (Code: $statusCode)';
    }
  }

  /// Shows error message in a SnackBar
  ///
  /// Parameters:
  /// - [context]: BuildContext for showing SnackBar
  /// - [error]: Error object to display
  /// - [duration]: Optional duration (defaults to 4 seconds)
  ///
  /// Example:
  /// ```dart
  /// ErrorHandler.showErrorSnackBar(context, error);
  /// ```
  static void showErrorSnackBar(
    BuildContext context,
    dynamic error, {
    Duration duration = const Duration(seconds: 4),
  }) {
    final message = getErrorMessage(error);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: Colors.red[700],
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// Shows success message in a SnackBar
  ///
  /// Parameters:
  /// - [context]: BuildContext for showing SnackBar
  /// - [message]: Success message to display
  /// - [duration]: Optional duration (defaults to 3 seconds)
  ///
  /// Example:
  /// ```dart
  /// ErrorHandler.showSuccessSnackBar(context, 'Profile updated!');
  /// ```
  static void showSuccessSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: Colors.green[700],
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// Shows warning message in a SnackBar
  ///
  /// Parameters:
  /// - [context]: BuildContext for showing SnackBar
  /// - [message]: Warning message to display
  /// - [duration]: Optional duration (defaults to 3 seconds)
  static void showWarningSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_outlined, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: Colors.orange[700],
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// Logs error to console with context
  ///
  /// Parameters:
  /// - [error]: Error object to log
  /// - [stackTrace]: Optional stack trace
  /// - [context]: Optional context description
  static void logError(
    dynamic error, {
    StackTrace? stackTrace,
    String? context,
  }) {
    print('═══════════════════════════════════════');
    print('ERROR${context != null ? ' in $context' : ''}');
    print('═══════════════════════════════════════');
    print('Error: $error');
    if (stackTrace != null) {
      print('Stack Trace:\n$stackTrace');
    }
    print('═══════════════════════════════════════');
  }
}

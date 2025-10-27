import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryGold = Color(0xFFC4933F);
  static const Color darkGray = Color(0xFF1D1D1D);
  static const Color backgroundColor = Color(0xFFFFFBF5);

  static ThemeData get theme {
    return ThemeData(
      primaryColor: primaryGold,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: darkGray,
        elevation: 0,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primaryGold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGold,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: darkGray,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: darkGray),
      ),
    );
  }
}

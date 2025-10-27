import 'package:flutter/material.dart';

/// Styled text input field with gold borders, validation support, and optional password masking
class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final String? Function(String?)? validator;

  static const Color primaryGold = Color(0xFFC4933F);
  static const Color darkGray = Color(0xFF1D1D1D);

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: darkGray),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: primaryGold),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: primaryGold, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red.shade300, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        errorStyle: const TextStyle(fontSize: 12, height: 0.8),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
      ),
    );
  }
}

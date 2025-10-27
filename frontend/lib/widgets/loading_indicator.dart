import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Centered circular progress indicator with primary gold color for loading states
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGold),
      ),
    );
  }
}

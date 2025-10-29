import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Displays a large number in gold with a label below, used for statistics on home page
class StatisticWidget extends StatelessWidget {
  final String number;
  final String label;

  const StatisticWidget({super.key, required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          number,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryGold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.getTextColor(context).withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}

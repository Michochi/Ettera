import 'package:flutter/material.dart';

/// Card displaying a feature with icon, title, and description in a white container
class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  static const Color darkGray = Color(0xFF1D1D1D);

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: darkGray.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 48, color: const Color(0xFFC4933F)),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: darkGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(fontSize: 16, color: darkGray.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }
}

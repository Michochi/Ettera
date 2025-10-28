// Reusable footer widget for the app
import 'package:flutter/material.dart';
import 'app_theme.dart';

class CustomFooter extends StatelessWidget {
  const CustomFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 768;

    return Container(
      width: double.infinity,
      color: AppTheme.darkGray,
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 20 : 60,
        vertical: isSmallScreen ? 30 : 50,
      ),
      child: Column(
        children: [
          // Main footer content
          isSmallScreen
              ? Column(
                  children: [
                    _buildAboutSection(),
                    const SizedBox(height: 30),
                    _buildContactSection(),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(child: _buildAboutSection()),
                    const SizedBox(width: 40),
                    Expanded(child: _buildContactSection()),
                  ],
                ),
          const SizedBox(height: 40),
          // Divider
          Container(height: 1, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 20),
          // Copyright
          Text(
            '© 2025 Eterra. All rights reserved.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          // Social links
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialIcon(Icons.facebook, () {}),
              const SizedBox(width: 16),
              _buildSocialIcon(Icons.camera_alt, () {}),
              const SizedBox(width: 16),
              _buildSocialIcon(Icons.travel_explore, () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About Eterra',
          style: TextStyle(
            color: AppTheme.primaryGold,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Connecting hearts and building meaningful relationships. Find your perfect match with our smart matching algorithm.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Us',
          style: TextStyle(
            color: AppTheme.primaryGold,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildContactItem(Icons.email, 'support@eterra.com'),
        const SizedBox(height: 8),
        _buildContactItem(Icons.location_on, 'Pasig City, Philippines'),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryGold, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

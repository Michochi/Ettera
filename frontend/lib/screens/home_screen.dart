import 'package:flutter/material.dart';
import '../widgets/feature_card.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/app_theme.dart';
import '../widgets/custom_container.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Use AppTheme colors
  static Color get primaryGold => AppTheme.primaryGold;
  static Color get darkGray => AppTheme.darkGray;
  static Color get backgroundColor => AppTheme.backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/silhouettes-man-woman.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side - Feature Cards
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        FeatureCard(
                          icon: Icons.favorite,
                          title: 'Smart Matching',
                          description:
                              'Our algorithm helps you find the perfect match based on your preferences',
                        ),
                        const SizedBox(height: 20),
                        FeatureCard(
                          icon: Icons.security,
                          title: 'Safe & Secure',
                          description:
                              'Your privacy and security are our top priority',
                        ),
                        const SizedBox(height: 20),
                        FeatureCard(
                          icon: Icons.people,
                          title: 'Growing Community',
                          description:
                              'Join thousands of people looking for meaningful connections',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Right side - Welcome Box
                  Expanded(
                    flex: 2,
                    child: CustomContainer(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Welcome to Eterra',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: darkGray,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Find your perfect match',
                            style: TextStyle(
                              fontSize: 18,
                              color: darkGray.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // TODO: Navigate to match finding screen
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryGold,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Start Matching',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Define brand colors to match login/register screens
  static const Color primaryGold = Color(0xFFC4933F);
  static const Color darkGray = Color(0xFF1D1D1D);
  static const Color backgroundColor = Color(0xFFFFFBF5);

  void _handleLogout(BuildContext context) {
    // Clear the user from provider
    context.read<UserProvider>().clearUser();

    // Navigate to login screen and remove all previous routes
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Image.asset('assets/images/eterra-logo2.png'),
        ),
        actions: [
          TextButton(
            onPressed: () => _handleLogout(context),
            style: TextButton.styleFrom(foregroundColor: primaryGold),
            child: const Text('Logout', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
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
                      _buildFeatureCard(
                        icon: Icons.favorite,
                        title: 'Smart Matching',
                        description:
                            'Our algorithm helps you find the perfect match based on your preferences',
                      ),
                      const SizedBox(height: 20),
                      _buildFeatureCard(
                        icon: Icons.security,
                        title: 'Safe & Secure',
                        description:
                            'Your privacy and security are our top priority',
                      ),
                      const SizedBox(height: 20),
                      _buildFeatureCard(
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
                  child: Container(
                    padding: const EdgeInsets.all(30),
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
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Icon(icon, size: 40, color: primaryGold),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkGray,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(color: darkGray.withOpacity(0.7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

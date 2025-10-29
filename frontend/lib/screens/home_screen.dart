import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/app_theme.dart';
import '../widgets/home_feature_card.dart';
import '../widgets/statistic_widget.dart';
import '../widgets/custom_footer.dart';
import '../providers/user_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Use AppTheme colors
  static Color get primaryGold => AppTheme.primaryGold;
  static Color get darkGray => AppTheme.darkGray;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 900;
    final userProvider = context.watch<UserProvider>();
    final isLoggedIn = userProvider.user != null;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: const CustomAppBar(),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section with Background Image
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/silhouettes-man-woman.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Color.fromRGBO(0, 0, 0, 0.6),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 20 : 60,
                  vertical: isSmallScreen ? 60 : 130,
                ),
                child: Column(
                  children: [
                    // Main Heading
                    Text(
                      'Find Your Perfect Match',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 36 : 56,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    // Subtitle
                    Text(
                      'Where meaningful connections begin',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 18 : 24,
                        color: Colors.white.withOpacity(0.95),
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(1, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    // CTA Buttons
                    if (isLoggedIn)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/browse');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGold,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 64,
                            vertical: 24,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 8,
                        ),
                        child: const Text(
                          'Match Now',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGold,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48,
                                vertical: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 8,
                            ),
                            child: const Text(
                              'Get Started',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48,
                                vertical: 20,
                              ),
                              side: const BorderSide(
                                color: Colors.white,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Sign in',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            // Features Section
            Container(
              color: AppTheme.getBackgroundColor(context),
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 20 : 60,
                vertical: 60,
              ),
              child: Column(
                children: [
                  Text(
                    'Why Choose Eterra?',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 28 : 36,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.getTextColor(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  // Feature Cards Grid
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 900) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: HomeFeatureCard(
                                icon: Icons.favorite,
                                title: 'Smart Matching',
                                description:
                                    'Our advanced algorithm analyzes your preferences and personality to find your perfect match',
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: HomeFeatureCard(
                                icon: Icons.security,
                                title: 'Safe & Secure',
                                description:
                                    'Your privacy and security are our top priority with verified profiles and encrypted data',
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: HomeFeatureCard(
                                icon: Icons.people,
                                title: 'Growing Community',
                                description:
                                    'Join thousands of people looking for meaningful and lasting connections',
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            HomeFeatureCard(
                              icon: Icons.favorite,
                              title: 'Smart Matching',
                              description:
                                  'Our advanced algorithm analyzes your preferences and personality to find your perfect match',
                            ),
                            const SizedBox(height: 20),
                            HomeFeatureCard(
                              icon: Icons.security,
                              title: 'Safe & Secure',
                              description:
                                  'Your privacy and security are our top priority with verified profiles and encrypted data',
                            ),
                            const SizedBox(height: 20),
                            HomeFeatureCard(
                              icon: Icons.people,
                              title: 'Growing Community',
                              description:
                                  'Join thousands of people looking for meaningful and lasting connections',
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            // Statistics Section
            Container(
              color: AppTheme.getBackgroundColor(context),
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 20 : 60,
                vertical: 60,
              ),
              child: Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: primaryGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: primaryGold.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Wrap(
                  spacing: 40,
                  runSpacing: 30,
                  alignment: WrapAlignment.spaceEvenly,
                  children: [
                    StatisticWidget(number: '10,000+', label: 'Active Users'),
                    StatisticWidget(number: '5,000+', label: 'Matches Made'),
                    StatisticWidget(number: '98%', label: 'Satisfaction Rate'),
                    StatisticWidget(number: '24/7', label: 'Support'),
                  ],
                ),
              ),
            ),

            // Footer
            const CustomFooter(),
          ],
        ),
      ),
    );
  }
}

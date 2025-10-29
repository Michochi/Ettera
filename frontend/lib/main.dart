import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/browse_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/matches_screen.dart';
import 'providers/user_provider.dart';
import 'widgets/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProvider()..loadUserFromPreferences(),
      child: MaterialApp(
        title: 'Eterra - Find Your Perfect Match',
        theme: AppTheme.theme,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/browse': (context) => const BrowseScreen(),
          '/messages': (context) => const MessagesScreen(),
          '/matches': (context) => const MatchesScreen(),
        },
      ),
    );
  }
}

// Splash screen to handle loading user data
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
    });
  }

  Future<void> _checkAuthStatus() async {
    try {
      print('SplashScreen: Starting auth check...');
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Wait for user data to load with a timeout (max 5 seconds)
      int attempts = 0;
      while (!userProvider.isInitialized && attempts < 50) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
        if (attempts % 10 == 0) {
          print('SplashScreen: Waiting for provider... attempt $attempts');
        }
      }

      print(
        'SplashScreen: Provider initialized: ${userProvider.isInitialized}',
      );
      print('SplashScreen: User logged in: ${userProvider.isLoggedIn}');

      // Navigate to home screen after loading
      if (mounted) {
        print('SplashScreen: Navigating to home...');
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      print('Error in splash screen: $e');
      // Navigate anyway after error
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/eterra-logo2.png',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC4933F)),
            ),
          ],
        ),
      ),
    );
  }
}

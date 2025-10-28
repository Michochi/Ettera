import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/user_provider.dart';
import '../models/user.dart';
import '../utils/error_handler.dart';
import '../utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _authService = AuthService();
  bool loading = false;

  // Define brand colors
  static const Color primaryGold = Color(0xFFC4933F);
  static const Color darkGray = Color(0xFF1D1D1D);
  static const Color backgroundColor = Color(0xFFFFFBF5);

  void login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);
    try {
      final response = await _authService.login(
        emailController.text,
        passwordController.text,
      );
      if (response.statusCode == 200) {
        // Parse user data and save to provider
        final userData = response.data['user'];
        final token = response.data['token'];
        final user = User.fromJson(userData);

        if (mounted) {
          context.read<UserProvider>().setUser(user, token: token);

          // Show success message using ErrorHandler
          ErrorHandler.showSuccessSnackBar(context, "Login successful!");
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      // Use ErrorHandler to show user-friendly error message
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, e);
        ErrorHandler.logError(e, context: 'Login');
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputDecoration = (String label, IconData icon) => InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: darkGray.withOpacity(0.7)),
      prefixIcon: Icon(icon, color: primaryGold),
      filled: true,
      fillColor: Colors.grey[50],
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryGold, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red.shade300, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      errorStyle: const TextStyle(fontSize: 12, height: 0.8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              backgroundColor,
              primaryGold.withOpacity(0.1),
              backgroundColor,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Center(
              child: SafeArea(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 480),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 40,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primaryGold.withOpacity(0.1),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: darkGray.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Logo with gradient background
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  primaryGold.withOpacity(0.1),
                                  primaryGold.withOpacity(0.05),
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset(
                              'assets/images/eterra-logo.png',
                              height: 120,
                              width: 120,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Welcome Back',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: darkGray,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Find your perfect match',
                            style: TextStyle(
                              fontSize: 16,
                              color: darkGray.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 40),
                          // Login Form
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: inputDecoration(
                              "Email",
                              Icons.email_outlined,
                            ),
                            validator: Validators.validateEmail,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: passwordController,
                            decoration: inputDecoration(
                              "Password",
                              Icons.lock_outline,
                            ),
                            validator: Validators.validatePassword,
                            obscureText: true,
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: loading ? null : login,
                              style:
                                  ElevatedButton.styleFrom(
                                    backgroundColor: primaryGold,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shadowColor: primaryGold.withOpacity(0.3),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ).copyWith(
                                    overlayColor: WidgetStateProperty.all(
                                      Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                              child: loading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : const Text(
                                      "Login",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: darkGray.withOpacity(0.7),
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pushNamed(context, '/register'),
                                style: TextButton.styleFrom(
                                  foregroundColor: primaryGold,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                ),
                                child: const Text(
                                  "Register",
                                  style: TextStyle(
                                    fontSize: 15,
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
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

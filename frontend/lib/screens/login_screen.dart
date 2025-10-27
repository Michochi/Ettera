import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_container.dart';
import '../providers/user_provider.dart';
import '../models/user.dart';

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

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Login successful!")));
          Navigator.pushReplacementNamed(context, '/');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Login failed")));
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputDecoration = (String label) => InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: darkGray),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryGold),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryGold, width: 2),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Center(
            child: SafeArea(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 450),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 40,
                ),
                child: Container(
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/eterra-logo.png',
                          height: 160,
                          width: 160,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Find your perfect match',
                          style: TextStyle(
                            fontSize: 16,
                            color: darkGray.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Login Form
                        TextFormField(
                          controller: emailController,
                          decoration: inputDecoration("Email"),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email is required';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: passwordController,
                          decoration: inputDecoration("Password"),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                          obscureText: true,
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: loading ? null : login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGold,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: loading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Login",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/register'),
                          style: TextButton.styleFrom(
                            foregroundColor: primaryGold,
                          ),
                          child: const Text(
                            "Don't have an account? Register",
                            style: TextStyle(fontSize: 16),
                          ),
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/app_theme.dart';
import '../providers/user_provider.dart';
import '../models/user.dart';
import '../utils/error_handler.dart';
import '../utils/validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool loading = false;
  String? selectedGender;
  DateTime? selectedBirthday;

  // Use AppTheme colors
  static Color get primaryGold => AppTheme.primaryGold;
  static Color get darkGray => AppTheme.darkGray;
  static Color get backgroundColor => AppTheme.backgroundColor;

  void register() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedGender == null) {
      ErrorHandler.showWarningSnackBar(context, "Please select your gender");
      return;
    }

    if (selectedBirthday == null) {
      ErrorHandler.showWarningSnackBar(context, "Please select your birthday");
      return;
    }

    // Use Validators utility to check age
    final ageError = Validators.validateAge(selectedBirthday!);
    if (ageError != null) {
      ErrorHandler.showWarningSnackBar(context, ageError);
      return;
    }

    setState(() => loading = true);
    try {
      final response = await _authService.register(
        nameController.text,
        emailController.text,
        passwordController.text,
        selectedGender!,
        selectedBirthday!,
      );
      if (response.statusCode == 201) {
        // Parse user data and token, save to provider
        final userData = response.data['user'];
        final token = response.data['token'];
        final user = User.fromJson(userData);

        if (mounted) {
          context.read<UserProvider>().setUser(user, token: token);

          // Show success message using ErrorHandler
          ErrorHandler.showSuccessSnackBar(context, "Registration successful!");
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      // Use ErrorHandler to show user-friendly error message
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, e);
        ErrorHandler.logError(e, context: 'Registration');
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  constraints: const BoxConstraints(maxWidth: 520),
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
                              height: 100,
                              width: 100,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: darkGray,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start your journey to find love',
                            style: TextStyle(
                              fontSize: 15,
                              color: darkGray.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Name field
                          TextFormField(
                            controller: nameController,
                            decoration: _buildInputDecoration(
                              "Full Name",
                              Icons.person_outline,
                            ),
                            validator: Validators.validateName,
                          ),
                          const SizedBox(height: 18),
                          // Email field
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _buildInputDecoration(
                              "Email",
                              Icons.email_outlined,
                            ),
                            validator: Validators.validateEmail,
                          ),
                          const SizedBox(height: 18),
                          // Gender Selection
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 4,
                                  bottom: 12,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.wc,
                                      color: primaryGold,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Gender',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: darkGray,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: RadioListTile<String>(
                                        title: const Text('Male'),
                                        value: 'Male',
                                        groupValue: selectedGender,
                                        activeColor: primaryGold,
                                        contentPadding: EdgeInsets.zero,
                                        dense: true,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedGender = value;
                                          });
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: RadioListTile<String>(
                                        title: const Text('Female'),
                                        value: 'Female',
                                        groupValue: selectedGender,
                                        activeColor: primaryGold,
                                        contentPadding: EdgeInsets.zero,
                                        dense: true,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedGender = value;
                                          });
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: RadioListTile<String>(
                                        title: const Text('Other'),
                                        value: 'Other',
                                        groupValue: selectedGender,
                                        activeColor: primaryGold,
                                        contentPadding: EdgeInsets.zero,
                                        dense: true,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedGender = value;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          // Birthday Selection
                          InkWell(
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime(2000, 1, 1),
                                firstDate: DateTime(1940),
                                lastDate: DateTime.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: primaryGold,
                                        onPrimary: Colors.white,
                                        onSurface: darkGray,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                setState(() {
                                  selectedBirthday = picked;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.cake_outlined, color: primaryGold),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Birthday',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: darkGray.withOpacity(0.6),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          selectedBirthday == null
                                              ? 'Select your birthday'
                                              : '${selectedBirthday!.day}/${selectedBirthday!.month}/${selectedBirthday!.year}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: selectedBirthday == null
                                                ? darkGray.withOpacity(0.5)
                                                : darkGray,
                                            fontWeight: selectedBirthday == null
                                                ? FontWeight.normal
                                                : FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: darkGray.withOpacity(0.5),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Password field
                          TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: _buildInputDecoration(
                              "Password",
                              Icons.lock_outline,
                            ),
                            validator: Validators.validatePassword,
                          ),
                          const SizedBox(height: 18),
                          // Confirm Password field
                          TextFormField(
                            controller: confirmPasswordController,
                            obscureText: true,
                            decoration: _buildInputDecoration(
                              "Confirm Password",
                              Icons.lock_outline,
                            ),
                            validator: (value) =>
                                Validators.validatePasswordMatch(
                                  passwordController.text,
                                  value,
                                ),
                          ),
                          const SizedBox(height: 32),
                          // Register Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: loading ? null : register,
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
                                      "Create Account",
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
                                "Already have an account? ",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: darkGray.withOpacity(0.7),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pushReplacementNamed(
                                  context,
                                  '/login',
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: primaryGold,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                ),
                                child: const Text(
                                  "Login",
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

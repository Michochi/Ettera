import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class AuthButtons extends StatelessWidget {
  const AuthButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isLoggedIn = userProvider.user != null;

    if (isLoggedIn) {
      return TextButton(
        onPressed: () {
          userProvider.clearUser();
          Navigator.pushReplacementNamed(context, '/');
        },
        child: const Text('Logout', style: TextStyle(fontSize: 16)),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/login'),
          child: const Text('Login', style: TextStyle(fontSize: 16)),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/register'),
          child: const Text('Register', style: TextStyle(fontSize: 16)),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}

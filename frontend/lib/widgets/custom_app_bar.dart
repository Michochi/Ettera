import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_buttons.dart';
import '../providers/user_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;

  const CustomAppBar({super.key, this.actions});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isLoggedIn = userProvider.user != null;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leadingWidth: 200,
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Image.asset(
          'assets/images/eterra-logo2.png',
          fit: BoxFit.contain,
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/'),
            child: const Text('Home', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 8),
          if (isLoggedIn)
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/profile'),
              child: const Text('Profile', style: TextStyle(fontSize: 16)),
            ),
        ],
      ),
      actions: actions ?? [const AuthButtons()],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

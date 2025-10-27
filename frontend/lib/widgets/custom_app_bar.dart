import 'package:flutter/material.dart';
import 'auth_buttons.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;

  const CustomAppBar({super.key, this.actions});

  @override
  Widget build(BuildContext context) {
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
      actions: actions ?? [const AuthButtons()],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

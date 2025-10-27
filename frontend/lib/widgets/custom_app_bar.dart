import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_buttons.dart';
import 'profile_dropdown.dart';
import '../providers/user_provider.dart';

/// Reusable app bar with logo, centered navigation links, and auth-aware actions
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;

  const CustomAppBar({super.key, this.actions});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isLoggedIn = userProvider.user != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;

        if (isDesktop) {
          // Desktop layout - full navigation
          return AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leadingWidth: 200,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/'),
                child: Image.asset(
                  'assets/images/eterra-logo2.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            centerTitle: true,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/'),
                  child: const Text('Home', style: TextStyle(fontSize: 16)),
                ),
                if (isLoggedIn) ...[
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/browse'),
                    child: const Text(
                      'Match Now',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/profile'),
                    child: const Text(
                      'Profile',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ],
            ),
            actions:
                actions ??
                [
                  if (isLoggedIn)
                    const Padding(
                      padding: EdgeInsets.only(right: 16.0),
                      child: ProfileDropdown(),
                    )
                  else
                    const AuthButtons(),
                ],
          );
        } else {
          // Mobile/Tablet layout - hamburger menu
          return AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.black),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            title: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/'),
              child: Image.asset(
                'assets/images/eterra-logo2.png',
                height: 40,
                fit: BoxFit.contain,
              ),
            ),
            centerTitle: true,
            actions:
                actions ??
                [
                  if (isLoggedIn)
                    const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: ProfileDropdown(),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: IconButton(
                        icon: const Icon(Icons.login, color: Colors.black),
                        onPressed: () => Navigator.pushNamed(context, '/login'),
                      ),
                    ),
                ],
          );
        }
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

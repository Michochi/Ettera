import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'app_theme.dart';

/// Profile picture dropdown menu with user info, Profile Management, and Logout options
class ProfileDropdown extends StatelessWidget {
  const ProfileDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    if (user == null) return const SizedBox.shrink();

    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.primaryGold.withOpacity(0.2),
            backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty
                ? NetworkImage(user.photoUrl!)
                : null,
            child: user.photoUrl == null || user.photoUrl!.isEmpty
                ? Icon(Icons.person, size: 22, color: AppTheme.primaryGold)
                : null,
          ),
          Icon(Icons.arrow_drop_down, color: AppTheme.darkGray, size: 24),
        ],
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          enabled: false,
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryGold.withOpacity(0.2),
                backgroundImage:
                    user.photoUrl != null && user.photoUrl!.isNotEmpty
                    ? NetworkImage(user.photoUrl!)
                    : null,
                child: user.photoUrl == null || user.photoUrl!.isEmpty
                    ? Icon(Icons.person, size: 20, color: AppTheme.primaryGold)
                    : null,
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkGray,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.darkGray.withOpacity(0.6),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person_outline, color: AppTheme.primaryGold, size: 20),
              const SizedBox(width: 12),
              const Text('Profile Management'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, color: Colors.red[400], size: 20),
              const SizedBox(width: 12),
              Text('Logout', style: TextStyle(color: Colors.red[400])),
            ],
          ),
        ),
      ],
      onSelected: (String value) {
        if (value == 'profile') {
          Navigator.pushNamed(context, '/profile');
        } else if (value == 'logout') {
          userProvider.clearUser();
          Navigator.pushReplacementNamed(context, '/');
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'app_theme.dart';

/// Toggle button for switching between light and dark mode
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return IconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return RotationTransition(
            turns: animation,
            child: ScaleTransition(scale: animation, child: child),
          );
        },
        child: Icon(
          isDark ? Icons.light_mode : Icons.dark_mode,
          key: ValueKey(isDark),
          color: AppTheme.primaryGold,
        ),
      ),
      tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
      onPressed: () => themeProvider.toggleTheme(),
    );
  }
}

/// Theme toggle switch for settings/profile
class ThemeToggleSwitch extends StatelessWidget {
  const ThemeToggleSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return SwitchListTile(
      title: Text(
        'Dark Mode',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppTheme.getTextColor(context),
        ),
      ),
      subtitle: Text(
        isDark ? 'Currently using dark theme' : 'Currently using light theme',
        style: TextStyle(
          fontSize: 14,
          color: AppTheme.getTextColor(context).withOpacity(0.6),
        ),
      ),
      value: isDark,
      activeColor: AppTheme.primaryGold,
      onChanged: (value) => themeProvider.toggleTheme(),
      secondary: Icon(
        isDark ? Icons.dark_mode : Icons.light_mode,
        color: AppTheme.primaryGold,
      ),
    );
  }
}

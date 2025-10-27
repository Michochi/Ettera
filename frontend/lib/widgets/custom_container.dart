import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  static const Color darkGray = Color(0xFF1D1D1D);

  const CustomContainer({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(24),
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
      child: child,
    );
  }
}

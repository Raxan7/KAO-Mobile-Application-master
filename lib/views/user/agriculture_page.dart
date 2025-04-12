import 'package:flutter/material.dart';

class AgriculturePage extends StatelessWidget {
  final Function(bool) onThemeChanged;
  final bool isDarkMode;

  const AgriculturePage({
    super.key,
    required this.onThemeChanged,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    final padding = isDesktop 
        ? const EdgeInsets.symmetric(horizontal: 100, vertical: 20)
        : const EdgeInsets.all(16.0);

    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.agriculture,
              size: isDesktop ? 120 : 80,
              color: Colors.teal,
            ),
            const SizedBox(height: 20),
            Text(
              'Agriculture Page',
              style: TextStyle(
                fontSize: isDesktop ? 32 : 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Coming Soon',
              style: TextStyle(
                fontSize: isDesktop ? 24 : 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
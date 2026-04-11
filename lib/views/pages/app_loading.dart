import 'package:flutter/material.dart';

class AppLoadingScreen extends StatelessWidget {
  const AppLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Circular progress indicator using theme's primary color
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            // Optional loading text – adapts to dark mode automatically
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 14,
                color: scheme.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
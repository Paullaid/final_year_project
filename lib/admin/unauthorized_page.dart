import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UnauthorizedPage extends StatelessWidget {
  const UnauthorizedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, color: scheme.error, size: 72),
              const SizedBox(height: 12),
              Text(
                'Unauthorized',
                style: GoogleFonts.playfairDisplay(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Your account is not allowed to access the admin panel.',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(fontSize: 15),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

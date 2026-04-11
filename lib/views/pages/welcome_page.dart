import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:past_questions/views/pages/description_page.dart';
import 'package:past_questions/views/pages/login_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: Stack(
        children: [
          // ---------- FUN BACKGROUND DECORATIONS ----------
          ..._buildBackgroundDecorations(context),

          // ---------- MAIN CONTENT (foreground) ----------
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // University Hat Icon
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.school,
                          size: 48,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // IUO Name (classy serif)
                      Text(
                        "IGBINEDION UNIVERSITY OKADA",
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Welcome Animation
                      Container(
                        height: 160,
                        width: 160,
                        child: Lottie.asset(
                          "assets/lotties/loader.json",
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Main Title (elegant serif)
                      Text(
                        "Question Vault",
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),

                      // Value Proposition (clean sans)
                      Text(
                        "Access past questions anytime, anywhere",
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),

                      // Get Started Button (gradient elevated)
                      GradientElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DescriptionPage(),
                            ),
                          );
                        },
                        gradient: LinearGradient(
                          colors: [primaryColor, primaryColor.withOpacity(0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        child: Text(
                          "Get Started",
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            letterSpacing: 3.0,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFB4D6F1), // light blue tint
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Login Button (gradient filled button style)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: GradientFilledButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade700,
                              Colors.blue.shade400,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          child: Text(
                            "Already have an account? Login",
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Footer
                      Text(
                        "© Igbinedion University Okada\nFaculty of Natural and Applied Sciences",
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withOpacity(0.6),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper: builds a set of fun background shapes (circles + small dots)
  List<Widget> _buildBackgroundDecorations(BuildContext context) {
    final colors = [
      Colors.blue.withOpacity(0.08),
      Colors.purple.withOpacity(0.06),
      Colors.teal.withOpacity(0.07),
      Colors.orange.withOpacity(0.05),
      Colors.pink.withOpacity(0.06),
    ];
    final sizes = [140.0, 220.0, 90.0, 170.0, 110.0];
    final positions = [
      Alignment.topLeft,
      Alignment.bottomRight,
      Alignment.topRight,
      Alignment.bottomLeft,
      Alignment.center,
    ];

    List<Widget> circles = List.generate(5, (index) {
      return Positioned(
        top: index % 2 == 0 ? -40 : null,
        bottom: index % 2 == 1 ? -40 : null,
        left: index == 2 ? -50 : null,
        right: index == 3 ? -50 : null,
        child: Container(
          width: sizes[index % sizes.length],
          height: sizes[index % sizes.length],
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors[index % colors.length],
          ),
        ),
      );
    });

    // Add some floating small dots for extra fun
    List<Widget> dots = List.generate(12, (index) {
      return Positioned(
        top: (index * 47) % 300 - 30,
        left: (index * 83) % 200 - 20,
        child: Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.withOpacity(0.2),
          ),
        ),
      );
    });

    return [...circles, ...dots];
  }
}

// ----------------------------------------------------------------------
// Custom gradient button with elevation (behaves like ElevatedButton)
// ----------------------------------------------------------------------
class GradientElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Gradient gradient;
  final Widget child;
  final double elevation;

  const GradientElevatedButton({
    super.key,
    required this.onPressed,
    required this.gradient,
    required this.child,
    this.elevation = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation,
      borderRadius: BorderRadius.circular(12),
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------
// Gradient filled button (no elevation, flat but with gradient)
// ----------------------------------------------------------------------
class GradientFilledButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Gradient gradient;
  final Widget child;

  const GradientFilledButton({
    super.key,
    required this.onPressed,
    required this.gradient,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(child: child),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:past_questions/views/pages/description_page.dart';
import 'package:past_questions/views/pages/login_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color blob = isDark
        ? Colors.lightBlueAccent.withOpacity(0.08)
        : Colors.blue.shade100.withOpacity(0.14);
    final Color blob2 =
        isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.7);

    return Scaffold(
      body: Stack(
        children: [
          // Base surface + subtle accent gradient (respects theme).
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surface,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scheme.surface,
                    isDark ? Colors.black.withOpacity(0.18) : Colors.blue.shade50,
                    scheme.surface,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),
          // Decorative blurred circles.
          Positioned(
            top: -40,
            left: -30,
            child: _BlurBlob(diameter: 180, color: blob),
          ),
          Positioned(
            bottom: -60,
            right: -40,
            child: _BlurBlob(diameter: 240, color: blob),
          ),
          Positioned(
            top: 140,
            right: 20,
            child: _BlurBlob(diameter: 110, color: blob2),
          ),
          // Floating dots/lines.
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _DotsPainter(
                  color: (isDark ? Colors.white : Colors.blueGrey)
                      .withOpacity(isDark ? 0.08 : 0.12),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 650),
                    curve: Curves.easeOutCubic,
                    builder: (context, t, child) {
                      final slide = Offset(0, (1 - t) * 0.06);
                      return Opacity(
                        opacity: t,
                        child: Transform.translate(offset: slide * 300, child: child),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(isDark ? 0.14 : 0.10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(isDark ? 0.35 : 0.10),
                                blurRadius: 18,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.school_rounded,
                            size: 44,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          "IGBINEDION UNIVERSITY OKADA",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontSize: 12.5,
                            letterSpacing: 2.1,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withOpacity(isDark ? 0.82 : 0.78),
                          ),
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          height: 160,
                          width: 160,
                          child: Lottie.asset(
                            "assets/lotties/loader.json",
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 26),
                        Text(
                          "Past Questions Bank",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            height: 1.05,
                            color: Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Access past questions anytime, anywhere",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            height: 1.35,
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withOpacity(isDark ? 0.78 : 0.70),
                          ),
                        ),
                        const SizedBox(height: 34),
                        _GradientButton(
                          label: "Get Started",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DescriptionPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute<void>(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            side: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(isDark ? 0.65 : 0.55),
                            ),
                          ),
                          child: Text(
                            "Already have an account? Login",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),
                        Text(
                          "© Igbinedion University Okada\nFaculty of Natural and Applied Sciences",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            fontSize: 12,
                            height: 1.5,
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withOpacity(isDark ? 0.62 : 0.60),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurBlob extends StatelessWidget {
  const _BlurBlob({required this.diameter, required this.color});

  final double diameter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: diameter,
      width: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.lightBlueAccent.withOpacity(isDark ? 0.9 : 1),
        scheme.primary.withOpacity(isDark ? 0.9 : 1),
      ],
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.12),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            letterSpacing: 2.4,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  _DotsPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    void dot(double x, double y, double r) =>
        canvas.drawCircle(Offset(x, y), r, paint);

    dot(size.width * 0.12, size.height * 0.20, 1.5);
    dot(size.width * 0.24, size.height * 0.34, 1.1);
    dot(size.width * 0.82, size.height * 0.22, 1.3);
    dot(size.width * 0.76, size.height * 0.64, 1.1);
    dot(size.width * 0.18, size.height * 0.78, 1.2);

    final line = Paint()
      ..color = color.withOpacity(0.8)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(size.width * 0.10, size.height * 0.56),
      Offset(size.width * 0.28, size.height * 0.52),
      line,
    );
    canvas.drawLine(
      Offset(size.width * 0.72, size.height * 0.40),
      Offset(size.width * 0.88, size.height * 0.44),
      line,
    );
  }

  @override
  bool shouldRepaint(covariant _DotsPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
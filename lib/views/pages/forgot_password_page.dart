import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:past_questions/routes/guest_routes.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _email = TextEditingController();
  bool _busy = false;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    final String email = _email.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter your email address.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      setState(() => _sent = true);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Could not send reset email.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _backToLogin() {
    Navigator.pushReplacementNamed(context, GuestRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final cardColor = isDark
        ? Colors.black.withOpacity(0.30)
        : Colors.white.withOpacity(0.22);

    InputDecoration fieldDecoration() {
      return InputDecoration(
        labelText: 'Email',
        hintText: 'you@example.com',
        labelStyle: GoogleFonts.lato(
          fontWeight: FontWeight.w600,
          color: scheme.onSurface.withOpacity(isDark ? 0.75 : 0.70),
        ),
        hintStyle: GoogleFonts.lato(
          color: scheme.onSurface.withOpacity(isDark ? 0.35 : 0.45),
        ),
        prefixIcon: Icon(Icons.email_outlined, color: scheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: scheme.outlineVariant.withOpacity(isDark ? 0.30 : 0.55),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        filled: true,
        fillColor: scheme.surface.withOpacity(isDark ? 0.22 : 0.85),
      );
    }

    Widget gradientButton({
      required String label,
      required VoidCallback? onPressed,
      bool busy = false,
    }) {
      final gradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(isDark ? 0.16 : 0.85),
          Colors.lightBlueAccent.withOpacity(isDark ? 0.75 : 1),
          scheme.primary.withOpacity(isDark ? 0.85 : 1),
        ],
        stops: const [0.0, 0.52, 1.0],
      );
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.40 : 0.14),
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
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: busy
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  label,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
                ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surface,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    scheme.surface,
                    isDark ? Colors.black.withOpacity(0.22) : Colors.blue.shade50,
                    scheme.surface,
                  ],
                  stops: const [0, 0.55, 1],
                ),
              ),
            ),
          ),
          Positioned(
            top: -60,
            left: -40,
            child: _Blob(
              diameter: 220,
              color: (isDark ? Colors.lightBlueAccent : Colors.blue.shade100)
                  .withOpacity(isDark ? 0.08 : 0.14),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -60,
            child: _Blob(
              diameter: 260,
              color: (isDark ? Colors.white : Colors.blue.shade200)
                  .withOpacity(isDark ? 0.05 : 0.10),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  title: Text(
                    'Forgot password',
                    style: GoogleFonts.playfairDisplay(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 650),
                          curve: Curves.easeOutCubic,
                          builder: (context, t, child) {
                            return Opacity(
                              opacity: t,
                              child: Transform.translate(
                                offset: Offset(0, (1 - t) * 18),
                                child: child,
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                _sent
                                    ? 'Check your inbox for a reset link.'
                                    : 'Enter your account email and we will send a password reset link.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lato(
                                  fontSize: 15,
                                  height: 1.4,
                                  color: scheme.onSurface
                                      .withOpacity(isDark ? 0.72 : 0.64),
                                ),
                              ),
                              const SizedBox(height: 18),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                                  child: Container(
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: cardColor,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(
                                          isDark ? 0.08 : 0.20,
                                        ),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(
                                            isDark ? 0.45 : 0.12,
                                          ),
                                          blurRadius: 24,
                                          offset: const Offset(0, 14),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        if (!_sent) ...[
                                          TextField(
                                            controller: _email,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            decoration: fieldDecoration(),
                                            style: GoogleFonts.lato(),
                                          ),
                                          const SizedBox(height: 16),
                                          gradientButton(
                                            label: 'Send reset email',
                                            onPressed: _busy ? null : _sendReset,
                                            busy: _busy,
                                          ),
                                        ] else ...[
                                          gradientButton(
                                            label: 'Back to Login',
                                            onPressed: _backToLogin,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
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
          ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.diameter, required this.color});

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
            blurRadius: 42,
            spreadRadius: 10,
          ),
        ],
      ),
    );
  }
}

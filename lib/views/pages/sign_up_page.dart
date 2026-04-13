import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:past_questions/routes/guest_routes.dart';
import 'package:past_questions/views/pages/login_page.dart';
import 'package:past_questions/views/pages/welcome_page.dart';
import 'package:past_questions/views/widgets/hero_widget.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    final String email = _email.text.trim();
    final String password = _password.text;
    final String confirm = _confirm.text;

    if (email.isEmpty || password.isEmpty) {
      _toast('Please enter email and password.');
      return;
    }
    if (password != confirm) {
      _toast('Passwords do not match.');
      return;
    }
    if (password.length < 6) {
      _toast('Password must be at least 6 characters.');
      return;
    }

    setState(() => _busy = true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _toast(e.message ?? 'Could not create account.');
    } catch (e) {
      if (!mounted) return;
      _toast('Something went wrong: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final cardColor = isDark
        ? Colors.black.withOpacity(0.30)
        : Colors.white.withOpacity(0.22);

    InputDecoration fieldDecoration({
      required String label,
      required String hint,
      required IconData icon,
      Widget? suffix,
    }) {
      return InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.lato(
          fontWeight: FontWeight.w600,
          color: scheme.onSurface.withOpacity(isDark ? 0.75 : 0.70),
        ),
        hintStyle: GoogleFonts.lato(
          color: scheme.onSurface.withOpacity(isDark ? 0.35 : 0.45),
        ),
        prefixIcon: Icon(icon, color: scheme.primary.withOpacity(0.9)),
        suffixIcon: suffix,
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
            minimumSize: const Size(double.infinity, 54),
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
                    letterSpacing: 1.4,
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
            right: -40,
            child: _Blob(
              diameter: 220,
              color: (isDark ? Colors.lightBlueAccent : Colors.blue.shade100)
                  .withOpacity(isDark ? 0.08 : 0.14),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
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
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: scheme.primary),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const WelcomePage(),
                        ),
                      );
                    },
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
                              Center(child: HeroWidget()),
                              const SizedBox(height: 18),
                              Text(
                                'Create account',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  height: 1.05,
                                  color:
                                      Theme.of(context).textTheme.titleLarge?.color,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Sign up with your email to get started',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lato(
                                  fontSize: 15,
                                  height: 1.35,
                                  color: scheme.onSurface
                                      .withOpacity(isDark ? 0.70 : 0.62),
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
                                        TextField(
                                          controller: _email,
                                          keyboardType: TextInputType.emailAddress,
                                          decoration: fieldDecoration(
                                            label: 'Email',
                                            hint: 'you@example.com',
                                            icon: Icons.email_outlined,
                                          ),
                                          style: GoogleFonts.lato(),
                                        ),
                                        const SizedBox(height: 14),
                                        TextField(
                                          controller: _password,
                                          obscureText: _obscurePassword,
                                          decoration: fieldDecoration(
                                            label: 'Password',
                                            hint: 'At least 6 characters',
                                            icon: Icons.lock_outline,
                                            suffix: IconButton(
                                              icon: Icon(
                                                _obscurePassword
                                                    ? Icons.visibility_off
                                                    : Icons.visibility,
                                                color: scheme.onSurface.withOpacity(
                                                  isDark ? 0.65 : 0.55,
                                                ),
                                              ),
                                              onPressed: () => setState(() {
                                                _obscurePassword = !_obscurePassword;
                                              }),
                                            ),
                                          ),
                                          style: GoogleFonts.lato(),
                                        ),
                                        const SizedBox(height: 14),
                                        TextField(
                                          controller: _confirm,
                                          obscureText: _obscureConfirm,
                                          decoration: fieldDecoration(
                                            label: 'Confirm password',
                                            hint: 'Repeat password',
                                            icon: Icons.lock_outline,
                                            suffix: IconButton(
                                              icon: Icon(
                                                _obscureConfirm
                                                    ? Icons.visibility_off
                                                    : Icons.visibility,
                                                color: scheme.onSurface.withOpacity(
                                                  isDark ? 0.65 : 0.55,
                                                ),
                                              ),
                                              onPressed: () => setState(() {
                                                _obscureConfirm = !_obscureConfirm;
                                              }),
                                            ),
                                          ),
                                          style: GoogleFonts.lato(),
                                        ),
                                        const SizedBox(height: 16),
                                        gradientButton(
                                          label: 'Sign up',
                                          onPressed: _busy ? null : _createAccount,
                                          busy: _busy,
                                        ),
                                        const SizedBox(height: 14),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Already have an account? ',
                                              style: GoogleFonts.lato(
                                                color: scheme.onSurface.withOpacity(
                                                  isDark ? 0.72 : 0.62,
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pushReplacementNamed(
                                                  context,
                                                  GuestRoutes.login,
                                                );
                                              },
                                              child: Text(
                                                'Login',
                                                style: GoogleFonts.montserrat(
                                                  fontWeight: FontWeight.w700,
                                                  color: scheme.primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
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

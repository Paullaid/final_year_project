import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:past_questions/data/google_auth_instance.dart';
import 'package:past_questions/providers/guest_session_provider.dart';
import 'package:past_questions/routes/guest_routes.dart';
import 'package:past_questions/views/widgets/hero_widget.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _obscurePassword = true;
  bool _googleSignInLoading = false;
  bool _emailLoginLoading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _onEmailLogin() async {
    final String email = _email.text.trim();
    final String password = _password.text;
    if (email.isEmpty || password.isEmpty) {
      _snack('Please enter email and password.');
      return;
    }

    setState(() => _emailLoginLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _snack(e.message ?? 'Login failed.');
    } catch (e) {
      if (!mounted) return;
      _snack('Something went wrong: $e');
    } finally {
      if (mounted) setState(() => _emailLoginLoading = false);
    }
  }

  Future<void> _onContinueWithGoogle() async {
    setState(() => _googleSignInLoading = true);
    try {
      final credential = await googleAuthService.signInWithGoogle();
      if (!mounted) return;
      if (credential == null) {
        _snack('Google sign-in was cancelled or could not finish.');
        return;
      }
    } catch (e, st) {
      debugPrint('Google sign-in error: $e\n$st');
      if (!mounted) return;
      _snack('Something went wrong: $e');
    } finally {
      if (mounted) setState(() => _googleSignInLoading = false);
    }
  }

  void _onGuest() {
    context.read<GuestSessionProvider>().enterGuestMode();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Widget _formScaffold(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final double maxWidth = 420;
    final cardColor = isDark
        ? Colors.black.withOpacity(0.30)
        : Colors.white.withOpacity(0.22);

    Widget gradientButton({
      required String label,
      required VoidCallback? onPressed,
      Widget? leading,
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
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (leading != null) ...[
                      leading,
                      const SizedBox(width: 10),
                    ],
                    Text(
                      label,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      );
    }

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
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: scheme.primary),
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushReplacementNamed(
                          context,
                          GuestRoutes.welcome,
                        );
                      }
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
                        constraints: BoxConstraints(maxWidth: maxWidth),
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
                                'Welcome Back',
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
                                'Sign in to continue to your account',
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
                                            hint: 'Enter your password',
                                            icon: Icons.lock_outline,
                                            suffix: IconButton(
                                              icon: Icon(
                                                _obscurePassword
                                                    ? Icons.visibility_off
                                                    : Icons.visibility,
                                                color: scheme.onSurface
                                                    .withOpacity(isDark ? 0.65 : 0.55),
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _obscurePassword = !_obscurePassword;
                                                });
                                              },
                                            ),
                                          ),
                                          style: GoogleFonts.lato(),
                                        ),
                                        const SizedBox(height: 8),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton(
                                            onPressed: () {
                                              Navigator.pushNamed(
                                                context,
                                                GuestRoutes.forgotPassword,
                                              );
                                            },
                                            child: Text(
                                              'Forgot Password?',
                                              style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.w600,
                                                color: scheme.primary,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        gradientButton(
                                          label: 'Login',
                                          onPressed: _emailLoginLoading
                                              ? null
                                              : _onEmailLogin,
                                          busy: _emailLoginLoading,
                                        ),
                                        const SizedBox(height: 14),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Don't have an account? ",
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
                                                  GuestRoutes.signUp,
                                                );
                                              },
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                                minimumSize: const Size(50, 30),
                                              ),
                                              child: Text(
                                                'Sign Up',
                                                style: GoogleFonts.montserrat(
                                                  fontWeight: FontWeight.w700,
                                                  color: scheme.primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Divider(
                                                color: scheme.outlineVariant
                                                    .withOpacity(isDark ? 0.25 : 0.55),
                                                thickness: 0.7,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                              ),
                                              child: Text(
                                                'OR',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 11,
                                                  letterSpacing: 1.6,
                                                  color: scheme.onSurface
                                                      .withOpacity(isDark ? 0.55 : 0.55),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Divider(
                                                color: scheme.outlineVariant
                                                    .withOpacity(isDark ? 0.25 : 0.55),
                                                thickness: 0.7,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        gradientButton(
                                          label: 'Continue with Google',
                                          onPressed: _googleSignInLoading
                                              ? null
                                              : _onContinueWithGoogle,
                                          busy: _googleSignInLoading,
                                          leading: const Icon(
                                            Icons.g_mobiledata_rounded,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        OutlinedButton.icon(
                                          onPressed: _onGuest,
                                          style: OutlinedButton.styleFrom(
                                            minimumSize: const Size(double.infinity, 52),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            side: BorderSide(
                                              color: scheme.primary
                                                  .withOpacity(isDark ? 0.55 : 0.50),
                                            ),
                                          ),
                                          icon: Icon(
                                            Icons.person_outline,
                                            color: scheme.primary,
                                          ),
                                          label: Text(
                                            'Continue as Guest',
                                            style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.w600,
                                              color: scheme.primary,
                                            ),
                                          ),
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return _formScaffold(context);
      },
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

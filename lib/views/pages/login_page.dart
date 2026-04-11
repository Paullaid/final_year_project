import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:past_questions/data/auth_service.dart';
import 'package:past_questions/views/pages/sign_in_page.dart';
import 'package:past_questions/views/pages/welcome_page.dart';
import 'package:past_questions/views/pages/widget_tree.dart';
import 'package:past_questions/views/theme/auth_typography.dart';
import 'package:past_questions/views/widgets/auth_login_components.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController controllerEmail = TextEditingController();
  final TextEditingController controllerPassword = TextEditingController();

  bool _obscurePassword = true;
  String errorMessage = '';

  @override
  void dispose() {
    controllerEmail.dispose();
    controllerPassword.dispose();
    super.dispose();
  }

  void signIn() async {
    try {
      await authServiceNotifier.value.signIn(
        email: controllerEmail.text,
        password: controllerPassword.text,
      );
      popPage();
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? "Incorrect credentials";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage), // 👈 dynamic error message
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade700,
          ),
      );
    }
  }

  void popPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const  WidgetTree()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    final titleColor = scheme.onSurface;
    const loginTitleBlue = Color(0xFF0C4A6E);
    final loginTitleColor = isDark ? scheme.primary : loginTitleBlue;
    final muted = isDark ? Colors.blueGrey[200]! : Colors.blueGrey[600]!;
    final accentBlue = isDark ? kAuthBlueLight : kAuthBlueDeep;
    final linkBlue = kAuthBlueDeep;
    final fieldInnerFillLight = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.white, const Color(0xFFE0F2FE)],
    );
    final fieldInnerFillDark = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [const Color(0xFF1E293B), const Color(0xFF0F172A)],
    );

    final blurSigma = isDark ? 30.0 : 24.0;
    final glassGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              Colors.white.withOpacity(0.2),
              kAuthBlueDeep.withOpacity(0.48),
              kAuthBlueMid.withOpacity(0.32),
              Colors.white.withOpacity(0.12),
            ]
          : [
              Colors.white.withOpacity(0.96),
              Color.lerp(
                scheme.primaryContainer,
                Colors.white,
                0.35,
              )!.withOpacity(0.92),
              kAuthBlueLight.withOpacity(0.62),
              Colors.white.withOpacity(0.88),
            ],
    );

    final themeBgGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              scheme.surface,
              Color.lerp(scheme.surface, scheme.primary, 0.22)!,
              scheme.surfaceContainerHigh,
            ]
          : [
              scheme.surface,
              Color.lerp(scheme.surface, scheme.primary, 0.08)!,
              scheme.surfaceContainerLow,
            ],
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: scheme.surface,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: scheme.surface,
        body: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(decoration: BoxDecoration(gradient: themeBgGradient)),
            Positioned(
              top: -120,
              left: -100,
              child: IgnorePointer(
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        kAuthBlueLight.withOpacity(isDark ? 0.55 : 0.65),
                        kAuthBlueMid.withOpacity(isDark ? 0.45 : 0.55),
                        kAuthBlueDeep.withOpacity(isDark ? 0.38 : 0.48),
                        scheme.primary.withOpacity(isDark ? 0.25 : 0.2),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              right: -60,
              child: IgnorePointer(
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.bottomRight,
                      end: Alignment.topLeft,
                      colors: [
                        kAuthBlueGlow.withOpacity(isDark ? 0.5 : 0.58),
                        kAuthBlueMid.withOpacity(isDark ? 0.42 : 0.52),
                        kAuthBlueDeep.withOpacity(isDark ? 0.35 : 0.42),
                        scheme.tertiary.withOpacity(isDark ? 0.22 : 0.18),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.sizeOf(context).height * 0.22,
              left: 24,
              child: IgnorePointer(
                child: Opacity(
                  opacity: isDark ? 0.15 : 0.35,
                  child: Transform.rotate(
                    angle: -0.35,
                    child: Container(
                      width: 120,
                      height: 14,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.9),
                            kAuthBlueMid.withOpacity(0.5),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Stack(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 20,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight - 40,
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 400),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: scheme.shadow.withOpacity(
                                        isDark ? 0.35 : 0.12,
                                      ),
                                      blurRadius: 28,
                                      spreadRadius: -4,
                                      offset: const Offset(0, 14),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(28),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: blurSigma,
                                      sigmaY: blurSigma,
                                    ),
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: glassGradient,
                                        borderRadius: BorderRadius.circular(28),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 26,
                                          vertical: 40,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Login',
                                              textAlign: TextAlign.center,
                                              style:
                                                  AuthTypography.displayTitle(
                                                    loginTitleColor,
                                                  ),
                                            ),
                                            const SizedBox(height: 10),
                                            Container(
                                              height: 5,
                                              width: 72,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(99),
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.white.withOpacity(
                                                      0.2,
                                                    ),
                                                    kAuthBlueMid,
                                                    kAuthBlueLight,
                                                    Colors.white.withOpacity(
                                                      0.15,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 22),
                                            Text.rich(
                                              textAlign: TextAlign.center,
                                              TextSpan(
                                                style: AuthTypography.subtitle(
                                                  muted,
                                                ),
                                                children: [
                                                  const TextSpan(
                                                    text:
                                                        "Don't have an account? ",
                                                  ),
                                                  WidgetSpan(
                                                    alignment:
                                                        PlaceholderAlignment
                                                            .baseline,
                                                    baseline:
                                                        TextBaseline.alphabetic,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        Navigator.pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                LoginPage(),
                                                          ),
                                                        );
                                                      },
                                                      child: Text(
                                                        'sign up',
                                                        style:
                                                            AuthTypography.link(
                                                              linkBlue,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 36),
                                            AuthStadiumEmailField(
                                              controller: controllerEmail,
                                              innerGradient: isDark
                                                  ? fieldInnerFillDark
                                                  : fieldInnerFillLight,
                                              isDark: isDark,
                                              accent: accentBlue,
                                            ),
                                            const SizedBox(height: 22),
                                            AuthStadiumPasswordField(
                                              controller: controllerPassword,
                                              obscureText: _obscurePassword,
                                              onToggleObscure: () {
                                                setState(
                                                  () => _obscurePassword =
                                                      !_obscurePassword,
                                                );
                                              },
                                              innerGradient: isDark
                                                  ? fieldInnerFillDark
                                                  : fieldInnerFillLight,
                                              accent: accentBlue,
                                              isDark: isDark,
                                              onForgot: () {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Password reset coming soon.',
                                                    ),
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                  ),
                                                );
                                              },
                                            ),
                                            const SizedBox(height: 14),
                                            Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 18,
                                                  ),
                                              height: 1,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.transparent,
                                                    kAuthBlueMid.withOpacity(
                                                      0.62,
                                                    ),
                                                    Colors.white.withOpacity(
                                                      isDark ? 0.32 : 0.78,
                                                    ),
                                                    kAuthBlueLight.withOpacity(
                                                      0.68,
                                                    ),
                                                    Colors.transparent,
                                                  ],
                                                ),
                                              ),
                                            ),
                                            AuthGradientPillButton(
                                              label: 'Login',
                                              icon: Icons.login_rounded,
                                              onPressed: () {
                                                signIn();                                                
                                              },
                                            ),
                                            const SizedBox(height: 22),
                                            OutlinedButton.icon(
                                              onPressed: () {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Google sign-in coming soon.',
                                                    ),
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                  ),
                                                );
                                              },
                                              icon: Icon(
                                                Icons.g_mobiledata,
                                                size: 30,
                                                color: linkBlue,
                                              ),
                                              label: Text(
                                                'Continue with Google',
                                                style:
                                                    AuthTypography.outlinedButton(
                                                      linkBlue,
                                                    ),
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: linkBlue,
                                                minimumSize: const Size(
                                                  double.infinity,
                                                  54,
                                                ),
                                                side: BorderSide(
                                                  color: linkBlue.withOpacity(
                                                    0.45,
                                                  ),
                                                  width: 1.5,
                                                ),
                                                backgroundColor: scheme.surface
                                                    .withOpacity(
                                                      isDark ? 0.2 : 0.45,
                                                    ),
                                                shape: const StadiumBorder(),
                                              ),
                                            ),
                                            const SizedBox(height: 26),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const WidgetTree(),
                                                  ),
                                                );
                                              },
                                              child: Text(
                                                'Continue as guest',
                                                style:
                                                    AuthTypography.textButtonLink(
                                                      linkBlue,
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
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: titleColor,
                        size: 20,
                      ),
                      onPressed: () {
                        print("Button pressed");
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WelcomePage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

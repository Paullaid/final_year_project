import 'package:flutter/material.dart';
import 'package:past_questions/views/theme/auth_typography.dart';

/// Shared palette + fields for [LoginPage] and [SignUpPage].
const Color kAuthBlueLight = Color(0xFF7DD3FC);
const Color kAuthBlueMid = Color(0xFF38BDF8);
const Color kAuthBlueDeep = Color(0xFF0284C7);
const Color kAuthBlueGlow = Color(0xFFA5F3FC);
const double kAuthWhiteBorder = 3;

class AuthGradientPillButton extends StatelessWidget {
  const AuthGradientPillButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                kAuthBlueDeep,
                kAuthBlueMid,
                kAuthBlueLight,
              ],
            ),
            border: Border.all(
              color: Colors.white,
              width: kAuthWhiteBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: kAuthBlueMid.withOpacity(0.45),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Text(
                label,
                style: AuthTypography.pillButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthStadiumEmailField extends StatelessWidget {
  const AuthStadiumEmailField({
    super.key,
    required this.controller,
    required this.innerGradient,
    required this.isDark,
    required this.accent,
    this.hintText = 'Email',
  });

  final TextEditingController controller;
  final Gradient innerGradient;
  final bool isDark;
  final Color accent;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    final hint = isDark ? Colors.blueGrey[300] : Colors.blueGrey[400];

    return Container(
      padding: const EdgeInsets.all(kAuthWhiteBorder),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        gradient: LinearGradient(
          colors: [
            Colors.white,
            kAuthBlueLight.withOpacity(1),
            kAuthBlueMid.withOpacity(0.55),
          ],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(33),
          gradient: innerGradient,
          border: Border.all(
            color: Colors.white.withOpacity(isDark ? 0.2 : 0.85),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 18),
              child: Icon(
                Icons.mail_outline_rounded,
                color: accent,
                size: 22,
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                style: AuthTypography.fieldText(
                  isDark ? Colors.white : const Color(0xFF0C4A6E),
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: AuthTypography.fieldHint(
                    hint ?? Colors.blueGrey,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthStadiumPasswordField extends StatelessWidget {
  const AuthStadiumPasswordField({
    super.key,
    required this.controller,
    required this.obscureText,
    required this.onToggleObscure,
    required this.innerGradient,
    required this.accent,
    required this.isDark,
    this.showForgot = true,
    this.onForgot,
    this.hintText = 'Password',
  });

  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onToggleObscure;
  final Gradient innerGradient;
  final Color accent;
  final bool isDark;
  final bool showForgot;
  final VoidCallback? onForgot;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    final hint = isDark ? Colors.blueGrey[300] : Colors.blueGrey[400];
    final iconMuted = isDark ? Colors.blueGrey[200] : Colors.blueGrey[500];

    return Container(
      padding: const EdgeInsets.all(kAuthWhiteBorder),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        gradient: LinearGradient(
          colors: [
            Colors.white,
            kAuthBlueMid.withOpacity(0.88),
            kAuthBlueDeep.withOpacity(0.45),
          ],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(33),
          gradient: innerGradient,
          border: Border.all(
            color: Colors.white.withOpacity(isDark ? 0.2 : 0.85),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 18),
              child: Icon(
                Icons.lock_outline_rounded,
                color: accent,
                size: 22,
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                obscureText: obscureText,
                textInputAction: TextInputAction.done,
                style: AuthTypography.fieldText(
                  isDark ? Colors.white : const Color(0xFF0C4A6E),
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: AuthTypography.fieldHint(
                    hint ?? Colors.blueGrey,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 20,
                  ),
                ),
              ),
            ),
            if (showForgot && onForgot != null)
              TextButton(
                onPressed: onForgot,
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [kAuthBlueDeep, kAuthBlueMid],
                  ).createShader(bounds),
                  child: Text(
                    'FORGOT',
                    style: AuthTypography.forgotCaps(),
                  ),
                ),
              ),
            IconButton(
              onPressed: onToggleObscure,
              icon: Icon(
                obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: iconMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:past_questions/providers/auth_flow_controller.dart';
import 'package:past_questions/providers/guest_session_provider.dart';
import 'package:past_questions/routes/guest_routes.dart';
import 'package:past_questions/views/pages/app_loading.dart';
import 'package:past_questions/views/pages/forgot_password_page.dart';
import 'package:past_questions/views/pages/login_page.dart';
import 'package:past_questions/views/pages/sign_up_page.dart';
import 'package:past_questions/views/pages/welcome_page.dart';
import 'package:past_questions/views/pages/widget_tree.dart';
import 'package:provider/provider.dart';

/// Root auth: [AppLoadingScreen] while auth is resolving, then [WidgetTree] if
/// signed in or guest, else a guest [Navigator] (welcome / login / sign-up).
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  String _guestInitialRoute = GuestRoutes.welcome;
  int _guestNavGeneration = 0;
  User? _previousUser;

  Route<dynamic> _onGuestRoute(RouteSettings settings) {
    switch (settings.name) {
      case GuestRoutes.login:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const LoginPage(),
        );
      case GuestRoutes.signUp:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const SignUpPage(),
        );
      case GuestRoutes.forgotPassword:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ForgotPasswordPage(),
        );
      case GuestRoutes.welcome:
      default:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const WelcomePage(),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<GuestSessionProvider>();
    final authFlow = context.watch<AuthFlowController>();

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AppLoadingScreen();
        }

        final User? user = snapshot.data;
        final guest = context.read<GuestSessionProvider>();
        final bool showMainApp = user != null || guest.isGuest;

        if (showMainApp) {
          if (user != null) {
            _previousUser = user;
          }
          return const WidgetTree();
        }

        if (user == null && _previousUser != null) {
          _guestInitialRoute = GuestRoutes.login;
          _guestNavGeneration++;
          _previousUser = null;
        } else if (authFlow.preferLoginEntry) {
          _guestInitialRoute = GuestRoutes.login;
          _guestNavGeneration++;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.read<AuthFlowController>().acknowledgeLoginShell();
            }
          });
        }

        return Navigator(
          key: ValueKey<int>(_guestNavGeneration),
          initialRoute: _guestInitialRoute,
          onGenerateRoute: _onGuestRoute,
        );
      },
    );
  }
}

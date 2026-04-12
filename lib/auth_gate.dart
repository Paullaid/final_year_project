import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:past_questions/data/google_auth_instance.dart';
import 'package:past_questions/routes/guest_routes.dart';
import 'package:past_questions/views/pages/login_page.dart';
import 'package:past_questions/views/pages/sign_in_page.dart';
import 'package:past_questions/views/pages/welcome_page.dart';
import 'package:past_questions/views/pages/widget_tree.dart';

/// Root auth routing: listens to [googleAuthService.authStateChanges] and
/// switches between the main shell ([WidgetTree]) and a guest [Navigator].
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  /// After a real sign-out (was signed in → now signed out), open login first.
  String _guestInitialRoute = GuestRoutes.welcome;
  int _guestNavGeneration = 0;

  StreamSubscription<User?>? _authSub;
  User? _previousUser;

  @override
  void initState() {
    super.initState();
    _authSub = googleAuthService.authStateChanges.listen((User? user) {
      if (_previousUser != null && user == null) {
        setState(() {
          _guestInitialRoute = GuestRoutes.login;
          _guestNavGeneration++;
        });
      }
      _previousUser = user;
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  Route<dynamic> _onGuestRoute(RouteSettings settings) {
    switch (settings.name) {
      case GuestRoutes.login:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const LoginPage(),
        );
      case GuestRoutes.signIn:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const SignInPage(),
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
    return StreamBuilder<User?>(
      stream: googleAuthService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final User? user = snapshot.data;
        if (user != null) {
          return const WidgetTree();
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

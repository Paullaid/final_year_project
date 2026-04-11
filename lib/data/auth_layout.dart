import 'package:flutter/material.dart';
import 'package:past_questions/data/auth_service.dart';
import 'package:past_questions/views/pages/app_loading.dart';
import 'package:past_questions/views/pages/home_page.dart';
import 'package:past_questions/views/pages/login_page.dart';
import 'package:past_questions/views/pages/welcome_page.dart';
import 'package:past_questions/views/pages/widget_tree.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, this.pageIfNotConnected});

  final Widget? pageIfNotConnected;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: authServiceNotifier,
      builder: (context, authServiceNotifier, child) {
        return StreamBuilder(
          stream: authServiceNotifier.authStateChanges, 
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            Widget widget;
            if (snapshot.connectionState == ConnectionState.waiting) {
              widget = const AppLoadingScreen();
            } else if (snapshot.hasData) {
              widget = const WidgetTree();
            } else {
              widget = pageIfNotConnected ?? const WelcomePage();
            }
            return widget;
          },
        );
      },
    );
  }
}

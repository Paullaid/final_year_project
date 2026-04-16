import 'package:flutter/material.dart';
import 'package:past_questions/admin/unauthorized_page.dart';
import 'package:past_questions/providers/admin_role_provider.dart';
import 'package:provider/provider.dart';

class AdminGuard extends StatelessWidget {
  const AdminGuard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminRoleProvider>(
      builder: (context, role, _) {
        if (role.loading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (!role.isAdmin) {
          return const UnauthorizedPage();
        }
        return child;
      },
    );
  }
}

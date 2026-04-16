import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Resolves whether the current signed-in user is an admin.
/// Admin if either:
/// 1) custom claim: role == 'admin' OR admin == true
/// 2) Firestore users/{uid}.role == 'admin' OR isAdmin == true
class AdminRoleProvider extends ChangeNotifier {
  AdminRoleProvider() {
    _sub = FirebaseAuth.instance.authStateChanges().listen((_) => refresh());
    refresh();
  }

  late final StreamSubscription<User?> _sub;
  bool _loading = true;
  bool _isAdmin = false;
  String? _error;

  bool get loading => _loading;
  bool get isAdmin => _isAdmin;
  String? get error => _error;

  Future<void> refresh() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _isAdmin = false;
        return;
      }

      final token = await user.getIdTokenResult(true);
      final claims = token.claims ?? const <String, dynamic>{};
      final claimRole = claims['role']?.toString().toLowerCase();
      final claimAdmin = claims['admin'] == true;
      if (claimRole == 'admin' || claimAdmin) {
        _isAdmin = true;
        return;
      }

      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data();
      final role = data?['role']?.toString().toLowerCase();
      final isAdminField = data?['isAdmin'] == true;
      _isAdmin = role == 'admin' || isAdminField;
    } catch (e) {
      _error = e.toString();
      _isAdmin = false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

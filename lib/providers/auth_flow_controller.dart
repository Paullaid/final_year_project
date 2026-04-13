import 'package:flutter/foundation.dart';

/// Coordinates post-logout UI: next unauthenticated shell should open on login.
class AuthFlowController extends ChangeNotifier {
  bool _preferLoginEntry = false;

  bool get preferLoginEntry => _preferLoginEntry;

  void requestLoginShellAfterLogout() {
    _preferLoginEntry = true;
    notifyListeners();
  }

  void acknowledgeLoginShell() {
    if (!_preferLoginEntry) return;
    _preferLoginEntry = false;
    notifyListeners();
  }
}

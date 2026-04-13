import 'package:flutter/foundation.dart';

/// Guest mode: main app without a Firebase user (local session only).
class GuestSessionProvider extends ChangeNotifier {
  bool _isGuest = false;

  bool get isGuest => _isGuest;

  void enterGuestMode() {
    if (_isGuest) return;
    _isGuest = true;
    notifyListeners();
  }

  void clearGuest() {
    if (!_isGuest) return;
    _isGuest = false;
    notifyListeners();
  }
}

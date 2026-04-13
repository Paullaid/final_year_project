import 'package:flutter/foundation.dart';

/// Bottom navigation index for [WidgetTree] (0–3: Home, Search, Profile, Settings).
class NavigationProvider extends ChangeNotifier {
  int _index = 0;

  int get currentIndex => _index;

  void setIndex(int index) {
    if (index < 0 || index > 3) return;
    if (_index == index) return;
    _index = index;
    notifyListeners();
  }

  void resetToHome() {
    setIndex(0);
  }
}

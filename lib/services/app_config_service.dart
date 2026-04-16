import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// App-level runtime config fetched from Firebase Remote Config.
class AppConfigService {
  AppConfigService._();

  static final AppConfigService instance = AppConfigService._();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 12),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );
      await _remoteConfig.setDefaults(const {
        'R2_WORKER_URL': '',
      });
      await _remoteConfig.fetchAndActivate();
      _initialized = true;
      debugPrint('[AppConfigService] Remote Config initialized.');
    } catch (e, st) {
      // Non-fatal: app can still use dotenv fallback.
      debugPrint('[AppConfigService] Remote Config init failed: $e\n$st');
    }
  }

  String? get workerUrl {
    final value = _remoteConfig.getString('R2_WORKER_URL').trim();
    if (value.isEmpty) return null;
    return value;
  }
}

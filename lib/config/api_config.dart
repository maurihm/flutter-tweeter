import 'package:flutter/foundation.dart';

class ApiConfig {
  // Allow overriding the API base URL at build time with --dart-define=API_BASE_URL=<url>
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');

  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;

    if (kIsWeb) {
      return 'http://localhost:8080';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8080';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return 'http://localhost:8080';
      default:
        return 'http://localhost:8080';
    }
  }
}
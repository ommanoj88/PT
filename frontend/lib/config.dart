import 'package:flutter/foundation.dart' show kIsWeb;

/// Configuration class for the Pure app.
/// Handles API Base URL based on the platform.
class Config {
  Config._();

  /// API Base URL configuration.
  /// - Web: Uses localhost
  /// - Android Emulator: Uses 10.0.2.2 (special alias for host localhost)
  /// - iOS Simulator and other platforms: Uses localhost
  static String get apiBaseUrl {
    // For web, always use localhost
    if (kIsWeb) {
      return 'http://localhost:3000';
    }
    
    // For mobile platforms, default to localhost
    // Android emulator users should manually change this to 10.0.2.2
    return 'http://localhost:3000';
  }

  /// API endpoints
  static String get healthEndpoint => '$apiBaseUrl/api/health';
  static String get loginEndpoint => '$apiBaseUrl/api/auth/login';
}

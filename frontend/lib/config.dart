import 'dart:io' show Platform;

/// Configuration class for the VibeCheck app.
/// Handles API Base URL based on the platform.
class Config {
  Config._();

  /// API Base URL configuration.
  /// - Android Emulator: Uses 10.0.2.2 (special alias for host localhost)
  /// - iOS Simulator and other platforms: Uses localhost
  static String get apiBaseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  /// API endpoints
  static String get healthEndpoint => '$apiBaseUrl/api/health';
}

import 'package:flutter/foundation.dart' show kIsWeb;

/// Configuration class for the VibeCheck app.
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
  static String get profileEndpoint => '$apiBaseUrl/api/profile';
  static String get goLiveEndpoint => '$apiBaseUrl/api/profile/go-live';
  static String get goOfflineEndpoint => '$apiBaseUrl/api/profile/go-offline';
  static String get feedEndpoint => '$apiBaseUrl/api/feed';
  static String get interactEndpoint => '$apiBaseUrl/api/interact';
  static String get matchesEndpoint => '$apiBaseUrl/api/interact/matches';
  static String get diceEndpoint => '$apiBaseUrl/api/dice';
  static String get walletEndpoint => '$apiBaseUrl/api/wallet';
  static String get notificationsEndpoint => '$apiBaseUrl/api/notifications';
  static String chatEndpoint(String matchId) => '$apiBaseUrl/api/chat/$matchId';
  static String get reportEndpoint => '$apiBaseUrl/api/report';
  
  // Pure-style chat requests endpoints
  static String get requestsEndpoint => '$apiBaseUrl/api/requests';
  static String get sentRequestsEndpoint => '$apiBaseUrl/api/requests/sent';
  static String acceptRequestEndpoint(String requestId) => '$apiBaseUrl/api/requests/$requestId/accept';
  static String rejectRequestEndpoint(String requestId) => '$apiBaseUrl/api/requests/$requestId/reject';
}

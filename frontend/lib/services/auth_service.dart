import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

/// Service class to handle authentication API calls.
class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  /// Login or register user with phone and/or email.
  /// Returns the authentication token on success.
  static Future<Map<String, dynamic>> login({
    String? phone,
    String? email,
  }) async {
    if (phone == null && email == null) {
      throw Exception('Phone or email is required');
    }

    final response = await http.post(
      Uri.parse(Config.loginEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (email != null && email.isNotEmpty) 'email': email,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      // Save token and user info to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, data['data']['token']);
      await prefs.setString(_userIdKey, data['data']['user']['id']);

      return data['data'];
    } else {
      throw Exception(data['error'] ?? 'Login failed');
    }
  }

  /// Check if user is logged in by verifying token exists.
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return token != null && token.isNotEmpty;
  }

  /// Get the stored authentication token.
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Get the stored user ID.
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  /// Logout the user by clearing stored credentials.
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
  }
}

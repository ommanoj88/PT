import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'auth_service.dart';

/// Service class to handle feed/discovery API calls.
class FeedService {
  /// Get potential matches.
  static Future<List<Map<String, dynamic>>> getFeed() async {
    final token = await AuthService.getToken();

    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.get(
      Uri.parse(Config.feedEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return List<Map<String, dynamic>>.from(data['data']['users']);
    } else {
      throw Exception(data['error'] ?? 'Failed to get feed');
    }
  }

  /// Record an interaction (like or pass).
  static Future<Map<String, dynamic>> interact({
    required String toUserId,
    required String action,
  }) async {
    final token = await AuthService.getToken();

    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.post(
      Uri.parse(Config.interactEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'to_user_id': toUserId,
        'action': action,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'];
    } else {
      throw Exception(data['error'] ?? 'Failed to record interaction');
    }
  }

  /// Get a random user (Roll the Dice).
  static Future<Map<String, dynamic>?> rollDice() async {
    final token = await AuthService.getToken();

    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.get(
      Uri.parse(Config.diceEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return data['data']['user'];
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception(data['error'] ?? 'Failed to roll dice');
    }
  }

  /// Get matches.
  static Future<List<Map<String, dynamic>>> getMatches() async {
    final token = await AuthService.getToken();

    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.get(
      Uri.parse(Config.matchesEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return List<Map<String, dynamic>>.from(data['data']['matches']);
    } else {
      throw Exception(data['error'] ?? 'Failed to get matches');
    }
  }
}

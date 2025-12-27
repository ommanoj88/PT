import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'auth_service.dart';

/// Service class to handle Pure-style chat request API calls.
class RequestService {
  /// Send a chat request to another user.
  static Future<Map<String, dynamic>> sendRequest({
    required String toUserId,
    String? message,
  }) async {
    final token = await AuthService.getToken();

    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.post(
      Uri.parse(Config.requestsEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'to_user_id': toUserId,
        if (message != null) 'message': message,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201 && data['success'] == true) {
      return data['data'];
    } else {
      throw Exception(data['error'] ?? 'Failed to send request');
    }
  }

  /// Get incoming chat requests.
  static Future<List<Map<String, dynamic>>> getRequests() async {
    final token = await AuthService.getToken();

    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.get(
      Uri.parse(Config.requestsEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return List<Map<String, dynamic>>.from(data['data']['requests']);
    } else {
      throw Exception(data['error'] ?? 'Failed to get requests');
    }
  }

  /// Get sent chat requests.
  static Future<List<Map<String, dynamic>>> getSentRequests() async {
    final token = await AuthService.getToken();

    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.get(
      Uri.parse(Config.sentRequestsEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return List<Map<String, dynamic>>.from(data['data']['requests']);
    } else {
      throw Exception(data['error'] ?? 'Failed to get sent requests');
    }
  }

  /// Accept a chat request.
  static Future<Map<String, dynamic>> acceptRequest(String requestId) async {
    final token = await AuthService.getToken();

    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.post(
      Uri.parse(Config.acceptRequestEndpoint(requestId)),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'];
    } else {
      throw Exception(data['error'] ?? 'Failed to accept request');
    }
  }

  /// Reject a chat request.
  static Future<void> rejectRequest(String requestId) async {
    final token = await AuthService.getToken();

    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.post(
      Uri.parse(Config.rejectRequestEndpoint(requestId)),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['error'] ?? 'Failed to reject request');
    }
  }
}

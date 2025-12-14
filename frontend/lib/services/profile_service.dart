import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'auth_service.dart';

/// Service class to handle profile API calls.
class ProfileService {
  /// Get own profile.
  static Future<Map<String, dynamic>> getProfile() async {
    final token = await AuthService.getToken();

    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.get(
      Uri.parse(Config.profileEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'];
    } else {
      throw Exception(data['error'] ?? 'Failed to get profile');
    }
  }

  /// Update own profile.
  static Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? gender,
    String? lookingFor,
    String? bio,
    String? birthdate,
    List<String>? photos,
    List<String>? tags,
  }) async {
    final token = await AuthService.getToken();

    if (token == null) {
      throw Exception('Not authenticated');
    }

    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (gender != null) body['gender'] = gender;
    if (lookingFor != null) body['looking_for'] = lookingFor;
    if (bio != null) body['bio'] = bio;
    if (birthdate != null) body['birthdate'] = birthdate;
    if (photos != null) body['photos'] = photos;
    if (tags != null) body['tags'] = tags;

    final response = await http.put(
      Uri.parse(Config.profileEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'];
    } else {
      throw Exception(data['error'] ?? 'Failed to update profile');
    }
  }
}

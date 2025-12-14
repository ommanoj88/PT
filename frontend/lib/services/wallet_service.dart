import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'auth_service.dart';

/// Service class to handle wallet/credits API calls.
class WalletService {
  /// Get current credit balance.
  static Future<int> getBalance() async {
    final token = await AuthService.getToken();

    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.get(
      Uri.parse(Config.walletEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return data['data']['credits'] as int;
    } else {
      throw Exception(data['error'] ?? 'Failed to get balance');
    }
  }

  /// Add credits (mock purchase).
  static Future<int> addCredits(int amount) async {
    final token = await AuthService.getToken();

    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.post(
      Uri.parse('${Config.walletEndpoint}/add'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'amount': amount,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return data['data']['credits'] as int;
    } else {
      throw Exception(data['error'] ?? 'Failed to add credits');
    }
  }
}

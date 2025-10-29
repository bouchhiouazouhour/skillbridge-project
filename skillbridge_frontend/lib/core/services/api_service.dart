import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class ApiService {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/login'),
      body: {'email': email, 'password': password},
    );

    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> register(
      String name, String email, String password, String confirmPassword) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/register'),
      body: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': confirmPassword,
      },
    );

    return json.decode(response.body);
  }
}

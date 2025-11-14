import 'package:dio/dio.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient api;
  AuthService(this.api);

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final Response resp = await api.post(
      '/login',
      data: {'email': email, 'password': password},
    );
    final data = resp.data['data'] as Map<String, dynamic>;
    final token = data['token'] as String;
    await api.saveToken(token);
    return data['user'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final Response resp = await api.post(
      '/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
    final data = resp.data['data'] as Map<String, dynamic>;
    final token = data['token'] as String;
    await api.saveToken(token);
    return data['user'] as Map<String, dynamic>;
  }

  Future<void> logout() async {
    try {
      await api.post('/logout');
    } finally {
      await api.clearToken();
    }
  }

  Future<Map<String, dynamic>> me() async {
    final Response resp = await api.get('/me');
    return (resp.data['data'] as Map<String, dynamic>);
  }
}

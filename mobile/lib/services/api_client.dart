import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  final Dio dio;
  final FlutterSecureStorage storage;
  static const _tokenKey = 'auth_token';

  ApiClient(String baseUrl)
    : dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
          headers: {'Accept': 'application/json'},
        ),
      ),
      storage = const FlutterSecureStorage() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.read(key: _tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Basic unauthorized handling: clear token so app returns to login on next check
          if (error.response?.statusCode == 401) {
            await clearToken();
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<void> saveToken(String token) =>
      storage.write(key: _tokenKey, value: token);
  Future<void> clearToken() => storage.delete(key: _tokenKey);
  Future<String?> getToken() => storage.read(key: _tokenKey);

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? query}) =>
      dio.get<T>(path, queryParameters: query);
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
  }) => dio.post<T>(path, data: data, queryParameters: query);
  Future<Response<T>> put<T>(String path, {dynamic data}) =>
      dio.put<T>(path, data: data);
  Future<Response<T>> delete<T>(String path) => dio.delete<T>(path);
}

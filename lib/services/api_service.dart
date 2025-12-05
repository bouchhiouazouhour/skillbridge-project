import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:file_picker/file_picker.dart';
import '../models/user.dart';
import '../models/cv_analysis.dart';
import '../models/job_match.dart';
import '../config/app_config.dart';

class ApiService {
  // Use configurable base URL from app config
  static String get baseUrl => AppConfig.apiBaseUrl;
  final storage = const FlutterSecureStorage();

  Future<String?> getToken() async {
    return await storage.read(key: 'auth_token');
  }

  Future<void> saveToken(String token) async {
    await storage.write(key: 'auth_token', value: token);
  }

  Future<void> deleteToken() async {
    await storage.delete(key: 'auth_token');
  }

  Future<Map<String, String>> getHeaders({bool includeAuth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Authentication
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: await getHeaders(),
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await saveToken(data['token']);
      return data;
    } else {
      throw Exception('Registration failed: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: await getHeaders(),
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveToken(data['token']);
      return data;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: await getHeaders(includeAuth: true),
      );
    } finally {
      await deleteToken();
    }
  }

  // CV Operations
  Future<Map<String, dynamic>> uploadCV(PlatformFile file) async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/cv/upload'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    // Handle both web and mobile platforms
    if (kIsWeb) {
      // For web: use bytes
      if (file.bytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'cv',
            file.bytes!,
            filename: file.name,
          ),
        );
      } else {
        throw Exception('File bytes not available for web upload. Ensure withData: true is set when picking the file.');
      }
    } else {
      // For mobile/desktop: use path
      if (file.path != null) {
        request.files.add(
          await http.MultipartFile.fromPath('cv', file.path!),
        );
      } else {
        throw Exception('File path not available on this platform. File path is required for mobile/desktop uploads.');
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Upload failed: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getResults(int cvId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/cv/$cvId/results'),
      headers: await getHeaders(includeAuth: true),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get results: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getScore(int cvId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/cv/$cvId/score'),
      headers: await getHeaders(includeAuth: true),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get score: ${response.body}');
    }
  }

  Future<List<dynamic>> getSuggestions(int cvId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/cv/$cvId/suggestions'),
      headers: await getHeaders(includeAuth: true),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['suggestions'] ?? [];
    } else {
      throw Exception('Failed to get suggestions: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> exportPDF(int cvId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cv/$cvId/export'),
      headers: await getHeaders(includeAuth: true),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to export PDF: ${response.body}');
    }
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: await getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['user'] ?? data;
      }
      return null;
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  Future<List<dynamic>> getCVHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cv/history'),
        headers: await getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['cvs'] ?? data['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error fetching CV history: $e');
      return [];
    }
  }

  // Job Match Operations

  Future<JobMatch> analyzeJobMatch(int cvId, String jobDescription) async {
    final response = await http.post(
      Uri.parse('$baseUrl/job-match/analyze'),
      headers: await getHeaders(includeAuth: true),
      body: jsonEncode({'cv_id': cvId, 'job_description': jobDescription}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return JobMatch.fromJson(data['job_match']);
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Failed to analyze job match');
    }
  }

  Future<List<JobMatch>> getJobMatchHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/job-match/history'),
        headers: await getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> matches = data['job_matches'] ?? [];
        return matches.map((m) => JobMatch.fromJson(m)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching job match history: $e');
      return [];
    }
  }

  Future<void> saveJobMatch(int matchId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/job-match/$matchId/save'),
      headers: await getHeaders(includeAuth: true),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Failed to save job match');
    }
  }

  Future<JobMatch> getJobMatchDetails(int matchId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/job-match/$matchId'),
      headers: await getHeaders(includeAuth: true),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return JobMatch.fromJson(data['job_match']);
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Failed to get job match details');
    }
  }

  Future<void> deleteJobMatch(int matchId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/job-match/$matchId'),
      headers: await getHeaders(includeAuth: true),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Failed to delete job match');
    }
  }
}

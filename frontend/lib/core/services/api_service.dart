import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class ApiService {
  static String? token;

  // ----------- LOGIN -----------
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/login'),
      body: {
        'email': email,
        'password': password,
      },
    );

    final data = json.decode(response.body);

    if (data.containsKey('token')) {
      token = data['token'];
    }

    return data;
  }

  // ----------- REGISTER -----------
  static Future<Map<String, dynamic>> register(
      String name, String email, String password, String confirmPassword) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/register'),
      headers: {"Accept": "application/json"},
      body: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': confirmPassword,
      },
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(response.body);
    }

    // Si Laravel renvoie une erreur
    try {
      return json.decode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Erreur interne serveur'};
    }  
  }

  // ----------- GET PROFILE -----------
  static Future<Map<String, dynamic>> getProfile() async {
    if (token == null) {
      throw Exception("Token is null — veuillez vous connecter !");
    }

    final res = await http.get(
      Uri.parse("${ApiConstants.baseUrl}/profile"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    return json.decode(res.body);
  }

  // ----------- UPDATE PROFILE (name + avatar) -----------
  static Future<Map<String, dynamic>> updateProfile(
    String name,
    dynamic avatarFile,
  ) async {

    final uri = Uri.parse("${ApiConstants.baseUrl}/profile");

    var request = http.MultipartRequest("POST", uri);
    request.fields['name'] = name;
    request.headers['Authorization'] = "Bearer $token";
    request.headers['Accept'] = "application/json";
    request.fields['_method'] = "PUT"; // Laravel fix

    if (avatarFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'avatar',
        avatarFile.path,
      ));
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    return json.decode(response.body);
  }

static Future<Map<String, dynamic>> updateProfileFull(
    Map<String, String> fields,
    File? avatarFile,
  ) async {

  final uri = Uri.parse("${ApiConstants.baseUrl}/profile");

  var request = http.MultipartRequest("POST", uri);
  request.headers['Authorization'] = "Bearer $token";
  request.headers['Accept'] = "application/json";

  request.fields['_method'] = "PUT";

  fields.forEach((key, value) {
    request.fields[key] = value;
  });

  if (avatarFile != null) {
    request.files.add(await http.MultipartFile.fromPath(
      'avatar',
      avatarFile.path,
    ));
  }

  final streamed = await request.send();
  final response = await http.Response.fromStream(streamed);

  return json.decode(response.body);
}

  // =====================================================================
  //                🔥🔥   NOUVELLES MÉTHODES PROFIL COMPLET   🔥🔥
  // =====================================================================

  // ----------- UPDATE "ABOUT" -----------
  static Future<Map<String, dynamic>> updateAbout(String summary) async {
    final res = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/about"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
      body: {
        "summary": summary,
      },
    );

    return json.decode(res.body);
  }

  // ----------- ADD SKILL -----------
  static Future<Map<String, dynamic>> addSkill(String skill) async {
    final res = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/skills"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
      body: {
        "name": skill,
      },
    );

    return json.decode(res.body);
  }

  // ----------- ADD EXPERIENCE -----------
  static Future<Map<String, dynamic>> addExperience(Map<String, String> data) async {
    final res = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/experiences"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
      body: data,
    );

    return json.decode(res.body);
  }

  // ----------- ADD EDUCATION -----------
  static Future<Map<String, dynamic>> addEducation(Map<String, String> data) async {
    final res = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/educations"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
      body: data,
    );

    return json.decode(res.body);
  }

  // ----------- ADD PROJECT -----------
  static Future<Map<String, dynamic>> addProject(Map<String, String> data) async {
    final res = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/projects"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
      body: data,
    );

    return json.decode(res.body);
  }

  // ----------- ADD CERTIFICATION -----------
  static Future<Map<String, dynamic>> addCertification(Map<String, String> data) async {
    final res = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/certifications"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
      body: data,
    );

    return json.decode(res.body);
  }
}

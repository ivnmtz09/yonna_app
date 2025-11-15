import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // --- IP Y URL BASE ---
  static const String _host = '192.168.1.4';
  static const String baseUrl = 'http://$_host:8000/api/';

  // --- SINGLETON SETUP ---
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late SharedPreferences _prefs;
  Map<String, dynamic> userData = {};

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final userJson = _prefs.getString('userData');
    if (userJson != null) {
      userData = jsonDecode(userJson);
    }
  }

  // --- HELPERS ---
  String? _getAccessToken() => _prefs.getString('access_token');
  String? _getRefreshToken() => _prefs.getString('refresh_token');

  Future<void> _saveTokens(String access, String refresh) async {
    await _prefs.setString('access_token', access);
    await _prefs.setString('refresh_token', refresh);
  }

  Future<void> _clearSession() async {
    await _prefs.remove('access_token');
    await _prefs.remove('refresh_token');
    await _prefs.remove('userData');
    userData = {};
  }

  Future<void> _saveUserData(Map<String, dynamic> data) async {
    userData = {
      'id': data['id'],
      'email': data['email'],
      'first_name': data['first_name'],
      'last_name': data['last_name'],
      'role': data['role'],
      'level': data['level'] ?? 1,
      'xp': data['xp'] ?? 0,
    };
    await _prefs.setString('userData', jsonEncode(userData));
  }

  Future<Map<String, dynamic>> _makeAuthenticatedRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final token = _getAccessToken();
    if (token == null) throw Exception('No autenticado');

    final uri = Uri.parse('$baseUrl$endpoint');
    http.Response response;

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(uri, headers: headers);
        break;
      case 'POST':
        response = await http.post(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
        break;
      case 'PATCH':
        response = await http.patch(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
        break;
      case 'DELETE':
        response = await http.delete(uri, headers: headers);
        break;
      default:
        throw Exception('Método HTTP no soportado');
    }

    // Si el token expiró, intentar refrescar
    if (response.statusCode == 401) {
      bool refreshed = await refreshToken();
      if (refreshed) {
        return await _makeAuthenticatedRequest(method, endpoint, body: body);
      }
    }

    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  // --- AUTENTICACIÓN ---
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${baseUrl}auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200) {
      await _saveTokens(data['access'], data['refresh']);
      await _saveUserData(data);
    }

    return data;
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password1,
    required String password2,
  }) async {
    final response = await http.post(
      Uri.parse('${baseUrl}auth/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'password1': password1,
        'password2': password2,
      }),
    );
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  Future<bool> refreshToken() async {
    final refresh = _getRefreshToken();
    if (refresh == null) return false;

    try {
      final response = await http.post(
        Uri.parse('${baseUrl}token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refresh}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _prefs.setString('access_token', data['access']);
        return true;
      }
    } catch (e) {
      // Ignorar error
    }
    await _clearSession();
    return false;
  }

  Future<Map<String, dynamic>> getProfile() async {
    final data = await _makeAuthenticatedRequest('GET', 'auth/profile/');
    if (data.containsKey('id')) {
      await _saveUserData(data);
    }
    return data;
  }

  Future<Map<String, dynamic>> updateProfile({
    String? telefono,
    String? localidad,
    List<String>? gustos,
  }) async {
    return await _makeAuthenticatedRequest(
      'PATCH',
      'auth/profile/',
      body: {
        if (telefono != null) 'telefono': telefono,
        if (localidad != null) 'localidad': localidad,
        if (gustos != null) 'gustos': gustos,
      },
    );
  }

  Future<Map<String, dynamic>> addXp(int xpAmount) async {
    return await _makeAuthenticatedRequest(
      'POST',
      'auth/add-xp/',
      body: {'xp_amount': xpAmount},
    );
  }

  // --- CURSOS ---
  Future<List<dynamic>> getAvailableCourses() async {
    final data = await _makeAuthenticatedRequest('GET', 'courses/available/');
    return data is List ? data as List<dynamic> : [];
  }

  Future<Map<String, dynamic>> createCourse({
    required String title,
    required String description,
  }) async {
    return await _makeAuthenticatedRequest(
      'POST',
      'courses/create/',
      body: {
        'title': title,
        'description': description,
      },
    );
  }

  Future<Map<String, dynamic>> enrollCourse(int courseId) async {
    return await _makeAuthenticatedRequest(
      'POST',
      'courses/enroll/',
      body: {'course_id': courseId},
    );
  }

  // --- QUIZZES ---
  Future<List<dynamic>> getAvailableQuizzes() async {
    final data = await _makeAuthenticatedRequest('GET', 'quizzes/available/');
    return data is List ? data as List<dynamic> : [];
  }

  Future<Map<String, dynamic>> createQuiz({
    required int courseId,
    required String title,
    required String description,
  }) async {
    return await _makeAuthenticatedRequest(
      'POST',
      'quizzes/create/',
      body: {
        'course': courseId,
        'title': title,
        'description': description,
      },
    );
  }

  Future<Map<String, dynamic>> submitQuizAttempt({
    required int quizId,
    required int score,
  }) async {
    return await _makeAuthenticatedRequest(
      'POST',
      'quizzes/attempt/',
      body: {
        'quiz': quizId,
        'score': score,
      },
    );
  }

  // --- PROGRESO ---
  Future<List<dynamic>> getProgress() async {
    final data = await _makeAuthenticatedRequest('GET', 'progress/');
    return data is List ? data as List<dynamic> : [];
  }

  Future<Map<String, dynamic>> getCourseProgress(int courseId) async {
    return await _makeAuthenticatedRequest('GET', 'progress/$courseId/');
  }

  // --- UTILIDADES ---
  Future<void> logout() async {
    await _clearSession();
  }

  Future<bool> isLoggedIn() async {
    return _getAccessToken() != null;
  }

  bool isTeacher() {
    return userData['role'] == 'teacher';
  }

  int getUserLevel() {
    return userData['level'] ?? 1;
  }

  int getUserXp() {
    return userData['xp'] ?? 0;
  }
}

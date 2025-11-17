import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // --- CONFIGURACIÓN BASE ---
  static const String _host = '192.168.1.4';
  static const String baseUrl = 'http://$_host:8000/api/';

  // --- SINGLETON ---
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

  // --- HELPERS PRIVADOS ---
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
      'bio': data['bio'],
      'telefono': data['telefono'],
      'localidad': data['localidad'],
      'gustos': data['gustos'],
    };
    await _prefs.setString('userData', jsonEncode(userData));
  }

  Future<dynamic> _handleResponse(http.Response response) async {
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isEmpty) return {};
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else if (response.statusCode == 401) {
      await _clearSession();
      throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
    } else {
      final errorData = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(errorData['message'] ??
          errorData['detail'] ??
          errorData['error'] ??
          'Error en la petición (${response.statusCode})');
    }
  }

  Future<Map<String, dynamic>> _makeAuthenticatedRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final token = _getAccessToken();
    if (token == null) throw Exception('No autenticado');

    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    http.Response response;

    try {
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

      if (response.statusCode == 401) {
        bool refreshed = await refreshToken();
        if (refreshed) {
          return await _makeAuthenticatedRequest(method, endpoint, body: body);
        }
      }

      return await _handleResponse(response);
    } catch (e) {
      print('Error en _makeAuthenticatedRequest: $e');
      rethrow;
    }
  }

  // ========== USERS - AUTENTICACIÓN ==========
  
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = await _handleResponse(response);
      await _saveTokens(data['access'], data['refresh']);
      await _saveUserData(data);
      return data;
    } catch (e) {
      print('Error en login: $e');
      rethrow;
    }
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
    return await _handleResponse(response);
  }

  Future<bool> refreshToken() async {
    final refresh = _getRefreshToken();
    if (refresh == null) return false;

    try {
      final response = await http.post(
        Uri.parse('${baseUrl}auth/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refresh}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _prefs.setString('access_token', data['access']);
        return true;
      }
    } catch (e) {
      print('Error refreshing token: $e');
    }
    await _clearSession();
    return false;
  }

  Future<Map<String, dynamic>> getProfile() async {
    final data = await _makeAuthenticatedRequest('GET', 'auth/profile/');
    
    if (data.containsKey('usuario')) {
      final usuarioData = Map<String, dynamic>.from(data['usuario'] as Map);
      final profileData = <String, dynamic>{
        ...usuarioData,
        'telefono': data['telefono'],
        'localidad': data['localidad'],
        'gustos': data['gustos'],
        'avatar': data['avatar'],
        'fecha_nacimiento': data['fecha_nacimiento'],
      };
      await _saveUserData(profileData);
      return profileData;
    }
    
    if (data.containsKey('id')) {
      await _saveUserData(Map<String, dynamic>.from(data));
    }
    return Map<String, dynamic>.from(data);
  }

  Future<Map<String, dynamic>> updateProfile({
    String? telefono,
    String? localidad,
    List<String>? gustos,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (telefono != null) body['telefono'] = telefono;
      if (localidad != null) body['localidad'] = localidad;
      if (gustos != null) body['gustos'] = gustos;

      final data = await _makeAuthenticatedRequest('PATCH', 'auth/profile/', body: body);

      if (data.containsKey('usuario')) {
        final usuarioData = Map<String, dynamic>.from(data['usuario'] as Map);
        final profileData = <String, dynamic>{
          ...usuarioData,
          'telefono': data['telefono'],
          'localidad': data['localidad'],
          'gustos': data['gustos'],
        };
        await _saveUserData(profileData);
        return profileData;
      }
      
      if (data.containsKey('id')) {
        await _saveUserData(Map<String, dynamic>.from(data));
      }
      return Map<String, dynamic>.from(data);
    } catch (e) {
      print('Error en updateProfile: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _makeAuthenticatedRequest('POST', 'auth/logout/');
    } catch (e) {
      print('Error during logout: $e');
    } finally {
      await _clearSession();
    }
  }

  Future<bool> isLoggedIn() async {
    final token = _getAccessToken();
    if (token == null) return false;

    try {
      await getProfile();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> addXp(int xpAmount) async {
    return await _makeAuthenticatedRequest(
      'POST',
      'auth/add-xp/',
      body: {'xp_amount': xpAmount},
    );
  }

  // ========== USERS - GESTIÓN (Admin/Moderator) ==========
  
  Future<List<dynamic>> getAllUsers() async {
    try {
      final data = await _makeAuthenticatedRequest('GET', 'auth/users/');
      return _extractList(data, ['results', 'users', 'data']);
    } catch (e) {
      print('❌ Error getting users: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> updateUserRole(int userId, String newRole) async {
    return await _makeAuthenticatedRequest(
      'PATCH',
      'auth/users/$userId/role/',
      body: {'role': newRole},
    );
  }

  Future<Map<String, dynamic>> deleteUser(int userId) async {
    return await _makeAuthenticatedRequest('DELETE', 'auth/users/$userId/');
  }

  // ========== COURSES ==========
  
  Future<List<dynamic>> getAvailableCourses() async {
    try {
      final data = await _makeAuthenticatedRequest('GET', 'courses/available/');
      return _extractList(data, ['results', 'courses', 'data']);
    } catch (e) {
      print('❌ Error getting courses: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getCourseDetail(int courseId) async {
    return await _makeAuthenticatedRequest('GET', 'courses/$courseId/');
  }

  Future<List<dynamic>> getCourseLessons(int courseId) async {
    try {
      final data = await _makeAuthenticatedRequest('GET', 'courses/$courseId/lessons/');
      return _extractList(data, ['results', 'lessons', 'data']);
    } catch (e) {
      print('❌ Error getting course lessons: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> enrollCourse(int courseId) async {
    return await _makeAuthenticatedRequest(
      'POST',
      'courses/enroll/',
      body: {'course_id': courseId},
    );
  }

  Future<List<dynamic>> getMyEnrollments() async {
    try {
      final data = await _makeAuthenticatedRequest('GET', 'courses/my-enrollments/');
      return _extractList(data, ['results', 'enrollments', 'data']);
    } catch (e) {
      print('❌ Error getting enrollments: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> createCourse({
    required String title,
    required String description,
    String? difficulty,
    int? levelRequired,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'description': description,
    };
    if (difficulty != null) body['difficulty'] = difficulty;
    if (levelRequired != null) body['level_required'] = levelRequired;
    
    return await _makeAuthenticatedRequest('POST', 'courses/create/', body: body);
  }

  // ========== QUIZZES ==========
  
  Future<List<dynamic>> getAvailableQuizzes() async {
    try {
      final data = await _makeAuthenticatedRequest('GET', 'quizzes/available/');
      return _extractList(data, ['results', 'quizzes', 'data']);
    } catch (e) {
      print('❌ Error getting quizzes: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getQuizDetail(int quizId) async {
    return await _makeAuthenticatedRequest('GET', 'quizzes/$quizId/');
  }

  Future<List<dynamic>> getCourseQuizzes(int courseId) async {
    try {
      final data = await _makeAuthenticatedRequest('GET', 'quizzes/course/$courseId/');
      return _extractList(data, ['results', 'quizzes', 'data']);
    } catch (e) {
      print('❌ Error getting course quizzes: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> submitQuiz({
    required int quizId,
    required Map<String, String> answers,
    required int timeTaken,
  }) async {
    return await _makeAuthenticatedRequest(
      'POST',
      'quizzes/submit/',
      body: {
        'quiz_id': quizId,
        'answers': answers,
        'time_taken': timeTaken,
      },
    );
  }

  Future<List<dynamic>> getMyQuizAttempts() async {
    try {
      final data = await _makeAuthenticatedRequest('GET', 'quizzes/my-attempts/');
      return _extractList(data, ['results', 'attempts', 'data']);
    } catch (e) {
      print('❌ Error getting quiz attempts: $e');
      return [];
    }
  }

  Future<List<dynamic>> getQuizAttempts(int quizId) async {
    try {
      final data = await _makeAuthenticatedRequest('GET', 'quizzes/$quizId/attempts/');
      return _extractList(data, ['results', 'attempts', 'data']);
    } catch (e) {
      print('❌ Error getting quiz attempts: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> createQuiz({
    required int courseId,
    required String title,
    required String description,
    String difficulty = 'medium',
    double passingScore = 70.0,
    int xpReward = 50,
    int timeLimit = 10,
    int maxAttempts = 3,
    List<Map<String, dynamic>>? questions,
  }) async {
    final body = {
      'course': courseId,
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'passing_score': passingScore,
      'xp_reward': xpReward,
      'time_limit': timeLimit,
      'max_attempts': maxAttempts,
    };
    
    if (questions != null && questions.isNotEmpty) {
      body['questions'] = questions;
    }
    
    return await _makeAuthenticatedRequest('POST', 'quizzes/create/', body: body);
  }

  Future<Map<String, dynamic>> updateQuiz({
    required int quizId,
    String? title,
    String? description,
    String? difficulty,
    double? passingScore,
    int? xpReward,
    int? timeLimit,
    int? maxAttempts,
  }) async {
    final Map<String, dynamic> body = {};
    
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (difficulty != null) body['difficulty'] = difficulty;
    if (passingScore != null) body['passing_score'] = passingScore;
    if (xpReward != null) body['xp_reward'] = xpReward;
    if (timeLimit != null) body['time_limit'] = timeLimit;
    if (maxAttempts != null) body['max_attempts'] = maxAttempts;
    
    return await _makeAuthenticatedRequest('PATCH', 'quizzes/$quizId/', body: body);
  }

  // ========== PROGRESS ==========
  
  Future<List<dynamic>> getProgress() async {
    try {
      final data = await _makeAuthenticatedRequest('GET', 'progress/');
      return _extractList(data, ['results', 'progress', 'data']);
    } catch (e) {
      print('❌ Error getting progress: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getCourseProgress(int courseId) async {
    return await _makeAuthenticatedRequest('GET', 'progress/course/$courseId/');
  }

  Future<Map<String, dynamic>> updateProgress({
    required int courseId,
    int? completedLessons,
    int? completedQuizzes,
  }) async {
    final body = {'course_id': courseId};
    if (completedLessons != null) body['completed_lessons'] = completedLessons;
    if (completedQuizzes != null) body['completed_quizzes'] = completedQuizzes;
    
    return await _makeAuthenticatedRequest('POST', 'progress/update/', body: body);
  }

  Future<List<dynamic>> getLeaderboard() async {
    try {
      final data = await _makeAuthenticatedRequest('GET', 'progress/leaderboard/');
      return _extractList(data, ['results', 'leaderboard', 'data']);
    } catch (e) {
      print('❌ Error getting leaderboard: $e');
      return [];
    }
  }

  // ========== STATS ==========
  
  Future<Map<String, dynamic>> getOverviewStats() async {
    return await _makeAuthenticatedRequest('GET', 'stats/overview/');
  }

  Future<Map<String, dynamic>> getUserStatistics() async {
    return await _makeAuthenticatedRequest('GET', 'stats/user-statistics/');
  }

  Future<Map<String, dynamic>> getTimeSeriesStats() async {
    return await _makeAuthenticatedRequest('GET', 'stats/time-series/');
  }

  Future<Map<String, dynamic>> getXpHistory() async {
    return await _makeAuthenticatedRequest('GET', 'stats/xp-history/');
  }

  Future<Map<String, dynamic>> getAdminStatistics() async {
    return await _makeAuthenticatedRequest('GET', 'stats/admin/');
  }

  Future<Map<String, dynamic>> getQuizStatistics() async {
    return await _makeAuthenticatedRequest('GET', 'quizzes/statistics/');
  }

  // ========== NOTIFICATIONS ==========
  
  Future<List<dynamic>> getNotifications() async {
    try {
      final data = await _makeAuthenticatedRequest('GET', 'notifications/');
      return _extractList(data, ['results', 'notifications', 'data']);
    } catch (e) {
      print('❌ Error getting notifications: $e');
      return [];
    }
  }

  Future<List<dynamic>> getRecentNotifications() async {
    try {
      final data = await _makeAuthenticatedRequest('GET', 'notifications/recent/');
      return _extractList(data, ['results', 'notifications', 'data']);
    } catch (e) {
      print('❌ Error getting recent notifications: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getUnreadCount() async {
    return await _makeAuthenticatedRequest('GET', 'notifications/unread-count/');
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    await _makeAuthenticatedRequest(
      'POST',
      'notifications/mark-read/',
      body: {'notification_id': notificationId},
    );
  }

  Future<void> markAllNotificationsAsRead() async {
    await _makeAuthenticatedRequest('POST', 'notifications/mark-all-read/');
  }

  // ========== MEDIA CONTENT ==========
  
  Future<List<dynamic>> getMediaContent() async {
    try {
      final data = await _makeAuthenticatedRequest('GET', 'media-content/');
      return _extractList(data, ['results', 'media', 'data']);
    } catch (e) {
      print('❌ Error getting media content: $e');
      return [];
    }
  }

  // ========== UTILIDADES ==========
  
  bool isAdmin() => userData['role'] == 'admin';
  bool isModerator() => userData['role'] == 'moderator';
  bool isUser() => userData['role'] == 'user';
  bool canManage() => isAdmin() || isModerator();
  
  int getUserLevel() => userData['level'] ?? 1;
  int getUserXp() => userData['xp'] ?? 0;

  // Helper para extraer listas de diferentes estructuras de respuesta
  List<dynamic> _extractList(dynamic data, List<String> possibleKeys) {
    if (data is List) {
      return data;
    } else if (data is Map) {
      for (final key in possibleKeys) {
        if (data.containsKey(key) && data[key] is List) {
          return data[key];
        }
      }
    }
    return [];
  }
}
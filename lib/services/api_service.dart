import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // --- IP Y URL BASE ---
  static const String _host = '192.168.1.4'; // Tu IP
  static const String baseUrl = 'http://$_host:8000/api/';

  // --- SINGLETON SETUP ---
  static final ApiService _instance = ApiService._internal();
  factory ApiService() {
    return _instance;
  }
  ApiService._internal();
  // ---------------------

  late SharedPreferences _prefs;
  Map<String, dynamic> userData =
      {}; // Caché en memoria para los datos del usuario

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    // Al iniciar, cargamos los datos del usuario si existen
    final userJson = _prefs.getString('userData');
    if (userJson != null) {
      userData = jsonDecode(userJson);
    }
  }

  // --- HELPERS INTERNOS ---
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
    // Guardamos los datos del usuario en la caché y en SharedPreferences
    userData = {
      'id': data['id'],
      'email': data['email'],
      'first_name': data['first_name'],
      'last_name': data['last_name'],
      'role': data['role'],
      'level': data['level'],
    };
    await _prefs.setString('userData', jsonEncode(userData));
  }

  // --- MÉTODOS PÚBLICOS ---

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${baseUrl}auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password1': password, // El body que tu backend espera
        'password2': password,
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
      // No hacer nada, simplemente fallar
    }
    await _clearSession();
    return false;
  }

  Future<Map<String, dynamic>> getProfile() async {
    final token = _getAccessToken();
    if (token == null) return {'detail': 'No autenticado'};

    final response = await http.get(
      Uri.parse('${baseUrl}auth/profile/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 401) {
      bool refreshed = await refreshToken();
      if (refreshed) return await getProfile();
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) {
      await _saveUserData(data);
    }
    return data;
  }

  Future<void> logout() async {
    await _clearSession();
  }

  Future<bool> isLoggedIn() async {
    return _getAccessToken() != null;
  }
}

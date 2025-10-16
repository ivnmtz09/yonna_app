// lib/services/auth_service.dart
import 'package:google_sign_in/google_sign_in.dart';
import 'api_service.dart';
import '../utils/secure_storage.dart';
import 'package:dio/dio.dart';

class AuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Para Android nativo se recomienda configurar un OAuth client type Android
    // Si no lo configuras aún, google_sign_in puede fallar en Android. Lo dejaremos aquí.
    clientId: null,
    scopes: ['email', 'profile'],
  );

  // Inicializar interceptors (llamar en main)
  static void init() => ApiService.initInterceptors();

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final res = await ApiService.post("auth/login/", {
        "email": email,
        "password1": password,
        "password2": password,
      });
      final data = res.data;
      // backend devuelve access + refresh
      await SecureStorage.saveToken(data['access']);
      await SecureStorage.saveRefresh(data['refresh']);
      return {"ok": true, "data": data};
    } on DioException catch (e) {
      return {"ok": false, "error": e.response?.data ?? e.message};
    }
  }

  static Future<Map<String, dynamic>> register(
    Map<String, dynamic> userData,
  ) async {
    try {
      final res = await ApiService.post("auth/register/", userData);
      return {"ok": true, "data": res.data};
    } on DioException catch (e) {
      return {"ok": false, "error": e.response?.data ?? e.message};
    }
  }

  static Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return {"ok": false, "error": "cancelled"};
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) return {"ok": false, "error": "no idToken"};
      final res = await ApiService.post("auth/google/", {"id_token": idToken});
      final data = res.data;
      await SecureStorage.saveToken(data['access']);
      await SecureStorage.saveRefresh(data['refresh']);
      return {"ok": true, "data": data};
    } catch (e) {
      return {"ok": false, "error": e.toString()};
    }
  }

  static Future<void> logout() async {
    await SecureStorage.clear();
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }

  static Future<bool> isLoggedIn() async {
    final t = await SecureStorage.getToken();
    return t != null;
  }
}

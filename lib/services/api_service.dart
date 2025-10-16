// lib/services/api_service.dart
import 'package:dio/dio.dart';
import '../utils/secure_storage.dart';

class ApiService {
  // Cambia esta IP por la de tu máquina: 192.168.1.4 (la que mostraste)
  // Para emulador Android (AVD) usar 10.0.2.2
  static String get baseUrl {
    // Development defaults:
    return "http://192.168.1.4:8000/api/";
  }

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {"Content-Type": "application/json"},
    ),
  );

  // Interceptor para añadir Authorization si existe
  static void initInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  static Future<Response> post(String path, Map<String, dynamic> data) async {
    return await _dio.post(path, data: data);
  }

  static Future<Response> get(String path) async {
    return await _dio.get(path);
  }
}

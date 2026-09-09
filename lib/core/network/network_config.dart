import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Manejador centralizado de la configuración de red y conectividad con el backend Django.
class NetworkConfig {
  static final NetworkConfig _instance = NetworkConfig._internal();
  factory NetworkConfig() => _instance;
  NetworkConfig._internal();

  static const String keyHost = 'backend_host';
  static const String keyPort = 'backend_port';

  // Presets comunes
  static const String presetUsbAdb = '127.0.0.1';
  static const String presetEmulator = '10.0.2.2';
  static const int defaultPort = 8000;

  late SharedPreferences _prefs;
  String _host = presetUsbAdb;
  int _port = defaultPort;

  String get host => _host;
  int get port => _port;
  String get serverUrl => 'http://$_host:$_port';
  String get baseUrl => '$serverUrl/api/';

  Future<void> init(SharedPreferences prefs) async {
    _prefs = prefs;
    _host = _prefs.getString(keyHost) ?? presetUsbAdb;
    _port = _prefs.getInt(keyPort) ?? defaultPort;
    debugPrint('🌐 NetworkConfig inicializado: $baseUrl');
  }

  Future<void> setHost(String newHost, [int? newPort]) async {
    _host = newHost.trim();
    if (newPort != null) _port = newPort;
    await _prefs.setString(keyHost, _host);
    await _prefs.setInt(keyPort, _port);
    debugPrint('🔄 NetworkConfig actualizado: $baseUrl');
  }

  /// Verifica la disponibilidad del servidor Django con un timeout corto.
  Future<NetworkHealthResult> checkHealth({Duration timeout = const Duration(seconds: 4)}) async {
    final testUri = Uri.parse('$baseUrl');
    try {
      final response = await http.get(testUri).timeout(timeout);
      // Si el servidor responde (incluso 401 o 404), significa que el host y puerto están activos
      return NetworkHealthResult(
        isReachable: true,
        statusCode: response.statusCode,
        message: 'Conectado exitosamente con Yonna Akademia ($serverUrl)',
      );
    } on SocketException catch (e) {
      debugPrint('❌ Health check SocketException: ${e.message} (errno: ${e.osError?.errorCode})');
      final isRefused = e.osError?.errorCode == 111 || e.message.contains('refused');
      final explanation = isRefused
          ? 'Conexión rechazada en $serverUrl. Verifica que el backend Django esté corriendo (python manage.py runserver) y que la regla ADB esté activa (adb reverse tcp:8000 tcp:8000).'
          : 'No se pudo alcanzar la dirección $serverUrl. Revisa si el dispositivo está en la misma red o si la IP es correcta.';
      return NetworkHealthResult(
        isReachable: false,
        message: explanation,
        isConnectionRefused: isRefused,
      );
    } on TimeoutException {
      return NetworkHealthResult(
        isReachable: false,
        message: 'Tiempo de espera agotado al conectar con $serverUrl.',
      );
    } catch (e) {
      return NetworkHealthResult(
        isReachable: false,
        message: 'Error de red inesperado: $e',
      );
    }
  }

  /// Transforma excepciones crudas en mensajes claros y accionables para la UI.
  static String formatErrorMessage(dynamic error) {
    if (error is SocketException) {
      if (error.osError?.errorCode == 111 || error.message.contains('refused')) {
        return 'No se pudo conectar al servidor Django. Asegúrate de que el backend esté corriendo y de ejecutar "adb reverse tcp:8000 tcp:8000".';
      }
      return 'Error de red: No se pudo contactar al servidor.';
    }
    if (error is TimeoutException) {
      return 'El servidor tardó demasiado en responder. Intenta de nuevo.';
    }
    if (error is http.ClientException) {
      return 'Fallo en la comunicación con el servidor. Revisa tu conexión.';
    }
    final str = error.toString();
    if (str.startsWith('Exception: ')) {
      return str.substring(11);
    }
    return str;
  }
}

class NetworkHealthResult {
  final bool isReachable;
  final int? statusCode;
  final String message;
  final bool isConnectionRefused;

  const NetworkHealthResult({
    required this.isReachable,
    this.statusCode,
    required this.message,
    this.isConnectionRefused = false,
  });
}

import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yonna_app/core/network/network_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NetworkConfig tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Default values and URL getters', () async {
      final prefs = await SharedPreferences.getInstance();
      final config = NetworkConfig();
      await config.init(prefs);

      expect(config.host, '127.0.0.1');
      expect(config.port, 8000);
      expect(config.serverUrl, 'http://127.0.0.1:8000');
      expect(config.baseUrl, 'http://127.0.0.1:8000/api/');
    });

    test('Update host and port persists to SharedPreferences', () async {
      final prefs = await SharedPreferences.getInstance();
      final config = NetworkConfig();
      await config.init(prefs);

      await config.setHost('192.168.1.50', 8080);

      expect(config.host, '192.168.1.50');
      expect(config.port, 8080);
      expect(config.serverUrl, 'http://192.168.1.50:8080');
      expect(config.baseUrl, 'http://192.168.1.50:8080/api/');

      // Verify persistence in SharedPreferences
      expect(prefs.getString(NetworkConfig.keyHost), '192.168.1.50');
      expect(prefs.getInt(NetworkConfig.keyPort), 8080);
    });

    test('formatErrorMessage recognizes SocketException errno 111 (connection refused)', () {
      const socketError = SocketException('Connection refused', osError: OSError('Connection refused', 111));
      final message = NetworkConfig.formatErrorMessage(socketError);

      expect(message, contains('No se pudo conectar al servidor Django'));
      expect(message, contains('adb reverse'));
    });

    test('formatErrorMessage recognizes TimeoutException', () {
      final timeoutError = TimeoutException('Timeout occurred');
      final message = NetworkConfig.formatErrorMessage(timeoutError);

      expect(message, contains('tardó demasiado en responder'));
    });
  });
}

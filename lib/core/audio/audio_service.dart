import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../../services/api_service.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;

  final AudioPlayer _player = AudioPlayer();
  String? _currentUrl;

  AudioService._internal() {
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _currentUrl = null;
      }
    });
  }

  AudioPlayer get player => _player;
  String? get currentUrl => _currentUrl;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  Future<void> playUrl(String url) async {
    try {
      final effectiveUrl = url.startsWith('/') ? '${ApiService.serverUrl}$url' : url;
      if (_currentUrl == effectiveUrl && _player.playing) {
        await _player.pause();
        return;
      }

      _currentUrl = effectiveUrl;
      await _player.stop();
      await _player.setUrl(effectiveUrl);
      await _player.play();
    } catch (e) {
      debugPrint('❌ Error playing audio from $url: $e');
      _currentUrl = null;
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
      _currentUrl = null;
    } catch (e) {
      debugPrint('❌ Error stopping audio: $e');
    }
  }

  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e) {
      debugPrint('❌ Error pausing audio: $e');
    }
  }

  void dispose() {
    _player.dispose();
  }
}

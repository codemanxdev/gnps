import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  TtsService._internal();
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  Future<void> init({
    String? language,
    double rate = 0.5,
    double pitch = 1.0,
  }) async {
    if (_initialized) return;
    try {
      debugPrint(
        'TTS: initializing (lang=${language ?? 'en-US'}, rate=$rate, pitch=$pitch)',
      );
      await _tts.setLanguage(language ?? 'en-US');
      await _tts.setSpeechRate(rate);
      await _tts.setPitch(pitch);
      _initialized = true;
      debugPrint('TTS: initialized');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('TTS init error: $e');
      }
    }
  }

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    await init();
    await _tts.stop();
    await _tts.speak(text);
    try {
      debugPrint('TTS: speak() called — text length=${text.length}');
      await _tts.stop();
      await _tts.speak(text);
      debugPrint('TTS: speak() dispatched');
    } catch (e) {
      debugPrint('TTS speak error: $e');
      rethrow;
    }
  }

  Future<void> stop() => _tts.stop();
}

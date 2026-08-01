// lib/services/tts_service.dart

import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _flutterTts.setLanguage("en-US"); // ✅ English
      await _flutterTts.setSpeechRate(0.5); // Medium speed
      await _flutterTts.setVolume(1.0); // Max volume
      await _flutterTts.setPitch(1.2); // Normal pitch

      _isInitialized = true;
      print('✅ TTS initialized successfully');
    } catch (e) {
      print('❌ TTS initialization failed: $e');
    }
  }

  Future<void> speak(String text) async {
    try {
      await initialize();
      await _flutterTts.speak(text);
      print('🔊 Speaking: $text');
    } catch (e) {
      print('❌ TTS speak failed: $e');
    }
  }

  Future<void> speakMedicationReminder(String medicationName) async {
    await speak("Time to take $medicationName");
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      print('❌ TTS stop failed: $e');
    }
  }
}

import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';
import 'app_settings.dart';

class SoundManager {
  static final SoundManager instance = SoundManager._init();
  final FlutterTts _flutterTts = FlutterTts();

  SoundManager._init() {
    _initTTS();
  }

  void _initTTS() async {
    await _flutterTts.setEngine("com.google.android.tts");
    await _flutterTts.awaitSpeakCompletion(true);
    await _flutterTts.setLanguage("ja-JP");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }
  Future<void> speakJapanese(String text, {bool isSlow = false}) async {
    if (text.isEmpty) return;
    try {
      await _flutterTts.stop();

      double speechRate = isSlow ? 0.1 : 0.5;
      await _flutterTts.setSpeechRate(speechRate);

      await _flutterTts.speak(text);
    } catch (e) {
      print("Lỗi TTS: $e");
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      print("Lỗi khi dừng TTS: $e");
    }
  }

  Future<void> vibrate(String type) async {
    if (AppSettings.sfxRatio == 0) return;
    if (await Vibration.hasVibrator() == true) {
      switch (type) {
        case 'light':
          Vibration.vibrate(duration: 50, amplitude: 64);
          break;
        case 'heavy':
          Vibration.vibrate(duration: 500, amplitude: 255);
          break;
        case 'error':
          Vibration.vibrate(pattern: [0, 200, 100, 200], intensities: [0, 255, 0, 255]);
          break;
      }
    } else {
      switch (type) {
        case 'light': Vibration.vibrate(duration: 50); break;
        case 'heavy': Vibration.vibrate(duration: 500); break;
        case 'error': Vibration.vibrate(pattern: [0, 200, 100, 200]); break;
      }
    }
  }
}
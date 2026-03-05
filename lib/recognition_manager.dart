import 'package:flutter/material.dart';
// Import thư viện ML Kit với tên gọi tắt là 'model' để tránh trùng lặp tên class Ink
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart' as model;

class RecognitionManager {
  // Singleton: Chỉ tạo 1 instance duy nhất
  static final RecognitionManager instance = RecognitionManager._init();

  // Ngôn ngữ nhận diện: Tiếng Nhật (ja)
  final String _language = 'ja';
  late final model.DigitalInkRecognizer _recognizer;
  final _modelManager = model.DigitalInkRecognizerModelManager();

  RecognitionManager._init() {
    _recognizer = model.DigitalInkRecognizer(languageCode: _language);
  }

  // 1. HÀM TẢI MODEL (Chạy lúc mới vào App)
  Future<bool> checkAndDownloadModel() async {
    print("AI: Đang kiểm tra bộ não tiếng Nhật...");
    try {
      final isDownloaded = await _modelManager.isModelDownloaded(_language);

      if (!isDownloaded) {
        print("AI: Chưa có não, đang tải về...");
        final success = await _modelManager.downloadModel(_language);
        print("AI: Tải model kết quả: $success");
        return success;
      } else {
        print("AI: Đã có sẵn não tiếng Nhật!");
        return true;
      }
    } catch (e) {
      print("Lỗi tải model: $e");
      return false;
    }
  }

  // 2. HÀM CHẤM ĐIỂM (Nhận diện nét vẽ)
  Future<List<String>> recognize(List<List<Offset>> strokes) async {
    if (strokes.isEmpty) return [];

    try {
      // Chuyển đổi dữ liệu nét vẽ sang định dạng Google Ink mới
      final ink = _convertStrokesToInk(strokes);

      // Yêu cầu AI nhận diện
      final candidates = await _recognizer.recognize(ink);

      // Trả về danh sách chữ cái (Vd: ['火', '人'])
      List<String> results = candidates.map((c) => c.text).toList();
      print("AI Nhìn thấy: $results");
      return results;
    } catch (e) {
      print("Lỗi nhận diện: $e");
      return [];
    }
  }

  // --- HÀM CHUYỂN ĐỔI QUAN TRỌNG (Cập nhật API Mới) ---
  model.Ink _convertStrokesToInk(List<List<Offset>> strokes) {
    final ink = model.Ink();

    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;

      final inkStroke = model.Stroke();

      int t = 0;
      for (final point in stroke) {
        t += 10;

        inkStroke.points.add(
          model.StrokePoint(
            x: point.dx,
            y: point.dy,
            t: t,
          ),
        );
      }

      ink.strokes.add(inkStroke);
    }

    return ink;
  }

  void close() {
    _recognizer.close();
  }
}
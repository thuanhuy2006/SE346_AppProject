import 'package:shared_preferences/shared_preferences.dart';

class UserProgress {
  static final UserProgress _instance = UserProgress._internal();
  factory UserProgress() => _instance;
  UserProgress._internal();

  static const String _keyExp = 'user_exp';
  static const String _keyCompletedLessons = 'completed_lessons';

  // 1. Lấy điểm EXP
  Future<int> getExp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyExp) ?? 0;
  }

  // 2. Cộng điểm EXP
  Future<void> addExp(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt(_keyExp) ?? 0;
    await prefs.setInt(_keyExp, current + amount);
  }

  // 3. Kiểm tra bài học đã xong chưa (trả về status: 0=khoá, 1=mở, 2=xong)
  Future<int> getLessonStatus(String lessonId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> completed = prefs.getStringList(_keyCompletedLessons) ?? [];

    if (completed.contains(lessonId)) return 2;
    return 0;
  }

  // 4. Lưu bài học đã xong
  Future<void> markLessonCompleted(String lessonId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> completed = prefs.getStringList(_keyCompletedLessons) ?? [];
    if (!completed.contains(lessonId)) {
      completed.add(lessonId);
      await prefs.setStringList(_keyCompletedLessons, completed);
    }
  }

  // 5. Lấy danh sách tất cả bài đã xong (Để check mở khóa)
  Future<List<String>> getCompletedLessons() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyCompletedLessons) ?? [];
  }

  Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyExp);
    await prefs.remove(_keyCompletedLessons);
  }
}
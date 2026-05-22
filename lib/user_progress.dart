import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProgress {
  static final UserProgress _instance = UserProgress._internal();
  factory UserProgress() => _instance;
  UserProgress._internal();

  static const String _keyExp = 'user_exp';
  static const String _keyCompletedLessons = 'completed_lessons';

  // Helper sinh key theo uid của user hiện tại
  String _getExpKey() {
    final user = FirebaseAuth.instance.currentUser;
    return user != null ? '${_keyExp}_${user.uid}' : '${_keyExp}_guest';
  }

  String _getCompletedLessonsKey() {
    final user = FirebaseAuth.instance.currentUser;
    return user != null ? '${_keyCompletedLessons}_${user.uid}' : '${_keyCompletedLessons}_guest';
  }

  // 1. Lấy điểm EXP từ local storage
  Future<int> getExp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_getExpKey()) ?? 0;
  }

  // 2. Cộng điểm EXP và đồng bộ lên Firebase
  Future<void> addExp(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final String expKey = _getExpKey();
    int current = prefs.getInt(expKey) ?? 0;
    int newExp = current + amount;
    await prefs.setInt(expKey, newExp);

    // Đồng bộ lên Firestore
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        String displayName = user.displayName ?? '';
        if (displayName.isEmpty && user.email != null) {
          displayName = user.email!.split('@').first;
        }

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'exp': newExp,
          'name': displayName,
          'email': user.email,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        print("Lỗi đồng bộ EXP lên Firebase: $e");
      }
    }
  }

  // 3. Kiểm tra bài học đã xong chưa (trả về status: 0=khoá, 1=mở, 2=xong)
  Future<int> getLessonStatus(String lessonId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> completed = prefs.getStringList(_getCompletedLessonsKey()) ?? [];

    if (completed.contains(lessonId)) return 2;
    return 0;
  }

  // 4. Lưu bài học đã xong và đồng bộ lên Firebase
  Future<void> markLessonCompleted(String lessonId) async {
    final prefs = await SharedPreferences.getInstance();
    final String lessonsKey = _getCompletedLessonsKey();
    List<String> completed = prefs.getStringList(lessonsKey) ?? [];
    if (!completed.contains(lessonId)) {
      completed.add(lessonId);
      await prefs.setStringList(lessonsKey, completed);

      // Đồng bộ lên Firestore
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'completedLessons': completed,
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (e) {
          print("Lỗi đồng bộ completedLessons lên Firebase: $e");
        }
      }
    }
  }

  // 5. Lấy danh sách tất cả bài đã xong (Để check mở khóa)
  Future<List<String>> getCompletedLessons() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_getCompletedLessonsKey()) ?? [];
  }

  // 6. Đồng bộ tiến trình của user hiện tại từ Firestore về SharedPreferences local
  Future<void> syncFromFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final prefs = await SharedPreferences.getInstance();
      final String expKey = '${_keyExp}_${user.uid}';
      final String lessonsKey = '${_keyCompletedLessons}_${user.uid}';

      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          // Sync EXP
          final int remoteExp = data['exp'] ?? 0;
          await prefs.setInt(expKey, remoteExp);

          // Sync Completed Lessons
          final List<dynamic>? remoteLessons = data['completedLessons'];
          if (remoteLessons != null) {
            final List<String> lessons = remoteLessons.map((e) => e.toString()).toList();
            await prefs.setStringList(lessonsKey, lessons);
          } else {
            await prefs.remove(lessonsKey);
          }
          print("Đồng bộ thành công tiến độ từ Firebase: EXP=$remoteExp");
        }
      } else {
        // Nếu document không tồn tại trên Firestore (User mới), khởi tạo giá trị 0
        await prefs.setInt(expKey, 0);
        await prefs.remove(lessonsKey);

        String displayName = user.displayName ?? '';
        if (displayName.isEmpty && user.email != null) {
          displayName = user.email!.split('@').first;
        }

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'exp': 0,
          'name': displayName,
          'email': user.email,
          'completedLessons': <String>[],
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        print("Đã khởi tạo tiến trình mặc định cho user mới trên Firestore.");
      }
    } catch (e) {
      print("Lỗi khi chạy syncFromFirebase: $e");
    }
  }

  Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;

    // Reset dữ liệu guest
    await prefs.remove('${_keyExp}_guest');
    await prefs.remove('${_keyCompletedLessons}_guest');

    // Reset dữ liệu user hiện tại nếu có
    if (user != null) {
      final String expKey = '${_keyExp}_${user.uid}';
      final String lessonsKey = '${_keyCompletedLessons}_${user.uid}';
      await prefs.remove(expKey);
      await prefs.remove(lessonsKey);

      // Reset trên Firestore
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'exp': 0,
          'completedLessons': <String>[],
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        print("Lỗi reset progress trên Firestore: $e");
      }
    }
  }

  // 7. Cập nhật tên hiển thị của người dùng
  Future<void> updateDisplayName(String newName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Cập nhật trên Firebase Auth
      await user.updateDisplayName(newName);
      await user.reload(); // Làm mới thông tin user cache local
      
      // Đồng bộ tên lên Firestore
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': newName,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        print("Đã cập nhật tên hiển thị lên Firestore: $newName");
      } catch (e) {
        print("Lỗi đồng bộ tên lên Firestore: $e");
      }
    }
  }
}
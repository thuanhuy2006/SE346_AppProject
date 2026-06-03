import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_progress.dart';
import 'sound_manager.dart';

// Tái định nghĩa các hằng số màu sắc cho đồng bộ
const Color kPrimaryBlue = Color(0xFF3366FF);
const Color kAccentCyan = Color(0xFF56CCF2);
const Color kSoftBackground = Color(0xFFF4F8FF);
const Color kSurfaceWhite = Color(0xFFFFFFFF);

class SurveyScreen extends StatefulWidget {
  final String uid;
  const SurveyScreen({super.key, required this.uid});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  String _selectedLevel = 'beginner'; // 'beginner', 'elementary', 'intermediate', 'proficient'
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _levels = [
    {
      'key': 'beginner',
      'title': 'Mới bắt đầu',
      'subtitle': 'Học từ bảng chữ cái Hiragana & Katakana (N5)',
      'icon': Icons.sort_by_alpha,
      'color': Color(0xFF4A89F3),
      'bgColor': Color(0xFFEDF4FE),
      'unlockedText': 'Bắt đầu từ cấp độ: N5',
    },
    {
      'key': 'elementary',
      'title': 'Sơ cấp',
      'subtitle': 'Bỏ qua N5, bắt đầu học từ cấp độ N4',
      'icon': Icons.waving_hand,
      'color': Color(0xFFFFA000),
      'bgColor': Color(0xFFFFF8E1),
      'unlockedText': 'Mở khóa toàn bộ cấp độ N5\n(Bắt đầu từ N4)',
    },
    {
      'key': 'intermediate',
      'title': 'Trung cấp',
      'subtitle': 'Bỏ qua N5 & N4, bắt đầu học từ cấp độ N3',
      'icon': Icons.assignment,
      'color': Color(0xFFE91E63),
      'bgColor': Color(0xFFFCE4EC),
      'unlockedText': 'Mở khóa toàn bộ cấp độ N5 và N4\n(Bắt đầu từ N3)',
    },
    {
      'key': 'proficient',
      'title': 'Thành thạo',
      'subtitle': 'Bỏ qua N5, N4, N3, bắt đầu học từ cấp độ N2',
      'icon': Icons.auto_awesome,
      'color': Color(0xFF4CAF50),
      'bgColor': Color(0xFFE8F5E9),
      'unlockedText': 'Mở khóa toàn bộ N5, N4 và N3\n(Bắt đầu từ N2)',
    },
  ];

  Future<void> _submitSurvey() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      List<String> completedLessons = [];

      // Định nghĩa các bài học để tự động mở khóa theo lựa chọn
      final List<String> alphabetKeys = [
        'hang_a', 'hang_ka', 'hang_sa', 'hang_ta', 'hang_na',
        'hang_ha', 'hang_ma', 'hang_ya', 'hang_ra', 'hang_wa', 'hang_all'
      ];

      List<String> getBasicKeys(int chapter) {
        return [
          'cb${chapter}_lythuyet',
          'cb${chapter}_luyentap1',
          'cb${chapter}_luyentap2',
          'cb${chapter}_luyentap3',
          'cb${chapter}_luyennoi',
          'cb${chapter}_luyenviet',
          'cb${chapter}_ontap',
        ];
      }

      List<String> getNXKeys(String levelPrefix, int chapter) {
        return [
          '${levelPrefix}_bai${chapter}_lythuyet',
          '${levelPrefix}_bai${chapter}_luyentap1',
          '${levelPrefix}_bai${chapter}_luyentap2',
          '${levelPrefix}_bai${chapter}_luyentap3',
          '${levelPrefix}_bai${chapter}_luyennoi',
          '${levelPrefix}_bai${chapter}_luyenviet',
          '${levelPrefix}_bai${chapter}_ontap',
        ];
      }

      if (_selectedLevel == 'elementary') {
        // Mở khóa toàn bộ N5
        completedLessons.addAll(alphabetKeys);
        for (int i = 1; i <= 10; i++) {
          completedLessons.addAll(getBasicKeys(i));
        }
      } else if (_selectedLevel == 'intermediate') {
        // Mở khóa toàn bộ N5 và N4
        completedLessons.addAll(alphabetKeys);
        for (int i = 1; i <= 10; i++) {
          completedLessons.addAll(getBasicKeys(i));
        }
        for (int i = 1; i <= 10; i++) {
          completedLessons.addAll(getNXKeys('n4', i));
        }
      } else if (_selectedLevel == 'proficient') {
        // Mở khóa toàn bộ N5, N4 và N3
        completedLessons.addAll(alphabetKeys);
        for (int i = 1; i <= 10; i++) {
          completedLessons.addAll(getBasicKeys(i));
        }
        for (int i = 1; i <= 10; i++) {
          completedLessons.addAll(getNXKeys('n4', i));
        }
        for (int i = 1; i <= 10; i++) {
          completedLessons.addAll(getNXKeys('n3', i));
        }
      }

      // Lưu các bài học hoàn thành qua UserProgress (lưu local + Firestore)
      await UserProgress().setCompletedLessons(completedLessons);

      // Cập nhật mức độ khảo sát lên Firestore
      await FirebaseFirestore.instance.collection('users').doc(widget.uid).set({
        'surveyLevel': _selectedLevel,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      SoundManager.instance.speakJapanese("Omedetou");
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Có lỗi xảy ra: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSoftBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              // Tiêu đề khảo sát
              const Text(
                "Khảo sát năng lực",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Hãy chọn mức độ hiểu biết tiếng Nhật hiện tại của bạn để JapaGo thiết lập lộ trình học phù hợp nhất nhé!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF64748B),
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),

              // Danh sách các thẻ lựa chọn
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _levels.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final level = _levels[index];
                    final isSelected = _selectedLevel == level['key'];

                    return GestureDetector(
                      onTap: () {
                        SoundManager.instance.vibrate('light');
                        setState(() {
                          _selectedLevel = level['key'];
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isSelected ? kPrimaryBlue : Colors.grey.shade200,
                            width: isSelected ? 2.5 : 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? kPrimaryBlue.withOpacity(0.08)
                                  : Colors.black.withOpacity(0.03),
                              blurRadius: isSelected ? 16 : 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icon tròn
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: level['bgColor'],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                level['icon'],
                                color: level['color'],
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Thông tin chữ
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    level['title'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected ? kPrimaryBlue : const Color(0xFF334155),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    level['subtitle'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  // Trạng thái mở khóa chi tiết
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.lock_open,
                                          size: 14,
                                          color: Colors.green,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            level['unlockedText'],
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Checkbox tròn ở góc phải
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? kPrimaryBlue : Colors.grey.shade300,
                                  width: 2,
                                ),
                                color: isSelected ? kPrimaryBlue : Colors.transparent,
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Nút xác nhận
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitSurvey,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 4,
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          "XÁC NHẬN",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

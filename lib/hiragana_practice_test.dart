import 'package:flutter/material.dart';
import 'sound_manager.dart';
import 'recognition_manager.dart';
import 'simple_video_player.dart';

// 4 Giai đoạn mới
enum PracticeStage {
  intro, // 1. Xem GIF
  practice, // 2. Viết lại
  video, // 3. Xem Video từ vựng
  quiz, // 4. Chọn đáp án đúng
}

class HiraganaPracticeScreen extends StatefulWidget {
  final Map<String, dynamic> charData;

  const HiraganaPracticeScreen({super.key, required this.charData});

  @override
  State<HiraganaPracticeScreen> createState() => _HiraganaPracticeScreenState();
}

class _HiraganaPracticeScreenState extends State<HiraganaPracticeScreen> {
  PracticeStage _currentStage = PracticeStage.intro;
  List<List<Offset>> _userStrokes = [];
  List<Offset> _currentStroke = [];
  bool _quizAnswered = false; // Đã trả lời quiz chưa

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      SoundManager.instance.speakJapanese(widget.charData['kana']);
    });
  }

  // --- LOGIC CHUYỂN CẢNH ---
  void _nextStage() {
    SoundManager.instance.vibrate('light');
    setState(() {
      if (_currentStage == PracticeStage.intro) {
        _currentStage = PracticeStage.practice;
      } else if (_currentStage == PracticeStage.practice) {
        _checkWriting(); // Chấm điểm viết
      } else if (_currentStage == PracticeStage.video) {
        _currentStage = PracticeStage.quiz;
      }
      // Quiz là màn cuối, xử lý riêng
    });
  }

  // --- HÀM TÍNH KHOẢNG CÁCH LEVENSHTEIN ---
  int _levenshteinDistance(String s1, String s2) {
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    List<List<int>> matrix = List.generate(s1.length + 1, (i) => List.filled(s2.length + 1, 0));

    for (int i = 0; i <= s1.length; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= s2.length; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= s1.length; i++) {
      for (int j = 1; j <= s2.length; j++) {
        int cost = (s1[i - 1] == s2[j - 1]) ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost
        ].reduce((a, b) => a < b ? a : b);
      }
    }
    return matrix[s1.length][s2.length];
  }

  // --- HÀM TÍNH ĐỘ TƯƠNG ĐỒNG (0.0 đến 1.0) ---
  double _calculateSimilarity(String a, String b) {
    if (a.isEmpty && b.isEmpty) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;
    int distance = _levenshteinDistance(a, b);
    int maxLength = a.length > b.length ? a.length : b.length;
    return 1.0 - (distance / maxLength);
  }

  // Chấm điểm viết
  void _checkWriting() async {
    if (_userStrokes.isEmpty) return;

    // --- BỘ LỌC CHỐNG GIAN LẬN (Anti-cheat) ---
    int totalStrokes = _userStrokes.length;
    double totalInkLength = 0;
    for (var stroke in _userStrokes) {
      for (int i = 0; i < stroke.length - 1; i++) {
        totalInkLength += (stroke[i] - stroke[i + 1]).distance;
      }
    }

    // Nếu vẽ quá nhiều nét (ví dụ > 15) hoặc vẽ quá dài (bôi đen màn hình)
    if (totalStrokes > 15 || totalInkLength > 4000) {
      _showFeedbackBottomSheet(false, () {
        setState(() => _userStrokes = []); // Xóa bảng
      });
      return;
    }

    // Hiển thị vòng chờ loading trong lúc AI chấm điểm
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    // Gọi AI (ML Kit) nhận diện nét viết của người dùng
    List<String> recognizedChars = await RecognitionManager.instance.recognize(
      _userStrokes,
    );
    Navigator.pop(context); // Tắt loading

    String targetChar = widget.charData['kana'] ?? '';
    double maxSimilarity = 0.0;
    String bestMatch = '';

    for (String recognized in recognizedChars) {
      double sim = _calculateSimilarity(targetChar, recognized);
      if (sim > maxSimilarity) {
        maxSimilarity = sim;
        bestMatch = recognized;
      }
    }

    bool isCorrect = maxSimilarity >= 0.75;

    if (isCorrect) {
      SoundManager.instance.vibrate('heavy');
      SoundManager.instance.speakJapanese("Seikai");
      _showFeedbackBottomSheet(true, () {
        setState(() => _currentStage = PracticeStage.video);
      });
    } else {
      SoundManager.instance.vibrate('error');
      _showFeedbackBottomSheet(false, () {
        setState(() => _userStrokes = []); // Xóa bảng
      });
    }
  }

  // Kiểm tra đáp án Quiz
  void _checkQuiz(String selectedChar) {
    if (_quizAnswered) return;
    setState(() => _quizAnswered = true);

    bool isCorrect = selectedChar == widget.charData['kana'];
    if (isCorrect) {
      SoundManager.instance.vibrate('heavy');
      SoundManager.instance.speakJapanese("Seikai"); // Đúng rồi
      _showFeedbackBottomSheet(true, () {
        Navigator.pop(context, true); // Thoát về tháp
      });
    } else {
      SoundManager.instance.vibrate('error');
      _showFeedbackBottomSheet(false, () {
        setState(() => _quizAnswered = false); // Cho chọn lại
      });
    }
  }

  void _showFeedbackBottomSheet(bool isCorrect, VoidCallback onContinue) {
    Color typeColor = isCorrect
        ? const Color(0xFF58CC02)
        : const Color(0xFFFF4B4B);
    Color bgColor = isCorrect
        ? const Color(0xFFD7FFB8)
        : const Color(0xFFFFDFE0);
    String title = isCorrect ? "Đúng rồi!" : "Sai rồi";
    String msg = isCorrect ? "Tuyệt vời! Tiếp tục nào." : "Cố gắng lên nhé!";
    String imageAsset = isCorrect
        ? 'assets/images/dog_happy.png'
        : 'assets/images/dog_sad.png';

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.1),
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: 20 + MediaQuery.of(context).padding.bottom,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    imageAsset,
                    width: 80,
                    height: 80,
                    errorBuilder: (_, _, _) => Icon(
                      isCorrect ? Icons.emoji_emotions : Icons.mood_bad,
                      size: 80,
                      color: typeColor,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: typeColor,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          msg,
                          style: TextStyle(
                            color: isCorrect ? typeColor : Colors.black54,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onContinue();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: typeColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "TIẾP TỤC",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double progress = (_currentStage.index + 1) / 4;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: LinearProgressIndicator(
          value: progress,
          color: const Color(0xFF58CC02),
          backgroundColor: Colors.grey[200],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildTitle(),

            Expanded(
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _buildContent(),
                ),
              ),
            ),

            // Nút bấm dưới cùng (Chỉ hiện ở Intro và Practice và Video)
            if (_currentStage != PracticeStage.quiz)
              Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextStage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF58CC02),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    _currentStage == PracticeStage.practice
                        ? "KIỂM TRA"
                        : "TIẾP TỤC",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    switch (_currentStage) {
      case PracticeStage.intro:
        return const Text(
          "QUAN SÁT CÁCH VIẾT",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        );
      case PracticeStage.practice:
        return const Text(
          "HÃY VIẾT LẠI",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        );
      case PracticeStage.video:
        return const Text(
          "TỪ VỰNG LIÊN QUAN",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        );
      case PracticeStage.quiz:
        return const Text(
          "CHỌN CHỮ ĐÚNG",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        );
    }
  }

  Widget _buildContent() {
    switch (_currentStage) {
      // 1. INTRO: Hiện GIF
      case PracticeStage.intro:
        return Center(
          child: widget.charData['gifPath'] != null
              ? Image.asset(widget.charData['gifPath'])
              : const Text(
                  "Không có ảnh mẫu",
                  style: TextStyle(color: Colors.grey),
                ),
        );

      // 2. PRACTICE: Bảng vẽ
      case PracticeStage.practice:
        return Stack(
          children: [
            Center(
              child: Text(
                widget.charData['kana'],
                style: TextStyle(
                  fontSize: 250,
                  color: Colors.grey.withOpacity(0.1),
                ),
              ),
            ),
            GestureDetector(
              onPanUpdate: (d) =>
                  setState(() => _currentStroke.add(d.localPosition)),
              onPanStart: (d) => setState(
                () => _userStrokes.add(_currentStroke = [d.localPosition]),
              ),
              child: CustomPaint(
                painter: StrokePainter(strokes: _userStrokes),
                size: Size.infinite,
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => setState(() => _userStrokes = []),
              ),
            ),
          ],
        );

      // 3. VIDEO: Video Player
      case PracticeStage.video:
        return Column(
          children: [
            Expanded(
              child: widget.charData['videoUrl'] != null
                  ? SimpleVideoPlayer(
                      url: widget.charData['videoUrl'],
                      onVideoFinished: () {}, // Có thể tự chuyển trang nếu muốn
                    )
                  : const Center(
                      child: Icon(
                        Icons.videocam_off,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                widget.charData['meaning'] ?? "",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );

      // 4. QUIZ: 4 Nút chọn
      case PracticeStage.quiz:
        List<String> options = List<String>.from(
          widget.charData['quizOptions'] ?? [],
        );
        return Center(
          child: Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: options.map((char) {
              return SizedBox(
                width: 120,
                height: 120,
                child: ElevatedButton(
                  onPressed: () => _checkQuiz(char),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Colors.grey),
                    ),
                  ),
                  child: Text(
                    char,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
    }
  }
}

// Painter vẽ nét bút (Giữ nguyên)
class StrokePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  StrokePainter({required this.strokes});
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10.0
      ..style = PaintingStyle.stroke;
    for (var stroke in strokes) {
      if (stroke.isEmpty) continue;
      Path path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

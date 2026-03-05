import 'package:flutter/material.dart';
import 'sound_manager.dart';
import 'recognition_manager.dart';
import 'simple_video_player.dart';

// 4 Giai đoạn mới
enum PracticeStage {
  intro,    // 1. Xem GIF
  practice, // 2. Viết lại
  video,    // 3. Xem Video từ vựng
  quiz      // 4. Chọn đáp án đúng
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

  // Chấm điểm viết
  void _checkWriting() async {
    if (_userStrokes.isEmpty) return;

    // ... (Giữ nguyên logic chấm điểm cũ, chỉ thay đổi phần chuyển trang) ...
    // Giả lập check nhanh để test flow
    bool isCorrect = true; // TODO: Gọi AI thật ở đây

    if (isCorrect) {
      _showResultDialog(true, "Tuyệt vời! Giờ hãy xem từ vựng.");
    } else {
      _showResultDialog(false, "Chưa đúng lắm. Thử lại nhé!");
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
      // Hiện dialog chúc mừng hoàn thành
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text("HOÀN THÀNH!", style: TextStyle(color: Colors.green)),
          content: const Text("Bạn đã chinh phục chữ cái này!"),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, true); // Thoát về tháp
              },
              child: const Text("Về Tháp"),
            )
          ],
        ),
      );
    } else {
      SoundManager.instance.vibrate('error');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sai rồi! Thử lại đi.")));
      Future.delayed(const Duration(seconds: 1), () {
        setState(() => _quizAnswered = false); // Cho chọn lại
      });
    }
  }

  void _showResultDialog(bool isSuccess, String msg) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(isSuccess ? "ĐÚNG RỒI" : "SAI RỒI"),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (isSuccess) {
                setState(() => _currentStage = PracticeStage.video); // Chuyển sang Video
              } else {
                setState(() => _userStrokes = []); // Xóa bảng
              }
            },
            child: const Text("Tiếp tục"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double progress = (_currentStage.index + 1) / 4;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: LinearProgressIndicator(value: progress, color: const Color(0xFF58CC02), backgroundColor: Colors.grey[200]),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.black), onPressed: () => Navigator.pop(context)),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text(
                  _currentStage == PracticeStage.practice ? "KIỂM TRA" : "TIẾP TỤC",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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
      case PracticeStage.intro: return const Text("QUAN SÁT CÁCH VIẾT", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
      case PracticeStage.practice: return const Text("HÃY VIẾT LẠI", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
      case PracticeStage.video: return const Text("TỪ VỰNG LIÊN QUAN", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
      case PracticeStage.quiz: return const Text("CHỌN CHỮ ĐÚNG", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
    }
  }

  Widget _buildContent() {
    switch (_currentStage) {
    // 1. INTRO: Hiện GIF
      case PracticeStage.intro:
        return Center(
          child: widget.charData['gifPath'] != null
              ? Image.asset(widget.charData['gifPath'])
              : const Text("Không có ảnh mẫu", style: TextStyle(color: Colors.grey)),
        );

    // 2. PRACTICE: Bảng vẽ
      case PracticeStage.practice:
        return Stack(
          children: [
            Center(child: Text(widget.charData['kana'], style: TextStyle(fontSize: 250, color: Colors.grey.withOpacity(0.1)))),
            GestureDetector(
              onPanUpdate: (d) => setState(() => _currentStroke.add(d.localPosition)),
              onPanStart: (d) => setState(() => _userStrokes.add(_currentStroke = [d.localPosition])),
              child: CustomPaint(painter: StrokePainter(strokes: _userStrokes), size: Size.infinite),
            ),
            Positioned(top: 10, right: 10, child: IconButton(icon: const Icon(Icons.refresh), onPressed: () => setState(() => _userStrokes = []))),
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
                  : const Center(child: Icon(Icons.videocam_off, size: 50, color: Colors.grey)),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(widget.charData['meaning'] ?? "", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            )
          ],
        );

    // 4. QUIZ: 4 Nút chọn
      case PracticeStage.quiz:
        List<String> options = List<String>.from(widget.charData['quizOptions'] ?? []);
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.grey)),
                  ),
                  child: Text(char, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
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
    Paint paint = Paint()..color = Colors.black..strokeCap = StrokeCap.round..strokeWidth = 10.0..style = PaintingStyle.stroke;
    for (var stroke in strokes) {
      if (stroke.isEmpty) continue;
      Path path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (int i = 1; i < stroke.length; i++) path.lineTo(stroke[i].dx, stroke[i].dy);
      canvas.drawPath(path, paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_progress.dart';

class ListeningDetailScreen extends StatefulWidget {
  final String title;
  final String audioAsset;

  const ListeningDetailScreen({
    super.key,
    required this.title,
    required this.audioAsset,
  });

  @override
  State<ListeningDetailScreen> createState() => _ListeningDetailScreenState();
}

class _ListeningDetailScreenState extends State<ListeningDetailScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  final Map<int, String> _userAnswers = {};
  bool _isSubmitted = false;
  bool _showAllAnswers = false;

  final List<Map<String, dynamic>> _questions = [
    {
      'id': 1,
      'q_image': 'assets/images/n5_l1_q1.png',
      'options': ["A. 1", "B. 2", "C. 3", "D. 4"],
      'correct': "B",
      'explanation': "Dựa vào nội dung nghe, nhân vật đang nói về môn thể thao Bowling (Hình 1)."
    },
    {
      'id': 2,
      'q_image': 'assets/images/n5_l1_q2.png',
      'options': ["A. 1", "B. 2", "C. 3", "D. 4"],
      'correct': "D",
      'explanation': "Người đàn ông tặng một bó hoa lớn cho người phụ nữ (Hình 3)."
    },
    {
      'id': 3,
      'q_image': 'assets/images/n5_l1_q3.png',
      'options': ["A. 1", "B. 2", "C. 3", "D. 4"],
      'correct': "D",
      'explanation': "Người phụ nữ đi mua sắm tại siêu thị (Hình 2)."
    },
    {
      'id': 4,
      'q_image': 'assets/images/n5_l1_q4.png',
      'options': ["A. 1", "B. 2", "C. 3", "D. 4"],
      'correct': "A",
      'explanation': "Bố trí phòng họp theo sơ đồ hình tam giác (Hình 4)."
    },
    {
      'id': 5,
      'options': ["A. 1. 43215018", "B. 2. 43215078", "C. 3. 42315018", "D. 4. 42315078"],
      'correct': "D",
      'explanation': "Số điện thoại chính xác được đọc trong đoạn băng là 4321-5078."
    },
    {
      'id': 6,
      'options': ["A. 1. 3じ", "B. 2. 4じ", "C. 3. 5じ", "D. 4. 6じ"],
      'correct': "C",
      'explanation': "Nhân vật chốt thời gian gặp mặt là 5 giờ (5じ)."
    },
    {
      'id': 7,
      'options': [
        "A. 1. 7じから",
        "B. 2. シャワーをあびてから",
        "C. 3. しんぶんをよんでから",
        "D. 4. しょっきをあらってから"
      ],
      'correct': "D",
      'explanation': "Theo lịch trình, hành động tiếp theo sẽ bắt đầu từ lúc 7 giờ (7じから)."
    },
    {
      'id': 8,
      'q_image': 'assets/images/n5_l1_q8.png',
      'options': ["A. 1", "B. 2", "C. 3", "D. 4"],
      'correct': "A",
      'explanation': "Nhân vật nữ đang đi mua sắm tại cửa hàng (Hình 2)."
    },
    {
      'id': 9,
      'q_image': 'assets/images/n5_l1_q9.png',
      'options': ["A. 1", "B. 2", "C. 3", "D. 4"],
      'correct': "A",
      'explanation': "Họ gọi 1 cafe và 1 nước trái cây (Hình 4)."
    },
    {
      'id': 10,
      'q_image': 'assets/images/n5_l1_q10.png',
      'options': ["A. 1", "B. 2", "C. 3", "D. 4"],
      'correct': "A",
      'explanation': "Chìa khóa được để ở trên đầu tivi (Hình 1)."
    },
    {
      'id': 11,
      'options': [
        "A. 1. でんしゃのつかいかた",
        "B. 2. きっぷのかいかた",
        "C. 3. ぎんこうのじかん",
        "D. 4. いえへのいきかた"
      ],
      'correct': "A",
      'explanation': "Đoạn hội thoại hướng dẫn về cách mua vé (きっぷのかいかた)."
    },
    {
      'id': 12,
      'options': [
        "A. 1. すし、てんぷら、ジュース",
        "B. 2. すし、てんぷら、おちゃ",
        "C. 3. すし、ていしょく",
        "D. 4. すし、わたし"
      ],
      'correct': "A",
      'explanation': "Các món được chọn là Sushi, Tempura và Trà."
    },
    {
      'id': 13,
      'options': ["A. 1. 100えん", "B. 2. 120えん", "C. 3. 500えん", "D. 4. 600えん"],
      'correct': "A",
      'explanation': "Số tiền tổng cộng được nhắc đến là 600 yên."
    },
    // MONDAI 3
    {
      'id': 14,
      'q_image': 'assets/images/n5_l1_q14.png',
      'options': ["A. 1", "B. 2", "C. 3"],
      'correct': "A",
      'explanation': "Câu chào hỏi phù hợp khi đưa chìa khóa/vật gì đó cho người khác."
    },
    {
      'id': 15,
      'q_image': 'assets/images/n5_l1_q15.png',
      'options': ["A. 1", "B. 2", "C. 3"],
      'correct': "A",
      'explanation': "Lời chào xã giao khi gặp đồng nghiệp ở thang máy."
    },
    {
      'id': 16,
      'q_image': 'assets/images/n5_l1_q16.png',
      'options': ["A. 1", "B. 2", "C. 3"],
      'correct': "A",
      'explanation': "Câu nói khi chia tay bạn bè sau buổi đi chơi."
    },
    {
      'id': 17,
      'q_image': 'assets/images/n5_l1_q17.png',
      'options': ["A. 1", "B. 2", "C. 3"],
      'correct': "A",
      'explanation': "Câu chào khi đi ra ngoài (Ittekimasu)."
    },
    {
      'id': 18,
      'q_image': 'assets/images/n5_l1_q18.png',
      'options': ["A. 1", "B. 2", "C. 3"],
      'correct': "A",
      'explanation': "Câu chào lễ phép khi gặp thầy giáo vào buổi sáng."
    },
    // MONDAI 4
    {
      'id': 19,
      'options': ["A. 1", "B. 2", "C. 3"],
      'correct': "B",
      'explanation': "Phản hồi phù hợp cho câu hỏi về sức khỏe hoặc tình trạng."
    },
    {
      'id': 20,
      'options': ["A. 1", "B. 2", "C. 3"],
      'correct': "A",
      'explanation': "Đáp lại một lời mời hoặc đề nghị làm gì đó."
    },
    {
      'id': 21,
      'options': ["A. 1", "B. 2", "C. 3"],
      'correct': "B",
      'explanation': "Phản hồi khi được khen ngợi (Iie, madamada desu)."
    },
    {
      'id': 22,
      'options': ["A. 1", "B. 2", "C. 3"],
      'correct': "C",
      'explanation': "Trả lời câu hỏi về thời gian hoặc thời điểm."
    },
    {
      'id': 23,
      'options': ["A. 1", "B. 2", "C. 3"],
      'correct': "C",
      'explanation': "Phản hồi khi nhận được quà hoặc sự giúp đỡ."
    },
    {
      'id': 24,
      'options': ["A. 1", "B. 2", "C. 3"],
      'correct': "C",
      'explanation': "Câu trả lời cho một câu hỏi lựa chọn (A hay B)."
    }
  ];

  bool _isLoadingFirestore = false;
  String _activeAudioAsset = "";

  @override
  void initState() {
    super.initState();
    _activeAudioAsset = widget.audioAsset;
    _initializeListeningLesson();
  }

  Future<void> _initializeListeningLesson() async {
    setState(() => _isLoadingFirestore = true);
    try {
      final String listenDocId = "listening_lesson_${widget.title.replaceAll(' ', '_')}";
      final lessonDoc = await FirebaseFirestore.instance.collection('listening_lessons').doc(listenDocId).get();
      if (lessonDoc.exists) {
        final lessonData = lessonDoc.data();
        if (lessonData != null && lessonData['audioAsset'] != null && lessonData['audioAsset'].toString().isNotEmpty) {
          _activeAudioAsset = lessonData['audioAsset'];
        }
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('listening_lessons')
          .doc(listenDocId)
          .collection('questions')
          .get();

      if (snapshot.docs.isNotEmpty) {
        final List<Map<String, dynamic>> tempQuestions = [];
        for (var doc in snapshot.docs) {
          final data = doc.data();
          tempQuestions.add({
            'id': data['id'] ?? 1,
            'q_image': data['q_image'] != null && data['q_image'].toString().isNotEmpty ? data['q_image'] : null,
            'options': List<String>.from(data['options'] ?? []),
            'correct': data['correct'] ?? 'A',
            'explanation': data['explanation'] ?? '',
          });
        }
        
        tempQuestions.sort((a, b) => (a['id'] as int).compareTo(b['id'] as int));
        
        setState(() {
          _questions.clear();
          _questions.addAll(tempQuestions);
        });
      }
    } catch (e) {
      print("Lỗi tải câu hỏi nghe từ Firestore: $e");
    }

    final isNetwork = _activeAudioAsset.startsWith('http') || _activeAudioAsset.startsWith('https');
    _controller = isNetwork
        ? VideoPlayerController.networkUrl(Uri.parse(_activeAudioAsset))
        : VideoPlayerController.asset(_activeAudioAsset);

    _controller.initialize().then((_) {
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoadingFirestore = false;
        });
      }
    }).catchError((e) {
      print("Lỗi khởi tạo audio player: $e");
      if (mounted) {
        setState(() => _isLoadingFirestore = false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_userAnswers.length < _questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bạn chưa trả lời hết các câu hỏi!")),
      );
      return;
    }

    setState(() {
      _isSubmitted = true;
      _showAllAnswers = true;
      _controller.pause();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingFirestore) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFFFF5252))),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.title, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TRÌNH PHÁT NHẠC
            _buildAudioPlayer(),

            const SizedBox(height: 30),

            // HƯỚNG DẪN MÀU XANH
            const Text(
              "もんだい1でははじめに、しつもんを聞いてください。それからはなしを聞いて、もんだいようしの1から4の中から、ただしいこたえをひとつえらんでください。\nでは、いちどれんしゅうをしましょう。\nれい",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 14),
            ),

            const SizedBox(height: 20),
            const Divider(),

            // DANH SÁCH CÂU HỎI
            ..._questions.sublist(0, 7).map((q) => _buildQuestionBlock(q)),

            const SizedBox(height: 30),
            // HƯỚNG DẪN MONDAI 2
            const Text(
              "もんだい2でははじめに、しつもんを聞いてください。それからはなしを聞いて、もんだいようしの1から4の中から、ただしいこたえをひとつえらんでください。",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 10),
            const Divider(),

            ..._questions.sublist(7, 13).map((q) => _buildQuestionBlock(q)),

            const SizedBox(height: 30),
            // HƯỚNG DẪN MONDAI 3
            const Text(
              "もんだい3ではえをみながらしつもんをきいてください。それから、ただしいこたえを1から3のなかからひとつえらんでください。",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 10),
            const Divider(),

            ..._questions.sublist(13, 18).map((q) => _buildQuestionBlock(q)),

            const SizedBox(height: 30),
            // HƯỚNG DẪN MONDAI 4
            const Text(
              "もんだい4には、えなどがありません。まずぶんをきいてください。それから、1から3のなかから、ただしいこたえをひとつえらんでください。",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 10),
            const Divider(),

            ..._questions.sublist(18).map((q) => _buildQuestionBlock(q)),

            const SizedBox(height: 40),

            if (!_isSubmitted)
              _buildLargeButton("NỘP BÀI", const Color(0xFFFF5252), _handleSubmit)
            else
              _buildLargeButton("KẾT THÚC XEM LẠI", Colors.orange, () async {
                int score = 0;
                for (var q in _questions) {
                  if (_userAnswers[q['id']] == q['correct']) score++;
                }
                await UserProgress().addExp(score * 5);
                if (mounted) Navigator.pop(context);
              }),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioPlayer() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
      ),
      child: Column(
        children: [
          const Icon(Icons.headset, size: 50, color: Color(0xFFFF5252)),
          const SizedBox(height: 16),
          if (_isInitialized) ...[
            ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, VideoPlayerValue value, child) {
                return Column(
                  children: [
                    Slider(
                      activeColor: const Color(0xFFFF5252),
                      inactiveColor: Colors.grey[200],
                      value: value.position.inMilliseconds.toDouble(),
                      min: 0,
                      max: value.duration.inMilliseconds.toDouble(),
                      onChanged: (val) {
                        _controller.seekTo(Duration(milliseconds: val.toInt()));
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDuration(value.position), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(_formatDuration(value.duration), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.replay_10, size: 30),
                  onPressed: () {
                    final newPos = _controller.value.position - const Duration(seconds: 10);
                    _controller.seekTo(newPos < Duration.zero ? Duration.zero : newPos);
                  },
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _controller.value.isPlaying ? _controller.pause() : _controller.play();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(color: Color(0xFFFF5252), shape: BoxShape.circle),
                    child: Icon(
                      _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.forward_10, size: 30),
                  onPressed: () {
                    final newPos = _controller.value.position + const Duration(seconds: 10);
                    _controller.seekTo(newPos);
                  },
                ),
              ],
            ),
          ] else
            const CircularProgressIndicator(color: Color(0xFFFF5252)),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    String minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    String seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  Widget _buildQuestionBlock(Map<String, dynamic> q) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text("Câu ${q['id']}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        if (q['question'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(q['question'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
          ),
        if (q['q_image'] != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: q['q_image'].toString().startsWith('http')
                ? Image.network(
                    q['q_image'],
                    errorBuilder: (c, e, s) => Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                    ),
                  )
                : Image.asset(
                    q['q_image'],
                    errorBuilder: (c, e, s) => Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                    ),
                  ),
          ),
        const SizedBox(height: 12),
        ...(q['options'] as List).map((opt) => _buildOption(q['id'], opt, q['correct'])),
        if (_showAllAnswers) _buildExplanationBox(q['correct'], q['explanation']),
      ],
    );
  }

  Widget _buildOption(int questionId, String text, String correctLetter) {
    String letter = text.substring(0, 1);
    bool isSelected = _userAnswers[questionId] == letter;
    bool isCorrect = letter == correctLetter;

    Color borderColor = Colors.grey.shade300;
    Color bgColor = Colors.white;

    if (isSelected) {
      borderColor = const Color(0xFFFF5252);
      bgColor = const Color(0xFFFFEBEE);
    }

    if (_showAllAnswers) {
      if (isCorrect) {
        borderColor = Colors.green;
        bgColor = Colors.green.shade50;
      } else if (isSelected) {
        borderColor = Colors.red;
        bgColor = Colors.red.shade50;
      }
    }

    return GestureDetector(
      onTap: () {
        if (!_isSubmitted) {
          setState(() => _userAnswers[questionId] = letter);
        }
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
            if (_showAllAnswers && isCorrect) const Icon(Icons.check_circle, color: Colors.green, size: 20),
            if (_showAllAnswers && isSelected && !isCorrect) const Icon(Icons.cancel, color: Colors.red, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationBox(String correct, String explanation) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Đáp án đúng: $correct", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          const SizedBox(height: 4),
          Text(explanation, style: const TextStyle(fontSize: 13, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildLargeButton(String label, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

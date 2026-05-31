import 'package:flutter/material.dart';
import 'user_progress.dart';

class ReadingDetailScreen extends StatefulWidget {
  final String title;
  const ReadingDetailScreen({super.key, required this.title});

  @override
  State<ReadingDetailScreen> createState() => _ReadingDetailScreenState();
}

class _ReadingDetailScreenState extends State<ReadingDetailScreen> {
  // Trạng thái lưu câu trả lời đã chọn của người dùng
  final Map<int, String> _userAnswers = {};
  bool _isSubmitted = false;
  bool _showAllAnswers = false;

  // Dữ liệu bài đọc
  final List<Map<String, dynamic>> _mondai8 = [
    {
      'id': 1,
      'passage': "（会社で）ムムさんは　同じ　会社の　大友さんに　メールを　しました。\n\n大友さん\n机の　上の　おかしを　ありがとう。旅行は　どうでしたか。\n今、大友さんの　ところに　行きましたが、いませんでしたから、メールを　しました。\nおいしかったです。ごちそうさまでした。\nムム",
      'question': "このメールで、ムムさんは　大友さんに　何が　言いたいですか。",
      'options': [
        "A. おかしを　ありがとうございました。",
        "B. わたしも　旅行に　行きたいです。",
        "C. 今、大友さんは　どこに　いますか。",
        "D. わたしも　おかしが　好きです。",
      ],
      'correct': "A",
      'explanation': "Trong email, Mum-san viết '机の上の おかしを ありがとう' (Cảm ơn vì món bánh trên bàn) và 'おいしかったです' (Nó rất ngon). Mục đích chính là để cảm ơn về món quà."
    },
    {
      'id': 2,
      'passage': "学生の　ころ、わたしは　いつも　友だちと　話しながら　電車で　学校に　行っていました。今は　一人で　電車で　会社に　行きます。会社まで　１時間、本을　読みながら　行きます. 今は　本が　わたしの　友だちです。",
      'question': "「わたし」は　今、電車の中で何をしますか。",
      'options': [
        "A. 友だちと　話します。",
        "B. 友だちと　本を　読みます。",
        "C. 一人で　本を　読みます。",
        "D. 会社の人と　話します。",
      ],
      'correct': "C",
      'explanation': "Đoạn văn có câu '今は 一人で 電車で 会社に 行きます... 本を 読みながら 行きます' (Bây giờ tôi đi làm một mình bằng tàu điện... vừa đi vừa đọc sách). Đáp án C là chính xác nhất."
    }
  ];

  final Map<String, dynamic> _mondai9 = {
    'passage': "これは　ランさんが　書いた　さくぶんです。\n\n青木山に　のぼりました\nきのう、はじめて　青木山に　のぼりました. 山の　上の　さくらが　見たかったからです. 山の　入口から　山の　上まで　２時間　かかります. 私は　１５分ぐらいのぼって、すぐに　つかれました。\n\nでも、山で　会った　人たちが　みんな、私に　元気な　声で　「こんにちは。」と　言いました. ちょっと　①うれしかったです。\n\n１時間ごろ　山の　上に　着きました. さくらの　木は　ありましたが、花は　ありませんでした. 近くに　いた　女の　人に　「さくらの　花は　まだですか。」と　聞きました. 女の　人は　「山の　上は　寒い　ですから、花は　まだです. 来月の　はじめごろに　咲く　と　思いますよ。」と　言いました. ですから、②来月　また　行きたいです。",
    'questions': [
      {
        'id': 3,
        'q': "どうして　①うれしかったですか。",
        'options': [
          "A. はじめて　青木山に　のぼったから。",
          "B. 山で　ぜんぜん　人に　会わなかったから。",
          "C. 山で　会った　人たちも　いっしょに　山に　のぼったから。",
          "D. 山で　会った　人たちが　私に　「こんにちは。」と　言ったから。",
        ],
        'correct': "D",
        'explanation': "Lan cảm thấy vui vì những người gặp trên núi đều chào cô ấy bằng giọng vui vẻ: '山で 会った 人たちが みんな、私に 元気な 声で 「こんにちは。」と 言いました'."
      },
      {
        'id': 4,
        'q': "どうして　②来月　また　行きたいですか。",
        'options': [
          "A. さくらの　花が　見られるから。",
          "B. 山の　上で　さくらの　花を　見られないから。",
          "C. 山の　上は　寒いから。",
          "D. 山で　たくさんの　人と　話したいから。",
        ],
        'correct': "A",
        'explanation': "Vì người phụ nữ nói rằng hoa anh đào sẽ nở vào đầu tháng sau ('来月の はじめごろに 咲く'), nên Lan muốn quay lại để ngắm hoa."
      }
    ]
  };

  final Map<String, dynamic> _mondai10 = {
    'id': 5,
    'title': "中野の町　今週のやすいい店",
    'subtitle': "12月13日(金)・14日(土)・15日(日)\n今週は下の四つの店がやすいですよ",
    'tableContent': [
      {'name': "① 六八くだもの", 'items': "13日(金) みかん 198円\n14日(土) バナナ 89円\n15日(日) いちご 300円"},
      {'name': "② とりのたかだ", 'items': "13日(金) とりにく 150円\n14日(土) たまご 99円\n15日(日) とりにく 150円"},
      {'name': "③ すずきスーパー", 'items': "13日(金) ジュース 50円\n14日(土) とうふ 48円\n15日(日) チョコレート 88円"},
      {'name': "④ スーパーやまだ", 'items': "13日(金) りんご 50円\n14日(土) ぎゅうにゅう 120円\n15日(日) アイスクリーム 80円"},
    ],
    'question': "ダトさんは、卵と　りんごを　安い　日に　買いたいです. いつ　どの　店へ　行きますか。",
    'options': [
      "A. 13日に ④、14日に ②",
      "B. 13日に ④, 15日に ①",
      "C. 14日に ②, 15日に ①",
      "D. 14日に ②, 15日に ④",
    ],
    'correct': "A",
    'explanation': "Dựa vào bảng: りんご (táo) rẻ nhất vào ngày 13 tại cửa hàng ④ (50円). たまご (trứng) rẻ vào ngày 14 tại cửa hàng ② (99円). Vậy đáp án là A."
  };

  int get _totalQuestions => 5;

  void _handleSubmit() {
    if (_userAnswers.length < _totalQuestions) {
      List<int> missing = [];
      for (int i = 1; i <= _totalQuestions; i++) {
        if (!_userAnswers.containsKey(i)) missing.add(i);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bạn chưa hoàn thành câu: ${missing.join(', ')}")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận"),
        content: const Text("Bạn có chắc chắn muốn nộp bài không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _isSubmitted = true;
                _showAllAnswers = true;
              });
            },
            child: const Text("Đồng ý"),
          ),
        ],
      ),
    );
  }

  void _finishReview() async {
    int score = 0;
    // Tính điểm
    for (var q in _mondai8) {
      if (_userAnswers[q['id']] == q['correct']) score++;
    }
    for (var q in _mondai9['questions']) {
      if (_userAnswers[q['id']] == q['correct']) score++;
    }
    if (_userAnswers[_mondai10['id']] == _mondai10['correct']) score++;

    // Thêm EXP
    await UserProgress().addExp(score * 5);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ReadingSummaryScreen(
          correctCount: score,
          totalCount: _totalQuestions,
          expEarned: score * 5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            // Mondai 8
            ..._mondai8.map((q) => _buildQuestionBlock(
              id: q['id'],
              passage: q['passage'],
              question: q['question'],
              options: q['options'],
              correct: q['correct'],
              explanation: q['explanation'],
            )),

            const Divider(height: 40),

            // Mondai 9
            _buildLongPassageBlock(),

            const Divider(height: 40),

            // Mondai 10
            _buildInfoReadingBlock(),

            const SizedBox(height: 40),

            if (!_isSubmitted)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3366FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("NỘP BÀI", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _finishReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("KẾT THÚC XEM LẠI", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionBlock({
    required int id,
    required String passage,
    required String question,
    required List<String> options,
    required String correct,
    required String explanation,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(passage, style: const TextStyle(fontSize: 15, height: 1.6)),
        ),
        const SizedBox(height: 16),
        Text(question, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...options.map((opt) => _buildOption(id, opt, correct)),
        if (_showAllAnswers) _buildExplanationBox(correct, explanation),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildLongPassageBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(_mondai9['passage'], style: const TextStyle(fontSize: 15, height: 1.6)),
        ),
        const SizedBox(height: 24),
        ...(_mondai9['questions'] as List).map((q) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(q['q'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ...(q['options'] as List<String>).map((opt) => _buildOption(q['id'], opt, q['correct'])),
            if (_showAllAnswers) _buildExplanationBox(q['correct'], q['explanation']),
            const SizedBox(height: 24),
          ],
        )),
      ],
    );
  }

  Widget _buildInfoReadingBlock() {
    final q = _mondai10;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 2),
          ),
          child: Column(
            children: [
              Text(q['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              const SizedBox(height: 8),
              Text(q['subtitle'], textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Colors.black54)),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.1,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  final item = q['tableContent'][index];
                  return Container(
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300, width: 0.5)),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(item['items']!, style: const TextStyle(fontSize: 11, color: Colors.black87)),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(q['question'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...(q['options'] as List<String>).map((opt) => _buildOption(q['id'], opt, q['correct'])),
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
      borderColor = const Color(0xFF3366FF);
      bgColor = const Color(0xFFE3F2FD);
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
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
            if (_showAllAnswers && isCorrect) const Icon(Icons.check_circle, color: Colors.green, size: 20),
            if (_showAllAnswers && isSelected && !isCorrect) const Icon(Icons.cancel, color: Colors.red, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationBox(String correct, String explanation) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text("Đáp án đúng: $correct", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
            ],
          ),
          const SizedBox(height: 8),
          const Text("Giải thích:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 4),
          Text(explanation, style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.5)),
        ],
      ),
    );
  }
}

class ReadingSummaryScreen extends StatelessWidget {
  final int correctCount;
  final int totalCount;
  final int expEarned;

  const ReadingSummaryScreen({
    super.key,
    required this.correctCount,
    required this.totalCount,
    required this.expEarned,
  });

  @override
  Widget build(BuildContext context) {
    int percent = ((correctCount / totalCount) * 100).round();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Image.asset(
                'assets/images/dog_happy.png',
                height: 180,
                errorBuilder: (_, _, _) => const Icon(Icons.emoji_events, size: 120, color: Colors.amber),
              ),
              const SizedBox(height: 30),
              const Text(
                "Hoàn thành bài đọc!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  _buildStatCard("CHÍNH XÁC", "$percent%", Colors.green, const Color(0xFFE8F5E9)),
                  const SizedBox(width: 16),
                  _buildStatCard("ĐIỂM SỐ", "$correctCount/$totalCount", Colors.blue, const Color(0xFFE3F2FD)),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("⚡ Kinh nghiệm nhận được:", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("+$expEarned EXP", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 18)),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3366FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text("TIẾP TỤC", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}

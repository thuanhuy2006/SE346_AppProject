import 'package:flutter/material.dart';
import 'user_progress.dart';

class ReadingDetailScreen extends StatefulWidget {
  final String title;
  final int lessonIndex; // 1 cho bài 1, 2 cho bài 2
  const ReadingDetailScreen({super.key, required this.title, this.lessonIndex = 1});

  @override
  State<ReadingDetailScreen> createState() => _ReadingDetailScreenState();
}

class _ReadingDetailScreenState extends State<ReadingDetailScreen> {
  final Map<int, String> _userAnswers = {};
  bool _isSubmitted = false;
  bool _showAllAnswers = false;

  late List<Map<String, dynamic>> _lessonData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    if (widget.lessonIndex == 1) {
      _lessonData = [
        {
          'type': 'instruction',
          'text': "つぎの ぶんしょうを 読んで、しつもんにつき いちばん いい ものを 一つ えらんでください。"
        },
        {
          'type': 'question',
          'id': 1,
          'passage': "（会社で）ムムさんは　同じ　会社の　大友さんに　メールを　しました。\n\n大友さん\n机の　上の　おかしを　ありがとう。旅行は　どうでしたか。\n今、大友さんの　ところに　行きましたが、いませんでしたから、メールを　しました。\nおいしかったです。ごちそうさまでした。\nムム",
          'question': "このメールで、ムムさんは　大友さんに　何が　言いたいですか。",
          'options': ["A. おかしを　ありがとうございました。", "B. わたしも　旅行に　行きたいです。", "C. 今、大友さんは　どこに　いますか。", "D. わたしも　おかしが　好きです。"],
          'correct': "A",
          'explanation': "Trong email, Mum-san viết '机の上の おかしを ありがとう' (Cảm ơn vì món bánh trên bàn) và 'おいしかったです' (Nó rất ngon). Mục đích chính là để cảm ơn về món quà."
        },
        {
          'type': 'question',
          'id': 2,
          'passage': "学生の　ころ、わたしは　いつも　友だちと　話しながら　電車で　学校に　行っていました。今は　一人で　電車で　会社に　行きます。会社まで　１時間、本を　読みながら　行きます。今は　本が　わたしの　友だちです。",
          'question': "「わたし」は　今、電車の中で何をしますか。",
          'options': ["A. 友だちと　話します。", "B. 友だちと　本を　読みます。", "C. 一人で　本を　読みます。", "D. 会社の人と　話します。"],
          'correct': "C",
          'explanation': "Đoạn văn có câu '今は 一人で 電車で 会社に 行きます... 本を 読みながら 行きます' (Bây giờ tôi đi làm một mình bằng tàu điện... vừa đi vừa đọc sách). Đáp án C là chính xác nhất."
        },
        {
          'type': 'question',
          'id': 3,
          'passage': "これは　ランさんが　書いた　さくぶんです。\n\n青木山に　のぼりました\nきのう、はじめて　青木山に　のぼりました。山の　上の　さくらが　見たかったからです。山の　入口 từ 山の　上まで　２時間　かかります。私は　１５分ぐらいのぼって、すぐに　つかれました。でも、山で　会った　人たちが　みんな、私に　元気な　声で　「こんにちは。」と　言いました。ちょっと　①うれしかったです。\n１時間ごろ　山の　上に　着きました。さくらの　木は　ありましたが、花は　ありませんでした。近くに　いた　女の　人に　「さくらの　花は　まだですか。」と　聞きました。女の　人は　「山の　上は　寒い　ですから、花は　まだです。来月の　はじめごろに　咲く　と　思いますよ。」と　言いました。ですから、②来月　また　行きたいです。",
          'question': "どうして　①うれしかったですか。",
          'options': ["A. はじめて　青木山に　のぼったから。", "B. 山で　ぜんぜん　人に　会わなかったから。", "C. 山で　会った　人たちも　いっしょに　山に　のぼったから。", "D. 山で　会った　人たちが　私に　「こんにちは。」と　言ったから。"],
          'correct': "D",
          'explanation': "Lan cảm thấy vui vì những người gặp trên núi đều chào cô ấy bằng giọng vui vẻ."
        },
        {
          'type': 'info_table',
          'id': 5,
          'title': "中野の町　今週のやすいい店",
          'subtitle': "12月13日(金)・14日(土)・15日(日)\n今週は下の四つの店がやすいですよ",
          'tableContent': [
            {'name': "① 六八くだもの", 'items': "13日(金) みかん 198円\n14日(土) バナナ 89円\n15日(日) いちご 300円"},
            {'name': "② とりのたかだ", 'items': "13日(金) とりにく 150円\n14日(土) たまご 99円\n15日(日) とりにく 150円"},
            {'name': "③ すずきスーパー", 'items': "13日(金) ジュース 50円\n14日(土) とうふ 48円\n15日(日) チョコレート 88円"},
            {'name': "④ スーパーやまだ", 'items': "13日(金) りんご 50円\n14日(土) ぎゅうにゅう 120円\n15日(日) アイスクリーム 80円"},
          ],
          'question': "ダトさんは、卵と　りんごを　安い　日に　買いたいです。いつ　どの　店へ　行きますか。",
          'options': ["A. 13日に ④、14日に ②", "B. 13日に ④, 15日に ①", "C. 14日に ②, 15日に ①", "D. 14日に ②, 15日に ④"],
          'correct': "A",
          'explanation': "Dựa vào bảng: りんご (táo) rẻ nhất vào ngày 13 tại cửa hàng ④. たまご (trứng) rẻ vào ngày 14 tại cửa hàng ②. Vậy đáp án là A."
        },
      ];
    } else {
      // BÀI 2 - DỮ LIỆU TỪ HÌNH ẢNH MỚI
      _lessonData = [
        {
          'type': 'instruction',
          'text': "つぎの（1）から（3）の ぶんしょうを 読んで、しつもんにつき いちばん いい ものを 一つ えらんでください。"
        },
        {
          'type': 'question',
          'id': 1,
          'passage': "わたしは　来週、りょうしんと　３人で　大阪へ　行きます。４月から　弟が　大阪に　住んでいますから、会いに　行きます。弟は　そうじが　きらいですから、へやは　たぶん　きたないでしょう。",
          'question': "「わたし」は、来週、何を　しますか。",
          'options': ["A. 弟と　大阪に　行きます。", "B. 弟の　へやを　そうじします。", "C. りょうしんと　大阪に　行きます。", "D. りょうしんと　いっしょに　住みます。"],
          'correct': "C",
          'explanation': "Đoạn văn viết: 'わたしは 来週、りょうしんと 3人で 大阪へ 行きます' (Tôi cùng bố mẹ, tổng cộng 3 người, tuần sau sẽ đi Osaka)."
        },
        {
          'type': 'question',
          'id': 2,
          'passage': "きのう　母と　デパート　行きました。母は　黒い　くつを　買いました。わたしはいつも　ズボンを　はきますが、かわいい　スカートを　買いました。シャツも　買いましたが、ちょっと　大きかったです。",
          'question': "「わたし」は、何を　買いましたか。",
          'options': ["A. スカートと　シャツ", "B. ズボンと　シャツ", "C. スカートと　くつ", "D. ズボンと　くつ"],
          'correct': "A",
          'explanation': "Nhân vật 'tôi' viết: 'スカートを 買いました' (đã mua váy) và 'シャツも 買いました' (cũng đã mua áo sơ mi)."
        },
        {
          'type': 'question',
          'id': 3,
          'passage': "あきこさんへ\nおはしや　紙の　コップは、きのう　買いました。ジュースと　お茶は　これから　買いに　行きます。明日の　朝、わたしと　さくらさんは　ケーキを　作りますから、あきこさんは　お花を　買ってきて　ください。12時までに　来て　ください。\nさくら",
          'question': "いつ　飲み物を　買いに　行きますか。",
          'options': ["A. きのう", "B. 今日", "C. 明日の朝", "D. 明日の昼"],
          'correct': "B",
          'explanation': "Trong thư viết 'ジュースと お茶は これから 買いに 行きます' (Nước trái cây và trà thì BÂY GIỜ/LÁT NỮA tôi sẽ đi mua). Thời điểm viết thư là 'Hôm nay' (今日)."
        },
        {
          'type': 'instruction',
          'text': "つぎの ぶんしょうを 読んで、しつもんに こたえて ください。こたえは、1・2・3・4 から いちばん いい ものを 一つ えらんで ください。"
        },
        {
          'type': 'question',
          'id': 4,
          'passage': "先週の　日曜日、田中さんの　家に　あそびに　行きました。そして、お昼に　いっしょに　ベトナムりょうりを　作りました。田中さんは　昔　ベトナムに　住んでいた　ことがありますから、ベトナムりょうりを　作る　ことが　できます。私は、ベトナムりょうりは　好きですが、作る　ことは　できませんから、田中さんに　ならいました。田中さんは「久しぶりに　作りました」と　言いました　が、とても　上手でした。おいしかったです。",
          'question': "田中さんは　どうして　ベトナムりょうりを　作る　ことが　できますか。",
          'options': ["A. ベトナムに　りょこうに　行ったから", "B. ベトナムに　住んでいたから", "C. レストランで　はたらいていたから", "D. 毎日　作るから"],
          'correct': "B",
          'explanation': "Đoạn văn viết: '田中さんは 昔 ベトナムに 住んでいた ことが ありますから' (Vì anh Tanaka trước đây đã từng sống ở Việt Nam)."
        },
        {
          'type': 'info_table',
          'id': 5,
          'title': "ふじスポーツクラブ",
          'subtitle': "いっしょに　スポーツを　しませんか！\n4月からの　時間",
          'tableContent': [
            {'name': "すいえい (Bơi)", 'items': "火・木 (T3,5)\n7:00 ~ 20:30"},
            {'name': "テニス (Tennis)", 'items': "月・水・金 (T2,4,6)\n18:30 ~ 20:30"},
            {'name': "ダンス (Nhảy)", 'items': "月・金 (T2,6)\n18:00 ~ 20:00"},
            {'name': "ゴルフ (Golf)", 'items': "土 (T7)\n10:00 ~ 12:00"},
          ],
          'question': "Người này đi làm T2-T6 (10:00-18:30). Thứ 7 bận học vẽ. Muốn đi tập 2 buổi/tuần. Chọn môn nào?",
          'options': ["A. すいえい (Bơi)", "B. テニス", "C. ダンス", "D. ゴルフ"],
          'correct': "A",
          'explanation': "Người này làm việc đến 18:30 nên không kịp tập Tennis/Nhảy (vốn bắt đầu lúc 18:00/18:30). Thứ 7 bận nên không tập Golf được. Môn Bơi (すいえい) kéo dài đến 20:30 vào T3,5 là phù hợp nhất."
        },
      ];
    }
  }

  void _handleSubmit() {
    int totalQ = _lessonData.where((e) => e['type'] == 'question' || e['type'] == 'info_table').length;
    if (_userAnswers.length < totalQ) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bạn chưa hoàn thành hết các câu hỏi!")),
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
    int total = 0;
    for (var item in _lessonData) {
      if (item['type'] == 'question' || item['type'] == 'info_table') {
        total++;
        if (_userAnswers[item['id']] == item['correct']) score++;
      }
    }
    await UserProgress().addExp(score * 5);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ReadingSummaryScreen(
          correctCount: score,
          totalCount: total,
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
          children: [
            ..._lessonData.map((item) {
              if (item['type'] == 'instruction') {
                return _buildInstruction(item['text']);
              } else if (item['type'] == 'question') {
                return _buildQuestionBlock(item);
              } else if (item['type'] == 'info_table') {
                return _buildInfoReadingBlock(item);
              }
              return const SizedBox();
            }),
            const SizedBox(height: 30),
            if (!_isSubmitted)
              _buildLargeButton("NỘP BÀI", const Color(0xFF3366FF), _handleSubmit)
            else
              _buildLargeButton("KẾT THÚC XEM LẠI", Colors.orange, _finishReview),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildInstruction(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFF0000FF), fontWeight: FontWeight.bold, fontSize: 14),
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

  Widget _buildQuestionBlock(Map<String, dynamic> item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item['passage'] != null)
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(item['passage'], style: const TextStyle(fontSize: 15, height: 1.6)),
          ),
        Text(item['question'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...(item['options'] as List).map((opt) => _buildOption(item['id'], opt, item['correct'])),
        if (_showAllAnswers) _buildExplanationBox(item['correct'], item['explanation']),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildInfoReadingBlock(Map<String, dynamic> item) {
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
              Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              const SizedBox(height: 8),
              Text(item['subtitle'], textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Colors.black54)),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.1,
                ),
                itemCount: (item['tableContent'] as List).length,
                itemBuilder: (context, index) {
                  final cell = item['tableContent'][index];
                  return Container(
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300, width: 0.5)),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cell['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(cell['items']!, style: const TextStyle(fontSize: 11, color: Colors.black87)),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(item['question'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...(item['options'] as List).map((opt) => _buildOption(item['id'], opt, item['correct'])),
        if (_showAllAnswers) _buildExplanationBox(item['correct'], item['explanation']),
        const SizedBox(height: 32),
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

import 'package:flutter/material.dart';
import 'recognition_manager.dart';
import 'sound_manager.dart';
import 'user_progress.dart';
import 'app_settings.dart';
import 'database_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

enum LessonType {
  learn,
  quiz,
  matching,
  imageQuiz,
  sentenceBuilder,
  kanjiDraw,
  listening,
  flashCard,
  vocabQuiz,
  vocabSummary,
  speaking,
  vocabListIntro,
  grammarListIntro,
  grammarStructure,
  grammarUsage,
  grammarExample,
}

class LessonScreen extends StatefulWidget {
  final String lessonId;
  final String lessonTitle;
  static DateTime? audioDisabledUntil;
  const LessonScreen({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  int _currentIndex = 0;
  double _progress = 0;
  List<Map<String, dynamic>> _activities = [];

  int _correctAnswers = 0;
  int _totalQuizCount = 0;

  Set<String> _wrongAnswers = {};
  LessonType _currentActivityType = LessonType.learn;

  @override
  void initState() {
    super.initState();
    _loadLessonData();
    
    if (_activities.isNotEmpty) {
      _currentActivityType = _activities[_currentIndex]['type'] as LessonType;
    }

    bool isAudioDisabled =
        LessonScreen.audioDisabledUntil != null &&
        DateTime.now().isBefore(LessonScreen.audioDisabledUntil!);
    if (isAudioDisabled &&
        _activities.isNotEmpty &&
        _activities[0]['type'] == LessonType.listening) {
      while (_currentIndex < _activities.length - 1 &&
          _activities[_currentIndex]['type'] == LessonType.listening) {
        _currentIndex++;
      }
    }
    _totalQuizCount = _activities
        .where(
          (e) =>
              e['type'] == LessonType.quiz ||
              e['type'] == LessonType.matching ||
              e['type'] == LessonType.imageQuiz ||
              e['type'] == LessonType.sentenceBuilder ||
              e['type'] == LessonType.listening ||
              e['type'] == LessonType.vocabQuiz,
        )
        .length;

    _playCurrentAudio();
  }

  void _playCurrentAudio() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted || _activities.isEmpty) return;

    final activity = _activities[_currentIndex];
    final type = activity['type'] as LessonType;

    String textToRead = activity['audio_text']?.toString() ?? "";

    if (textToRead.isEmpty) {
      if (type == LessonType.learn) {
        textToRead = activity['char'] ?? "";
      } else if (type == LessonType.sentenceBuilder) {
        textToRead = activity['jp'] ?? "";
      } else if (type == LessonType.listening) {
        textToRead = activity['answer'] ?? "";
      } else if (type == LessonType.flashCard) {
        textToRead = activity['hiragana'] ?? activity['kanji'] ?? "";
      } else if (type == LessonType.vocabQuiz) {
        textToRead = activity['hiragana'] ?? activity['kanji'] ?? "";
      } else if (type == LessonType.quiz) {
        textToRead = activity['question'] ?? activity['answer'] ?? "";
      } else if (type == LessonType.speaking) {
        textToRead = activity['jp'] ?? "";
      }
    }

    if (textToRead.isNotEmpty) {
      SoundManager.instance.speakJapanese(textToRead);
    }
  }

  // --- HÀM TRỢ GIÚP LẤY ĐƯỜNG DẪN ẢNH THEO CẤP ĐỘ ---
  String _img(String level, String name) => 'assets/images/$level/$name';

  void _loadLessonData() {
    switch (widget.lessonId) {
      case 'hang_a': _activities = _getHangAData(); break;
      case 'cb1_lythuyet': _activities = _getCb1LyThuyetData(); break;
      case 'cb1_luyentap1': _activities = _getLuyenTap1Data(); break;
      case 'n4_bai1_lythuyet': _activities = _getN4Bai1LyThuyetData(); break;
      case 'n4_bai1_luyentap1': _activities = _getN4Bai1LuyenTap1Data(); break;
      // ... Các case khác tương tự, trỏ đến các hàm bên dưới
      default: _activities = _getCb1LyThuyetData(); // Demo mặc định
    }
  }

  // ==========================================
  // N5 DATA (FOLDERS: assets/images/N5/)
  // ==========================================
  List<Map<String, dynamic>> _getCb1LyThuyetData() {
    return [
      {
        'type': LessonType.vocabListIntro,
        'words': [
          {'kanji': 'こんにちは', 'hiragana': 'こんにちは', 'romaji': 'konnichiwa', 'meaning': 'Xin chào'},
          {'kanji': 'さようなら', 'hiragana': 'さようなら', 'romaji': 'sayounara', 'meaning': 'Tạm biệt'},
          {'kanji': '娘', 'hiragana': 'むすめ', 'romaji': 'musume', 'meaning': 'Con gái'},
        ],
      },
      {
        'type': LessonType.flashCard,
        'kanji': '',
        'hiragana': 'こんにちは',
        'romaji': 'konnichiwa',
        'meaning': 'Xin chào',
        'example_img': _img('N5', 'example_konnichiwa.png'),
        'example_jp': 'こんにちは、元気ですか。',
        'example_rmj': 'Konnichiwa, genki desu ka.',
        'example_vn': 'Xin chào, bạn có khỏe không?',
      },
      {
        'type': LessonType.flashCard,
        'kanji': '娘',
        'hiragana': 'むすめ',
        'romaji': 'musume',
        'meaning': 'Con gái (của mình)',
        'example_img': _img('N5', 'example_musume.png'),
        'example_jp': '私の娘は５歳です。',
        'example_rmj': 'Watashi no musume wa gosai desu.',
        'example_vn': 'Con gái tôi 5 tuổi.',
      },
      {
        'type': LessonType.vocabSummary,
        'words': [
          {'id': 1, 'kanji': 'こんにちは', 'hiragana': 'こんにちは', 'romaji': 'konnichiwa', 'meaning': 'xin chào'},
          {'id': 3, 'kanji': '娘', 'hiragana': 'むすめ', 'romaji': 'musume', 'meaning': 'con gái'},
        ],
      },
    ];
  }

  List<Map<String, dynamic>> _getLuyenTap1Data() {
    return [
      {
        'type': LessonType.imageQuiz,
        'question': 'Xin chào.',
        'answerIndex': 1,
        'options': [
          {'img': _img('N5', 'example_sayounara.png'), 'jp': 'さようなら', 'rmj': 'sayounara'},
          {'img': _img('N5', 'example_konnichiwa.png'), 'jp': 'こんにちは', 'rmj': 'konnichiwa'},
          {'img': _img('N5', 'example_musume.png'), 'jp': 'むすめ', 'rmj': 'musume'},
          {'img': _img('N5', 'example_musuko.png'), 'jp': 'むすこ', 'rmj': 'musuko'},
        ],
      },
    ];
  }

  // ==========================================
  // N4 DATA (FOLDERS: assets/images/N4/)
  // ==========================================
  List<Map<String, dynamic>> _getN4Bai1LyThuyetData() {
    return [
      {
        'type': LessonType.flashCard,
        'kanji': '泳ぎます',
        'hiragana': 'およぎます',
        'romaji': 'oyogimasu',
        'meaning': 'Bơi',
        'example_img': _img('N4', 'example_oyogimasu.png'),
        'example_jp': '海で泳ぎます。',
        'example_rmj': 'Umi de oyogimasu.',
        'example_vn': 'Tôi bơi ở biển.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': '弾きます',
        'hiragana': 'ひきます',
        'romaji': 'hikimasu',
        'meaning': 'Chơi (nhạc cụ)',
        'example_img': _img('N4', 'example_hikimasu.png'),
        'example_jp': 'ギターを弾きます。',
        'example_rmj': 'Gitaa o hikimasu.',
        'example_vn': 'Tôi chơi đàn guitar.',
      },
    ];
  }

  List<Map<String, dynamic>> _getN4Bai1LuyenTap1Data() {
    return [
      {
        'type': LessonType.imageQuiz,
        'question': 'Biển.',
        'answerIndex': 3,
        'options': [
          {'img': _img('N4', 'example_piano.png'), 'jp': 'ピアノ', 'rmj': 'piano'},
          {'img': _img('N4', 'example_gitaa.png'), 'jp': 'ギター', 'rmj': 'gitaa'},
          {'img': _img('N4', 'example_oyogimasu.png'), 'jp': '泳ぎます', 'rmj': 'oyogimasu'},
          {'img': _img('N4', 'example_umi.png'), 'jp': '海', 'rmj': 'umi'},
        ],
      },
    ];
  }

  // ==========================================
  // LOGIC CHUYỂN BÀI & SRS EVALUATION
  // ==========================================
  void _nextActivity() {
    if (_currentIndex < _activities.length - 1) {
      setState(() {
        _currentIndex++;
        _currentActivityType = _activities[_currentIndex]['type'] as LessonType;
      });
      _progress = (_currentIndex + 1) / _activities.length;
      _playCurrentAudio();
    } else {
      _finishLesson();
    }
  }

  void _finishLesson() async {
    if (_currentActivityType == LessonType.vocabSummary) {
      await _showSrsEvaluationDialog();
    }
    _completeLessonFinal();
  }

  Future<void> _showSrsEvaluationDialog() async {
    final summaryAct = _activities.firstWhere(
      (a) => a['type'] == LessonType.vocabSummary,
      orElse: () => {},
    );

    if (summaryAct.isEmpty || summaryAct['words'] == null) return;
    final List<dynamic> words = summaryAct['words'];

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Bạn nhớ những từ này thế nào?", 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: words.length,
            itemBuilder: (ctx, index) {
              final word = words[index];
              final String display = word['kanji'] != '' ? word['kanji'] : word['hiragana'];
              final int? vocabId = word['id'];

              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(display, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(word['meaning'] ?? ""),
                trailing: vocabId == null 
                  ? const Text("N/A") 
                  : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _srsActionBtn("Quên", Colors.red, vocabId, 0),
                      _srsActionBtn("Khó", Colors.orange, vocabId, 3),
                      _srsActionBtn("OK", Colors.green, vocabId, 5),
                    ],
                  ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("XÁC NHẬN", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _srsActionBtn(String label, Color color, int id, int quality) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(40, 30),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: () {
          DatabaseHelper.instance.updateVocabSrs(id, quality);
          SoundManager.instance.vibrate('light');
        },
        child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _completeLessonFinal() async {
    SoundManager.instance.vibrate('heavy');
    await UserProgress().addExp(19);
    await UserProgress().markLessonCompleted(widget.lessonId);
    if (!mounted) return;

    int total = _totalQuizCount > 0 ? _totalQuizCount : 1;
    int correct = _correctAnswers > 0 ? _correctAnswers : total;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonCompletionScreen(
          correctCount: correct,
          totalCount: total,
          expEarned: 19,
        ),
      ),
    );
    if (mounted) Navigator.pop(context, true);
  }

  void _showResultSheet(bool isCorrect, String correctAnswer, String userAnswer) {
    if (isCorrect) {
      _correctAnswers++;
      SoundManager.instance.vibrate('light');
      SoundManager.instance.speakJapanese("Seikai");
    } else {
      _wrongAnswers.add(correctAnswer.toLowerCase());
      SoundManager.instance.vibrate('error');
      SoundManager.instance.speakJapanese(correctAnswer);
    }

    Color typeColor = isCorrect ? const Color(0xFF58CC02) : const Color(0xFFFF4B4B);
    Color bgColor = isCorrect ? const Color(0xFFD7FFB8) : const Color(0xFFFFDFE0);
    String imageAsset = isCorrect ? 'assets/images/dog_happy.png' : 'assets/images/dog_sad.png';

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: bgColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Image.asset(imageAsset, width: 80, height: 80, errorBuilder: (_,__,___) => Icon(isCorrect ? Icons.check : Icons.close, size: 80, color: typeColor)),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isCorrect ? "Đúng rồi!" : "Sai rồi", style: TextStyle(color: typeColor, fontSize: 22, fontWeight: FontWeight.bold)),
                        if (!isCorrect) Text("Đáp án đúng: $correctAnswer", style: TextStyle(color: typeColor, fontSize: 18)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () { Navigator.pop(context); _nextActivity(); }, child: const Text("TIẾP TỤC"))),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_activities.isEmpty) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final activity = _activities[_currentIndex];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        title: LinearProgressIndicator(value: _progress, backgroundColor: Colors.grey[200], color: const Color(0xFF58CC02), minHeight: 12),
      ),
      body: SafeArea(child: Padding(padding: const EdgeInsets.all(20.0), child: _buildBody(activity))),
    );
  }

  Widget _buildBody(Map<String, dynamic> data) {
    final currentKey = ValueKey(_currentIndex);
    switch (data['type'] as LessonType) {
      case LessonType.vocabListIntro: return VocabListIntroView(words: data['words'], onNext: _nextActivity);
      case LessonType.grammarListIntro: return GrammarListIntroView(grammars: data['grammars'], onNext: _nextActivity);
      case LessonType.grammarStructure: return GrammarStructureView(data: data, onNext: _nextActivity);
      case LessonType.grammarUsage: return GrammarUsageView(data: data, onNext: _nextActivity);
      case LessonType.grammarExample: return GrammarExampleView(data: data, onNext: _nextActivity);
      case LessonType.flashCard: return FlashCardView(data: data, onNext: _nextActivity);
      case LessonType.imageQuiz: return _buildImageQuizView(data);
      case LessonType.quiz: return StandardQuizView(key: currentKey, data: data, onCheckResult: _showResultSheet);
      case LessonType.vocabSummary: return VocabSummaryView(words: data['words'], wrongAnswers: _wrongAnswers, onNext: _nextActivity, onExit: _finishLesson);
      default: return const SizedBox();
    }
  }

  Widget _buildImageQuizView(Map<String, dynamic> data) {
    return Column(
      children: [
        Text(data['question'], style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 30),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16),
            itemCount: data['options'].length,
            itemBuilder: (context, index) {
              final opt = data['options'][index];
              return GestureDetector(
                onTap: () => _showResultSheet(index == data['answerIndex'], data['options'][data['answerIndex']]['jp'], opt['jp']),
                child: Container(
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(16)),
                  child: Column(children: [
                    Expanded(child: Image.asset(opt['img'], fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.image))),
                    Text(opt['jp'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  ]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- MÀN HÌNH BẢNG CHỮ CÁI (DEMO) ---
  List<Map<String, dynamic>> _getHangAData() {
    return [
      {'type': LessonType.learn, 'char': 'あ', 'romaji': 'a', 'gif': 'assets/gifs/a.gif'},
      {'type': LessonType.quiz, 'question': 'Chọn "a"', 'options': ['あ', 'い', 'う', 'え'], 'answer': 'あ'},
    ];
  }
}

// ==========================================
// CÁC SUB-VIEW GIAO DIỆN
// ==========================================

class VocabListIntroView extends StatelessWidget {
  final List<dynamic> words;
  final VoidCallback onNext;
  const VocabListIntroView({super.key, required this.words, required this.onNext});
  @override Widget build(BuildContext context) { 
    return Column(children: [
      const Text("Từ vựng bài học", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 20),
      Expanded(child: ListView.builder(itemCount: words.length, itemBuilder: (ctx, i) => ListTile(title: Text(words[i]['kanji']), subtitle: Text(words[i]['meaning'])))), 
      ElevatedButton(onPressed: onNext, child: const Text("BẮT ĐẦU HỌC"))
    ]); 
  }
}

class GrammarListIntroView extends StatelessWidget {
  final List<dynamic> grammars;
  final VoidCallback onNext;
  const GrammarListIntroView({super.key, required this.grammars, required this.onNext});
  @override Widget build(BuildContext context) { return Column(children: [const Text("Ngữ pháp bài học", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Expanded(child: ListView.builder(itemCount: grammars.length, itemBuilder: (ctx, i) => ListTile(title: Text(grammars[i]['title'])))), ElevatedButton(onPressed: onNext, child: const Text("HỌC TIẾP"))]); }
}

class GrammarStructureView extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onNext;
  const GrammarStructureView({super.key, required this.data, required this.onNext});
  @override Widget build(BuildContext context) { return Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Text("Cấu trúc:", style: TextStyle(color: Colors.grey)), Text(data['formula'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), const SizedBox(height: 30), ElevatedButton(onPressed: onNext, child: const Text("OK"))]); }
}

class GrammarUsageView extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onNext;
  const GrammarUsageView({super.key, required this.data, required this.onNext});
  @override Widget build(BuildContext context) { return Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(data['title'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 20), const Text("Cách dùng: ..."), const SizedBox(height: 40), ElevatedButton(onPressed: onNext, child: const Text("TIẾP"))]); }
}

class GrammarExampleView extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onNext;
  const GrammarExampleView({super.key, required this.data, required this.onNext});
  @override Widget build(BuildContext context) { return Column(children: [if(data['img']!=null) Image.asset(data['img'], errorBuilder: (_,__,___) => const Icon(Icons.image)), const SizedBox(height: 20), Text(data['jp'], style: const TextStyle(fontSize: 24)), Text(data['rmj'], style: const TextStyle(color: Colors.grey)), const Spacer(), ElevatedButton(onPressed: onNext, child: const Text("ĐÃ HIỂU"))]); }
}

class FlashCardView extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onNext;
  const FlashCardView({super.key, required this.data, required this.onNext});
  @override Widget build(BuildContext context) { 
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      if(data['example_img']!=null) ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.asset(data['example_img'], height: 200, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.image, size: 100))), 
      const SizedBox(height: 20),
      Text(data['kanji'] != '' ? data['kanji'] : data['hiragana'], style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
      Text(data['meaning'], style: const TextStyle(fontSize: 22, color: Colors.blue)),
      const Spacer(),
      SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: onNext, child: const Text("TIẾP THEO")))
    ]); 
  }
}

class StandardQuizView extends StatelessWidget {
  final Map<String, dynamic> data;
  final Function(bool, String, String) onCheckResult;
  const StandardQuizView({super.key, required this.data, required this.onCheckResult});
  @override Widget build(BuildContext context) { 
    return Column(children: [
      Text(data['question'] ?? "Chọn đáp án đúng", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), 
      const SizedBox(height: 30),
      ... (data['options'] as List).map((o) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: SizedBox(width: double.infinity, height: 60, child: OutlinedButton(onPressed: () => onCheckResult(o == data['answer'], data['answer'], o), child: Text(o, style: const TextStyle(fontSize: 18)))),
      ))
    ]); 
  }
}

class VocabSummaryView extends StatelessWidget {
  final List<dynamic> words;
  final Set<String> wrongAnswers;
  final VoidCallback onNext;
  final VoidCallback onExit;
  const VocabSummaryView({super.key, required this.words, required this.wrongAnswers, required this.onNext, required this.onExit});
  @override Widget build(BuildContext context) { 
    return Column(children: [
      const Text("Tổng kết từ vựng", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), 
      const SizedBox(height: 20),
      Expanded(child: ListView.builder(itemCount: words.length, itemBuilder: (ctx, i) => ListTile(
        leading: Icon(wrongAnswers.contains(words[i]['kanji'].toLowerCase()) ? Icons.close : Icons.check, color: wrongAnswers.contains(words[i]['kanji'].toLowerCase()) ? Colors.red : Colors.green),
        title: Text(words[i]['kanji']), 
        subtitle: Text(words[i]['meaning'])
      ))), 
      SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: onExit, child: const Text("HOÀN THÀNH")))
    ]); 
  }
}

class LessonCompletionScreen extends StatelessWidget {
  final int correctCount;
  final int totalCount;
  final int expEarned;
  const LessonCompletionScreen({super.key, required this.correctCount, required this.totalCount, required this.expEarned});
  @override Widget build(BuildContext context) { 
    return Scaffold(body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.emoji_events, size: 120, color: Colors.amber), 
      const SizedBox(height: 20),
      Text("HÀNH THÀNH! +$expEarned EXP", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), 
      Text("Đúng $correctCount/$totalCount câu"),
      const SizedBox(height: 40),
      ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("ĐÓNG"))
    ]))); 
  }
}

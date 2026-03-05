import 'package:flutter/material.dart';
import 'sound_manager.dart';
import 'user_progress.dart';

// Đã cập nhật thêm 3 dạng bài mới
enum LessonType { learn, quiz, matching, imageQuiz, sentenceBuilder, kanjiDraw, listening, flashCard, vocabQuiz, vocabSummary}

class LessonScreen extends StatefulWidget {
  final String lessonId;
  final String lessonTitle;

  const LessonScreen({super.key, required this.lessonId, required this.lessonTitle});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  int _currentIndex = 0;
  double _progress = 0;
  List<Map<String, dynamic>> _activities = [];

  // Biến đếm số câu đúng để hiện kết quả cuối cùng
  int _correctAnswers = 0;
  int _totalQuizCount = 0;

  @override
  void initState() {
    super.initState();
    _loadLessonData();
    // Cập nhật tổng số câu đố để tính điểm
    _totalQuizCount = _activities.where((e) =>
        e['type'] == LessonType.quiz ||
        e['type'] == LessonType.matching ||
        e['type'] == LessonType.imageQuiz ||
        e['type'] == LessonType.sentenceBuilder ||
        e['type'] == LessonType.listening ||
            e['type'] == LessonType.vocabQuiz
    ).length;

    _playCurrentAudio();
  }

  void _playCurrentAudio() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    if (_activities.isEmpty) return;

    final activity = _activities[_currentIndex];
    if (activity['type'] == LessonType.learn) {
      SoundManager.instance.speakJapanese(activity['char']);
    } else if (activity['type'] == LessonType.sentenceBuilder) {
      SoundManager.instance.speakJapanese(activity['jp']);
    } else if (activity['type'] == LessonType.listening) {
      SoundManager.instance.speakJapanese(activity['answer']);
    }
  }

  // --- 1. HÀM LOAD DỮ LIỆU TỔNG HỢP ---
  void _loadLessonData() {
    switch (widget.lessonId) {
      case 'hang_a': _activities = _getHangAData(); break;
      case 'hang_ka': _activities = _getHangKaData(); break;
      case 'hang_sa': _activities = _getHangSaData(); break;
      case 'hang_ta': _activities = _getHangTaData(); break;
      case 'hang_na': _activities = _getHangNaData(); break;
      case 'hang_ha': _activities = _getHangHaData(); break;
      case 'hang_ma': _activities = _getHangMaData(); break;
      case 'hang_ya': _activities = _getHangYaData(); break;
      case 'hang_ra': _activities = _getHangRaData(); break;
      case 'hang_wa': _activities = _getHangWaNData(); break;
      case 'hang_all': _activities = _getFinalReviewData(); break;
      case 'cb1_lythuyet': _activities = _getCb1LyThuyetData(); break;
      case 'cb1_luyentap1': _activities = _getLuyenTap1Data(); break;
      case 'cb1_luyentap2': _activities = _getCb1LuyenTap2Data(); break;
      case 'cb1_luyentap3': _activities = _getCb1LuyenTap3Data(); break;
      case 'cb1_luyennoi': _activities = _getCb1LuyenNoiData(); break;
      case 'cb1_luyenviet': _activities = _getCb1LuyenVietData(); break;
      case 'cb1_ontap': _activities = _getCb1OnTapData(); break;
      default: _activities = [];
    }
  }

  // =======================================================
  // --- KHU VỰC DỮ LIỆU CÁC BÀI HỌC ---
  // =======================================================
  List<Map<String, dynamic>> _getLuyenTap1Data() {
    return [
      {
        'type': LessonType.flashCard,
        'kanji': '医者', 'hiragana': 'いしゃ', 'romaji': 'isha', 'meaning': 'bác sĩ',
        'example_img': 'assets/images/example_isha.png',
        'example_jp': 'シュミットさんは医者です。', 'example_rmj': 'Shumitto-san wa isha desu.', 'example_vn': 'Anh Schmidt là bác sĩ.'
      },
      {
        'type': LessonType.flashCard,
        'kanji': '会社員', 'hiragana': 'かいしゃいん', 'romaji': 'kaishain', 'meaning': 'nhân viên công ty',
        'example_img': 'assets/images/example_kaishain.png',
        'example_jp': 'ミラーさんは会社員です。', 'example_rmj': 'Mira-san wa kaishain desu.', 'example_vn': 'Anh Miller là nhân viên công ty.'
      },
      {
        'type': LessonType.vocabQuiz,
        'kanji': '学生',
        'hiragana': 'がくせい',
        'romaji': 'gakusei',
        'options': ['giáo viên', 'học sinh', 'kỹ sư', 'bác sĩ'],
        'answer': 'học sinh'
      },
      {
        'type': LessonType.vocabQuiz,
        'kanji': '先生',
        'hiragana': 'せんせい',
        'romaji': 'sensei',
        'options': ['nhân viên ngân hàng', 'nhà nghiên cứu', 'giáo viên', 'học sinh'],
        'answer': 'giáo viên'
      },
      {'type': LessonType.listening, 'options': ['いしゃ', 'かいしゃいん', 'エンジニア', 'ぎんこういん'], 'answer': 'エンジニア'},
      {'type': LessonType.matching, 'pairs': [
        {'left': 'Bác sĩ', 'right': '医者'},
        {'left': 'Giáo viên', 'right': '先生'},
        {'left': 'Học sinh', 'right': '学生'},
        {'left': 'Kỹ sư', 'right': 'エンジニア'},
        {'left': 'Nhân viên', 'right': '会社員'}
      ]},
    ];
  }

  // ==========================================
  // DỮ LIỆU PHẦN CƠ BẢN 1 (BÀI 1: GIỚI THIỆU BẢN THÂN)
  // ==========================================

  // 1. Lý thuyết (Từ vựng cơ bản)
  List<Map<String, dynamic>> _getCb1LyThuyetData() {
    return [
      {
        'type': LessonType.flashCard, 'kanji': '私', 'hiragana': 'わたし', 'romaji': 'watashi', 'meaning': 'Tôi',
        'example_img': 'assets/images/example_watashi.png',
        'example_jp': '私はマイクです。', 'example_rmj': 'Watashi wa Maiku desu.', 'example_vn': 'Tôi là Mike.'
      },
      {
        'type': LessonType.flashCard, 'kanji': 'あなた', 'hiragana': 'あなた', 'romaji': 'anata', 'meaning': 'Bạn / Anh / Chị',
        'example_img': 'assets/images/example_anata.png',
        'example_jp': 'あなたは学生ですか。', 'example_rmj': 'Anata wa gakusei desu ka.', 'example_vn': 'Bạn có phải là học sinh không?'
      },
      {
        'type': LessonType.flashCard, 'kanji': 'あの人', 'hiragana': 'あのひと', 'romaji': 'ano hito', 'meaning': 'Người kia, người đó',
        'example_img': 'assets/images/example_anohito.png',
        'example_jp': 'あの人は誰ですか。', 'example_rmj': 'Ano hito wa dare desu ka.', 'example_vn': 'Người kia là ai vậy?'
      },
      {'type': LessonType.vocabQuiz, 'kanji': '私', 'hiragana': 'わたし', 'romaji': 'watashi', 'options': ['bạn', 'người kia', 'tôi', 'ai'], 'answer': 'tôi'},
      {
        'type': LessonType.flashCard, 'kanji': '先生', 'hiragana': 'せんせい', 'romaji': 'sensei', 'meaning': 'Giáo viên',
        'example_img': 'assets/images/example_sensei.png',
        'example_jp': '先生、おはようございます。', 'example_rmj': 'Sensei, ohayou gozaimasu.', 'example_vn': 'Em chào thầy/cô ạ.'
      },
      {
        'type': LessonType.flashCard, 'kanji': '学生', 'hiragana': 'がくせい', 'romaji': 'gakusei', 'meaning': 'Học sinh, sinh viên',
        'example_img': 'assets/images/example_gakusei.png',
        'example_jp': '私は学生です。', 'example_rmj': 'Watashi wa gakusei desu.', 'example_vn': 'Tôi là học sinh.'
      },
      {
        'type': LessonType.flashCard, 'kanji': '会社員', 'hiragana': 'かいしゃいん', 'romaji': 'kaishain', 'meaning': 'Nhân viên công ty',
        'example_img': 'assets/images/example_kaishain.png',
        'example_jp': '父は会社員です。', 'example_rmj': 'Chichi wa kaishain desu.', 'example_vn': 'Bố tôi là nhân viên công ty.'
      },
      {
        'type': LessonType.flashCard, 'kanji': '医者', 'hiragana': 'いしゃ', 'romaji': 'isha', 'meaning': 'Bác sĩ',
        'example_img': 'assets/images/example_isha.png',
        'example_jp': '母は医者です。', 'example_rmj': 'Haha wa isha desu.', 'example_vn': 'Mẹ tôi là bác sĩ.'
      },
      {'type': LessonType.listening, 'options': ['わたし', 'あなた', 'がくせい', 'せんせい'], 'answer': 'せんせい'},
      {'type': LessonType.vocabQuiz, 'kanji': '会社員', 'hiragana': 'かいしゃいん', 'romaji': 'kaishain', 'options': ['bác sĩ', 'giáo viên', 'nhân viên công ty', 'học sinh'], 'answer': 'nhân viên công ty'},
      {'type': LessonType.vocabQuiz, 'kanji': '医者', 'hiragana': 'いしゃ', 'romaji': 'isha', 'options': ['kỹ sư', 'bác sĩ', 'ngân hàng', 'nhân viên'], 'answer': 'bác sĩ'},
      {
        'type': LessonType.vocabSummary,
        'words': [
          {'kanji': '私', 'romaji': 'watashi', 'meaning': 'Tôi'},
          {'kanji': 'あなた', 'romaji': 'anata', 'meaning': 'Bạn'},
          {'kanji': 'あの人', 'romaji': 'ano hito', 'meaning': 'Người kia'},
          {'kanji': '先生', 'romaji': 'sensei', 'meaning': 'Giáo viên'},
          {'kanji': '学生', 'romaji': 'gakusei', 'meaning': 'Học sinh'},
          {'kanji': '会社員', 'romaji': 'kaishain', 'meaning': 'Nhân viên công ty'},
          {'kanji': '医者', 'romaji': 'isha', 'meaning': 'Bác sĩ'},
        ]
      }
    ];
  }

  // 3. Luyện tập 2 (Ngữ pháp: N1 wa N2 desu / ja arimasen) - 10 bài
  List<Map<String, dynamic>> _getCb1LuyenTap2Data() {
    return [
      {
        'type': LessonType.sentenceBuilder,
        'jp': '私は学生です',
        'rmj': 'watashi wa gakusei desu',
        'words': ['tôi', 'là', 'học sinh', 'giáo viên', 'không phải'],
        'answer': 'tôi là học sinh',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': '山田さんは銀行員です',
        'rmj': 'Yamada-san wa ginkouin desu',
        'words': ['anh Yamada', 'là', 'nhân viên ngân hàng', 'bác sĩ', 'cũng'],
        'answer': 'anh Yamada là nhân viên ngân hàng',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': '私は先生じゃありません',
        'rmj': 'watashi wa sensei ja arimasen',
        'words': ['tôi', 'là', 'không phải', 'giáo viên', 'bác sĩ'],
        'answer': 'tôi không phải là giáo viên',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'サントスさんは医者じゃありません',
        'rmj': 'Santosu-san wa isha ja arimasen',
        'words': ['anh Santos', 'không phải', 'là', 'bác sĩ', 'học sinh'],
        'answer': 'anh Santos không phải là bác sĩ',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'ワットさんはイギリス人じゃありません',
        'rmj': 'Watto-san wa Igirisujin ja arimasen',
        'words': ['anh Watt', 'không phải', 'là', 'người Anh', 'người Mỹ'],
        'answer': 'anh Watt không phải là người Anh',
      },
      {'type': LessonType.listening, 'options': ['わたしはがくせいじゃありません', 'わたしはがくせいです', 'あなたはがくせいです', 'あのひとはがくせいです'], 'answer': 'わたしはがくせいじゃありません'},
      {'type': LessonType.listening, 'options': ['アメリカじんです', 'ベトナムじんです', 'にほんじんです', 'インドじんです'], 'answer': 'にほんじんです'},
      {'type': LessonType.quiz, 'question': 'Trợ từ đi sau chủ ngữ (Tôi, Anh ấy...) được đọc là gì?', 'options': ['ha', 'wa', 'ga', 'o'], 'answer': 'wa'},
      {'type': LessonType.quiz, 'question': 'Từ nào dùng để phủ định (Không phải là)?', 'options': ['です (desu)', 'ですか (desu ka)', 'じゃありません (ja arimasen)', 'も (mo)'], 'answer': 'じゃありません (ja arimasen)'},
      {'type': LessonType.quiz, 'question': 'Điền vào chỗ trống: ミラーさん ( ... ) アメリカじんです。', 'options': ['は (wa)', 'が (ga)', 'を (o)', 'に (ni)'], 'answer': 'は (wa)'},
    ];
  }

  // 4. Luyện tập 3 (Ngữ pháp: Câu hỏi KA, trợ từ MO, trợ từ NO) - 10 bài
  List<Map<String, dynamic>> _getCb1LuyenTap3Data() {
    return [
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'あなたは学生ですか',
        'rmj': 'anata wa gakusei desu ka',
        'words': ['bạn', 'có phải', 'là', 'học sinh', 'không'],
        'answer': 'bạn có phải là học sinh không',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'あの方はどなたですか',
        'rmj': 'ano kata wa donata desu ka',
        'words': ['vị kia', 'là', 'ai', 'vậy', 'người kia'],
        'answer': 'vị kia là ai vậy',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'ミラーさんも会社員です',
        'rmj': 'Mira-san mo kaishain desu',
        'words': ['anh Miller', 'cũng', 'là', 'nhân viên công ty', 'không phải'],
        'answer': 'anh Miller cũng là nhân viên công ty',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'グプタさんも学生ですか',
        'rmj': 'Guputa-san mo gakusei desu ka',
        'words': ['anh Gupta', 'cũng', 'có phải', 'là', 'học sinh', 'không'],
        'answer': 'anh Gupta cũng có phải là học sinh không',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': '私はFPT大学の学生です',
        'rmj': 'watashi wa FPT daigaku no gakusei desu',
        'words': ['tôi', 'là', 'học sinh', 'của', 'đại học FPT'],
        'answer': 'tôi là học sinh của đại học FPT',
      },
      {'type': LessonType.quiz, 'question': 'Trợ từ "Cũng" trong tiếng Nhật là gì?', 'options': ['は (wa)', 'も (mo)', 'の (no)', 'か (ka)'], 'answer': 'も (mo)'},
      {'type': LessonType.quiz, 'question': 'Trợ từ "Của" (Sở hữu) trong tiếng Nhật là gì?', 'options': ['は (wa)', 'も (mo)', 'の (no)', 'か (ka)'], 'answer': 'の (no)'},
      {'type': LessonType.listening, 'options': ['だれ', 'どなた', 'あのひと', 'あのかた'], 'answer': 'どなた'},
      {'type': LessonType.listening, 'options': ['なんさい', 'おいくつ', 'だれ', 'どなた'], 'answer': 'おいくつ'},
      {'type': LessonType.matching, 'pairs': [{'left': 'Tôi', 'right': 'わたし'}, {'left': 'Cũng', 'right': 'も (mo)'}, {'left': 'Của', 'right': 'の (no)'}, {'left': 'Câu hỏi', 'right': 'か (ka)'}, {'left': 'Ai (Lịch sự)', 'right': 'どなた'}]},
    ];
  }

  // 5. Luyện nói (Chào hỏi & Tuổi tác) - 10 bài
  List<Map<String, dynamic>> _getCb1LuyenNoiData() {
    return [
      {
        'type': LessonType.flashCard, 'kanji': '初めまして', 'hiragana': 'はじめまして', 'romaji': 'Hajimemashite', 'meaning': 'Rất hân hạnh được gặp (Lần đầu)',
        'example_img': 'assets/images/example_hajimemashite.png',
        'example_jp': '初めまして、マイクです。', 'example_rmj': 'Hajimemashite, Maiku desu.', 'example_vn': 'Rất hân hạnh, tôi là Mike.'
      },
      {
        'type': LessonType.flashCard, 'kanji': 'どうぞよろしく', 'hiragana': 'どうぞよろしく', 'romaji': 'Douzo yoroshiku', 'meaning': 'Rất mong được giúp đỡ',
        'example_img': 'assets/images/example_yoroshiku.png',
        'example_jp': 'どうぞよろしくお願いします。', 'example_rmj': 'Douzo yoroshiku onegaishimasu.', 'example_vn': 'Rất mong được sự giúp đỡ của bạn.'
      },
      {'type': LessonType.vocabQuiz, 'kanji': '〜から来ました', 'hiragana': '〜からきました', 'romaji': '~ kara kimashita', 'options': ['rất vui được gặp', 'tôi đến từ ~', 'tạm biệt', 'xin lỗi'], 'answer': 'tôi đến từ ~'},
      {'type': LessonType.vocabQuiz, 'kanji': '失礼ですが', 'hiragana': 'しつれいですが', 'romaji': 'shitsurei desu ga', 'options': ['xin lỗi, cho tôi hỏi', 'chào buổi sáng', 'chào mừng', 'không có chi'], 'answer': 'xin lỗi, cho tôi hỏi'},
      {'type': LessonType.vocabQuiz, 'kanji': 'お名前は？', 'hiragana': 'おなまえは？', 'romaji': 'o-namae wa?', 'options': ['bạn bao nhiêu tuổi', 'tên bạn là gì', 'bạn khỏe không', 'bạn làm nghề gì'], 'answer': 'tên bạn là gì'},
      {'type': LessonType.listening, 'options': ['はじめまして', 'おはよう', 'こんにちは', 'さようなら'], 'answer': 'はじめまして'},
      {'type': LessonType.listening, 'options': ['アメリカからきました', 'ベトナムからきました', 'にほんからきました', 'インドからきました'], 'answer': 'ベトナムからきました'},
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'ベトナムから来ました',
        'rmj': 'Betonamu kara kimashita',
        'words': ['tôi', 'đến từ', 'Việt Nam', 'Nhật Bản', 'nước Mỹ'],
        'answer': 'tôi đến từ Việt Nam',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'お名前は何ですか',
        'rmj': 'o-namae wa nan desu ka',
        'words': ['tên', 'của bạn', 'là gì', 'vậy', 'tuổi'],
        'answer': 'tên của bạn là gì vậy',
      },
      {'type': LessonType.quiz, 'question': 'Cách hỏi tuổi LỊCH SỰ nhất là?', 'options': ['なんさいですか (nan sai desu ka)', 'おいくつですか (o-ikutsu desu ka)', 'だれですか (dare desu ka)', 'どなたですか (donata desu ka)'], 'answer': 'おいくつですか (o-ikutsu desu ka)'},
    ];
  }

  // 6. Luyện viết (Kanji cơ bản bài 1) - 8 bài
  List<Map<String, dynamic>> _getCb1LuyenVietData() {
    return [
      {'type': LessonType.kanjiDraw, 'kanji_word': '私', 'kanji_target': '私', 'meaning': 'Tôi (Tư)', 'rmj': 'watashi'},
      {'type': LessonType.kanjiDraw, 'kanji_word': '人', 'kanji_target': '人', 'meaning': 'Người (Nhân)', 'rmj': 'hito / jin'},
      {'type': LessonType.kanjiDraw, 'kanji_word': '本', 'kanji_target': '本', 'meaning': 'Sách / Nguồn gốc (Bản)', 'rmj': 'hon'},
      {'type': LessonType.kanjiDraw, 'kanji_word': '日', 'kanji_target': '日', 'meaning': 'Mặt trời / Ngày (Nhật)', 'rmj': 'nichi / hi'},
      {'type': LessonType.kanjiDraw, 'kanji_word': '学', 'kanji_target': '学', 'meaning': 'Học', 'rmj': 'gaku'},
      {'type': LessonType.kanjiDraw, 'kanji_word': '生', 'kanji_target': '生', 'meaning': 'Sinh (Sống, Sinh ra)', 'rmj': 'sei'},
      {'type': LessonType.kanjiDraw, 'kanji_word': '先', 'kanji_target': '先', 'meaning': 'Trước (Tiên)', 'rmj': 'sen'},
      {'type': LessonType.matching, 'pairs': [
        {'left': 'Người', 'right': '人'},
        {'left': 'Sách', 'right': '本'},
        {'left': 'Ngày', 'right': '日'},
        {'left': 'Tiên', 'right': '先'},
        {'left': 'Sinh', 'right': '生'}
      ]},
    ];
  }

  // 7. Ôn tập (Boss Level - Thử thách chốt bài) - 15 bài
  List<Map<String, dynamic>> _getCb1OnTapData() {
    return [
      {'type': LessonType.listening, 'options': ['わたし', 'あなた', 'あのひと', 'だれ'], 'answer': 'あのひと'},
      {'type': LessonType.listening, 'options': ['いしゃ', 'かいしゃいん', 'エンジニア', 'ぎんこういん'], 'answer': 'かいしゃいん'},
      {'type': LessonType.quiz, 'question': 'Từ nào nghĩa là "Bác sĩ"?', 'options': ['いしゃ', 'せんせい', 'がくせい', 'かいしゃいん'], 'answer': 'いしゃ'},
      {'type': LessonType.quiz, 'question': 'Điền trợ từ: わたし ( ... ) がくせいです。', 'options': ['は (wa)', 'が (ga)', 'の (no)', 'も (mo)'], 'answer': 'は (wa)'},
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'イーさんはアメリカ人じゃありません',
        'rmj': 'I-san wa Amerikajin ja arimasen',
        'words': ['anh Lee', 'không phải', 'là', 'người Mỹ', 'người Nhật'],
        'answer': 'anh Lee không phải là người Mỹ',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'カリナさんもエンジニアですか',
        'rmj': 'Karina-san mo enjinia desu ka',
        'words': ['chị Karina', 'cũng', 'có phải', 'là kỹ sư', 'không'],
        'answer': 'chị Karina cũng có phải là kỹ sư không',
      },
      {'type': LessonType.vocabQuiz, 'kanji': '大学', 'hiragana': 'だいがく', 'romaji': 'daigaku', 'options': ['đại học', 'bệnh viện', 'công ty', 'trường cấp 3'], 'answer': 'đại học'},
      {'type': LessonType.vocabQuiz, 'kanji': '病院', 'hiragana': 'びょういん', 'romaji': 'byouin', 'options': ['bệnh viện', 'ngân hàng', 'công ty', 'siêu thị'], 'answer': 'bệnh viện'},
      {'type': LessonType.listening, 'options': ['はじめまして', 'おはよう', 'こんにちは', 'さようなら'], 'answer': 'はじめまして'},
      {'type': LessonType.quiz, 'question': 'Cách hỏi "Ai vậy?" LỊCH SỰ?', 'options': ['だれですか', 'どなたですか', 'なんさいですか', 'おいくつですか'], 'answer': 'どなたですか'},
      {'type': LessonType.kanjiDraw, 'kanji_word': '先生', 'kanji_target': '先', 'meaning': 'Tiên (trong Tiên sinh)', 'rmj': 'sen'},
      {'type': LessonType.matching, 'pairs': [
        {'left': 'Mỹ', 'right': 'アメリカ'},
        {'left': 'Anh', 'right': 'イギリス'},
        {'left': 'Nhật Bản', 'right': 'にほん'},
        {'left': 'Hàn Quốc', 'right': 'かんこく'},
        {'left': 'Trung Quốc', 'right': 'ちゅうごく'}
      ]},
      {'type': LessonType.matching, 'pairs': [
        {'left': 'Tôi', 'right': '私'},
        {'left': 'Người', 'right': '人'},
        {'left': 'Đại học', 'right': '大学'},
        {'left': 'Bệnh viện', 'right': '病院'},
        {'left': 'Ngân hàng', 'right': '銀行員'}
      ]},
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'どうぞよろしく',
        'rmj': 'douzo yoroshiku',
        'words': ['rất mong', 'được', 'giúp đỡ', 'xin chào', 'tạm biệt'],
        'answer': 'rất mong được giúp đỡ',
      },
      // Thẻ tổng kết toàn bộ từ vựng Bài 1
      {
        'type': LessonType.vocabSummary,
        'words': [
          {'kanji': '私', 'romaji': 'watashi', 'meaning': 'tôi'},
          {'kanji': 'あなた', 'romaji': 'anata', 'meaning': 'bạn'},
          {'kanji': 'あの人', 'romaji': 'ano hito', 'meaning': 'người kia'},
          {'kanji': '先生', 'romaji': 'sensei', 'meaning': 'giáo viên'},
          {'kanji': '学生', 'romaji': 'gakusei', 'meaning': 'học sinh'},
          {'kanji': '会社員', 'romaji': 'kaishain', 'meaning': 'nhân viên công ty'},
          {'kanji': '医者', 'romaji': 'isha', 'meaning': 'bác sĩ'},
          {'kanji': 'エンジニア', 'romaji': 'enjinia', 'meaning': 'kỹ sư'},
          {'kanji': '銀行員', 'romaji': 'ginkouin', 'meaning': 'nhân viên ngân hàng'},
          {'kanji': '大学', 'romaji': 'daigaku', 'meaning': 'đại học'},
          {'kanji': '病院', 'romaji': 'byouin', 'meaning': 'bệnh viện'},
          {'kanji': 'だれ/どなた', 'romaji': 'dare / donata', 'meaning': 'ai / vị nào'},
          {'kanji': 'ベトナム', 'romaji': 'Betonamu', 'meaning': 'Việt Nam'},
          {'kanji': '日本', 'romaji': 'Nihon', 'meaning': 'Nhật Bản'},
          {'kanji': '初めまして', 'romaji': 'hajimemashite', 'meaning': 'Rất hân hạnh'},
        ]
      }
    ];
  }

  List<Map<String, dynamic>> _getHangAData() => [
    {'type': LessonType.learn, 'char': 'あ', 'romaji': 'a', 'gif': 'assets/gifs/a.gif', 'isHiragana': true},
    {'type': LessonType.learn, 'char': 'ア', 'romaji': 'a (Katakana)', 'gif': 'assets/gifs/ak.gif', 'isHiragana': false},
    {'type': LessonType.learn, 'char': 'い', 'romaji': 'i', 'gif': 'assets/gifs/i.gif', 'isHiragana': true},
    {'type': LessonType.learn, 'char': 'イ', 'romaji': 'i (Katakana)', 'gif': 'assets/gifs/ik.gif', 'isHiragana': false},
    {'type': LessonType.listening, 'options': ['あ', 'い', 'う', 'え'], 'answer': 'あ'},
    {'type': LessonType.listening, 'options': ['ア', 'イ', 'ウ', 'エ'], 'answer': 'イ'},
    {'type': LessonType.listening, 'options': ['お', 'え', 'い', 'あ'], 'answer': 'お'},
    {'type': LessonType.quiz, 'question': 'Chữ nào là "i" (Hiragana)?', 'options': ['あ', 'い', 'ア', 'イ'], 'answer': 'い'},
    {'type': LessonType.matching, 'pairs': [{'left': 'あ', 'right': 'ア'}, {'left': 'い', 'right': 'イ'}]},
    {'type': LessonType.learn, 'char': 'う', 'romaji': 'u', 'gif': 'assets/gifs/u.gif', 'isHiragana': true},
    {'type': LessonType.learn, 'char': 'ウ', 'romaji': 'u (Katakana)', 'gif': 'assets/gifs/uk.gif', 'isHiragana': false},
    {'type': LessonType.learn, 'char': 'え', 'romaji': 'e', 'gif': 'assets/gifs/e.gif', 'isHiragana': true},
    {'type': LessonType.learn, 'char': 'エ', 'romaji': 'e (Katakana)', 'gif': 'assets/gifs/ek.gif', 'isHiragana': false},
    {'type': LessonType.quiz, 'question': 'Chữ nào là "E" (Katakana)?', 'options': ['エ', 'オ', 'え', 'う'], 'answer': 'エ'},
    {'type': LessonType.matching, 'pairs': [{'left': 'う', 'right': 'ウ'}, {'left': 'え', 'right': 'エ'}]},
    {'type': LessonType.learn, 'char': 'お', 'romaji': 'o', 'gif': 'assets/gifs/o.gif', 'isHiragana': true},
    {'type': LessonType.learn, 'char': 'オ', 'romaji': 'o (Katakana)', 'gif': 'assets/gifs/ok.gif', 'isHiragana': false},
    {'type': LessonType.matching, 'pairs': [{'left': 'あ', 'right': 'ア'}, {'left': 'い', 'right': 'イ'}, {'left': 'う', 'right': 'ウ'}, {'left': 'え', 'right': 'エ'}, {'left': 'お', 'right': 'オ'}]},
  ];

  List<Map<String, dynamic>> _getHangKaData() {
    return [
      {'type': LessonType.learn, 'char': 'か', 'romaji': 'ka', 'gif': 'assets/gifs/ka.gif', 'isHiragana': true},
      {'type': LessonType.learn, 'char': 'カ', 'romaji': 'ka (Katakana)', 'gif': 'assets/gifs/kak.gif', 'isHiragana': false},
      {'type': LessonType.learn, 'char': 'き', 'romaji': 'ki', 'gif': 'assets/gifs/ki.gif', 'isHiragana': true},
      {'type': LessonType.learn, 'char': 'キ', 'romaji': 'ki (Katakana)', 'gif': 'assets/gifs/kik.gif', 'isHiragana': false},

      // --- Bài tập Nghe Hàng Ka ---
      {'type': LessonType.listening, 'options': ['か', 'き', 'く', 'け'], 'answer': 'か'},
      {'type': LessonType.listening, 'options': ['カ', 'キ', 'ク', 'ケ'], 'answer': 'キ'},
      {'type': LessonType.listening, 'options': ['こ', 'け', 'く', 'き'], 'answer': 'こ'},
      // -----------------------------

      {'type': LessonType.quiz, 'question': 'Chữ nào là "Ki" (Hiragana)?', 'options': ['か', 'き', 'く', 'け'], 'answer': 'き'},
      {'type': LessonType.matching, 'pairs': [{'left': 'か', 'right': 'カ'}, {'left': 'き', 'right': 'キ'}]},
      {'type': LessonType.learn, 'char': 'く', 'romaji': 'ku', 'gif': 'assets/gifs/ku.gif', 'isHiragana': true},
      {'type': LessonType.learn, 'char': 'ク', 'romaji': 'ku (Katakana)', 'gif': 'assets/gifs/kuk.gif', 'isHiragana': false},
      {'type': LessonType.learn, 'char': 'け', 'romaji': 'ke', 'gif': 'assets/gifs/ke.gif', 'isHiragana': true},
      {'type': LessonType.learn, 'char': 'ケ', 'romaji': 'ke (Katakana)', 'gif': 'assets/gifs/kek.gif', 'isHiragana': false},
      {'type': LessonType.quiz, 'question': 'Chữ nào là "Ku" (Katakana)?', 'options': ['ク', 'シ', 'ツ', 'ソ'], 'answer': 'ク'},
      {'type': LessonType.matching, 'pairs': [{'left': 'く', 'right': 'ク'}, {'left': 'け', 'right': 'ケ'}]},
      {'type': LessonType.learn, 'char': 'こ', 'romaji': 'ko', 'gif': 'assets/gifs/ko.gif', 'isHiragana': true},
      {'type': LessonType.learn, 'char': 'コ', 'romaji': 'ko (Katakana)', 'gif': 'assets/gifs/kok.gif', 'isHiragana': false},
      {'type': LessonType.quiz, 'question': 'Chọn chữ "Ke" (Hiragana)', 'options': ['け', 'い', 'は', 'ほ'], 'answer': 'け'},
      {'type': LessonType.matching, 'pairs': [{'left': 'か', 'right': 'カ'}, {'left': 'き', 'right': 'キ'}, {'left': 'く', 'right': 'ク'}, {'left': 'け', 'right': 'ケ'}, {'left': 'こ', 'right': 'コ'}]},
    ];
  }

  List<Map<String, dynamic>> _getHangSaData() {
    return [
      {'type': LessonType.learn, 'char': 'さ', 'romaji': 'sa', 'gif': 'assets/gifs/sa.gif', 'isHiragana': true},
      {'type': LessonType.learn, 'char': 'サ', 'romaji': 'sa (Katakana)', 'gif': 'assets/gifs/sak.gif', 'isHiragana': false},
      {'type': LessonType.learn, 'char': 'し', 'romaji': 'shi', 'gif': 'assets/gifs/shi.gif', 'isHiragana': true},
      {'type': LessonType.learn, 'char': 'シ', 'romaji': 'shi (Katakana)', 'gif': 'assets/gifs/shik.gif', 'isHiragana': false},
      {'type': LessonType.listening, 'options': ['さ', 'し', 'す', 'せ'], 'answer': 'さ'},
      {'type': LessonType.matching, 'pairs': [{'left': 'さ', 'right': 'サ'}, {'left': 'し', 'right': 'シ'}]},

      {'type': LessonType.learn, 'char': 'す', 'romaji': 'su', 'gif': 'assets/gifs/su.gif', 'isHiragana': true},
      {'type': LessonType.learn, 'char': 'ス', 'romaji': 'su (Katakana)', 'gif': 'assets/gifs/suk.gif', 'isHiragana': false},
      {'type': LessonType.learn, 'char': 'せ', 'romaji': 'se', 'gif': 'assets/gifs/se.gif', 'isHiragana': true},
      {'type': LessonType.learn, 'char': 'セ', 'romaji': 'se (Katakana)', 'gif': 'assets/gifs/sek.gif', 'isHiragana': false},
      {'type': LessonType.quiz, 'question': 'Chữ nào là "Shi" (Katakana)?', 'options': ['シ', 'ツ', 'ソ', 'ン'], 'answer': 'シ'},
      {'type': LessonType.listening, 'options': ['サ', 'シ', 'ス', 'セ'], 'answer': 'ス'},
      {'type': LessonType.matching, 'pairs': [{'left': 'す', 'right': 'ス'}, {'left': 'せ', 'right': 'セ'}]},

      {'type': LessonType.learn, 'char': 'そ', 'romaji': 'so', 'gif': 'assets/gifs/so.gif', 'isHiragana': true},
      {'type': LessonType.learn, 'char': 'ソ', 'romaji': 'so (Katakana)', 'gif': 'assets/gifs/sok.gif', 'isHiragana': false},
      {'type': LessonType.listening, 'options': ['そ', 'せ', 'す', 'し'], 'answer': 'そ'},
      {'type': LessonType.quiz, 'question': 'Chọn chữ "So" (Hiragana)', 'options': ['そ', 'て', 'と', 'を'], 'answer': 'そ'},
      {'type': LessonType.matching, 'pairs': [{'left': 'さ', 'right': 'サ'}, {'left': 'し', 'right': 'シ'}, {'left': 'す', 'right': 'ス'}, {'left': 'せ', 'right': 'セ'}, {'left': 'そ', 'right': 'ソ'}]},
    ];
  }

  List<Map<String, dynamic>> _getHangTaData() {
    return [
      {'type': LessonType.learn, 'char': 'た', 'romaji': 'ta', 'gif': 'assets/gifs/ta.gif', 'isHiragana': true},
      {'type': LessonType.learn, 'char': 'タ', 'romaji': 'ta (Katakana)', 'gif': 'assets/gifs/tak.gif', 'isHiragana': false},
      {'type': LessonType.learn, 'char': 'ち', 'romaji': 'chi', 'gif': 'assets/gifs/chi.gif', 'isHiragana': true},
      {'type': LessonType.learn, 'char': 'チ', 'romaji': 'chi (Katakana)', 'gif': 'assets/gifs/chik.gif', 'isHiragana': false},
      {'type': LessonType.listening, 'options': ['た', 'ち', 'つ', 'て'], 'answer': 'た'},
      {'type': LessonType.matching, 'pairs': [{'left': 'た', 'right': 'タ'}, {'left': 'ち', 'right': 'チ'}]},

      {'type': LessonType.learn, 'char': 'つ', 'romaji': 'tsu', 'gif': 'assets/gifs/tsu.gif', 'isHiragana': true},
      {'type': LessonType.learn, 'char': 'ツ', 'romaji': 'tsu (Katakana)', 'gif': 'assets/gifs/tsuk.gif', 'isHiragana': false},
      {'type': LessonType.learn, 'char': 'て', 'romaji': 'te', 'gif': 'assets/gifs/te.gif', 'isHiragana': true},
      {'type': LessonType.learn, 'char': 'テ', 'romaji': 'te (Katakana)', 'gif': 'assets/gifs/tek.gif', 'isHiragana': false},
      {'type': LessonType.quiz, 'question': 'Chữ nào là "Tsu" (Hiragana)?', 'options': ['つ', 'う', 'し', 'て'], 'answer': 'つ'},
      {'type': LessonType.listening, 'options': ['タ', 'チ', 'ツ', 'テ'], 'answer': 'チ'},
      {'type': LessonType.matching, 'pairs': [{'left': 'つ', 'right': 'ツ'}, {'left': 'て', 'right': 'テ'}]},

      {'type': LessonType.learn, 'char': 'と', 'romaji': 'to', 'gif': 'assets/gifs/to.gif', 'isHiragana': true},
      {'type': LessonType.learn, 'char': 'ト', 'romaji': 'to (Katakana)', 'gif': 'assets/gifs/tok.gif', 'isHiragana': false},
      {'type': LessonType.listening, 'options': ['と', 'て', 'つ', 'ち'], 'answer': 'と'},
      {'type': LessonType.quiz, 'question': 'Chọn chữ "Te" (Katakana)', 'options': ['テ', 'チ', 'シ', 'ツ'], 'answer': 'テ'},
      {'type': LessonType.matching, 'pairs': [{'left': 'た', 'right': 'タ'}, {'left': 'ち', 'right': 'チ'}, {'left': 'つ', 'right': 'ツ'}, {'left': 'て', 'right': 'テ'}, {'left': 'と', 'right': 'ト'}]},
    ];
  }

  List<Map<String, dynamic>> _getHangNaData() {
    return [
      {'type': LessonType.learn, 'char': 'な', 'romaji': 'na', 'gif': 'assets/gifs/na.gif', 'isHiragana': true},
      {'type': LessonType.learn, 'char': 'ナ', 'romaji': 'na (Katakana)', 'gif': 'assets/gifs/nak.gif', 'isHiragana': false},
      {'type': LessonType.learn, 'char': 'に', 'romaji': 'ni', 'gif': 'assets/gifs/ni.gif', 'isHiragana': true},
      {'type': LessonType.learn, 'char': 'ニ', 'romaji': 'ni (Katakana)', 'gif': 'assets/gifs/nik.gif', 'isHiragana': false},
      {'type': LessonType.listening, 'options': ['な', 'に', 'ぬ', 'ね'], 'answer': 'な'},
      {'type': LessonType.matching, 'pairs': [{'left': 'な', 'right': 'ナ'}, {'left': 'に', 'right': 'ニ'}]},

      {'type': LessonType.learn, 'char': 'ぬ', 'romaji': 'nu', 'gif': 'assets/gifs/nu.gif', 'isHiragana': true},
      {'type': LessonType.learn, 'char': 'ヌ', 'romaji': 'nu (Katakana)', 'gif': 'assets/gifs/nuk.gif', 'isHiragana': false},
      {'type': LessonType.learn, 'char': 'ね', 'romaji': 'ne', 'gif': 'assets/gifs/ne.gif', 'isHiragana': true},
      {'type': LessonType.learn, 'char': 'ネ', 'romaji': 'ne (Katakana)', 'gif': 'assets/gifs/nek.gif', 'isHiragana': false},
      {'type': LessonType.quiz, 'question': 'Chữ nào là "Ni" (Katakana)?', 'options': ['ニ', 'こ', 'ネ', 'ミ'], 'answer': 'ニ'},
      {'type': LessonType.listening, 'options': ['ナ', 'ニ', 'ヌ', 'ネ'], 'answer': 'ヌ'},
      {'type': LessonType.matching, 'pairs': [{'left': 'ぬ', 'right': 'ヌ'}, {'left': 'ね', 'right': 'ネ'}]},

      {'type': LessonType.learn, 'char': 'の', 'romaji': 'no', 'gif': 'assets/gifs/no.gif', 'isHiragana': true},
      {'type': LessonType.learn, 'char': 'ノ', 'romaji': 'no (Katakana)', 'gif': 'assets/gifs/nok.gif', 'isHiragana': false},
      {'type': LessonType.listening, 'options': ['の', 'ね', 'ぬ', 'に'], 'answer': 'の'},
      {'type': LessonType.matching, 'pairs': [{'left': 'な', 'right': 'ナ'}, {'left': 'に', 'right': 'ニ'}, {'left': 'ぬ', 'right': 'ヌ'}, {'left': 'ね', 'right': 'ネ'}, {'left': 'の', 'right': 'ノ'}]},
    ];
  }

  List<Map<String, dynamic>> _getHangHaData() {
    return [
      {'type': LessonType.learn, 'char': 'は', 'romaji': 'ha', 'gif': 'assets/gifs/ha.gif', 'isHiragana': true},
      {'type': LessonType.learn, 'char': 'ハ', 'romaji': 'ha (Katakana)', 'gif': 'assets/gifs/hak.gif', 'isHiragana': false},
      {'type': LessonType.learn, 'char': 'ひ', 'romaji': 'hi', 'gif': 'assets/gifs/hi.gif', 'isHiragana': true},
      {'type': LessonType.learn, 'char': 'ヒ', 'romaji': 'hi (Katakana)', 'gif': 'assets/gifs/hik.gif', 'isHiragana': false},
      {'type': LessonType.listening, 'options': ['は', 'ひ', 'ふ', 'へ'], 'answer': 'は'},
      {'type': LessonType.matching, 'pairs': [{'left': 'は', 'right': 'ハ'}, {'left': 'ひ', 'right': 'ヒ'}]},

      {'type': LessonType.learn, 'char': 'ふ', 'romaji': 'fu', 'gif': 'assets/gifs/fu.gif', 'isHiragana': true},
      {'type': LessonType.learn, 'char': 'フ', 'romaji': 'fu (Katakana)', 'gif': 'assets/gifs/fuk.gif', 'isHiragana': false},
      {'type': LessonType.learn, 'char': 'へ', 'romaji': 'he', 'gif': 'assets/gifs/he.gif', 'isHiragana': true},
      {'type': LessonType.learn, 'char': 'ヘ', 'romaji': 'he (Katakana)', 'gif': 'assets/gifs/hek.gif', 'isHiragana': false},
      {'type': LessonType.quiz, 'question': 'Chữ nào là "Fu" (Hiragana)?', 'options': ['ふ', 'う', 'く', 'む'], 'answer': 'ふ'},
      {'type': LessonType.listening, 'options': ['ハ', 'ヒ', 'フ', 'ヘ'], 'answer': 'ヒ'},
      {'type': LessonType.matching, 'pairs': [{'left': 'ふ', 'right': 'フ'}, {'left': 'へ', 'right': 'ヘ'}]},

      {'type': LessonType.learn, 'char': 'ほ', 'romaji': 'ho', 'gif': 'assets/gifs/ho.gif', 'isHiragana': true},
      {'type': LessonType.learn, 'char': 'ホ', 'romaji': 'ho (Katakana)', 'gif': 'assets/gifs/hok.gif', 'isHiragana': false},
      {'type': LessonType.listening, 'options': ['ほ', 'へ', 'ふ', 'ひ'], 'answer': 'ほ'},
      {'type': LessonType.quiz, 'question': 'Chọn chữ "Ho" (Katakana)', 'options': ['ホ', 'オ', '木', 'ネ'], 'answer': 'ホ'},
      {'type': LessonType.matching, 'pairs': [{'left': 'は', 'right': 'ハ'}, {'left': 'ひ', 'right': 'ヒ'}, {'left': 'ふ', 'right': 'フ'}, {'left': 'へ', 'right': 'ヘ'}, {'left': 'ほ', 'right': 'ホ'}]},
    ];
  }

  List<Map<String, dynamic>> _getHangMaData() {
    return [
      {'type': LessonType.learn, 'char': 'ま', 'romaji': 'ma', 'gif': 'assets/gifs/ma.gif', 'isHiragana': true},
      {'type': LessonType.learn, 'char': 'マ', 'romaji': 'ma (Katakana)', 'gif': 'assets/gifs/mak.gif', 'isHiragana': false},
      {'type': LessonType.learn, 'char': 'み', 'romaji': 'mi', 'gif': 'assets/gifs/mi.gif', 'isHiragana': true},
      {'type': LessonType.learn, 'char': 'ミ', 'romaji': 'mi (Katakana)', 'gif': 'assets/gifs/mik.gif', 'isHiragana': false},
      {'type': LessonType.listening, 'options': ['ま', 'み', 'む', 'め'], 'answer': 'ま'},
      {'type': LessonType.matching, 'pairs': [{'left': 'ま', 'right': 'マ'}, {'left': 'み', 'right': 'ミ'}]},

      {'type': LessonType.learn, 'char': 'む', 'romaji': 'mu', 'gif': 'assets/gifs/mu.gif', 'isHiragana': true},
      {'type': LessonType.learn, 'char': 'ム', 'romaji': 'mu (Katakana)', 'gif': 'assets/gifs/muk.gif', 'isHiragana': false},
      {'type': LessonType.learn, 'char': 'め', 'romaji': 'me', 'gif': 'assets/gifs/me.gif', 'isHiragana': true},
      {'type': LessonType.learn, 'char': 'メ', 'romaji': 'me (Katakana)', 'gif': 'assets/gifs/mek.gif', 'isHiragana': false},
      {'type': LessonType.quiz, 'question': 'Chữ nào là "Me" (Hiragana)?', 'options': ['め', 'ぬ', 'ね', 'の'], 'answer': 'め'},
      {'type': LessonType.listening, 'options': ['マ', 'ミ', 'ム', 'メ'], 'answer': 'ミ'},
      {'type': LessonType.matching, 'pairs': [{'left': 'む', 'right': 'ム'}, {'left': 'め', 'right': 'メ'}]},

      {'type': LessonType.learn, 'char': 'も', 'romaji': 'mo', 'gif': 'assets/gifs/mo.gif', 'isHiragana': true},
      {'type': LessonType.learn, 'char': 'モ', 'romaji': 'mo (Katakana)', 'gif': 'assets/gifs/mok.gif', 'isHiragana': false},
      {'type': LessonType.listening, 'options': ['も', 'め', 'む', 'み'], 'answer': 'も'},
      {'type': LessonType.matching, 'pairs': [{'left': 'ま', 'right': 'マ'}, {'left': 'み', 'right': 'ミ'}, {'left': 'む', 'right': 'ム'}, {'left': 'め', 'right': 'メ'}, {'left': 'も', 'right': 'モ'}]},
    ];
  }

  List<Map<String, dynamic>> _getHangYaData() {
    return [
      {'type': LessonType.learn, 'char': 'や', 'romaji': 'ya', 'gif': 'assets/gifs/ya.gif', 'isHiragana': true},
      {'type': LessonType.learn, 'char': 'ヤ', 'romaji': 'ya (Katakana)', 'gif': 'assets/gifs/yak.gif', 'isHiragana': false},
      {'type': LessonType.learn, 'char': 'ゆ', 'romaji': 'yu', 'gif': 'assets/gifs/yu.gif', 'isHiragana': true},
      {'type': LessonType.learn, 'char': 'ユ', 'romaji': 'yu (Katakana)', 'gif': 'assets/gifs/yuk.gif', 'isHiragana': false},
      {'type': LessonType.listening, 'options': ['や', 'ゆ', 'よ', 'わ'], 'answer': 'や'},
      {'type': LessonType.matching, 'pairs': [{'left': 'や', 'right': 'ヤ'}, {'left': 'ゆ', 'right': 'ユ'}]},

      {'type': LessonType.learn, 'char': 'よ', 'romaji': 'yo', 'gif': 'assets/gifs/yo.gif', 'isHiragana': true},
      {'type': LessonType.learn, 'char': 'ヨ', 'romaji': 'yo (Katakana)', 'gif': 'assets/gifs/yok.gif', 'isHiragana': false},
      {'type': LessonType.quiz, 'question': 'Chữ nào là "Yu" (Katakana)?', 'options': ['ユ', 'コ', 'ヨ', 'ア'], 'answer': 'ユ'},
      {'type': LessonType.listening, 'options': ['ヤ', 'ユ', 'ヨ', 'ワ'], 'answer': 'ヨ'},
      {'type': LessonType.matching, 'pairs': [{'left': 'や', 'right': 'ヤ'}, {'left': 'ゆ', 'right': 'ユ'}, {'left': 'よ', 'right': 'ヨ'}]},
    ];
  }

  List<Map<String, dynamic>> _getHangRaData() {
    return [
      {'type': LessonType.learn, 'char': 'ら', 'romaji': 'ra', 'gif': 'assets/gifs/ra.gif', 'isHiragana': true},
      {'type': LessonType.learn, 'char': 'ラ', 'romaji': 'ra (Katakana)', 'gif': 'assets/gifs/rak.gif', 'isHiragana': false},
      {'type': LessonType.learn, 'char': 'り', 'romaji': 'ri', 'gif': 'assets/gifs/ri.gif', 'isHiragana': true},
      {'type': LessonType.learn, 'char': 'リ', 'romaji': 'ri (Katakana)', 'gif': 'assets/gifs/rik.gif', 'isHiragana': false},
      {'type': LessonType.listening, 'options': ['ら', 'り', 'る', 'れ'], 'answer': 'ら'},
      {'type': LessonType.matching, 'pairs': [{'left': 'ら', 'right': 'ラ'}, {'left': 'り', 'right': 'リ'}]},

      {'type': LessonType.learn, 'char': 'る', 'romaji': 'ru', 'gif': 'assets/gifs/ru.gif', 'isHiragana': true},
      {'type': LessonType.learn, 'char': 'ル', 'romaji': 'ru (Katakana)', 'gif': 'assets/gifs/ruk.gif', 'isHiragana': false},
      {'type': LessonType.learn, 'char': 'れ', 'romaji': 're', 'gif': 'assets/gifs/re.gif', 'isHiragana': true},
      {'type': LessonType.learn, 'char': 'レ', 'romaji': 're (Katakana)', 'gif': 'assets/gifs/rek.gif', 'isHiragana': false},
      {'type': LessonType.quiz, 'question': 'Chữ nào là "Ru" (Hiragana)?', 'options': ['る', 'ろ', 'そ', 'ゐ'], 'answer': 'る'},
      {'type': LessonType.listening, 'options': ['ラ', 'リ', 'ル', 'レ'], 'answer': 'リ'},
      {'type': LessonType.matching, 'pairs': [{'left': 'る', 'right': 'ル'}, {'left': 'れ', 'right': 'レ'}]},

      {'type': LessonType.learn, 'char': 'ろ', 'romaji': 'ro', 'gif': 'assets/gifs/ro.gif', 'isHiragana': true},
      {'type': LessonType.learn, 'char': 'ロ', 'romaji': 'ro (Katakana)', 'gif': 'assets/gifs/rok.gif', 'isHiragana': false},
      {'type': LessonType.listening, 'options': ['ろ', 'れ', 'る', 'り'], 'answer': 'ろ'},
      {'type': LessonType.matching, 'pairs': [{'left': 'ら', 'right': 'ラ'}, {'left': 'り', 'right': 'リ'}, {'left': 'る', 'right': 'ル'}, {'left': 'れ', 'right': 'レ'}, {'left': 'ろ', 'right': 'ロ'}]},
    ];
  }

  List<Map<String, dynamic>> _getHangWaNData() {
    return [
      {'type': LessonType.learn, 'char': 'わ', 'romaji': 'wa', 'gif': 'assets/gifs/wa.gif', 'isHiragana': true},
      {'type': LessonType.learn, 'char': 'ワ', 'romaji': 'wa (Katakana)', 'gif': 'assets/gifs/wak.gif', 'isHiragana': false},
      {'type': LessonType.learn, 'char': 'を', 'romaji': 'wo', 'gif': 'assets/gifs/wo.gif', 'isHiragana': true},
      {'type': LessonType.learn, 'char': 'ヲ', 'romaji': 'wo (Katakana)', 'gif': 'assets/gifs/wok.gif', 'isHiragana': false},
      {'type': LessonType.listening, 'options': ['わ', 'を', 'ん', 'や'], 'answer': 'わ'},
      {'type': LessonType.matching, 'pairs': [{'left': 'わ', 'right': 'ワ'}, {'left': 'を', 'right': 'ヲ'}]},

      {'type': LessonType.learn, 'char': 'ん', 'romaji': 'n', 'gif': 'assets/gifs/n.gif', 'isHiragana': true},
      {'type': LessonType.learn, 'char': 'ン', 'romaji': 'n (Katakana)', 'gif': 'assets/gifs/nk.gif', 'isHiragana': false},
      {'type': LessonType.quiz, 'question': 'Chữ nào là "Wo" (Hiragana)?', 'options': ['を', 'わ', 'ち', 'ん'], 'answer': 'を'},
      {'type': LessonType.listening, 'options': ['ワ', 'ヲ', 'ン', 'ヨ'], 'answer': 'ン'},
      {'type': LessonType.matching, 'pairs': [{'left': 'わ', 'right': 'ワ'}, {'left': 'を', 'right': 'ヲ'}, {'left': 'ん', 'right': 'ン'}]},
    ];
  }

  List<Map<String, dynamic>> _getFinalReviewData() {
    return [
      // 1. Khởi động với trắc nghiệm cơ bản
      {'type': LessonType.quiz, 'question': 'Chữ nào là "O" (Hiragana)?', 'options': ['あ', 'お', 'す', 'む'], 'answer': 'お'},
      {'type': LessonType.quiz, 'question': 'Chữ nào là "Ki" (Katakana)?', 'options': ['キ', 'チ', 'ミ', 'ニ'], 'answer': 'キ'},

      // 2. Bài nghe chữ Hiragana dễ nhầm
      {'type': LessonType.listening, 'options': ['ぬ', 'ね', 'め', 'の'], 'answer': 'め'}, // Nghe 'Me'
      {'type': LessonType.listening, 'options': ['わ', 'れ', 'ね', 'る'], 'answer': 'れ'}, // Nghe 'Re'

      // 3. Ghép thẻ Hiragana & Katakana (Cấp độ 1)
      {'type': LessonType.matching, 'pairs': [
        {'left': 'あ', 'right': 'ア'},
        {'left': 'か', 'right': 'カ'},
        {'left': 'さ', 'right': 'サ'},
        {'left': 'た', 'right': 'タ'},
        {'left': 'な', 'right': 'ナ'}
      ]},

      // 4. Trắc nghiệm phân biệt Katakana
      {'type': LessonType.quiz, 'question': 'Chọn chữ "N" (Katakana)', 'options': ['シ', 'ツ', 'ソ', 'ン'], 'answer': 'ン'},
      {'type': LessonType.quiz, 'question': 'Chọn chữ "Shi" (Katakana)', 'options': ['シ', 'ツ', 'ソ', 'ン'], 'answer': 'シ'},

      // 5. Bài nghe Katakana
      {'type': LessonType.listening, 'options': ['ハ', 'ヒ', 'フ', 'ヘ'], 'answer': 'フ'}, // Nghe 'Fu'
      {'type': LessonType.listening, 'options': ['マ', 'ミ', 'ム', 'メ'], 'answer': 'ミ'}, // Nghe 'Mi'

      // 6. Ghép thẻ Hiragana & Katakana (Cấp độ 2)
      {'type': LessonType.matching, 'pairs': [
        {'left': 'は', 'right': 'ハ'},
        {'left': 'ま', 'right': 'マ'},
        {'left': 'や', 'right': 'ヤ'},
        {'left': 'ら', 'right': 'ラ'},
        {'left': 'わ', 'right': 'ワ'}
      ]},

      // 7. Chốt hạ bằng các chữ cái đặc biệt
      {'type': LessonType.quiz, 'question': 'Chữ nào là "Wo" (Hiragana)?', 'options': ['を', 'わ', 'ち', 'ん'], 'answer': 'を'},
      {'type': LessonType.listening, 'options': ['ら', 'り', 'る', 'れ'], 'answer': 'る'}, // Nghe 'Ru'

      // 8. Thử thách cuối cùng: Ghép thẻ toàn Katakana dễ nhầm
      {'type': LessonType.matching, 'pairs': [
        {'left': 'Shi', 'right': 'シ'},
        {'left': 'Tsu', 'right': 'ツ'},
        {'left': 'So', 'right': 'ソ'},
        {'left': 'N', 'right': 'ン'},
        {'left': 'Ku', 'right': 'ク'}
      ]},
    ];
  }

  // --- LOGIC CHUYỂN BÀI ---
  void _nextActivity() {
    if (_currentIndex < _activities.length - 1) {
      setState(() {
        _currentIndex++;
        _progress = (_currentIndex + 1) / _activities.length;
      });
      _playCurrentAudio();
    } else {
      _finishLesson();
    }
  }

  void _finishLesson() async {
    SoundManager.instance.vibrate('heavy');
    await UserProgress().addExp(19);
    await UserProgress().markLessonCompleted(widget.lessonId);
    int total = _totalQuizCount > 0 ? _totalQuizCount : 1;
    int correct = _correctAnswers > 0 ? _correctAnswers : total;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LessonCompletionScreen(
          correctCount: correct,
          totalCount: total,
          expEarned: 19,
        ),
      ),
      result: true,
    ).then((result) {
      if (mounted) Navigator.pop(context, true);
    });
  }

  void _showResultSheet(bool isCorrect, String correctAnswer, String userAnswer) {
    if (isCorrect) {
      _correctAnswers++;
      SoundManager.instance.vibrate('light');
      SoundManager.instance.speakJapanese("Seikai");
    } else {
      SoundManager.instance.vibrate('error');
      SoundManager.instance.speakJapanese(correctAnswer);
    }

    Color typeColor = isCorrect ? const Color(0xFF58CC02) : const Color(0xFFFF4B4B);
    Color bgColor = isCorrect ? const Color(0xFFD7FFB8) : const Color(0xFFFFDFE0);
    String title = isCorrect ? "Đúng rồi!" : "Sai rồi";
    String msg = isCorrect ? "Tuyệt vời! Tiếp tục nào." : "Đáp án đúng:";
    String imageAsset = isCorrect ? 'assets/images/dog_happy.png' : 'assets/images/dog_sad.png';

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.1),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(imageAsset, width: 80, height: 80, errorBuilder: (_,__,___) => Icon(isCorrect ? Icons.emoji_emotions : Icons.mood_bad, size: 80, color: typeColor)),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(title, style: TextStyle(color: typeColor, fontSize: 22, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: Icon(Icons.volume_up, color: typeColor),
                              onPressed: () => SoundManager.instance.speakJapanese(correctAnswer),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(msg, style: TextStyle(color: isCorrect ? typeColor : Colors.black54, fontSize: 16)),
                        if (!isCorrect)
                          Text(correctAnswer, style: TextStyle(color: typeColor, fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _nextActivity();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: typeColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("TIẾP TỤC", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
    if (_activities.isEmpty) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final activity = _activities[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.black54), onPressed: () => Navigator.pop(context)),
        title: LinearProgressIndicator(value: _progress, backgroundColor: Colors.grey[200], color: const Color(0xFF58CC02), minHeight: 12, borderRadius: BorderRadius.circular(6)),
        centerTitle: true, backgroundColor: Colors.white, elevation: 0,
      ),
      body: SafeArea(child: Padding(padding: const EdgeInsets.all(20.0), child: _buildBody(activity))),
    );
  }

  Widget _buildBody(Map<String, dynamic> data) {
    switch (data['type'] as LessonType) {
      case LessonType.learn: return _buildLearnView(data);
      case LessonType.quiz: return _buildQuizView(data);
      case LessonType.matching: return _buildMatchingView(data);
      case LessonType.imageQuiz: return _buildImageQuizView(data);
      case LessonType.listening: return _buildListeningView(data);
      case LessonType.sentenceBuilder:
        return SentenceBuilderView(
            data: data,
            onCheckResult: (isCorrect, correctAns, userAns) => _showResultSheet(isCorrect, correctAns, userAns)
        );
      case LessonType.kanjiDraw:
        return KanjiDrawView(data: data, onNext: _nextActivity);
      case LessonType.flashCard:
        return FlashCardView(data: data, onNext: _nextActivity);
      case LessonType.vocabQuiz:
        return VocabQuizView(
            data: data,
            onCheckResult: (isCorrect, correctAns, userAns) => _showResultSheet(isCorrect, correctAns, userAns)
        );
      case LessonType.vocabSummary:
        return VocabSummaryView(words: data['words'], onNext: _nextActivity, onExit: () => Navigator.pop(context));
      default: return const SizedBox();
    }
  }

  // CÁC GIAO DIỆN BÀI HỌC CŨ
  Widget _buildLearnView(Map<String, dynamic> data) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Tập viết chữ cái", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 30),
        Container(
          width: 250, height: 250,
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300, width: 2), borderRadius: BorderRadius.circular(20)),
          child: ClipRRect(borderRadius: BorderRadius.circular(18), child: Image.asset(data['gif'] ?? '', fit: BoxFit.contain, errorBuilder: (_,__,___)=> const Icon(Icons.image, size: 50))),
        ),
        const SizedBox(height: 20),
        Text(data['char'], style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Color(0xFF58CC02))),
        Text(data['romaji'], style: const TextStyle(fontSize: 24, color: Colors.grey)),
        IconButton(icon: const Icon(Icons.volume_up, size: 40, color: Color(0xFF58CC02)), onPressed: () => SoundManager.instance.speakJapanese(data['char'])),
        const Spacer(),
        SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () { SoundManager.instance.vibrate('light'); _nextActivity(); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF58CC02)), child: const Text("ĐÃ HIỂU", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))))
      ],
    );
  }

  Widget _buildQuizView(Map<String, dynamic> data) {
    return Column(
      children: [
        const Text("Chọn đáp án đúng", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: Text(data['question'], textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
            IconButton(onPressed: () => SoundManager.instance.speakJapanese(data['answer']), icon: const Icon(Icons.volume_up, color: Color(0xFF58CC02), size: 30)),
          ],
        ),
        const SizedBox(height: 30),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2, mainAxisSpacing: 15, crossAxisSpacing: 15, childAspectRatio: 1.1,
            children: (data['options'] as List<String>).map((opt) {
              return ElevatedButton(
                onPressed: () {
                  bool isCorrect = (opt == data['answer']);
                  _showResultSheet(isCorrect, data['answer'], opt);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.grey, width: 2)),
                ),
                child: Text(opt, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMatchingView(Map<String, dynamic> data) {
    return MatchingGame(
        pairs: data['pairs'],
        onCompleted: () {
          _correctAnswers++;
          _nextActivity();
        }
    );
  }

  // 1. GIAO DIỆN TRẮC NGHIỆM HÌNH ẢNH MỚI
  Widget _buildImageQuizView(Map<String, dynamic> data) {
    return Column(
      children: [
        const Text("Từ nào có nghĩa là", style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text(data['question'], style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 30),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.8,
            ),
            itemCount: data['options'].length,
            itemBuilder: (context, index) {
              final opt = data['options'][index];
              return GestureDetector(
                onTap: () {
                  bool isCorrect = (index == data['answerIndex']);
                  _showResultSheet(isCorrect, data['options'][data['answerIndex']]['jp'], opt['jp']);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                  child: Column(
                    children: [
                      // Hình ảnh
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                          child: Image.asset(opt['img'], fit: BoxFit.cover, width: double.infinity,
                              errorBuilder: (_,__,___) => Container(color: Colors.grey.shade100, child: const Icon(Icons.image, size: 50, color: Colors.grey))),
                        ),
                      ),
                      // Text tiếng Nhật + Romaji
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          children: [
                            Text(opt['jp'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text(opt['rmj'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // GIAO DIỆN BÀI TẬP NGHE CHỮ CÁI
  Widget _buildListeningView(Map<String, dynamic> data) {
    return Column(
      children: [
        const Text("Nghe và chọn chữ cái đúng", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),

        const SizedBox(height: 60), // Tăng khoảng cách để loa nằm cân đối ở giữa

        // Nút Loa đơn giản (Giống ở màn hình học chữ cái)
        IconButton(
          onPressed: () => SoundManager.instance.speakJapanese(data['answer']),
          icon: const Icon(Icons.volume_up, color: Color(0xFF58CC02), size: 80), // Size to để dễ bấm
        ),

        const SizedBox(height: 60),

        // 4 đáp án bên dưới
        Expanded(
          child: GridView.count(
            crossAxisCount: 2, mainAxisSpacing: 15, crossAxisSpacing: 15, childAspectRatio: 1.1,
            children: (data['options'] as List<String>).map((opt) {
              return ElevatedButton(
                onPressed: () {
                  bool isCorrect = (opt == data['answer']);
                  _showResultSheet(isCorrect, data['answer'], opt);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.grey, width: 2)),
                ),
                child: Text(opt, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// 2. GIAO DIỆN GHÉP CÂU MỚI (Stateful Widget để quản lý việc nhặt/thả từ vựng)
class SentenceBuilderView extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function(bool, String, String) onCheckResult;

  const SentenceBuilderView({super.key, required this.data, required this.onCheckResult});

  @override
  State<SentenceBuilderView> createState() => _SentenceBuilderViewState();
}

class _SentenceBuilderViewState extends State<SentenceBuilderView> {
  List<String> poolWords = []; // Từ bên dưới
  List<String> selectedWords = []; // Từ được chọn lên trên

  @override
  void initState() {
    super.initState();
    poolWords = List<String>.from(widget.data['words'])..shuffle();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Nghe và dịch câu sau", style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Text(widget.data['jp'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
        Text(widget.data['rmj'], style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 20),

        // Nút loa
        GestureDetector(
          onTap: () => SoundManager.instance.speakJapanese(widget.data['jp']),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(color: Color(0xFFF1F8E9), shape: BoxShape.circle),
            child: const Icon(Icons.volume_up, color: Color(0xFF58CC02), size: 40),
          ),
        ),

        const SizedBox(height: 30),
        Divider(color: Colors.grey.shade300, thickness: 2),
        const SizedBox(height: 30),

        // Vùng hiển thị từ ĐÃ CHỌN
        Container(
          constraints: const BoxConstraints(minHeight: 60),
          width: double.infinity,
          alignment: Alignment.center,
          child: Wrap(
            spacing: 12, runSpacing: 12, alignment: WrapAlignment.center,
            children: selectedWords.map((word) => _buildWordChip(word, true)).toList(),
          ),
        ),

        const Spacer(),

        // Vùng hiển thị từ CHƯA CHỌN
        Wrap(
          spacing: 12, runSpacing: 12, alignment: WrapAlignment.center,
          children: poolWords.map((word) => _buildWordChip(word, false)).toList(),
        ),

        const SizedBox(height: 40),

        // Nút Kiểm tra
        SizedBox(
          width: double.infinity, height: 50,
          child: ElevatedButton(
            onPressed: selectedWords.isEmpty ? null : () {
              String userAnswer = selectedWords.join(' ');
              bool isCorrect = (userAnswer == widget.data['answer']);
              widget.onCheckResult(isCorrect, widget.data['answer'], userAnswer);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedWords.isEmpty ? Colors.grey.shade300 : const Color(0xFF58CC02),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Text("Kiểm tra", style: TextStyle(color: selectedWords.isEmpty ? Colors.grey : Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildWordChip(String word, bool isSelectedZone) {
    return GestureDetector(
      onTap: () {
        SoundManager.instance.vibrate('light');
        setState(() {
          if (isSelectedZone) {
            selectedWords.remove(word);
            poolWords.add(word);
          } else {
            poolWords.remove(word);
            selectedWords.add(word);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 2),
          boxShadow: [BoxShadow(color: Colors.grey.shade200, offset: const Offset(0, 3))],
        ),
        child: Text(word, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
      ),
    );
  }
}

// 3. GIAO DIỆN TẬP VIẾT KANJI MỚI (Dùng Canvas vẽ tay)
class KanjiDrawView extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback onNext;

  const KanjiDrawView({super.key, required this.data, required this.onNext});

  @override
  State<KanjiDrawView> createState() => _KanjiDrawViewState();
}

class _KanjiDrawViewState extends State<KanjiDrawView> {
  List<Offset?> points = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.data['rmj'], style: const TextStyle(fontSize: 14, color: Colors.grey)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.data['kanji_word'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => SoundManager.instance.speakJapanese(widget.data['kanji_word']),
              child: const Icon(Icons.volume_up, color: Color(0xFF58CC02), size: 28),
            )
          ],
        ),
        Text(widget.data['meaning'], style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 20),

        // Khung Canvas tập vẽ
        Container(
          width: 300, height: 300,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300, width: 2),
              boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 10, offset: const Offset(0, 5))]
          ),
          child: Stack(
            children: [
              // Lưới chữ thập mờ
              Center(child: Container(width: double.infinity, height: 1, color: Colors.grey.shade200)),
              Center(child: Container(height: double.infinity, width: 1, color: Colors.grey.shade200)),

              // Chữ Kanji mờ chìm bên dưới để đồ theo
              Center(
                child: Text(widget.data['kanji_target'], style: TextStyle(fontSize: 220, color: Colors.grey.shade200, height: 1.1)),
              ),

              // Bảng vẽ bắt sự kiện chạm tay
              GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    RenderBox renderBox = context.findRenderObject() as RenderBox;
                    points.add(renderBox.globalToLocal(details.globalPosition));
                  });
                },
                onPanEnd: (details) => setState(() => points.add(null)),
                child: CustomPaint(
                  painter: DrawingPainter(points: points),
                  size: Size.infinite,
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        // Thanh công cụ thao tác nhanh
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle), child: const Icon(Icons.visibility_off, color: Colors.green)),
            const SizedBox(width: 20),
            // Nút xóa nét vẽ
            GestureDetector(
              onTap: () => setState(() => points.clear()),
              child: Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(color: Color(0xFF58CC02), shape: BoxShape.circle), child: const Icon(Icons.cleaning_services, color: Colors.white, size: 30)),
            ),
            const SizedBox(width: 20),
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle), child: const Icon(Icons.visibility, color: Colors.green)),
            const SizedBox(width: 20),
            // Nút qua bài
            GestureDetector(
              onTap: widget.onNext,
              child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle), child: const Icon(Icons.keyboard_double_arrow_right, color: Colors.black54)),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Nút Tiếp Tục lớn
        SizedBox(
          width: double.infinity, height: 50,
          child: ElevatedButton(
            onPressed: widget.onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF58CC02),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text("Tiếp tục", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}

// Logic vẽ đường thẳng
class DrawingPainter extends CustomPainter {
  List<Offset?> points;
  DrawingPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = const Color(0xFF2C3E50)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }
  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}

// CÁC WIDGET PHỤ TRỢ (Matching Game & Màn hình Kết Quả)
class MatchingGame extends StatefulWidget {
  final List<Map<String, String>> pairs;
  final VoidCallback onCompleted;
  const MatchingGame({super.key, required this.pairs, required this.onCompleted});
  @override
  State<MatchingGame> createState() => _MatchingGameState();
}
class _MatchingGameState extends State<MatchingGame> {
  late List<String> leftItems;
  late List<String> rightItems;
  String? selectedLeft;
  String? selectedRight;
  final Set<String> matchedItems = {};

  @override
  void initState() {
    super.initState();
    leftItems = widget.pairs.map((e) => e['left']!).toList()..shuffle();
    rightItems = widget.pairs.map((e) => e['right']!).toList()..shuffle();
  }

  void _handleTap(String item, bool isLeft) {
    setState(() { if (isLeft) selectedLeft = item; else selectedRight = item; });
    _checkMatch();
  }

  void _checkMatch() async {
    if (selectedLeft != null && selectedRight != null) {
      bool isCorrect = widget.pairs.any((pair) => pair['left'] == selectedLeft && pair['right'] == selectedRight);
      if (isCorrect) {
        SoundManager.instance.vibrate('light');
        setState(() { matchedItems.add(selectedLeft!); matchedItems.add(selectedRight!); selectedLeft = null; selectedRight = null; });
        if (matchedItems.length == widget.pairs.length * 2) { await Future.delayed(const Duration(milliseconds: 500)); widget.onCompleted(); }
      } else {
        SoundManager.instance.vibrate('error');
        await Future.delayed(const Duration(milliseconds: 300));
        setState(() { selectedLeft = null; selectedRight = null; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Nối các cặp tương ứng", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 20),
        Expanded(
          child: Row(
            children: [
              Expanded(child: ListView(children: leftItems.map((item) => _buildCard(item, true)).toList())),
              const SizedBox(width: 20),
              Expanded(child: ListView(children: rightItems.map((item) => _buildCard(item, false)).toList())),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCard(String text, bool isLeft) {
    bool isSelected = isLeft ? (selectedLeft == text) : (selectedRight == text);
    bool isMatched = matchedItems.contains(text);
    return IgnorePointer(
      ignoring: isMatched,
      child: GestureDetector(
        onTap: () => _handleTap(text, isLeft),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isMatched ? Colors.grey[300] : (isSelected ? Colors.blue[100] : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isMatched ? Colors.transparent : (isSelected ? Colors.blue : Colors.grey.shade300), width: 2),
            boxShadow: [if (!isMatched) BoxShadow(color: Colors.grey.shade200, offset: const Offset(0, 4), blurRadius: 0)],
          ),
          child: Center(child: isMatched ? const Icon(Icons.check, color: Colors.grey) : Text(text, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isSelected ? Colors.blue : Colors.black87))),
        ),
      ),
    );
  }
}

class LessonCompletionScreen extends StatelessWidget {
  final int correctCount;
  final int totalCount;
  final int expEarned;

  const LessonCompletionScreen({super.key, required this.correctCount, required this.totalCount, required this.expEarned});

  @override
  Widget build(BuildContext context) {
    int percent = totalCount > 0 ? ((correctCount / totalCount) * 100).round() : 100;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Image.asset('assets/images/dog_happy.png', height: 200, errorBuilder: (_, __, ___) => const Icon(Icons.emoji_events, size: 150, color: Colors.amber)),
              const SizedBox(height: 20),
              const Text("Bạn đã hoàn thành bài học!", textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF3C3C3C))),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(child: _buildResultCard(label: "$correctCount/$totalCount", icon: Icons.track_changes, color: const Color(0xFF4285F4), bgColor: const Color(0xFFE8F0FE))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildResultCard(label: "$percent%", icon: Icons.headphones, color: const Color(0xFF58CC02), bgColor: const Color(0xFFE5F6D5), badge: "+5 ⚡")),
                ],
              ),
              const SizedBox(height: 20),
              const Text("~~ ❇ ~~", style: TextStyle(color: Colors.grey, fontSize: 20)),
              const Spacer(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("EXP", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)), Text("+$expEarned ⚡", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 18))]),
              const SizedBox(height: 8),
              ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: 0.9, minHeight: 12, backgroundColor: Colors.grey[200], color: const Color(0xFFFFC800))),
              const SizedBox(height: 8),
              const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("-", style: TextStyle(color: Colors.grey)), Text("9 exp để lên cấp", style: TextStyle(color: Colors.grey)), Text("Tân binh", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold))]),
              const SizedBox(height: 30),
              SizedBox(width: double.infinity, height: 55, child: ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF58CC02), elevation: 5, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text("Tiếp tục", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)))),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard({required String label, required IconData icon, required Color color, required Color bgColor, String? badge}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 100, decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: bgColor, width: 2)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: color, size: 30), const SizedBox(height: 8), Center(child: Text(label, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)))]),
        ),
        if (badge != null) Positioned(top: -10, right: -5, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(12)), child: Text(badge, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))))
      ],
    );
  }
}

// ==========================================================
// 1. GIAO DIỆN FLASHCARD (MẶT TRƯỚC / MẶT SAU)
// ==========================================================
class FlashCardView extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback onNext;

  const FlashCardView({super.key, required this.data, required this.onNext});

  @override
  State<FlashCardView> createState() => _FlashCardViewState();
}

class _FlashCardViewState extends State<FlashCardView> {
  bool _isFlipped = false;

  void _flipCard() {
    setState(() {
      _isFlipped = true;
    });
    // Tự động đọc câu ví dụ khi lật sang mặt sau
    SoundManager.instance.speakJapanese(widget.data['example_jp']);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(scale: animation, child: child); // Hiệu ứng zoom lật thẻ
            },
            child: _isFlipped ? _buildBack() : _buildFront(),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity, height: 55,
          child: ElevatedButton(
            onPressed: _isFlipped ? widget.onNext : _flipCard,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF58CC02),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
            child: Text(
                _isFlipped ? "Tiếp tục" : "Lật Thẻ",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)
            ),
          ),
        ),
      ],
    );
  }

  // Mặt trước: Từ vựng
  Widget _buildFront() {
    return Container(
      key: const ValueKey('front'),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9C4), // Màu vàng nhạt giống thiết kế
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.arrow_back_ios, size: 12, color: Colors.black54),
              const SizedBox(width: 5),
              const Text("TỪ MỚI", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
              const SizedBox(width: 5),
              const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.black54),
              const SizedBox(width: 15),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.lightbulb, color: Colors.amber),
              )
            ],
          ),
          const SizedBox(height: 30),
          Text(widget.data['hiragana'], style: const TextStyle(fontSize: 20, color: Colors.black54)),
          Text(widget.data['kanji'], style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 10),
          Text(widget.data['romaji'], style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 20),
          Text(widget.data['meaning'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSoundBtn(Icons.pets, () => SoundManager.instance.speakJapanese(widget.data['hiragana'])), // Nút Rùa (Đọc chậm - Có thể custom hàm đọc chậm sau)
              const SizedBox(width: 20),
              _buildSoundBtn(Icons.volume_up, () => SoundManager.instance.speakJapanese(widget.data['hiragana'])),
            ],
          ),
          const SizedBox(height: 20),
          const Icon(Icons.touch_app, color: Colors.black54, size: 30),
        ],
      ),
    );
  }

  // Mặt sau: Ví dụ
  Widget _buildBack() {
    return Container(
      key: const ValueKey('back'),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9C4),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(color: Colors.amber.shade700, borderRadius: BorderRadius.circular(20)),
            child: const Text("Ví dụ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(widget.data['example_img'], fit: BoxFit.cover, width: double.infinity, errorBuilder: (_,__,___) => Container(color: Colors.grey[200], child: const Icon(Icons.image, size: 50, color: Colors.grey))),
            ),
          ),
          const SizedBox(height: 20),
          Text(widget.data['example_jp'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
          Text(widget.data['example_rmj'], style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 15),
          Text(widget.data['example_vn'], style: const TextStyle(fontSize: 18, color: Colors.black87)),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildSoundBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: const BoxDecoration(color: Color(0xFF6D4C41), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }
}

// ==========================================================
// 2. GIAO DIỆN TRẮC NGHIỆM TỪ VỰNG (CÓ NÚT KIỂM TRA RỜI)
// ==========================================================
class VocabQuizView extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function(bool, String, String) onCheckResult;

  const VocabQuizView({super.key, required this.data, required this.onCheckResult});

  @override
  State<VocabQuizView> createState() => _VocabQuizViewState();
}

class _VocabQuizViewState extends State<VocabQuizView> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    List<String> options = widget.data['options'];
    bool isSelected = _selectedIndex != null;

    return Column(
      children: [
        const Text("Chọn nghĩa của từ dưới đây", style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        Text(widget.data['hiragana'], style: const TextStyle(fontSize: 14, color: Colors.grey)),
        Text(widget.data['kanji'], style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87)),
        Text(widget.data['romaji'], style: const TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 15),
        GestureDetector(
          onTap: () => SoundManager.instance.speakJapanese(widget.data['kanji']),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(color: Color(0xFFF1F8E9), shape: BoxShape.circle),
            child: const Icon(Icons.volume_up, color: Color(0xFF58CC02), size: 35),
          ),
        ),
        const SizedBox(height: 30),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 1.5),
            itemCount: options.length,
            itemBuilder: (context, index) {
              bool isThisSelected = _selectedIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedIndex = index),
                child: Container(
                  decoration: BoxDecoration(
                    color: isThisSelected ? const Color(0xFFE8F5E9) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: isThisSelected ? const Color(0xFF58CC02) : Colors.grey.shade300, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(options[index], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isThisSelected ? const Color(0xFF58CC02) : Colors.black87)),
                ),
              );
            },
          ),
        ),
        SizedBox(
          width: double.infinity, height: 55,
          child: ElevatedButton(
            onPressed: isSelected ? () {
              String userAns = options[_selectedIndex!];
              bool isCorrect = userAns == widget.data['answer'];
              widget.onCheckResult(isCorrect, widget.data['answer'], userAns);
            } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isSelected ? const Color(0xFF58CC02) : Colors.grey.shade300,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: isSelected ? 4 : 0,
            ),
            child: Text("Kiểm tra", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.grey.shade500)),
          ),
        ),
      ],
    );
  }
}

// ==========================================================
// 3. GIAO DIỆN TỔNG KẾT TỪ VỰNG LÝ THUYẾT
// ==========================================================
class VocabSummaryView extends StatelessWidget {
  final List<Map<String, String>> words;
  final VoidCallback onNext;
  final VoidCallback onExit;

  const VocabSummaryView({super.key, required this.words, required this.onNext, required this.onExit});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Tổng kết bài học", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 20),
        // Tabs giả lập
        Container(
          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20)),
          child: Row(
            children: [
              const Expanded(child: Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text("Cần ôn tập", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))))),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(color: const Color(0xFF58CC02), borderRadius: BorderRadius.circular(20)),
                  child: const Center(child: Text("Đã nắm vững", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Align(alignment: Alignment.centerLeft, child: Text("TỪ VỰNG", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: words.length,
            itemBuilder: (context, index) {
              final w = words[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.check_circle, color: Color(0xFF58CC02), size: 28),
                title: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(text: w['kanji']! + " "),
                      TextSpan(text: "(${w['romaji']})", style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.normal)),
                    ],
                  ),
                ),
                subtitle: Text(w['meaning']!, style: const TextStyle(fontSize: 16, color: Colors.black54)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                onTap: () => SoundManager.instance.speakJapanese(w['kanji']!),
              );
            },
          ),
        ),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: onExit,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Text("Thoát", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF58CC02), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Text("Học tiếp", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        )
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'sound_manager.dart';
import 'user_progress.dart';
import 'app_settings.dart';
import 'package:permission_handler/permission_handler.dart';
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

  @override
  void initState() {
    super.initState();
    _loadLessonData();
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

    // Ưu tiên đọc biến audio_text nếu có
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

  // --- 1. HÀM LOAD DỮ LIỆU TỔNG HỢP ---
  void _loadLessonData() {
    switch (widget.lessonId) {
      case 'hang_a':
        _activities = _getHangAData();
        break;
      case 'hang_ka':
        _activities = _getHangKaData();
        break;
      case 'hang_sa':
        _activities = _getHangSaData();
        break;
      case 'hang_ta':
        _activities = _getHangTaData();
        break;
      case 'hang_na':
        _activities = _getHangNaData();
        break;
      case 'hang_ha':
        _activities = _getHangHaData();
        break;
      case 'hang_ma':
        _activities = _getHangMaData();
        break;
      case 'hang_ya':
        _activities = _getHangYaData();
        break;
      case 'hang_ra':
        _activities = _getHangRaData();
        break;
      case 'hang_wa':
        _activities = _getHangWaNData();
        break;
      case 'hang_all':
        _activities = _getFinalReviewData();
        break;
      case 'cb1_lythuyet':
        _activities = _getCb1LyThuyetData();
        break;
      case 'cb1_luyentap1':
        _activities = _getLuyenTap1Data();
        break;
      case 'cb1_luyentap2':
        _activities = _getCb1LuyenTap2Data();
        break;
      case 'cb1_luyentap3':
        _activities = _getCb1LuyenTap3Data();
        break;
      case 'cb1_luyennoi':
        _activities = _getCb1LuyenNoiData();
        break;
      case 'cb1_luyenviet':
        _activities = _getCb1LuyenVietData();
        break;
      case 'cb2_lythuyet':
        _activities = _getCb2LyThuyetData();
        break;
      case 'cb2_luyentap1':
        _activities = _getCb2LuyenTap1Data();
        break;
      case 'cb2_luyentap2':
        _activities = _getCb2LuyenTap2Data();
        break;
      case 'cb2_luyentap3':
        _activities = _getCb2LuyenTap3Data();
        break;
      case 'cb2_luyennoi':
        _activities = _getCb2LuyenNoiData();
        break;
      case 'cb2_luyenviet':
        _activities = _getCb2LuyenVietData();
        break;
      case 'cb3_lythuyet':
        _activities = _getCb3LyThuyetData();
        break;
      case 'cb3_luyentap1':
        _activities = _getCb3LuyenTap1Data();
        break;
      case 'cb3_luyentap2':
        _activities = _getCb3LuyenTap2Data();
        break;
      case 'cb3_luyentap3':
        _activities = _getCb3LuyenTap3Data();
        break;
      case 'cb3_luyennoi':
        _activities = _getCb3LuyenNoiData();
        break;
      case 'cb3_luyenviet':
        _activities = _getCb3LuyenVietData();
        break;
      case 'cb4_lythuyet':
        _activities = _getCb4LyThuyetData();
        break;
      case 'cb4_luyentap1':
        _activities = _getCb4LuyenTap1Data();
        break;
      case 'cb4_luyentap2':
        _activities = _getCb4LuyenTap2Data();
        break;
      case 'cb4_luyentap3':
        _activities = _getCb4LuyenTap3Data();
        break;
      case 'cb4_luyennoi':
        _activities = _getCb4LuyenNoiData();
        break;
      case 'cb4_luyenviet':
        _activities = _getCb4LuyenVietData();
        break;
      case 'cb5_lythuyet':
        _activities = _getCb5LyThuyetData();
        break;
      case 'cb5_luyentap1':
        _activities = _getCb5LuyenTap1Data();
        break;
      case 'cb5_luyentap2':
        _activities = _getCb5LuyenTap2Data();
        break;
      case 'cb5_luyentap3':
        _activities = _getCb5LuyenTap3Data();
        break;
      case 'cb5_luyennoi':
        _activities = _getCb5LuyenNoiData();
        break;
      case 'cb5_luyenviet':
        _activities = _getCb5LuyenVietData();
        break;
      case 'cb6_lythuyet':
        _activities = _getCb6LyThuyetData();
        break;
      case 'cb6_luyentap1':
        _activities = _getCb6LuyenTap1Data();
        break;
      case 'cb6_luyentap2':
        _activities = _getCb6LuyenTap2Data();
        break;
      case 'cb6_luyentap3':
        _activities = _getCb6LuyenTap3Data();
        break;
      case 'cb6_luyennoi':
        _activities = _getCb6LuyenNoiData();
        break;
      case 'cb6_luyenviet':
        _activities = _getCb6LuyenVietData();
        break;
      case 'cb7_lythuyet':
        _activities = _getCb7LyThuyetData();
        break;
      case 'cb7_luyentap1':
        _activities = _getCb7LuyenTap1Data();
        break;
      case 'cb7_luyentap2':
        _activities = _getCb7LuyenTap2Data();
        break;
      case 'cb7_luyentap3':
        _activities = _getCb7LuyenTap3Data();
        break;
      case 'cb7_luyennoi':
        _activities = _getCb7LuyenNoiData();
        break;
      case 'cb7_luyenviet':
        _activities = _getCb7LuyenVietData();
        break;
      case 'cb8_lythuyet':
        _activities = _getCb8LyThuyetData();
        break;
      case 'cb8_luyentap1':
        _activities = _getCb8LuyenTap1Data();
        break;
      case 'cb8_luyentap2':
        _activities = _getCb8LuyenTap2Data();
        break;
      case 'cb8_luyentap3':
        _activities = _getCb8LuyenTap3Data();
        break;
      case 'cb8_luyennoi':
        _activities = _getCb8LuyenNoiData();
        break;
      case 'cb8_luyenviet':
        _activities = _getCb8LuyenVietData();
        break;
      //case 'cb8_ontap':
      //  _activities = _getCb8OnTapData();
      //  break;
      case 'cb9_lythuyet':
        _activities = _getCb9LyThuyetData();
        break;
      case 'cb9_luyentap1':
        _activities = _getCb9LuyenTap1Data();
        break;
      case 'cb9_luyentap2':
        _activities = _getCb9LuyenTap2Data();
        break;
      case 'cb9_luyentap3':
        _activities = _getCb9LuyenTap3Data();
        break;
      case 'cb9_luyennoi':
        _activities = _getCb9LuyenNoiData();
        break;
      case 'cb9_luyenviet':
        _activities = _getCb9LuyenVietData();
        break;
      case 'cb10_lythuyet':
        _activities = _getCb10LyThuyetData();
        break;
      case 'cb10_luyentap1':
        _activities = _getCb10LuyenTap1Data();
        break;
      case 'cb10_luyentap2':
        _activities = _getCb10LuyenTap2Data();
        break;
      case 'cb10_luyentap3':
        _activities = _getCb10LuyenTap3Data();
        break;
      case 'cb10_luyennoi':
        _activities = _getCb10LuyenNoiData();
        break;
      case 'cb10_luyenviet':
        _activities = _getCb10LuyenVietData();
        break;
      default:
        _activities = [];
    }
  }

  List<Map<String, dynamic>> _getCb1LyThuyetData() {
    return [
      {
        'type': LessonType.vocabListIntro,
        'words': [
          {
            'kanji': 'こんにちは',
            'hiragana': 'こんにちは',
            'romaji': 'konnichiwa',
            'meaning': 'Xin chào',
          },
          {
            'kanji': 'さようなら',
            'hiragana': 'さようなら',
            'romaji': 'sayounara',
            'meaning': 'Tạm biệt',
          },
          {
            'kanji': '娘',
            'hiragana': 'むすめ',
            'romaji': 'musume',
            'meaning': 'Con gái',
          },
          {
            'kanji': '息子',
            'hiragana': 'むすこ',
            'romaji': 'musuko',
            'meaning': 'Con trai',
          },
          {'kanji': '父', 'hiragana': 'ちち', 'romaji': 'chichi', 'meaning': 'Bố'},
          {'kanji': '母', 'hiragana': 'はは', 'romaji': 'haha', 'meaning': 'Mẹ'},
          {
            'kanji': '彼',
            'hiragana': 'かれ',
            'romaji': 'kare',
            'meaning': 'Anh ấy / Bạn trai',
          },
          {
            'kanji': '彼女',
            'hiragana': 'かのじょ',
            'romaji': 'kanojo',
            'meaning': 'Cô ấy / Bạn gái',
          },
          {
            'kanji': '私',
            'hiragana': 'わたし',
            'romaji': 'watashi',
            'meaning': 'Tôi',
          },
          {
            'kanji': 'あなた',
            'hiragana': 'あなた',
            'romaji': 'anata',
            'meaning': 'Bạn / Anh / Chị',
          },
        ],
      },
      {
        'type': LessonType.flashCard,
        'kanji': '',
        'hiragana': 'こんにちは',
        'romaji': 'konnichiwa',
        'meaning': 'Xin chào',
        'example_img': 'assets/images/example_konnichiwa.png',
        'example_jp': 'こんにちは、元気ですか。',
        'example_rmj': 'Konnichiwa, genki desu ka.',
        'example_vn': 'Xin chào, bạn có khỏe không?',
      },
      {
        'type': LessonType.flashCard,
        'kanji': '',
        'hiragana': 'さようなら',
        'romaji': 'sayounara',
        'meaning': 'Tạm biệt',
        'example_img': 'assets/images/example_sayounara.png',
        'example_jp': '先生、さようなら。',
        'example_rmj': 'Sensei, sayounara.',
        'example_vn': 'Em chào thầy, em về ạ.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': '娘',
        'hiragana': 'むすめ',
        'romaji': 'musume',
        'meaning': 'Con gái (của mình)',
        'example_img': 'assets/images/example_musume.png',
        'example_jp': '私の娘は５歳です。',
        'example_rmj': 'Watashi no musume wa gosai desu.',
        'example_vn': 'Con gái tôi 5 tuổi.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': '息子',
        'hiragana': 'むすこ',
        'romaji': 'musuko',
        'meaning': 'Con trai (của mình)',
        'example_img': 'assets/images/example_musuko.png',
        'example_jp': '息子は学生です。',
        'example_rmj': 'Musuko wa gakusei desu.',
        'example_vn': 'Con trai tôi là học sinh.',
      },

      {
        'type': LessonType.vocabQuiz,
        'kanji': '',
        'hiragana': 'こんにちは',
        'romaji': 'konnichiwa',
        'options': ['tạm biệt', 'xin chào', 'cảm ơn', 'xin lỗi'],
        'answer': 'xin chào',
      },
      {
        'type': LessonType.vocabQuiz,
        'kanji': '娘',
        'hiragana': 'むすめ',
        'romaji': 'musume',
        'options': ['con trai', 'vợ', 'chồng', 'con gái'],
        'answer': 'con gái',
      },
      {
        'type': LessonType.listening,
        'options': ['こんにちは', 'さようなら', 'むすめ', 'むすこ'],
        'answer': 'さようなら',
      },

      {
        'type': LessonType.flashCard,
        'kanji': '父 / お父さん',
        'hiragana': 'ちち / おとうさん',
        'romaji': 'chichi / otousan',
        'meaning': 'Bố',
        'example_img': 'assets/images/example_chichi.png',
        'example_jp': 'お父さんは会社員です。',
        'example_rmj': 'Otousan wa kaishain desu.',
        'example_vn': 'Bố tôi là nhân viên công ty.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': '母 / お母さん',
        'hiragana': 'はは / おかあさん',
        'romaji': 'haha / okasan',
        'meaning': 'Mẹ',
        'example_img': 'assets/images/example_haha.png',
        'example_jp': '母は料理が上手です。',
        'example_rmj': 'Haha wa ryouri ga jouzu desu.',
        'example_vn': 'Mẹ tôi nấu ăn giỏi.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': '彼',
        'hiragana': 'かれ',
        'romaji': 'kare',
        'meaning': 'Anh ấy / Bạn trai',
        'example_img': 'assets/images/example_kare.png',
        'example_jp': '彼は私の友達です。',
        'example_rmj': 'Kare wa watashi no tomodachi desu.',
        'example_vn': 'Anh ấy là bạn của tôi.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': '彼女',
        'hiragana': 'かのじょ',
        'romaji': 'kanojo',
        'meaning': 'Cô ấy / Bạn gái',
        'example_img': 'assets/images/example_kanojo.png',
        'example_jp': '彼女はとてもきれいです。',
        'example_rmj': 'Kanojo wa totemo kirei desu.',
        'example_vn': 'Cô ấy rất đẹp.',
      },

      {
        'type': LessonType.vocabQuiz,
        'kanji': '母',
        'hiragana': 'はは',
        'romaji': 'haha',
        'options': ['bố', 'mẹ', 'anh trai', 'chị gái'],
        'answer': 'mẹ',
      },
      {
        'type': LessonType.vocabQuiz,
        'kanji': '彼',
        'hiragana': 'かれ',
        'romaji': 'kare',
        'options': ['cô ấy', 'tôi', 'bạn', 'anh ấy'],
        'answer': 'anh ấy',
      },
      {
        'type': LessonType.listening,
        'options': ['ちち', 'はは', 'かれ', 'かのじょ'],
        'answer': 'かのじょ',
      },

      {
        'type': LessonType.flashCard,
        'kanji': '私',
        'hiragana': 'わたし',
        'romaji': 'watashi',
        'meaning': 'Tôi',
        'example_img': 'assets/images/example_watashi.png',
        'example_jp': '私は学生です。',
        'example_rmj': 'Watashi wa gakusei desu.',
        'example_vn': 'Tôi là học sinh.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': '',
        'hiragana': 'あなた',
        'romaji': 'anata',
        'meaning': 'Bạn / Anh / Chị',
        'example_img': 'assets/images/example_anata.png',
        'example_jp': 'あなたは会社員ですか。',
        'example_rmj': 'Anata wa kaishain desu ka.',
        'example_vn': 'Bạn có phải là nhân viên công ty không?',
      },

      // NGỮ PHÁP
      {
        'type': LessonType.grammarListIntro,
        'grammars': [
          {'title': 'Danh từ です', 'meaning': 'là ~'},
          {'title': 'Trợ từ 「は」', 'meaning': 'thì, là (chủ ngữ)'},
        ],
      },
      {
        'type': LessonType.grammarStructure,
        'title': 'DANH TỪ です',
        'formula': 'N + です',
        'meaning': 'là ~',
      },
      {
        'type': LessonType.grammarUsage,
        'title': 'DANH TỪ です',
        'notes': [
          '「です」 trong tiếng Nhật thường mang ý nghĩa gần giống với từ "là" trong tiếng Việt. Tuy nhiên thay vì đặt ở giữa câu, tiếng Nhật đặt nó ở cuối câu.',
          '「です」 đặt sau danh từ làm vị ngữ để thể hiện sự phán đoán hoặc khẳng định điều gì đó.',
          'Thể hiện sự lịch sự của người nói đối với người nghe.',
        ],
      },
      {
        'type': LessonType.grammarExample,
        'title': 'DANH TỪ です',
        'img': 'assets/images/example_kim.png',
        'jp': 'キムです。',
        'rmj': 'Kimu desu.',
        'vn': 'Tôi là Kim.',
      },

      {
        'type': LessonType.vocabSummary,
        'words': [
          {'kanji': 'こんにちは', 'romaji': 'konnichiwa', 'meaning': 'xin chào'},
          {'kanji': 'さようなら', 'romaji': 'sayounara', 'meaning': 'tạm biệt'},
          {'kanji': '娘', 'romaji': 'musume', 'meaning': 'con gái'},
          {'kanji': '息子', 'romaji': 'musuko', 'meaning': 'con trai'},
          {'kanji': '父', 'romaji': 'chichi', 'meaning': 'bố'},
          {'kanji': '母', 'romaji': 'haha', 'meaning': 'mẹ'},
          {'kanji': '彼', 'romaji': 'kare', 'meaning': 'anh ấy'},
          {'kanji': '彼女', 'romaji': 'kanojo', 'meaning': 'cô ấy'},
          {'kanji': '私', 'romaji': 'watashi', 'meaning': 'tôi'},
          {'kanji': 'あなた', 'romaji': 'anata', 'meaning': 'bạn / anh / chị'},
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
          {
            'img': 'assets/images/example_sayounara.png',
            'jp': 'さようなら',
            'rmj': 'sayounara',
          },
          {
            'img': 'assets/images/example_konnichiwa.png',
            'jp': 'こんにちは',
            'rmj': 'konnichiwa',
          },
          {
            'img': 'assets/images/example_musume.png',
            'jp': 'むすめ',
            'rmj': 'musume',
          },
          {
            'img': 'assets/images/example_musuko.png',
            'jp': 'むすこ',
            'rmj': 'musuko',
          },
        ],
      },
      {
        'type': LessonType.listening,
        'options': [
          {'kanji': '', 'hiragana': 'こんにちは'},
          {'kanji': '', 'hiragana': 'さようなら'},
          {'kanji': '娘', 'hiragana': 'むすめ'},
          {'kanji': '息子', 'hiragana': 'むすこ'},
        ],
        'answer': 'さようなら',
      },
      {
        'type': LessonType.imageQuiz,
        'question': 'Con gái.',
        'answerIndex': 2,
        'options': [
          {
            'img': 'assets/images/example_musuko.png',
            'jp': 'むすこ',
            'rmj': 'musuko',
          },
          {
            'img': 'assets/images/example_chichi.png',
            'jp': 'おとうさん',
            'rmj': 'otousan',
          },
          {
            'img': 'assets/images/example_musume.png',
            'jp': 'むすめ',
            'rmj': 'musume',
          },
          {
            'img': 'assets/images/example_haha.png',
            'jp': 'おかあさん',
            'rmj': 'okaasan',
          },
        ],
      },
      {
        'type': LessonType.listening,
        'options': [
          {'kanji': 'お父さん', 'hiragana': 'おとうさん'},
          {'kanji': 'お母さん', 'hiragana': 'おかあさん'},
          {'kanji': '息子', 'hiragana': 'むすこ'},
          {'kanji': '娘', 'hiragana': 'むすめ'},
        ],
        'answer': 'お父さん',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'こんにちは、お父さん',
        'rmj': 'konnichiwa, otousan',
        'words': ['xin chào', 'bố', 'tạm biệt', 'con gái', 'mẹ'],
        'answer': 'xin chào bố',
      },
      {'type': LessonType.speaking, 'jp': 'こんにちは', 'answer': 'こんにちは'},
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '娘',
        'kanji_target': '娘',
        'meaning': 'Con gái',
        'rmj': 'musume',
      },
      {'type': LessonType.speaking, 'jp': '娘', 'answer': '娘'},
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '父 / お父さん',
        'kanji_target': '父',
        'meaning': 'Bố',
        'rmj': 'chichi / otousan',
      },
      {'type': LessonType.speaking, 'jp': 'お父さん', 'answer': 'お父さん'},
    ];
  }

  List<Map<String, dynamic>> _getCb1LuyenTap2Data() {
    return [
      {
        'type': LessonType.flashCard,
        'kanji': 'Nです',
        'hiragana': 'です',
        'romaji': 'desu',
        'meaning': 'Ngữ pháp: Danh từ + です (Là ~)',
        'example_img': 'assets/images/example_chichi.png',
        'example_jp': '父です。',
        'example_rmj': 'Chichi desu.',
        'example_vn': 'Là bố.',
      },
      {
        'type': LessonType.quiz,
        'question': '', // Bỏ trống để UI tự chuyển sang chế độ "Chỉ nghe"
        'audio_text': 'こんにちは、お父さん',
        'options': ['Xin chào, bố.', 'Tôi là bố.'],
        'answer': 'Xin chào, bố.',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': '息子です。',
        'rmj': 'musuko desu.',
        'audio_text': '息子です',
        'words': ['là', 'con trai', 'con gái', 'bố', 'mẹ'],
        'answer': 'là con trai',
      },
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '父 / お父さん',
        'kanji_target': '父',
        'meaning': 'Bố',
        'rmj': 'chichi / o tou sa n',
      },

      // === PHẦN 2: NGỮ PHÁP "TRỢ TỪ は" ===
      {
        'type': LessonType.flashCard,
        'kanji': 'N1はN2です',
        'hiragana': 'は',
        'romaji': 'wa',
        'meaning': 'Ngữ pháp: N1 là N2 (は đóng vai trò trợ từ chủ ngữ)',
        'example_img': 'assets/images/example_watashi.png',
        'example_jp': '私は父です。',
        'example_rmj': 'Watashi wa chichi desu.',
        'example_vn': 'Tôi là bố.',
      },
      // Hình 1000015511: Hình ảnh
      {
        'type': LessonType.imageQuiz,
        'question': 'tôi.',
        'answerIndex': 0,
        'options': [
          {
            'img': 'assets/images/example_watashi.png',
            'jp': '私',
            'rmj': 'watashi',
          },
          {
            'img': 'assets/images/example_konbanwa.png',
            'jp': 'こんばんは',
            'rmj': 'konbanwa',
          },
          {
            'img': 'assets/images/example_konnichiwa.png',
            'jp': 'こんにちは',
            'rmj': 'konnichiwa',
          },
          {
            'img': 'assets/images/example_ohayou.png',
            'jp': 'おはようございます',
            'rmj': 'ohayougozaimasu',
          },
        ],
      },
      // Hình 1000015513: Dịch câu
      {
        'type': LessonType.quiz,
        'question': '私は父です。',
        'audio_text': '私は父です。',
        'options': [
          'Tôi là con trai.',
          'Xin chào, tôi là bố.',
          'Tôi là bố.',
          'Xin chào, tôi là con trai.',
        ],
        'answer': 'Tôi là bố.',
      },
      // Hình 1000015515: Đọc và dịch
      {
        'type': LessonType.sentenceBuilder,
        'jp': '私は息子です。',
        'rmj': 'watashi wa musuko desu.',
        'audio_text': '私は息子です。',
        'words': ['là', 'tôi', 'con trai', 'bố', 'xin chào'],
        'answer': 'tôi là con trai',
      },
      // Hình 1000015519: Nghe và ghép từ thành câu tiếng Nhật (Ẩn chữ)
      {
        'type': LessonType.sentenceBuilder,
        'jp': '', // Bỏ trống jp và rmj để ẩn chữ, chuyển sang mode Luyện Nghe
        'rmj': '',
        'audio_text': '私は父です',
        'words': ['私', '父', 'は', 'です'],
        'answer': '私 は 父 です', // Các thẻ được nối với nhau bằng dấu cách
      },
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '私',
        'kanji_target': '私',
        'meaning': 'Tôi',
        'rmj': 'watashi',
      },
      // Hình 1000015521: Luyện nói
      {'type': LessonType.speaking, 'jp': '私は息子です。', 'answer': '私は息子です。'},
    ];
  }

  List<Map<String, dynamic>> _getCb1LuyenTap3Data() {
    return [
      // 1. CÂU HỎI HÌNH ẢNH (Focus: Mẹ)
      {
        'type': LessonType.imageQuiz,
        'question': 'Mẹ (của mình).',
        'answerIndex': 0,
        'options': [
          {'img': 'assets/images/example_haha.png', 'jp': 'はは', 'rmj': 'haha'},
          {'img': 'assets/images/example_kare.png', 'jp': 'かれ', 'rmj': 'kare'},
          {
            'img': 'assets/images/example_kanojo.png',
            'jp': 'かのじょ',
            'rmj': 'kanojo',
          },
          {
            'img': 'assets/images/example_anata.png',
            'jp': 'あなた',
            'rmj': 'anata',
          },
        ],
      },

      // 2. CÂU HỎI NGHE (Focus: Cô ấy)
      {
        'type': LessonType.listening,
        'options': [
          {'kanji': '母', 'hiragana': 'はは'},
          {'kanji': '彼女', 'hiragana': 'かのじょ'},
          {'kanji': '彼', 'hiragana': 'かれ'},
          {'kanji': '私', 'hiragana': 'わたし'},
        ],
        'answer': '彼女', // Kanojo
      },

      // 3. CÂU HỎI HÌNH ẢNH (Focus: Bạn / Anh / Chị)
      {
        'type': LessonType.imageQuiz,
        'question': 'Bạn / Anh / Chị.',
        'answerIndex': 2,
        'options': [
          {'img': 'assets/images/example_kare.png', 'jp': 'かれ', 'rmj': 'kare'},
          {
            'img': 'assets/images/example_watashi.png',
            'jp': 'わたし',
            'rmj': 'watashi',
          },
          {
            'img': 'assets/images/example_anata.png',
            'jp': 'あなた',
            'rmj': 'anata',
          },
          {'img': 'assets/images/example_haha.png', 'jp': 'はは', 'rmj': 'haha'},
        ],
      },

      // 4. CÂU HỎI NGHE (Focus: Anh ấy)
      {
        'type': LessonType.listening,
        'options': [
          {'kanji': '彼', 'hiragana': 'かれ'},
          {'kanji': '彼女', 'hiragana': 'かのじょ'},
          {'kanji': '', 'hiragana': 'あなた'},
          {'kanji': '私', 'hiragana': 'わたし'},
        ],
        'answer': '彼', // Kare
      },

      // 5. CÂU HỎI GHÉP CHỮ (Kết hợp các từ trong nhóm)
      {
        'type': LessonType.sentenceBuilder,
        'jp': '彼女は私の母です',
        'rmj': 'kanojo wa watashi no haha desu',
        'words': ['cô ấy', 'là', 'mẹ', 'của tôi', 'anh ấy'],
        'answer': 'cô ấy là mẹ của tôi',
      },

      // 6. CÂU HỎI LUYỆN NÓI (Focus: Tôi)
      {'type': LessonType.speaking, 'jp': 'わたし', 'answer': 'わたし'},

      // 7. CÂU HỎI VẼ KANJI - Từ "Mẹ" (母)
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '母',
        'kanji_target': '母',
        'meaning': 'Mẹ',
        'rmj': 'haha',
      },
      {'type': LessonType.speaking, 'jp': '母', 'answer': '母'},

      // 8. CÂU HỎI VẼ KANJI - Từ "Tôi" (私)
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '私',
        'kanji_target': '私',
        'meaning': 'Tôi',
        'rmj': 'watashi',
      },
      {'type': LessonType.speaking, 'jp': '私', 'answer': '私'},
    ];
  }

  List<Map<String, dynamic>> _getCb1LuyenNoiData() {
    return [
      // 1. Chào hỏi
      {'type': LessonType.speaking, 'jp': 'こんにちは', 'answer': 'こんにちは'},
      // 2. Bố
      {
        'type': LessonType.speaking,
        'jp': '父',
        'answer':
            'ちち', // AI Whisper đôi khi bắt Kanji thành Hiragana, nên để answer là dạng đọc chuẩn nhất
      },
      // 3. Mẹ
      {'type': LessonType.speaking, 'jp': '母', 'answer': 'はは'},
      // 4. Con trai
      {'type': LessonType.speaking, 'jp': '息子', 'answer': 'むすこ'},
      // 5. Con gái
      {'type': LessonType.speaking, 'jp': '娘', 'answer': 'むすめ'},
      // 6. Tôi
      {'type': LessonType.speaking, 'jp': '私', 'answer': 'わたし'},
      // 7. Bạn / Anh / Chị
      {'type': LessonType.speaking, 'jp': 'あなた', 'answer': 'あなた'},
      // 8. Anh ấy
      {'type': LessonType.speaking, 'jp': '彼', 'answer': 'かれ'},
      // 9. Cô ấy
      {'type': LessonType.speaking, 'jp': '彼女', 'answer': 'かのじょ'},
      // 10. Tạm biệt
      {'type': LessonType.speaking, 'jp': 'さようなら', 'answer': 'さようなら'},
    ];
  }

  List<Map<String, dynamic>> _getCb1LuyenVietData() {
    return [
      // 1. Tập viết chữ Tôi (私)
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '私',
        'kanji_target': '私',
        'meaning': 'Tôi (Tư)',
        'rmj': 'watashi',
      },
      // 2. Tập viết chữ Bố (父)
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '父',
        'kanji_target': '父',
        'meaning': 'Bố (Phụ)',
        'rmj': 'chichi',
      },
      // 3. Tập viết chữ Mẹ (母)
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '母',
        'kanji_target': '母',
        'meaning': 'Mẹ (Mẫu)',
        'rmj': 'haha',
      },
      // 4. Tập viết chữ Con gái (娘)
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '娘',
        'kanji_target': '娘',
        'meaning': 'Con gái (Nương)',
        'rmj': 'musume',
      },
      // 5. Tập viết chữ Tử (trong Con trai - 息子)
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '息子',
        'kanji_target': '子',
        'meaning': 'Tử (Con)',
        'rmj': 'ko / shi',
      },
      // 6. Tập viết chữ Anh ấy (彼)
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '彼',
        'kanji_target': '彼',
        'meaning': 'Anh ấy (Bỉ)',
        'rmj': 'kare',
      },
      // 7. Tập viết chữ Nữ (trong Cô ấy - 彼女)
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '彼女',
        'kanji_target': '女',
        'meaning': 'Nữ (Phụ nữ)',
        'rmj': 'onna / jo',
      },
      // 8. Chốt lại bằng Game ghép Kanji
      {
        'type': LessonType.matching,
        'pairs': [
          {'left': 'Tôi', 'right': '私'},
          {'left': 'Bố', 'right': '父'},
          {'left': 'Mẹ', 'right': '母'},
          {'left': 'Con gái', 'right': '娘'},
          {'left': 'Anh ấy', 'right': '彼'},
        ],
      },
    ];
  }

  List<Map<String, dynamic>> _getCb2LyThuyetData() {
    return [
      // ================= PHẦN 1: TỪ VỰNG =================
      {
        'type': LessonType.vocabListIntro,
        'words': [
          {
            'kanji': 'アメリカ',
            'hiragana': 'アメリカ',
            'romaji': 'amerika',
            'meaning': 'Mỹ',
          },
          {
            'kanji': '日本',
            'hiragana': 'にほん',
            'romaji': 'nihon',
            'meaning': 'Nhật Bản',
          },
          {
            'kanji': '〜人',
            'hiragana': '〜じん',
            'romaji': '~jin',
            'meaning': 'Hậu tố mang nghĩa "người (nước) ~"',
          },
          {
            'kanji': '好き [な]',
            'hiragana': 'すき',
            'romaji': 'suki [na]',
            'meaning': 'Thích (tính từ đuôi な)',
          },
          {'kanji': '犬', 'hiragana': 'いぬ', 'romaji': 'inu', 'meaning': 'Chó'},
          {'kanji': '猫', 'hiragana': 'ねこ', 'romaji': 'neko', 'meaning': 'Mèo'},
        ],
      },

      // --- NHÓM TỪ 1: QUỐC GIA & NGƯỜI (3 TỪ) ---
      {
        'type': LessonType.flashCard,
        'kanji': 'アメリカ',
        'hiragana': 'アメリカ',
        'romaji': 'amerika',
        'meaning': 'Mỹ',
        'example_img': 'assets/images/example_amerika.png',
        'example_jp': 'アメリカから来ました。',
        'example_rmj': 'Amerika kara kimashita.',
        'example_vn': 'Tôi đến từ Mỹ.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': '日本',
        'hiragana': 'にほん',
        'romaji': 'nihon',
        'meaning': 'Nhật Bản',
        'example_img': 'assets/images/example_nihon.png',
        'example_jp': '日本はきれいです。',
        'example_rmj': 'Nihon wa kirei desu.',
        'example_vn': 'Nhật Bản rất đẹp.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': '〜人',
        'hiragana': '〜じん',
        'romaji': '~jin',
        'meaning': 'Người (nước) ~',
        'example_img': 'assets/images/example_jin.png',
        'example_jp': '私はベトナム人です。',
        'example_rmj': 'Watashi wa Betonamujin desu.',
        'example_vn': 'Tôi là người Việt Nam.',
      },
      {
        'type': LessonType.vocabQuiz,
        'kanji': '日本',
        'hiragana': 'にほん',
        'romaji': 'nihon',
        'options': ['Việt Nam', 'Mỹ', 'Hàn Quốc', 'Nhật Bản'],
        'answer': 'Nhật Bản',
      },
      {
        'type': LessonType.vocabQuiz,
        'kanji': 'アメリカ',
        'hiragana': 'アメリカ',
        'romaji': 'amerika',
        'options': ['Anh', 'Mỹ', 'Pháp', 'Đức'],
        'answer': 'Mỹ',
      },
      {
        'type': LessonType.listening,
        'options': ['アメリカ', 'にほん', 'ベトナム', 'じん'],
        'answer': 'にほん',
      },

      // --- NHÓM TỪ 2: ĐỘNG VẬT & SỞ THÍCH (3 TỪ) ---
      {
        'type': LessonType.flashCard,
        'kanji': '好き',
        'hiragana': 'すき',
        'romaji': 'suki',
        'meaning': 'Thích',
        'example_img': 'assets/images/example_suki.png',
        'example_jp': '私はスポーツが好きです。',
        'example_rmj': 'Watashi wa supo-tsu ga suki desu.',
        'example_vn': 'Tôi thích thể thao.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': '犬',
        'hiragana': 'いぬ',
        'romaji': 'inu',
        'meaning': 'Chó',
        'example_img': 'assets/images/example_inu.png',
        'example_jp': '犬が可愛いです。',
        'example_rmj': 'Inu ga kawaii desu.',
        'example_vn': 'Con chó thật dễ thương.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': '猫',
        'hiragana': 'ねこ',
        'romaji': 'neko',
        'meaning': 'Mèo',
        'example_img': 'assets/images/example_neko.png',
        'example_jp': '猫がいます。',
        'example_rmj': 'Neko ga imasu.',
        'example_vn': 'Có con mèo.',
      },
      {
        'type': LessonType.vocabQuiz,
        'kanji': '犬',
        'hiragana': 'いぬ',
        'romaji': 'inu',
        'options': ['mèo', 'chó', 'chim', 'cá'],
        'answer': 'chó',
      },
      {
        'type': LessonType.vocabQuiz,
        'kanji': '好き',
        'hiragana': 'すき',
        'romaji': 'suki',
        'options': ['ghét', 'đẹp', 'thích', 'tốt'],
        'answer': 'thích',
      },
      {
        'type': LessonType.listening,
        'options': ['いぬ', 'ねこ', 'すき', 'きらい'],
        'answer': 'ねこ',
      },

      // ================= PHẦN 2: NGỮ PHÁP =================
      {
        'type': LessonType.grammarListIntro,
        'grammars': [
          {'title': 'Danh từ じゃありません', 'meaning': 'không phải là ~'},
          {'title': 'Hậu tố chỉ số nhiều「〜たち」', 'meaning': 'các ~, những ~'},
          {'title': 'Hậu tố chỉ số nhiều「〜ら」', 'meaning': 'bọn ~, các ~'},
          {'title': 'Tính từ です / じゃありません', 'meaning': 'thì ~ / thì không ~'},
          {'title': 'Trợ từ「も」', 'meaning': 'cũng ~'},
        ],
      },

      // NGỮ PHÁP 1: Danh từ じゃありません
      {
        'type': LessonType.grammarStructure,
        'title': 'DANH TỪ じゃありません',
        'formula': 'N + じゃありません',
        'meaning': 'Không phải là ~',
      },
      {
        'type': LessonType.grammarUsage,
        'title': 'DANH TỪ じゃありません',
        'notes': [
          'Dùng để phủ định một danh từ, mang ý nghĩa "không phải là...".',
          'Đây là dạng phủ định của 「です」.',
          'Trong văn nói trang trọng hoặc văn viết, người ta hay dùng 「ではありません」 (dewa arimasen).',
        ],
      },
      {
        'type': LessonType.grammarExample,
        'title': 'DANH TỪ じゃありません',
        'img': 'assets/images/example_ja_arimasen.png',
        'jp': '私はアメリカ人じゃありません。',
        'rmj': 'Watashi wa Amerikajin ja arimasen.',
        'vn': 'Tôi không phải là người Mỹ.',
      },

      // NGỮ PHÁP 2: Hậu tố 〜たち
      {
        'type': LessonType.grammarStructure,
        'title': 'HẬU TỐ「〜たち」',
        'formula': 'N (người) + たち',
        'meaning': 'Các ~, những ~ (Số nhiều)',
      },
      {
        'type': LessonType.grammarUsage,
        'title': 'HẬU TỐ「〜たち」',
        'notes': [
          'Thêm vào sau danh từ hoặc đại từ chỉ người để biểu thị số nhiều.',
          'Ví dụ phổ biến: 私 (Tôi) ➔ 私たち (Chúng tôi).',
          'Lưu ý: Không dùng 「たち」 cho đồ vật vô tri vô giác.',
        ],
      },
      {
        'type': LessonType.grammarExample,
        'title': 'HẬU TỐ「〜たち」',
        'img': 'assets/images/example_watashitachi.png',
        'jp': '私たちは日本人です。',
        'rmj': 'Watashitachi wa Nihonjin desu.',
        'vn': 'Chúng tôi là người Nhật Bản.',
      },

      // NGỮ PHÁP 3: Hậu tố 〜ら
      {
        'type': LessonType.grammarStructure,
        'title': 'HẬU TỐ「〜ら」',
        'formula': 'Đại từ + ら',
        'meaning': 'Bọn ~, các ~ (Số nhiều)',
      },
      {
        'type': LessonType.grammarUsage,
        'title': 'HẬU TỐ「〜ら」',
        'notes': [
          'Tương tự như 「〜たち」, hậu tố này cũng dùng để chỉ số nhiều.',
          'Thường được gắn cố định với một số đại từ nhất định. Ví dụ: 彼 (Kare - anh ấy) ➔ 彼ら (Karera - bọn họ).',
        ],
      },
      {
        'type': LessonType.grammarExample,
        'title': 'HẬU TỐ「〜ら」',
        'img': 'assets/images/example_karera.png',
        'jp': '彼らはアメリカ人です。',
        'rmj': 'Karera wa Amerikajin desu.',
        'vn': 'Bọn họ là người Mỹ.',
      },

      // NGỮ PHÁP 4: Tính từ です / じゃありません
      {
        'type': LessonType.grammarStructure,
        'title': 'TÍNH TỪ です / じゃありません',
        'formula': 'Tính từ (đuôi な) + です / じゃありません',
        'meaning': 'Thì ~ / Thì không ~',
      },
      {
        'type': LessonType.grammarUsage,
        'title': 'TÍNH TỪ です / じゃありません',
        'notes': [
          'Khác với tiếng Việt, tính từ trong tiếng Nhật cũng phải chia thì giống như Động từ và Danh từ.',
          'Khi khẳng định một đặc điểm ở hiện tại, ta thêm 「です」.',
          'Khi phủ định (đối với tính từ đuôi な như 好き), ta dùng 「じゃありません」 (Thì không thích).',
        ],
      },
      {
        'type': LessonType.grammarExample,
        'title': 'TÍNH TỪ です / じゃありません',
        'img': 'assets/images/example_suki.png',
        'jp': '私は猫が好きじゃありません。',
        'rmj': 'Watashi wa neko ga suki ja arimasen.',
        'vn': 'Tôi thì không thích mèo.',
      },

      // NGỮ PHÁP 5: Trợ từ も
      {
        'type': LessonType.grammarStructure,
        'title': 'TRỢ TỪ「も」',
        'formula': 'N + も',
        'meaning': 'Cũng ~',
      },
      {
        'type': LessonType.grammarUsage,
        'title': 'TRỢ TỪ「も」',
        'notes': [
          'Trợ từ 「も」 được dùng để thay thế hoàn toàn cho trợ từ 「は」.',
          'Nó mang ý nghĩa tương đồng với một sự vật, sự việc đã được nhắc đến trước đó (N cũng...).',
        ],
      },
      {
        'type': LessonType.grammarExample,
        'title': 'TRỢ TỪ「も」',
        'img': 'assets/images/example_mo.png',
        'jp': '私も犬が好きです。',
        'rmj': 'Watashi mo inu ga suki desu.',
        'vn': 'Tôi CŨNG thích chó.',
      },

      // ================= PHẦN 3: TỔNG KẾT =================
      {
        'type': LessonType.vocabSummary,
        'words': [
          {'kanji': 'アメリカ', 'romaji': 'amerika', 'meaning': 'Mỹ'},
          {'kanji': '日本', 'romaji': 'nihon', 'meaning': 'Nhật Bản'},
          {'kanji': '〜人', 'romaji': '~jin', 'meaning': 'người (nước) ~'},
          {'kanji': '好き [な]', 'romaji': 'suki [na]', 'meaning': 'thích'},
          {'kanji': '犬', 'romaji': 'inu', 'meaning': 'chó'},
          {'kanji': '猫', 'romaji': 'neko', 'meaning': 'mèo'},
        ],
      },
    ];
  }

  List<Map<String, dynamic>> _getCb2LuyenTap1Data() {
    return [
      // -----------------------------------------------------
      // NHÓM 1: TỪ VỰNG ĐƠN LẺ (Hình ảnh & Nghe) - 4 Câu
      // -----------------------------------------------------
      // 1. Hình ảnh: Mỹ
      {
        'type': LessonType.imageQuiz,
        'question': 'Mỹ.',
        'answerIndex': 0,
        'options': [
          {
            'img': 'assets/images/example_amerika.png',
            'jp': 'アメリカ',
            'rmj': 'amerika',
          },
          {
            'img': 'assets/images/example_nihon.png',
            'jp': '日本',
            'rmj': 'nihon',
          },
          {'img': 'assets/images/example_inu.png', 'jp': '犬', 'rmj': 'inu'},
          {'img': 'assets/images/example_jin.png', 'jp': '人', 'rmj': 'jin'},
        ],
      },
      // 2. Nghe: Nhật Bản
      {
        'type': LessonType.listening,
        'options': [
          {'kanji': 'アメリカ', 'hiragana': 'アメリカ'},
          {'kanji': '日本', 'hiragana': 'にほん'},
          {'kanji': '人', 'hiragana': 'じん'},
          {'kanji': '私', 'hiragana': 'わたし'},
        ],
        'answer': '日本',
      },
      // 3. Hình ảnh: Người (nước) ~
      {
        'type': LessonType.imageQuiz,
        'question': 'Hậu tố "người (nước)".',
        'answerIndex': 3,
        'options': [
          {
            'img': 'assets/images/example_nihon.png',
            'jp': '日本',
            'rmj': 'nihon',
          },
          {
            'img': 'assets/images/example_amerika.png',
            'jp': 'アメリカ',
            'rmj': 'amerika',
          },
          {
            'img': 'assets/images/example_chichi.png',
            'jp': '父',
            'rmj': 'chichi',
          },
          {'img': 'assets/images/example_jin.png', 'jp': '人', 'rmj': 'jin'},
        ],
      },
      // 4. Trắc nghiệm chữ: アメリカ
      {
        'type': LessonType.vocabQuiz,
        'kanji': 'アメリカ',
        'hiragana': 'アメリカ',
        'romaji': 'amerika',
        'options': ['Mỹ', 'Nhật Bản', 'Việt Nam', 'Hàn Quốc'],
        'answer': 'Mỹ',
      },

      // -----------------------------------------------------
      // NHÓM 2: CHỌN CÂU DÀI & ĐỌC HIỂU (Focus: じゃありません) - 4 Câu
      // -----------------------------------------------------
      // 5. Nghe và chọn câu: Phủ định (Tôi không phải là người Mỹ)
      {
        'type': LessonType.quiz,
        'question': 'Tôi không phải là người Mỹ.',
        'audio_text': '私はアメリカ人じゃありません。',
        'options': [
          {'kanji': '私はアメリカ人じゃありません。', 'hiragana': 'わたしはアメリカ人じゃありません。'},
          {'kanji': '私はアメリカ人です。', 'hiragana': 'わたしはアメリカ人です。'},
        ],
        'answer': '私はアメリカ人じゃありません。',
      },
      // 6. Đọc và dịch câu: Khẳng định (Anh ấy là người Nhật)
      {
        'type': LessonType.sentenceBuilder,
        'jp': '彼は日本人です。',
        'rmj': 'Kare wa Nihonjin desu.',
        'audio_text': '彼は日本人です。',
        'words': ['anh ấy', 'là', 'người', 'Nhật Bản', 'Mỹ', 'không phải'],
        'answer': 'anh ấy là người Nhật Bản',
      },
      // 7. Nghe và chọn câu: (Cô ấy không phải là mẹ)
      {
        'type': LessonType.quiz,
        'question': 'Cô ấy không phải là mẹ.',
        'audio_text': '彼女は母じゃありません。',
        'options': [
          {'kanji': '彼女は母じゃありません。', 'hiragana': 'かのじょは母じゃありません。'},
          {'kanji': '彼女は母です。', 'hiragana': 'かのじょは母です。'},
        ],
        'answer': '彼女は母じゃありません。',
      },
      // 8. Đọc và dịch câu: (Tôi không phải là người Nhật Bản)
      {
        'type': LessonType.sentenceBuilder,
        'jp': '私は日本人じゃありません。',
        'rmj': 'Watashi wa Nihonjin ja arimasen.',
        'audio_text': '私は日本人じゃありません。',
        'words': ['tôi', 'không phải', 'là', 'người', 'Nhật Bản', 'anh ấy'],
        'answer': 'tôi không phải là người Nhật Bản',
      },

      // -----------------------------------------------------
      // NHÓM 3: NGHE VÀ GHÉP TỪ THÀNH CÂU (Ẩn chữ) - 4 Câu
      // -----------------------------------------------------
      // 9. Ghép câu: Khẳng định (Anh ấy là người Mỹ)
      {
        'type': LessonType.sentenceBuilder,
        'jp': '',
        'rmj': '',
        'audio_text': '彼はアメリカ人です。',
        'words': ['彼', 'は', 'アメリカ', '人', 'です', 'じゃありません'],
        'answer': '彼 は アメリカ 人 です',
      },
      // 10. Ghép câu: Phủ định (Bố tôi không phải là người Mỹ)
      {
        'type': LessonType.sentenceBuilder,
        'jp': '',
        'rmj': '',
        'audio_text': '父はアメリカ人じゃありません。',
        'words': ['父', 'は', 'アメリカ', '人', 'じゃありません', '日本'],
        'answer': '父 は アメリカ 人 じゃありません',
      },
      // 11. Ghép câu: Khẳng định (Mẹ tôi là người Nhật Bản)
      {
        'type': LessonType.sentenceBuilder,
        'jp': '',
        'rmj': '',
        'audio_text': '母は日本人です。',
        'words': ['母', 'は', '日本', '人', 'です', 'アメリカ'],
        'answer': '母 は 日本 人 です',
      },
      // 12. Ghép câu: Phủ định tổng hợp
      {
        'type': LessonType.sentenceBuilder,
        'jp': '',
        'rmj': '',
        'audio_text': '私は日本人じゃありません。',
        'words': ['私', 'は', '日本', '人', 'じゃありません', 'です'],
        'answer': '私 は 日本 人 じゃありません',
      },

      // -----------------------------------------------------
      // NHÓM 4: LUYỆN NÓI & VẼ KANJI - 3 Câu
      // -----------------------------------------------------
      // 13. Luyện nói: アメリカ
      {
        'type': LessonType.speaking,
        'jp': 'アメリカ人',
        'answer': 'アメリカじん', // Để hiragana để AI dễ bắt âm "jin" hơn
      },
      // 14. Luyện nói: Câu phủ định
      {
        'type': LessonType.speaking,
        'jp': '日本人じゃありません',
        'answer': 'にほんじんじゃありません',
      },
      // 15. Vẽ Kanji: Chữ Nhân (人)
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '〜人',
        'kanji_target': '人',
        'meaning': 'Nhân (Người)',
        'rmj': 'jin',
      },
    ];
  }

  List<Map<String, dynamic>> _getCb2LuyenTap2Data() {
    return [
      // -----------------------------------------------------
      // NHÓM 1: TỪ VỰNG ĐƠN LẺ (Hình ảnh & Nghe) - 4 Câu
      // -----------------------------------------------------
      // 1. Hình ảnh: Mèo
      {
        'type': LessonType.imageQuiz,
        'question': 'Mèo.',
        'answerIndex': 1,
        'options': [
          {'img': 'assets/images/example_inu.png', 'jp': '犬', 'rmj': 'inu'},
          {'img': 'assets/images/example_neko.png', 'jp': '猫', 'rmj': 'neko'},
          {'img': 'assets/images/example_suki.png', 'jp': '好き', 'rmj': 'suki'},
          {
            'img': 'assets/images/example_watashitachi.png',
            'jp': '私たち',
            'rmj': 'watashitachi',
          },
        ],
      },
      // 2. Nghe: Chó
      {
        'type': LessonType.listening,
        'options': [
          {'kanji': '猫', 'hiragana': 'ねこ'},
          {'kanji': '犬', 'hiragana': 'いぬ'},
          {'kanji': '好き', 'hiragana': 'すき'},
          {'kanji': '人', 'hiragana': 'じん'},
        ],
        'answer': '犬',
      },
      // 3. Hình ảnh: Thích
      {
        'type': LessonType.imageQuiz,
        'question': 'Thích.',
        'answerIndex': 2,
        'options': [
          {'img': 'assets/images/example_neko.png', 'jp': '猫', 'rmj': 'neko'},
          {'img': 'assets/images/example_inu.png', 'jp': '犬', 'rmj': 'inu'},
          {'img': 'assets/images/example_suki.png', 'jp': '好き', 'rmj': 'suki'},
          {
            'img': 'assets/images/example_nihon.png',
            'jp': '日本',
            'rmj': 'nihon',
          },
        ],
      },
      // 4. Trắc nghiệm chữ: Chúng tôi (Ứng dụng たち)
      {
        'type': LessonType.vocabQuiz,
        'kanji': '私たち',
        'hiragana': 'わたしたち',
        'romaji': 'watashitachi',
        'options': ['các bạn', 'chúng tôi', 'bọn họ', 'bạn bè'],
        'answer': 'chúng tôi',
      },

      // -----------------------------------------------------
      // NHÓM 2: CHỌN CÂU DÀI & ĐỌC HIỂU (Focus: 〜たち & 好き) - 4 Câu
      // -----------------------------------------------------
      // 5. Nghe và chọn câu: Chúng tôi thích chó
      {
        'type': LessonType.quiz,
        'question': 'Chúng tôi thích chó.',
        'audio_text': '私たちは犬が好きです。',
        'options': [
          {'kanji': '私たちは猫が好きです。', 'hiragana': 'わたしたちはねこがすきです。'},
          {'kanji': '私たちは犬が好きです。', 'hiragana': 'わたしたちはいぬがすきです。'},
        ],
        'answer': '私たちは犬が好きです。',
      },
      // 6. Đọc và dịch câu: Các bạn là học sinh
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'あなたたちは学生です。',
        'rmj': 'Anatatachi wa gakusei desu.',
        'audio_text': 'あなたたちは学生です。',
        'words': [
          'các bạn',
          'là',
          'học sinh',
          'giáo viên',
          'chúng tôi',
          'không phải',
        ],
        'answer': 'các bạn là học sinh',
      },
      // 7. Nghe và chọn câu: Chúng tôi không phải là người Mỹ
      {
        'type': LessonType.quiz,
        'question': 'Chúng tôi không phải là người Mỹ.',
        'audio_text': '私たちはアメリカ人じゃありません。',
        'options': [
          {'kanji': '私たちはアメリカ人じゃありません。', 'hiragana': 'わたしたちはアメリカ人じゃありません。'},
          {'kanji': '私たちは日本人じゃありません。', 'hiragana': 'わたしたちは日本人じゃありません。'},
        ],
        'answer': '私たちはアメリカ人じゃありません。',
      },
      // 8. Đọc và dịch câu: Tôi thích mèo
      {
        'type': LessonType.sentenceBuilder,
        'jp': '私は猫が好きです。',
        'rmj': 'Watashi wa neko ga suki desu.',
        'audio_text': '私は猫が好きです。',
        'words': ['tôi', 'thích', 'mèo', 'chó', 'không thích', 'của'],
        'answer': 'tôi thích mèo',
      },

      // -----------------------------------------------------
      // NHÓM 3: NGHE VÀ GHÉP TỪ THÀNH CÂU (Ẩn chữ) - 4 Câu
      // -----------------------------------------------------
      // 9. Ghép câu: Chúng tôi thích mèo
      {
        'type': LessonType.sentenceBuilder,
        'jp': '',
        'rmj': '',
        'audio_text': '私たちは猫が好きです。',
        'words': ['私', 'たち', 'は', '猫', 'が', '好き', 'です'],
        'answer': '私 たち は 猫 が 好き です',
      },
      // 10. Ghép câu: Các giáo viên là người Nhật Bản (Ghép たち vào sau nghề nghiệp)
      {
        'type': LessonType.sentenceBuilder,
        'jp': '',
        'rmj': '',
        'audio_text': '先生たちは日本人です。',
        'words': ['先生', 'たち', 'は', '日本', '人', 'です', 'アメリカ'],
        'answer': '先生 たち は 日本 人 です',
      },
      // 11. Ghép câu: Không thích chó (Ôn lại じゃありません)
      {
        'type': LessonType.sentenceBuilder,
        'jp': '',
        'rmj': '',
        'audio_text': '犬が好きじゃありません。',
        'words': ['犬', 'が', '好き', 'じゃありません', '猫', 'です'],
        'answer': '犬 が 好き じゃありません',
      },
      // 12. Ghép câu: Chúng tôi cũng thích chó (Ôn trợ từ も ghép với たち)
      {
        'type': LessonType.sentenceBuilder,
        'jp': '',
        'rmj': '',
        'audio_text': '私たちも犬が好きです。',
        'words': ['私', 'たち', 'も', '犬', 'が', '好き', 'です'],
        'answer': '私 たち も 犬 が 好き です',
      },

      // -----------------------------------------------------
      // NHÓM 4: LUYỆN NÓI & VẼ KANJI - 3 Câu
      // -----------------------------------------------------
      // 13. Luyện nói: Thích chó
      {'type': LessonType.speaking, 'jp': '犬が好きです', 'answer': 'いぬがすきです'},
      // 14. Luyện nói: Chúng tôi
      {'type': LessonType.speaking, 'jp': '私たち', 'answer': 'わたしたち'},
      // 15. Vẽ Kanji: Chữ Khuyển (犬)
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '犬',
        'kanji_target': '犬',
        'meaning': 'Khuyển (Chó)',
        'rmj': 'inu',
      },
    ];
  }

  List<Map<String, dynamic>> _getCb2LuyenTap3Data() {
    return [
      // -----------------------------------------------------
      // NHÓM 1: LÀM QUEN TRỢ TỪ 「も」 - 4 Câu
      // -----------------------------------------------------
      // 1. Trắc nghiệm ngữ pháp: Nhận diện
      {
        'type': LessonType.quiz,
        'question': 'Trợ từ nào mang ý nghĩa "Cũng" (thay thế cho trợ từ は)?',
        'options': ['が (ga)', 'は (wa)', 'も (mo)', 'の (no)'],
        'answer': 'も (mo)',
      },
      // 2. Điền từ (Gây nhiễu は và も)
      {
        'type': LessonType.quiz,
        'question': 'Điền trợ từ: \n私は日本人です。彼 ( ... ) 日本人です。',
        'options': ['は', 'も', 'が', 'に'],
        'answer': 'も',
      },
      // 3. Đọc và dịch câu: Tôi cũng thích chó
      {
        'type': LessonType.sentenceBuilder,
        'jp': '私も犬が好きです。',
        'rmj': 'Watashi mo inu ga suki desu.',
        'audio_text': '私も犬が好きです。',
        'words': ['tôi', 'cũng', 'thích', 'chó', 'mèo', 'thì'],
        'answer': 'tôi cũng thích chó',
      },
      // 4. Ghép câu tiếng Nhật: Bọn họ cũng là người Mỹ
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'Bọn họ cũng là người Mỹ.',
        'rmj': 'Karera mo Amerikajin desu.',
        'audio_text': '彼らもアメリカ人です。',
        'words': [
          '彼',
          'ら',
          'も',
          'アメリカ',
          '人',
          'です',
          'は',
          'たち',
        ], // Nhiễu "は" và "たち"
        'answer': '彼 ら も アメリカ 人 です',
      },

      // -----------------------------------------------------
      // NHÓM 2: PHỦ ĐỊNH & SỐ NHIỀU VỚI 「も」 - 4 Câu
      // -----------------------------------------------------
      // 5. Nghe và chọn câu tiếng Việt (Ẩn chữ)
      {
        'type': LessonType.quiz,
        'question': '', // Audio only
        'audio_text': '私たちも日本人じゃありません。',
        'options': [
          'Chúng tôi không phải người Nhật Bản.',
          'Chúng tôi cũng không phải người Nhật Bản.',
          'Bọn họ cũng không phải người Nhật Bản.',
        ],
        'answer': 'Chúng tôi cũng không phải người Nhật Bản.',
      },
      // 6. Ghép câu tiếng Nhật (Ẩn chữ): Cô ấy cũng không phải là người Mỹ
      {
        'type': LessonType.sentenceBuilder,
        'jp': '',
        'rmj': '',
        'audio_text': '彼女もアメリカ人じゃありません。',
        'words': [
          '彼女',
          'も',
          'アメリカ',
          '人',
          'じゃありません',
          'は',
          'です',
        ], // Nhiễu "は" và "です"
        'answer': '彼女 も アメリカ 人 じゃありません',
      },
      // 7. Nghe chọn đáp án tiếng Nhật (Phân biệt Bạn / Anh ấy / Tôi)
      {
        'type': LessonType.listening,
        'options': [
          {'kanji': '彼も日本人ですか。', 'hiragana': 'かれもにほんじんですか。'},
          {'kanji': 'あなたも日本人ですか。', 'hiragana': 'あなたもにほんじんですか。'},
          {'kanji': '私も日本人です。', 'hiragana': 'わたしもにほんじんです。'},
        ],
        'answer': 'あなたも日本人ですか。', // Bạn cũng là người Nhật à?
      },
      // 8. Đọc và dịch câu: Mẹ tôi cũng không thích mèo (Nhiễu が và も)
      {
        'type': LessonType.sentenceBuilder,
        'jp': '母も猫が好きじゃありません。',
        'rmj': 'Haha mo neko ga suki ja arimasen.',
        'audio_text': '母も猫が好きじゃありません。',
        'words': ['mẹ', 'cũng', 'không thích', 'mèo', 'chó', 'thì'],
        'answer': 'mẹ cũng không thích mèo',
      },

      // -----------------------------------------------------
      // NHÓM 3: LUYỆN NGHE PHẢN XẠ SÂU (Ẩn chữ) - 4 Câu
      // -----------------------------------------------------
      // 9. Nghe và ghép câu (Khẳng định - Người Nhật Bản cũng thích mèo)
      {
        'type': LessonType.sentenceBuilder,
        'jp': '',
        'rmj': '',
        'audio_text': '日本人も猫が好きです。',
        'words': ['日本', '人', 'も', '猫', 'が', '好き', 'です', 'は'],
        'answer': '日本 人 も 猫 が 好き です',
      },
      // 10. Nghe và ghép câu (Số nhiều + Phủ định)
      {
        'type': LessonType.sentenceBuilder,
        'jp': '',
        'rmj': '',
        'audio_text': '彼らもアメリカ人じゃありません。',
        'words': [
          '彼',
          'ら',
          'も',
          'アメリカ',
          '人',
          'じゃありません',
          'たち',
        ], // Phân biệt ら và たち
        'answer': '彼 ら も アメリカ 人 じゃありません',
      },
      // 11. Nghe và chọn câu tương ứng (So sánh は và も)
      {
        'type': LessonType.quiz,
        'question': 'Tôi cũng thích chó.',
        'audio_text': '私も犬が好きです。',
        'options': [
          {'kanji': '私は犬が好きです。', 'hiragana': 'わたしはいぬがすきです。'},
          {'kanji': '私も犬が好きです。', 'hiragana': 'わたしもいぬがすきです。'},
        ],
        'answer': '私も犬が好きです。',
      },
      // 12. Nghe và ghép câu (Trùm cuối: Số nhiều + Sở thích + Cũng)
      {
        'type': LessonType.sentenceBuilder,
        'jp': '',
        'rmj': '',
        'audio_text': '私たちも猫が好きです。',
        'words': ['私', 'たち', 'も', '猫', 'が', '好き', 'です', 'は'],
        'answer': '私 たち も 猫 が 好き です',
      },

      // -----------------------------------------------------
      // NHÓM 4: LUYỆN NÓI & VẼ KANJI - 3 Câu
      // -----------------------------------------------------
      // 13. Luyện nói: Trợ từ も
      {'type': LessonType.speaking, 'jp': '私も好きです', 'answer': 'わたしもすきです'},
      // 14. Vẽ Kanji: 猫 (Mèo)
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '猫',
        'kanji_target': '猫',
        'meaning': 'Miêu (Mèo)',
        'rmj': 'neko',
      },
      // 15. Vẽ Kanji: 好き (Thích)
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '好き',
        'kanji_target': '好',
        'meaning': 'Hảo (Thích)',
        'rmj': 'su(ki)',
      },
    ];
  }

  List<Map<String, dynamic>> _getCb2LuyenNoiData() {
    return [
      {
        'type': LessonType.speaking,
        'jp': '私たちは日本人です。',
        'answer': 'わたしたちはにほんじんです', // Watashitachi wa Nihonjin desu
      },
      {
        'type': LessonType.speaking,
        'jp': '彼らはアメリカ人じゃありません。',
        'answer': 'かれらはアメリカじんじゃありません', // Karera wa Amerikajin ja arimasen
      },
      {
        'type': LessonType.speaking,
        'jp': '私も犬が好きです。',
        'answer': 'わたしもいぬがすきです', // Watashi mo inu ga suki desu
      },
      {
        'type': LessonType.speaking,
        'jp': '猫が好きじゃありません。',
        'answer': 'ねこがすきじゃありません', // Neko ga suki ja arimasen
      },
      {
        'type': LessonType.speaking,
        'jp': '日本人も猫が好きです。',
        'answer': 'にほんじんもねこがすきです', // Nihonjin mo neko ga suki desu
      },
    ];
  }

  List<Map<String, dynamic>> _getCb2LuyenVietData() {
    return [
      // 1. Chữ Nhật
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '日本',
        'kanji_target': '日',
        'meaning': 'Nhật (Mặt trời / Ngày)',
        'rmj': 'ni',
      },
      // 2. Chữ Bản
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '日本',
        'kanji_target': '本',
        'meaning': 'Bản (Gốc / Sách)',
        'rmj': 'hon',
      },
      // 3. Chữ Nhân
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '〜人',
        'kanji_target': '人',
        'meaning': 'Nhân (Người)',
        'rmj': 'jin / hito',
      },
      // 4. Chữ Khuyển
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '犬',
        'kanji_target': '犬',
        'meaning': 'Khuyển (Chó)',
        'rmj': 'inu',
      },
      // 5. Chữ Miêu
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '猫',
        'kanji_target': '猫',
        'meaning': 'Miêu (Mèo)',
        'rmj': 'neko',
      },
      // 6. Chữ Hảo (Thích)
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '好き',
        'kanji_target': '好',
        'meaning': 'Hảo (Thích)',
        'rmj': 'su(ki)',
      },
      // 7. Chốt lại bằng Game ghép Kanji
      {
        'type': LessonType.matching,
        'pairs': [
          {'left': 'Nhật Bản', 'right': '日本'},
          {'left': 'Người', 'right': '人'},
          {'left': 'Chó', 'right': '犬'},
          {'left': 'Mèo', 'right': '猫'},
          {'left': 'Thích', 'right': '好き'},
        ],
      },
    ];
  }

  List<Map<String, dynamic>> _getCb3LyThuyetData() {
    return [
      // ================= PHẦN 1: TỪ VỰNG =================
      {
        'type': LessonType.vocabListIntro,
        'words': [
          {
            'kanji': 'これ',
            'hiragana': 'これ',
            'romaji': 'kore',
            'meaning': 'Cái này (gần người nói)',
          },
          {
            'kanji': 'それ',
            'hiragana': 'それ',
            'romaji': 'sore',
            'meaning': 'Cái đó (gần người nghe)',
          },
          {
            'kanji': 'あれ',
            'hiragana': 'あれ',
            'romaji': 'are',
            'meaning': 'Cái kia (xa cả hai)',
          },
          {
            'kanji': '本',
            'hiragana': 'ほん',
            'romaji': 'hon',
            'meaning': 'Quyển sách',
          },
          {
            'kanji': '傘',
            'hiragana': 'かさ',
            'romaji': 'kasa',
            'meaning': 'Cái ô (dù)',
          },
          {
            'kanji': '車',
            'hiragana': 'くるま',
            'romaji': 'kuruma',
            'meaning': 'Ô tô',
          },
          {
            'kanji': 'いくら',
            'hiragana': 'いくら',
            'romaji': 'ikura',
            'meaning': 'Bao nhiêu (tiền)',
          },
          {
            'kanji': '円',
            'hiragana': 'えん',
            'romaji': 'en',
            'meaning': 'Yên (tiền Nhật)',
          },
        ],
      },

      // --- NHÓM TỪ 1: CHỈ ĐỊNH TỪ ---
      {
        'type': LessonType.flashCard,
        'kanji': 'これ',
        'hiragana': 'これ',
        'romaji': 'kore',
        'meaning': 'Cái này',
        'example_img': 'assets/images/example_kore.png',
        'example_jp': 'これは本です。',
        'example_rmj': 'Kore wa hon desu.',
        'example_vn': 'Cái này là quyển sách.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': 'それ',
        'hiragana': 'それ',
        'romaji': 'sore',
        'meaning': 'Cái đó',
        'example_img': 'assets/images/example_sore.png',
        'example_jp': 'それは傘ですか。',
        'example_rmj': 'Sore wa kasa desu ka.',
        'example_vn': 'Cái đó là cái ô phải không?',
      },
      {
        'type': LessonType.flashCard,
        'kanji': 'あれ',
        'hiragana': 'あれ',
        'romaji': 'are',
        'meaning': 'Cái kia',
        'example_img': 'assets/images/example_are.png',
        'example_jp': 'あれは車です。',
        'example_rmj': 'Are wa kuruma desu.',
        'example_vn': 'Cái kia là ô tô.',
      },
      {
        'type': LessonType.vocabQuiz,
        'kanji': 'これ',
        'hiragana': 'これ',
        'romaji': 'kore',
        'options': ['cái kia', 'cái này', 'cái đó', 'ở đâu'],
        'answer': 'cái này',
      },
      {
        'type': LessonType.listening,
        'options': ['これ', 'それ', 'あれ', 'どれ'],
        'answer': 'あれ',
      },

      // --- NHÓM TỪ 2: ĐỒ VẬT & TIỀN TỆ ---
      {
        'type': LessonType.flashCard,
        'kanji': '本',
        'hiragana': 'ほん',
        'romaji': 'hon',
        'meaning': 'Quyển sách',
        'example_img': 'assets/images/example_hon.png',
        'example_jp': '私の本です。',
        'example_rmj': 'Watashi no hon desu.',
        'example_vn': 'Là sách của tôi.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': '傘',
        'hiragana': 'かさ',
        'romaji': 'kasa',
        'meaning': 'Cái ô (dù)',
        'example_img': 'assets/images/example_kasa.png',
        'example_jp': 'これは傘です。',
        'example_rmj': 'Kore wa kasa desu.',
        'example_vn': 'Cái này là cái ô.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': '車',
        'hiragana': 'くるま',
        'romaji': 'kuruma',
        'meaning': 'Ô tô',
        'example_img': 'assets/images/example_kuruma.png',
        'example_jp': '日本の車です。',
        'example_rmj': 'Nihon no kuruma desu.',
        'example_vn': 'Là ô tô của Nhật Bản.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': 'いくら',
        'hiragana': 'いくら',
        'romaji': 'ikura',
        'meaning': 'Bao nhiêu tiền',
        'example_img': 'assets/images/example_ikura.png',
        'example_jp': 'これはいくらですか。',
        'example_rmj': 'Kore wa ikura desu ka.',
        'example_vn': 'Cái này giá bao nhiêu tiền?',
      },
      {
        'type': LessonType.vocabQuiz,
        'kanji': '車',
        'hiragana': 'くるま',
        'romaji': 'kuruma',
        'options': ['ô tô', 'xe đạp', 'quyển sách', 'cái ô'],
        'answer': 'ô tô',
      },
      {
        'type': LessonType.listening,
        'options': ['ほん', 'かさ', 'くるま', 'いくら'],
        'answer': 'いくら',
      },

      // ================= PHẦN 2: NGỮ PHÁP =================
      {
        'type': LessonType.grammarListIntro,
        'grammars': [
          {'title': 'これ / それ / あれ', 'meaning': 'Cái này / Cái đó / Cái kia'},
          {'title': 'Trợ từ 「の」', 'meaning': 'Của (Sở hữu) / Xuất xứ'},
          {'title': '〜はいくらですか', 'meaning': '~ giá bao nhiêu tiền?'},
        ],
      },

      // NGỮ PHÁP 1: Đại từ chỉ thị
      {
        'type': LessonType.grammarStructure,
        'title': 'ĐẠI TỪ CHỈ THỊ',
        'formula': 'これ / それ / あれ + は + N + です',
        'meaning': 'Cái này / đó / kia là N',
      },
      {
        'type': LessonType.grammarUsage,
        'title': 'これ / それ / あれ',
        'notes': [
          'これ (Kore): Chỉ vật ở gần người nói.',
          'それ (Sore): Chỉ vật ở gần người nghe.',
          'あれ (Are): Chỉ vật ở xa cả người nói và người nghe.',
          'Chúng đóng vai trò như một danh từ độc lập làm chủ ngữ trong câu.',
        ],
      },
      {
        'type': LessonType.grammarExample,
        'title': 'ĐẠI TỪ CHỈ THỊ',
        'img': 'assets/images/example_kore.png',
        'jp': 'これは本です。',
        'rmj': 'Kore wa hon desu.',
        'vn': 'Cái này là quyển sách.',
      },

      // NGỮ PHÁP 2: Trợ từ の
      {
        'type': LessonType.grammarStructure,
        'title': 'TRỢ TỪ 「の」',
        'formula': 'N1 + の + N2',
        'meaning': 'N2 của N1 / N2 xuất xứ từ N1',
      },
      {
        'type': LessonType.grammarUsage,
        'title': 'TRỢ TỪ 「の」',
        'notes': [
          'Dùng để nối 2 danh từ. N1 giải thích, bổ nghĩa cho N2.',
          'Thường mang nghĩa sở hữu (Sách CỦA tôi) hoặc xuất xứ (Ô tô CỦA Nhật Bản).',
          'Dịch ngược từ N2 về N1 so với tiếng Việt.',
        ],
      },
      {
        'type': LessonType.grammarExample,
        'title': 'TRỢ TỪ 「の」',
        'img': 'assets/images/example_watashinohon.png',
        'jp': '私の本です。',
        'rmj': 'Watashi no hon desu.',
        'vn': 'Là quyển sách CỦA tôi.',
      },

      // NGỮ PHÁP 3: Hỏi giá
      {
        'type': LessonType.grammarStructure,
        'title': 'HỎI GIÁ TIỀN',
        'formula': 'N + は + いくら + ですか',
        'meaning': 'N giá bao nhiêu tiền?',
      },
      {
        'type': LessonType.grammarUsage,
        'title': '〜はいくらですか',
        'notes': [
          'Dùng từ để hỏi「いくら」để hỏi giá cả của một món đồ.',
          'Kết thúc câu hỏi luôn phải có trợ từ 「か」 ở cuối.',
        ],
      },
      {
        'type': LessonType.grammarExample,
        'title': 'HỎI GIÁ TIỀN',
        'img': 'assets/images/example_ikura.png',
        'jp': 'それはいくらですか。',
        'rmj': 'Sore wa ikura desu ka.',
        'vn': 'Cái đó giá bao nhiêu tiền?',
      },

      // ================= PHẦN 3: TỔNG KẾT =================
      {
        'type': LessonType.vocabSummary,
        'words': [
          {'kanji': 'これ', 'romaji': 'kore', 'meaning': 'cái này'},
          {'kanji': 'それ', 'romaji': 'sore', 'meaning': 'cái đó'},
          {'kanji': 'あれ', 'romaji': 'are', 'meaning': 'cái kia'},
          {'kanji': '本', 'romaji': 'hon', 'meaning': 'sách'},
          {'kanji': '傘', 'romaji': 'kasa', 'meaning': 'cái ô'},
          {'kanji': '車', 'romaji': 'kuruma', 'meaning': 'ô tô'},
          {'kanji': 'いくら', 'romaji': 'ikura', 'meaning': 'bao nhiêu tiền'},
        ],
      },
    ];
  }

  List<Map<String, dynamic>> _getCb3LuyenTap1Data() {
    return [
      // 1. CÂU HỎI HÌNH ẢNH (Phát huy sức mạnh của GridView hình ảnh)
      {
        'type': LessonType.imageQuiz,
        'question': 'Quyển sách.',
        'answerIndex': 0,
        'options': [
          {'img': 'assets/images/example_hon.png', 'jp': '本', 'rmj': 'hon'},
          {
            'img': 'assets/images/example_kuruma.png',
            'jp': '車',
            'rmj': 'kuruma',
          },
          {'img': 'assets/images/example_kasa.png', 'jp': '傘', 'rmj': 'kasa'},
          {'img': 'assets/images/example_inu.png', 'jp': '犬', 'rmj': 'inu'},
        ],
      },
      // 2. NGHE CHỮ CÁI
      {
        'type': LessonType.listening,
        'options': [
          {'kanji': '本', 'hiragana': 'ほん'},
          {'kanji': '傘', 'hiragana': 'かさ'},
          {'kanji': '車', 'hiragana': 'くるま'},
          {'kanji': '円', 'hiragana': 'えん'},
        ],
        'answer': '車',
      },
      // 3. CHỌN CÂU DÀI (Test UI nút dài)
      {
        'type': LessonType.quiz,
        'question': 'Cái này là cái ô.',
        'audio_text': 'これは傘です。',
        'options': [
          {'kanji': 'あれは傘です。', 'hiragana': 'あれはかさです。'},
          {'kanji': 'これは傘です。', 'hiragana': 'これはかさです。'},
        ],
        'answer': 'これは傘です。',
      },
      // 4. ĐỌC VÀ DỊCH CÂU (Lắp ráp sở hữu "の")
      {
        'type': LessonType.sentenceBuilder,
        'jp': '私の本です。',
        'rmj': 'Watashi no hon desu.',
        'audio_text': '私の本です。',
        'words': ['sách', 'của', 'tôi', 'là', 'cái này', 'ô tô'],
        'answer': 'là sách của tôi',
      },
      // 5. NGHE VÀ GHÉP TỪ (Kiểm tra xem User có biết ghép N1 no N2 không)
      {
        'type': LessonType.sentenceBuilder,
        'jp': '',
        'rmj': '',
        'audio_text': 'これは日本の車です。',
        'words': ['これ', 'は', '日本', 'の', '車', 'です', 'アメリカ'],
        'answer': 'これ は 日本 の 車 です',
      },
      // 6. LUYỆN NÓI
      {'type': LessonType.speaking, 'jp': 'いくらですか', 'answer': 'いくらですか'},
      // 7. VẼ KANJI (Sách)
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '本',
        'kanji_target': '本',
        'meaning': 'Bản (Sách)',
        'rmj': 'hon',
      },
    ];
  }

  List<Map<String, dynamic>> _getCb3LuyenTap2Data() {
    return [
      // -----------------------------------------------------
      // NHÓM 1: TỪ VỰNG ĐƠN LẺ - 4 Câu
      // -----------------------------------------------------
      // 1. Trắc nghiệm chữ: Cái này
      {
        'type': LessonType.vocabQuiz,
        'kanji': 'これ',
        'hiragana': 'これ',
        'romaji': 'kore',
        'options': ['cái kia', 'cái đó', 'cái này', 'ở đâu'],
        'answer': 'cái này',
      },
      // 2. Nghe: Cái đó
      {
        'type': LessonType.listening,
        'options': [
          {'kanji': 'これ', 'hiragana': 'これ'},
          {'kanji': 'それ', 'hiragana': 'それ'},
          {'kanji': 'あれ', 'hiragana': 'あれ'},
          {'kanji': 'どれ', 'hiragana': 'どれ'},
        ],
        'answer': 'それ',
      },
      // 3. Trắc nghiệm chữ: Bao nhiêu tiền
      {
        'type': LessonType.vocabQuiz,
        'kanji': 'いくら',
        'hiragana': 'いくら',
        'romaji': 'ikura',
        'options': [
          'bao nhiêu tiền',
          'như thế nào',
          'cái nào',
          'bao nhiêu tuổi',
        ],
        'answer': 'bao nhiêu tiền',
      },
      // 4. Nghe: Cái kia
      {
        'type': LessonType.listening,
        'options': [
          {'kanji': 'これ', 'hiragana': 'これ'},
          {'kanji': 'それ', 'hiragana': 'それ'},
          {'kanji': 'あれ', 'hiragana': 'あれ'},
          {'kanji': '車', 'hiragana': 'くるま'},
        ],
        'answer': 'あれ',
      },

      // -----------------------------------------------------
      // NHÓM 2: CHỌN CÂU & ĐỌC DỊCH - 4 Câu
      // -----------------------------------------------------
      // 5. Nghe và chọn câu: Cái này bao nhiêu tiền?
      {
        'type': LessonType.quiz,
        'question': 'Cái này bao nhiêu tiền?',
        'audio_text': 'これはいくらですか。',
        'options': [
          {'kanji': 'それはいくらですか。', 'hiragana': 'それはいくらですか。'},
          {'kanji': 'これはいくらですか。', 'hiragana': 'これはいくらですか。'},
        ],
        'answer': 'これはいくらですか。',
      },
      // 6. Đọc và dịch câu: Cái đó là ô tô
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'それは車です。',
        'rmj': 'Sore wa kuruma desu.',
        'audio_text': 'それは車です。',
        'words': ['cái đó', 'là', 'ô tô', 'cái này', 'sách', 'bao nhiêu'],
        'answer': 'cái đó là ô tô',
      },
      // 7. Nghe và chọn câu: Cái kia không phải là cái ô
      {
        'type': LessonType.quiz,
        'question': 'Cái kia không phải là cái ô.',
        'audio_text': 'あれは傘じゃありません。',
        'options': [
          {'kanji': 'あれは傘じゃありません。', 'hiragana': 'あれはかさじゃありません。'},
          {'kanji': 'これは傘じゃありません。', 'hiragana': 'これはかさじゃありません。'},
        ],
        'answer': 'あれは傘じゃありません。',
      },
      // 8. Đọc và dịch câu: Cái này là sách
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'これは本です。',
        'rmj': 'Kore wa hon desu.',
        'audio_text': 'これは本です。',
        'words': ['cái này', 'là', 'sách', 'cái kia', 'của', 'không phải'],
        'answer': 'cái này là sách',
      },

      // -----------------------------------------------------
      // NHÓM 3: NGHE VÀ GHÉP CÂU (Ẩn chữ) - 4 Câu
      // -----------------------------------------------------
      // 9. Ghép câu: Cái đó là cái ô phải không? (Thêm trợ từ か)
      {
        'type': LessonType.sentenceBuilder,
        'jp': '',
        'rmj': '',
        'audio_text': 'それは傘ですか。',
        'words': ['それ', 'は', '傘', 'です', 'か', 'これ', 'あれ'],
        'answer': 'それ は 傘 です か',
      },
      // 10. Ghép câu: Cái kia cũng là ô tô (Ôn lại も)
      {
        'type': LessonType.sentenceBuilder,
        'jp': '',
        'rmj': '',
        'audio_text': 'あれも車です。',
        'words': ['あれ', 'も', '車', 'です', 'は', 'これ'],
        'answer': 'あれ も 車 です',
      },
      // 11. Ghép câu: Cái đó không phải là sách
      {
        'type': LessonType.sentenceBuilder,
        'jp': '',
        'rmj': '',
        'audio_text': 'それは本じゃありません。',
        'words': ['それ', 'は', '本', 'じゃありません', 'も', '傘'],
        'answer': 'それ は 本 じゃありません',
      },
      // 12. Ghép câu: Cái này bao nhiêu tiền?
      {
        'type': LessonType.sentenceBuilder,
        'jp': '',
        'rmj': '',
        'audio_text': 'これはいくらですか。',
        'words': ['これ', 'は', 'いくら', 'です', 'か', 'それ'],
        'answer': 'これ は いくら です か',
      },

      // -----------------------------------------------------
      // NHÓM 4: LUYỆN NÓI & VẼ KANJI - 3 Câu
      // -----------------------------------------------------
      // 13. Luyện nói: Cái kia là ô tô
      {'type': LessonType.speaking, 'jp': 'あれは車です', 'answer': 'あれはくるまです'},
      // 14. Vẽ Kanji: Chữ Xa (車 - Ô tô)
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '車',
        'kanji_target': '車',
        'meaning': 'Xa (Ô tô)',
        'rmj': 'kuruma',
      },
      // 15. Vẽ Kanji: Chữ Viên (円 - Tiền Yên)
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '円',
        'kanji_target': '円',
        'meaning': 'Viên (Đơn vị tiền)',
        'rmj': 'en',
      },
    ];
  }

  List<Map<String, dynamic>> _getCb3LuyenTap3Data() {
    return [
      {
        'type': LessonType.quiz,
        'question':
            'Điền trợ từ thích hợp (mang nghĩa sở hữu): \n私 ( ... ) 本です。',
        'options': ['が', 'は', 'の', 'も'],
        'answer': 'の',
      },
      // 2. Trắc nghiệm chữ: Yên (Tiền tệ)
      {
        'type': LessonType.vocabQuiz,
        'kanji': '円',
        'hiragana': 'えん',
        'romaji': 'en',
        'options': ['Đô la', 'Yên', 'Việt Nam Đồng', 'Won'],
        'answer': 'Yên',
      },
      // 3. Đọc và dịch câu: Sách của tôi
      {
        'type': LessonType.sentenceBuilder,
        'jp': '私の本です。',
        'rmj': 'Watashi no hon desu.',
        'audio_text': '私の本です。',
        'words': ['là', 'sách', 'của', 'tôi', 'bố', 'cái này'],
        'answer': 'là sách của tôi',
      },
      // 4. Ghép câu tiếng Nhật: Ô tô của Nhật Bản
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'Ô tô của Nhật Bản.',
        'rmj': 'Nihon no kuruma desu.',
        'audio_text': '日本の車です。',
        'words': ['日本', 'の', '車', 'です', 'アメリカ', 'は'],
        'answer': '日本 の 車 です',
      },

      // -----------------------------------------------------
      // NHÓM 2: PHỦ ĐỊNH & KẾT HỢP の - 4 Câu
      // -----------------------------------------------------
      // 5. Nghe và chọn câu tiếng Việt (Ẩn chữ)
      {
        'type': LessonType.quiz,
        'question': '', // Audio only
        'audio_text': 'それは父の傘じゃありません。',
        'options': [
          'Cái đó là cái ô của bố.',
          'Cái này không phải là cái ô của bố.',
          'Cái đó không phải là cái ô của bố.',
        ],
        'answer': 'Cái đó không phải là cái ô của bố.',
      },
      // 6. Ghép câu tiếng Nhật (Ẩn chữ): Chó của cô ấy
      {
        'type': LessonType.sentenceBuilder,
        'jp': '',
        'rmj': '',
        'audio_text': '彼女の犬です。',
        'words': ['彼女', 'の', '犬', 'です', 'は', '彼'],
        'answer': '彼女 の 犬 です',
      },
      // 7. Nghe chọn đáp án tiếng Nhật (Hỏi giá kết hợp)
      {
        'type': LessonType.listening,
        'options': [
          {'kanji': 'あれはいくらですか。', 'hiragana': 'あれはいくらですか。'},
          {'kanji': 'これはいくらですか。', 'hiragana': 'これはいくらですか。'},
          {'kanji': 'それはいくらですか。', 'hiragana': 'それはいくらですか。'},
        ],
        'answer': 'これはいくらですか。', // Cái này giá bao nhiêu?
      },
      // 8. Đọc và dịch câu: Tôi thích ô tô Nhật Bản (Nhiễu の và が)
      {
        'type': LessonType.sentenceBuilder,
        'jp': '私は日本の車が好きです。',
        'rmj': 'Watashi wa Nihon no kuruma ga suki desu.',
        'audio_text': '私は日本の車が好きです。',
        'words': ['tôi', 'thích', 'ô tô', 'của', 'Nhật Bản', 'Mỹ'],
        'answer': 'tôi thích ô tô của Nhật Bản',
      },

      // -----------------------------------------------------
      // NHÓM 3: LUYỆN NGHE PHẢN XẠ SÂU (Ẩn chữ) - 4 Câu
      // -----------------------------------------------------
      // 9. Nghe và ghép câu (Cái kia là xe của bọn họ phải không?)
      {
        'type': LessonType.sentenceBuilder,
        'jp': '',
        'rmj': '',
        'audio_text': 'あれは彼らの車ですか。',
        'words': ['あれ', 'は', '彼', 'ら', 'の', '車', 'です', 'か'],
        'answer': 'あれ は 彼 ら の 車 です か',
      },
      // 10. Nghe và ghép câu (Sách của tôi cũng là cái này - Ôn trợ từ も)
      {
        'type': LessonType.sentenceBuilder,
        'jp': '',
        'rmj': '',
        'audio_text': '私の本もこれです。',
        'words': ['私', 'の', '本', 'も', 'これ', 'です', 'は'],
        'answer': '私 の 本 も これ です',
      },
      // 11. Nghe và chọn câu tương ứng
      {
        'type': LessonType.quiz,
        'question': 'Đó không phải là chó của tôi.',
        'audio_text': 'それは私の犬じゃありません。',
        'options': [
          {'kanji': 'これは私の犬じゃありません。', 'hiragana': 'これはわたしのいぬじゃありません。'},
          {'kanji': 'それは私の犬じゃありません。', 'hiragana': 'それはわたしのいぬじゃありません。'},
        ],
        'answer': 'それは私の犬じゃありません。',
      },
      // 12. Nghe và ghép câu (Trùm cuối: Phủ định + Số nhiều + Sở hữu)
      {
        'type': LessonType.sentenceBuilder,
        'jp': '',
        'rmj': '',
        'audio_text': 'あれは私たちの傘じゃありません。',
        'words': ['あれ', 'は', '私', 'たち', 'の', '傘', 'じゃありません'],
        'answer': 'あれ は 私 たち の 傘 じゃありません',
      },

      // -----------------------------------------------------
      // NHÓM 4: LUYỆN NÓI & GAME TỔNG HỢP - 3 Câu
      // -----------------------------------------------------
      // 13. Luyện nói: Sách của tôi
      {'type': LessonType.speaking, 'jp': '私の本です', 'answer': 'わたしのほんです'},
      // 14. Luyện nói: Bao nhiêu tiền
      {'type': LessonType.speaking, 'jp': 'いくらですか', 'answer': 'いくらですか'},
      // 15. Game ghép cặp: Tổng hợp từ vựng CB3
      {
        'type': LessonType.matching,
        'pairs': [
          {'left': 'Cái này', 'right': 'これ'},
          {'left': 'Cái đó', 'right': 'それ'},
          {'left': 'Cái kia', 'right': 'あれ'},
          {'left': 'Quyển sách', 'right': '本'},
          {'left': 'Ô tô', 'right': '車'},
          {'left': 'Bao nhiêu', 'right': 'いくら'},
        ],
      },
    ];
  }

  List<Map<String, dynamic>> _getCb3LuyenNoiData() {
    return [
      {
        'type': LessonType.speaking,
        'jp': 'これは私の本です。',
        'answer': 'これはわたしのほんです', // Kore wa watashi no hon desu
      },
      {
        'type': LessonType.speaking,
        'jp': 'それは日本の車です。',
        'answer': 'それはにほんのくるまです', // Sore wa Nihon no kuruma desu
      },
      {
        'type': LessonType.speaking,
        'jp': 'これはいくらですか。',
        'answer': 'これはいくらですか', // Kore wa ikura desu ka
      },
      {
        'type': LessonType.speaking,
        'jp': 'あれ là cái ô của tôi。',
        'jp_display': 'あれは私の傘です。', // Nếu bạn có trường hiển thị riêng
        'answer': 'あれはわたしのかさです', // Are wa watashi no kasa desu
      },
      {
        'type': LessonType.speaking,
        'jp': 'それは本じゃありません。',
        'answer': 'それはほんじゃありません', // Sore wa hon ja arimasen
      },
    ];
  }

  List<Map<String, dynamic>> _getCb3LuyenVietData() {
    return [
      // 1. Chữ Bản (Sách)
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '本',
        'kanji_target': '本',
        'meaning': 'Bản (Quyển sách)',
        'rmj': 'hon',
      },
      // 2. Chữ Xa (Ô tô)
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '車',
        'kanji_target': '車',
        'meaning': 'Xa (Ô tô)',
        'rmj': 'kuruma',
      },
      // 3. Chữ Viên (Tiền Yên)
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '円',
        'kanji_target': '円',
        'meaning': 'Viên (Tiền Yên Nhật)',
        'rmj': 'en',
      },
      // 4. Game ghép cặp Kanji & Nghĩa (Dành cho đồ vật)
      {
        'type': LessonType.matching,
        'pairs': [
          {'left': 'Quyển sách', 'right': '本'},
          {'left': 'Ô tô', 'right': '車'},
          {'left': 'Tiền Yên', 'right': '円'},
          {'left': 'Cái ô', 'right': '傘'},
          {'left': 'Cái này', 'right': 'これ'},
        ],
      },
    ];
  }

  List<Map<String, dynamic>> _getCb4LyThuyetData() {
    return [
      // ================= PHẦN 1: TỪ VỰNG =================
      {
        'type': LessonType.vocabListIntro,
        'words': [
          {
            'kanji': '今',
            'hiragana': 'いま',
            'romaji': 'ima',
            'meaning': 'Bây giờ',
          },
          {'kanji': '〜時', 'hiragana': '〜じ', 'romaji': '~ji', 'meaning': 'Giờ'},
          {
            'kanji': '〜分',
            'hiragana': '〜ふん / ぷん',
            'romaji': '~fun / pun',
            'meaning': 'Phút',
          },
          {
            'kanji': '毎日',
            'hiragana': 'まいにち',
            'romaji': 'mainichi',
            'meaning': 'Mỗi ngày',
          },
          {
            'kanji': '起きます',
            'hiragana': 'おきます',
            'romaji': 'okimasu',
            'meaning': 'Thức dậy',
          },
          {
            'kanji': '寝ます',
            'hiragana': 'ねます',
            'romaji': 'nemasu',
            'meaning': 'Ngủ',
          },
        ],
      },

      // --- NHÓM TỪ 1: THỜI GIAN ---
      {
        'type': LessonType.flashCard,
        'kanji': '今',
        'hiragana': 'いま',
        'romaji': 'ima',
        'meaning': 'Bây giờ',
        'example_img': 'assets/images/example_ima.png',
        'example_jp': '今は何時ですか。',
        'example_rmj': 'Ima wa nanji desu ka.',
        'example_vn': 'Bây giờ là mấy giờ?',
      },
      {
        'type': LessonType.flashCard,
        'kanji': '〜時',
        'hiragana': '〜じ',
        'romaji': '~ji',
        'meaning': 'Giờ',
        'example_img': 'assets/images/example_ji.png',
        'example_jp': '今は８時です。',
        'example_rmj': 'Ima wa hachiji desu.',
        'example_vn': 'Bây giờ là 8 giờ.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': '〜分',
        'hiragana': '〜ふん / ぷん',
        'romaji': '~fun / pun',
        'meaning': 'Phút',
        'example_img': 'assets/images/example_fun.png',
        'example_jp': '１０分です。',
        'example_rmj': 'Juppun desu.',
        'example_vn': 'Là 10 phút.',
      },
      {
        'type': LessonType.vocabQuiz,
        'kanji': '今',
        'hiragana': 'いま',
        'romaji': 'ima',
        'options': ['hôm nay', 'bây giờ', 'ngày mai', 'mỗi ngày'],
        'answer': 'bây giờ',
      },
      {
        'type': LessonType.listening,
        'options': ['いま', 'じ', 'ふん', 'なん'],
        'answer': 'じ',
      },

      // --- NHÓM TỪ 2: HOẠT ĐỘNG ---
      {
        'type': LessonType.flashCard,
        'kanji': '毎日',
        'hiragana': 'まいにち',
        'romaji': 'mainichi',
        'meaning': 'Mỗi ngày',
        'example_img': 'assets/images/example_mainichi.png',
        'example_jp': '毎日、勉強します。',
        'example_rmj': 'Mainichi, benkyou shimasu.',
        'example_vn': 'Mỗi ngày tôi đều học bài.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': '起きます',
        'hiragana': 'おきます',
        'romaji': 'okimasu',
        'meaning': 'Thức dậy',
        'example_img': 'assets/images/example_okimasu.png',
        'example_jp': '６時に起きます。',
        'example_rmj': 'Rokuji ni okimasu.',
        'example_vn': 'Tôi thức dậy lúc 6 giờ.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': '寝ます',
        'hiragana': 'ねます',
        'romaji': 'nemasu',
        'meaning': 'Ngủ',
        'example_img': 'assets/images/example_nemasu.png',
        'example_jp': '１０時に寝ます。',
        'example_rmj': 'Juuji ni nemasu.',
        'example_vn': 'Tôi đi ngủ lúc 10 giờ.',
      },
      {
        'type': LessonType.vocabQuiz,
        'kanji': '寝ます',
        'hiragana': 'ねます',
        'romaji': 'nemasu',
        'options': ['thức dậy', 'ăn', 'ngủ', 'uống'],
        'answer': 'ngủ',
      },
      {
        'type': LessonType.listening,
        'options': ['おきます', 'ねます', 'まいにち', 'いま'],
        'answer': 'おきます',
      },

      // ================= PHẦN 2: NGỮ PHÁP =================
      {
        'type': LessonType.grammarListIntro,
        'grammars': [
          {'title': '今は〜時です', 'meaning': 'Bây giờ là ~ giờ'},
          {
            'title': 'Động từ đuôi 「〜ます」',
            'meaning': 'Thì hiện tại / Tương lai',
          },
          {'title': 'Thời gian + に + Vます', 'meaning': 'Làm gì đó vào lúc ~'},
        ],
      },

      // NGỮ PHÁP 1
      {
        'type': LessonType.grammarStructure,
        'title': 'NÓI GIỜ',
        'formula': '今 + は + Số đếm + 時 + です',
        'meaning': 'Bây giờ là ~ giờ',
      },
      {
        'type': LessonType.grammarUsage,
        'title': '今は〜時です',
        'notes': [
          'Dùng để thông báo thời gian hiện tại.',
          'Để hỏi giờ, ta dùng từ để hỏi 「何時」(Nanji - Mấy giờ): 今は何時ですか (Bây giờ là mấy giờ?).',
        ],
      },
      {
        'type': LessonType.grammarExample,
        'title': 'NÓI GIỜ',
        'img': 'assets/images/example_ima.png',
        'jp': '今は９時です。',
        'rmj': 'Ima wa kuji desu.',
        'vn': 'Bây giờ là 9 giờ.',
      },

      // NGỮ PHÁP 2
      {
        'type': LessonType.grammarStructure,
        'title': 'ĐỘNG TỪ 〜ます',
        'formula': 'V + ます',
        'meaning': 'Thì hiện tại / Tương lai khẳng định',
      },
      {
        'type': LessonType.grammarUsage,
        'title': 'ĐỘNG TỪ 〜ます',
        'notes': [
          'Khác với tính từ đi với です, các hành động trong tiếng Nhật được biểu hiện bằng động từ kết thúc bằng đuôi 「〜ます」.',
          'Nó mang sắc thái lịch sự, dùng để diễn tả một thói quen hàng ngày (ví dụ: Mỗi ngày tôi đều thức dậy) hoặc một hành động sẽ xảy ra trong tương lai.',
        ],
      },
      {
        'type': LessonType.grammarExample,
        'title': 'ĐỘNG TỪ 〜ます',
        'img': 'assets/images/example_mainichi.png',
        'jp': '毎日、起きます。',
        'rmj': 'Mainichi, okimasu.',
        'vn': 'Mỗi ngày tôi đều thức dậy.',
      },

      // NGỮ PHÁP 3
      {
        'type': LessonType.grammarStructure,
        'title': 'TRỢ TỪ 「に」',
        'formula': 'Danh từ (Thời gian) + に + Vます',
        'meaning': 'Làm việc gì đó vào lúc ~',
      },
      {
        'type': LessonType.grammarUsage,
        'title': 'TRỢ TỪ 「に」',
        'notes': [
          'Trợ từ 「に」 được đặt ngay sau danh từ chỉ thời gian cụ thể (có con số như giờ, phút, ngày, tháng, năm).',
          'Nó chỉ ra thời điểm mà hành động xảy ra.',
          'Lưu ý: Không dùng 「に」 sau các từ thời gian chung chung như: Hôm nay, Ngày mai, Mỗi ngày (毎日).',
        ],
      },
      {
        'type': LessonType.grammarExample,
        'title': 'TRỢ TỪ 「に」',
        'img': 'assets/images/example_okimasu.png',
        'jp': '６時に起きます。',
        'rmj': 'Rokuji ni okimasu.',
        'vn': 'Tôi thức dậy lúc 6 giờ.',
      },

      // ================= PHẦN 3: TỔNG KẾT =================
      {
        'type': LessonType.vocabSummary,
        'words': [
          {'kanji': '今', 'romaji': 'ima', 'meaning': 'bây giờ'},
          {'kanji': '〜時', 'romaji': '~ji', 'meaning': 'giờ'},
          {'kanji': '〜分', 'romaji': '~fun/pun', 'meaning': 'phút'},
          {'kanji': '毎日', 'romaji': 'mainichi', 'meaning': 'mỗi ngày'},
          {'kanji': '起きます', 'romaji': 'okimasu', 'meaning': 'thức dậy'},
          {'kanji': '寝ます', 'romaji': 'nemasu', 'meaning': 'ngủ'},
        ],
      },
    ];
  }

  List<Map<String, dynamic>> _getCb4LuyenTap1Data() {
    return [
      // 1. Hình ảnh: Bây giờ
      {
        'type': LessonType.imageQuiz,
        'question': 'Bây giờ.',
        'answerIndex': 0,
        'options': [
          {'img': 'assets/images/example_ima.png', 'jp': '今', 'rmj': 'ima'},
          {'img': 'assets/images/example_ji.png', 'jp': '時', 'rmj': 'ji'},
          {
            'img': 'assets/images/example_okimasu.png',
            'jp': '起きます',
            'rmj': 'okimasu',
          },
          {
            'img': 'assets/images/example_nemasu.png',
            'jp': '寝ます',
            'rmj': 'nemasu',
          },
        ],
      },
      // 2. Nghe: Giờ
      {
        'type': LessonType.listening,
        'options': [
          {'kanji': '今', 'hiragana': 'いま'},
          {'kanji': '時', 'hiragana': 'じ'},
          {'kanji': '分', 'hiragana': 'ふん'},
          {'kanji': '毎日', 'hiragana': 'まいにち'},
        ],
        'answer': '時',
      },
      // 3. Chọn câu dài: Bây giờ là 9 giờ
      {
        'type': LessonType.quiz,
        'question': 'Bây giờ là 9 giờ.',
        'audio_text': '今は９時です。',
        'options': [
          {'kanji': '今は８時です。', 'hiragana': 'いまははちじです。'},
          {'kanji': '今は９時です。', 'hiragana': 'いまはくじです。'},
        ],
        'answer': '今は９時です。',
      },
      // 4. Đọc và dịch câu: Bây giờ là mấy giờ?
      {
        'type': LessonType.sentenceBuilder,
        'jp': '今は何時ですか。',
        'rmj': 'Ima wa nanji desu ka.',
        'audio_text': '今は何時ですか。',
        'words': ['bây giờ', 'là', 'mấy', 'giờ', 'phút', 'ngày mai'],
        'answer': 'bây giờ là mấy giờ',
      },
      // 5. Nghe và ghép từ (Ẩn chữ)
      {
        'type': LessonType.sentenceBuilder,
        'jp': '',
        'rmj': '',
        'audio_text': '今は１０時です。',
        'words': ['今', 'は', '１０', '時', 'です', '分', 'か'],
        'answer': '今 は １０ 時 です',
      },
    ];
  }

  List<Map<String, dynamic>> _getCb4LuyenTap2Data() {
    return [
      // 1. Trắc nghiệm chữ: Thức dậy
      {
        'type': LessonType.vocabQuiz,
        'kanji': '起きます',
        'hiragana': 'おきます',
        'romaji': 'okimasu',
        'options': ['ngủ', 'ăn', 'thức dậy', 'uống'],
        'answer': 'thức dậy',
      },
      // 2. Nghe: Ngủ
      {
        'type': LessonType.listening,
        'options': [
          {'kanji': '起きます', 'hiragana': 'おきます'},
          {'kanji': '寝ます', 'hiragana': 'ねます'},
          {'kanji': '毎日', 'hiragana': 'まいにち'},
          {'kanji': '今', 'hiragana': 'いま'},
        ],
        'answer': '寝ます',
      },
      // 3. Chọn câu dài: Tôi thức dậy lúc 6 giờ
      {
        'type': LessonType.quiz,
        'question': 'Tôi thức dậy lúc 6 giờ.',
        'audio_text': '私は６時に起きます。',
        'options': [
          {'kanji': '私は６時に寝ます。', 'hiragana': 'わたしはろくじにねます。'},
          {'kanji': '私は６時に起きます。', 'hiragana': 'わたしはろくじにおきます。'},
        ],
        'answer': '私は６時に起きます。',
      },
      // 4. Đọc và dịch câu: Bọn họ ngủ lúc 10 giờ
      {
        'type': LessonType.sentenceBuilder,
        'jp': '彼らは１０時に寝ます。',
        'rmj': 'Karera wa juuji ni nemasu.',
        'audio_text': '彼らは１０時に寝ます。',
        'words': ['bọn họ', 'ngủ', 'lúc', '10', 'giờ', 'thức dậy', 'của'],
        'answer': 'bọn họ ngủ lúc 10 giờ',
      },
      // 5. Nghe và ghép từ (Focus trợ từ に)
      {
        'type': LessonType.sentenceBuilder,
        'jp': '',
        'rmj': '',
        'audio_text': '毎日、６時に起きます。',
        'words': ['毎日', '６', '時', 'に', '起きます', '寝ます', 'は'],
        'answer': '毎日 ６ 時 に 起きます',
      },
    ];
  }

  List<Map<String, dynamic>> _getCb4LuyenTap3Data() {
    return [
      // 1. Điền trợ từ
      {
        'type': LessonType.quiz,
        'question': 'Điền trợ từ: \n私 ( ... ) ７時に起きます。',
        'options': ['に', 'は', 'の', 'が'],
        'answer': 'は',
      },
      // 2. Điền trợ từ thời gian
      {
        'type': LessonType.quiz,
        'question': 'Điền trợ từ: \n私は１０時 ( ... ) 寝ます。',
        'options': ['に', 'は', 'も', 'が'],
        'answer': 'に',
      },
      // 3. Đọc và dịch câu (Cũng)
      {
        'type': LessonType.sentenceBuilder,
        'jp': '私も６時に起きます。',
        'rmj': 'Watashi mo rokuji ni okimasu.',
        'audio_text': '私も６時に起きます。',
        'words': ['tôi', 'cũng', 'thức dậy', 'lúc', '6', 'giờ', 'không phải'],
        'answer': 'tôi cũng thức dậy lúc 6 giờ',
      },
      // 4. Nghe và ghép từ (Nhiễu に và は)
      {
        'type': LessonType.sentenceBuilder,
        'jp': '',
        'rmj': '',
        'audio_text': '母は１０時に寝ます。',
        'words': ['母', 'は', '１０', '時', 'に', '寝ます', 'も'],
        'answer': '母 は １０ 時 に 寝ます',
      },
      // 5. Nghe và chọn câu (Ẩn chữ)
      {
        'type': LessonType.quiz,
        'question': '',
        'audio_text': '彼らも６時に起きます。',
        'options': [
          'Bọn họ thức dậy lúc 6 giờ.',
          'Bọn họ cũng thức dậy lúc 6 giờ.',
          'Chúng tôi cũng thức dậy lúc 6 giờ.',
        ],
        'answer': 'Bọn họ cũng thức dậy lúc 6 giờ.',
      },
      // 6. Game ghép cặp: Tổng hợp
      {
        'type': LessonType.matching,
        'pairs': [
          {'left': 'Bây giờ', 'right': '今'},
          {'left': 'Thức dậy', 'right': '起きます'},
          {'left': 'Ngủ', 'right': '寝ます'},
          {'left': 'Mỗi ngày', 'right': '毎日'},
          {'left': 'Giờ', 'right': '時'},
        ],
      },
    ];
  }

  List<Map<String, dynamic>> _getCb4LuyenNoiData() {
    return [
      {
        'type': LessonType.speaking,
        'jp': '今は何時ですか。',
        'answer': 'いまはなんじですか', // Ima wa nanji desu ka
      },
      {
        'type': LessonType.speaking,
        'jp': '今は８時です。',
        'answer': 'いまははちじです', // Ima wa hachiji desu
      },
      {
        'type': LessonType.speaking,
        'jp': '毎日、６時に起きます。',
        'answer': 'まいにちろくじにおきます', // Mainichi rokuji ni okimasu
      },
      {
        'type': LessonType.speaking,
        'jp': '１０時に寝ます。',
        'answer': 'じゅうじにねます', // Juuji ni nemasu
      },
      {
        'type': LessonType.speaking,
        'jp': '私も６時に起きます。',
        'answer': 'わたしもろくじにおきます',
      },
    ];
  }

  List<Map<String, dynamic>> _getCb4LuyenVietData() {
    return [
      // 1. Chữ Kim (Bây giờ)
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '今',
        'kanji_target': '今',
        'meaning': 'Kim (Bây giờ / Hiện tại)',
        'rmj': 'ima',
      },
      // 2. Chữ Thời (Giờ)
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '〜時',
        'kanji_target': '時',
        'meaning': 'Thời (Thời gian / Giờ)',
        'rmj': 'ji',
      },
      // 3. Chữ Phân (Phút)
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '〜分',
        'kanji_target': '分',
        'meaning': 'Phân (Phút)',
        'rmj': 'fun / pun',
      },
      // 4. Chữ Mỗi (Mỗi ngày)
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '毎日',
        'kanji_target': '毎',
        'meaning': 'Mỗi (Mỗi ngày)',
        'rmj': 'mai',
      },
      // 5. Game ghép cặp Kanji
      {
        'type': LessonType.matching,
        'pairs': [
          {'left': 'Bây giờ', 'right': '今'},
          {'left': 'Giờ', 'right': '時'},
          {'left': 'Phút', 'right': '分'},
          {'left': 'Mỗi', 'right': '毎'},
          {'left': 'Ngày', 'right': '日'}, // Ôn lại chữ Nhật của bài 2
        ],
      },
    ];
  }

  List<Map<String, dynamic>> _getCb5LyThuyetData() {
    return [
      // ================= PHẦN 1: TỪ VỰNG =================
      {
        'type': LessonType.vocabListIntro,
        'words': [
          {
            'kanji': '行きます',
            'hiragana': 'いきます',
            'romaji': 'ikimasu',
            'meaning': 'Đi',
          },
          {
            'kanji': '来ます',
            'hiragana': 'きます',
            'romaji': 'kimasu',
            'meaning': 'Đến',
          },
          {
            'kanji': '帰ります',
            'hiragana': 'かえります',
            'romaji': 'kaerimasu',
            'meaning': 'Về',
          },
          {
            'kanji': '学校',
            'hiragana': 'がっこう',
            'romaji': 'gakkou',
            'meaning': 'Trường học',
          },
          {
            'kanji': '電車',
            'hiragana': 'でんしゃ',
            'romaji': 'densha',
            'meaning': 'Tàu điện',
          },
          {
            'kanji': '自転車',
            'hiragana': 'じてんしゃ',
            'romaji': 'jitensha',
            'meaning': 'Xe đạp',
          },
        ],
      },

      // --- NHÓM TỪ 1: ĐỘNG TỪ DI CHUYỂN ---
      {
        'type': LessonType.flashCard,
        'kanji': '行きます',
        'hiragana': 'いきます',
        'romaji': 'ikimasu',
        'meaning': 'Đi',
        'example_img': 'assets/images/example_ikimasu.png',
        'example_jp': '学校へ行きます。',
        'example_rmj': 'Gakkou e ikimasu.',
        'example_vn': 'Tôi đi đến trường.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': '来ます',
        'hiragana': 'きます',
        'romaji': 'kimasu',
        'meaning': 'Đến',
        'example_img': 'assets/images/example_kimasu.png',
        'example_jp': '日本へ来ました。',
        'example_rmj': 'Nihon e kimashita.',
        'example_vn': 'Tôi đã đến Nhật Bản.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': '帰ります',
        'hiragana': 'かえります',
        'romaji': 'kaerimasu',
        'meaning': 'Về',
        'example_img': 'assets/images/example_kaerimasu.png',
        'example_jp': 'うちへ帰ります。',
        'example_rmj': 'Uchi e kaerimasu.',
        'example_vn': 'Tôi đi về nhà.',
      },
      {
        'type': LessonType.vocabQuiz,
        'kanji': '行きます',
        'hiragana': 'いきます',
        'romaji': 'ikimasu',
        'options': ['đến', 'đi', 'về', 'ngủ'],
        'answer': 'đi',
      },
      {
        'type': LessonType.listening,
        'options': ['いきます', 'きます', 'かえります', 'おきます'],
        'answer': 'かえります',
      },

      // --- NHÓM TỪ 2: ĐỊA ĐIỂM & PHƯƠNG TIỆN ---
      {
        'type': LessonType.flashCard,
        'kanji': '学校',
        'hiragana': 'がっこう',
        'romaji': 'gakkou',
        'meaning': 'Trường học',
        'example_img': 'assets/images/example_gakkou.png',
        'example_jp': '毎日、学校へ行きます。',
        'example_rmj': 'Mainichi, gakkou e ikimasu.',
        'example_vn': 'Mỗi ngày tôi đều đi đến trường.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': '電車',
        'hiragana': 'でんしゃ',
        'romaji': 'densha',
        'meaning': 'Tàu điện',
        'example_img': 'assets/images/example_densha.png',
        'example_jp': '電車で行きます。',
        'example_rmj': 'Densha de ikimasu.',
        'example_vn': 'Tôi đi bằng tàu điện.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': '自転車',
        'hiragana': 'じてんしゃ',
        'romaji': 'jitensha',
        'meaning': 'Xe đạp',
        'example_img': 'assets/images/example_jitensha.png',
        'example_jp': '自転車で帰ります。',
        'example_rmj': 'Jitensha de kaerimasu.',
        'example_vn': 'Tôi về bằng xe đạp.',
      },
      {
        'type': LessonType.vocabQuiz,
        'kanji': '電車',
        'hiragana': 'でんしゃ',
        'romaji': 'densha',
        'options': ['xe đạp', 'ô tô', 'tàu điện', 'trường học'],
        'answer': 'tàu điện',
      },
      {
        'type': LessonType.listening,
        'options': ['がっこう', 'でんしゃ', 'じてんしゃ', 'くるま'],
        'answer': 'じてんしゃ',
      },

      // ================= PHẦN 2: NGỮ PHÁP =================
      {
        'type': LessonType.grammarListIntro,
        'grammars': [
          {
            'title': 'N(địa điểm) + へ + 行きます',
            'meaning': 'Đi / Đến / Về nơi nào đó',
          },
          {
            'title': 'N(phương tiện) + で + 行きます',
            'meaning': 'Đi bằng phương tiện gì',
          },
          {'title': 'N(người) + と + 行きます', 'meaning': 'Đi cùng với ai'},
        ],
      },

      // NGỮ PHÁP 1
      {
        'type': LessonType.grammarStructure,
        'title': 'TRỢ TỪ CHỈ HƯỚNG「へ」',
        'formula': 'Danh từ (Địa điểm) + へ + 行きます / 来ます / 帰ります',
        'meaning': 'Đi / Đến / Về (địa điểm nào đó)',
      },
      {
        'type': LessonType.grammarUsage,
        'title': 'TRỢ TỪ「へ」',
        'notes': [
          'Dùng để chỉ phương hướng của sự di chuyển.',
          'Lưu ý cực kỳ quan trọng: Trợ từ này viết là 「へ」 (he) nhưng luôn luôn được phát âm là 「え」 (e).',
        ],
      },
      {
        'type': LessonType.grammarExample,
        'title': 'TRỢ TỪ「へ」',
        'img': 'assets/images/example_ikimasu.png',
        'jp': '学校へ行きます。',
        'rmj': 'Gakkou e ikimasu.',
        'vn': 'Tôi đi đến trường.',
      },

      // NGỮ PHÁP 2
      {
        'type': LessonType.grammarStructure,
        'title': 'TRỢ TỪ CHỈ PHƯƠNG TIỆN「で」',
        'formula': 'Danh từ (Phương tiện) + で + Hành động',
        'meaning': 'Làm gì đó bằng phương tiện / công cụ gì',
      },
      {
        'type': LessonType.grammarUsage,
        'title': 'TRỢ TỪ「で」',
        'notes': [
          'Đặt trợ từ「で」sau danh từ chỉ phương tiện giao thông để diễn tả cách thức di chuyển.',
          'Ngoại lệ: Nếu đi bộ, ta dùng từ 「歩いて」(aruite) và KHÔNG dùng trợ từ で.',
        ],
      },
      {
        'type': LessonType.grammarExample,
        'title': 'TRỢ TỪ「で」',
        'img': 'assets/images/example_densha.png',
        'jp': '電車で学校へ行きます。',
        'rmj': 'Densha de gakkou e ikimasu.',
        'vn': 'Tôi đi đến trường BẰNG tàu điện.',
      },

      // NGỮ PHÁP 3
      {
        'type': LessonType.grammarStructure,
        'title': 'TRỢ TỪ ĐỒNG HÀNH「と」',
        'formula': 'Danh từ (Người) + と + Hành động',
        'meaning': 'Làm gì đó CÙNG VỚI ai',
      },
      {
        'type': LessonType.grammarUsage,
        'title': 'TRỢ TỪ「と」',
        'notes': [
          'Biểu thị người (hoặc động vật) cùng thực hiện hành động với mình.',
          'Nếu làm một mình, ta dùng từ 「一人で」(hitori de - một mình) và không dùng trợ từ と.',
        ],
      },
      {
        'type': LessonType.grammarExample,
        'title': 'TRỢ TỪ「と」',
        'img': 'assets/images/example_tomodachi.png',
        'jp': '友達と日本へ来ました。',
        'rmj': 'Tomodachi to Nihon e kimashita.',
        'vn': 'Tôi đã đến Nhật VỚI bạn.',
      },

      // ================= PHẦN 3: TỔNG KẾT =================
      {
        'type': LessonType.vocabSummary,
        'words': [
          {'kanji': '行きます', 'romaji': 'ikimasu', 'meaning': 'đi'},
          {'kanji': '来ます', 'romaji': 'kimasu', 'meaning': 'đến'},
          {'kanji': '帰ります', 'romaji': 'kaerimasu', 'meaning': 'về'},
          {'kanji': '学校', 'romaji': 'gakkou', 'meaning': 'trường học'},
          {'kanji': '電車', 'romaji': 'densha', 'meaning': 'tàu điện'},
          {'kanji': '自転車', 'romaji': 'jitensha', 'meaning': 'xe đạp'},
        ],
      },
    ];
  }

  List<Map<String, dynamic>> _getCb5LuyenTap1Data() {
    return [
      // 1. Hình ảnh: Trường học
      {
        'type': LessonType.imageQuiz,
        'question': 'Trường học.',
        'answerIndex': 3,
        'options': [
          {
            'img': 'assets/images/example_ikimasu.png',
            'jp': '行きます',
            'rmj': 'ikimasu',
          },
          {
            'img': 'assets/images/example_densha.png',
            'jp': '電車',
            'rmj': 'densha',
          },
          {
            'img': 'assets/images/example_jitensha.png',
            'jp': '自転車',
            'rmj': 'jitensha',
          },
          {
            'img': 'assets/images/example_gakkou.png',
            'jp': '学校',
            'rmj': 'gakkou',
          },
        ],
      },
      // 2. Nghe: Đi
      {
        'type': LessonType.listening,
        'options': [
          {'kanji': '行きます', 'hiragana': 'いきます'},
          {'kanji': '来ます', 'hiragana': 'きます'},
          {'kanji': '帰ります', 'hiragana': 'かえります'},
          {'kanji': '学校', 'hiragana': 'がっこう'},
        ],
        'answer': '行きます',
      },
      // 3. Chọn câu: Tôi đi đến trường
      {
        'type': LessonType.quiz,
        'question': 'Tôi đi đến trường.',
        'audio_text': '私は学校へ行きます。',
        'options': [
          {'kanji': '私は学校へ帰ります。', 'hiragana': 'わたしはがっこうへかえります。'},
          {'kanji': '私は学校へ行きます。', 'hiragana': 'わたしはがっこうへいきます。'},
        ],
        'answer': '私は学校へ行きます。',
      },
      // 4. Đọc và dịch câu: Tôi về Nhật Bản
      {
        'type': LessonType.sentenceBuilder,
        'jp': '日本へ帰ります。',
        'rmj': 'Nihon e kaerimasu.',
        'audio_text': '日本へ帰ります。',
        'words': ['Nhật Bản', 'về', 'đi', 'đến', 'tôi', 'bằng'],
        'answer': 'về Nhật Bản',
      },
      // 5. Nghe và ghép từ (Ẩn chữ)
      {
        'type': LessonType.sentenceBuilder,
        'jp': '',
        'rmj': '',
        'audio_text': '学校へ来ました。',
        'words': ['学校', 'へ', '来ました', '行きます', 'で', 'に'],
        'answer': '学校 へ 来ました',
      },
    ];
  }

  List<Map<String, dynamic>> _getCb5LuyenTap2Data() {
    return [
      // 1. Trắc nghiệm chữ: Tàu điện
      {
        'type': LessonType.vocabQuiz,
        'kanji': '電車',
        'hiragana': 'でんしゃ',
        'romaji': 'densha',
        'options': ['ô tô', 'tàu điện', 'xe đạp', 'trường học'],
        'answer': 'tàu điện',
      },
      // 2. Nghe: Xe đạp
      {
        'type': LessonType.listening,
        'options': [
          {'kanji': '電車', 'hiragana': 'でんしゃ'},
          {'kanji': '自転車', 'hiragana': 'じてんしゃ'},
          {'kanji': '車', 'hiragana': 'くるま'},
          {'kanji': '学校', 'hiragana': 'がっこう'},
        ],
        'answer': '自転車',
      },
      // 3. Chọn câu: Đi bằng tàu điện
      {
        'type': LessonType.quiz,
        'question': 'Tôi đi bằng tàu điện.',
        'audio_text': '電車で行きます。',
        'options': [
          {'kanji': '電車で行きます。', 'hiragana': 'でんしゃでいきます。'},
          {'kanji': '自転車で行きます。', 'hiragana': 'じてんしゃでいきます。'},
        ],
        'answer': '電車で行きます。',
      },
      // 4. Đọc và dịch câu: Về bằng xe đạp
      {
        'type': LessonType.sentenceBuilder,
        'jp': '自転車で帰ります。',
        'rmj': 'Jitensha de kaerimasu.',
        'audio_text': '自転車で帰ります。',
        'words': ['xe đạp', 'bằng', 'về', 'đi', 'ô tô', 'đến'],
        'answer': 'về bằng xe đạp',
      },
      // 5. Nghe và ghép từ (Có cả phương tiện và hướng đi)
      {
        'type': LessonType.sentenceBuilder,
        'jp': '',
        'rmj': '',
        'audio_text': '車で学校へ行きます。',
        'words': ['車', 'で', '学校', 'へ', '行きます', 'に', 'は'],
        'answer': '車 で 学校 へ 行きます',
      },
    ];
  }

  List<Map<String, dynamic>> _getCb5LuyenTap3Data() {
    return [
      // 1. Điền trợ từ (Đi cùng bạn)
      {
        'type': LessonType.quiz,
        'question': 'Điền trợ từ (cùng với): \n友達 ( ... ) 行きます。',
        'options': ['で', 'へ', 'と', 'に'],
        'answer': 'と',
      },
      // 2. Điền trợ từ (Bằng tàu điện)
      {
        'type': LessonType.quiz,
        'question': 'Điền trợ từ (bằng phương tiện): \n電車 ( ... ) 帰ります。',
        'options': ['で', 'は', 'へ', 'と'],
        'answer': 'で',
      },
      // 3. Đọc và dịch câu: Bọn họ đi đến Mỹ
      {
        'type': LessonType.sentenceBuilder,
        'jp': '彼らはアメリカへ行きます。',
        'rmj': 'Karera wa Amerika e ikimasu.',
        'audio_text': '彼らはアメリカへ行きます。',
        'words': ['bọn họ', 'đi', 'đến', 'Mỹ', 'Nhật Bản', 'bằng'],
        'answer': 'bọn họ đi đến Mỹ',
      },
      // 4. Nghe và ghép từ (Đi với mẹ)
      {
        'type': LessonType.sentenceBuilder,
        'jp': '',
        'rmj': '',
        'audio_text': '母と学校へ行きます。',
        'words': ['母', 'と', '学校', 'へ', '行きます', 'で', 'も'],
        'answer': '母 と 学校 へ 行きます',
      },
      // 5. Nghe và chọn câu (Câu trùm cuối)
      {
        'type': LessonType.quiz,
        'question': '',
        'audio_text': '友達と自転車で帰ります。',
        'options': [
          'Tôi về bằng tàu điện với bạn.',
          'Tôi về bằng xe đạp với bạn.',
          'Tôi đi xe đạp đến trường với bạn.',
        ],
        'answer': 'Tôi về bằng xe đạp với bạn.',
      },
    ];
  }

  List<Map<String, dynamic>> _getCb5LuyenNoiData() {
    return [
      {
        'type': LessonType.speaking,
        'jp': '学校へ行きます。',
        'answer': 'がっこうへいきます', // Gakkou e ikimasu
      },
      {
        'type': LessonType.speaking,
        'jp': '日本へ来ました。',
        'answer': 'にほんへきました', // Nihon e kimashita
      },
      {
        'type': LessonType.speaking,
        'jp': '電車で帰ります。',
        'answer': 'でんしゃでかえります', // Densha de kaerimasu
      },
      {
        'type': LessonType.speaking,
        'jp': '自転車で学校へ行きます。',
        'answer': 'じてんしゃでがっこうへいきます', // Jitensha de gakkou e ikimasu
      },
      {
        'type': LessonType.speaking,
        'jp': '友達と帰ります。',
        'answer': 'ともだちとかえります', // Tomodachi to kaerimasu
      },
    ];
  }

  List<Map<String, dynamic>> _getCb5LuyenVietData() {
    return [
      // 1. Chữ Hành (Đi)
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '行きます',
        'kanji_target': '行',
        'meaning': 'Hành (Đi)',
        'rmj': 'i(kimasu)',
      },
      // 2. Chữ Lai (Đến)
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '来ます',
        'kanji_target': '来',
        'meaning': 'Lai (Đến)',
        'rmj': 'ki(masu)',
      },
      // 3. Chữ Quy (Về)
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '帰ります',
        'kanji_target': '帰',
        'meaning': 'Quy (Về)',
        'rmj': 'kae(rimasu)',
      },
      // 4. Chữ Học (Trường học)
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '学校',
        'kanji_target': '学',
        'meaning': 'Học (Học tập / Trường học)',
        'rmj': 'gaku / ga',
      },
      // 5. Game ghép cặp Kanji
      {
        'type': LessonType.matching,
        'pairs': [
          {'left': 'Đi', 'right': '行きます'},
          {'left': 'Đến', 'right': '来ます'},
          {'left': 'Về', 'right': '帰ります'},
          {'left': 'Trường học', 'right': '学校'},
          {'left': 'Tàu điện', 'right': '電車'},
        ],
      },
    ];
  }

  List<Map<String, dynamic>> _getCb6LyThuyetData() {
    return [
      // ================= PHẦN 1: TỪ VỰNG =================
      {
        'type': LessonType.vocabListIntro,
        'words': [
          {
            'kanji': '食べます',
            'hiragana': 'たべます',
            'romaji': 'tabemasu',
            'meaning': 'Ăn',
          },
          {
            'kanji': '飲みます',
            'hiragana': 'のみます',
            'romaji': 'nomimasu',
            'meaning': 'Uống',
          },
          {
            'kanji': '見ます',
            'hiragana': 'みます',
            'romaji': 'mimasu',
            'meaning': 'Xem / Nhìn',
          },
          {
            'kanji': 'ご飯',
            'hiragana': 'ごはん',
            'romaji': 'gohan',
            'meaning': 'Cơm / Bữa ăn',
          },
          {'kanji': '水', 'hiragana': 'みず', 'romaji': 'mizu', 'meaning': 'Nước'},
          {
            'kanji': 'お酒',
            'hiragana': 'おさけ',
            'romaji': 'osake',
            'meaning': 'Rượu / Đồ uống có cồn',
          },
          {
            'kanji': '一緒に',
            'hiragana': 'いっしょに',
            'romaji': 'isshoni',
            'meaning': 'Cùng nhau',
          },
        ],
      },

      // --- NHÓM TỪ 1: ĐỘNG TỪ ---
      {
        'type': LessonType.flashCard,
        'kanji': '食べます',
        'hiragana': 'たべます',
        'romaji': 'tabemasu',
        'meaning': 'Ăn',
        'example_img': 'assets/images/example_tabemasu.png',
        'example_jp': 'ご飯を食べます。',
        'example_rmj': 'Gohan o tabemasu.',
        'example_vn': 'Tôi ăn cơm.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': '飲みます',
        'hiragana': 'のみます',
        'romaji': 'nomimasu',
        'meaning': 'Uống',
        'example_img': 'assets/images/example_nomimasu.png',
        'example_jp': '水を飲みます。',
        'example_rmj': 'Mizu o nomimasu.',
        'example_vn': 'Tôi uống nước.',
      },
      {
        'type': LessonType.vocabQuiz,
        'kanji': '見ます',
        'hiragana': 'みます',
        'romaji': 'mimasu',
        'options': ['ăn', 'ngủ', 'xem', 'uống'],
        'answer': 'xem',
      },

      // --- NHÓM TỪ 2: ĐỒ ĂN & TRẠNG TỪ ---
      {
        'type': LessonType.flashCard,
        'kanji': 'ご飯',
        'hiragana': 'ごはん',
        'romaji': 'gohan',
        'meaning': 'Cơm',
        'example_img': 'assets/images/example_gohan.png',
        'example_jp': '朝ご飯を食べます。',
        'example_rmj': 'Asagohan o tabemasu.',
        'example_vn': 'Tôi ăn bữa sáng.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': '一緒に',
        'hiragana': 'いっしょに',
        'romaji': 'isshoni',
        'meaning': 'Cùng nhau',
        'example_img': 'assets/images/example_isshoni.png',
        'example_jp': '一緒に食べませんか。',
        'example_rmj': 'Isshoni tabemasenka.',
        'example_vn': 'Cùng ăn với tôi không?',
      },
      {
        'type': LessonType.listening,
        'options': ['ごはん', 'みず', 'おさけ', 'いっしょに'],
        'answer': 'おさけ',
      },

      // ================= PHẦN 2: NGỮ PHÁP =================
      {
        'type': LessonType.grammarListIntro,
        'grammars': [
          {
            'title': 'N + を + V(ngoại động từ)',
            'meaning': 'Làm gì đó với cái gì (Ăn cơm, uống nước)',
          },
          {'title': 'Địa điểm + で + V', 'meaning': 'Làm gì đó TẠI đâu'},
          {'title': 'V-ませんか', 'meaning': 'Rủ rê (Cùng làm ~ với tôi không?)'},
        ],
      },

      // NGỮ PHÁP 1: Trợ từ を
      {
        'type': LessonType.grammarStructure,
        'title': 'TRỢ TỪ TÂN NGỮ「を」',
        'formula': 'Danh từ + を + Động từ',
        'meaning': 'Ăn / Uống / Xem (một cái gì đó)',
      },
      {
        'type': LessonType.grammarUsage,
        'title': 'TRỢ TỪ「を」',
        'notes': [
          'Dùng để chỉ đối tượng chịu tác động của hành động.',
          'Ví dụ: Ăn (V) cái gì? -> Ăn cơm (N). Cơm là đối tượng nên đi với を.',
          'Lưu ý: Chữ này viết là 「を」(wo) nhưng chỉ phát âm là 「o」.',
        ],
      },
      {
        'type': LessonType.grammarExample,
        'title': 'TRỢ TỪ「を」',
        'img': 'assets/images/example_tabemasu.png',
        'jp': '魚を食べます。',
        'rmj': 'Sakana o tabemasu.',
        'vn': 'Tôi ăn cá.',
      },

      // NGỮ PHÁP 2: Trợ từ で (Địa điểm hành động)
      {
        'type': LessonType.grammarStructure,
        'title': 'TRỢ TỪ ĐỊA ĐIỂM「で」',
        'formula': 'Địa điểm + で + Động từ',
        'meaning': 'Làm gì đó TẠI địa điểm nào đó',
      },
      {
        'type': LessonType.grammarUsage,
        'title': 'PHÂN BIỆT で VÀ へ',
        'notes': [
          'へ (e): Chỉ hướng di chuyển (Đi ĐẾN đâu).',
          'で (de): Chỉ nơi xảy ra hành động (Ăn cơm TẠI đâu).',
          'Ví dụ: 学校で勉強します (Học bài TẠI trường).',
        ],
      },
      {
        'type': LessonType.grammarExample,
        'title': 'TRỢ TỪ「で」',
        'img': 'assets/images/example_gakkou_taberu.png',
        'jp': '学校でご飯を食べます。',
        'rmj': 'Gakkou de gohan o tabemasu.',
        'vn': 'Tôi ăn cơm TẠI trường học.',
      },

      // NGỮ PHÁP 3: Rủ rê
      {
        'type': LessonType.grammarStructure,
        'title': 'CÂU RỦ RÊ「〜ませんか」',
        'formula': 'V-ます ➔ V-ませんか',
        'meaning': 'Cùng làm ~ với tôi không?',
      },
      {
        'type': LessonType.grammarUsage,
        'title': 'CÁCH RỦ RÊ LỊCH SỰ',
        'notes': [
          'Dùng để mời hoặc rủ người nghe cùng thực hiện hành động với mình.',
          'Thường đi kèm với phó từ 「一緒に」(isshoni - cùng nhau).',
          'Cách trả lời đồng ý: 「ええ、しましょう」(Vâng, cùng làm thôi).',
        ],
      },
      {
        'type': LessonType.grammarExample,
        'title': 'CÂU RỦ RÊ',
        'img': 'assets/images/example_isshoni.png',
        'jp': '一緒に飲みませんか。',
        'rmj': 'Isshoni nomimasenka.',
        'vn': 'Cùng uống với tôi không?',
      },

      // ================= PHẦN 3: TỔNG KẾT =================
      {
        'type': LessonType.vocabSummary,
        'words': [
          {'kanji': '食べます', 'romaji': 'tabemasu', 'meaning': 'ăn'},
          {'kanji': '飲みます', 'romaji': 'nomimasu', 'meaning': 'uống'},
          {'kanji': '見ます', 'romaji': 'mimasu', 'meaning': 'xem'},
          {'kanji': 'ご飯', 'romaji': 'gohan', 'meaning': 'cơm'},
          {'kanji': '水', 'romaji': 'mizu', 'meaning': 'nước'},
          {'kanji': '一緒に', 'romaji': 'isshoni', 'meaning': 'cùng nhau'},
        ],
      },
    ];
  }

  List<Map<String, dynamic>> _getCb6LuyenTap1Data() {
    return [
      {
        'type': LessonType.imageQuiz,
        'question': 'Ăn cơm.',
        'answerIndex': 0,
        'options': [
          {
            'img': 'assets/images/example_tabemasu.png',
            'jp': '食べます',
            'rmj': 'tabemasu',
          },
          {
            'img': 'assets/images/example_nomimasu.png',
            'jp': '飲みます',
            'rmj': 'nomimasu',
          },
          {'img': 'assets/images/example_mizu.png', 'jp': '水', 'rmj': 'mizu'},
          {
            'img': 'assets/images/example_isshoni.png',
            'jp': '一緒に',
            'rmj': 'isshoni',
          },
        ],
      },
      {
        'type': LessonType.listening,
        'options': [
          {'kanji': '食べます', 'hiragana': 'たべます'},
          {'kanji': '飲みます', 'hiragana': 'のみます'},
          {'kanji': '見ます', 'hiragana': 'みます'},
          {'kanji': 'ご飯', 'hiragana': 'ごはん'},
        ],
        'answer': '飲みます',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': '水を飲みます。',
        'rmj': 'Mizu o nomimasu.',
        'audio_text': '水を飲みます。',
        'words': ['nước', 'uống', 'ăn', 'cơm', 'xem'],
        'answer': 'uống nước',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': '',
        'rmj': '',
        'audio_text': '魚を食べます。',
        'words': ['魚', 'を', '食べます', '飲みます', 'ご飯'],
        'answer': '魚 を 食べます',
      },
    ];
  }

  List<Map<String, dynamic>> _getCb6LuyenTap2Data() {
    return [
      {
        'type': LessonType.quiz,
        'question': 'Điền trợ từ (tại/ở đâu): \n学校 ( ... ) ご飯を食べます。',
        'options': ['へ', 'に', 'で', 'を'],
        'answer': 'で',
      },
      {
        'type': LessonType.quiz,
        'question': 'Tôi xem TV ở nhà.',
        'audio_text': 'うちでテレビを見ます。',
        'options': [
          {'kanji': 'うちでテレビを見ます。', 'hiragana': 'うちでテレビをみます。'},
          {'kanji': 'うちへテレビを見ます。', 'hiragana': 'うちへテレビをみます。'},
        ],
        'answer': 'うちでテレビを見ます。',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': '',
        'rmj': '',
        'audio_text': '学校で水を飲みます。',
        'words': ['学校', 'で', '水', 'を', '飲みます', 'へ', 'は'],
        'answer': '学校 で 水 を 飲みます',
      },
    ];
  }

  List<Map<String, dynamic>> _getCb6LuyenTap3Data() {
    return [
      {
        'type': LessonType.quiz,
        'question': 'Câu nào mang nghĩa "Cùng ăn cơm với tôi không?"',
        'options': ['一緒にご飯を食べますか。', '一緒にご飯を食べませんか。', '一緒にご飯を食べました。'],
        'answer': '一緒にご飯を食べませんか。',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': '',
        'rmj': '',
        'audio_text': '一緒に日本へ行きませんか。',
        'words': ['一緒に', '日本', 'へ', '行きませんか', '行きます', 'で'],
        'answer': '一緒に 日本 へ 行きませんか',
      },
      {
        'type': LessonType.matching,
        'pairs': [
          {'left': 'Ăn', 'right': '食べます'},
          {'left': 'Uống', 'right': '飲みます'},
          {'left': 'Xem', 'right': '見ます'},
          {'left': 'Nước', 'right': '水'},
          {'left': 'Cơm', 'right': 'ご飯'},
        ],
      },
    ];
  }

  List<Map<String, dynamic>> _getCb6LuyenNoiData() {
    return [
      {'type': LessonType.speaking, 'jp': '水を飲みます。', 'answer': 'みずをのみます'},
      {'type': LessonType.speaking, 'jp': '魚を食べます。', 'answer': 'さかなをたべます'},
      {
        'type': LessonType.speaking,
        'jp': '学校で勉強します。',
        'answer': 'がっこうでべんきょうします',
      },
      {
        'type': LessonType.speaking,
        'jp': '一緒に食べませんか。',
        'answer': 'いっしょにたべませんか',
      },
      {'type': LessonType.speaking, 'jp': 'ええ、食べましょう。', 'answer': 'ええたべましょう'},
    ];
  }

  List<Map<String, dynamic>> _getCb6LuyenVietData() {
    return [
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '食べます',
        'kanji_target': '食',
        'meaning': 'Thực (Ăn)',
        'rmj': 'ta(beru)',
      },
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '飲みます',
        'kanji_target': '飲',
        'meaning': 'Ẩm (Uống)',
        'rmj': 'no(mu)',
      },
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '見ます',
        'kanji_target': '見',
        'meaning': 'Kiến (Nhìn/Xem)',
        'rmj': 'mi(ru)',
      },
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '水',
        'kanji_target': '水',
        'meaning': 'Thủy (Nước)',
        'rmj': 'mizu',
      },
      {
        'type': LessonType.matching,
        'pairs': [
          {'left': 'Ăn', 'right': '食'},
          {'left': 'Uống', 'right': '飲'},
          {'left': 'Xem', 'right': '見'},
          {'left': 'Nước', 'right': '水'},
          {'left': 'Cơm', 'right': '飯'},
        ],
      },
    ];
  }

  List<Map<String, dynamic>> _getCb7LyThuyetData() {
    return [
      // ================= PHẦN 1: TỪ VỰNG =================
      {
        'type': LessonType.vocabListIntro,
        'words': [
          {'kanji': '手', 'hiragana': 'て', 'romaji': 'te', 'meaning': 'Tay'},
          {'kanji': '箸', 'hiragana': 'はし', 'romaji': 'hashi', 'meaning': 'Đũa'},
          {
            'kanji': '日本語',
            'hiragana': 'にほんご',
            'romaji': 'nihongo',
            'meaning': 'Tiếng Nhật',
          },
          {
            'kanji': '英語',
            'hiragana': 'えいご',
            'romaji': 'eigo',
            'meaning': 'Tiếng Anh',
          },
          {
            'kanji': 'あげます',
            'hiragana': 'あげます',
            'romaji': 'agemasu',
            'meaning': 'Cho / Tặng',
          },
          {
            'kanji': 'もらいます',
            'hiragana': 'もらいます',
            'romaji': 'moraimasu',
            'meaning': 'Nhận',
          },
          {
            'kanji': '教えます',
            'hiragana': 'おしえます',
            'romaji': 'oshiemasu',
            'meaning': 'Dạy',
          },
          {
            'kanji': '習います',
            'hiragana': 'ならいます',
            'romaji': 'naraimasu',
            'meaning': 'Học / Được dạy',
          },
        ],
      },

      // --- NHÓM TỪ 1: CÔNG CỤ & NGÔN NGỮ ---
      {
        'type': LessonType.flashCard,
        'kanji': '手',
        'hiragana': 'て',
        'romaji': 'te',
        'meaning': 'Tay',
        'example_img': 'assets/images/example_te.png',
        'example_jp': '手で食べます。',
        'example_rmj': 'Te de tabemasu.',
        'example_vn': 'Ăn bằng tay.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': '日本語',
        'hiragana': 'にほんご',
        'romaji': 'nihongo',
        'meaning': 'Tiếng Nhật',
        'example_img': 'assets/images/example_nihongo.png',
        'example_jp': '日本語で話します。',
        'example_rmj': 'Nihongo de hanashimasu.',
        'example_vn': 'Nói chuyện bằng tiếng Nhật.',
      },
      {
        'type': LessonType.vocabQuiz,
        'kanji': '箸',
        'hiragana': 'はし',
        'romaji': 'hashi',
        'options': ['ô tô', 'đũa', 'thìa', 'tay'],
        'answer': 'đũa',
      },

      // --- NHÓM TỪ 2: CHO - NHẬN ---
      {
        'type': LessonType.flashCard,
        'kanji': 'あげます',
        'hiragana': 'あげます',
        'romaji': 'agemasu',
        'meaning': 'Cho / Tặng',
        'example_img': 'assets/images/example_agemasu.png',
        'example_jp': '母にプレゼントをあげます。',
        'example_rmj': 'Haha ni purezento o agemasu.',
        'example_vn': 'Tôi tặng quà cho mẹ.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': '習います',
        'hiragana': 'ならいます',
        'romaji': 'naraimasu',
        'meaning': 'Học (từ ai đó)',
        'example_img': 'assets/images/example_naraimasu.png',
        'example_jp': '先生に日本語を習います。',
        'example_rmj': 'Sensei ni nihongo o naraimasu.',
        'example_vn': 'Tôi học tiếng Nhật từ thầy giáo.',
      },
      {
        'type': LessonType.listening,
        'options': ['あげます', 'もらいます', 'おしえます', 'ならいます'],
        'answer': 'もらいます',
      },

      // ================= PHẦN 2: NGỮ PHÁP =================
      {
        'type': LessonType.grammarListIntro,
        'grammars': [
          {
            'title': 'Công cụ/Ngôn ngữ + で + V',
            'meaning': 'Làm gì bằng công cụ / ngôn ngữ gì',
          },
          {'title': 'N(người) + に + あげます', 'meaning': 'Làm gì CHO ai đó'},
          {'title': 'N(người) + に + もらいます', 'meaning': 'NHẬN gì từ ai đó'},
        ],
      },

      // NGỮ PHÁP 1: Trợ từ で (Công cụ)
      {
        'type': LessonType.grammarStructure,
        'title': 'TRỢ TỪ CÔNG CỤ「で」',
        'formula': 'Công cụ / Ngôn ngữ + で + Động từ',
        'meaning': 'Bằng ~',
      },
      {
        'type': LessonType.grammarUsage,
        'title': 'CÁCH DÙNG TRỢ TỪ「で」',
        'notes': [
          'Biểu thị phương tiện hoặc cách thức thực hiện hành động.',
          'Dùng cho công cụ: 箸で食べます (Ăn bằng đũa).',
          'Dùng cho ngôn ngữ: 日本語でレポートを書きます (Viết báo cáo bằng tiếng Nhật).',
        ],
      },
      {
        'type': LessonType.grammarExample,
        'title': 'TRỢ TỪ CÔNG CỤ「で」',
        'img': 'assets/images/example_hashi.png',
        'jp': '箸で食べます。',
        'rmj': 'Hashi de tabemasu.',
        'vn': 'Tôi ăn bằng đũa.',
      },

      // NGỮ PHÁP 2: Trợ từ に (Đối tượng nhận/cho)
      {
        'type': LessonType.grammarStructure,
        'title': 'TRỢ TỪ ĐỐI TƯỢNG「に」',
        'formula': 'Đối tượng (Người) + に + Động từ (Cho/Nhận)',
        'meaning': 'Cho ai / Từ ai',
      },
      {
        'type': LessonType.grammarUsage,
        'title': 'PHÂN BIỆT CHO VÀ NHẬN',
        'notes': [
          'Với các từ "Cho/Dạy/Cho mượn": Trợ từ に chỉ người nhận.',
          'Với các từ "Nhận/Học/Mượn": Trợ từ に chỉ người cho (đối tượng mà mình nhận từ họ).',
          'Riêng với "Nhận từ ai đó", có thể dùng 「から」 thay cho 「に」.',
        ],
      },
      {
        'type': LessonType.grammarExample,
        'title': 'TRỢ TỪ ĐỐI TƯỢNG「に」',
        'img': 'assets/images/example_agemasu.png',
        'jp': '友達に本をあげます。',
        'rmj': 'Tomodachi ni hon o agemasu.',
        'vn': 'Tôi tặng sách cho bạn.',
      },

      // ================= PHẦN 3: TỔNG KẾT =================
      {
        'type': LessonType.vocabSummary,
        'words': [
          {'kanji': '手', 'romaji': 'te', 'meaning': 'tay'},
          {'kanji': '箸', 'romaji': 'hashi', 'meaning': 'đũa'},
          {'kanji': '日本語', 'romaji': 'nihongo', 'meaning': 'tiếng Nhật'},
          {'kanji': 'あげます', 'romaji': 'agemasu', 'meaning': 'tặng'},
          {'kanji': 'もらいます', 'romaji': 'moraimasu', 'meaning': 'nhận'},
          {'kanji': '教えます', 'romaji': 'oshiemasu', 'meaning': 'dạy'},
        ],
      },
    ];
  }

  List<Map<String, dynamic>> _getCb7LuyenTap1Data() {
    return [
      {
        'type': LessonType.imageQuiz,
        'question': 'Ăn bằng đũa.',
        'answerIndex': 1,
        'options': [
          {'img': 'assets/images/example_te.png', 'jp': '手', 'rmj': 'te'},
          {'img': 'assets/images/example_hashi.png', 'jp': '箸', 'rmj': 'hashi'},
          {
            'img': 'assets/images/example_nihongo.png',
            'jp': '日本語',
            'rmj': 'nihongo',
          },
          {'img': 'assets/images/example_eigo.png', 'jp': '英語', 'rmj': 'eigo'},
        ],
      },
      {
        'type': LessonType.listening,
        'options': [
          {'kanji': '日本語', 'hiragana': 'にほんご'},
          {'kanji': '英語', 'hiragana': 'えいご'},
          {'kanji': '手', 'hiragana': 'て'},
          {'kanji': '箸', 'hiragana': 'はし'},
        ],
        'answer': '英語',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': '手で食べます。',
        'rmj': 'Te de tabemasu.',
        'audio_text': '手で食べます。',
        'words': ['tay', 'bằng', 'ăn', 'đũa', 'uống'],
        'answer': 'ăn bằng tay',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': '',
        'rmj': '',
        'audio_text': '日本語で話します。',
        'words': ['日本語', 'で', '話します', '英語', 'を', 'に'],
        'answer': '日本語 で 話します',
      },
    ];
  }

  List<Map<String, dynamic>> _getCb7LuyenTap2Data() {
    return [
      {
        'type': LessonType.quiz,
        'question': 'Tôi tặng hoa cho mẹ.',
        'audio_text': '母に花をあげます。',
        'options': [
          {'kanji': '母に花をあげます。', 'hiragana': 'ははにはなをあげます。'},
          {'kanji': '母に花をもらいます。', 'hiragana': 'ははにはなをもらいます。'},
        ],
        'answer': '母に花 को あげます。',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': '',
        'rmj': '',
        'audio_text': '先生に英語を習います。',
        'words': ['先生', 'に', '英語', 'を', '習います', '教えます', 'で'],
        'answer': '先生 に 英語 を 習います',
      },
      {
        'type': LessonType.quiz,
        'question': 'Điền trợ từ (cho ai): \n友達 ( ... ) プレゼントをあげます。',
        'options': ['で', 'を', 'に', 'へ'],
        'answer': 'に',
      },
    ];
  }

  List<Map<String, dynamic>> _getCb7LuyenTap3Data() {
    return [
      {
        'type': LessonType.quiz,
        'question': 'Câu nào nghĩa là: "Tôi học tiếng Nhật từ bạn"?',
        'options': ['友達に日本語を教えます。', '友達に日本語を習います。', '友達も日本語を習います。'],
        'answer': '友達に日本語を習います。',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': '',
        'rmj': '',
        'audio_text': '英語でレポートを書きます。',
        'words': ['英語', 'で', 'レポート', 'を', '書きます', 'に', 'は'],
        'answer': '英語 で レポート を 書きます',
      },
      {
        'type': LessonType.matching,
        'pairs': [
          {'left': 'Tay', 'right': '手'},
          {'left': 'Tiếng Nhật', 'right': '日本語'},
          {'left': 'Cho / Tặng', 'right': 'あげます'},
          {'left': 'Dạy', 'right': '教えます'},
          {'left': 'Học', 'right': '習います'},
        ],
      },
    ];
  }

  List<Map<String, dynamic>> _getCb7LuyenNoiData() {
    return [
      {'type': LessonType.speaking, 'jp': '箸で食べます。', 'answer': 'はしでたべます'},
      {'type': LessonType.speaking, 'jp': '日本語で話します。', 'answer': 'にほんごではなします'},
      {
        'type': LessonType.speaking,
        'jp': '母にプレゼントをあげます。',
        'answer': 'ははにぷれぜんとをあげます',
      },
      {
        'type': LessonType.speaking,
        'jp': '友達に英語を習います。',
        'answer': 'ともだちにえいごをならいます',
      },
      {
        'type': LessonType.speaking,
        'jp': '父に本をもらいました。',
        'answer': 'ちちにほんをもらいました',
      },
    ];
  }

  List<Map<String, dynamic>> _getCb7LuyenVietData() {
    return [
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '手',
        'kanji_target': '手',
        'meaning': 'Thủ (Tay)',
        'rmj': 'te',
      },
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '日本語',
        'kanji_target': '語',
        'meaning': 'Ngữ (Ngôn ngữ)',
        'rmj': 'go',
      },
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '英語',
        'kanji_target': '英',
        'meaning': 'Anh (Tiếng Anh / Anh hùng)',
        'rmj': 'ei',
      },
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '教えます',
        'kanji_target': '教',
        'meaning': 'Giáo (Dạy / Giáo dục)',
        'rmj': 'oshi(eru)',
      },
      {
        'type': LessonType.matching,
        'pairs': [
          {'left': 'Tay', 'right': '手'},
          {'left': 'Ngôn ngữ', 'right': '語'},
          {'left': 'Dạy', 'right': '教'},
          {'left': 'Học', 'right': '習'},
          {'left': 'Viết', 'right': '書'},
        ],
      },
    ];
  }

  List<Map<String, dynamic>> _getCb8LyThuyetData() {
    return [
      // ================= PHẦN 1: TỪ VỰNG =================
      {
        'type': LessonType.vocabListIntro,
        'words': [
          {
            'kanji': '大きい',
            'hiragana': 'おおきい',
            'romaji': 'ookii',
            'meaning': 'To / Lớn (Tính từ đuôi い)',
          },
          {
            'kanji': '小さい',
            'hiragana': 'ちいさい',
            'romaji': 'chiisai',
            'meaning': 'Nhỏ / Bé (Tính từ đuôi い)',
          },
          {
            'kanji': '暑い',
            'hiragana': 'あつい',
            'romaji': 'atsui',
            'meaning': 'Nóng (Thời tiết) (Tính từ đuôi い)',
          },
          {
            'kanji': '寒い',
            'hiragana': 'さむい',
            'romaji': 'samui',
            'meaning': 'Lạnh (Thời tiết) (Tính từ đuôi い)',
          },
          {
            'kanji': 'きれい[な]',
            'hiragana': 'きれい[な]',
            'romaji': 'kirei [na]',
            'meaning': 'Đẹp / Sạch sẽ (Tính từ đuôi な)',
          },
          {
            'kanji': '静か[な]',
            'hiragana': 'しずか[な]',
            'romaji': 'shizuka [na]',
            'meaning': 'Yên tĩnh (Tính từ đuôi な)',
          },
          {
            'kanji': '町',
            'hiragana': 'まち',
            'romaji': 'machi',
            'meaning': 'Thành phố / Thị trấn',
          },
          {'kanji': '山', 'hiragana': 'やま', 'romaji': 'yama', 'meaning': 'Núi'},
        ],
      },

      // --- NHÓM TỪ 1: TÍNH TỪ ĐUÔI い ---
      {
        'type': LessonType.flashCard,
        'kanji': '大きい',
        'hiragana': 'おおきい',
        'romaji': 'ookii',
        'meaning': 'To / Lớn',
        'example_img': 'assets/images/example_ookii.png',
        'example_jp': '大きい車です。',
        'example_rmj': 'Ookii kuruma desu.',
        'example_vn': 'Là chiếc ô tô lớn.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': '小さい',
        'hiragana': 'ちいさい',
        'romaji': 'chiisai',
        'meaning': 'Nhỏ / Bé',
        'example_img': 'assets/images/example_chiisai.png',
        'example_jp': '小さい犬です。',
        'example_rmj': 'Chiisai inu desu.',
        'example_vn': 'Là con chó nhỏ.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': '暑い',
        'hiragana': 'あつい',
        'romaji': 'atsui',
        'meaning': 'Nóng',
        'example_img': 'assets/images/example_atsui.png',
        'example_jp': '今日は暑いです。',
        'example_rmj': 'Kyou wa atsui desu.',
        'example_vn': 'Hôm nay trời nóng.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': '寒い',
        'hiragana': 'さむい',
        'romaji': 'samui',
        'meaning': 'Lạnh',
        'example_img': 'assets/images/example_samui.png',
        'example_jp': '日本は寒いです。',
        'example_rmj': 'Nihon wa samui desu.',
        'example_vn': 'Nhật Bản thì lạnh.',
      },
      {
        'type': LessonType.vocabQuiz,
        'kanji': '大きい',
        'hiragana': 'おおきい',
        'romaji': 'ookii',
        'options': ['nhỏ', 'to / lớn', 'nóng', 'lạnh'],
        'answer': 'to / lớn',
      },
      {
        'type': LessonType.listening,
        'options': ['おおきい', 'ちいさい', 'あつい', 'さむい'],
        'answer': 'あつい',
      },

      // --- NHÓM TỪ 2: TÍNH TỪ ĐUÔI な & DANH TỪ ---
      {
        'type': LessonType.flashCard,
        'kanji': 'きれい[な]',
        'hiragana': 'きれい[な]',
        'romaji': 'kirei [na]',
        'meaning': 'Đẹp / Sạch sẽ',
        'example_img': 'assets/images/example_kirei.png',
        'example_jp': 'きれいな町です。',
        'example_rmj': 'Kirei na machi desu.',
        'example_vn': 'Là một thành phố đẹp.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': '静か[な]',
        'hiragana': 'しずか[な]',
        'romaji': 'shizuka [na]',
        'meaning': 'Yên tĩnh',
        'example_img': 'assets/images/example_shizuka.png',
        'example_jp': '静かな山です。',
        'example_rmj': 'Shizuka na yama desu.',
        'example_vn': 'Là ngọn núi yên tĩnh.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': '町',
        'hiragana': 'まち',
        'romaji': 'machi',
        'meaning': 'Thành phố / Thị trấn',
        'example_img': 'assets/images/example_machi.png',
        'example_jp': '私の町です。',
        'example_rmj': 'Watashi no machi desu.',
        'example_vn': 'Là thành phố của tôi.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': '山',
        'hiragana': 'やま',
        'romaji': 'yama',
        'meaning': 'Núi',
        'example_img': 'assets/images/example_yama.png',
        'example_jp': '日本の山です。',
        'example_rmj': 'Nihon no yama desu.',
        'example_vn': 'Là núi của Nhật Bản.',
      },
      {
        'type': LessonType.vocabQuiz,
        'kanji': '町',
        'hiragana': 'まち',
        'romaji': 'machi',
        'options': ['núi', 'biển', 'thành phố', 'sông'],
        'answer': 'thành phố',
      },
      {
        'type': LessonType.listening,
        'options': ['きれい', 'しずか', 'まち', 'やま'],
        'answer': 'やま',
      },

      // ================= PHẦN 2: NGỮ PHÁP =================
      {
        'type': LessonType.grammarListIntro,
        'grammars': [
          {
            'title': 'N + は + Tính từ + です',
            'meaning': 'N thì (Đẹp, Nóng, To...)',
          },
          {
            'title': 'Tính từ + Danh từ',
            'meaning': 'Bổ nghĩa cho danh từ (Người đẹp, Ô tô to)',
          },
        ],
      },

      // NGỮ PHÁP 1: N は Tính từ です
      {
        'type': LessonType.grammarStructure,
        'title': 'CÂU MIÊU TẢ SỰ VẬT',
        'formula': 'Danh từ + は + Tính từ + です',
        'meaning': 'Danh từ thì (như thế nào đó)',
      },
      {
        'type': LessonType.grammarUsage,
        'title': 'N + は + Adj + です',
        'notes': [
          'Dùng để miêu tả tính chất, trạng thái của sự vật, sự việc.',
          'Đối với tính từ đuôi い: Giữ nguyên đuôi い + です (Ví dụ: 大きいです - thì to).',
          'Đối với tính từ đuôi な: Bỏ đuôi な + です (Ví dụ: きれいです - thì đẹp).',
        ],
      },
      {
        'type': LessonType.grammarExample,
        'title': 'CÂU MIÊU TẢ SỰ VẬT',
        'img': 'assets/images/example_ookii.png',
        'jp': 'この町は大きいです。',
        'rmj': 'Kono machi wa ookii desu.',
        'vn': 'Thành phố này thì lớn.',
      },

      // NGỮ PHÁP 2: Tính từ bổ nghĩa Danh từ
      {
        'type': LessonType.grammarStructure,
        'title': 'TÍNH TỪ BỔ NGHĨA',
        'formula': 'Tính từ + Danh từ',
        'meaning': 'Danh từ (như thế nào đó)',
      },
      {
        'type': LessonType.grammarUsage,
        'title': 'Adj + N',
        'notes': [
          'Dùng tính từ đặt TRƯỚC danh từ để làm rõ nghĩa cho danh từ đó.',
          'Tính từ đuôi い: Giữ nguyên đuôi い + Danh từ (Ví dụ: 大きい山 - Ngọn núi to).',
          'Tính từ đuôi な: PHẢI GIỮ LẠI đuôi な + Danh từ (Ví dụ: きれいな町 - Thành phố đẹp).',
        ],
      },
      {
        'type': LessonType.grammarExample,
        'title': 'TÍNH TỪ BỔ NGHĨA',
        'img': 'assets/images/example_kirei.png',
        'jp': 'きれいな町です。',
        'rmj': 'Kirei na machi desu.',
        'vn': 'Là một thành phố đẹp.',
      },

      // ================= PHẦN 3: TỔNG KẾT =================
      {
        'type': LessonType.vocabSummary,
        'words': [
          {'kanji': '大きい', 'romaji': 'ookii', 'meaning': 'to / lớn'},
          {'kanji': '小さい', 'romaji': 'chiisai', 'meaning': 'nhỏ'},
          {'kanji': '暑い', 'romaji': 'atsui', 'meaning': 'nóng'},
          {'kanji': '寒い', 'romaji': 'samui', 'meaning': 'lạnh'},
          {'kanji': 'きれい[な]', 'romaji': 'kirei [na]', 'meaning': 'đẹp'},
          {'kanji': '静か[な]', 'romaji': 'shizuka [na]', 'meaning': 'yên tĩnh'},
          {'kanji': '町', 'romaji': 'machi', 'meaning': 'thành phố'},
          {'kanji': '山', 'romaji': 'yama', 'meaning': 'núi'},
        ],
      },
    ];
  }

  List<Map<String, dynamic>> _getCb8LuyenTap1Data() {
    return [
      {
        'type': LessonType.imageQuiz,
        'question': 'To / Lớn.',
        'answerIndex': 0,
        'options': [
          {
            'img': 'assets/images/example_ookii.png',
            'jp': '大きい',
            'rmj': 'ookii',
          },
          {
            'img': 'assets/images/example_chiisai.png',
            'jp': '小さい',
            'rmj': 'chiisai',
          },
          {
            'img': 'assets/images/example_atsui.png',
            'jp': '暑い',
            'rmj': 'atsui',
          },
          {
            'img': 'assets/images/example_samui.png',
            'jp': '寒い',
            'rmj': 'samui',
          },
        ],
      },
      {
        'type': LessonType.listening,
        'options': [
          {'kanji': '大きい', 'hiragana': 'おおきい'},
          {'kanji': '小さい', 'hiragana': 'ちいさい'},
          {'kanji': '暑い', 'hiragana': 'あつい'},
          {'kanji': '寒い', 'hiragana': 'さむい'},
        ],
        'answer': '小さい',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': '日本は寒いです。',
        'rmj': 'Nihon wa samui desu.',
        'audio_text': '日本は寒いです。',
        'words': ['Nhật Bản', 'thì', 'lạnh', 'nóng', 'to', 'Mỹ'],
        'answer': 'Nhật Bản thì lạnh',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': '',
        'rmj': '',
        'audio_text': 'アメリカは大きいです。',
        'words': ['アメリカ', 'は', '大きい', 'です', '小さい', 'が'],
        'answer': 'アメリカ は 大きい です',
      },
    ];
  }

  List<Map<String, dynamic>> _getCb8LuyenTap2Data() {
    return [
      {
        'type': LessonType.quiz,
        'question': 'Điền từ đúng (Thành phố yên tĩnh): \n( ... ) 町です。',
        'options': ['静か', '静かに', '静かな', '静かの'],
        'answer':
            '静かな', // Nhấn mạnh đuôi な phải giữ lại khi bổ nghĩa cho danh từ
      },
      {
        'type': LessonType.quiz,
        'question': 'Đây là ngọn núi to.',
        'audio_text': 'これは大きい山です。',
        'options': [
          {'kanji': 'これは小さい山です。', 'hiragana': 'これはちいさいやまです。'},
          {'kanji': 'これは大きい山です。', 'hiragana': 'これはおおきいやまです。'},
        ],
        'answer': 'これは大きい山です。',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': '',
        'rmj': '',
        'audio_text': 'きれいな町です。',
        'words': ['きれいな', '町', 'です', '大きい', '山', 'は'],
        'answer': 'きれいな 町 です',
      },
    ];
  }

  List<Map<String, dynamic>> _getCb8LuyenTap3Data() {
    return [
      {
        'type': LessonType.quiz,
        'question': 'Câu nào nghĩa là: "Quyển sách này thì nhỏ"?',
        'options': [
          'これは小さい本です。',
          'この本は小さいです。', // Cả 2 đều đúng về nghĩa tiếng Việt, nhưng câu này khớp với cấu trúc N は Adj です
          '小さい本はこれです。',
        ],
        'answer': 'この本は小さいです。',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': '',
        'rmj': '',
        'audio_text': '私の町は静かです。',
        'words': ['私', 'の', '町', 'は', '静か', 'です', 'きれいな'],
        'answer': '私 の 町 は 静か です',
      },
      {
        'type': LessonType.matching,
        'pairs': [
          {'left': 'Thành phố', 'right': '町'},
          {'left': 'Núi', 'right': '山'},
          {'left': 'To', 'right': '大きい'},
          {'left': 'Đẹp', 'right': 'きれい'},
          {'left': 'Nóng', 'right': '暑い'},
        ],
      },
    ];
  }

  List<Map<String, dynamic>> _getCb8LuyenNoiData() {
    return [
      {'type': LessonType.speaking, 'jp': '日本は寒いです。', 'answer': 'にほんはさむいです'},
      {'type': LessonType.speaking, 'jp': '大きい犬です。', 'answer': 'おおきいいぬです'},
      {'type': LessonType.speaking, 'jp': 'きれいな町です。', 'answer': 'きれいなまちです'},
      {
        'type': LessonType.speaking,
        'jp': '私の町は静かです。',
        'answer': 'わたしのまちはしずかです',
      },
      {
        'type': LessonType.speaking,
        'jp': 'これは大きい山です。',
        'answer': 'これはおおきいやまです',
      },
    ];
  }

  List<Map<String, dynamic>> _getCb8LuyenVietData() {
    return [
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '大きい',
        'kanji_target': '大',
        'meaning': 'Đại (To / Lớn)',
        'rmj': 'oo(kii) / dai',
      },
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '小さい',
        'kanji_target': '小',
        'meaning': 'Tiểu (Nhỏ / Bé)',
        'rmj': 'chii(sai) / shou',
      },
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '町',
        'kanji_target': '町',
        'meaning': 'Đinh (Thành phố / Thị trấn)',
        'rmj': 'machi',
      },
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '山',
        'kanji_target': '山',
        'meaning': 'Sơn (Núi)',
        'rmj': 'yama / san',
      },
      {
        'type': LessonType.matching,
        'pairs': [
          {'left': 'Đại', 'right': '大'},
          {'left': 'Tiểu', 'right': '小'},
          {'left': 'Đinh', 'right': '町'},
          {'left': 'Sơn', 'right': '山'},
          {'left': 'Thủy', 'right': '水'}, // Ôn lại bài 6
        ],
      },
    ];
  }

  List<Map<String, dynamic>> _getCb9LyThuyetData() {
    return [
      // ================= PHẦN 1: TỪ VỰNG =================
      {
        'type': LessonType.vocabListIntro,
        'words': [
          {
            'kanji': 'わかります',
            'hiragana': 'わかります',
            'romaji': 'wakarimasu',
            'meaning': 'Hiểu / Nắm được',
          },
          {
            'kanji': '上手[な]',
            'hiragana': 'じょうず[な]',
            'romaji': 'jouzu [na]',
            'meaning': 'Giỏi / Khéo',
          },
          {
            'kanji': '下手[な]',
            'hiragana': 'へた[な]',
            'romaji': 'heta [na]',
            'meaning': 'Kém / Dở',
          },
          {
            'kanji': '歌',
            'hiragana': 'うた',
            'romaji': 'uta',
            'meaning': 'Bài hát / Việc ca hát',
          },
          {
            'kanji': '料理',
            'hiragana': 'りょうり',
            'romaji': 'ryouri',
            'meaning': 'Món ăn / Việc nấu ăn',
          },
          {
            'kanji': '忙しい',
            'hiragana': 'いそがしい',
            'romaji': 'isogashii',
            'meaning': 'Bận rộn',
          },
        ],
      },

      // --- NHÓM TỪ 1: NĂNG LỰC ---
      {
        'type': LessonType.flashCard,
        'kanji': 'わかります',
        'hiragana': 'わかります',
        'romaji': 'wakarimasu',
        'meaning': 'Hiểu',
        'example_img': 'assets/images/example_wakarimasu.png',
        'example_jp': '日本語がわかります。',
        'example_rmj': 'Nihongo ga wakarimasu.',
        'example_vn': 'Tôi hiểu tiếng Nhật.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': '上手[な]',
        'hiragana': 'じょうず[な]',
        'romaji': 'jouzu [na]',
        'meaning': 'Giỏi',
        'example_img': 'assets/images/example_jouzu.png',
        'example_jp': '料理が上手です。',
        'example_rmj': 'Ryouri ga jouzu desu.',
        'example_vn': 'Tôi nấu ăn giỏi.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': '下手[な]',
        'hiragana': 'へた[な]',
        'romaji': 'heta [na]',
        'meaning': 'Kém / Dở',
        'example_img': 'assets/images/example_heta.png',
        'example_jp': '歌が下手です。',
        'example_rmj': 'Uta ga heta desu.',
        'example_vn': 'Tôi hát dở.',
      },
      {
        'type': LessonType.vocabQuiz,
        'kanji': '上手',
        'hiragana': 'じょうず',
        'romaji': 'jouzu',
        'options': ['kém', 'giỏi', 'bận rộn', 'hiểu'],
        'answer': 'giỏi',
      },
      {
        'type': LessonType.listening,
        'options': ['わかります', 'じょうず', 'へた', 'いそがしい'],
        'answer': 'わかります',
      },

      // --- NHÓM TỪ 2: DANH TỪ & LÝ DO ---
      {
        'type': LessonType.flashCard,
        'kanji': '歌',
        'hiragana': 'うた',
        'romaji': 'uta',
        'meaning': 'Bài hát',
        'example_img': 'assets/images/example_uta.png',
        'example_jp': '日本の歌です。',
        'example_rmj': 'Nihon no uta desu.',
        'example_vn': 'Là bài hát Nhật Bản.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': '料理',
        'hiragana': 'りょうり',
        'romaji': 'ryouri',
        'meaning': 'Việc nấu ăn',
        'example_img': 'assets/images/example_ryouri.png',
        'example_jp': '母の料理です。',
        'example_rmj': 'Haha no ryouri desu.',
        'example_vn': 'Là món ăn của mẹ.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': '忙しい',
        'hiragana': 'いそがしい',
        'romaji': 'isogashii',
        'meaning': 'Bận rộn',
        'example_img': 'assets/images/example_isogashii.png',
        'example_jp': '今日は忙しいです。',
        'example_rmj': 'Kyou wa isogashii desu.',
        'example_vn': 'Hôm nay tôi bận.',
      },
      {
        'type': LessonType.vocabQuiz,
        'kanji': '料理',
        'hiragana': 'りょうり',
        'romaji': 'ryouri',
        'options': ['bài hát', 'việc nấu ăn', 'thành phố', 'công việc'],
        'answer': 'việc nấu ăn',
      },
      {
        'type': LessonType.listening,
        'options': ['うた', 'りょうり', 'いそがしい', 'じょうず'],
        'answer': 'いそがしい',
      },

      // ================= PHẦN 2: NGỮ PHÁP =================
      {
        'type': LessonType.grammarListIntro,
        'grammars': [
          {'title': 'N + が + わかります', 'meaning': 'Hiểu / Biết về N'},
          {'title': 'N + が + 上手/下手です', 'meaning': 'Giỏi / Kém về N'},
          {'title': 'Câu 1 + から、Câu 2', 'meaning': 'Vì (Câu 1) nên (Câu 2)'},
        ],
      },

      // NGỮ PHÁP 1: Trợ từ が chỉ năng lực
      {
        'type': LessonType.grammarStructure,
        'title': 'TRỢ TỪ NĂNG LỰC「が」',
        'formula': 'Danh từ + が + わかります / 上手です / 下手です',
        'meaning': 'Hiểu / Giỏi / Kém (cái gì đó)',
      },
      {
        'type': LessonType.grammarUsage,
        'title': 'CÁCH DÙNG TRỢ TỪ「が」',
        'notes': [
          'Khác với các động từ hành động dùng trợ từ を, các từ chỉ trạng thái, năng lực (Hiểu, Giỏi, Kém, Thích, Ghét) bắt buộc phải đi với trợ từ が.',
          'Ví dụ: 日本語がわかります (Hiểu tiếng Nhật - Không dùng を).',
        ],
      },
      {
        'type': LessonType.grammarExample,
        'title': 'TRỢ TỪ「が」',
        'img': 'assets/images/example_jouzu.png',
        'jp': '料理が上手です。',
        'rmj': 'Ryouri ga jouzu desu.',
        'vn': 'Tôi nấu ăn giỏi.',
      },

      // NGỮ PHÁP 2: Liên từ から
      {
        'type': LessonType.grammarStructure,
        'title': 'LIÊN TỪ LÝ DO「から」',
        'formula': 'Mệnh đề 1 (Lý do) + から、Mệnh đề 2 (Kết quả).',
        'meaning': 'Vì... nên...',
      },
      {
        'type': LessonType.grammarUsage,
        'title': 'CÁCH DÙNG「から」',
        'notes': [
          'Từ 「から」 đặt ở cuối câu lý do để giải thích nguyên nhân.',
          'Chú ý: Trong tiếng Nhật, Lý do luôn đứng trước, Kết quả đứng sau. (Trái ngược với "Nên... Vì..." trong tiếng Việt).',
          'Có thể đứng độc lập: 忙しいですから。(Vì tôi bận.)',
        ],
      },
      {
        'type': LessonType.grammarExample,
        'title': 'LIÊN TỪ「から」',
        'img': 'assets/images/example_isogashii.png',
        'jp': '忙しいですから、行きません。',
        'rmj': 'Isogashii desu kara, ikimasen.',
        'vn': 'Vì bận rộn nên tôi không đi.',
      },

      // ================= PHẦN 3: TỔNG KẾT =================
      {
        'type': LessonType.vocabSummary,
        'words': [
          {'kanji': 'わかります', 'romaji': 'wakarimasu', 'meaning': 'hiểu'},
          {'kanji': '上手', 'romaji': 'jouzu', 'meaning': 'giỏi'},
          {'kanji': '下手', 'romaji': 'heta', 'meaning': 'kém'},
          {'kanji': '歌', 'romaji': 'uta', 'meaning': 'bài hát'},
          {'kanji': '料理', 'romaji': 'ryouri', 'meaning': 'nấu ăn'},
          {'kanji': '忙しい', 'romaji': 'isogashii', 'meaning': 'bận rộn'},
        ],
      },
    ];
  }

  List<Map<String, dynamic>> _getCb9LuyenTap1Data() {
    return [
      {
        'type': LessonType.imageQuiz,
        'question': 'Nấu ăn.',
        'answerIndex': 2,
        'options': [
          {'img': 'assets/images/example_uta.png', 'jp': '歌', 'rmj': 'uta'},
          {
            'img': 'assets/images/example_wakarimasu.png',
            'jp': 'わかります',
            'rmj': 'wakarimasu',
          },
          {
            'img': 'assets/images/example_ryouri.png',
            'jp': '料理',
            'rmj': 'ryouri',
          },
          {
            'img': 'assets/images/example_isogashii.png',
            'jp': '忙しい',
            'rmj': 'isogashii',
          },
        ],
      },
      {
        'type': LessonType.listening,
        'options': [
          {'kanji': '上手', 'hiragana': 'じょうず'},
          {'kanji': '下手', 'hiragana': 'へた'},
          {'kanji': '忙しい', 'hiragana': 'いそがしい'},
          {'kanji': '歌', 'hiragana': 'うた'},
        ],
        'answer': '下手',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': '日本語がわかります。',
        'rmj': 'Nihongo ga wakarimasu.',
        'audio_text': '日本語がわかります。',
        'words': ['tiếng Nhật', 'hiểu', 'giỏi', 'kém', 'bận rộn'],
        'answer': 'hiểu tiếng Nhật',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': '',
        'rmj': '',
        'audio_text': '今日は忙しいです。',
        'words': ['今日', 'は', '忙しい', 'です', 'から', 'が'],
        'answer': '今日 は 忙しい です',
      },
    ];
  }

  List<Map<String, dynamic>> _getCb9LuyenTap2Data() {
    return [
      {
        'type': LessonType.quiz,
        'question': 'Điền trợ từ đúng (Hiểu tiếng Anh): \n英語 ( ... ) わかります。',
        'options': ['を', 'に', 'が', 'で'],
        'answer':
            'が', // Bẫy kinh điển: nhiều người sẽ chọn を vì nghĩ là hành động
      },
      {
        'type': LessonType.quiz,
        'question': 'Tôi hát dở.',
        'audio_text': '私は歌が下手です。',
        'options': [
          {'kanji': '私は歌が上手です。', 'hiragana': 'わたしはうたがじょうずです。'},
          {'kanji': '私は歌が下手です。', 'hiragana': 'わたしはうたがへたです。'},
        ],
        'answer': '私は歌が下手です。',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': '',
        'rmj': '',
        'audio_text': '母は料理が上手です。',
        'words': ['母', 'は', '料理', 'が', '上手', 'です', 'を'],
        'answer': '母 は 料理 が 上手 です',
      },
    ];
  }

  List<Map<String, dynamic>> _getCb9LuyenTap3Data() {
    return [
      {
        'type': LessonType.quiz,
        'question': 'Câu nào có nghĩa là: "Vì bận nên tôi không đi"?',
        'options': [
          '行きませんから、忙しいです。', // Ngược logic
          '忙しいですから、行きません。', // Đúng logic Nhật
          '忙しいですから、行きます。',
        ],
        'answer': '忙しいですから、行きません。',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': '',
        'rmj': '',
        'audio_text': '日本語がわかりますから、日本の本を読みます。', // Câu trùm cuối cực xịn
        'words': ['日本語', 'が', 'わかります', 'から', '日本', 'の', '本', 'を', '読みます'],
        'answer': '日本語 が わかります から 日本 の 本 を 読みます',
      },
      {
        'type': LessonType.matching,
        'pairs': [
          {'left': 'Hiểu', 'right': 'わかります'},
          {'left': 'Giỏi', 'right': '上手'},
          {'left': 'Kém', 'right': '下手'},
          {'left': 'Bài hát', 'right': '歌'},
          {'left': 'Bận rộn', 'right': '忙しい'},
        ],
      },
    ];
  }

  List<Map<String, dynamic>> _getCb9LuyenNoiData() {
    return [
      {'type': LessonType.speaking, 'jp': '日本語がわかります。', 'answer': 'にほんごがわかります'},
      {'type': LessonType.speaking, 'jp': '料理が上手です。', 'answer': 'りょうりがじょうずです'},
      {'type': LessonType.speaking, 'jp': '歌が下手です。', 'answer': 'うたがへたです'},
      {
        'type': LessonType.speaking,
        'jp': '忙しいですから。', // Trả lời ngắn bằng lý do
        'answer': 'いそがしいですから',
      },
      {
        'type': LessonType.speaking,
        'jp': '忙しいですから、行きません。',
        'answer': 'いそがしいですからいきません',
      },
    ];
  }

  List<Map<String, dynamic>> _getCb9LuyenVietData() {
    return [
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '上手',
        'kanji_target': '上',
        'meaning': 'Thượng (Trên / Giỏi)',
        'rmj': 'jou / ue',
      },
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '下手',
        'kanji_target': '下',
        'meaning': 'Hạ (Dưới / Kém)',
        'rmj': 'he / shita',
      },
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '歌',
        'kanji_target': '歌',
        'meaning': 'Ca (Ca hát / Bài hát)',
        'rmj': 'uta',
      },
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '料理',
        'kanji_target': '料',
        'meaning': 'Liệu (Nguyên liệu / Nấu ăn)',
        'rmj': 'ryou',
      },
      {
        'type': LessonType.matching,
        'pairs': [
          {'left': 'Thượng', 'right': '上'},
          {'left': 'Hạ', 'right': '下'},
          {'left': 'Ca', 'right': '歌'},
          {'left': 'Liệu', 'right': '料'},
          {
            'left': 'Thủ',
            'right': '手',
          }, // Ôn lại chữ "Thủ - Tay" đã học, ghép thành Thượng Thủ (Giỏi)
        ],
      },
    ];
  }

  List<Map<String, dynamic>> _getCb10LyThuyetData() {
    return [
      // ================= PHẦN 1: TỪ VỰNG =================
      {
        'type': LessonType.vocabListIntro,
        'words': [
          {
            'kanji': 'あります',
            'hiragana': 'あります',
            'romaji': 'arimasu',
            'meaning': 'Có (Dùng cho đồ vật, cây cối)',
          },
          {
            'kanji': 'います',
            'hiragana': 'います',
            'romaji': 'imasu',
            'meaning': 'Có / Ở (Dùng cho người, động vật)',
          },
          {'kanji': '上', 'hiragana': 'うえ', 'romaji': 'ue', 'meaning': 'Trên'},
          {
            'kanji': '下',
            'hiragana': 'した',
            'romaji': 'shita',
            'meaning': 'Dưới',
          },
          {
            'kanji': '中',
            'hiragana': 'なか',
            'romaji': 'naka',
            'meaning': 'Trong',
          },
          {
            'kanji': '外',
            'hiragana': 'そと',
            'romaji': 'soto',
            'meaning': 'Ngoài',
          },
          {
            'kanji': '箱',
            'hiragana': 'はこ',
            'romaji': 'hako',
            'meaning': 'Cái hộp',
          },
        ],
      },

      // --- NHÓM TỪ 1: ĐỘNG TỪ TỒN TẠI ---
      {
        'type': LessonType.flashCard,
        'kanji': 'あります',
        'hiragana': 'あります',
        'romaji': 'arimasu',
        'meaning': 'Có (Đồ vật)',
        'example_img': 'assets/images/example_arimasu.png',
        'example_jp': '本があります。',
        'example_rmj': 'Hon ga arimasu.',
        'example_vn': 'Có quyển sách.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': 'います',
        'hiragana': 'います',
        'romaji': 'imasu',
        'meaning': 'Có (Người/Động vật)',
        'example_img': 'assets/images/example_imasu.png',
        'example_jp': '犬がいます。',
        'example_rmj': 'Inu ga imasu.',
        'example_vn': 'Có con chó.',
      },
      {
        'type': LessonType.vocabQuiz,
        'kanji': 'あります',
        'hiragana': 'あります',
        'romaji': 'arimasu',
        'options': ['có (người)', 'không có', 'có (đồ vật)', 'ăn'],
        'answer': 'có (đồ vật)',
      },

      // --- NHÓM TỪ 2: VỊ TRÍ ---
      {
        'type': LessonType.flashCard,
        'kanji': '上',
        'hiragana': 'うえ',
        'romaji': 'ue',
        'meaning': 'Trên',
        'example_img': 'assets/images/example_ue.png',
        'example_jp': '箱の上です。',
        'example_rmj': 'Hako no ue desu.',
        'example_vn': 'Ở trên cái hộp.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': '中',
        'hiragana': 'なか',
        'romaji': 'naka',
        'meaning': 'Trong',
        'example_img': 'assets/images/example_naka.png',
        'example_jp': '箱の中です。',
        'example_rmj': 'Hako no naka desu.',
        'example_vn': 'Ở trong cái hộp.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': '外',
        'hiragana': 'そと',
        'romaji': 'soto',
        'meaning': 'Ngoài',
        'example_img': 'assets/images/example_soto.png',
        'example_jp': '外に犬がいます。',
        'example_rmj': 'Soto ni inu ga imasu.',
        'example_vn': 'Bên ngoài có con chó.',
      },
      {
        'type': LessonType.vocabQuiz,
        'kanji': '中',
        'hiragana': 'なか',
        'romaji': 'naka',
        'options': ['trên', 'ngoài', 'dưới', 'trong'],
        'answer': 'trong',
      },
      {
        'type': LessonType.listening,
        'options': ['うえ', 'した', 'なか', 'そと'],
        'answer': 'うえ',
      },

      // ================= PHẦN 2: NGỮ PHÁP =================
      {
        'type': LessonType.grammarListIntro,
        'grammars': [
          {'title': 'N + が + あります / います', 'meaning': 'Có cái gì / Có ai đó'},
          {
            'title': 'Địa điểm + に + N + が + あります',
            'meaning': 'Ở đâu có cái gì',
          },
          {
            'title': 'Danh từ + の + Vị trí',
            'meaning': 'Trên/Dưới/Trong/Ngoài của cái gì',
          },
        ],
      },

      // NGỮ PHÁP 1: あります vs います
      {
        'type': LessonType.grammarStructure,
        'title': 'CÂU TỒN TẠI',
        'formula': 'Danh từ + が + あります / います',
        'meaning': 'Có N',
      },
      {
        'type': LessonType.grammarUsage,
        'title': 'あります VÀ います',
        'notes': [
          'Dùng để diễn tả sự hiện diện, tồn tại của người hoặc vật. Bắt buộc đi với trợ từ が.',
          'あります: Dùng cho đồ vật vô tri vô giác, cây cối (Sách, xe, cây, nhà).',
          'います: Dùng cho người và động vật có thể tự chuyển động (Bạn bè, chó, mèo).',
        ],
      },
      {
        'type': LessonType.grammarExample,
        'title': 'CÂU TỒN TẠI',
        'img': 'assets/images/example_imasu.png',
        'jp': '犬がいます。',
        'rmj': 'Inu ga imasu.',
        'vn': 'Có con chó.',
      },

      // NGỮ PHÁP 2: N に N が あります
      {
        'type': LessonType.grammarStructure,
        'title': 'ĐỊA ĐIỂM TỒN TẠI',
        'formula': 'Địa điểm + に + Vật/Người + が + あります/います',
        'meaning': 'Ở (địa điểm) có (vật/người)',
      },
      {
        'type': LessonType.grammarUsage,
        'title': 'TRỢ TỪ「に」',
        'notes': [
          'Trợ từ に lúc này mang nghĩa là "Ở / Tại". Nó chỉ ra không gian tồn tại của sự vật.',
          'Ví dụ: 部屋にベッドがあります (Trong phòng có cái giường).',
        ],
      },
      {
        'type': LessonType.grammarExample,
        'title': 'ĐỊA ĐIỂM TỒN TẠI',
        'img': 'assets/images/example_soto.png',
        'jp': '外に犬がいます。',
        'rmj': 'Soto ni inu ga imasu.',
        'vn': 'Ở bên ngoài có con chó.',
      },

      // NGỮ PHÁP 3: N の Vị trí
      {
        'type': LessonType.grammarStructure,
        'title': 'TỪ CHỈ VỊ TRÍ',
        'formula': 'Danh từ + の + 上 / 下 / 中 / 外',
        'meaning': 'Phía trên/dưới/trong/ngoài của N',
      },
      {
        'type': LessonType.grammarUsage,
        'title': 'CÁCH ĐỊNH VỊ',
        'notes': [
          'Trong tiếng Nhật, để nói "Trong cái hộp", ta phải lật ngược lại thành "Cái hộp CỦA bên trong": 箱の中.',
          'Cụm từ này đóng vai trò như một danh từ chỉ địa điểm, có thể đi kèm với trợ từ に.',
        ],
      },
      {
        'type': LessonType.grammarExample,
        'title': 'TỪ CHỈ VỊ TRÍ',
        'img': 'assets/images/example_naka.png',
        'jp': '箱の中に本があります。',
        'rmj': 'Hako no naka ni hon ga arimasu.',
        'vn': 'Ở trong hộp có quyển sách.',
      },

      // ================= PHẦN 3: TỔNG KẾT =================
      {
        'type': LessonType.vocabSummary,
        'words': [
          {'kanji': 'あります', 'romaji': 'arimasu', 'meaning': 'có (đồ vật)'},
          {'kanji': 'います', 'romaji': 'imasu', 'meaning': 'có (người/vật)'},
          {'kanji': '上', 'romaji': 'ue', 'meaning': 'trên'},
          {'kanji': '下', 'romaji': 'shita', 'meaning': 'dưới'},
          {'kanji': '中', 'romaji': 'naka', 'meaning': 'trong'},
          {'kanji': '外', 'romaji': 'soto', 'meaning': 'ngoài'},
        ],
      },
    ];
  }

  List<Map<String, dynamic>> _getCb10LuyenTap1Data() {
    return [
      {
        'type': LessonType.imageQuiz,
        'question': 'Bên trên.',
        'answerIndex': 0,
        'options': [
          {'img': 'assets/images/example_ue.png', 'jp': '上', 'rmj': 'ue'},
          {'img': 'assets/images/example_shita.png', 'jp': '下', 'rmj': 'shita'},
          {'img': 'assets/images/example_naka.png', 'jp': '中', 'rmj': 'naka'},
          {'img': 'assets/images/example_soto.png', 'jp': '外', 'rmj': 'soto'},
        ],
      },
      {
        'type': LessonType.listening,
        'options': [
          {'kanji': 'あります', 'hiragana': 'あります'},
          {'kanji': 'います', 'hiragana': 'います'},
          {'kanji': '箱', 'hiragana': 'はこ'},
          {'kanji': '中', 'hiragana': 'なか'},
        ],
        'answer': '箱',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': '箱の中です。',
        'rmj': 'Hako no naka desu.',
        'audio_text': '箱の中です。',
        'words': ['cái hộp', 'trong', 'của', 'là', 'trên'],
        'answer': 'ở trong cái hộp', // Nghĩa tương đương
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': '',
        'rmj': '',
        'audio_text': '箱の上に本があります。',
        'words': ['箱', 'の', '上', 'に', '本', 'が', 'あります'],
        'answer': '箱 の 上 に 本 が あります',
      },
    ];
  }

  List<Map<String, dynamic>> _getCb10LuyenTap2Data() {
    return [
      {
        'type': LessonType.quiz,
        'question': 'Điền từ đúng (Có con mèo): \n猫が ( ... )。',
        'options': ['あります', 'います', 'です', 'わかります'],
        'answer': 'います', // Mèo là động vật
      },
      {
        'type': LessonType.quiz,
        'question': 'Điền từ đúng (Có ô tô): \n車が ( ... )。',
        'options': ['あります', 'います', 'です', 'わかります'],
        'answer': 'あります', // Ô tô là vật vô tri
      },
      {
        'type': LessonType.quiz,
        'question': 'Bên ngoài có con chó.',
        'audio_text': '外に犬がいます。',
        'options': [
          {'kanji': '外に犬があります。', 'hiragana': 'そとにいぬがあります。'},
          {'kanji': '外に犬がいます。', 'hiragana': 'そとにいぬがいます。'},
        ],
        'answer': '外に犬がいます。',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': '',
        'rmj': '',
        'audio_text': '車の中に猫がいます。',
        'words': ['車', 'の', '中', 'に', '猫', 'が', 'います', 'あります'],
        'answer': '車 の 中 に 猫 が います',
      },
    ];
  }

  List<Map<String, dynamic>> _getCb10LuyenTap3Data() {
    return [
      {
        'type': LessonType.quiz,
        'question': 'Điền trợ từ (Ở trong hộp có sách): \n箱の中 ( ... ) 本があります。',
        'options': ['を', 'に', 'で', 'へ'],
        'answer': 'に',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': '',
        'rmj': '',
        'audio_text': '日本の町に大きい車があります。', // Ráp với tính từ của Bài 8
        'words': ['日本', 'の', '町', 'に', '大きい', '車', 'が', 'あります'],
        'answer': '日本 の 町 に 大きい 車 が あります',
      },
      {
        'type': LessonType.matching,
        'pairs': [
          {'left': 'Trên', 'right': '上'},
          {'left': 'Dưới', 'right': '下'},
          {'left': 'Trong', 'right': '中'},
          {'left': 'Ngoài', 'right': '外'},
          {'left': 'Có (đồ vật)', 'right': 'あります'},
        ],
      },
    ];
  }

  List<Map<String, dynamic>> _getCb10LuyenNoiData() {
    return [
      {'type': LessonType.speaking, 'jp': '本があります。', 'answer': 'ほんがあります'},
      {'type': LessonType.speaking, 'jp': '犬がいます。', 'answer': 'いぬがいます'},
      {'type': LessonType.speaking, 'jp': '箱の中です。', 'answer': 'はこのなかです'},
      {
        'type': LessonType.speaking,
        'jp': '箱の上に本があります。',
        'answer': 'はこのうえにほんがあります',
      },
      {'type': LessonType.speaking, 'jp': '外に犬がいます。', 'answer': 'そとにいぬがいます'},
    ];
  }

  List<Map<String, dynamic>> _getCb10LuyenVietData() {
    return [
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '上',
        'kanji_target': '上',
        'meaning': 'Thượng (Trên)',
        'rmj': 'ue / jou',
      },
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '下',
        'kanji_target': '下',
        'meaning': 'Hạ (Dưới)',
        'rmj': 'shita / ge',
      },
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '中',
        'kanji_target': '中',
        'meaning': 'Trung (Trong / Giữa)',
        'rmj': 'naka / chuu',
      },
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '外',
        'kanji_target': '外',
        'meaning': 'Ngoại (Ngoài)',
        'rmj': 'soto / gai',
      },
      {
        'type': LessonType.matching,
        'pairs': [
          {'left': 'Thượng', 'right': '上'},
          {'left': 'Hạ', 'right': '下'},
          {'left': 'Trung', 'right': '中'},
          {'left': 'Ngoại', 'right': '外'},
          {'left': 'Hộp', 'right': '箱'}, // Có thể vẽ thêm hoặc chỉ ghép chữ
        ],
      },
    ];
  }

  List<Map<String, dynamic>> _generateAlphabetData(List<Map<String, String>> chars) {
    List<Map<String, dynamic>> data = [];
    for (var c in chars) {
      String gifName = c['romaji'] == 'ne' ? 'ne1' : c['romaji']!;
      data.add({
        'type': LessonType.learn,
        'char': c['kana'],
        'romaji': c['romaji'],
        'gif': 'assets/gifs/$gifName.gif'
      });
      
      List<String> options = ['あ', 'い', 'う', 'え', 'お', 'か', 'き', 'く', 'け', 'こ', 'さ', 'し', 'す', 'せ', 'そ', 'た', 'ち', 'つ', 'て', 'と', 'な', 'に', 'ぬ', 'ね', 'の', 'は', 'ひ', 'ふ', 'へ', 'ほ', 'ま', 'み', 'む', 'め', 'も', 'や', 'ゆ', 'よ', 'ら', 'り', 'る', 'れ', 'ろ', 'わ', 'を', 'ん'];
      options.remove(c['kana']);
      options.shuffle();
      List<String> finalOptions = [c['kana']!, ...options.take(3)]..shuffle();

      data.add({
        'type': LessonType.quiz,
        'question': 'Chọn chữ "${c['romaji']}"',
        'options': finalOptions,
        'answer': c['kana']
      });
    }
    return data;
  }

  List<Map<String, dynamic>> _getHangAData() {
    return _generateAlphabetData([
      {'kana': 'あ', 'romaji': 'a'}, {'kana': 'い', 'romaji': 'i'}, {'kana': 'う', 'romaji': 'u'}, {'kana': 'え', 'romaji': 'e'}, {'kana': 'お', 'romaji': 'o'},
    ]);
  }

  List<Map<String, dynamic>> _getHangKaData() {
    return _generateAlphabetData([
      {'kana': 'か', 'romaji': 'ka'}, {'kana': 'き', 'romaji': 'ki'}, {'kana': 'く', 'romaji': 'ku'}, {'kana': 'け', 'romaji': 'ke'}, {'kana': 'こ', 'romaji': 'ko'},
    ]);
  }

  List<Map<String, dynamic>> _getHangSaData() {
    return _generateAlphabetData([
      {'kana': 'さ', 'romaji': 'sa'}, {'kana': 'し', 'romaji': 'shi'}, {'kana': 'す', 'romaji': 'su'}, {'kana': 'せ', 'romaji': 'se'}, {'kana': 'そ', 'romaji': 'so'},
    ]);
  }

  List<Map<String, dynamic>> _getHangTaData() {
    return _generateAlphabetData([
      {'kana': 'た', 'romaji': 'ta'}, {'kana': 'ち', 'romaji': 'chi'}, {'kana': 'つ', 'romaji': 'tsu'}, {'kana': 'て', 'romaji': 'te'}, {'kana': 'と', 'romaji': 'to'},
    ]);
  }

  List<Map<String, dynamic>> _getHangNaData() {
    return _generateAlphabetData([
      {'kana': 'な', 'romaji': 'na'}, {'kana': 'に', 'romaji': 'ni'}, {'kana': 'ぬ', 'romaji': 'nu'}, {'kana': 'ね', 'romaji': 'ne'}, {'kana': 'の', 'romaji': 'no'},
    ]);
  }

  List<Map<String, dynamic>> _getHangHaData() {
    return _generateAlphabetData([
      {'kana': 'は', 'romaji': 'ha'}, {'kana': 'ひ', 'romaji': 'hi'}, {'kana': 'ふ', 'romaji': 'fu'}, {'kana': 'へ', 'romaji': 'he'}, {'kana': 'ほ', 'romaji': 'ho'},
    ]);
  }

  List<Map<String, dynamic>> _getHangMaData() {
    return _generateAlphabetData([
      {'kana': 'ま', 'romaji': 'ma'}, {'kana': 'み', 'romaji': 'mi'}, {'kana': 'む', 'romaji': 'mu'}, {'kana': 'め', 'romaji': 'me'}, {'kana': 'も', 'romaji': 'mo'},
    ]);
  }

  List<Map<String, dynamic>> _getHangYaData() {
    return _generateAlphabetData([
      {'kana': 'や', 'romaji': 'ya'}, {'kana': 'ゆ', 'romaji': 'yu'}, {'kana': 'よ', 'romaji': 'yo'},
    ]);
  }

  List<Map<String, dynamic>> _getHangRaData() {
    return _generateAlphabetData([
      {'kana': 'ら', 'romaji': 'ra'}, {'kana': 'り', 'romaji': 'ri'}, {'kana': 'る', 'romaji': 'ru'}, {'kana': 'れ', 'romaji': 're'}, {'kana': 'ろ', 'romaji': 'ro'},
    ]);
  }

  List<Map<String, dynamic>> _getHangWaNData() {
    return _generateAlphabetData([
      {'kana': 'わ', 'romaji': 'wa'}, {'kana': 'を', 'romaji': 'wo'}, {'kana': 'ん', 'romaji': 'n'},
    ]);
  }

  List<Map<String, dynamic>> _getFinalReviewData() {
    List<Map<String, dynamic>> data = [];
    List<Map<String, String>> allChars = [
      {'kana': 'あ', 'romaji': 'a'}, {'kana': 'か', 'romaji': 'ka'}, {'kana': 'さ', 'romaji': 'sa'}, {'kana': 'た', 'romaji': 'ta'},
      {'kana': 'な', 'romaji': 'na'}, {'kana': 'は', 'romaji': 'ha'}, {'kana': 'ま', 'romaji': 'ma'}, {'kana': 'や', 'romaji': 'ya'},
      {'kana': 'ら', 'romaji': 'ra'}, {'kana': 'わ', 'romaji': 'wa'}, {'kana': 'ん', 'romaji': 'n'}
    ];
    allChars.shuffle();
    for (var c in allChars.take(8)) {
      List<String> options = ['あ', 'い', 'う', 'え', 'お', 'か', 'き', 'く', 'け', 'こ', 'さ', 'し', 'す', 'せ', 'そ', 'た', 'ち', 'つ', 'て', 'と', 'な', 'に', 'ぬ', 'ね', 'の', 'は', 'ひ', 'ふ', 'へ', 'ほ', 'ま', 'み', 'む', 'め', 'も', 'や', 'ゆ', 'よ', 'ら', 'り', 'る', 'れ', 'ろ', 'わ', 'を', 'ん'];
      options.remove(c['kana']);
      options.shuffle();
      List<String> finalOptions = [c['kana']!, ...options.take(3)]..shuffle();
      data.add({
        'type': LessonType.quiz,
        'question': 'Chọn chữ "${c['romaji']}"',
        'options': finalOptions,
        'answer': c['kana']
      });
    }
    return data;
  }

  void _nextActivity() {
    if (_currentIndex < _activities.length - 1) {
      setState(() {
        _currentIndex++;
      });
      bool isAudioDisabled =
          LessonScreen.audioDisabledUntil != null &&
          DateTime.now().isBefore(LessonScreen.audioDisabledUntil!);
      if (isAudioDisabled &&
          _activities[_currentIndex]['type'] == LessonType.listening) {
        _nextActivity();
        return;
      }
      _progress = (_currentIndex + 1) / _activities.length;
      _playCurrentAudio();
    } else {
      _finishLesson();
    }
  }

  void _finishLesson() async {
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

  void _showResultSheet(
    bool isCorrect,
    String correctAnswer,
    String userAnswer,
  ) {
    if (isCorrect) {
      _correctAnswers++;
      SoundManager.instance.vibrate('light');
      SoundManager.instance.speakJapanese("Seikai");
    } else {
      // NẾU SAI SẼ ĐƯA VÀO DANH SÁCH CẦN ÔN TẬP
      _wrongAnswers.add(correctAnswer.toLowerCase());

      SoundManager.instance.vibrate('error');
      SoundManager.instance.speakJapanese(correctAnswer);
    }

    Color typeColor = isCorrect
        ? const Color(0xFF58CC02)
        : const Color(0xFFFF4B4B);
    Color bgColor = isCorrect
        ? const Color(0xFFD7FFB8)
        : const Color(0xFFFFDFE0);
    String title = isCorrect ? "Đúng rồi!" : "Sai rồi";
    String msg = isCorrect ? "Tuyệt vời! Tiếp tục nào." : "Đáp án đúng:";
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
          padding: const EdgeInsets.all(20),
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
                    errorBuilder: (_, __, ___) => Icon(
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                color: typeColor,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.volume_up, color: typeColor),
                              onPressed: () => SoundManager.instance
                                  .speakJapanese(correctAnswer),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          msg,
                          style: TextStyle(
                            color: isCorrect ? typeColor : Colors.black54,
                            fontSize: 16,
                          ),
                        ),
                        if (!isCorrect)
                          Text(
                            correctAnswer,
                            style: TextStyle(
                              color: typeColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
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
                    _nextActivity();
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
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
    if (_activities.isEmpty)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final activity = _activities[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: LinearProgressIndicator(
          value: _progress,
          backgroundColor: Colors.grey[200],
          color: const Color(0xFF58CC02),
          minHeight: 12,
          borderRadius: BorderRadius.circular(6),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black54),
            onPressed: _showSettingsSheet,
          ),
        ],
      ),
      body: SafeArea(
        child: MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(AppSettings.textScale)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: _buildBody(activity),
          ),
        ),
      ),
    );
  }

  void _showSettingsSheet() {
    SoundManager.instance.vibrate('light');
    double tempFontScale = AppSettings.fontScaleValue;
    double tempSfxVolume = AppSettings.sfxVolumeValue;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Cỡ chữ",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFF66BB6A),
                      inactiveTrackColor: Colors.grey.shade300,
                      thumbColor: const Color(0xFF66BB6A),
                      tickMarkShape: const RoundSliderTickMarkShape(
                        tickMarkRadius: 5,
                      ),
                      activeTickMarkColor: const Color(0xFF66BB6A),
                      inactiveTickMarkColor: Colors.black87,
                      trackHeight: 4.0,
                    ),
                    child: Slider(
                      value: tempFontScale,
                      min: 0,
                      max: 4,
                      divisions: 4,
                      onChanged: (value) {
                        setModalState(() => tempFontScale = value);
                        SoundManager.instance.vibrate('light');
                      },
                    ),
                  ),
                  Center(
                    child: Text(
                      "Mặc định",
                      style: TextStyle(
                        color: tempFontScale == 2
                            ? const Color(0xFF58CC02)
                            : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "Âm lượng hiệu ứng âm thanh",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFF66BB6A),
                      inactiveTrackColor: Colors.grey.shade300,
                      thumbColor: const Color(0xFF66BB6A),
                      tickMarkShape: const RoundSliderTickMarkShape(
                        tickMarkRadius: 5,
                      ),
                      activeTickMarkColor: const Color(0xFF66BB6A),
                      inactiveTickMarkColor: Colors.black87,
                      trackHeight: 4.0,
                    ),
                    child: Slider(
                      value: tempSfxVolume,
                      min: 0,
                      max: 100,
                      divisions: 4,
                      onChanged: (value) {
                        setModalState(() => tempSfxVolume = value);
                        SoundManager.instance.vibrate('light');
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "0",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          "25",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          "50",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          "75",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          "100",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        SoundManager.instance.vibrate('light');
                        setState(() {
                          AppSettings.fontScaleValue = tempFontScale;
                          AppSettings.sfxVolumeValue = tempSfxVolume;
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF66BB6A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Lưu",
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
      },
    );
  }

  Widget _buildBody(Map<String, dynamic> data) {
    switch (data['type'] as LessonType) {
      case LessonType.vocabListIntro:
        return VocabListIntroView(words: data['words'], onNext: _nextActivity);
      case LessonType.grammarListIntro:
        return GrammarListIntroView(
          grammars: data['grammars'],
          onNext: _nextActivity,
        );
      case LessonType.grammarStructure:
        return GrammarStructureView(data: data, onNext: _nextActivity);
      case LessonType.grammarUsage:
        return GrammarUsageView(data: data, onNext: _nextActivity);
      case LessonType.grammarExample:
        return GrammarExampleView(data: data, onNext: _nextActivity);
      case LessonType.learn:
        return _buildLearnView(data);
      case LessonType.quiz:
        return StandardQuizView(
          data: data,
          onCheckResult: (isCorrect, correctAns, userAns) =>
              _showResultSheet(isCorrect, correctAns, userAns),
        );
      case LessonType.matching:
        return _buildMatchingView(data);
      case LessonType.imageQuiz:
        return _buildImageQuizView(data);
      case LessonType.listening:
        return ListeningQuizView(
          data: data,
          onCheckResult: (isCorrect, correctAns, userAns) =>
              _showResultSheet(isCorrect, correctAns, userAns),
        );
      case LessonType.sentenceBuilder:
        return SentenceBuilderView(
          data: data,
          onCheckResult: (isCorrect, correctAns, userAns) =>
              _showResultSheet(isCorrect, correctAns, userAns),
        );
      case LessonType.speaking:
        return SpeakingPracticeView(
          data: data,
          onCheckResult: (isCorrect, correctAns, userAns) =>
              _showResultSheet(isCorrect, correctAns, userAns),
          onSkip: _nextActivity,
        );
      case LessonType.kanjiDraw:
        return KanjiDrawView(data: data, onNext: _nextActivity);
      case LessonType.flashCard:
        return FlashCardView(data: data, onNext: _nextActivity);
      case LessonType.vocabQuiz:
        return VocabQuizView(
          data: data,
          onCheckResult: (isCorrect, correctAns, userAns) =>
              _showResultSheet(isCorrect, correctAns, userAns),
        );
      case LessonType.vocabSummary:
        return VocabSummaryView(
          words: data['words'],
          wrongAnswers: _wrongAnswers,
          onNext: _nextActivity,
          onExit: _finishLesson,
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildLearnView(Map<String, dynamic> data) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Tập viết chữ cái",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 30),
        Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300, width: 2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(
              data['gif'] ?? '',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 50),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          data['char'],
          style: const TextStyle(
            fontSize: 60,
            fontWeight: FontWeight.bold,
            color: Color(0xFF58CC02),
          ),
        ),
        Text(
          data['romaji'],
          style: const TextStyle(fontSize: 24, color: Colors.grey),
        ),
        IconButton(
          icon: const Icon(Icons.volume_up, size: 40, color: Color(0xFF58CC02)),
          onPressed: () => SoundManager.instance.speakJapanese(data['char']),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              SoundManager.instance.vibrate('light');
              _nextActivity();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF58CC02),
            ),
            child: const Text(
              "ĐÃ HIỂU",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
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
      },
    );
  }

  Widget _buildImageQuizView(Map<String, dynamic> data) {
    return Column(
      children: [
        const Text(
          "Từ nào có nghĩa là",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          data['question'],
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 30),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: data['options'].length,
            itemBuilder: (context, index) {
              final opt = data['options'][index];
              return GestureDetector(
                onTap: () {
                  bool isCorrect = (index == data['answerIndex']);
                  _showResultSheet(
                    isCorrect,
                    data['options'][data['answerIndex']]['jp'],
                    opt['jp'],
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(14),
                          ),
                          child: Image.asset(
                            opt['img'],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.shade100,
                              child: const Icon(
                                Icons.image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          children: [
                            Text(
                              opt['jp'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              opt['rmj'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
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
}

// ==========================================================
// CÁC MÀN HÌNH MỚI: LÝ THUYẾT & NGỮ PHÁP (HÌNH 1 ĐẾN 5)
// ==========================================================
class VocabListIntroView extends StatelessWidget {
  final List<dynamic> words;
  final VoidCallback onNext;

  const VocabListIntroView({
    super.key,
    required this.words,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "👉 Từ vựng bạn sẽ học",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: words.length,
            itemBuilder: (context, index) {
              final w = words[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              children: [
                                TextSpan(
                                  text: w['kanji'] != ''
                                      ? w['kanji']
                                      : w['hiragana'],
                                ),
                                TextSpan(
                                  text: "  (${w['romaji']})",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            w['meaning'],
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => SoundManager.instance.speakJapanese(
                        w['kanji'] != '' ? w['kanji'] : w['hiragana'],
                      ),
                      child: const Icon(Icons.volume_up, color: Colors.grey),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF78C850),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Học từ vựng",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class GrammarListIntroView extends StatelessWidget {
  final List<dynamic> grammars;
  final VoidCallback onNext;

  const GrammarListIntroView({
    super.key,
    required this.grammars,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "👉 Ngữ pháp bạn sẽ học",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: grammars.length,
            itemBuilder: (context, index) {
              final g = grammars[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      g['title'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      g['meaning'],
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF78C850),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Học ngữ pháp",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class GrammarStructureView extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onNext;

  const GrammarStructureView({
    super.key,
    required this.data,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            "《 NGỮ PHÁP MỚI 》",
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 15),
        Center(
          child: Text(
            data['title'],
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 40),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF78C850),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            "Cấu trúc",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          "●  " + data['formula'],
          style: const TextStyle(
            fontSize: 20,
            color: Color(0xFF78C850),
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            "Nghĩa",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          data['meaning'],
          style: const TextStyle(fontSize: 18, color: Colors.black87),
        ),

        const Spacer(),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: onNext,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class GrammarUsageView extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onNext;

  const GrammarUsageView({super.key, required this.data, required this.onNext});

  @override
  Widget build(BuildContext context) {
    List<dynamic> notes = data['notes'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            "Cách sử dụng",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          data['title'],
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 30),

        Expanded(
          child: ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Icon(Icons.circle, size: 10, color: Colors.grey),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        notes[index],
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: onNext,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class GrammarExampleView extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onNext;

  const GrammarExampleView({
    super.key,
    required this.data,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF4285F4),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            "Ví dụ",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          data['title'],
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF78C850),
          ),
        ),
        const SizedBox(height: 30),

        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              data['img'],
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.image, size: 50),
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),

        GestureDetector(
          onTap: () => SoundManager.instance.speakJapanese(data['jp']),
          child: Text(
            data['jp'],
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          data['rmj'],
          style: const TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          data['vn'],
          style: const TextStyle(
            fontSize: 18,
            color: Color(0xFF78C850),
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 40),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onNext,
                icon: const Icon(Icons.check_circle, color: Color(0xFF78C850)),
                label: const Text(
                  "Đã hiểu",
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF7F7F7),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onNext,
                icon: const Icon(Icons.cancel, color: Colors.redAccent),
                label: const Text(
                  "Nhắc tôi sau",
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF7F7F7),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ==========================================================
// CÁC WIDGET CŨ NHƯNG CẬP NHẬT LOGIC (SentenceBuilder, KanjiDraw, v.v...)
// ==========================================================

class SentenceBuilderView extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function(bool, String, String) onCheckResult;

  const SentenceBuilderView({
    super.key,
    required this.data,
    required this.onCheckResult,
  });

  @override
  State<SentenceBuilderView> createState() => _SentenceBuilderViewState();
}

class _SentenceBuilderViewState extends State<SentenceBuilderView> {
  List<String> poolWords = [];
  List<String> selectedWords = [];

  String _normalize(String s) =>
      s.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  @override
  void initState() {
    super.initState();
    poolWords = List<String>.from(widget.data['words'])..shuffle();
  }

  @override
  Widget build(BuildContext context) {
    // Kiểm tra xem có phải dạng ẩn chữ chỉ hiện audio không
    bool isAudioOnly =
        widget.data['jp'] == null || widget.data['jp'].toString().isEmpty;

    return Column(
      children: [
        Text(
          isAudioOnly ? "Nghe và ghép từ thành câu" : "Nghe và dịch câu sau",
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),

        if (!isAudioOnly) ...[
          Text(
            widget.data['jp'],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            widget.data['rmj'],
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 20),

          GestureDetector(
            onTap: () => SoundManager.instance.speakJapanese(
              widget.data['audio_text'] ?? widget.data['jp'],
            ),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F8E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.volume_up,
                color: Color(0xFF58CC02),
                size: 40,
              ),
            ),
          ),
        ] else ...[
          // HIỂN THỊ NÚT AUDIO LỚN GIỮA MÀN HÌNH NẾU ẨN CHỮ
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  SoundManager.instance.vibrate('light');
                  SoundManager.instance.speakJapanese(
                    widget.data['audio_text'] ?? widget.data['answer'],
                  );
                },
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEF7E8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.volume_up,
                    color: Color(0xFF58CC02),
                    size: 45,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () {
                  SoundManager.instance.vibrate('light');
                  SoundManager.instance.speakJapanese(
                    widget.data['audio_text'] ?? widget.data['answer'],
                    isSlow: true,
                  );
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEF7E8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.pets,
                    color: Color(0xFF58CC02),
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 30),
        Divider(color: Colors.grey.shade300, thickness: 2),
        const SizedBox(height: 30),

        Container(
          constraints: const BoxConstraints(minHeight: 60),
          width: double.infinity,
          alignment: Alignment.center,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: selectedWords
                .map((word) => _buildWordChip(word, true))
                .toList(),
          ),
        ),

        const Spacer(),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: poolWords
              .map((word) => _buildWordChip(word, false))
              .toList(),
        ),

        const SizedBox(height: 40),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: selectedWords.isEmpty
                ? null
                : () {
                    String userAnswer = selectedWords.join(' ');
                    bool isCorrect = (userAnswer == widget.data['answer']);
                    widget.onCheckResult(
                      isCorrect,
                      widget.data['answer'],
                      userAnswer,
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedWords.isEmpty
                  ? Colors.grey.shade300
                  : const Color(0xFF58CC02),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              "Kiểm tra",
              style: TextStyle(
                color: selectedWords.isEmpty ? Colors.grey : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
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
          boxShadow: [
            BoxShadow(color: Colors.grey.shade200, offset: const Offset(0, 3)),
          ],
        ),
        child: Text(
          word,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

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
        Text(
          widget.data['rmj'],
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.data['kanji_word'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => SoundManager.instance.speakJapanese(
                widget.data['kanji_word'],
              ),
              child: const Icon(
                Icons.volume_up,
                color: Color(0xFF58CC02),
                size: 28,
              ),
            ),
          ],
        ),
        Text(
          widget.data['meaning'],
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 20),

        Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade100,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: Container(
                  width: double.infinity,
                  height: 1,
                  color: Colors.grey.shade200,
                ),
              ),
              Center(
                child: Container(
                  height: double.infinity,
                  width: 1,
                  color: Colors.grey.shade200,
                ),
              ),
              Center(
                child: Text(
                  widget.data['kanji_target'],
                  style: TextStyle(
                    fontSize: 220,
                    color: Colors.grey.shade200,
                    height: 1.1,
                  ),
                ),
              ),
              GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    RenderBox renderBox =
                        context.findRenderObject() as RenderBox;
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

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.visibility_off, color: Colors.green),
            ),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: () => setState(() => points.clear()),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF58CC02),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cleaning_services,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.visibility, color: Colors.green),
            ),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: widget.onNext,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.keyboard_double_arrow_right,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: widget.onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF58CC02),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              "Tiếp tục",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

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

class MatchingGame extends StatefulWidget {
  final List<Map<String, String>> pairs;
  final VoidCallback onCompleted;
  const MatchingGame({
    super.key,
    required this.pairs,
    required this.onCompleted,
  });
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
    SoundManager.instance.vibrate('light');
    setState(() {
      if (isLeft) {
        selectedLeft = (selectedLeft == item) ? null : item;
      } else {
        selectedRight = (selectedRight == item) ? null : item;
      }
    });
    _checkMatch();
  }

  void _checkMatch() async {
    if (selectedLeft != null && selectedRight != null) {
      bool isCorrect = widget.pairs.any(
        (pair) =>
            pair['left'] == selectedLeft && pair['right'] == selectedRight,
      );

      if (isCorrect) {
        SoundManager.instance.vibrate('light');
        setState(() {
          matchedItems.add(selectedLeft!);
          matchedItems.add(selectedRight!);
          selectedLeft = null;
          selectedRight = null;
        });
        if (matchedItems.length == widget.pairs.length * 2) {
          await Future.delayed(const Duration(milliseconds: 500));
          widget.onCompleted();
        }
      } else {
        SoundManager.instance.vibrate('error');
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          setState(() {
            selectedLeft = null;
            selectedRight = null;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Ghép các cặp từ tương ứng",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Color(0xFF777777),
          ),
        ),
        const SizedBox(height: 30),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: leftItems
                      .map((item) => _buildCard(item, true))
                      .toList(),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: rightItems
                      .map((item) => _buildCard(item, false))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCard(String text, bool isLeft) {
    bool isSelected = isLeft ? (selectedLeft == text) : (selectedRight == text);
    bool isMatched = matchedItems.contains(text);
    Color bgColor;
    Color borderColor;
    Color textColor;

    if (isMatched) {
      bgColor = const Color(0xFFF0F0F0);
      borderColor = Colors.transparent;
      textColor = Colors.grey.shade400;
    } else if (isSelected) {
      bgColor = const Color(0xFFE5F6D5);
      borderColor = const Color(0xFF88D847);
      textColor = const Color(0xFF58CC02);
    } else {
      bgColor = const Color(0xFFF7F7F7);
      borderColor = Colors.transparent;
      textColor = Colors.black87;
    }

    return IgnorePointer(
      ignoring: isMatched,
      child: GestureDetector(
        onTap: () => _handleTap(text, isLeft),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Center(
            child: isMatched
                ? const Icon(Icons.check, color: Color(0xFFD0D0D0), size: 28)
                : Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: text.length > 5 ? 16 : 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class LessonCompletionScreen extends StatelessWidget {
  final int correctCount;
  final int totalCount;
  final int expEarned;

  const LessonCompletionScreen({
    super.key,
    required this.correctCount,
    required this.totalCount,
    required this.expEarned,
  });

  @override
  Widget build(BuildContext context) {
    int percent = totalCount > 0
        ? ((correctCount / totalCount) * 100).round()
        : 100;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Image.asset(
                'assets/images/dog_happy.png',
                height: 200,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.emoji_events,
                  size: 150,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Bạn đã hoàn thành bài học!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3C3C3C),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: _buildResultCard(
                      label: "$correctCount/$totalCount",
                      icon: Icons.track_changes,
                      color: const Color(0xFF4285F4),
                      bgColor: const Color(0xFFE8F0FE),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildResultCard(
                      label: "$percent%",
                      icon: Icons.headphones,
                      color: const Color(0xFF58CC02),
                      bgColor: const Color(0xFFE5F6D5),
                      badge: "+5 ⚡",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                "~~ ❇ ~~",
                style: TextStyle(color: Colors.grey, fontSize: 20),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "EXP",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    "+$expEarned ⚡",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: 0.9,
                  minHeight: 12,
                  backgroundColor: Colors.grey[200],
                  color: const Color(0xFFFFC800),
                ),
              ),
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("-", style: TextStyle(color: Colors.grey)),
                  Text(
                    "9 exp để lên cấp",
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    "Tân binh",
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF58CC02),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Tiếp tục",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard({
    required String label,
    required IconData icon,
    required Color color,
    required Color bgColor,
    String? badge,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: bgColor, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (badge != null)
          Positioned(
            top: -10,
            right: -5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class FlashCardView extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback onNext;

  const FlashCardView({super.key, required this.data, required this.onNext});

  @override
  State<FlashCardView> createState() => _FlashCardViewState();
}

class _FlashCardViewState extends State<FlashCardView> {
  bool _isFlipped = false;

  @override
  void didUpdateWidget(covariant FlashCardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      setState(() {
        _isFlipped = false;
      });
    }
  }

  void _toggleFlip() {
    SoundManager.instance.vibrate('light');
    setState(() {
      _isFlipped = !_isFlipped;
    });

    if (_isFlipped) {
      SoundManager.instance.speakJapanese(widget.data['example_jp']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _toggleFlip,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: _isFlipped ? _buildBack() : _buildFront(),
            ),
          ),
        ),
        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: _isFlipped ? widget.onNext : _toggleFlip,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF58CC02),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
            ),
            child: Text(
              _isFlipped ? "Tiếp tục" : "Lật thẻ",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFront() {
    String kanji = widget.data['kanji']?.toString() ?? '';
    String hiragana = widget.data['hiragana']?.toString() ?? '';

    String mainText = kanji.isNotEmpty ? kanji : hiragana;
    bool showFurigana = kanji.isNotEmpty && kanji != hiragana;

    return Container(
      key: const ValueKey('front'),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4C7),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "《 TỪ MỚI 》",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF5A6275),
                  fontSize: 16,
                ),
              ),
            ],
          ),

          const Spacer(),

          if (showFurigana)
            Text(
              hiragana,
              style: const TextStyle(fontSize: 20, color: Colors.black54),
            ),

          Text(
            mainText,
            style: const TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 15),
          Text(
            widget.data['romaji'],
            style: const TextStyle(fontSize: 18, color: Color(0xFF7A8394)),
          ),
          const SizedBox(height: 15),
          Text(
            widget.data['meaning'],
            style: const TextStyle(fontSize: 20, color: Colors.black87),
          ),

          const Spacer(),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSoundBtn(
                Icons.pets,
                () => SoundManager.instance.speakJapanese(
                  hiragana.isNotEmpty ? hiragana : mainText,
                  isSlow: true,
                ),
              ),
              const SizedBox(width: 20),
              _buildSoundBtn(
                Icons.volume_up,
                () => SoundManager.instance.speakJapanese(
                  hiragana.isNotEmpty ? hiragana : mainText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      key: const ValueKey('back'),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4C7),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF9E8A2F),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Ví dụ",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 25),

          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                widget.data['example_img'],
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.white54,
                  child: const Icon(Icons.image, size: 50, color: Colors.grey),
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          GestureDetector(
            onTap: () {
              SoundManager.instance.vibrate('light');
              SoundManager.instance.speakJapanese(widget.data['example_jp']);
            },
            child: Column(
              children: [
                Text(
                  widget.data['example_jp'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.data['example_rmj'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF7A8394),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text(
            widget.data['example_vn'],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF78C850),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildSoundBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        SoundManager.instance.vibrate('light');
        onTap();
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: const BoxDecoration(
          color: Color(0xFF6B5B15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 35),
      ),
    );
  }
}

class VocabQuizView extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function(bool, String, String) onCheckResult;

  const VocabQuizView({
    super.key,
    required this.data,
    required this.onCheckResult,
  });

  @override
  State<VocabQuizView> createState() => _VocabQuizViewState();
}

class _VocabQuizViewState extends State<VocabQuizView> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    List<String> options = widget.data['options'];
    bool isSelected = _selectedIndex != null;

    String kanji = widget.data['kanji']?.toString() ?? '';
    String hiragana = widget.data['hiragana']?.toString() ?? '';

    String mainText = kanji.isNotEmpty ? kanji : hiragana;
    bool showFurigana = kanji.isNotEmpty && kanji != hiragana;

    return Column(
      children: [
        const Text(
          "Chọn nghĩa của từ dưới đây",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Color(0xFF777777),
          ),
        ),
        const SizedBox(height: 30),

        if (showFurigana)
          Text(
            hiragana,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),

        Text(
          mainText,
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),

        Text(
          widget.data['romaji'],
          style: const TextStyle(fontSize: 18, color: Color(0xFF7A8394)),
        ),

        const SizedBox(height: 25),

        GestureDetector(
          onTap: () {
            SoundManager.instance.vibrate('light');
            SoundManager.instance.speakJapanese(
              hiragana.isNotEmpty ? hiragana : mainText,
            );
          },
          child: Container(
            width: 65,
            height: 65,
            decoration: const BoxDecoration(
              color: Color(0xFFEEF7E8),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.volume_up,
              color: Color(0xFF58CC02),
              size: 35,
            ),
          ),
        ),

        const SizedBox(height: 40),

        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.3,
            ),
            itemCount: options.length,
            itemBuilder: (context, index) {
              bool isThisSelected = _selectedIndex == index;

              return GestureDetector(
                onTap: () {
                  SoundManager.instance.vibrate('light');
                  setState(() => _selectedIndex = index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: isThisSelected
                        ? const Color(0xFFE5F6D5)
                        : const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    options[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isThisSelected
                          ? const Color(0xFF58CC02)
                          : Colors.black87,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: isSelected
                ? () {
                    String userAns = options[_selectedIndex!];
                    bool isCorrect = userAns == widget.data['answer'];
                    widget.onCheckResult(
                      isCorrect,
                      widget.data['answer'],
                      userAns,
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isSelected
                  ? const Color(0xFF58CC02)
                  : Colors.grey.shade200,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: Text(
              "Kiểm tra",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey.shade400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class VocabSummaryView extends StatefulWidget {
  final List<dynamic> words;
  final Set<String> wrongAnswers; // Nhận danh sách những câu làm sai
  final VoidCallback onNext;
  final VoidCallback onExit;

  const VocabSummaryView({
    super.key,
    required this.words,
    required this.wrongAnswers,
    required this.onNext,
    required this.onExit,
  });

  @override
  State<VocabSummaryView> createState() => _VocabSummaryViewState();
}

class _VocabSummaryViewState extends State<VocabSummaryView> {
  int _selectedTab = 1; // 0: Cần ôn tập, 1: Đã nắm vững

  @override
  Widget build(BuildContext context) {
    // PHÂN LOẠI TỪ VỰNG
    List<dynamic> needsReview = [];
    List<dynamic> mastered = [];

    for (var w in widget.words) {
      // Kiểm tra xem ý nghĩa, kanji hoặc romaji của từ này có nằm trong danh sách trả lời sai không
      String meaningLower = w['meaning'].toString().toLowerCase();
      String kanjiLower = w['kanji'].toString().toLowerCase();

      if (widget.wrongAnswers.contains(meaningLower) ||
          widget.wrongAnswers.contains(kanjiLower)) {
        needsReview.add(w);
      } else {
        mastered.add(w);
      }
    }

    // Danh sách sẽ hiển thị theo Tab
    List<dynamic> displayList = _selectedTab == 0 ? needsReview : mastered;

    return Column(
      children: [
        const Text(
          "Tổng kết bài học",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 20),

        // TAB SELECTOR
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTab = 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _selectedTab == 0
                          ? Colors.orange
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        "Cần ôn tập (${needsReview.length})",
                        style: TextStyle(
                          color: _selectedTab == 0 ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTab = 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _selectedTab == 1
                          ? const Color(0xFF58CC02)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        "Đã nắm vững (${mastered.length})",
                        style: TextStyle(
                          color: _selectedTab == 1 ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "TỪ VỰNG",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),

        Expanded(
          child: displayList.isEmpty
              ? Center(
                  child: Text(
                    _selectedTab == 0
                        ? "Quá tuyệt! Bạn không làm sai câu nào."
                        : "Chưa có từ nào hoàn thành.",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: displayList.length,
                  itemBuilder: (context, index) {
                    final w = displayList[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      // Chuyển icon X đỏ hoặc V xanh tùy tab
                      leading: Icon(
                        _selectedTab == 0 ? Icons.cancel : Icons.check_circle,
                        color: _selectedTab == 0
                            ? Colors.redAccent
                            : const Color(0xFF58CC02),
                        size: 28,
                      ),
                      title: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(text: w['kanji']! + " "),
                            TextSpan(
                              text: "(${w['romaji']})",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      subtitle: Text(
                        w['meaning']!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                      ),
                      onTap: () => SoundManager.instance.speakJapanese(
                        w['kanji'] != '' ? w['kanji'] : w['romaji'],
                      ),
                    );
                  },
                ),
        ),

        Row(
          children: [
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: widget.onExit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Thoát",
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: widget.onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF58CC02),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Học tiếp",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ListeningQuizView extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function(bool, String, String) onCheckResult;

  const ListeningQuizView({
    super.key,
    required this.data,
    required this.onCheckResult,
  });

  @override
  State<ListeningQuizView> createState() => _ListeningQuizViewState();
}

class _ListeningQuizViewState extends State<ListeningQuizView> {
  String? _selectedOption;

  @override
  void didUpdateWidget(covariant ListeningQuizView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      setState(() => _selectedOption = null);
    }
  }

  void _showCantListenDialog() {
    SoundManager.instance.vibrate('light');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFFFFF4C7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 30.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Chúng tôi sẽ tạm thời ẩn đi các câu hỏi cần nghe audio trong 15 phút tiếp theo!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      SoundManager.instance.vibrate('light');
                      LessonScreen.audioDisabledUntil = DateTime.now().add(
                        const Duration(minutes: 15),
                      );
                      Navigator.pop(context);
                      widget.onCheckResult(
                        true,
                        widget.data['answer'],
                        widget.data['answer'],
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF78C850),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      "Đồng ý",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                GestureDetector(
                  onTap: () {
                    SoundManager.instance.vibrate('light');
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Đóng",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF78C850),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> options = widget.data['options'];
    bool canCheck = _selectedOption != null;

    return Column(
      children: [
        const Text(
          "Nghe và chọn chữ cái tương ứng",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Color(0xFF777777),
          ),
        ),
        const SizedBox(height: 40),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildAudioBtn(Icons.volume_up, 90, 45, false),
            const SizedBox(width: 20),
            _buildAudioBtn(Icons.pets, 60, 28, true),
          ],
        ),

        const SizedBox(height: 40),

        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.1,
            physics: const NeverScrollableScrollPhysics(),
            children: widget.data['options'].map<Widget>((dynamic opt) {
              String kanji = '';
              String hiragana = '';
              String matchValue = '';

              if (opt is String) {
                kanji = opt;
                matchValue = opt;
              } else if (opt is Map) {
                kanji = opt['kanji']?.isNotEmpty == true
                    ? opt['kanji']
                    : opt['hiragana'];
                hiragana =
                    (opt['kanji']?.isNotEmpty == true &&
                        opt['kanji'] != opt['hiragana'])
                    ? opt['hiragana']
                    : '';
                matchValue = opt['kanji']?.isNotEmpty == true
                    ? opt['kanji']
                    : opt['hiragana'];
              }

              bool isSelected = (_selectedOption == matchValue);

              return GestureDetector(
                onTap: () {
                  SoundManager.instance.vibrate('light');
                  setState(() => _selectedOption = matchValue);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFE5F6D5)
                        : const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF88D847)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (hiragana.isNotEmpty)
                        Text(
                          hiragana,
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected
                                ? const Color(0xFF58CC02)
                                : Colors.grey.shade600,
                          ),
                        ),

                      Text(
                        kanji,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? const Color(0xFF58CC02)
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        TextButton(
          onPressed: _showCantListenDialog,
          child: const Text(
            "Bạn đang không thể nghe",
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 10),

        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: canCheck
                ? () {
                    widget.onCheckResult(
                      _selectedOption == widget.data['answer'],
                      widget.data['answer'],
                      _selectedOption!,
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canCheck
                  ? const Color(0xFF58CC02)
                  : Colors.grey.shade200,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              "KIỂM TRA",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: canCheck ? Colors.white : Colors.grey.shade400,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAudioBtn(
    IconData icon,
    double boxSize,
    double iconSize,
    bool isSlow,
  ) {
    return GestureDetector(
      onTap: () {
        SoundManager.instance.vibrate('light');
        SoundManager.instance.speakJapanese(
          widget.data['answer'],
          isSlow: isSlow,
        );
      },
      child: Container(
        width: boxSize,
        height: boxSize,
        decoration: const BoxDecoration(
          color: Color(0xFFEEF7E8),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF58CC02), size: iconSize),
      ),
    );
  }
}

class StandardQuizView extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function(bool, String, String) onCheckResult;

  const StandardQuizView({
    super.key,
    required this.data,
    required this.onCheckResult,
  });

  @override
  State<StandardQuizView> createState() => _StandardQuizViewState();
}

class _StandardQuizViewState extends State<StandardQuizView> {
  String? _selectedOption;

  @override
  void didUpdateWidget(covariant StandardQuizView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      setState(() => _selectedOption = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> options = widget.data['options'];
    bool canCheck = _selectedOption != null;

    // Kiểm tra xem có phải dạng ẩn chữ chỉ hiện audio không
    bool isAudioOnly =
        widget.data['question'] == null ||
        widget.data['question'].toString().isEmpty;

    return Column(
      children: [
        Text(
          isAudioOnly ? "Nghe và chọn đáp án đúng" : "Chọn đáp án đúng",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Color(0xFF777777),
          ),
        ),
        const SizedBox(height: 30),

        if (!isAudioOnly) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  widget.data['question'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => SoundManager.instance.speakJapanese(
                  widget.data['audio_text'] ?? widget.data['question'],
                ),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEF7E8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.volume_up,
                    color: Color(0xFF58CC02),
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          // HIỂN THỊ NÚT AUDIO LỚN GIỮA MÀN HÌNH NẾU ẨN CHỮ
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  SoundManager.instance.vibrate('light');
                  SoundManager.instance.speakJapanese(
                    widget.data['audio_text'] ?? widget.data['answer'],
                  );
                },
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEF7E8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.volume_up,
                    color: Color(0xFF58CC02),
                    size: 45,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () {
                  SoundManager.instance.vibrate('light');
                  SoundManager.instance.speakJapanese(
                    widget.data['audio_text'] ?? widget.data['answer'],
                    isSlow: true,
                  );
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEF7E8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.pets,
                    color: Color(0xFF58CC02),
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 40),

        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.1,
            physics: const NeverScrollableScrollPhysics(),
            children: widget.data['options'].map<Widget>((dynamic opt) {
              String kanji = '';
              String hiragana = '';
              String matchValue = '';

              if (opt is String) {
                kanji = opt;
                matchValue = opt;
              } else if (opt is Map) {
                kanji = opt['kanji']?.isNotEmpty == true
                    ? opt['kanji']
                    : opt['hiragana'];
                hiragana =
                    (opt['kanji']?.isNotEmpty == true &&
                        opt['kanji'] != opt['hiragana'])
                    ? opt['hiragana']
                    : '';
                matchValue = opt['kanji']?.isNotEmpty == true
                    ? opt['kanji']
                    : opt['hiragana'];
              }

              bool isSelected = (_selectedOption == matchValue);

              return GestureDetector(
                onTap: () {
                  SoundManager.instance.vibrate('light');
                  setState(() => _selectedOption = matchValue);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFE5F6D5)
                        : const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF88D847)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (hiragana.isNotEmpty)
                        Text(
                          hiragana,
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected
                                ? const Color(0xFF58CC02)
                                : Colors.grey.shade600,
                          ),
                        ),

                      Text(
                        kanji,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? const Color(0xFF58CC02)
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: canCheck
                ? () {
                    widget.onCheckResult(
                      _selectedOption == widget.data['answer'],
                      widget.data['answer'],
                      _selectedOption!,
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canCheck
                  ? const Color(0xFF58CC02)
                  : Colors.grey.shade200,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              "KIỂM TRA",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: canCheck ? Colors.white : Colors.grey.shade400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SpeakingPracticeView extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function(bool, String, String) onCheckResult;
  final VoidCallback onSkip;

  const SpeakingPracticeView({
    super.key,
    required this.data,
    required this.onCheckResult,
    required this.onSkip,
  });

  @override
  State<SpeakingPracticeView> createState() => _SpeakingPracticeViewState();
}

class _SpeakingPracticeViewState extends State<SpeakingPracticeView> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = "";
  bool _isAvailable = false;
  bool _hasSpoken = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _isAvailable = await _speech.initialize(
      onError: (val) => debugPrint('onError: $val'),
    );
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _speech.cancel();
    super.dispose();
  }

  void _startListening() async {
    if (!_isAvailable) {
      bool available = await _speech.initialize(
        onError: (val) => debugPrint('onError: $val'),
      );
      if (mounted) {
        setState(() {
          _isAvailable = available;
        });
      }
      if (!available) return;
    }

    SoundManager.instance.vibrate('light');
    setState(() {
      _isListening = true;
      _recognizedText = "";
      _hasSpoken = false;
    });

    _speech.listen(
      onResult: (val) {
        if (mounted) {
          setState(() {
            _recognizedText = val.recognizedWords;
          });
        }
      },
      localeId: 'ja_JP', // Nhận diện giọng nói theo tiếng Nhật
    );
  }

  void _stopListening() {
    if (!_isListening) return;
    SoundManager.instance.vibrate('light');
    _speech.stop();
    setState(() {
      _isListening = false;
      _hasSpoken = true;
    });
  }

  void _checkAnswer() {
    String targetAnswer = widget.data['answer'].toString();
    bool isCorrect = _compareJapaneseText(targetAnswer, _recognizedText);
    widget.onCheckResult(isCorrect, targetAnswer, _recognizedText);
  }

  bool _compareJapaneseText(String target, String input) {
    String cleanTarget = target.replaceAll(RegExp(r'[。、！？\s]'), '');
    String cleanInput = input.replaceAll(RegExp(r'[。、！？\s]'), '');

    cleanTarget = cleanTarget
        .replaceAll('こんにちは', 'こんにちわ')
        .replaceAll('こんばんは', 'こんばんわ');
    cleanInput = cleanInput
        .replaceAll('こんにちは', 'こんにちわ')
        .replaceAll('こんばんは', 'こんばんわ');

    if (cleanTarget == cleanInput) return true;

    double similarity = _calculateSimilarity(cleanTarget, cleanInput);
    return similarity >= 0.8;
  }

  double _calculateSimilarity(String s1, String s2) {
    if (s1.isEmpty && s2.isEmpty) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    List<List<int>> dp = List.generate(
      s1.length + 1,
      (i) => List.filled(s2.length + 1, 0),
    );
    for (int i = 0; i <= s1.length; i++) dp[i][0] = i;
    for (int j = 0; j <= s2.length; j++) dp[0][j] = j;

    for (int i = 1; i <= s1.length; i++) {
      for (int j = 1; j <= s2.length; j++) {
        int cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        dp[i][j] = [
          dp[i - 1][j] + 1,
          dp[i][j - 1] + 1,
          dp[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    int maxLength = s1.length > s2.length ? s1.length : s2.length;
    int distance = dp[s1.length][s2.length];
    return (maxLength - distance) / maxLength;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Nghe và nói lại câu sau",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Color(0xFF777777),
          ),
        ),
        const SizedBox(height: 40),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                SoundManager.instance.vibrate('light');
                SoundManager.instance.speakJapanese(widget.data['jp']);
              },
              child: Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: Color(0xFFEEF7E8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.volume_up,
                  color: Color(0xFF58CC02),
                  size: 45,
                ),
              ),
            ),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: () {
                SoundManager.instance.vibrate('light');
                SoundManager.instance.speakJapanese(
                  widget.data['jp'],
                  isSlow: true,
                );
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFEEF7E8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.pets,
                  color: Color(0xFF58CC02),
                  size: 28,
                ),
              ),
            ),
          ],
        ),

        const Spacer(),

        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Text(
                _recognizedText.isEmpty ? "..." : _recognizedText,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const Spacer(),

        GestureDetector(
          onTapDown: (_) => _startListening(),
          onTapUp: (_) => _stopListening(),
          onTapCancel: () => _stopListening(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _isListening ? 100 : 85,
            height: _isListening ? 100 : 85,
            decoration: BoxDecoration(
              color: _isListening
                  ? const Color(0xFFFF4B4B)
                  : const Color(0xFF78C850),
              shape: BoxShape.circle,
              boxShadow: _isListening
                  ? [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ]
                  : [],
            ),
            child: const Icon(Icons.mic, color: Colors.white, size: 45),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _isListening ? "Thả ra để dừng" : "Ấn giữ để nói",
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),

        TextButton(
          onPressed: () {
            SoundManager.instance.vibrate('light');
            widget.onSkip();
          },
          child: const Text(
            "Tôi không thể nói",
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: _hasSpoken ? _checkAnswer : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _hasSpoken
                  ? const Color(0xFF58CC02)
                  : Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: _hasSpoken ? 5 : 0,
            ),
            child: Text(
              "KIỂM TRA",
              style: TextStyle(
                color: _hasSpoken ? Colors.white : Colors.grey.shade500,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

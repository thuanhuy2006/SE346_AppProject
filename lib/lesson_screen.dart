import 'package:flutter/material.dart';
import 'sound_manager.dart';
import 'user_progress.dart';
import 'app_settings.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

enum LessonType { learn, quiz, matching, imageQuiz, sentenceBuilder, kanjiDraw, listening, flashCard, vocabQuiz, vocabSummary, speaking}

class LessonScreen extends StatefulWidget{
  final String lessonId;
  final String lessonTitle;
  static DateTime? audioDisabledUntil;
  const LessonScreen({super.key, required this.lessonId, required this.lessonTitle});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen>{
  int _currentIndex = 0;
  double _progress = 0;
  List<Map<String, dynamic>> _activities = [];

  int _correctAnswers = 0;
  int _totalQuizCount = 0;

  @override
  void initState() {
    super.initState();
    _loadLessonData();
    bool isAudioDisabled = LessonScreen.audioDisabledUntil != null &&
        DateTime.now().isBefore(LessonScreen.audioDisabledUntil!);
    if (isAudioDisabled && _activities.isNotEmpty && _activities[0]['type'] == LessonType.listening) {
      while (_currentIndex < _activities.length - 1 && _activities[_currentIndex]['type'] == LessonType.listening) {
        _currentIndex++;
      }
    }
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
    await Future.delayed(const Duration(milliseconds: 400)); // Chờ UI render xong
    if (!mounted || _activities.isEmpty) return;

    final activity = _activities[_currentIndex];
    final type = activity['type'] as LessonType;

    String textToRead = "";

    if (type == LessonType.learn) {
      textToRead = activity['char'];
    } else if (type == LessonType.sentenceBuilder) {
      textToRead = activity['jp'];
    } else if (type == LessonType.listening) {
      textToRead = activity['answer'];
    } else if (type == LessonType.flashCard) {
      textToRead = activity['hiragana'] ?? activity['kanji'];
    } else if (type == LessonType.vocabQuiz) {
      textToRead = activity['hiragana'] ?? activity['kanji'];
    } else if (type == LessonType.quiz) {
      textToRead = activity['answer'];
    } else if (type == LessonType.speaking) {
      textToRead = activity['jp'];
    }

    if (textToRead.isNotEmpty) {
      SoundManager.instance.speakJapanese(textToRead);
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
      case 'cb2_lythuyet': _activities = _getCb2LyThuyetData(); break;
      case 'cb2_luyentap1': _activities = _getCb2LuyenTap1Data(); break;
      case 'cb2_luyentap2': _activities = _getCb2LuyenTap2Data(); break;
      case 'cb2_luyentap3': _activities = _getCb2LuyenTap3Data(); break;
      case 'cb2_luyennoi': _activities = _getCb2LuyenNoiData(); break;
      case 'cb2_luyenviet': _activities = _getCb2LuyenVietData(); break;
      case 'cb2_ontap': _activities = _getCb2OnTapData(); break;
      case 'cb3_lythuyet': _activities = _getCb3LyThuyetData(); break;
      case 'cb3_luyentap1': _activities = _getCb3LuyenTap1Data(); break;
      case 'cb3_luyentap2': _activities = _getCb3LuyenTap2Data(); break;
      case 'cb3_luyentap3': _activities = _getCb3LuyenTap3Data(); break;
      case 'cb3_luyennoi': _activities = _getCb3LuyenNoiData(); break;
      case 'cb3_luyenviet': _activities = _getCb3LuyenVietData(); break;
      case 'cb3_ontap': _activities = _getCb3OnTapData(); break;
      case 'cb4_lythuyet': _activities = _getCb4LyThuyetData(); break;
      case 'cb4_luyentap1': _activities = _getCb4LuyenTap1Data(); break;
      case 'cb4_luyentap2': _activities = _getCb4LuyenTap2Data(); break;
      case 'cb4_luyentap3': _activities = _getCb4LuyenTap3Data(); break;
      case 'cb4_luyennoi': _activities = _getCb4LuyenNoiData(); break;
      case 'cb4_luyenviet': _activities = _getCb4LuyenVietData(); break;
      case 'cb4_ontap': _activities = _getCb4OnTapData(); break;
      case 'cb5_lythuyet': _activities = _getCb5LyThuyetData(); break;
      case 'cb5_luyentap1': _activities = _getCb5LuyenTap1Data(); break;
      case 'cb5_luyentap2': _activities = _getCb5LuyenTap2Data(); break;
      case 'cb5_luyentap3': _activities = _getCb5LuyenTap3Data(); break;
      case 'cb5_luyennoi': _activities = _getCb5LuyenNoiData(); break;
      case 'cb5_luyenviet': _activities = _getCb5LuyenVietData(); break;
      case 'cb5_ontap': _activities = _getCb5OnTapData(); break;
      case 'cb6_lythuyet': _activities = _getCb6LyThuyetData(); break;
      case 'cb6_luyentap1': _activities = _getCb6LuyenTap1Data(); break;
      case 'cb6_luyentap2': _activities = _getCb6LuyenTap2Data(); break;
      case 'cb6_luyentap3': _activities = _getCb6LuyenTap3Data(); break;
      case 'cb6_luyennoi': _activities = _getCb6LuyenNoiData(); break;
      case 'cb6_luyenviet': _activities = _getCb6LuyenVietData(); break;
      case 'cb6_ontap': _activities = _getCb6OnTapData(); break;
      case 'cb7_lythuyet': _activities = _getCb7LyThuyetData(); break;
      case 'cb7_luyentap1': _activities = _getCb7LuyenTap1Data(); break;
      case 'cb7_luyentap2': _activities = _getCb7LuyenTap2Data(); break;
      case 'cb7_luyentap3': _activities = _getCb7LuyenTap3Data(); break;
      case 'cb7_luyennoi': _activities = _getCb7LuyenNoiData(); break;
      case 'cb7_luyenviet': _activities = _getCb7LuyenVietData(); break;
      case 'cb7_ontap': _activities = _getCb7OnTapData(); break;
      case 'cb8_lythuyet': _activities = _getCb8LyThuyetData(); break;
      case 'cb8_luyentap1': _activities = _getCb8LuyenTap1Data(); break;
      case 'cb8_luyentap2': _activities = _getCb8LuyenTap2Data(); break;
      case 'cb8_luyentap3': _activities = _getCb8LuyenTap3Data(); break;
      case 'cb8_luyennoi': _activities = _getCb8LuyenNoiData(); break;
      case 'cb8_luyenviet': _activities = _getCb8LuyenVietData(); break;
      case 'cb8_ontap': _activities = _getCb8OnTapData(); break;
      case 'cb9_lythuyet': _activities = _getCb9LyThuyetData(); break;
      case 'cb9_luyentap1': _activities = _getCb9LuyenTap1Data(); break;
      case 'cb9_luyentap2': _activities = _getCb9LuyenTap2Data(); break;
      case 'cb9_luyentap3': _activities = _getCb9LuyenTap3Data(); break;
      case 'cb9_luyennoi': _activities = _getCb9LuyenNoiData(); break;
      case 'cb9_luyenviet': _activities = _getCb9LuyenVietData(); break;
      case 'cb9_ontap': _activities = _getCb9OnTapData(); break;
      case 'cb10_lythuyet': _activities = _getCb10LyThuyetData(); break;
      case 'cb10_luyentap1': _activities = _getCb10LuyenTap1Data(); break;
      case 'cb10_luyentap2': _activities = _getCb10LuyenTap2Data(); break;
      case 'cb10_luyentap3': _activities = _getCb10LuyenTap3Data(); break;
      case 'cb10_luyennoi': _activities = _getCb10LuyenNoiData(); break;
      case 'cb10_luyenviet': _activities = _getCb10LuyenVietData(); break;
      case 'cb10_ontap': _activities = _getCb10OnTapData(); break;
      default: _activities = [];
    }
  }

  // =======================================================
  // --- KHU VỰC DỮ LIỆU CÁC BÀI HỌC ---
  // =======================================================
  // ==========================================
  // LUYỆN TẬP 1 (Sử dụng 5 từ đầu của bài 1)
  // ==========================================
  List<Map<String, dynamic>> _getLuyenTap1Data(){
    return [
      {
        'type': LessonType.imageQuiz,
        'question': 'Xin chào.',
        'answerIndex': 1,
        'options': [
          {'img': 'assets/images/example_sayounara.png', 'jp': 'さようなら', 'rmj': 'sayounara'},
          {'img': 'assets/images/example_konnichiwa.png', 'jp': 'こんにちは', 'rmj': 'konnichiwa'},
          {'img': 'assets/images/example_musume.png', 'jp': 'むすめ', 'rmj': 'musume'},
          {'img': 'assets/images/example_musuko.png', 'jp': 'むすこ', 'rmj': 'musuko'},
        ]
      },
      {
        'type': LessonType.listening,
        'options': [
          {'kanji': '', 'hiragana': 'こんにちは'},
          {'kanji': '', 'hiragana': 'さようなら'},
          {'kanji': '娘', 'hiragana': 'むすめ'},
          {'kanji': '息子', 'hiragana': 'むすこ'},
        ],
        'answer': 'さようなら'
      },
      {
        'type': LessonType.imageQuiz,
        'question': 'Con gái.',
        'answerIndex': 2,
        'options': [
          {'img': 'assets/images/example_musuko.png', 'jp': 'むすこ', 'rmj': 'musuko'},
          {'img': 'assets/images/example_chichi.png', 'jp': 'おとうさん', 'rmj': 'otousan'},
          {'img': 'assets/images/example_musume.png', 'jp': 'むすめ', 'rmj': 'musume'},
          {'img': 'assets/images/example_haha.png', 'jp': 'おかあさん', 'rmj': 'okaasan'},
        ]
      },
      {
        'type': LessonType.listening,
        'options': [
          {'kanji': 'お父さん', 'hiragana': 'おとうさん'},
          {'kanji': 'お母さん', 'hiragana': 'おかあさん'},
          {'kanji': '息子', 'hiragana': 'むすこ'},
          {'kanji': '娘', 'hiragana': 'むすめ'},
        ],
        'answer': 'お父さん'
      },

      // 5. CÂU HỎI GHÉP CHỮ (Giống Hình 3)
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'こんにちは、お父さん',
        'rmj': 'konnichiwa, otousan',
        'words': ['xin chào', 'bố', 'tạm biệt', 'con gái', 'mẹ'],
        'answer': 'xin chào bố',
      },

      {
        'type': LessonType.speaking,
        'jp': 'こんにちは',
        'answer': 'こんにちは',
      },
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '娘',
        'kanji_target': '娘',
        'meaning': 'Con gái',
        'rmj': 'musume'
      },
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '父 / お父さん',
        'kanji_target': '父',
        'meaning': 'Bố',
        'rmj': 'chichi / otousan'
      },
    ];
  }

  // ==========================================
  // DỮ LIỆU PHẦN CƠ BẢN 1 (BÀI 1: GIỚI THIỆU BẢN THÂN)
  // ==========================================

  // 1. Lý thuyết (Từ vựng cơ bản)
  List<Map<String, dynamic>> _getCb1LyThuyetData(){
    return [
      // --- NHÓM 1: CHÀO HỎI (4 TỪ) ---
      {
        'type': LessonType.flashCard, 'kanji': '', 'hiragana': 'こんにちは', 'romaji': 'konnichiwa', 'meaning': 'Xin chào',
        'example_img': 'assets/images/example_konnichiwa.png',
        'example_jp': 'こんにちは、元気ですか。', 'example_rmj': 'Konnichiwa, genki desu ka.', 'example_vn': 'Xin chào, bạn có khỏe không?'
      },
      {
        'type': LessonType.flashCard, 'kanji': '', 'hiragana': 'さようなら', 'romaji': 'sayounara', 'meaning': 'Tạm biệt',
        'example_img': 'assets/images/example_sayounara.png',
        'example_jp': '先生、さようなら。', 'example_rmj': 'Sensei, sayounara.', 'example_vn': 'Em chào thầy, em về ạ.'
      },
      {
        'type': LessonType.flashCard, 'kanji': '娘', 'hiragana': 'むすめ', 'romaji': 'musume', 'meaning': 'Con gái (của mình)',
        'example_img': 'assets/images/example_musume.png',
        'example_jp': '私の娘は５歳です。', 'example_rmj': 'Watashi no musume wa gosai desu.', 'example_vn': 'Con gái tôi 5 tuổi.'
      },
      {
        'type': LessonType.flashCard, 'kanji': '息子', 'hiragana': 'むすこ', 'romaji': 'musuko', 'meaning': 'Con trai (của mình)',
        'example_img': 'assets/images/example_musuko.png',
        'example_jp': '息子は学生です。', 'example_rmj': 'Musuko wa gakusei desu.', 'example_vn': 'Con trai tôi là học sinh.'
      },

      // --- QUIZ NHÓM 1 ---
      {'type': LessonType.vocabQuiz, 'kanji': '', 'hiragana': 'こんにちは', 'romaji': 'konnichiwa', 'options': ['tạm biệt', 'xin chào', 'cảm ơn', 'xin lỗi'], 'answer': 'xin chào'},
      {'type': LessonType.vocabQuiz, 'kanji': '娘', 'hiragana': 'むすめ', 'romaji': 'musume', 'options': ['con trai', 'vợ', 'chồng', 'con gái'], 'answer': 'con gái'},
      {'type': LessonType.listening, 'options': ['こんにちは', 'さようなら', 'むすめ', 'むすこ'], 'answer': 'さようなら'},

      // --- NHÓM 2: GIA ĐÌNH & ĐẠI TỪ (4 TỪ) ---
      {
        'type': LessonType.flashCard, 'kanji': '父 / お父さん', 'hiragana': 'ちち / おとうさん', 'romaji': 'chichi / otousan', 'meaning': 'Bố',
        'example_img': 'assets/images/example_chichi.png',
        'example_jp': 'お父さんは会社員です。', 'example_rmj': 'Otousan wa kaishain desu.', 'example_vn': 'Bố tôi là nhân viên công ty.'
      },
      {
        'type': LessonType.flashCard, 'kanji': '母 / お母さん', 'hiragana': 'はは / おかあさん', 'romaji': 'haha / okasan', 'meaning': 'Mẹ',
        'example_img': 'assets/images/example_haha.png',
        'example_jp': '母は料理が上手です。', 'example_rmj': 'Haha wa ryouri ga jouzu desu.', 'example_vn': 'Mẹ tôi nấu ăn giỏi.'
      },
      {
        'type': LessonType.flashCard, 'kanji': '彼', 'hiragana': 'かれ', 'romaji': 'kare', 'meaning': 'Anh ấy / Bạn trai',
        'example_img': 'assets/images/example_kare.png',
        'example_jp': '彼は私の友達です。', 'example_rmj': 'Kare wa watashi no tomodachi desu.', 'example_vn': 'Anh ấy là bạn của tôi.'
      },
      {
        'type': LessonType.flashCard, 'kanji': '彼女', 'hiragana': 'かのじょ', 'romaji': 'kanojo', 'meaning': 'Cô ấy / Bạn gái',
        'example_img': 'assets/images/example_kanojo.png',
        'example_jp': '彼女はとてもきれいです。', 'example_rmj': 'Kanojo wa totemo kirei desu.', 'example_vn': 'Cô ấy rất đẹp.'
      },

      // --- QUIZ NHÓM 2 ---
      {'type': LessonType.vocabQuiz, 'kanji': '母', 'hiragana': 'はは', 'romaji': 'haha', 'options': ['bố', 'mẹ', 'anh trai', 'chị gái'], 'answer': 'mẹ'},
      {'type': LessonType.vocabQuiz, 'kanji': '彼', 'hiragana': 'かれ', 'romaji': 'kare', 'options': ['cô ấy', 'tôi', 'bạn', 'anh ấy'], 'answer': 'anh ấy'},
      {'type': LessonType.listening, 'options': ['ちち', 'はは', 'かれ', 'かのじょ'], 'answer': 'かのじょ'},

      // --- NHÓM 3: ĐẠI TỪ CƠ BẢN (2 TỪ CUỐI) ---
      {
        'type': LessonType.flashCard, 'kanji': '私', 'hiragana': 'わたし', 'romaji': 'watashi', 'meaning': 'Tôi',
        'example_img': 'assets/images/example_watashi.png',
        'example_jp': '私は学生です。', 'example_rmj': 'Watashi wa gakusei desu.', 'example_vn': 'Tôi là học sinh.'
      },
      {
        'type': LessonType.flashCard, 'kanji': '', 'hiragana': 'あなた', 'romaji': 'anata', 'meaning': 'Bạn / Anh / Chị',
        'example_img': 'assets/images/example_anata.png',
        'example_jp': 'あなたは会社員ですか。', 'example_rmj': 'Anata wa kaishain desu ka.', 'example_vn': 'Bạn có phải là nhân viên công ty không?'
      },

      // --- TỔNG KẾT BÀI HỌC ---
      {
        'type': LessonType.vocabSummary,
        'words': [
          {'kanji': 'こんにちは', 'romaji': 'konnichiwa', 'meaning': 'Xin chào'},
          {'kanji': 'さようなら', 'romaji': 'sayounara', 'meaning': 'Tạm biệt'},
          {'kanji': '娘', 'romaji': 'musume', 'meaning': 'Con gái'},
          {'kanji': '息子', 'romaji': 'musuko', 'meaning': 'Con trai'},
          {'kanji': '父', 'romaji': 'chichi', 'meaning': 'Bố'},
          {'kanji': '母', 'romaji': 'haha', 'meaning': 'Mẹ'},
          {'kanji': '彼', 'romaji': 'kare', 'meaning': 'Anh ấy'},
          {'kanji': '彼女', 'romaji': 'kanojo', 'meaning': 'Cô ấy'},
          {'kanji': '私', 'romaji': 'watashi', 'meaning': 'Tôi'},
          {'kanji': 'あなた', 'romaji': 'anata', 'meaning': 'Bạn'},
        ]
      }
    ];
  }

  // 3. Luyện tập 2
  List<Map<String, dynamic>> _getCb1LuyenTap2Data() {
    return [
      {
        'type': LessonType.imageQuiz,
        'question': 'Mẹ (của mình).',
        'answerIndex': 0,
        'options': [
          {'img': 'assets/images/example_haha.png', 'jp': 'はは', 'rmj': 'haha'},
          {'img': 'assets/images/example_chichi.png', 'jp': 'ちち', 'rmj': 'chichi'},
          {'img': 'assets/images/example_kare.png', 'jp': 'かれ', 'rmj': 'kare'},
          {'img': 'assets/images/example_kanojo.png', 'jp': 'かのじょ', 'rmj': 'kanojo'},
        ]
      },

      // 2. CÂU HỎI HÌNH ẢNH (Focus: Anh ấy)
      {
        'type': LessonType.imageQuiz,
        'question': 'Anh ấy.',
        'answerIndex': 2,
        'options': [
          {'img': 'assets/images/example_anata.png', 'jp': 'あなた', 'rmj': 'anata'},
          {'img': 'assets/images/example_watashi.png', 'jp': 'わたし', 'rmj': 'watashi'},
          {'img': 'assets/images/example_kare.png', 'jp': 'かれ', 'rmj': 'kare'},
          {'img': 'assets/images/example_kanojo.png', 'jp': 'かのじょ', 'rmj': 'kanojo'},
        ]
      },

      // 3. CÂU HỎI NGHE (Focus: Mẹ - Dùng dạng lịch sự)
      {
        'type': LessonType.listening,
        'options': ['お母さん', 'お父さん', '娘', '息子'],
        'answer': 'お母さん'
      },

      // 4. CÂU HỎI NGHE (Focus: Anh ấy)
      {
        'type': LessonType.listening,
        'options': ['かれ', 'かのじょ', 'わたし', 'あなた'],
        'answer': 'かれ'
      },

      // 5. CÂU HỎI GHÉP CHỮ (Sử dụng "Cô ấy")
      {
        'type': LessonType.sentenceBuilder,
        'jp': '彼女は私の母です',
        'rmj': 'kanojo wa watashi no haha desu',
        'words': ['cô ấy', 'là', 'mẹ', 'của tôi', 'anh ấy'],
        'answer': 'cô ấy là mẹ của tôi',
      },

      // 6. CÂU HỎI LUYỆN NÓI (Sử dụng "Tôi")
      {
        'type': LessonType.speaking,
        'jp': 'わたし',
        'answer': 'わたし',
      },

      // 7. CÂU HỎI VẼ KANJI - Từ "Mẹ" (母)
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '母',
        'kanji_target': '母',
        'meaning': 'Mẹ',
        'rmj': 'haha / okaasan'
      },

      // 8. CÂU HỎI VẼ KANJI - Từ "Tôi" (私)
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '私',
        'kanji_target': '私',
        'meaning': 'Tôi',
        'rmj': 'watashi'
      },
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
  // ==========================================
  // DỮ LIỆU PHẦN CƠ BẢN 2 (BÀI 2: ĐỒ VẬT VÀ SỞ HỮU)
  // ==========================================

  // 1. Lý thuyết (Đại từ chỉ thị & Sách vở) - 12 bài
  List<Map<String, dynamic>> _getCb2LyThuyetData() {
    return [
      {
        'type': LessonType.flashCard, 'kanji': 'これ', 'hiragana': 'これ', 'romaji': 'kore', 'meaning': 'Cái này (gần người nói)',
        'example_img': 'assets/images/example_kore.png',
        'example_jp': 'これは本です。', 'example_rmj': 'Kore wa hon desu.', 'example_vn': 'Cái này là quyển sách.'
      },
      {
        'type': LessonType.flashCard, 'kanji': 'それ', 'hiragana': 'それ', 'romaji': 'sore', 'meaning': 'Cái đó (gần người nghe)',
        'example_img': 'assets/images/example_sore.png',
        'example_jp': 'それは辞書ですか。', 'example_rmj': 'Sore wa jisho desu ka.', 'example_vn': 'Cái đó có phải là từ điển không?'
      },
      {
        'type': LessonType.flashCard, 'kanji': 'あれ', 'hiragana': 'あれ', 'romaji': 'are', 'meaning': 'Cái kia (xa cả hai)',
        'example_img': 'assets/images/example_are.png',
        'example_jp': 'あれは私の車です。', 'example_rmj': 'Are wa watashi no kuruma desu.', 'example_vn': 'Cái kia là xe hơi của tôi.'
      },
      {'type': LessonType.vocabQuiz, 'kanji': 'これ', 'hiragana': 'これ', 'romaji': 'kore', 'options': ['cái kia', 'cái đó', 'cái này', 'ở đâu'], 'answer': 'cái này'},
      {
        'type': LessonType.flashCard, 'kanji': '本', 'hiragana': 'ほん', 'romaji': 'hon', 'meaning': 'Quyển sách',
        'example_img': 'assets/images/example_hon.png',
        'example_jp': 'これは日本語の本です。', 'example_rmj': 'Kore wa nihongo no hon desu.', 'example_vn': 'Đây là sách tiếng Nhật.'
      },
      {
        'type': LessonType.flashCard, 'kanji': '辞書', 'hiragana': 'じしょ', 'romaji': 'jisho', 'meaning': 'Từ điển',
        'example_img': 'assets/images/example_jisho.png',
        'example_jp': 'これは英語の辞書です。', 'example_rmj': 'Kore wa eigo no jisho desu.', 'example_vn': 'Đây là từ điển tiếng Anh.'
      },
      {
        'type': LessonType.flashCard, 'kanji': '雑誌', 'hiragana': 'ざっし', 'romaji': 'zasshi', 'meaning': 'Tạp chí',
        'example_img': 'assets/images/example_zasshi.png',
        'example_jp': 'それはカメラの雑誌です。', 'example_rmj': 'Sore wa kamera no zasshi desu.', 'example_vn': 'Đó là tạp chí máy ảnh.'
      },
      {'type': LessonType.listening, 'options': ['これ', 'それ', 'あれ', 'どれ'], 'answer': 'それ'},
      {'type': LessonType.vocabQuiz, 'kanji': '辞書', 'hiragana': 'じしょ', 'romaji': 'jisho', 'options': ['tạp chí', 'từ điển', 'sách', 'báo'], 'answer': 'từ điển'},
      {'type': LessonType.vocabQuiz, 'kanji': '雑誌', 'hiragana': 'ざっし', 'romaji': 'zasshi', 'options': ['tạp chí', 'sổ tay', 'từ điển', 'chìa khóa'], 'answer': 'tạp chí'},
      {'type': LessonType.matching, 'pairs': [{'left': 'Cái này', 'right': 'これ'}, {'left': 'Cái đó', 'right': 'それ'}, {'left': 'Cái kia', 'right': 'あれ'}, {'left': 'Sách', 'right': '本'}]},
      {
        'type': LessonType.vocabSummary,
        'words': [
          {'kanji': 'これ', 'romaji': 'kore', 'meaning': 'Cái này'},
          {'kanji': 'それ', 'romaji': 'sore', 'meaning': 'Cái đó'},
          {'kanji': 'あれ', 'romaji': 'are', 'meaning': 'Cái kia'},
          {'kanji': '本', 'romaji': 'hon', 'meaning': 'Quyển sách'},
          {'kanji': '辞書', 'romaji': 'jisho', 'meaning': 'Từ điển'},
          {'kanji': '雑誌', 'romaji': 'zasshi', 'meaning': 'Tạp chí'},
        ]
      }
    ];
  }

  // 2. Luyện tập 1 (Từ vựng: Đồ vật cá nhân) - 10 bài
  List<Map<String, dynamic>> _getCb2LuyenTap1Data() {
    return [
      {
        'type': LessonType.flashCard, 'kanji': '鞄', 'hiragana': 'かばん', 'romaji': 'kaban', 'meaning': 'Cặp xách, túi xách',
        'example_img': 'assets/images/example_kaban.png',
        'example_jp': 'これは私の鞄です。', 'example_rmj': 'Kore wa watashi no kaban desu.', 'example_vn': 'Đây là cái cặp của tôi.'
      },
      {
        'type': LessonType.flashCard, 'kanji': '傘', 'hiragana': 'かさ', 'romaji': 'kasa', 'meaning': 'Cây dù, ô',
        'example_img': 'assets/images/example_kasa.png',
        'example_jp': 'あれは誰の傘ですか。', 'example_rmj': 'Are wa dare no kasa desu ka.', 'example_vn': 'Kia là cây dù của ai vậy?'
      },
      {
        'type': LessonType.flashCard, 'kanji': '鍵', 'hiragana': 'かぎ', 'romaji': 'kagi', 'meaning': 'Chìa khóa',
        'example_img': 'assets/images/example_kagi.png',
        'example_jp': 'それは車の鍵です。', 'example_rmj': 'Sore wa kuruma no kagi desu.', 'example_vn': 'Đó là chìa khóa xe hơi.'
      },
      {
        'type': LessonType.flashCard, 'kanji': '時計', 'hiragana': 'とけい', 'romaji': 'tokei', 'meaning': 'Đồng hồ',
        'example_img': 'assets/images/example_tokei.png',
        'example_jp': 'これは時計です。', 'example_rmj': 'Kore wa tokei desu.', 'example_vn': 'Đây là cái đồng hồ.'
      },
      {'type': LessonType.vocabQuiz, 'kanji': '鞄', 'hiragana': 'かばん', 'romaji': 'kaban', 'options': ['đồng hồ', 'chìa khóa', 'cặp xách', 'cây dù'], 'answer': 'cặp xách'},
      {'type': LessonType.vocabQuiz, 'kanji': '時計', 'hiragana': 'とけい', 'romaji': 'tokei', 'options': ['đồng hồ', 'chìa khóa', 'máy ảnh', 'sổ tay'], 'answer': 'đồng hồ'},
      {'type': LessonType.listening, 'options': ['かぎ', 'かばん', 'かさ', 'とけい'], 'answer': 'かぎ'},
      {'type': LessonType.quiz, 'question': 'Từ nào được viết bằng Katakana?', 'options': ['かばん (kaban)', 'カメラ (kamera)', 'とけい (tokei)', 'かさ (kasa)'], 'answer': 'カメラ (kamera)'},
      {'type': LessonType.matching, 'pairs': [
        {'left': 'Máy ảnh', 'right': 'カメラ'},
        {'left': 'Ti vi', 'right': 'テレビ'},
        {'left': 'Máy tính', 'right': 'コンピューター'},
        {'left': 'Sổ tay', 'right': 'ノート'}
      ]},
      {'type': LessonType.matching, 'pairs': [
        {'left': 'Cặp xách', 'right': '鞄'},
        {'left': 'Đồng hồ', 'right': '時計'},
        {'left': 'Chìa khóa', 'right': '鍵'},
        {'left': 'Cây dù', 'right': '傘'}
      ]},
    ];
  }

  // 3. Luyện tập 2 (Ngữ pháp: Kore wa ~ desu / Sore wa ~ desu ka) - 10 bài
  List<Map<String, dynamic>> _getCb2LuyenTap2Data() {
    return [
      {
        'type': LessonType.flashCard,
        'kanji': 'これ／それ／あれ',
        'hiragana': 'これ/それ/あれ',
        'romaji': 'kore/sore/are',
        'meaning': 'Cái này / Cái đó / Cái kia',
        'example_img': 'assets/images/example_kore.png',
        'example_jp': 'これは辞書ですか。',
        'example_rmj': 'Kore wa jisho desu ka.',
        'example_vn': 'Cái này có phải là từ điển không?',
      },
      {
        'type': LessonType.flashCard,
        'kanji': 'Nは Nじゃありません',
        'hiragana': 'Nは Nじゃありません',
        'romaji': 'N wa N ja arimasen',
        'meaning': '[N1] không phải là [N2]',
        'example_img': 'assets/images/example_kore.png',
        'example_jp': 'これはカメラじゃありません。',
        'example_rmj': 'Kore wa kamera ja arimasen.',
        'example_vn': 'Cái này không phải là máy ảnh.',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'これは辞書です',
        'rmj': 'kore wa jisho desu',
        'words': ['cái này', 'là', 'từ điển', 'quyển sách', 'không phải'],
        'answer': 'cái này là từ điển',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'それは傘ですか',
        'rmj': 'sore wa kasa desu ka',
        'words': ['cái đó', 'có phải', 'là', 'cây dù', 'không'],
        'answer': 'cái đó có phải là cây dù không',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'あれは私の鞄です',
        'rmj': 'are wa watashi no kaban desu',
        'words': ['cái kia', 'là', 'cặp xách', 'của tôi', 'của bạn'],
        'answer': 'cái kia là cặp xách của tôi',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'これはカメラじゃありません',
        'rmj': 'kore wa kamera ja arimasen',
        'words': ['cái này', 'không phải', 'là', 'máy ảnh', 'ti vi'],
        'answer': 'cái này không phải là máy ảnh',
      },
      {'type': LessonType.quiz, 'question': 'Câu hỏi "Cái này là cái gì?" nói thế nào?', 'options': ['これはだれですか', 'これはなんですか', 'それはなんですか', 'あれはなんですか'], 'answer': 'これはなんですか'},
      {'type': LessonType.quiz, 'question': 'Điền từ: ( ... ) は時計です。 (Vật ở xa cả 2 người)', 'options': ['これ', 'それ', 'あれ', 'どれ'], 'answer': 'あれ'},
      {'type': LessonType.listening, 'options': ['これはかばんです', 'それはかばんです', 'あれはかばんです', 'これはかばんですか'], 'answer': 'それはかばんです'},
      {'type': LessonType.listening, 'options': ['これはなんですか', 'それはなんですか', 'あれはなんですか', 'だれですか'], 'answer': 'これはなんですか'},
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'それは何ですか',
        'rmj': 'sore wa nan desu ka',
        'words': ['cái đó', 'là', 'cái gì', 'vậy', 'của ai'],
        'answer': 'cái đó là cái gì vậy',
      },
      {'type': LessonType.matching, 'pairs': [{'left': 'Cái này là...', 'right': 'これは...'}, {'left': 'Cái đó là...', 'right': 'それは...'}, {'left': 'Cái kia là...', 'right': 'あれは...'}, {'left': 'Cái gì?', 'right': 'なんですか'}]},
    ];
  }

  // 4. Luyện tập 3 (Ngữ pháp: Kono N wa / Sở hữu "Của ai") - 10 bài
  List<Map<String, dynamic>> _getCb2LuyenTap3Data() {
    return [
      {
        'type': LessonType.flashCard, 'kanji': 'この', 'hiragana': 'この', 'romaji': 'kono', 'meaning': '... này (Kèm theo Danh từ)',
        'example_img': 'assets/images/example_kono.png',
        'example_jp': 'この本は私のです。', 'example_rmj': 'Kono hon wa watashi no desu.', 'example_vn': 'Quyển sách này là của tôi.'
      },
      {
        'type': LessonType.flashCard, 'kanji': '誰の', 'hiragana': 'だれの', 'romaji': 'dare no', 'meaning': 'Của ai',
        'example_img': 'assets/images/example_dareno.png',
        'example_jp': 'それは誰の鞄ですか。', 'example_rmj': 'Sore wa dare no kaban desu ka.', 'example_vn': 'Đó là cặp xách của ai vậy?'
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'この本は私のです',
        'rmj': 'kono hon wa watashi no desu',
        'words': ['quyển sách', 'này', 'là', 'của tôi', 'của bạn'],
        'answer': 'quyển sách này là của tôi',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'その鍵は誰のですか',
        'rmj': 'sono kagi wa dare no desu ka',
        'words': ['chìa khóa', 'đó', 'là', 'của ai', 'vậy'],
        'answer': 'chìa khóa đó là của ai vậy',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'あの車は先生のじゃありません',
        'rmj': 'ano kuruma wa sensei no ja arimasen',
        'words': ['xe hơi', 'kia', 'không phải', 'của giáo viên', 'của tôi'],
        'answer': 'xe hơi kia không phải của giáo viên',
      },
      {'type': LessonType.quiz, 'question': 'Cách dùng nào ĐÚNG?', 'options': ['これ本は... (Kore hon wa...)', 'この本は... (Kono hon wa...)', 'このは本です (Kono wa hon desu)', 'それ本は... (Sore hon wa...)'], 'answer': 'この本は... (Kono hon wa...)'},
      {'type': LessonType.listening, 'options': ['だれ', 'どなた', 'だれの', 'なん'], 'answer': 'だれの'},
      {'type': LessonType.quiz, 'question': 'Dịch sang tiếng Nhật: "Quyển tạp chí đó là của anh Yamada."', 'options': ['その雑誌は山田さんのです', 'それは雑誌の山田さんです', 'あの雑誌は山田さんのです', '山田さんの雑誌はそれです'], 'answer': 'その雑誌は山田さんのです'},
      {'type': LessonType.matching, 'pairs': [{'left': 'Sách này', 'right': 'このほん'}, {'left': 'Sách đó', 'right': 'そのほん'}, {'left': 'Sách kia', 'right': 'あのほん'}, {'left': 'Của tôi', 'right': 'わたしの'}, {'left': 'Của ai', 'right': 'だれの'}]},
      {'type': LessonType.vocabQuiz, 'kanji': '誰の', 'hiragana': 'だれの', 'romaji': 'dare no', 'options': ['cái gì', 'của ai', 'ai', 'ở đâu'], 'answer': 'của ai'},
    ];
  }

  // 5. Luyện nói (Giao tiếp: Phủ định, Xác nhận, Tặng quà) - 10 bài
  List<Map<String, dynamic>> _getCb2LuyenNoiData() {
    return [
      {
        'type': LessonType.flashCard, 'kanji': '違います', 'hiragana': 'ちがいます', 'romaji': 'chigaimasu', 'meaning': 'Không phải / Sai rồi',
        'example_img': 'assets/images/example_chigaimasu.png',
        'example_jp': 'いいえ、違います。', 'example_rmj': 'Iie, chigaimasu.', 'example_vn': 'Không, nhầm rồi (không phải vậy).'
      },
      {
        'type': LessonType.flashCard, 'kanji': 'そうですか', 'hiragana': 'そうですか', 'romaji': 'sou desu ka', 'meaning': 'Thế à / Vậy à (Hiểu ra vấn đề)',
        'example_img': 'assets/images/example_soudesuka.png',
        'example_jp': 'あ、そうですか。', 'example_rmj': 'A, sou desu ka.', 'example_vn': 'À, ra là vậy.'
      },
      {
        'type': LessonType.flashCard, 'kanji': 'どうぞ', 'hiragana': 'どうぞ', 'romaji': 'douzo', 'meaning': 'Xin mời',
        'example_img': 'assets/images/example_douzo.png',
        'example_jp': 'これ、どうぞ。', 'example_rmj': 'Kore, douzo.', 'example_vn': 'Cái này, xin mời bạn.'
      },
      {'type': LessonType.vocabQuiz, 'kanji': '違います', 'hiragana': 'ちがいます', 'romaji': 'chigaimasu', 'options': ['đúng rồi', 'xin mời', 'sai rồi / không phải', 'vậy à'], 'answer': 'sai rồi / không phải'},
      {'type': LessonType.listening, 'options': ['そうですか', 'ちがいます', 'どうぞ', 'ありがとう'], 'answer': 'そうですか'},
      {'type': LessonType.listening, 'options': ['いいえ、ちがいます', 'はい、そうです', 'これ、どうぞ', 'どうも'], 'answer': 'いいえ、ちがいます'},
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'いいえ、違います',
        'rmj': 'iie, chigaimasu',
        'words': ['không', 'sai rồi', 'vâng', 'đúng vậy', 'xin mời'],
        'answer': 'không sai rồi',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'どうもありがとうございます',
        'rmj': 'doumo arigatou gozaimasu',
        'words': ['xin', 'chân thành', 'cảm ơn', 'bạn', 'rất nhiều'],
        'answer': 'xin chân thành cảm ơn',
      },
      {'type': LessonType.quiz, 'question': 'Khi đưa quà cho ai đó, bạn sẽ nói gì?', 'options': ['ありがとう', 'どうぞ', 'ちがいます', 'そうですか'], 'answer': 'どうぞ'},
      {'type': LessonType.matching, 'pairs': [{'left': 'Vâng, đúng vậy', 'right': 'はい、そうです'}, {'left': 'Không, sai rồi', 'right': 'いいえ、ちがいます'}, {'left': 'Thế à', 'right': 'そうですか'}, {'left': 'Xin mời', 'right': 'どうぞ'}]},
    ];
  }

  // 6. Luyện viết (Kanji cơ bản bài 2) - 8 bài
  List<Map<String, dynamic>> _getCb2LuyenVietData() {
    return [
      {'type': LessonType.kanjiDraw, 'kanji_word': '何', 'kanji_target': '何', 'meaning': 'Hà (Cái gì)', 'rmj': 'nani / nan'},
      {'type': LessonType.kanjiDraw, 'kanji_word': '車', 'kanji_target': '車', 'meaning': 'Xa (Xe hơi)', 'rmj': 'kuruma'},
      {'type': LessonType.kanjiDraw, 'kanji_word': '語', 'kanji_target': '語', 'meaning': 'Ngữ (Ngôn ngữ)', 'rmj': 'go'},
      {'type': LessonType.kanjiDraw, 'kanji_word': '書', 'kanji_target': '書', 'meaning': 'Thư (Viết, sách)', 'rmj': 'sho / ka(ku)'},
      {'type': LessonType.quiz, 'question': 'Kanji "何" có nghĩa là gì?', 'options': ['Ai', 'Cái gì', 'Ở đâu', 'Khi nào'], 'answer': 'Cái gì'},
      {'type': LessonType.quiz, 'question': 'Kanji "車" đọc là gì?', 'options': ['hon', 'hito', 'kuruma', 'nani'], 'answer': 'kuruma'},
      {'type': LessonType.matching, 'pairs': [
        {'left': 'Hà (Cái gì)', 'right': '何'},
        {'left': 'Xa (Xe hơi)', 'right': '車'},
        {'left': 'Ngữ (Tiếng)', 'right': '語'},
        {'left': 'Thư (Sách)', 'right': '書'},
      ]},
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'これは日本語の本です',
        'rmj': 'kore wa nihongo no hon desu',
        'words': ['đây', 'là', 'sách', 'tiếng Nhật', 'từ điển'],
        'answer': 'đây là sách tiếng Nhật',
      },
    ];
  }

  // 7. Ôn tập (Boss Level Bài 2) - 15 bài
  List<Map<String, dynamic>> _getCb2OnTapData() {
    return [
      {'type': LessonType.listening, 'options': ['これ', 'それ', 'あれ', 'どれ'], 'answer': 'あれ'},
      {'type': LessonType.listening, 'options': ['かばん', 'かぎ', 'とけい', 'かさ'], 'answer': 'かさ'},
      {'type': LessonType.quiz, 'question': 'Dịch: "Cái này là máy ảnh."', 'options': ['それはカメラです', 'これはカメラです', 'あれはカメラです', 'このカメラはわたしのです'], 'answer': 'これはカメラです'},
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'その鍵は誰のですか',
        'rmj': 'sono kagi wa dare no desu ka',
        'words': ['chìa khóa', 'đó', 'là', 'của ai', 'vậy'],
        'answer': 'chìa khóa đó là của ai vậy',
      },
      {'type': LessonType.vocabQuiz, 'kanji': '辞書', 'hiragana': 'じしょ', 'romaji': 'jisho', 'options': ['tạp chí', 'sách', 'từ điển', 'chìa khóa'], 'answer': 'từ điển'},
      {'type': LessonType.kanjiDraw, 'kanji_word': '何', 'kanji_target': '何', 'meaning': 'Hà (Cái gì)', 'rmj': 'nan'},
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'あれは私の鞄じゃありません',
        'rmj': 'are wa watashi no kaban ja arimasen',
        'words': ['cái kia', 'không phải', 'cặp xách', 'của tôi', 'của bạn'],
        'answer': 'cái kia không phải cặp xách của tôi',
      },
      {'type': LessonType.listening, 'options': ['ちがいます', 'そうですか', 'どうぞ', 'ありがとう'], 'answer': 'ちがいます'},
      {'type': LessonType.quiz, 'question': 'Từ nào sai ngữ pháp?', 'options': ['この本', 'その傘', 'あの時計', 'これ鍵'], 'answer': 'これ鍵'}, // Cố tình hỏi câu tư duy
      {'type': LessonType.matching, 'pairs': [
        {'left': 'Từ điển', 'right': '辞書'},
        {'left': 'Tạp chí', 'right': '雑誌'},
        {'left': 'Đồng hồ', 'right': '時計'},
        {'left': 'Chìa khóa', 'right': '鍵'},
        {'left': 'Cây dù', 'right': '傘'}
      ]},
      {'type': LessonType.matching, 'pairs': [
        {'left': 'Cái này là', 'right': 'これは'},
        {'left': 'Sách này là', 'right': 'この本は'},
        {'left': 'Của tôi', 'right': '私の'},
        {'left': 'Của ai', 'right': '誰の'},
        {'left': 'Cái gì', 'right': '何'}
      ]},
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'これ、どうぞ',
        'rmj': 'kore, douzo',
        'words': ['cái này', 'xin', 'mời', 'bạn', 'cảm ơn'],
        'answer': 'cái này xin mời bạn',
      },
      {'type': LessonType.vocabQuiz, 'kanji': '車', 'hiragana': 'くるま', 'romaji': 'kuruma', 'options': ['xe đạp', 'xe hơi', 'máy bay', 'tàu hỏa'], 'answer': 'xe hơi'},
      // Thẻ tổng kết toàn bộ từ vựng Bài 2
      {
        'type': LessonType.vocabSummary,
        'words': [
          {'kanji': 'これ/それ/あれ', 'romaji': 'kore/sore/are', 'meaning': 'cái này/cái đó/cái kia'},
          {'kanji': 'この/その/あの', 'romaji': 'kono/sono/ano', 'meaning': '...này/đó/kia'},
          {'kanji': '本', 'romaji': 'hon', 'meaning': 'sách'},
          {'kanji': '辞書', 'romaji': 'jisho', 'meaning': 'từ điển'},
          {'kanji': '雑誌', 'romaji': 'zasshi', 'meaning': 'tạp chí'},
          {'kanji': '鞄', 'romaji': 'kaban', 'meaning': 'cặp xách'},
          {'kanji': '傘', 'romaji': 'kasa', 'meaning': 'cây dù'},
          {'kanji': '鍵', 'romaji': 'kagi', 'meaning': 'chìa khóa'},
          {'kanji': '時計', 'romaji': 'tokei', 'meaning': 'đồng hồ'},
          {'kanji': '車', 'romaji': 'kuruma', 'meaning': 'xe hơi'},
          {'kanji': '何', 'romaji': 'nani/nan', 'meaning': 'cái gì'},
          {'kanji': '誰の', 'romaji': 'dare no', 'meaning': 'của ai'},
          {'kanji': '違います', 'romaji': 'chigaimasu', 'meaning': 'sai rồi, không phải'},
          {'kanji': 'どうぞ', 'romaji': 'douzo', 'meaning': 'xin mời'},
        ]
      }
    ];
  }

  // ==========================================
  // DỮ LIỆU PHẦN CƠ BẢN 3 (ĐỊA ĐIỂM & GIÁ TIỀN)
  // ==========================================

  List<Map<String, dynamic>> _getCb3LyThuyetData() {
    return [
      {
        'type': LessonType.flashCard, 'kanji': 'ここ', 'hiragana': 'ここ', 'romaji': 'koko', 'meaning': 'Chỗ này, đây',
        'example_img': 'assets/images/example_koko.png',
        'example_jp': 'ここは教室です。', 'example_rmj': 'Koko wa kyoushitsu desu.', 'example_vn': 'Chỗ này là phòng học.'
      },
      {
        'type': LessonType.flashCard, 'kanji': 'そこ', 'hiragana': 'そこ', 'romaji': 'soko', 'meaning': 'Chỗ đó, đó',
        'example_img': 'assets/images/example_soko.png',
        'example_jp': 'そこはトイレですか。', 'example_rmj': 'Soko wa toire desu ka.', 'example_vn': 'Chỗ đó có phải là nhà vệ sinh không?'
      },
      {
        'type': LessonType.flashCard, 'kanji': 'あそこ', 'hiragana': 'あそこ', 'romaji': 'asoko', 'meaning': 'Chỗ kia, kia',
        'example_img': 'assets/images/example_asoko.png',
        'example_jp': '事務所はあそこです。', 'example_rmj': 'Jimusho wa asoko desu.', 'example_vn': 'Văn phòng ở đằng kia.'
      },
      {'type': LessonType.vocabQuiz, 'kanji': 'どこ', 'hiragana': 'どこ', 'romaji': 'doko', 'options': ['ở đâu', 'chỗ này', 'chỗ kia', 'cái gì'], 'answer': 'ở đâu'},
      {
        'type': LessonType.flashCard, 'kanji': '教室', 'hiragana': 'きょうしつ', 'romaji': 'kyoushitsu', 'meaning': 'Phòng học',
        'example_img': 'assets/images/example_kyoushitsu.png',
        'example_jp': '教室はどこですか。', 'example_rmj': 'Kyoushitsu wa doko desu ka.', 'example_vn': 'Phòng học ở đâu vậy?'
      },
      {
        'type': LessonType.flashCard, 'kanji': '食堂', 'hiragana': 'しょくどう', 'romaji': 'shokudou', 'meaning': 'Nhà ăn, căng tin',
        'example_img': 'assets/images/example_shokudou.png',
        'example_jp': 'ここは食堂です。', 'example_rmj': 'Koko wa shokudou desu.', 'example_vn': 'Đây là nhà ăn.'
      },
      {'type': LessonType.listening, 'options': ['ここ', 'そこ', 'あそこ', 'どこ'], 'answer': 'どこ'},
      {'type': LessonType.vocabQuiz, 'kanji': '事務所', 'hiragana': 'じむしょ', 'romaji': 'jimusho', 'options': ['phòng học', 'nhà ăn', 'văn phòng', 'bệnh viện'], 'answer': 'văn phòng'},
      {
        'type': LessonType.vocabSummary,
        'words': [
          {'kanji': 'ここ', 'romaji': 'koko', 'meaning': 'Chỗ này'},
          {'kanji': 'そこ', 'romaji': 'soko', 'meaning': 'Chỗ đó'},
          {'kanji': 'あそこ', 'romaji': 'asoko', 'meaning': 'Chỗ kia'},
          {'kanji': 'どこ', 'romaji': 'doko', 'meaning': 'Ở đâu'},
          {'kanji': '教室', 'romaji': 'kyoushitsu', 'meaning': 'Phòng học'},
          {'kanji': '食堂', 'romaji': 'shokudou', 'meaning': 'Nhà ăn'},
          {'kanji': '事務所', 'romaji': 'jimusho', 'meaning': 'Văn phòng'},
        ]
      }
    ];
  }

  List<Map<String, dynamic>> _getCb3LuyenTap1Data() {
    return [
      {
        'type': LessonType.flashCard, 'kanji': '部屋', 'hiragana': 'へや', 'romaji': 'heya', 'meaning': 'Căn phòng',
        'example_img': 'assets/images/example_heya.png',
        'example_jp': '山田さんの部屋はあそこです。', 'example_rmj': 'Yamada-san no heya wa asoko desu.', 'example_vn': 'Phòng của anh Yamada ở đằng kia.'
      },
      {
        'type': LessonType.flashCard, 'kanji': '受付', 'hiragana': 'うけつけ', 'romaji': 'uketsuke', 'meaning': 'Quầy lễ tân',
        'example_img': 'assets/images/example_uketsuke.png',
        'example_jp': '受付はここです。', 'example_rmj': 'Uketsuke wa koko desu.', 'example_vn': 'Quầy lễ tân ở đây.'
      },
      {'type': LessonType.vocabQuiz, 'kanji': 'トイレ', 'hiragana': 'といれ', 'romaji': 'toire', 'options': ['căn phòng', 'thang máy', 'nhà vệ sinh', 'hành lang'], 'answer': 'nhà vệ sinh'},
      {'type': LessonType.vocabQuiz, 'kanji': 'エレベーター', 'hiragana': 'えれべーたー', 'romaji': 'erebe-ta-', 'options': ['thang cuốn', 'thang máy', 'cầu thang', 'hành lang'], 'answer': 'thang máy'},
      {'type': LessonType.quiz, 'question': 'Từ nào nghĩa là "Thang cuốn"?', 'options': ['エレベーター', 'エスカレーター', 'コンピューター', 'カメラ'], 'answer': 'エスカレーター'},
      {'type': LessonType.matching, 'pairs': [
        {'left': 'Phòng', 'right': '部屋'},
        {'left': 'Lễ tân', 'right': '受付'},
        {'left': 'Nhà vệ sinh', 'right': 'トイレ'},
        {'left': 'Thang máy', 'right': 'エレベーター'}
      ]},
    ];
  }

  List<Map<String, dynamic>> _getCb3LuyenTap2Data() {
    return [
      {
        'type': LessonType.flashCard,
        'kanji': 'ここ／そこ／あそこ', 'hiragana': 'ここ/そこ/あそこ', 'romaji': 'koko/soko/asoko',
        'meaning': 'Chỗ này / Chỗ đó / Chỗ kia',
        'example_img': 'assets/images/example_koko.png',
        'example_jp': 'トイレはあそこです。', 'example_rmj': 'Toire wa asoko desu.',
        'example_vn': 'Nhà vệ sinh ở đằng kia.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': '〜はどこですか', 'hiragana': 'どこですか', 'romaji': '~ wa doko desu ka',
        'meaning': '[...] ở đâu vậy?',
        'example_img': 'assets/images/example_soko.png',
        'example_jp': '食堂はどこですか。', 'example_rmj': 'Shokudou wa doko desu ka.',
        'example_vn': 'Nhà ăn ở đâu vậy?',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'ここは食堂です',
        'rmj': 'koko wa shokudou desu',
        'words': ['chỗ này', 'là', 'nhà ăn', 'phòng học', 'văn phòng'],
        'answer': 'chỗ này là nhà ăn',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'トイレはどこですか',
        'rmj': 'toire wa doko desu ka',
        'words': ['nhà vệ sinh', 'ở đâu', 'vậy', 'có phải', 'chỗ kia'],
        'answer': 'nhà vệ sinh ở đâu vậy',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'エレベーターはあそこです',
        'rmj': 'erebe-ta- wa asoko desu',
        'words': ['thang máy', 'thì', 'ở chỗ kia', 'chỗ này', 'nhà vệ sinh'],
        'answer': 'thang máy thì ở chỗ kia',
      },
      {'type': LessonType.quiz, 'question': 'Dịch: "Điện thoại ở đằng kia."', 'options': ['電話はあそこです', '電話はここです', 'あそこは電話です', '電話はどこですか'], 'answer': '電話はあそこです'},
      {'type': LessonType.listening, 'options': ['ここはきょうしつです', 'そこはきょうしつです', 'あそこはきょうしつです', 'きょうしつはどこですか'], 'answer': 'きょうしつはどこですか'},
    ];
  }

  List<Map<String, dynamic>> _getCb3LuyenTap3Data() {
    return [
      {
        'type': LessonType.flashCard, 'kanji': '靴', 'hiragana': 'くつ', 'romaji': 'kutsu', 'meaning': 'Giầy',
        'example_img': 'assets/images/example_kutsu.png',
        'example_jp': 'それは日本の靴です。', 'example_rmj': 'Sore wa nihon no kutsu desu.', 'example_vn': 'Đó là giầy của Nhật.'
      },
      {
        'type': LessonType.flashCard, 'kanji': 'いくら', 'hiragana': 'いくら', 'romaji': 'ikura', 'meaning': 'Bao nhiêu tiền',
        'example_img': 'assets/images/example_ikura.png',
        'example_jp': 'この靴はいくらですか。', 'example_rmj': 'Kono kutsu wa ikura desu ka.', 'example_vn': 'Đôi giầy này bao nhiêu tiền?'
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'この時計はいくらですか',
        'rmj': 'kono tokei wa ikura desu ka',
        'words': ['đồng hồ', 'này', 'bao nhiêu tiền', 'vậy', 'của ai'],
        'answer': 'đồng hồ này bao nhiêu tiền vậy',
      },
      {'type': LessonType.vocabQuiz, 'kanji': '百', 'hiragana': 'ひゃく', 'romaji': 'hyaku', 'options': ['mười', 'trăm', 'ngàn', 'vạn'], 'answer': 'trăm'},
      {'type': LessonType.vocabQuiz, 'kanji': '千', 'hiragana': 'せん', 'romaji': 'sen', 'options': ['mười', 'trăm', 'ngàn', 'vạn'], 'answer': 'ngàn'},
      {'type': LessonType.vocabQuiz, 'kanji': '万', 'hiragana': 'まん', 'romaji': 'man', 'options': ['mười', 'trăm', 'ngàn', 'mười ngàn (vạn)'], 'answer': 'mười ngàn (vạn)'},
      {'type': LessonType.matching, 'pairs': [{'left': 'Giầy', 'right': '靴'}, {'left': 'Bao nhiêu tiền', 'right': 'いくら'}, {'left': 'Nước (quốc gia)', 'right': '国'}, {'left': 'Công ty', 'right': '会社'}]},
    ];
  }

  List<Map<String, dynamic>> _getCb3LuyenNoiData() {
    return [
      {
        'type': LessonType.flashCard, 'kanji': 'すみません', 'hiragana': 'すみません', 'romaji': 'sumimasen', 'meaning': 'Xin lỗi (Dùng khi gọi nhân viên)',
        'example_img': 'assets/images/example_sumimasen.png',
        'example_jp': 'すみません、時計を見せてください。', 'example_rmj': 'Sumimasen, tokei o misete kudasai.', 'example_vn': 'Xin lỗi, cho tôi xem cái đồng hồ.'
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'じゃ、これをください',
        'rmj': 'ja, kore o kudasai',
        'words': ['vậy thì', 'cho tôi', 'lấy cái này', 'bao nhiêu tiền', 'cám ơn'],
        'answer': 'vậy thì cho tôi lấy cái này',
      },
      {'type': LessonType.listening, 'options': ['いくらですか', 'どこですか', 'だれですか', 'なんですか'], 'answer': 'いくらですか'},
      {'type': LessonType.quiz, 'question': 'Câu nói khi quyết định mua hàng là?', 'options': ['これをください', 'これを見せてください', 'いくらですか', 'そうですか'], 'answer': 'これをください'},
    ];
  }

  List<Map<String, dynamic>> _getCb3LuyenVietData() {
    return [
      {'type': LessonType.kanjiDraw, 'kanji_word': '円', 'kanji_target': '円', 'meaning': 'Viên (Đồng Yên Nhật)', 'rmj': 'en'},
      {'type': LessonType.kanjiDraw, 'kanji_word': '百', 'kanji_target': '百', 'meaning': 'Bách (Một trăm)', 'rmj': 'hyaku'},
      {'type': LessonType.kanjiDraw, 'kanji_word': '千', 'kanji_target': '千', 'meaning': 'Thiên (Một ngàn)', 'rmj': 'sen'},
      {'type': LessonType.kanjiDraw, 'kanji_word': '万', 'kanji_target': '万', 'meaning': 'Vạn (Mười ngàn)', 'rmj': 'man'},
      {'type': LessonType.matching, 'pairs': [
        {'left': 'Đồng Yên', 'right': '円'},
        {'left': 'Trăm', 'right': '百'},
        {'left': 'Ngàn', 'right': '千'},
        {'left': 'Mười Ngàn', 'right': '万'},
      ]},
    ];
  }

  List<Map<String, dynamic>> _getCb3OnTapData() {
    return [
      {'type': LessonType.quiz, 'question': 'Phòng học ở đâu? (Dịch)', 'options': ['教室はどこですか', '教室はここですか', '教室はいくらですか', 'ここは教室ですか'], 'answer': '教室はどこですか'},
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'この鞄はいくらですか',
        'rmj': 'kono kaban wa ikura desu ka',
        'words': ['cái cặp', 'này', 'bao nhiêu tiền', 'vậy', 'của ai'],
        'answer': 'cái cặp này bao nhiêu tiền vậy',
      },
      {'type': LessonType.vocabQuiz, 'kanji': '靴', 'hiragana': 'くつ', 'romaji': 'kutsu', 'options': ['quần áo', 'giầy', 'cà vạt', 'đồng hồ'], 'answer': 'giầy'},
      {'type': LessonType.kanjiDraw, 'kanji_word': '万', 'kanji_target': '万', 'meaning': 'Vạn (Mười ngàn)', 'rmj': 'man'},
      {'type': LessonType.listening, 'options': ['これをください', 'これを見せてください', 'いくらですか', 'そうですか'], 'answer': 'これを見せてください'},
      {
        'type': LessonType.vocabSummary,
        'words': [
          {'kanji': 'ここ/そこ/あそこ', 'romaji': 'koko/soko/asoko', 'meaning': 'Chỗ này/đó/kia'},
          {'kanji': 'どこ', 'romaji': 'doko', 'meaning': 'Ở đâu'},
          {'kanji': '教室', 'romaji': 'kyoushitsu', 'meaning': 'Phòng học'},
          {'kanji': '食堂', 'romaji': 'shokudou', 'meaning': 'Nhà ăn'},
          {'kanji': '事務所', 'romaji': 'jimusho', 'meaning': 'Văn phòng'},
          {'kanji': '部屋', 'romaji': 'heya', 'meaning': 'Căn phòng'},
          {'kanji': '受付', 'romaji': 'uketsuke', 'meaning': 'Lễ tân'},
          {'kanji': 'トイレ', 'romaji': 'toire', 'meaning': 'Nhà vệ sinh'},
          {'kanji': '靴', 'romaji': 'kutsu', 'meaning': 'Giầy'},
          {'kanji': 'いくら', 'romaji': 'ikura', 'meaning': 'Bao nhiêu tiền'},
          {'kanji': '百/千/万', 'romaji': 'hyaku/sen/man', 'meaning': 'Trăm/Ngàn/Vạn'},
        ]
      }
    ];
  }

  // ==========================================
  // DỮ LIỆU PHẦN CƠ BẢN 4 (THỜI GIAN & ĐỘNG TỪ)
  // ==========================================

  List<Map<String, dynamic>> _getCb4LyThuyetData() {
    return [
      {
        'type': LessonType.flashCard, 'kanji': '今', 'hiragana': 'いま', 'romaji': 'ima', 'meaning': 'Bây giờ',
        'example_img': 'assets/images/example_ima.png',
        'example_jp': '今は何時ですか。', 'example_rmj': 'Ima wa nanji desu ka.', 'example_vn': 'Bây giờ là mấy giờ?'
      },
      {
        'type': LessonType.flashCard, 'kanji': '時', 'hiragana': 'じ', 'romaji': 'ji', 'meaning': 'Giờ (dùng kèm số)',
        'example_img': 'assets/images/example_ji.png',
        'example_jp': '今は９時です。', 'example_rmj': 'Ima wa kuji desu.', 'example_vn': 'Bây giờ là 9 giờ.'
      },
      {'type': LessonType.vocabQuiz, 'kanji': '分', 'hiragana': 'ふん／ぷん', 'romaji': 'fun / pun', 'options': ['giây', 'phút', 'giờ', 'ngày'], 'answer': 'phút'},
      {'type': LessonType.vocabQuiz, 'kanji': '半', 'hiragana': 'はん', 'romaji': 'han', 'options': ['nửa / rưỡi', 'toàn bộ', 'một phần', 'chưa tới'], 'answer': 'nửa / rưỡi'},
      {'type': LessonType.listening, 'options': ['いま', 'なんじ', 'なんぷん', 'はん'], 'answer': 'なんじ'},
      {
        'type': LessonType.sentenceBuilder,
        'jp': '今は４時半です',
        'rmj': 'ima wa yoji han desu',
        'words': ['bây giờ', 'là', '4 giờ', 'rưỡi', 'mấy giờ'],
        'answer': 'bây giờ là 4 giờ rưỡi',
      },
      {'type': LessonType.matching, 'pairs': [{'left': 'Bây giờ', 'right': '今'}, {'left': 'Giờ', 'right': '時'}, {'left': 'Phút', 'right': '分'}, {'left': 'Rưỡi', 'right': '半'}]},
      {
        'type': LessonType.vocabSummary,
        'words': [
          {'kanji': '今', 'romaji': 'ima', 'meaning': 'Bây giờ'},
          {'kanji': '～時', 'romaji': '~ji', 'meaning': '... giờ'},
          {'kanji': '～分', 'romaji': '~fun/pun', 'meaning': '... phút'},
          {'kanji': '半', 'romaji': 'han', 'meaning': 'rưỡi / một nửa'},
          {'kanji': '何時', 'romaji': 'nanji', 'meaning': 'Mấy giờ'},
          {'kanji': '何分', 'romaji': 'nanpun', 'meaning': 'Mấy phút'},
        ]
      }
    ];
  }

  List<Map<String, dynamic>> _getCb4LuyenTap1Data() {
    return [
      {'type': LessonType.vocabQuiz, 'kanji': '月曜日', 'hiragana': 'げつようび', 'romaji': 'getsuyoubi', 'options': ['Thứ hai', 'Thứ ba', 'Thứ tư', 'Thứ năm'], 'answer': 'Thứ hai'},
      {'type': LessonType.vocabQuiz, 'kanji': '火曜日', 'hiragana': 'かようび', 'romaji': 'kayoubi', 'options': ['Thứ hai', 'Thứ ba', 'Thứ tư', 'Thứ năm'], 'answer': 'Thứ ba'},
      {'type': LessonType.vocabQuiz, 'kanji': '日曜日', 'hiragana': 'にちようび', 'romaji': 'nichiyoubi', 'options': ['Thứ sáu', 'Thứ bảy', 'Chủ nhật', 'Hôm qua'], 'answer': 'Chủ nhật'},
      {'type': LessonType.listening, 'options': ['げつようび', 'すいようび', 'きんようび', 'にちようび'], 'answer': 'きんようび'},
      {'type': LessonType.quiz, 'question': 'Hôm nay là thứ mấy? (Tiếng Nhật)', 'options': ['きょうはなんようびですか', 'きょうはなんじですか', 'きょうはなんにちですか', 'あしたはなんようびですか'], 'answer': 'きょうはなんようびですか'},
      {'type': LessonType.matching, 'pairs': [
        {'left': 'Thứ hai', 'right': '月曜日'},
        {'left': 'Thứ ba', 'right': '火曜日'},
        {'left': 'Thứ tư', 'right': '水曜日'},
        {'left': 'Thứ năm', 'right': '木曜日'}
      ]},
    ];
  }

  List<Map<String, dynamic>> _getCb4LuyenTap2Data() {
    return [
      {
        'type': LessonType.flashCard,
        'kanji': '起きます', 'hiragana': 'おきます', 'romaji': 'okimasu', 'meaning': 'Thức dậy',
        'example_img': 'assets/images/example_okimasu.png',
        'example_jp': '毎朝６時に起きます。', 'example_rmj': 'Maiasa rokuji ni okimasu.',
        'example_vn': 'Tôi thức dậy lúc 6 giờ mỗi sáng.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': '寝ます', 'hiragana': 'ねます', 'romaji': 'nemasu', 'meaning': 'Ngủ',
        'example_img': 'assets/images/example_nemasu.png',
        'example_jp': '11時に寝ます。', 'example_rmj': 'Juu-ichi ji ni nemasu.',
        'example_vn': 'Tôi ngủ lúc 11 giờ.',
      },
      {
        'type': LessonType.flashCard, 'kanji': '起きます', 'hiragana': 'おきます', 'romaji': 'okimasu', 'meaning': 'Thức dậy',
        'example_img': 'assets/images/example_okimasu.png',
        'example_jp': '私は毎朝６時に起きます。', 'example_rmj': 'Watashi wa maiasa rokuji ni okimasu.', 'example_vn': 'Tôi thức dậy lúc 6 giờ mỗi sáng.'
      },
      {
        'type': LessonType.flashCard, 'kanji': '寝ます', 'hiragana': 'ねます', 'romaji': 'nemasu', 'meaning': 'Ngủ',
        'example_img': 'assets/images/example_nemasu.png',
        'example_jp': '昨日の夜、１１時に寝ました。', 'example_rmj': 'Kinou no yoru, juu-ichi ji ni nemashita.', 'example_vn': 'Đêm qua tôi đã ngủ lúc 11 giờ.'
      },
      {'type': LessonType.vocabQuiz, 'kanji': '働きます', 'hiragana': 'はたらきます', 'romaji': 'hatarakimasu', 'options': ['nghỉ ngơi', 'làm việc', 'học tập', 'kết thúc'], 'answer': 'làm việc'},
      {'type': LessonType.vocabQuiz, 'kanji': '休みます', 'hiragana': 'やすみます', 'romaji': 'yasumimasu', 'options': ['thức dậy', 'làm việc', 'học tập', 'nghỉ ngơi'], 'answer': 'nghỉ ngơi'},
      {'type': LessonType.vocabQuiz, 'kanji': '勉強します', 'hiragana': 'べんきょうします', 'romaji': 'benkyoushimasu', 'options': ['làm việc', 'nghỉ ngơi', 'học tập', 'thức dậy'], 'answer': 'học tập'},
      {'type': LessonType.sentenceBuilder,
        'jp': '私は６時に起きます',
        'rmj': 'watashi wa rokuji ni okimasu',
        'words': ['tôi', 'thức dậy', 'lúc', '6 giờ', 'sáng'],
        'answer': 'tôi thức dậy lúc 6 giờ',
      },
    ];
  }

  List<Map<String, dynamic>> _getCb4LuyenTap3Data() {
    return [
      {'type': LessonType.quiz, 'question': 'Trợ từ đi với thời gian cụ thể (lúc mấy giờ) là gì?', 'options': ['に (ni)', 'で (de)', 'を (o)', 'へ (he)'], 'answer': 'に (ni)'},
      {'type': LessonType.quiz, 'question': 'Thì Quá khứ của です (desu) là gì?', 'options': ['でした (deshita)', 'じゃありません (ja arimasen)', 'ます (masu)', 'ません (masen)'], 'answer': 'でした (deshita)'},
      {'type': LessonType.quiz, 'question': 'Động từ phủ định ở thì hiện tại kết thúc bằng gì?', 'options': ['～ます (~masu)', '～ました (~mashita)', '～ません (~masen)', '～ませんでした (~masen deshita)'], 'answer': '～ません (~masen)'},
      {
        'type': LessonType.sentenceBuilder,
        'jp': '昨日勉強しませんでした',
        'rmj': 'kinou benkyoushimasen deshita',
        'words': ['hôm qua', 'đã', 'không', 'học bài', 'ngủ'],
        'answer': 'hôm qua đã không học bài',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': '９時から５時まで働きます',
        'rmj': 'kuji kara goji made hatarakimasu',
        'words': ['từ', '9 giờ', 'đến', '5 giờ', 'làm việc'],
        'answer': 'làm việc từ 9 giờ đến 5 giờ',
      },
      {'type': LessonType.matching, 'pairs': [
        {'left': 'Học', 'right': '勉強します'},
        {'left': 'Đã học', 'right': '勉強しました'},
        {'left': 'Không học', 'right': '勉強しません'},
        {'left': 'Đã không học', 'right': '勉強しませんでした'}
      ]},
    ];
  }

  List<Map<String, dynamic>> _getCb4LuyenNoiData() {
    return [
      {
        'type': LessonType.flashCard, 'kanji': '大変ですね', 'hiragana': 'たいへんですね', 'romaji': 'Taihen desu ne', 'meaning': 'Vất vả cho bạn quá / Bạn mệt nhỉ',
        'example_img': 'assets/images/example_taihen.png',
        'example_jp': '毎日１０時まで働きます。大変ですね。', 'example_rmj': 'Mainichi juuji made hatarakimasu. Taihen desu ne.', 'example_vn': 'Ngày nào tôi cũng làm đến 10 giờ. Vất vả quá nhỉ.'
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'そちらは何時までですか',
        'rmj': 'sochira wa nanji made desu ka',
        'words': ['chỗ bạn', 'làm việc', 'đến', 'mấy giờ', 'vậy'],
        'answer': 'chỗ bạn làm việc đến mấy giờ vậy',
      },
      {'type': LessonType.listening, 'options': ['たいへんですね', 'ありがとうございます', 'すみません', 'どうぞ'], 'answer': 'たいへんですね'},
    ];
  }

  List<Map<String, dynamic>> _getCb4LuyenVietData() {
    return [
      {'type': LessonType.kanjiDraw, 'kanji_word': '時', 'kanji_target': '時', 'meaning': 'Thời (Thời gian, giờ)', 'rmj': 'toki / ji'},
      {'type': LessonType.kanjiDraw, 'kanji_word': '分', 'kanji_target': '分', 'meaning': 'Phân (Phút, chia ra)', 'rmj': 'fun / pun / wa(keru)'},
      {'type': LessonType.kanjiDraw, 'kanji_word': '半', 'kanji_target': '半', 'meaning': 'Bán (Một nửa, rưỡi)', 'rmj': 'han'},
      {'type': LessonType.kanjiDraw, 'kanji_word': '行', 'kanji_target': '行', 'meaning': 'Hành (Đi)', 'rmj': 'i(ku) / kou'},
      {'type': LessonType.matching, 'pairs': [
        {'left': 'Giờ', 'right': '時'},
        {'left': 'Phút', 'right': '分'},
        {'left': 'Rưỡi', 'right': '半'},
        {'left': 'Đi', 'right': '行'},
      ]},
    ];
  }

  List<Map<String, dynamic>> _getCb4OnTapData() {
    return [
      {'type': LessonType.quiz, 'question': 'Bây giờ là mấy giờ? (Dịch)', 'options': ['今は何時ですか', '今は何分ですか', '今日は何曜日ですか', '明日は何日ですか'], 'answer': '今は何時ですか'},
      {
        'type': LessonType.sentenceBuilder,
        'jp': '月曜日から金曜日まで働きます',
        'rmj': 'getsuyoubi kara kinyoubi made hatarakimasu',
        'words': ['tôi làm việc', 'từ', 'thứ hai', 'đến', 'thứ sáu'],
        'answer': 'tôi làm việc từ thứ hai đến thứ sáu',
      },
      {'type': LessonType.vocabQuiz, 'kanji': '起きます', 'hiragana': 'おきます', 'romaji': 'okimasu', 'options': ['ngủ', 'thức dậy', 'làm việc', 'nghỉ ngơi'], 'answer': 'thức dậy'},
      {'type': LessonType.kanjiDraw, 'kanji_word': '時', 'kanji_target': '時', 'meaning': 'Thời (Thời gian, giờ)', 'rmj': 'ji'},
      {'type': LessonType.listening, 'options': ['おきます', 'ねます', 'やすみます', 'はたらきます'], 'answer': 'はたらきます'},
      {
        'type': LessonType.vocabSummary,
        'words': [
          {'kanji': '今', 'romaji': 'ima', 'meaning': 'Bây giờ'},
          {'kanji': '～時 / ～分', 'romaji': '~ji / ~fun', 'meaning': 'Giờ / Phút'},
          {'kanji': '半', 'romaji': 'han', 'meaning': 'Rưỡi'},
          {'kanji': '月曜日', 'romaji': 'getsuyoubi', 'meaning': 'Thứ hai'},
          {'kanji': '起きます', 'romaji': 'okimasu', 'meaning': 'Thức dậy'},
          {'kanji': '寝ます', 'romaji': 'nemasu', 'meaning': 'Ngủ'},
          {'kanji': '働きます', 'romaji': 'hatarakimasu', 'meaning': 'Làm việc'},
          {'kanji': '休みます', 'romaji': 'yasumimasu', 'meaning': 'Nghỉ ngơi'},
          {'kanji': '勉強します', 'romaji': 'benkyoushimasu', 'meaning': 'Học tập'},
          {'kanji': '～から / ～まで', 'romaji': '~kara / ~made', 'meaning': 'Từ ~ / Đến ~'},
        ]
      }
    ];
  }

  List<Map<String, dynamic>> _getCb5LyThuyetData() {
    return [
      {
        'type': LessonType.flashCard, 'kanji': '行きます', 'hiragana': 'いきます', 'romaji': 'ikimasu', 'meaning': 'Đi',
        'example_img': 'assets/images/example_ikimasu.png',
        'example_jp': '私は京都へ行きます。', 'example_rmj': 'Watashi wa Kyouto e ikimasu.', 'example_vn': 'Tôi đi Kyoto.'
      },
      {
        'type': LessonType.flashCard, 'kanji': '来ます', 'hiragana': 'きます', 'romaji': 'kimasu', 'meaning': 'Đến',
        'example_img': 'assets/images/example_kimasu.png',
        'example_jp': '昨日、日本へ来ました。', 'example_rmj': 'Kinou, Nihon e kimashita.', 'example_vn': 'Tôi đã đến Nhật Bản hôm qua.'
      },
      {
        'type': LessonType.flashCard, 'kanji': '帰ります', 'hiragana': 'かえります', 'romaji': 'kaerimasu', 'meaning': 'Về',
        'example_img': 'assets/images/example_kaerimasu.png',
        'example_jp': 'うちへ帰ります。', 'example_rmj': 'Uchi e kaerimasu.', 'example_vn': 'Tôi đi về nhà.'
      },
      {'type': LessonType.vocabQuiz, 'kanji': '行きます', 'hiragana': 'いきます', 'romaji': 'ikimasu', 'options': ['đến', 'đi', 'về', 'ngủ'], 'answer': 'đi'},
      {'type': LessonType.vocabQuiz, 'kanji': '来ます', 'hiragana': 'きます', 'romaji': 'kimasu', 'options': ['đến', 'thức dậy', 'làm việc', 'về'], 'answer': 'đến'},
      {'type': LessonType.matching, 'pairs': [{'left': 'Đi', 'right': '行きます'}, {'left': 'Đến', 'right': '来ます'}, {'left': 'Về', 'right': '帰ります'}, {'left': 'Nhà', 'right': 'うち'}]},
    ];
  }

  List<Map<String, dynamic>> _getCb5LuyenTap1Data() {
    return [
      {
        'type': LessonType.flashCard, 'kanji': '電車', 'hiragana': 'でんしゃ', 'romaji': 'densha', 'meaning': 'Tàu điện',
        'example_img': 'assets/images/example_densha.png',
        'example_jp': '電車で会社へ行きます。', 'example_rmj': 'Densha de kaisha e ikimasu.', 'example_vn': 'Tôi đi đến công ty bằng tàu điện.'
      },
      {
        'type': LessonType.flashCard, 'kanji': '自転車', 'hiragana': 'じてんしゃ', 'romaji': 'jitensha', 'meaning': 'Xe đạp',
        'example_img': 'assets/images/example_jitensha.png',
        'example_jp': '自転車でうちへ帰ります。', 'example_rmj': 'Jitensha de uchi e kaerimasu.', 'example_vn': 'Tôi về nhà bằng xe đạp.'
      },
      {'type': LessonType.vocabQuiz, 'kanji': '飛行機', 'hiragana': 'ひこうき', 'romaji': 'hikouki', 'options': ['xe buýt', 'xe đạp', 'máy bay', 'tàu thủy'], 'answer': 'máy bay'},
      {'type': LessonType.vocabQuiz, 'kanji': '歩いて', 'hiragana': 'あるいて', 'romaji': 'aruite', 'options': ['đi bộ', 'chạy', 'đi xe', 'bơi'], 'answer': 'đi bộ'},
      {'type': LessonType.listening, 'options': ['でんしゃ', 'ちかてつ', 'じてんしゃ', 'ひこうき'], 'answer': 'ちかてつ'},
      {'type': LessonType.matching, 'pairs': [{'left': 'Xe đạp', 'right': '自転車'}, {'left': 'Tàu điện', 'right': '電車'}, {'left': 'Tàu điện ngầm', 'right': '地下鉄'}, {'left': 'Đi bộ', 'right': '歩いて'}]},
    ];
  }

  List<Map<String, dynamic>> _getCb5LuyenTap2Data() {
    return [
      {
        'type': LessonType.flashCard,
        'kanji': '行きます', 'hiragana': 'いきます', 'romaji': 'ikimasu', 'meaning': 'Đi',
        'example_img': 'assets/images/example_ikimasu.png',
        'example_jp': '学校へ行きます。', 'example_rmj': 'Gakkou e ikimasu.',
        'example_vn': 'Tôi đi đến trường.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': 'どこへも行きません', 'hiragana': 'どこへもいきません', 'romaji': 'doko e mo ikimasen',
        'meaning': 'Không đi đâu cả',
        'example_img': 'assets/images/example_kaerimasu.png',
        'example_jp': '今日はどこへも行きません。', 'example_rmj': 'Kyou wa doko e mo ikimasen.',
        'example_vn': 'Hôm nay tôi không đi đâu cả.',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'どこへ行きますか',
        'rmj': 'doko e ikimasu ka',
        'words': ['bạn', 'đi', 'đâu', 'vậy', 'ở đâu'],
        'answer': 'bạn đi đâu vậy',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'スーパーへ行きます',
        'rmj': 'su-pa- e ikimasu',
        'words': ['tôi', 'đi', 'đến', 'siêu thị', 'trường học'],
        'answer': 'tôi đi đến siêu thị',
      },
      {'type': LessonType.quiz, 'question': 'Trợ từ chỉ hướng di chuyển (Đi đến...) viết là gì?', 'options': ['へ (he)', 'に (ni)', 'で (de)', 'を (o)'], 'answer': 'へ (he)'},
      {'type': LessonType.quiz, 'question': 'Phủ định hoàn toàn: "Tôi không đi đâu cả" nói thế nào?', 'options': ['どこへも行きません', 'どこへ行きます', 'どこも行きません', 'だれも行きません'], 'answer': 'どこへも行きません'},
      {'type': LessonType.listening, 'options': ['うちへかえります', 'がっこうへいきます', 'スーパーへいきます', 'どこへもいきません'], 'answer': 'どこへもいきません'},
    ];
  }

  List<Map<String, dynamic>> _getCb5LuyenTap3Data() {
    return [
      {
        'type': LessonType.sentenceBuilder,
        'jp': '何で京都へ行きますか',
        'rmj': 'nan de kyouto e ikimasu ka',
        'words': ['bạn', 'đi', 'đến Kyoto', 'bằng gì', 'với ai'],
        'answer': 'bạn đi đến Kyoto bằng gì',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': '新幹線で行きます',
        'rmj': 'shinkansen de ikimasu',
        'words': ['tôi', 'đi', 'bằng', 'tàu siêu tốc', 'máy bay'],
        'answer': 'tôi đi bằng tàu siêu tốc',
      },
      {'type': LessonType.quiz, 'question': 'Hỏi "Đi với ai?" dùng từ gì?', 'options': ['だれと (dare to)', 'なんで (nan de)', 'だれで (dare de)', 'どこへ (doko e)'], 'answer': 'だれと (dare to)'},
      {
        'type': LessonType.sentenceBuilder,
        'jp': '友達と来ました',
        'rmj': 'tomodachi to kimashita',
        'words': ['tôi', 'đã đến', 'cùng với', 'bạn bè', 'gia đình'],
        'answer': 'tôi đã đến cùng với bạn bè',
      },
    ];
  }

  List<Map<String, dynamic>> _getCb5LuyenNoiData() {
    return [
      {'type': LessonType.vocabQuiz, 'kanji': 'いつ', 'hiragana': 'いつ', 'romaji': 'itsu', 'options': ['khi nào', 'ở đâu', 'ai', 'cái gì'], 'answer': 'khi nào'},
      {'type': LessonType.vocabQuiz, 'kanji': '誕生日', 'hiragana': 'たんじょうび', 'romaji': 'tanjoubi', 'options': ['ngày mai', 'sinh nhật', 'hôm nay', 'năm sau'], 'answer': 'sinh nhật'},
      {
        'type': LessonType.sentenceBuilder,
        'jp': '誕生日はいつですか',
        'rmj': 'tanjoubi wa itsu desu ka',
        'words': ['sinh nhật', 'của bạn', 'là', 'khi nào', 'tháng mấy'],
        'answer': 'sinh nhật của bạn là khi nào',
      },
      {'type': LessonType.listening, 'options': ['いつですか', 'どこですか', 'だれですか', 'なんですか'], 'answer': 'いつですか'},
    ];
  }

  List<Map<String, dynamic>> _getCb5LuyenVietData() {
    return [
      {'type': LessonType.kanjiDraw, 'kanji_word': '行きます', 'kanji_target': '行', 'meaning': 'Hành (Đi)', 'rmj': 'i(ku) / kou'},
      {'type': LessonType.kanjiDraw, 'kanji_word': '来ます', 'kanji_target': '来', 'meaning': 'Lai (Đến)', 'rmj': 'ki(masu) / rai'},
      {'type': LessonType.kanjiDraw, 'kanji_word': '休み', 'kanji_target': '休', 'meaning': 'Hưu (Nghỉ ngơi)', 'rmj': 'yasu(mi)'},
      {'type': LessonType.matching, 'pairs': [{'left': 'Đi', 'right': '行きます'}, {'left': 'Đến', 'right': '来ます'}, {'left': 'Nghỉ', 'right': '休み'}]},
    ];
  }

  List<Map<String, dynamic>> _getCb5OnTapData() {
    return [
      {'type': LessonType.quiz, 'question': 'Trợ từ chỉ phương tiện di chuyển (Bằng...) là?', 'options': ['で (de)', 'に (ni)', 'と (to)', 'を (o)'], 'answer': 'で (de)'},
      {
        'type': LessonType.sentenceBuilder,
        'jp': '自転車で学校へ行きます',
        'rmj': 'jitensha de gakkou e ikimasu',
        'words': ['tôi', 'đi', 'đến trường', 'bằng', 'xe đạp'],
        'answer': 'tôi đi đến trường bằng xe đạp',
      },
      {'type': LessonType.vocabQuiz, 'kanji': '飛行機', 'hiragana': 'ひこうき', 'romaji': 'hikouki', 'options': ['máy bay', 'tàu thủy', 'tàu điện', 'xe đạp'], 'answer': 'máy bay'},
      {'type': LessonType.kanjiDraw, 'kanji_word': '帰ります', 'kanji_target': '帰', 'meaning': 'Quy (Về)', 'rmj': 'kae(ru)'},
      {
        'type': LessonType.vocabSummary,
        'words': [
          {'kanji': '行きます', 'romaji': 'ikimasu', 'meaning': 'Đi'},
          {'kanji': '来ます', 'romaji': 'kimasu', 'meaning': 'Đến'},
          {'kanji': '帰ります', 'romaji': 'kaerimasu', 'meaning': 'Về'},
          {'kanji': '電車', 'romaji': 'densha', 'meaning': 'Tàu điện'},
          {'kanji': '自転車', 'romaji': 'jitensha', 'meaning': 'Xe đạp'},
          {'kanji': '飛行機', 'romaji': 'hikouki', 'meaning': 'Máy bay'},
          {'kanji': '歩いて', 'romaji': 'aruite', 'meaning': 'Đi bộ'},
          {'kanji': '友達', 'romaji': 'tomodachi', 'meaning': 'Bạn bè'},
          {'kanji': 'いつ', 'romaji': 'itsu', 'meaning': 'Khi nào'},
        ]
      }
    ];
  }

  // ==========================================
  // DỮ LIỆU CƠ BẢN 6 (ĂN UỐNG, MUA SẮM & RỦ RÊ)
  // ==========================================

  List<Map<String, dynamic>> _getCb6LyThuyetData() {
    return [
      {
        'type': LessonType.flashCard, 'kanji': '食べます', 'hiragana': 'たべます', 'romaji': 'tabemasu', 'meaning': 'Ăn',
        'example_img': 'assets/images/example_tabemasu.png',
        'example_jp': 'パンを食べます。', 'example_rmj': 'Pan o tabemasu.', 'example_vn': 'Tôi ăn bánh mì.'
      },
      {
        'type': LessonType.flashCard, 'kanji': '飲みます', 'hiragana': 'のみます', 'romaji': 'nomimasu', 'meaning': 'Uống',
        'example_img': 'assets/images/example_nomimasu.png',
        'example_jp': '水を飲みます。', 'example_rmj': 'Mizu o nomimasu.', 'example_vn': 'Tôi uống nước.'
      },
      {
        'type': LessonType.flashCard, 'kanji': '見ます', 'hiragana': 'みます', 'romaji': 'mimasu', 'meaning': 'Xem, nhìn',
        'example_img': 'assets/images/example_mimasu.png',
        'example_jp': 'テレビを見ます。', 'example_rmj': 'Terebi o mimasu.', 'example_vn': 'Tôi xem ti vi.'
      },
      {'type': LessonType.vocabQuiz, 'kanji': '買います', 'hiragana': 'かいます', 'romaji': 'kaimasu', 'options': ['mua', 'bán', 'đọc', 'nghe'], 'answer': 'mua'},
      {'type': LessonType.vocabQuiz, 'kanji': '聞きます', 'hiragana': 'ききます', 'romaji': 'kikimasu', 'options': ['nghe', 'nói', 'đọc', 'viết'], 'answer': 'nghe'},
      {'type': LessonType.matching, 'pairs': [{'left': 'Ăn', 'right': '食べます'}, {'left': 'Uống', 'right': '飲みます'}, {'left': 'Xem', 'right': '見ます'}, {'left': 'Mua', 'right': '買います'}]},
    ];
  }

  List<Map<String, dynamic>> _getCb6LuyenTap1Data() {
    return [
      {
        'type': LessonType.flashCard, 'kanji': '水', 'hiragana': 'みず', 'romaji': 'mizu', 'meaning': 'Nước',
        'example_img': 'assets/images/example_mizu.png',
        'example_jp': '水を飲みます。', 'example_rmj': 'Mizu o nomimasu.', 'example_vn': 'Tôi uống nước.'
      },
      {'type': LessonType.vocabQuiz, 'kanji': '肉', 'hiragana': 'にく', 'romaji': 'niku', 'options': ['thịt', 'cá', 'rau', 'trứng'], 'answer': 'thịt'},
      {'type': LessonType.vocabQuiz, 'kanji': '魚', 'hiragana': 'さかな', 'romaji': 'sakana', 'options': ['thịt', 'cá', 'rau', 'trái cây'], 'answer': 'cá'},
      {'type': LessonType.vocabQuiz, 'kanji': '卵', 'hiragana': 'たまご', 'romaji': 'tamago', 'options': ['trái cây', 'sữa', 'trứng', 'bánh mì'], 'answer': 'trứng'},
      {'type': LessonType.listening, 'options': ['ごはん', 'パン', 'にく', 'さかな'], 'answer': 'ごはん'},
      {'type': LessonType.matching, 'pairs': [{'left': 'Thịt', 'right': '肉'}, {'left': 'Cá', 'right': '魚'}, {'left': 'Trứng', 'right': '卵'}, {'left': 'Nước', 'right': '水'}]},
    ];
  }

  List<Map<String, dynamic>> _getCb6LuyenTap2Data() {
    return [
      {
        'type': LessonType.flashCard,
        'kanji': '食べます／飲みます', 'hiragana': 'たべます/のみます', 'romaji': 'tabemasu / nomimasu',
        'meaning': 'Ăn / Uống',
        'example_img': 'assets/images/example_tabemasu.png',
        'example_jp': 'ご飯を食べます。', 'example_rmj': 'Gohan o tabemasu.',
        'example_vn': 'Tôi ăn cơm.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': 'を (tân ngữ)', 'hiragana': 'を', 'romaji': 'o',
        'meaning': 'Trợ từ: [Ăn CÁI GÌ], [Uống CÁI GÌ]',
        'example_img': 'assets/images/example_nomimasu.png',
        'example_jp': '何を飲みますか。', 'example_rmj': 'Nani o nomimasu ka.',
        'example_vn': 'Bạn uống gì vậy?',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'パンを食べます',
        'rmj': 'pan o tabemasu',
        'words': ['tôi', 'ăn', 'bánh mì', 'uống', 'nước'],
        'answer': 'tôi ăn bánh mì',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': '何を飲みますか',
        'rmj': 'nani o nomimasu ka',
        'words': ['bạn', 'uống', 'cái gì', 'vậy', 'ăn'],
        'answer': 'bạn uống cái gì vậy',
      },
      {'type': LessonType.quiz, 'question': 'Trợ từ nối TÂN NGỮ và ĐỘNG TỪ (Ăn bánh, Uống nước) là gì?', 'options': ['を (o)', 'で (de)', 'に (ni)', 'が (ga)'], 'answer': 'を (o)'},
      {'type': LessonType.quiz, 'question': 'Dịch: "Tôi không ăn gì cả."', 'options': ['何も食べません', '何も食べます', 'どこも行きません', '何をたべません'], 'answer': '何も食べません'},
      {'type': LessonType.listening, 'options': ['なにをしますか', 'なにをたべますか', 'なにをのみますか', 'なにもしません'], 'answer': 'なにをしますか'},
    ];
  }

  List<Map<String, dynamic>> _getCb6LuyenTap3Data() {
    return [
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'デパートで靴を買います',
        'rmj': 'depa-to de kutsu o kaimasu',
        'words': ['tôi', 'mua', 'giầy', 'ở', 'trung tâm thương mại'],
        'answer': 'tôi mua giầy ở trung tâm thương mại',
      },
      {'type': LessonType.quiz, 'question': 'Trợ từ chỉ NƠI XẢY RA HÀNH ĐỘNG (Làm gì TẠI đâu) là?', 'options': ['で (de)', 'に (ni)', 'へ (he)', 'を (o)'], 'answer': 'で (de)'},
      {
        'type': LessonType.sentenceBuilder,
        'jp': '一緒に京都へ行きませんか',
        'rmj': 'issho ni kyouto e ikimasen ka',
        'words': ['cùng nhau', 'đi', 'đến Kyoto', 'không', 'nhỉ'],
        'answer': 'cùng nhau đi đến Kyoto không nhỉ',
      },
      {'type': LessonType.quiz, 'question': 'Cấu trúc dùng để RỦ RÊ, MỜI MỌC ai đó?', 'options': ['～ませんか (~masen ka)', '～ますか (~masu ka)', '～ましたか (~mashita ka)', '～ません (~masen)'], 'answer': '～ませんか (~masen ka)'},
      {'type': LessonType.listening, 'options': ['いっしょにいきませんか', 'いきましょう', 'ちょっと...', 'いいですね'], 'answer': 'いっしょにいきませんか'},
    ];
  }

  List<Map<String, dynamic>> _getCb6LuyenNoiData() {
    return [
      {
        'type': LessonType.flashCard, 'kanji': 'いいですね', 'hiragana': 'いいですね', 'romaji': 'Ii desu ne', 'meaning': 'Hay quá nhỉ / Được đấy',
        'example_img': 'assets/images/example_iidesune.png',
        'example_jp': '一緒にビールを飲みませんか。いいですね。', 'example_rmj': 'Issho ni bi-ru o nomimasen ka. Ii desu ne.', 'example_vn': 'Cùng uống bia nhé. Được đấy nhỉ.'
      },
      {
        'type': LessonType.flashCard, 'kanji': 'ちょっと...', 'hiragana': 'ちょっと', 'romaji': 'chotto...', 'meaning': 'Có chút... (Cách từ chối khéo)',
        'example_img': 'assets/images/example_chotto.png',
        'example_jp': '今日はちょっと...', 'example_rmj': 'Kyou wa chotto...', 'example_vn': 'Hôm nay thì có chút (không tiện)...'
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'ちょっと休みましょう',
        'rmj': 'chotto yasumimashou',
        'words': ['chúng ta', 'cùng', 'nghỉ ngơi', 'một chút', 'nào'],
        'answer': 'chúng ta cùng nghỉ ngơi một chút nào',
      },
      {'type': LessonType.quiz, 'question': 'Đồng ý lời rủ rê một cách hào hứng, ta dùng?', 'options': ['～ましょう (~mashou)', '～ません (~masen)', 'ちょっと...', 'ちがいます'], 'answer': '～ましょう (~mashou)'},
    ];
  }

  List<Map<String, dynamic>> _getCb6LuyenVietData() {
    return [
      {'type': LessonType.kanjiDraw, 'kanji_word': '食べます', 'kanji_target': '食', 'meaning': 'Thực (Ăn)', 'rmj': 'ta(beru)'},
      {'type': LessonType.kanjiDraw, 'kanji_word': '飲みます', 'kanji_target': '飲', 'meaning': 'Ẩm (Uống)', 'rmj': 'no(mu)'},
      {'type': LessonType.kanjiDraw, 'kanji_word': '見ます', 'kanji_target': '見', 'meaning': 'Kiến (Xem, nhìn)', 'rmj': 'mi(ru)'},
      {'type': LessonType.kanjiDraw, 'kanji_word': '買います', 'kanji_target': '買', 'meaning': 'Mãi (Mua)', 'rmj': 'ka(u)'},
      {'type': LessonType.matching, 'pairs': [{'left': 'Ăn', 'right': '食'}, {'left': 'Uống', 'right': '飲'}, {'left': 'Xem', 'right': '見'}, {'left': 'Mua', 'right': '買'}]},
    ];
  }

  List<Map<String, dynamic>> _getCb6OnTapData() {
    return [
      {'type': LessonType.quiz, 'question': 'Trợ từ đứng sau Nơi chốn để chỉ địa điểm xảy ra hành động?', 'options': ['で (de)', 'に (ni)', 'へ (he)', 'を (o)'], 'answer': 'で (de)'},
      {
        'type': LessonType.sentenceBuilder,
        'jp': '一緒に映画を見ませんか',
        'rmj': 'issho ni eiga o mimasen ka',
        'words': ['cùng nhau', 'xem', 'phim', 'không', 'nhỉ'],
        'answer': 'cùng nhau xem phim không nhỉ',
      },
      {'type': LessonType.vocabQuiz, 'kanji': '卵', 'hiragana': 'たまご', 'romaji': 'tamago', 'options': ['trứng', 'thịt', 'cá', 'rau'], 'answer': 'trứng'},
      {'type': LessonType.kanjiDraw, 'kanji_word': '飲みます', 'kanji_target': '飲', 'meaning': 'Ẩm (Uống)', 'rmj': 'no(mu)'},
      {
        'type': LessonType.vocabSummary,
        'words': [
          {'kanji': '食べます', 'romaji': 'tabemasu', 'meaning': 'Ăn'},
          {'kanji': '飲みます', 'romaji': 'nomimasu', 'meaning': 'Uống'},
          {'kanji': '見ます', 'romaji': 'mimasu', 'meaning': 'Xem'},
          {'kanji': '買います', 'romaji': 'kaimasu', 'meaning': 'Mua'},
          {'kanji': '肉', 'romaji': 'niku', 'meaning': 'Thịt'},
          {'kanji': '魚', 'romaji': 'sakana', 'meaning': 'Cá'},
          {'kanji': '水', 'romaji': 'mizu', 'meaning': 'Nước'},
          {'kanji': '映画', 'romaji': 'eiga', 'meaning': 'Phim ảnh'},
          {'kanji': '一緒に', 'romaji': 'issho ni', 'meaning': 'Cùng nhau'},
        ]
      }
    ];
  }

  // ==========================================
  // DỮ LIỆU CƠ BẢN 7 (CÔNG CỤ, CHO & NHẬN)
  // ==========================================

  List<Map<String, dynamic>> _getCb7LyThuyetData() {
    return [
      {
        'type': LessonType.flashCard, 'kanji': '切ります', 'hiragana': 'きります', 'romaji': 'kirimasu', 'meaning': 'Cắt',
        'example_img': 'assets/images/example_kirimasu.png',
        'example_jp': 'はさみで紙を切ります。', 'example_rmj': 'Hasami de kami o kirimasu.', 'example_vn': 'Tôi cắt giấy bằng kéo.'
      },
      {
        'type': LessonType.flashCard, 'kanji': 'あげます', 'hiragana': 'あげます', 'romaji': 'agemasu', 'meaning': 'Cho, tặng',
        'example_img': 'assets/images/example_agemasu.png',
        'example_jp': '木村さんに花をあげます。', 'example_rmj': 'Kimura-san ni hana o agemasu.', 'example_vn': 'Tôi tặng hoa cho chị Kimura.'
      },
      {
        'type': LessonType.flashCard, 'kanji': 'もらいます', 'hiragana': 'もらいます', 'romaji': 'moraimasu', 'meaning': 'Nhận',
        'example_img': 'assets/images/example_moraimasu.png',
        'example_jp': '父に時計をもらいました。', 'example_rmj': 'Chichi ni tokei o moraimashita.', 'example_vn': 'Tôi đã nhận đồng hồ từ bố.'
      },
      {'type': LessonType.vocabQuiz, 'kanji': '送ります', 'hiragana': 'おくります', 'romaji': 'okurimasu', 'options': ['cắt', 'gửi', 'nhận', 'cho'], 'answer': 'gửi'},
      {'type': LessonType.vocabQuiz, 'kanji': '教えます', 'hiragana': 'おしえます', 'romaji': 'oshiemasu', 'options': ['học', 'dạy', 'hỏi', 'trả lời'], 'answer': 'dạy'},
      {'type': LessonType.matching, 'pairs': [{'left': 'Cắt', 'right': '切ります'}, {'left': 'Cho', 'right': 'あげます'}, {'left': 'Nhận', 'right': 'もらいます'}, {'left': 'Dạy', 'right': '教えます'}]},
    ];
  }

  List<Map<String, dynamic>> _getCb7LuyenTap1Data() {
    return [
      {
        'type': LessonType.flashCard, 'kanji': '手', 'hiragana': 'て', 'romaji': 'te', 'meaning': 'Tay',
        'example_img': 'assets/images/example_te.png',
        'example_jp': '手で食べます。', 'example_rmj': 'Te de tabemasu.', 'example_vn': 'Tôi ăn bằng tay.'
      },
      {'type': LessonType.vocabQuiz, 'kanji': '箸', 'hiragana': 'はし', 'romaji': 'hashi', 'options': ['muỗng', 'đũa', 'nĩa', 'dao'], 'answer': 'đũa'},
      {'type': LessonType.vocabQuiz, 'kanji': 'はさみ', 'hiragana': 'はさみ', 'romaji': 'hasami', 'options': ['kéo', 'dao', 'bút', 'giấy'], 'answer': 'kéo'},
      {'type': LessonType.vocabQuiz, 'kanji': 'パソコン', 'hiragana': 'ぱそこん', 'romaji': 'pasokon', 'options': ['ti vi', 'điện thoại', 'máy tính cá nhân', 'máy ảnh'], 'answer': 'máy tính cá nhân'},
      {'type': LessonType.listening, 'options': ['て', 'はし', 'スプーン', 'ナイフ'], 'answer': 'はし'},
      {'type': LessonType.matching, 'pairs': [{'left': 'Tay', 'right': '手'}, {'left': 'Đũa', 'right': '箸'}, {'left': 'Kéo', 'right': 'はさみ'}, {'left': 'Máy tính', 'right': 'パソコン'}]},
    ];
  }

  List<Map<String, dynamic>> _getCb7LuyenTap2Data() {
    return [
      {
        'type': LessonType.flashCard,
        'kanji': 'で (công cụ)', 'hiragana': 'で', 'romaji': 'de',
        'meaning': 'Trợ từ chỉ CÔNG CỤ (Bằng...)',
        'example_img': 'assets/images/example_te.png',
        'example_jp': 'はさみで紙を切ります。', 'example_rmj': 'Hasami de kami o kirimasu.',
        'example_vn': 'Tôi cắt giấy bằng kéo.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': '日本語で', 'hiragana': 'にほんごで', 'romaji': 'nihongo de',
        'meaning': 'Bằng tiếng Nhật',
        'example_img': 'assets/images/example_te.png',
        'example_jp': '日本語で話します。', 'example_rmj': 'Nihongo de hanashimasu.',
        'example_vn': 'Tôi nói bằng tiếng Nhật.',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': '箸で食べます',
        'rmj': 'hashi de tabemasu',
        'words': ['tôi', 'ăn', 'bằng', 'đũa', 'muỗng'],
        'answer': 'tôi ăn bằng đũa',
      },
      {'type': LessonType.quiz, 'question': 'Trợ từ chỉ CÔNG CỤ / PHƯƠNG TIỆN (Bằng cái gì) là?', 'options': ['で (de)', 'に (ni)', 'を (o)', 'へ (he)'], 'answer': 'で (de)'},
      {
        'type': LessonType.sentenceBuilder,
        'jp': '日本語で手紙を書きます',
        'rmj': 'nihongo de tegami o kakimasu',
        'words': ['tôi', 'viết', 'bức thư', 'bằng', 'tiếng Nhật'],
        'answer': 'tôi viết bức thư bằng tiếng Nhật',
      },
      {'type': LessonType.listening, 'options': ['にほんごでかきます', 'えいごでかきます', 'はしでたべます', 'てでたべます'], 'answer': 'にほんごでかきます'},
    ];
  }

  List<Map<String, dynamic>> _getCb7LuyenTap3Data() {
    return [
      {
        'type': LessonType.sentenceBuilder,
        'jp': '木村さんに花をあげます',
        'rmj': 'kimura-san ni hana o agemasu',
        'words': ['tôi', 'tặng', 'hoa', 'cho', 'chị Kimura'],
        'answer': 'tôi tặng hoa cho chị Kimura',
      },
      {'type': LessonType.quiz, 'question': 'Trợ từ đi sau đối tượng NHẬN HÀNH ĐỘNG (Cho ai, Mượn từ ai) là?', 'options': ['に (ni)', 'で (de)', 'を (o)', 'は (wa)'], 'answer': 'に (ni)'},
      {
        'type': LessonType.sentenceBuilder,
        'jp': '父に時計をもらいました',
        'rmj': 'chichi ni tokei o moraimashita',
        'words': ['tôi', 'đã nhận', 'đồng hồ', 'từ', 'bố'],
        'answer': 'tôi đã nhận đồng hồ từ bố',
      },
      {'type': LessonType.quiz, 'question': 'Dịch: "Tôi gọi điện thoại cho mẹ."', 'options': ['母に電話をかけます', '母で電話をかけます', '母と電話をかけます', '母は電話をかけます'], 'answer': '母に電話をかけます'},
    ];
  }

  List<Map<String, dynamic>> _getCb7LuyenNoiData() {
    return [
      {
        'type': LessonType.flashCard, 'kanji': 'もう', 'hiragana': 'もう', 'romaji': 'mou', 'meaning': 'Đã... rồi',
        'example_img': 'assets/images/example_mou.png',
        'example_jp': 'もう昼ごはんを食べましたか。', 'example_rmj': 'Mou hirugohan o tabemashita ka.', 'example_vn': 'Bạn đã ăn trưa rồi à?'
      },
      {
        'type': LessonType.flashCard, 'kanji': 'まだです', 'hiragana': 'まだです', 'romaji': 'mada desu', 'meaning': 'Vẫn chưa',
        'example_img': 'assets/images/example_mada.png',
        'example_jp': 'いいえ、まだです。', 'example_rmj': 'Iie, mada desu.', 'example_vn': 'Không, tôi vẫn chưa (ăn).'
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'もうレポートを送りました',
        'rmj': 'mou repo-to o okurimashita',
        'words': ['tôi', 'đã', 'gửi', 'báo cáo', 'rồi'],
        'answer': 'tôi đã gửi báo cáo rồi',
      },
      {'type': LessonType.quiz, 'question': 'Phủ định của "Đã làm rồi" trong hội thoại là gì?', 'options': ['まだです', 'ちがいます', 'いいえ、しません', 'いいえ、しませんでした'], 'answer': 'まだです'},
    ];
  }

  List<Map<String, dynamic>> _getCb7LuyenVietData() {
    return [
      {'type': LessonType.kanjiDraw, 'kanji_word': '手', 'kanji_target': '手', 'meaning': 'Thủ (Tay)', 'rmj': 'te'},
      {'type': LessonType.kanjiDraw, 'kanji_word': '紙', 'kanji_target': '紙', 'meaning': 'Chỉ (Giấy)', 'rmj': 'kami / shi'},
      {'type': LessonType.kanjiDraw, 'kanji_word': '花', 'kanji_target': '花', 'meaning': 'Hoa (Bông hoa)', 'rmj': 'hana'},
      {'type': LessonType.kanjiDraw, 'kanji_word': '教えます', 'kanji_target': '教', 'meaning': 'Giáo (Dạy)', 'rmj': 'oshi(eru) / kyou'},
      {'type': LessonType.matching, 'pairs': [{'left': 'Tay', 'right': '手'}, {'left': 'Giấy', 'right': '紙'}, {'left': 'Hoa', 'right': '花'}, {'left': 'Dạy', 'right': '教'}]},
    ];
  }

  List<Map<String, dynamic>> _getCb7OnTapData() {
    return [
      {'type': LessonType.quiz, 'question': 'Trợ từ đi với CÔNG CỤ (Bằng kéo, bằng tiếng Nhật)?', 'options': ['で (de)', 'に (ni)', 'を (o)', 'と (to)'], 'answer': 'で (de)'},
      {
        'type': LessonType.sentenceBuilder,
        'jp': '友達にプレゼントをあげます',
        'rmj': 'tomodachi ni purezento o agemasu',
        'words': ['tôi', 'tặng', 'quà', 'cho', 'bạn bè'],
        'answer': 'tôi tặng quà cho bạn bè',
      },
      {'type': LessonType.vocabQuiz, 'kanji': '箸', 'hiragana': 'はし', 'romaji': 'hashi', 'options': ['đũa', 'muỗng', 'kéo', 'tay'], 'answer': 'đũa'},
      {'type': LessonType.kanjiDraw, 'kanji_word': '手紙', 'kanji_target': '紙', 'meaning': 'Chỉ (Giấy - trong Bức thư)', 'rmj': 'kami / gami'},
      {'type': LessonType.listening, 'options': ['もうたべました', 'まだです', 'もうおわりました', 'これからたべます'], 'answer': 'まだです'},
      {
        'type': LessonType.vocabSummary,
        'words': [
          {'kanji': '切ります', 'romaji': 'kirimasu', 'meaning': 'Cắt'},
          {'kanji': 'あげます', 'romaji': 'agemasu', 'meaning': 'Cho, tặng'},
          {'kanji': 'もらいます', 'romaji': 'moraimasu', 'meaning': 'Nhận'},
          {'kanji': '教えます', 'romaji': 'oshiemasu', 'meaning': 'Dạy'},
          {'kanji': '習います', 'romaji': 'naraimasu', 'meaning': 'Học (từ ai)'},
          {'kanji': '手', 'romaji': 'te', 'meaning': 'Tay'},
          {'kanji': '箸', 'romaji': 'hashi', 'meaning': 'Đũa'},
          {'kanji': 'はさみ', 'romaji': 'hasami', 'meaning': 'Cái kéo'},
          {'kanji': '花', 'romaji': 'hana', 'meaning': 'Bông hoa'},
          {'kanji': 'もう', 'romaji': 'mou', 'meaning': 'Đã... rồi'},
          {'kanji': 'まだです', 'romaji': 'mada desu', 'meaning': 'Vẫn chưa'},
        ]
      }
    ];
  }

  List<Map<String, dynamic>> _getCb8LyThuyetData() {
    return [
      {
        'type': LessonType.flashCard, 'kanji': 'ハンサム（な）', 'hiragana': 'はんさむ', 'romaji': 'hansamu', 'meaning': 'Đẹp trai',
        'example_img': 'assets/images/example_hansamu.png',
        'example_jp': 'ミラーさんはハンサムです。', 'example_rmj': 'Mira-san wa hansamu desu.', 'example_vn': 'Anh Miller đẹp trai.'
      },
      {
        'type': LessonType.flashCard, 'kanji': 'きれい（な）', 'hiragana': 'きれい', 'romaji': 'kirei', 'meaning': 'Đẹp, sạch sẽ',
        'example_img': 'assets/images/example_kirei.png',
        'example_jp': 'きれいな花ですね。', 'example_rmj': 'Kireina hana desu ne.', 'example_vn': 'Bông hoa đẹp quá nhỉ.'
      },
      {
        'type': LessonType.flashCard, 'kanji': '静か（な）', 'hiragana': 'しずか', 'romaji': 'shizuka', 'meaning': 'Yên tĩnh',
        'example_img': 'assets/images/example_shizuka.png',
        'example_jp': 'ここは静かです。', 'example_rmj': 'Koko wa shizuka desu.', 'example_vn': 'Chỗ này yên tĩnh.'
      },
      {'type': LessonType.vocabQuiz, 'kanji': '賑やか', 'hiragana': 'にぎやか', 'romaji': 'nigiyaka', 'options': ['yên tĩnh', 'náo nhiệt', 'nổi tiếng', 'đẹp'], 'answer': 'náo nhiệt'},
      {'type': LessonType.vocabQuiz, 'kanji': '有名', 'hiragana': 'ゆうめい', 'romaji': 'yuumei', 'options': ['đẹp trai', 'náo nhiệt', 'nổi tiếng', 'sạch sẽ'], 'answer': 'nổi tiếng'},
      {'type': LessonType.matching, 'pairs': [{'left': 'Đẹp, sạch', 'right': 'きれい'}, {'left': 'Yên tĩnh', 'right': '静か'}, {'left': 'Nổi tiếng', 'right': '有名'}, {'left': 'Náo nhiệt', 'right': '賑やか'}]},
    ];
  }

  List<Map<String, dynamic>> _getCb8LuyenTap1Data() {
    return [
      {
        'type': LessonType.flashCard, 'kanji': '大きい', 'hiragana': 'おおきい', 'romaji': 'ookii', 'meaning': 'To, lớn',
        'example_img': 'assets/images/example_ookii.png',
        'example_jp': '大きい鞄を買いました。', 'example_rmj': 'Ookii kaban o kaimashita.', 'example_vn': 'Tôi đã mua một cái cặp to.'
      },
      {
        'type': LessonType.flashCard, 'kanji': '小さい', 'hiragana': 'ちいさい', 'romaji': 'chiisai', 'meaning': 'Nhỏ, bé',
        'example_img': 'assets/images/example_chiisai.png',
        'example_jp': 'その車は小さいです。', 'example_rmj': 'Sono kuruma wa chiisai desu.', 'example_vn': 'Chiếc xe đó thì nhỏ.'
      },
      {'type': LessonType.vocabQuiz, 'kanji': '新しい', 'hiragana': 'あたらしい', 'romaji': 'atarashii', 'options': ['cũ', 'mới', 'to', 'nhỏ'], 'answer': 'mới'},
      {'type': LessonType.vocabQuiz, 'kanji': '古い', 'hiragana': 'ふるい', 'romaji': 'furui', 'options': ['cũ', 'mới', 'tốt', 'xấu'], 'answer': 'cũ'},
      {'type': LessonType.vocabQuiz, 'kanji': '暑い', 'hiragana': 'あつい', 'romaji': 'atsui', 'options': ['lạnh', 'nóng', 'mát', 'ấm'], 'answer': 'nóng'},
      {'type': LessonType.listening, 'options': ['おおきい', 'ちいさい', 'あたらしい', 'ふるい'], 'answer': 'あたらしい'},
      {'type': LessonType.matching, 'pairs': [{'left': 'To', 'right': '大きい'}, {'left': 'Nhỏ', 'right': '小さい'}, {'left': 'Mới', 'right': '新しい'}, {'left': 'Cũ', 'right': '古い'}]},
    ];
  }

  List<Map<String, dynamic>> _getCb8LuyenTap2Data() {
    return [
      {
        'type': LessonType.flashCard,
        'kanji': 'い形容詞', 'hiragana': 'おおきい・たかい', 'romaji': 'ookii / takai',
        'meaning': 'Tính từ đuôi I: to lớn / đắt',
        'example_img': 'assets/images/example_ookii.png',
        'example_jp': 'この時計は高いです。', 'example_rmj': 'Kono tokei wa takai desu.',
        'example_vn': 'Cái đồng hồ này đắt.',
      },
      {
        'type': LessonType.flashCard,
        'kanji': 'な形容詞', 'hiragana': 'しずかな', 'romaji': 'shizuka na',
        'meaning': 'Tính từ đuôi NA khi bổ nghĩa danh từ',
        'example_img': 'assets/images/example_shizuka.png',
        'example_jp': 'ここは静かな町です。', 'example_rmj': 'Koko wa shizuka na machi desu.',
        'example_vn': 'Đây là thị trấn yên tĩnh.',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': '日本のカメラは高いです',
        'rmj': 'Nihon no kamera wa takai desu',
        'words': ['máy ảnh', 'của Nhật Bản', 'thì', 'đắt', 'rẻ'],
        'answer': 'máy ảnh của Nhật Bản thì đắt',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'この町は静かじゃありません',
        'rmj': 'Kono machi wa shizuka ja arimasen',
        'words': ['thị trấn', 'này', 'không', 'yên tĩnh', 'đẹp'],
        'answer': 'thị trấn này không yên tĩnh',
      },
      {'type': LessonType.quiz, 'question': 'Cách phủ định tính từ đuôi "i" (ví dụ: takai -> không đắt) là?', 'options': ['takai ja arimasen', 'takakunai desu', 'takakatta desu', 'takai deshita'], 'answer': 'takakunai desu'},
      {'type': LessonType.quiz, 'question': 'Phủ định của いい (tốt) là gì?', 'options': ['いくないです', 'よくないです', 'いいじゃありません', 'いかありません'], 'answer': 'よくないです'},
    ];
  }

  List<Map<String, dynamic>> _getCb8LuyenTap3Data() {
    return [
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'サントスさんは親切な人です',
        'rmj': 'Santosu-san wa shinsetsu na hito desu',
        'words': ['anh Santos', 'là', 'người', 'tốt bụng', 'đẹp trai'],
        'answer': 'anh Santos là người tốt bụng',
      },
      {'type': LessonType.quiz, 'question': 'Từ chỉ mức độ "Rất..." trong tiếng Nhật là?', 'options': ['とても (totemo)', 'あまり (amari)', 'そして (soshite)', 'が (ga)'], 'answer': 'とても (totemo)'},
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'この辞書はあまりよくないです',
        'rmj': 'Kono jisho wa amari yokunai desu',
        'words': ['quyển từ điển', 'này', 'không', 'tốt', 'lắm'],
        'answer': 'quyển từ điển này không tốt lắm',
      },
      {'type': LessonType.quiz, 'question': 'Từ nối hai câu mang ý nghĩa trái ngược "Nhưng..." là?', 'options': ['そして (soshite)', 'が (ga)', 'とても (totemo)', 'どんな (donna)'], 'answer': 'が (ga)'},
    ];
  }

  List<Map<String, dynamic>> _getCb8LuyenNoiData() {
    return [
      {'type': LessonType.vocabQuiz, 'kanji': 'どんな', 'hiragana': 'どんな', 'romaji': 'donna', 'options': ['như thế nào', 'cái gì', 'ở đâu', 'khi nào'], 'answer': 'như thế nào'},
      {
        'type': LessonType.sentenceBuilder,
        'jp': '東京はどんな町ですか',
        'rmj': 'Toukyou wa donna machi desu ka',
        'words': ['Tokyo', 'là', 'thành phố', 'như thế nào', 'đẹp'],
        'answer': 'Tokyo là thành phố như thế nào',
      },
      {'type': LessonType.listening, 'options': ['どんな', 'どれ', 'だれ', 'どこ'], 'answer': 'どんな'},
    ];
  }

  List<Map<String, dynamic>> _getCb8LuyenVietData() {
    return [
      {'type': LessonType.kanjiDraw, 'kanji_word': '大きい', 'kanji_target': '大', 'meaning': 'Đại (To lớn)', 'rmj': 'oo(kii) / dai'},
      {'type': LessonType.kanjiDraw, 'kanji_word': '小さい', 'kanji_target': '小', 'meaning': 'Tiểu (Nhỏ bé)', 'rmj': 'chii(sai) / shou'},
      {'type': LessonType.kanjiDraw, 'kanji_word': '高い', 'kanji_target': '高', 'meaning': 'Cao (Cao, Đắt)', 'rmj': 'taka(i) / kou'},
      {'type': LessonType.kanjiDraw, 'kanji_word': '安い', 'kanji_target': '安', 'meaning': 'An (Rẻ, an toàn)', 'rmj': 'yasu(i) / an'},
      {'type': LessonType.matching, 'pairs': [{'left': 'To', 'right': '大'}, {'left': 'Nhỏ', 'right': '小'}, {'left': 'Cao/Đắt', 'right': '高'}, {'left': 'Rẻ', 'right': '安'}]},
    ];
  }

  List<Map<String, dynamic>> _getCb8OnTapData() {
    return [
      {'type': LessonType.quiz, 'question': 'Tính từ đuôi NA khi bổ nghĩa cho Danh từ thì...', 'options': ['Bỏ NA', 'Giữ nguyên NA', 'Đổi thành I', 'Thêm NO'], 'answer': 'Giữ nguyên NA'},
      {
        'type': LessonType.sentenceBuilder,
        'jp': '富士山はきれいで、高い山です',
        'rmj': 'Fujisan wa kirei de, takai yama desu',
        'words': ['núi Phú Sĩ', 'là', 'ngọn núi', 'đẹp', 'và cao'],
        'answer': 'núi Phú Sĩ là ngọn núi đẹp và cao',
      },
      {'type': LessonType.kanjiDraw, 'kanji_word': '高い', 'kanji_target': '高', 'meaning': 'Cao (Cao, Đắt)', 'rmj': 'taka(i)'},
      {'type': LessonType.listening, 'options': ['とてもいいです', 'あまりよくないです', 'いいです', 'よくないです'], 'answer': 'あまりよくないです'},
      {
        'type': LessonType.vocabSummary,
        'words': [
          {'kanji': 'ハンサム', 'romaji': 'hansamu', 'meaning': 'Đẹp trai'},
          {'kanji': 'きれい', 'romaji': 'kirei', 'meaning': 'Đẹp, sạch'},
          {'kanji': '静か', 'romaji': 'shizuka', 'meaning': 'Yên tĩnh'},
          {'kanji': '有名', 'romaji': 'yuumei', 'meaning': 'Nổi tiếng'},
          {'kanji': '大きい', 'romaji': 'ookii', 'meaning': 'To lớn'},
          {'kanji': '小さい', 'romaji': 'chiisai', 'meaning': 'Nhỏ bé'},
          {'kanji': '新しい', 'romaji': 'atarashii', 'meaning': 'Mới'},
          {'kanji': '古い', 'romaji': 'furui', 'meaning': 'Cũ'},
          {'kanji': '高い', 'romaji': 'takai', 'meaning': 'Cao, đắt'},
          {'kanji': '安い', 'romaji': 'yasui', 'meaning': 'Rẻ'},
          {'kanji': 'どんな', 'romaji': 'donna', 'meaning': 'Như thế nào'},
          {'kanji': 'とても', 'romaji': 'totemo', 'meaning': 'Rất'},
          {'kanji': 'あまり', 'romaji': 'amari', 'meaning': 'Không... lắm'},
        ]
      }
    ];
  }

  // ==========================================
  // DỮ LIỆU CƠ BẢN 9 (SỞ THÍCH, NĂNG LỰC & LÝ DO)
  // ==========================================

  List<Map<String, dynamic>> _getCb9LyThuyetData() {
    return [
      {
        'type': LessonType.flashCard, 'kanji': '好き（な）', 'hiragana': 'すき', 'romaji': 'suki', 'meaning': 'Thích',
        'example_img': 'assets/images/example_suki.png',
        'example_jp': '私はスポーツが好きです。', 'example_rmj': 'Watashi wa supo-tsu ga suki desu.', 'example_vn': 'Tôi thích thể thao.'
      },
      {
        'type': LessonType.flashCard, 'kanji': '嫌い（な）', 'hiragana': 'きらい', 'romaji': 'kirai', 'meaning': 'Ghét',
        'example_img': 'assets/images/example_kirai.png',
        'example_jp': '魚が嫌いです。', 'example_rmj': 'Sakana ga kirai desu.', 'example_vn': 'Tôi ghét cá.'
      },
      {
        'type': LessonType.flashCard, 'kanji': '上手（な）', 'hiragana': 'じょうず', 'romaji': 'jouzu', 'meaning': 'Giỏi',
        'example_img': 'assets/images/example_jouzu.png',
        'example_jp': '彼女は歌が上手です。', 'example_rmj': 'Kanojo wa uta ga jouzu desu.', 'example_vn': 'Cô ấy hát giỏi.'
      },
      {'type': LessonType.vocabQuiz, 'kanji': '下手', 'hiragana': 'へた', 'romaji': 'heta', 'options': ['thích', 'ghét', 'giỏi', 'kém'], 'answer': 'kém'},
      {'type': LessonType.vocabQuiz, 'kanji': '料理', 'hiragana': 'りょうり', 'romaji': 'ryouri', 'options': ['thể thao', 'món ăn / nấu ăn', 'âm nhạc', 'bức tranh'], 'answer': 'món ăn / nấu ăn'},
      {'type': LessonType.matching, 'pairs': [{'left': 'Thích', 'right': '好き'}, {'left': 'Ghét', 'right': '嫌い'}, {'left': 'Giỏi', 'right': '上手'}, {'left': 'Kém', 'right': '下手'}]},
    ];
  }

  List<Map<String, dynamic>> _getCb9LuyenTap1Data() {
    return [
      {
        'type': LessonType.flashCard, 'kanji': '分かります', 'hiragana': 'わかります', 'romaji': 'wakarimasu', 'meaning': 'Hiểu',
        'example_img': 'assets/images/example_wakarimasu.png',
        'example_jp': '日本語が分かります。', 'example_rmj': 'Nihongo ga wakarimasu.', 'example_vn': 'Tôi hiểu tiếng Nhật.'
      },
      {
        'type': LessonType.flashCard, 'kanji': 'あります', 'hiragana': 'あります', 'romaji': 'arimasu', 'meaning': 'Có (Sở hữu)',
        'example_img': 'assets/images/example_arimasu_possession.png',
        'example_jp': '車があります。', 'example_rmj': 'Kuruma ga arimasu.', 'example_vn': 'Tôi có xe hơi.'
      },
      {'type': LessonType.vocabQuiz, 'kanji': '時間', 'hiragana': 'じかん', 'romaji': 'jikan', 'options': ['thời gian', 'tiền bạc', 'cuộc hẹn', 'việc bận'], 'answer': 'thời gian'},
      {'type': LessonType.vocabQuiz, 'kanji': '用事', 'hiragana': 'ようじ', 'romaji': 'youji', 'options': ['cuộc hẹn', 'việc bận', 'thời gian', 'gia đình'], 'answer': 'việc bận'},
      {'type': LessonType.vocabQuiz, 'kanji': '約束', 'hiragana': 'やくそく', 'romaji': 'yakusoku', 'options': ['thời gian', 'việc bận', 'lời hứa, cuộc hẹn', 'công việc'], 'answer': 'lời hứa, cuộc hẹn'},
      {'type': LessonType.listening, 'options': ['わかります', 'あります', 'います', 'ききます'], 'answer': 'わかります'},
      {'type': LessonType.matching, 'pairs': [{'left': 'Hiểu', 'right': '分かります'}, {'left': 'Có', 'right': 'あります'}, {'left': 'Thời gian', 'right': '時間'}, {'left': 'Cuộc hẹn', 'right': '約束'}]},
    ];
  }

  List<Map<String, dynamic>> _getCb9LuyenTap2Data() {
    return [
      {
        'type': LessonType.sentenceBuilder,
        'jp': '私はイタリア料理が好きです',
        'rmj': 'Watashi wa Itaria ryouri ga suki desu',
        'words': ['tôi', 'thì', 'thích', 'món ăn', 'của Ý'],
        'answer': 'tôi thì thích món ăn của Ý',
      },
      {'type': LessonType.quiz, 'question': 'Trợ từ đi trước 好き(Thích), 上手(Giỏi), 分かる(Hiểu), ある(Có) là gì?', 'options': ['を (o)', 'が (ga)', 'に (ni)', 'へ (he)'], 'answer': 'が (ga)'},
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'マリアさんはダンスが上手です',
        'rmj': 'Maria-san wa dansu ga jouzu desu',
        'words': ['chị Maria', 'thì', 'nhảy', 'rất giỏi', 'không giỏi'],
        'answer': 'chị Maria thì nhảy rất giỏi',
      },
      {'type': LessonType.quiz, 'question': 'Hỏi "Thích loại N nào" dùng cấu trúc?', 'options': ['どんな N', 'どれ N', 'なんの N', 'どう N'], 'answer': 'どんな N'},
    ];
  }

  List<Map<String, dynamic>> _getCb9LuyenTap3Data() {
    return [
      {
        'type': LessonType.sentenceBuilder,
        'jp': '英語がよく分かります',
        'rmj': 'Eigo ga yoku wakarimasu',
        'words': ['tôi', 'hiểu', 'rất rõ', 'tiếng Anh', 'tiếng Nhật'],
        'answer': 'tôi hiểu rất rõ tiếng Anh',
      },
      {'type': LessonType.quiz, 'question': 'Từ chỉ mức độ "Hơi hơi, một chút" là?', 'options': ['よく (yoku)', 'だいたい (daitai)', 'すこし (sukoshi)', 'ぜんぜん (zenzen)'], 'answer': 'すこし (sukoshi)'},
      {'type': LessonType.quiz, 'question': 'Từ chỉ mức độ "Hoàn toàn không" (Đi với phủ định) là?', 'options': ['あまり (amari)', 'ぜんぜん (zenzen)', 'よく (yoku)', 'すこし (sukoshi)'], 'answer': 'ぜんぜん (zenzen)'},
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'お金が全然ありません',
        'rmj': 'Okane ga zenzen arimasen',
        'words': ['tôi', 'hoàn toàn', 'không có', 'tiền', 'thời gian'],
        'answer': 'tôi hoàn toàn không có tiền',
      },
    ];
  }

  List<Map<String, dynamic>> _getCb9LuyenNoiData() {
    return [
      {
        'type': LessonType.flashCard, 'kanji': 'から', 'hiragana': 'から', 'romaji': 'kara', 'meaning': 'Vì...',
        'example_img': 'assets/images/example_kara.png',
        'example_jp': '時間がないから、新聞を読みません。', 'example_rmj': 'Jikan ga nai kara, shinbun o yomimasen.', 'example_vn': 'Vì không có thời gian, nên tôi không đọc báo.'
      },
      {'type': LessonType.vocabQuiz, 'kanji': 'どうして', 'hiragana': 'どうして', 'romaji': 'doushite', 'options': ['như thế nào', 'tại sao', 'khi nào', 'ở đâu'], 'answer': 'tại sao'},
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'どうしてきのう早く帰りましたか',
        'rmj': 'Doushite kinou hayaku kaerimashita ka',
        'words': ['tại sao', 'hôm qua', 'bạn lại về', 'sớm', 'vậy'],
        'answer': 'tại sao hôm qua bạn lại về sớm vậy',
      },
      {'type': LessonType.listening, 'options': ['どうしてですか', 'いつですか', 'だれですか', 'どこですか'], 'answer': 'どうしてですか'},
    ];
  }

  List<Map<String, dynamic>> _getCb9LuyenVietData() {
    return [
      {'type': LessonType.kanjiDraw, 'kanji_word': '好き', 'kanji_target': '好', 'meaning': 'Hảo (Thích, tốt)', 'rmj': 'su(ki) / kou'},
      {'type': LessonType.kanjiDraw, 'kanji_word': '歌', 'kanji_target': '歌', 'meaning': 'Ca (Bài hát)', 'rmj': 'uta / ka'},
      {'type': LessonType.kanjiDraw, 'kanji_word': '音', 'kanji_target': '音', 'meaning': 'Âm (Âm thanh)', 'rmj': 'oto / on'},
      {'type': LessonType.kanjiDraw, 'kanji_word': '楽', 'kanji_target': '楽', 'meaning': 'Lạc (Vui vẻ, âm nhạc)', 'rmj': 'tano(shii) / raku'},
      {'type': LessonType.matching, 'pairs': [{'left': 'Thích', 'right': '好'}, {'left': 'Bài hát', 'right': '歌'}, {'left': 'Âm thanh', 'right': '音'}, {'left': 'Vui vẻ', 'right': '楽'}]},
    ];
  }

  List<Map<String, dynamic>> _getCb9OnTapData() {
    return [
      {'type': LessonType.quiz, 'question': 'Trợ từ trước "Arimasu" (Có) là?', 'options': ['を (o)', 'が (ga)', 'に (ni)', 'で (de)'], 'answer': 'が (ga)'},
      {
        'type': LessonType.sentenceBuilder,
        'jp': '約束がありますから、早く帰ります',
        'rmj': 'Yakusoku ga arimasu kara, hayaku kaerimasu',
        'words': ['vì', 'có cuộc hẹn', 'nên', 'tôi về', 'sớm'],
        'answer': 'vì có cuộc hẹn nên tôi về sớm',
      },
      {'type': LessonType.vocabQuiz, 'kanji': '下手', 'hiragana': 'へた', 'romaji': 'heta', 'options': ['giỏi', 'kém', 'thích', 'ghét'], 'answer': 'kém'},
      {'type': LessonType.kanjiDraw, 'kanji_word': '歌', 'kanji_target': '歌', 'meaning': 'Ca (Bài hát)', 'rmj': 'uta'},
      {'type': LessonType.listening, 'options': ['よくわかります', 'だいたいわかります', 'すこしわかります', 'ぜんぜんわかりません'], 'answer': 'ぜんぜんわかりません'},
      {
        'type': LessonType.vocabSummary,
        'words': [
          {'kanji': '好き', 'romaji': 'suki', 'meaning': 'Thích'},
          {'kanji': '嫌い', 'romaji': 'kirai', 'meaning': 'Ghét'},
          {'kanji': '上手', 'romaji': 'jouzu', 'meaning': 'Giỏi'},
          {'kanji': '下手', 'romaji': 'heta', 'meaning': 'Kém'},
          {'kanji': '分かります', 'romaji': 'wakarimasu', 'meaning': 'Hiểu'},
          {'kanji': 'あります', 'romaji': 'arimasu', 'meaning': 'Có (sở hữu)'},
          {'kanji': '時間', 'romaji': 'jikan', 'meaning': 'Thời gian'},
          {'kanji': '約束', 'romaji': 'yakusoku', 'meaning': 'Cuộc hẹn'},
          {'kanji': 'どうして', 'romaji': 'doushite', 'meaning': 'Tại sao'},
          {'kanji': '～から', 'romaji': '~kara', 'meaning': 'Vì...'},
          {'kanji': '全然', 'romaji': 'zenzen', 'meaning': 'Hoàn toàn không...'},
        ]
      }
    ];
  }

  // ==========================================
  // DỮ LIỆU CƠ BẢN 10 (SỰ TỒN TẠI & VỊ TRÍ)
  // ==========================================

  List<Map<String, dynamic>> _getCb10LyThuyetData() {
    return [
      {
        'type': LessonType.flashCard, 'kanji': 'あります', 'hiragana': 'あります', 'romaji': 'arimasu', 'meaning': 'Có (Đồ vật, cây cối)',
        'example_img': 'assets/images/example_arimasu_exist.png',
        'example_jp': 'あそこに机があります。', 'example_rmj': 'Asoko ni tsukue ga arimasu.', 'example_vn': 'Ở đằng kia có cái bàn.'
      },
      {
        'type': LessonType.flashCard, 'kanji': 'います', 'hiragana': 'います', 'romaji': 'imasu', 'meaning': 'Có (Người, động vật)',
        'example_img': 'assets/images/example_imasu.png',
        'example_jp': 'あそこに男の人がいます。', 'example_rmj': 'Asoko ni otoko no hito ga imasu.', 'example_vn': 'Ở đằng kia có người đàn ông.'
      },
      {'type': LessonType.vocabQuiz, 'kanji': 'いろいろ（な）', 'hiragana': 'いろいろ', 'romaji': 'iroiro', 'options': ['to lớn', 'màu sắc', 'nhiều loại / đa dạng', 'ít'], 'answer': 'nhiều loại / đa dạng'},
      {'type': LessonType.quiz, 'question': 'Khi nói "Có quyển sách" ta dùng từ nào?', 'options': ['あります (arimasu)', 'います (imasu)', 'きます (kimasu)', 'いきます (ikimasu)'], 'answer': 'あります (arimasu)'},
      {'type': LessonType.quiz, 'question': 'Khi nói "Có con chó" ta dùng từ nào?', 'options': ['あります (arimasu)', 'います (imasu)', 'きます (kimasu)', 'いきます (ikimasu)'], 'answer': 'います (imasu)'},
      {'type': LessonType.matching, 'pairs': [{'left': 'Có (Vật)', 'right': 'あります'}, {'left': 'Có (Người/ĐV)', 'right': 'います'}, {'left': 'Nhiều loại', 'right': 'いろいろ'}]},
    ];
  }

  List<Map<String, dynamic>> _getCb10LuyenTap1Data() {
    return [
      {
        'type': LessonType.flashCard, 'kanji': '男の人', 'hiragana': 'おとこのひと', 'romaji': 'otoko no hito', 'meaning': 'Người đàn ông',
        'example_img': 'assets/images/example_otokonohito.png',
        'example_jp': '男の人がいます。', 'example_rmj': 'Otoko no hito ga imasu.', 'example_vn': 'Có người đàn ông.'
      },
      {
        'type': LessonType.flashCard, 'kanji': '女の人', 'hiragana': 'おんなのひと', 'romaji': 'onna no hito', 'meaning': 'Người phụ nữ',
        'example_img': 'assets/images/example_onnanohito.png',
        'example_jp': '女の人がいます。', 'example_rmj': 'Onna no hito ga imasu.', 'example_vn': 'Có người phụ nữ.'
      },
      {'type': LessonType.vocabQuiz, 'kanji': '男の子', 'hiragana': 'おとこのこ', 'romaji': 'otoko no ko', 'options': ['người đàn ông', 'bé trai', 'người phụ nữ', 'bé gái'], 'answer': 'bé trai'},
      {'type': LessonType.vocabQuiz, 'kanji': '女の子', 'hiragana': 'おんなのこ', 'romaji': 'onna no ko', 'options': ['người phụ nữ', 'bé gái', 'người đàn ông', 'bé trai'], 'answer': 'bé gái'},
      {'type': LessonType.vocabQuiz, 'kanji': '犬', 'hiragana': 'いぬ', 'romaji': 'inu', 'options': ['con mèo', 'con cá', 'con chó', 'con chim'], 'answer': 'con chó'},
      {'type': LessonType.vocabQuiz, 'kanji': '猫', 'hiragana': 'ねこ', 'romaji': 'neko', 'options': ['con mèo', 'con chó', 'con chim', 'con chuột'], 'answer': 'con mèo'},
      {'type': LessonType.matching, 'pairs': [{'left': 'Đàn ông', 'right': '男の人'}, {'left': 'Phụ nữ', 'right': '女の人'}, {'left': 'Chó', 'right': '犬'}, {'left': 'Mèo', 'right': '猫'}]},
    ];
  }

  List<Map<String, dynamic>> _getCb10LuyenTap2Data() {
    return [
      {
        'type': LessonType.flashCard, 'kanji': '上', 'hiragana': 'うえ', 'romaji': 'ue', 'meaning': 'Trên',
        'example_img': 'assets/images/example_ue.png',
        'example_jp': '机の上に本があります。', 'example_rmj': 'Tsukue no ue ni hon ga arimasu.', 'example_vn': 'Ở trên bàn có sách.'
      },
      {
        'type': LessonType.flashCard, 'kanji': '下', 'hiragana': 'した', 'romaji': 'shita', 'meaning': 'Dưới',
        'example_img': 'assets/images/example_shita.png',
        'example_jp': '机の下に猫がいます。', 'example_rmj': 'Tsukue no shita ni neko ga imasu.', 'example_vn': 'Ở dưới bàn có con mèo.'
      },
      {'type': LessonType.vocabQuiz, 'kanji': '前', 'hiragana': 'まえ', 'romaji': 'mae', 'options': ['trước', 'sau', 'trên', 'dưới'], 'answer': 'trước'},
      {'type': LessonType.vocabQuiz, 'kanji': '後ろ', 'hiragana': 'うしろ', 'romaji': 'ushiro', 'options': ['trước', 'sau', 'phải', 'trái'], 'answer': 'sau'},
      {'type': LessonType.vocabQuiz, 'kanji': '中', 'hiragana': 'なか', 'romaji': 'naka', 'options': ['ngoài', 'giữa', 'trong', 'cạnh'], 'answer': 'trong'},
      {'type': LessonType.vocabQuiz, 'kanji': '外', 'hiragana': 'そと', 'romaji': 'soto', 'options': ['trong', 'ngoài', 'trên', 'dưới'], 'answer': 'ngoài'},
      {'type': LessonType.matching, 'pairs': [{'left': 'Trên', 'right': '上'}, {'left': 'Dưới', 'right': '下'}, {'left': 'Trước', 'right': '前'}, {'left': 'Sau', 'right': '後ろ'}, {'left': 'Trong', 'right': '中'}]},
    ];
  }

  List<Map<String, dynamic>> _getCb10LuyenTap3Data() {
    return [
      {
        'type': LessonType.sentenceBuilder,
        'jp': '庭にだれがいますか',
        'rmj': 'Niwa ni dare ga imasu ka',
        'words': ['ở ngoài sân', 'có', 'ai', 'vậy', 'cái gì'],
        'answer': 'ở ngoài sân có ai vậy',
      },
      {
        'type': LessonType.sentenceBuilder,
        'jp': '箱の中に何がありますか',
        'rmj': 'Hako no naka ni nani ga arimasu ka',
        'words': ['ở', 'trong hộp', 'có', 'cái gì', 'ai'],
        'answer': 'ở trong hộp có cái gì',
      },
      {'type': LessonType.quiz, 'question': 'Trợ từ đi sau Địa điểm để chỉ SỰ TỒN TẠI (Ở đâu có cái gì) là?', 'options': ['に (ni)', 'で (de)', 'へ (he)', 'を (o)'], 'answer': 'に (ni)'},
      {
        'type': LessonType.sentenceBuilder,
        'jp': '公園に猫がいます',
        'rmj': 'Kouen ni neko ga imasu',
        'words': ['ở', 'công viên', 'có', 'con mèo', 'con chó'],
        'answer': 'ở công viên có con mèo',
      },
    ];
  }

  List<Map<String, dynamic>> _getCb10LuyenNoiData() {
    return [
      {'type': LessonType.vocabQuiz, 'kanji': '隣', 'hiragana': 'となり', 'romaji': 'tonari', 'options': ['bên cạnh', 'gần', 'giữa', 'đối diện'], 'answer': 'bên cạnh'},
      {'type': LessonType.vocabQuiz, 'kanji': '近く', 'hiragana': 'ちかく', 'romaji': 'chikaku', 'options': ['xa', 'gần', 'trước', 'sau'], 'answer': 'gần'},
      {'type': LessonType.vocabQuiz, 'kanji': '間', 'hiragana': 'あいだ', 'romaji': 'aida', 'options': ['trong', 'giữa', 'ngoài', 'trên'], 'answer': 'giữa'},
      {
        'type': LessonType.sentenceBuilder,
        'jp': '本屋はスーパーの隣にあります',
        'rmj': 'Honya wa su-pa- no tonari ni arimasu',
        'words': ['hiệu sách', 'thì', 'ở', 'bên cạnh siêu thị', 'trong siêu thị'],
        'answer': 'hiệu sách thì ở bên cạnh siêu thị',
      },
      {'type': LessonType.listening, 'options': ['となりにあります', 'ちかくにあります', 'あいだにあります', 'なかにあります'], 'answer': 'となりにあります'},
    ];
  }

  List<Map<String, dynamic>> _getCb10LuyenVietData() {
    return [
      {'type': LessonType.kanjiDraw, 'kanji_word': '男', 'kanji_target': '男', 'meaning': 'Nam', 'rmj': 'otoko / dan'},
      {'type': LessonType.kanjiDraw, 'kanji_word': '女', 'kanji_target': '女', 'meaning': 'Nữ', 'rmj': 'onna / jo'},
      {'type': LessonType.kanjiDraw, 'kanji_word': '上', 'kanji_target': '上', 'meaning': 'Thượng (Trên)', 'rmj': 'ue / jou'},
      {'type': LessonType.kanjiDraw, 'kanji_word': '下', 'kanji_target': '下', 'meaning': 'Hạ (Dưới)', 'rmj': 'shita / ka'},
      {'type': LessonType.matching, 'pairs': [{'left': 'Nam', 'right': '男'}, {'left': 'Nữ', 'right': '女'}, {'left': 'Thượng', 'right': '上'}, {'left': 'Hạ', 'right': '下'}]},
    ];
  }

  List<Map<String, dynamic>> _getCb10OnTapData() {
    return [
      {'type': LessonType.quiz, 'question': 'Trợ từ dùng khi nói "Có A và B..." là?', 'options': ['や (ya)', 'と (to)', 'も (mo)', 'が (ga)'], 'answer': 'や (ya)'},
      {
        'type': LessonType.sentenceBuilder,
        'jp': '箱の中に手紙や写真があります',
        'rmj': 'Hako no naka ni tegami ya shashin ga arimasu',
        'words': ['ở trong hộp', 'có', 'bức thư', 'và', 'bức ảnh'],
        'answer': 'ở trong hộp có bức thư và bức ảnh',
      },
      {'type': LessonType.vocabQuiz, 'kanji': '犬', 'hiragana': 'いぬ', 'romaji': 'inu', 'options': ['mèo', 'chó', 'chim', 'chuột'], 'answer': 'chó'},
      {'type': LessonType.kanjiDraw, 'kanji_word': '男の人', 'kanji_target': '男', 'meaning': 'Nam', 'rmj': 'otoko'},
      {'type': LessonType.listening, 'options': ['うえにあります', 'したにあります', 'まえにあります', 'うしろにあります'], 'answer': 'したにあります'},
      {
        'type': LessonType.vocabSummary,
        'words': [
          {'kanji': 'あります', 'romaji': 'arimasu', 'meaning': 'Có (Vật, cây cối)'},
          {'kanji': 'います', 'romaji': 'imasu', 'meaning': 'Có (Người, động vật)'},
          {'kanji': '男の人', 'romaji': 'otoko no hito', 'meaning': 'Người đàn ông'},
          {'kanji': '女の人', 'romaji': 'onna no hito', 'meaning': 'Người phụ nữ'},
          {'kanji': '犬', 'romaji': 'inu', 'meaning': 'Con chó'},
          {'kanji': '猫', 'romaji': 'neko', 'meaning': 'Con mèo'},
          {'kanji': '上/下', 'romaji': 'ue/shita', 'meaning': 'Trên/Dưới'},
          {'kanji': '前/後ろ', 'romaji': 'mae/ushiro', 'meaning': 'Trước/Sau'},
          {'kanji': '中/外', 'romaji': 'naka/soto', 'meaning': 'Trong/Ngoài'},
          {'kanji': '隣/近く/間', 'romaji': 'tonari/chikaku/aida', 'meaning': 'Bên cạnh/Gần/Giữa'},
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
    {'type': LessonType.learn, 'char': 'う', 'romaji': 'u', 'gif': 'assets/gifs/u.gif', 'isHiragana': true},
    {'type': LessonType.learn, 'char': 'ウ', 'romaji': 'u (Katakana)', 'gif': 'assets/gifs/uk.gif', 'isHiragana': false},
    {'type': LessonType.learn, 'char': 'え', 'romaji': 'e', 'gif': 'assets/gifs/e.gif', 'isHiragana': true},
    {'type': LessonType.learn, 'char': 'エ', 'romaji': 'e (Katakana)', 'gif': 'assets/gifs/ek.gif', 'isHiragana': false},
    {'type': LessonType.quiz, 'question': 'Chữ nào là "E" (Katakana)?', 'options': ['エ', 'オ', 'え', 'う'], 'answer': 'エ'},
    {'type': LessonType.matching, 'pairs': [{'left': 'あ', 'right': 'ア'}, {'left': 'い', 'right': 'イ'}, {'left': 'う', 'right': 'ウ'}, {'left': 'え', 'right': 'エ'}]},
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
      {'type': LessonType.listening, 'options': ['か', 'き', 'く', 'け'], 'answer': 'か'},
      {'type': LessonType.listening, 'options': ['カ', 'キ', 'ク', 'ケ'], 'answer': 'キ'},
      {'type': LessonType.listening, 'options': ['こ', 'け', 'く', 'き'], 'answer': 'こ'},
      {'type': LessonType.quiz, 'question': 'Chữ nào là "Ki" (Hiragana)?', 'options': ['か', 'き', 'く', 'け'], 'answer': 'き'},
      {'type': LessonType.learn, 'char': 'く', 'romaji': 'ku', 'gif': 'assets/gifs/ku.gif', 'isHiragana': true},
      {'type': LessonType.learn, 'char': 'ク', 'romaji': 'ku (Katakana)', 'gif': 'assets/gifs/kuk.gif', 'isHiragana': false},
      {'type': LessonType.learn, 'char': 'け', 'romaji': 'ke', 'gif': 'assets/gifs/ke.gif', 'isHiragana': true},
      {'type': LessonType.learn, 'char': 'ケ', 'romaji': 'ke (Katakana)', 'gif': 'assets/gifs/kek.gif', 'isHiragana': false},
      {'type': LessonType.quiz, 'question': 'Chữ nào là "Ku" (Katakana)?', 'options': ['ク', 'シ', 'ツ', 'ソ'], 'answer': 'ク'},
      {'type': LessonType.matching, 'pairs': [{'left': 'か', 'right': 'カ'}, {'left': 'き', 'right': 'キ'}, {'left': 'く', 'right': 'ク'}, {'left': 'け', 'right': 'ケ'}]},
      {'type': LessonType.learn, 'char': 'こ', 'romaji': 'ko', 'gif': 'assets/gifs/ko.gif', 'isHiragana': true},
      {'type': LessonType.learn, 'char': 'コ', 'romaji': 'ko (Katakana)', 'gif': 'assets/gifs/kok.gif', 'isHiragana': false},
      {'type': LessonType.quiz, 'question': 'Chữ nào là "Ke" (Hiragana)', 'options': ['け', 'い', 'は', 'ほ'], 'answer': 'け'},
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
      {'type': LessonType.quiz, 'question': 'Chữ nào là "O" (Hiragana)?', 'options': ['あ', 'お', 'す', 'む'], 'answer': 'お'},
      {'type': LessonType.quiz, 'question': 'Chữ nào là "Ki" (Katakana)?', 'options': ['キ', 'チ', 'ミ', 'ニ'], 'answer': 'キ'},
      {'type': LessonType.listening, 'options': ['ぬ', 'ね', 'め', 'の'], 'answer': 'め'},
      {'type': LessonType.listening, 'options': ['わ', 'れ', 'ね', 'る'], 'answer': 'れ'},
      {'type': LessonType.matching, 'pairs': [
        {'left': 'あ', 'right': 'ア'},
        {'left': 'か', 'right': 'カ'},
        {'left': 'さ', 'right': 'サ'},
        {'left': 'た', 'right': 'タ'},
        {'left': 'な', 'right': 'ナ'}
      ]},
      {'type': LessonType.quiz, 'question': 'Chọn chữ "N" (Katakana)', 'options': ['シ', 'ツ', 'ソ', 'ン'], 'answer': 'ン'},
      {'type': LessonType.quiz, 'question': 'Chọn chữ "Shi" (Katakana)', 'options': ['シ', 'ツ', 'ソ', 'ン'], 'answer': 'シ'},
      {'type': LessonType.listening, 'options': ['ハ', 'ヒ', 'フ', 'ヘ'], 'answer': 'フ'},
      {'type': LessonType.listening, 'options': ['マ', 'ミ', 'ム', 'メ'], 'answer': 'ミ'},
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

  void _nextActivity(){
    if (_currentIndex < _activities.length - 1) {
      setState(() {
        _currentIndex++;
      });
      bool isAudioDisabled = LessonScreen.audioDisabledUntil != null &&
          DateTime.now().isBefore(LessonScreen.audioDisabledUntil!);
      if (isAudioDisabled && _activities[_currentIndex]['type'] == LessonType.listening) {
        _nextActivity();
        return;
      }
      _progress = (_currentIndex + 1) / _activities.length;
      _playCurrentAudio();
    } else{
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
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black54),
            onPressed: _showSettingsSheet, // Gọi hàm mở bảng cài đặt
          )
        ],
      ),
      body: SafeArea(
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(AppSettings.textScale),
          ),
          child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: _buildBody(activity)
          ),
        ),
      ),
    );
  }

  double _fontScaleValue = 2.0; // 0, 1, 2 (Mặc định), 3, 4
  double _sfxVolumeValue = 40.0; // Từ 0 đến 100

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
                borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Cỡ chữ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 10),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFF66BB6A),
                      inactiveTrackColor: Colors.grey.shade300,
                      thumbColor: const Color(0xFF66BB6A),
                      tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 5),
                      activeTickMarkColor: const Color(0xFF66BB6A),
                      inactiveTickMarkColor: Colors.black87,
                      trackHeight: 4.0,
                    ),
                    child: Slider(
                      value: tempFontScale,
                      min: 0, max: 4, divisions: 4,
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
                            color: tempFontScale == 2 ? const Color(0xFF58CC02) : Colors.grey,
                            fontWeight: FontWeight.bold
                        )
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text("Âm lượng hiệu ứng âm thanh", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 10),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFF66BB6A),
                      inactiveTrackColor: Colors.grey.shade300,
                      thumbColor: const Color(0xFF66BB6A),
                      tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 5),
                      activeTickMarkColor: const Color(0xFF66BB6A),
                      inactiveTickMarkColor: Colors.black87,
                      trackHeight: 4.0,
                    ),
                    child: Slider(
                      value: tempSfxVolume,
                      min: 0, max: 100, divisions: 4,
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
                        Text("0", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                        Text("25", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                        Text("50", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                        Text("75", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                        Text("100", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),

                  // 3. NÚT LƯU
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        SoundManager.instance.vibrate('light');
                        // SỬA LỖI 3: Lưu thẳng vào AppSettings
                        setState(() {
                          AppSettings.fontScaleValue = tempFontScale;
                          AppSettings.sfxVolumeValue = tempSfxVolume;
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF66BB6A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      child: const Text("Lưu", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
      case LessonType.learn: return _buildLearnView(data);
      case LessonType.quiz: return StandardQuizView(
        data: data,
        onCheckResult: (isCorrect, correctAns, userAns) => _showResultSheet(isCorrect, correctAns, userAns),
      );
      case LessonType.matching: return _buildMatchingView(data);
      case LessonType.imageQuiz: return _buildImageQuizView(data);
      case LessonType.listening:
        return ListeningQuizView(
          data: data,
          onCheckResult: (isCorrect, correctAns, userAns) => _showResultSheet(isCorrect, correctAns, userAns),
        );
      case LessonType.sentenceBuilder:
        return SentenceBuilderView(
            data: data,
            onCheckResult: (isCorrect, correctAns, userAns) => _showResultSheet(isCorrect, correctAns, userAns)
        );
      case LessonType.speaking:
        return SpeakingPracticeView(
          data: data,
          onCheckResult: (isCorrect, correctAns, userAns) => _showResultSheet(isCorrect, correctAns, userAns),
          onSkip: _nextActivity,
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
        return VocabSummaryView(words: data['words'], onNext: _nextActivity, onExit: _finishLesson,);
      default: return const SizedBox();
    }
  }

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

  String _normalize(String s) =>
      s.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

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

class MatchingGame extends StatefulWidget{
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
    SoundManager.instance.vibrate('light');
    setState(() {
      if (isLeft) {
        // Cho phép bấm lại để hủy chọn
        selectedLeft = (selectedLeft == item) ? null : item;
      } else {
        selectedRight = (selectedRight == item) ? null : item;
      }
    });
    _checkMatch();
  }

  void _checkMatch() async {
    if (selectedLeft != null && selectedRight != null) {
      bool isCorrect = widget.pairs.any((pair) => pair['left'] == selectedLeft && pair['right'] == selectedRight);

      if (isCorrect) {
        SoundManager.instance.vibrate('light');
        setState(() {
          matchedItems.add(selectedLeft!);
          matchedItems.add(selectedRight!);
          selectedLeft = null;
          selectedRight = null;
        });

        // Hoàn thành tất cả
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF777777))
        ),
        const SizedBox(height: 30),
        Expanded(
          child: Row(
            children: [
              Expanded(
                  child: ListView(
                      physics: const BouncingScrollPhysics(), // Hiệu ứng cuộn mượt mà
                      children: leftItems.map((item) => _buildCard(item, true)).toList()
                  )
              ),
              const SizedBox(width: 20),
              Expanded(
                  child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: rightItems.map((item) => _buildCard(item, false)).toList()
                  )
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
            borderRadius: BorderRadius.circular(20), // Bo góc tròn xoe
            border: Border.all(color: borderColor, width: 2),
            // Đã xóa hoàn toàn boxShadow
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
                      color: textColor
                  )
              )
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

  // --- BỔ SUNG HÀM NÀY ĐỂ FIX LỖI ---
  // Hàm này tự động chạy mỗi khi Widget mẹ truyền data mới xuống
  @override
  void didUpdateWidget(covariant FlashCardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Nếu dữ liệu của bài học thay đổi (chuyển sang từ tiếp theo)
    if (oldWidget.data != widget.data) {
      setState(() {
        _isFlipped = false; // Bắt buộc thẻ úp lại về mặt trước (từ vựng)
      });
    }
  }
  // ----------------------------------

  // Đổi hàm lật thành dạng Toggle (Lật qua lật lại)
  void _toggleFlip() {
    SoundManager.instance.vibrate('light');
    setState(() {
      _isFlipped = !_isFlipped;
    });

    // Chỉ tự động đọc câu ví dụ khi lật sang mặt sau
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
            onTap: _toggleFlip, // <-- Bấm vào thẻ để lật qua lật lại tuỳ ý
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

        // Nút phía dưới
        SizedBox(
          width: double.infinity, height: 55,
          child: ElevatedButton(
            // Nếu chưa lật, bấm nút này sẽ lật thẻ. Nếu đã lật, bấm sẽ sang bài tiếp.
            onPressed: _isFlipped ? widget.onNext : _toggleFlip,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF58CC02),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 0,
            ),
            child: Text(
                _isFlipped ? "Tiếp tục" : "Lật thẻ", // Chữ đổi linh hoạt theo ngữ cảnh
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)
            ),
          ),
        ),
      ],
    );
  }

  // ================= MẶT TRƯỚC =================
  Widget _buildFront() {
    // 1. CHUẨN HOÁ DỮ LIỆU ĐỂ TRÁNH LỖI CHUỖI RỖNG
    String kanji = widget.data['kanji']?.toString() ?? '';
    String hiragana = widget.data['hiragana']?.toString() ?? '';

    // Nếu có Kanji thì chữ chính là Kanji, không có thì chữ chính là Hiragana
    String mainText = kanji.isNotEmpty ? kanji : hiragana;

    // Chỉ hiện Hiragana nhỏ (Furigana) ở trên nếu có Kanji và Kanji khác Hiragana
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
              Text("《 TỪ MỚI 》", style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF5A6275), fontSize: 16)),
            ],
          ),

          const Spacer(),

          // 2. HIỂN THỊ CHỮ THEO LOGIC MỚI
          if (showFurigana)
            Text(hiragana, style: const TextStyle(fontSize: 20, color: Colors.black54)),

          Text(
              mainText, // Dùng biến mainText đã xử lý ở trên
              style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.black87)
          ),

          const SizedBox(height: 15),
          Text(widget.data['romaji'], style: const TextStyle(fontSize: 18, color: Color(0xFF7A8394))),
          const SizedBox(height: 15),
          Text(widget.data['meaning'], style: const TextStyle(fontSize: 20, color: Colors.black87)),

          const Spacer(),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSoundBtn(Icons.pets, () => SoundManager.instance.speakJapanese(hiragana.isNotEmpty ? hiragana : mainText, isSlow: true)),
              const SizedBox(width: 20),
              _buildSoundBtn(Icons.volume_up, () => SoundManager.instance.speakJapanese(hiragana.isNotEmpty ? hiragana : mainText)),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // ================= MẶT SAU =================
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
          // 1. Badge "Ví dụ"
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
                color: const Color(0xFF9E8A2F),
                borderRadius: BorderRadius.circular(20)
            ),
            child: const Text("Ví dụ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          ),
          const SizedBox(height: 25),

          // 2. Hình ảnh minh họa
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

          // 3. Câu ví dụ tiếng Nhật + Bấm để nghe lại
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
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.data['example_rmj'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Color(0xFF7A8394)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 4. Nghĩa tiếng Việt
          Text(
            widget.data['example_vn'],
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF78C850)),
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
        width: 70, height: 70,
        decoration: const BoxDecoration(
            color: Color(0xFF6B5B15),
            shape: BoxShape.circle
        ),
        child: Icon(icon, color: Colors.white, size: 35),
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

    String kanji = widget.data['kanji']?.toString() ?? '';
    String hiragana = widget.data['hiragana']?.toString() ?? '';

    String mainText = kanji.isNotEmpty ? kanji : hiragana;
    bool showFurigana = kanji.isNotEmpty && kanji != hiragana;

    return Column(
      children: [
        const Text(
            "Chọn nghĩa của từ dưới đây",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF777777))
        ),
        const SizedBox(height: 30),

        // 2. HIỂN THỊ CHỮ THEO LOGIC MỚI
        if (showFurigana)
          Text(hiragana, style: const TextStyle(fontSize: 16, color: Colors.grey)),

        Text(
            mainText, // Dùng biến mainText đã xử lý ở trên
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black87)
        ),
        const SizedBox(height: 8),

        Text(widget.data['romaji'], style: const TextStyle(fontSize: 18, color: Color(0xFF7A8394))),

        const SizedBox(height: 25),

        GestureDetector(
          onTap: () {
            SoundManager.instance.vibrate('light');
            SoundManager.instance.speakJapanese(hiragana.isNotEmpty ? hiragana : mainText);
          },
          child: Container(
            width: 65, height: 65,
            decoration: const BoxDecoration(
                color: Color(0xFFEEF7E8),
                shape: BoxShape.circle
            ),
            child: const Icon(Icons.volume_up, color: Color(0xFF58CC02), size: 35),
          ),
        ),

        const SizedBox(height: 40),

        // 4. Grid đáp án phẳng (Flat Design)
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(), // Tắt cuộn để cố định
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.3 // Tỷ lệ ô chữ nhật mập mạp giống ảnh
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
                    // Màu xanh nhạt khi chọn, màu xám nhạt khi không chọn
                    color: isThisSelected ? const Color(0xFFE5F6D5) : const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(20),
                    // Xóa bỏ hoàn toàn Border và Shadow để làm thiết kế phẳng
                  ),
                  child: Text(
                      options[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          // Màu chữ xanh khi chọn, màu đen khi không chọn
                          color: isThisSelected ? const Color(0xFF58CC02) : Colors.black87
                      )
                  ),
                ),
              );
            },
          ),
        ),

        // 5. Nút Kiểm tra
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity, height: 55,
          child: ElevatedButton(
            onPressed: isSelected ? () {
              String userAns = options[_selectedIndex!];
              bool isCorrect = userAns == widget.data['answer'];
              widget.onCheckResult(isCorrect, widget.data['answer'], userAns);
            } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isSelected ? const Color(0xFF58CC02) : Colors.grey.shade200,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0, // Bỏ bóng đổ của nút
            ),
            child: Text(
                "Kiểm tra", // Viết hoa chữ K giống UI ảnh 1
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.grey.shade400
                )
            ),
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

// ==========================================================
// GIAO DIỆN BÀI TẬP NGHE (MỚI - Chuẩn UX thân thiện)
// ==========================================================
class ListeningQuizView extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function(bool, String, String) onCheckResult;

  const ListeningQuizView({super.key, required this.data, required this.onCheckResult});

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

  // --- HÀM HIỂN THỊ POPUP KHI KHÔNG THỂ NGHE ---
  void _showCantListenDialog() {
    SoundManager.instance.vibrate('light');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFFFFF4C7), // Nền vàng pastel giống thiết kế
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Tự động co hẹp theo nội dung
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

                // Nút "Đồng ý"
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      SoundManager.instance.vibrate('light');
                      LessonScreen.audioDisabledUntil = DateTime.now().add(const Duration(minutes: 15));
                      Navigator.pop(context);
                      widget.onCheckResult(true, widget.data['answer'], widget.data['answer']);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF78C850), // Màu xanh lá mềm
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    child: const Text("Đồng ý", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 15),

                // Nút "Đóng" dạng text
                GestureDetector(
                  onTap: () {
                    SoundManager.instance.vibrate('light');
                    Navigator.pop(context); // Chỉ đóng popup, không làm gì cả
                  },
                  child: const Text(
                      "Đóng",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF78C850))
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  // ---------------------------------------------

  @override
  Widget build(BuildContext context) {
    List<dynamic> options = widget.data['options'];
    bool canCheck = _selectedOption != null;

    return Column(
      children: [
        const Text(
            "Nghe và chọn chữ cái tương ứng",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF777777))
        ),
        const SizedBox(height: 40),

        // Khu vực âm thanh (Loa to & Rùa)
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
            mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 1.1,
            physics: const NeverScrollableScrollPhysics(),
            children: widget.data['options'].map<Widget>((dynamic opt) {

              String kanji = '';
              String hiragana = '';
              String matchValue = '';

              if (opt is String) {
                kanji = opt;
                matchValue = opt;
              } else if (opt is Map) {
                kanji = opt['kanji']?.isNotEmpty == true ? opt['kanji'] : opt['hiragana'];
                hiragana = (opt['kanji']?.isNotEmpty == true && opt['kanji'] != opt['hiragana']) ? opt['hiragana'] : '';
                matchValue = opt['kanji']?.isNotEmpty == true ? opt['kanji'] : opt['hiragana'];
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
                    color: isSelected ? const Color(0xFFE5F6D5) : const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: isSelected ? const Color(0xFF88D847) : Colors.transparent, width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // HIỂN THỊ HIRAGANA NHỎ Ở TRÊN NẾU CÓ KANJI
                      if (hiragana.isNotEmpty)
                        Text(hiragana, style: TextStyle(fontSize: 14, color: isSelected ? const Color(0xFF58CC02) : Colors.grey.shade600)),

                      // HIỂN THỊ KANJI SIÊU TO
                      Text(kanji, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF58CC02) : Colors.black87)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Nút mở Popup Không Thể Nghe
        TextButton(
          onPressed: _showCantListenDialog, // <-- Gọi hàm hiển thị Popup ở đây
          child: const Text("Bạn đang không thể nghe", style: TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.bold)),
        ),

        const SizedBox(height: 10),

        // Nút Kiểm Tra
        SizedBox(
          width: double.infinity, height: 55,
          child: ElevatedButton(
            onPressed: canCheck ? () {
              widget.onCheckResult(_selectedOption == widget.data['answer'], widget.data['answer'], _selectedOption!);
            } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canCheck ? const Color(0xFF58CC02) : Colors.grey.shade200,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Text(
                "KIỂM TRA",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: canCheck ? Colors.white : Colors.grey.shade400)
            ),
          ),
        ),
      ],
    );
  }

  // Widget hỗ trợ vẽ nút loa nhanh gọn
  Widget _buildAudioBtn(IconData icon, double boxSize, double iconSize, bool isSlow) {
    return GestureDetector(
      onTap: () {
        SoundManager.instance.vibrate('light');
        SoundManager.instance.speakJapanese(widget.data['answer'], isSlow: isSlow);
      },
      child: Container(
        width: boxSize, height: boxSize,
        decoration: const BoxDecoration(color: Color(0xFFEEF7E8), shape: BoxShape.circle),
        child: Icon(icon, color: const Color(0xFF58CC02), size: iconSize),
      ),
    );
  }
}

// ==========================================================
// GIAO DIỆN CÂU HỎI TRẮC NGHIỆM CHỮ (MỚI - Flat Design)
// ==========================================================
class StandardQuizView extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function(bool, String, String) onCheckResult;

  const StandardQuizView({super.key, required this.data, required this.onCheckResult});

  @override
  State<StandardQuizView> createState() => _StandardQuizViewState();
}

class _StandardQuizViewState extends State<StandardQuizView> {
  String? _selectedOption;

  @override
  void didUpdateWidget(covariant StandardQuizView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      setState(() => _selectedOption = null); // Reset khi qua câu mới
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> options = widget.data['options'];
    bool canCheck = _selectedOption != null;

    return Column(
      children: [
        const Text(
            "Chọn đáp án đúng",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF777777))
        ),
        const SizedBox(height: 30),

        // Khu vực câu hỏi
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                  widget.data['question'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)
              ),
            ),
            // Nút loa để nghe lại yêu cầu
            GestureDetector(
              onTap: () => SoundManager.instance.speakJapanese(widget.data['answer']),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: Color(0xFFEEF7E8), shape: BoxShape.circle),
                child: const Icon(Icons.volume_up, color: Color(0xFF58CC02), size: 30),
              ),
            ),
          ],
        ),

        const SizedBox(height: 40),

        // Grid đáp án phẳng (Không Romaji theo yêu cầu)
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 1.1,
            physics: const NeverScrollableScrollPhysics(),
            children: widget.data['options'].map<Widget>((dynamic opt) {

              // LOGIC PHÂN TÍCH DỮ LIỆU ĐỂ LẤY KANJI VÀ HIRAGANA
              String kanji = '';
              String hiragana = '';
              String matchValue = '';

              if (opt is String) {
                kanji = opt; // Hỗ trợ bài học cũ
                matchValue = opt;
              } else if (opt is Map) {
                kanji = opt['kanji']?.isNotEmpty == true ? opt['kanji'] : opt['hiragana'];
                hiragana = (opt['kanji']?.isNotEmpty == true && opt['kanji'] != opt['hiragana']) ? opt['hiragana'] : '';
                matchValue = opt['kanji']?.isNotEmpty == true ? opt['kanji'] : opt['hiragana'];
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
                    color: isSelected ? const Color(0xFFE5F6D5) : const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: isSelected ? const Color(0xFF88D847) : Colors.transparent, width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // HIỂN THỊ HIRAGANA NHỎ Ở TRÊN NẾU CÓ KANJI
                      if (hiragana.isNotEmpty)
                        Text(hiragana, style: TextStyle(fontSize: 14, color: isSelected ? const Color(0xFF58CC02) : Colors.grey.shade600)),

                      // HIỂN THỊ KANJI SIÊU TO
                      Text(kanji, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF58CC02) : Colors.black87)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Nút Kiểm tra
        SizedBox(
          width: double.infinity, height: 55,
          child: ElevatedButton(
            onPressed: canCheck ? () {
              widget.onCheckResult(_selectedOption == widget.data['answer'], widget.data['answer'], _selectedOption!);
            } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canCheck ? const Color(0xFF58CC02) : Colors.grey.shade200,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Text(
                "KIỂM TRA",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: canCheck ? Colors.white : Colors.grey.shade400
                )
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================================
// GIAO DIỆN BÀI TẬP LUYỆN NÓI (Nghe và nói lại)
// ==========================================================
class SpeakingPracticeView extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function(bool, String, String) onCheckResult;
  final VoidCallback onSkip;

  const SpeakingPracticeView({
    super.key,
    required this.data,
    required this.onCheckResult,
    required this.onSkip
  });

  @override
  State<SpeakingPracticeView> createState() => _SpeakingPracticeViewState();
}

class _SpeakingPracticeViewState extends State<SpeakingPracticeView> {
  bool _isRecording = false;
  bool _isProcessing = false;

  late final AudioRecorder _audioRecorder;
  String? _audioPath;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  // --- HÀM XỬ LÝ BẤM NÚT (TOGGLE) ---
  void _toggleRecording() {
    if (_isProcessing) return; // Đang chờ AI thì không cho bấm

    if (_isRecording) {
      _stopRecordingAndCheck(); // Đang thu thì dừng và chấm điểm
    } else {
      _startRecording(); // Chưa thu thì bắt đầu
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await Permission.microphone.request().isGranted) {
        final dir = await getTemporaryDirectory();
        _audioPath = '${dir.path}/speech_temp.m4a';

        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: _audioPath!,
        );

        SoundManager.instance.vibrate('light');
        setState(() => _isRecording = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng cấp quyền Micro để thu âm!")));
      }
    } catch (e) {
      debugPrint("Lỗi ghi âm: $e");
    }
  }

  Future<void> _stopRecordingAndCheck() async {
    try {
      final path = await _audioRecorder.stop();
      if (path == null) return;

      SoundManager.instance.vibrate('light');
      setState(() {
        _isRecording = false;
        _isProcessing = true;
      });

      String transcribedText = await _sendToWhisperAPI(path);

      if (!mounted) return;
      setState(() => _isProcessing = false);

      if (transcribedText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Không nghe rõ, vui lòng thử lại!")));
        return;
      }

      // --- LOGIC CHẤM ĐIỂM CHÂM CHƯỚC (FUZZY MATCHING) ---
      String targetAnswer = widget.data['answer'].toString();
      bool isCorrect = _compareJapaneseText(targetAnswer, transcribedText);

      widget.onCheckResult(isCorrect, targetAnswer, transcribedText);

    } catch (e) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi kết nối AI: $e")));
    }
  }

  // Thuật toán so sánh thông minh
  bool _compareJapaneseText(String target, String input) {
    // 1. Lọc bỏ dấu câu và khoảng trắng
    String cleanTarget = target.replaceAll(RegExp(r'[。、！？\s]'), '');
    String cleanInput = input.replaceAll(RegExp(r'[。、！？\s]'), '');

    // 2. Chuẩn hóa các âm dễ nhầm lẫn (Ví dụ: AI có thể nghe Konnichiwa thành Konnichiwa 'わ' thay vì 'は')
    cleanTarget = cleanTarget.replaceAll('こんにちは', 'こんにちわ').replaceAll('こんばんは', 'こんばんわ');
    cleanInput = cleanInput.replaceAll('こんにちは', 'こんにちわ').replaceAll('こんばんは', 'こんばんわ');

    // Nếu giống hệt nhau 100% thì trả về true luôn
    if (cleanTarget == cleanInput) return true;

    // 3. Tính độ giống nhau bằng thuật toán Levenshtein Distance
    double similarity = _calculateSimilarity(cleanTarget, cleanInput);

    // NẾU GIỐNG TỪ 80% TRỞ LÊN LÀ ĐƯỢC CHẤM ĐÚNG (Châm chước sai 1-2 âm do mic/giọng)
    return similarity >= 0.8;
  }

  // Hàm tính tỷ lệ % giống nhau giữa 2 chuỗi
  double _calculateSimilarity(String s1, String s2) {
    if (s1.isEmpty && s2.isEmpty) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    List<List<int>> dp = List.generate(s1.length + 1, (i) => List.filled(s2.length + 1, 0));
    for (int i = 0; i <= s1.length; i++) dp[i][0] = i;
    for (int j = 0; j <= s2.length; j++) dp[0][j] = j;

    for (int i = 1; i <= s1.length; i++) {
      for (int j = 1; j <= s2.length; j++) {
        int cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        dp[i][j] = [dp[i - 1][j] + 1, dp[i][j - 1] + 1, dp[i - 1][j - 1] + cost].reduce((a, b) => a < b ? a : b);
      }
    }

    int maxLength = s1.length > s2.length ? s1.length : s2.length;
    int distance = dp[s1.length][s2.length];
    return (maxLength - distance) / maxLength;
  }

  Future<String> _sendToWhisperAPI(String filePath) async {
    const String apiKey = 'sk-proj-YOUR_OPENAI_API_KEY'; // Nhớ thay API Key vào đây!
    var uri = Uri.parse('https://api.openai.com/v1/audio/transcriptions');
    var request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $apiKey'
      ..fields['model'] = 'whisper-1'
      ..fields['language'] = 'ja'
      ..files.add(await http.MultipartFile.fromPath('file', filePath));

    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    var jsonResponse = jsonDecode(responseData);

    if (response.statusCode == 200) {
      return jsonResponse['text']?.toString().trim() ?? '';
    } else {
      debugPrint("Whisper Error: $responseData");
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
            "Nghe và nói lại câu sau",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF777777))
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
                width: 90, height: 90,
                decoration: const BoxDecoration(color: Color(0xFFEEF7E8), shape: BoxShape.circle),
                child: const Icon(Icons.volume_up, color: Color(0xFF58CC02), size: 45),
              ),
            ),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: () {
                SoundManager.instance.vibrate('light');
                SoundManager.instance.speakJapanese(widget.data['jp'], isSlow: true);
              },
              child: Container(
                width: 60, height: 60,
                decoration: const BoxDecoration(color: Color(0xFFEEF7E8), shape: BoxShape.circle),
                child: const Icon(Icons.pets, color: Color(0xFF58CC02), size: 28),
              ),
            ),
          ],
        ),

        const Spacer(),

        if (_isProcessing)
          const Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Text("AI đang chấm điểm...", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16)),
          ),

        SizedBox(
          height: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // NÚT MICRO ĐÃ ĐƯỢC ĐỔI SANG DẠNG CHẠM (TAP)
              GestureDetector(
                onTap: _toggleRecording,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _isRecording ? 100 : 85,
                  height: _isRecording ? 100 : 85,
                  decoration: BoxDecoration(
                    color: _isProcessing
                        ? Colors.grey
                        : (_isRecording ? const Color(0xFFFF4B4B) : const Color(0xFF78C850)),
                    shape: BoxShape.circle,
                    boxShadow: _isRecording
                        ? [BoxShadow(color: Colors.red.withOpacity(0.4), blurRadius: 20, spreadRadius: 5)]
                        : [],
                  ),
                  child: _isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Icon(_isRecording ? Icons.stop : Icons.mic, color: Colors.white, size: 45),
                ),
              ),

              Positioned(
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    SoundManager.instance.vibrate('light');
                    widget.onSkip();
                  },
                  child: Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300, width: 1.5)
                    ),
                    child: const Icon(Icons.keyboard_double_arrow_right, color: Colors.grey, size: 24),
                  ),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Đổi Text hướng dẫn cho đúng UX mới
        Text(
            _isRecording ? "Bấm lại để dừng" : "Bấm để thu âm",
            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
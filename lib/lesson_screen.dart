import 'package:flutter/material.dart';
import 'sound_manager.dart';
import 'user_progress.dart';
import 'app_settings.dart';
import 'package:path_provider/path_provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

enum LessonType {
  learn, quiz, matching, imageQuiz, sentenceBuilder, kanjiDraw, listening, flashCard, vocabQuiz, vocabSummary, speaking,
  vocabListIntro, grammarListIntro, grammarStructure, grammarUsage, grammarExample
}

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

  Set<String> _wrongAnswers = {};

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
      case 'cb3_lythuyet': _activities = _getCb3LyThuyetData(); break;
      case 'cb3_luyentap1': _activities = _getCb3LuyenTap1Data(); break;
      case 'cb3_luyentap2': _activities = _getCb3LuyenTap2Data(); break;
      case 'cb3_luyentap3': _activities = _getCb3LuyenTap3Data(); break;
      case 'cb3_luyennoi': _activities = _getCb3LuyenNoiData(); break;
      case 'cb3_luyenviet': _activities = _getCb3LuyenVietData(); break;
      case 'cb4_lythuyet': _activities = _getCb4LyThuyetData(); break;
      case 'cb4_luyentap1': _activities = _getCb4LuyenTap1Data(); break;
      case 'cb4_luyentap2': _activities = _getCb4LuyenTap2Data(); break;
      case 'cb4_luyentap3': _activities = _getCb4LuyenTap3Data(); break;
      case 'cb4_luyennoi': _activities = _getCb4LuyenNoiData(); break;
      case 'cb4_luyenviet': _activities = _getCb4LuyenVietData(); break;
      case 'cb5_lythuyet': _activities = _getCb5LyThuyetData(); break;
      case 'cb5_luyentap1': _activities = _getCb5LuyenTap1Data(); break;
      case 'cb5_luyentap2': _activities = _getCb5LuyenTap2Data(); break;
      case 'cb5_luyentap3': _activities = _getCb5LuyenTap3Data(); break;
      case 'cb5_luyennoi': _activities = _getCb5LuyenNoiData(); break;
      case 'cb5_luyenviet': _activities = _getCb5LuyenVietData(); break;
      case 'cb6_lythuyet': _activities = _getCb6LyThuyetData(); break;
      case 'cb6_luyentap1': _activities = _getCb6LuyenTap1Data(); break;
      case 'cb6_luyentap2': _activities = _getCb6LuyenTap2Data(); break;
      case 'cb6_luyentap3': _activities = _getCb6LuyenTap3Data(); break;
      case 'cb6_luyennoi': _activities = _getCb6LuyenNoiData(); break;
      case 'cb6_luyenviet': _activities = _getCb6LuyenVietData(); break;
      case 'cb7_lythuyet': _activities = _getCb7LyThuyetData(); break;
      case 'cb7_luyentap1': _activities = _getCb7LuyenTap1Data(); break;
      case 'cb7_luyentap2': _activities = _getCb7LuyenTap2Data(); break;
      case 'cb7_luyentap3': _activities = _getCb7LuyenTap3Data(); break;
      case 'cb7_luyennoi': _activities = _getCb7LuyenNoiData(); break;
      case 'cb7_luyenviet': _activities = _getCb7LuyenVietData(); break;
      case 'cb8_lythuyet': _activities = _getCb8LyThuyetData(); break;
      case 'cb8_luyentap1': _activities = _getCb8LuyenTap1Data(); break;
      case 'cb8_luyentap2': _activities = _getCb8LuyenTap2Data(); break;
      case 'cb8_luyentap3': _activities = _getCb8LuyenTap3Data(); break;
      case 'cb8_luyennoi': _activities = _getCb8LuyenNoiData(); break;
      case 'cb8_luyenviet': _activities = _getCb8LuyenVietData(); break;
      case 'cb9_lythuyet': _activities = _getCb9LyThuyetData(); break;
      case 'cb9_luyentap1': _activities = _getCb9LuyenTap1Data(); break;
      case 'cb9_luyentap2': _activities = _getCb9LuyenTap2Data(); break;
      case 'cb9_luyentap3': _activities = _getCb9LuyenTap3Data(); break;
      case 'cb9_luyennoi': _activities = _getCb9LuyenNoiData(); break;
      case 'cb9_luyenviet': _activities = _getCb9LuyenVietData(); break;
      case 'cb10_lythuyet': _activities = _getCb10LyThuyetData(); break;
      case 'cb10_luyentap1': _activities = _getCb10LuyenTap1Data(); break;
      case 'cb10_luyentap2': _activities = _getCb10LuyenTap2Data(); break;
      case 'cb10_luyentap3': _activities = _getCb10LuyenTap3Data(); break;
      case 'cb10_luyennoi': _activities = _getCb10LuyenNoiData(); break;
      case 'cb10_luyenviet': _activities = _getCb10LuyenVietData(); break;
      case 'n4_bai1_lythuyet': _activities = _getN4Bai1LyThuyetData(); break;
      case 'n4_bai1_luyentap1': _activities = _getN4Bai1LuyenTap1Data(); break;
      case 'n4_bai1_luyentap2': _activities = _getN4Bai1LuyenTap2Data(); break;
      case 'n4_bai1_luyentap3': _activities = _getN4Bai1LuyenTap3Data(); break;
      case 'n4_bai1_luyennoi': _activities = _getN4Bai1LuyenNoiData(); break;
      case 'n4_bai1_luyenviet': _activities = _getN4Bai1LuyenVietData(); break;

            case 'n4_bai2_lythuyet': _activities = _getN4Bai2LyThuyetData(); break;
            case 'n4_bai2_luyentap1': _activities = _getN4Bai2LuyenTap1Data(); break;
            case 'n4_bai2_luyentap2': _activities = _getN4Bai2LuyenTap2Data(); break;
            case 'n4_bai2_luyentap3': _activities = _getN4Bai2LuyenTap3Data(); break;
            case 'n4_bai2_luyennoi': _activities = _getN4Bai2LuyenNoiData(); break;
            case 'n4_bai2_luyenviet': _activities = _getN4Bai2LuyenVietData(); break;

            case 'n4_bai3_lythuyet': _activities = _getN4Bai3LyThuyetData(); break;
            case 'n4_bai3_luyentap1': _activities = _getN4Bai3LuyenTap1Data(); break;
            case 'n4_bai3_luyentap2': _activities = _getN4Bai3LuyenTap2Data(); break;
            case 'n4_bai3_luyentap3': _activities = _getN4Bai3LuyenTap3Data(); break;
            case 'n4_bai3_luyennoi': _activities = _getN4Bai3LuyenNoiData(); break;
            case 'n4_bai3_luyenviet': _activities = _getN4Bai3LuyenVietData(); break;

            case 'n4_bai4_lythuyet': _activities = _getN4Bai4LyThuyetData(); break;
            case 'n4_bai4_luyentap1': _activities = _getN4Bai4LuyenTap1Data(); break;
            case 'n4_bai4_luyentap2': _activities = _getN4Bai4LuyenTap2Data(); break;
            case 'n4_bai4_luyentap3': _activities = _getN4Bai4LuyenTap3Data(); break;
            case 'n4_bai4_luyennoi': _activities = _getN4Bai4LuyenNoiData(); break;
            case 'n4_bai4_luyenviet': _activities = _getN4Bai4LuyenVietData(); break;

            case 'n4_bai5_lythuyet': _activities = _getN4Bai5LyThuyetData(); break;
            case 'n4_bai5_luyentap1': _activities = _getN4Bai5LuyenTap1Data(); break;
            case 'n4_bai5_luyentap2': _activities = _getN4Bai5LuyenTap2Data(); break;
            case 'n4_bai5_luyentap3': _activities = _getN4Bai5LuyenTap3Data(); break;
            case 'n4_bai5_luyennoi': _activities = _getN4Bai5LuyenNoiData(); break;
            case 'n4_bai5_luyenviet': _activities = _getN4Bai5LuyenVietData(); break;

            case 'n4_bai6_lythuyet': _activities = _getN4Bai6LyThuyetData(); break;
            case 'n4_bai6_luyentap1': _activities = _getN4Bai6LuyenTap1Data(); break;
            case 'n4_bai6_luyentap2': _activities = _getN4Bai6LuyenTap2Data(); break;
            case 'n4_bai6_luyentap3': _activities = _getN4Bai6LuyenTap3Data(); break;
            case 'n4_bai6_luyennoi': _activities = _getN4Bai6LuyenNoiData(); break;
            case 'n4_bai6_luyenviet': _activities = _getN4Bai6LuyenVietData(); break;

            case 'n4_bai7_lythuyet': _activities = _getN4Bai7LyThuyetData(); break;
            case 'n4_bai7_luyentap1': _activities = _getN4Bai7LuyenTap1Data(); break;
            case 'n4_bai7_luyentap2': _activities = _getN4Bai7LuyenTap2Data(); break;
            case 'n4_bai7_luyentap3': _activities = _getN4Bai7LuyenTap3Data(); break;
            case 'n4_bai7_luyennoi': _activities = _getN4Bai7LuyenNoiData(); break;
            case 'n4_bai7_luyenviet': _activities = _getN4Bai7LuyenVietData(); break;

            case 'n4_bai8_lythuyet': _activities = _getN4Bai8LyThuyetData(); break;
            case 'n4_bai8_luyentap1': _activities = _getN4Bai8LuyenTap1Data(); break;
            case 'n4_bai8_luyentap2': _activities = _getN4Bai8LuyenTap2Data(); break;
            case 'n4_bai8_luyentap3': _activities = _getN4Bai8LuyenTap3Data(); break;
            case 'n4_bai8_luyennoi': _activities = _getN4Bai8LuyenNoiData(); break;
            case 'n4_bai8_luyenviet': _activities = _getN4Bai8LuyenVietData(); break;

            case 'n4_bai9_lythuyet': _activities = _getN4Bai9LyThuyetData(); break;
            case 'n4_bai9_luyentap1': _activities = _getN4Bai9LuyenTap1Data(); break;
            case 'n4_bai9_luyentap2': _activities = _getN4Bai9LuyenTap2Data(); break;
            case 'n4_bai9_luyentap3': _activities = _getN4Bai9LuyenTap3Data(); break;
            case 'n4_bai9_luyennoi': _activities = _getN4Bai9LuyenNoiData(); break;
            case 'n4_bai9_luyenviet': _activities = _getN4Bai9LuyenVietData(); break;

            case 'n4_bai10_lythuyet': _activities = _getN4Bai10LyThuyetData(); break;
            case 'n4_bai10_luyentap1': _activities = _getN4Bai10LuyenTap1Data(); break;
            case 'n4_bai10_luyentap2': _activities = _getN4Bai10LuyenTap2Data(); break;
            case 'n4_bai10_luyentap3': _activities = _getN4Bai10LuyenTap3Data(); break;
            case 'n4_bai10_luyennoi': _activities = _getN4Bai10LuyenNoiData(); break;
            case 'n4_bai10_luyenviet': _activities = _getN4Bai10LuyenVietData(); break;
case 'n3_bai1_lythuyet': _activities = _getN3Bai1LyThuyetData(); break;
      case 'n3_bai1_luyentap1': _activities = _getN3Bai1LuyenTap1Data(); break;
      case 'n3_bai1_luyentap2': _activities = _getN3Bai1LuyenTap2Data(); break;
      case 'n3_bai1_luyentap3': _activities = _getN3Bai1LuyenTap3Data(); break;
      case 'n3_bai1_luyennoi': _activities = _getN3Bai1LuyenNoiData(); break;
      case 'n3_bai1_luyenviet': _activities = _getN3Bai1LuyenVietData(); break;

      case 'n3_bai2_lythuyet': _activities = _getN3Bai2LyThuyetData(); break;
      case 'n3_bai2_luyentap1': _activities = _getN3Bai2LuyenTap1Data(); break;
      case 'n3_bai2_luyentap2': _activities = _getN3Bai2LuyenTap2Data(); break;
      case 'n3_bai2_luyentap3': _activities = _getN3Bai2LuyenTap3Data(); break;
      case 'n3_bai2_luyennoi': _activities = _getN3Bai2LuyenNoiData(); break;
      case 'n3_bai2_luyenviet': _activities = _getN3Bai2LuyenVietData(); break;

      case 'n3_bai3_lythuyet': _activities = _getN3Bai3LyThuyetData(); break;
      case 'n3_bai3_luyentap1': _activities = _getN3Bai3LuyenTap1Data(); break;
      case 'n3_bai3_luyentap2': _activities = _getN3Bai3LuyenTap2Data(); break;
      case 'n3_bai3_luyentap3': _activities = _getN3Bai3LuyenTap3Data(); break;
      case 'n3_bai3_luyennoi': _activities = _getN3Bai3LuyenNoiData(); break;
      case 'n3_bai3_luyenviet': _activities = _getN3Bai3LuyenVietData(); break;

      case 'n3_bai4_lythuyet': _activities = _getN3Bai4LyThuyetData(); break;
      case 'n3_bai4_luyentap1': _activities = _getN3Bai4LuyenTap1Data(); break;
      case 'n3_bai4_luyentap2': _activities = _getN3Bai4LuyenTap2Data(); break;
      case 'n3_bai4_luyentap3': _activities = _getN3Bai4LuyenTap3Data(); break;
      case 'n3_bai4_luyennoi': _activities = _getN3Bai4LuyenNoiData(); break;
      case 'n3_bai4_luyenviet': _activities = _getN3Bai4LuyenVietData(); break;

      case 'n3_bai5_lythuyet': _activities = _getN3Bai5LyThuyetData(); break;
      case 'n3_bai5_luyentap1': _activities = _getN3Bai5LuyenTap1Data(); break;
      case 'n3_bai5_luyentap2': _activities = _getN3Bai5LuyenTap2Data(); break;
      case 'n3_bai5_luyentap3': _activities = _getN3Bai5LuyenTap3Data(); break;
      case 'n3_bai5_luyennoi': _activities = _getN3Bai5LuyenNoiData(); break;
      case 'n3_bai5_luyenviet': _activities = _getN3Bai5LuyenVietData(); break;

      case 'n3_bai6_lythuyet': _activities = _getN3Bai6LyThuyetData(); break;
      case 'n3_bai6_luyentap1': _activities = _getN3Bai6LuyenTap1Data(); break;
      case 'n3_bai6_luyentap2': _activities = _getN3Bai6LuyenTap2Data(); break;
      case 'n3_bai6_luyentap3': _activities = _getN3Bai6LuyenTap3Data(); break;
      case 'n3_bai6_luyennoi': _activities = _getN3Bai6LuyenNoiData(); break;
      case 'n3_bai6_luyenviet': _activities = _getN3Bai6LuyenVietData(); break;

      case 'n3_bai7_lythuyet': _activities = _getN3Bai7LyThuyetData(); break;
      case 'n3_bai7_luyentap1': _activities = _getN3Bai7LuyenTap1Data(); break;
      case 'n3_bai7_luyentap2': _activities = _getN3Bai7LuyenTap2Data(); break;
      case 'n3_bai7_luyentap3': _activities = _getN3Bai7LuyenTap3Data(); break;
      case 'n3_bai7_luyennoi': _activities = _getN3Bai7LuyenNoiData(); break;
      case 'n3_bai7_luyenviet': _activities = _getN3Bai7LuyenVietData(); break;

      case 'n3_bai8_lythuyet': _activities = _getN3Bai8LyThuyetData(); break;
      case 'n3_bai8_luyentap1': _activities = _getN3Bai8LuyenTap1Data(); break;
      case 'n3_bai8_luyentap2': _activities = _getN3Bai8LuyenTap2Data(); break;
      case 'n3_bai8_luyentap3': _activities = _getN3Bai8LuyenTap3Data(); break;
      case 'n3_bai8_luyennoi': _activities = _getN3Bai8LuyenNoiData(); break;
      case 'n3_bai8_luyenviet': _activities = _getN3Bai8LuyenVietData(); break;

      case 'n3_bai9_lythuyet': _activities = _getN3Bai9LyThuyetData(); break;
      case 'n3_bai9_luyentap1': _activities = _getN3Bai9LuyenTap1Data(); break;
      case 'n3_bai9_luyentap2': _activities = _getN3Bai9LuyenTap2Data(); break;
      case 'n3_bai9_luyentap3': _activities = _getN3Bai9LuyenTap3Data(); break;
      case 'n3_bai9_luyennoi': _activities = _getN3Bai9LuyenNoiData(); break;
      case 'n3_bai9_luyenviet': _activities = _getN3Bai9LuyenVietData(); break;

      case 'n3_bai10_lythuyet': _activities = _getN3Bai10LyThuyetData(); break;
      case 'n3_bai10_luyentap1': _activities = _getN3Bai10LuyenTap1Data(); break;
      case 'n3_bai10_luyentap2': _activities = _getN3Bai10LuyenTap2Data(); break;
      case 'n3_bai10_luyentap3': _activities = _getN3Bai10LuyenTap3Data(); break;
      case 'n3_bai10_luyennoi': _activities = _getN3Bai10LuyenNoiData(); break;
      case 'n3_bai10_luyenviet': _activities = _getN3Bai10LuyenVietData(); break;
case 'n2_bai1_lythuyet': _activities = _getN2Bai1LyThuyetData(); break;
      case 'n2_bai1_luyentap1': _activities = _getN2Bai1LuyenTap1Data(); break;
      case 'n2_bai1_luyentap2': _activities = _getN2Bai1LuyenTap2Data(); break;
      case 'n2_bai1_luyentap3': _activities = _getN2Bai1LuyenTap3Data(); break;
      case 'n2_bai1_luyennoi': _activities = _getN2Bai1LuyenNoiData(); break;
      case 'n2_bai1_luyenviet': _activities = _getN2Bai1LuyenVietData(); break;

      case 'n2_bai2_lythuyet': _activities = _getN2Bai2LyThuyetData(); break;
      case 'n2_bai2_luyentap1': _activities = _getN2Bai2LuyenTap1Data(); break;
      case 'n2_bai2_luyentap2': _activities = _getN2Bai2LuyenTap2Data(); break;
      case 'n2_bai2_luyentap3': _activities = _getN2Bai2LuyenTap3Data(); break;
      case 'n2_bai2_luyennoi': _activities = _getN2Bai2LuyenNoiData(); break;
      case 'n2_bai2_luyenviet': _activities = _getN2Bai2LuyenVietData(); break;

      case 'n2_bai3_lythuyet': _activities = _getN2Bai3LyThuyetData(); break;
      case 'n2_bai3_luyentap1': _activities = _getN2Bai3LuyenTap1Data(); break;
      case 'n2_bai3_luyentap2': _activities = _getN2Bai3LuyenTap2Data(); break;
      case 'n2_bai3_luyentap3': _activities = _getN2Bai3LuyenTap3Data(); break;
      case 'n2_bai3_luyennoi': _activities = _getN2Bai3LuyenNoiData(); break;
      case 'n2_bai3_luyenviet': _activities = _getN2Bai3LuyenVietData(); break;

      case 'n2_bai4_lythuyet': _activities = _getN2Bai4LyThuyetData(); break;
      case 'n2_bai4_luyentap1': _activities = _getN2Bai4LuyenTap1Data(); break;
      case 'n2_bai4_luyentap2': _activities = _getN2Bai4LuyenTap2Data(); break;
      case 'n2_bai4_luyentap3': _activities = _getN2Bai4LuyenTap3Data(); break;
      case 'n2_bai4_luyennoi': _activities = _getN2Bai4LuyenNoiData(); break;
      case 'n2_bai4_luyenviet': _activities = _getN2Bai4LuyenVietData(); break;

      case 'n2_bai5_lythuyet': _activities = _getN2Bai5LyThuyetData(); break;
      case 'n2_bai5_luyentap1': _activities = _getN2Bai5LuyenTap1Data(); break;
      case 'n2_bai5_luyentap2': _activities = _getN2Bai5LuyenTap2Data(); break;
      case 'n2_bai5_luyentap3': _activities = _getN2Bai5LuyenTap3Data(); break;
      case 'n2_bai5_luyennoi': _activities = _getN2Bai5LuyenNoiData(); break;
      case 'n2_bai5_luyenviet': _activities = _getN2Bai5LuyenVietData(); break;

      case 'n2_bai6_lythuyet': _activities = _getN2Bai6LyThuyetData(); break;
      case 'n2_bai6_luyentap1': _activities = _getN2Bai6LuyenTap1Data(); break;
      case 'n2_bai6_luyentap2': _activities = _getN2Bai6LuyenTap2Data(); break;
      case 'n2_bai6_luyentap3': _activities = _getN2Bai6LuyenTap3Data(); break;
      case 'n2_bai6_luyennoi': _activities = _getN2Bai6LuyenNoiData(); break;
      case 'n2_bai6_luyenviet': _activities = _getN2Bai6LuyenVietData(); break;

      case 'n2_bai7_lythuyet': _activities = _getN2Bai7LyThuyetData(); break;
      case 'n2_bai7_luyentap1': _activities = _getN2Bai7LuyenTap1Data(); break;
      case 'n2_bai7_luyentap2': _activities = _getN2Bai7LuyenTap2Data(); break;
      case 'n2_bai7_luyentap3': _activities = _getN2Bai7LuyenTap3Data(); break;
      case 'n2_bai7_luyennoi': _activities = _getN2Bai7LuyenNoiData(); break;
      case 'n2_bai7_luyenviet': _activities = _getN2Bai7LuyenVietData(); break;

      case 'n2_bai8_lythuyet': _activities = _getN2Bai8LyThuyetData(); break;
      case 'n2_bai8_luyentap1': _activities = _getN2Bai8LuyenTap1Data(); break;
      case 'n2_bai8_luyentap2': _activities = _getN2Bai8LuyenTap2Data(); break;
      case 'n2_bai8_luyentap3': _activities = _getN2Bai8LuyenTap3Data(); break;
      case 'n2_bai8_luyennoi': _activities = _getN2Bai8LuyenNoiData(); break;
      case 'n2_bai8_luyenviet': _activities = _getN2Bai8LuyenVietData(); break;

      case 'n2_bai9_lythuyet': _activities = _getN2Bai9LyThuyetData(); break;
      case 'n2_bai9_luyentap1': _activities = _getN2Bai9LuyenTap1Data(); break;
      case 'n2_bai9_luyentap2': _activities = _getN2Bai9LuyenTap2Data(); break;
      case 'n2_bai9_luyentap3': _activities = _getN2Bai9LuyenTap3Data(); break;
      case 'n2_bai9_luyennoi': _activities = _getN2Bai9LuyenNoiData(); break;
      case 'n2_bai9_luyenviet': _activities = _getN2Bai9LuyenVietData(); break;

      case 'n2_bai10_lythuyet': _activities = _getN2Bai10LyThuyetData(); break;
      case 'n2_bai10_luyentap1': _activities = _getN2Bai10LuyenTap1Data(); break;
      case 'n2_bai10_luyentap2': _activities = _getN2Bai10LuyenTap2Data(); break;
      case 'n2_bai10_luyentap3': _activities = _getN2Bai10LuyenTap3Data(); break;
      case 'n2_bai10_luyennoi': _activities = _getN2Bai10LuyenNoiData(); break;
      case 'n2_bai10_luyenviet': _activities = _getN2Bai10LuyenVietData(); break;
      case 'n1_bai1_lythuyet': _activities = _getN1Bai1LyThuyetData(); break;
            case 'n1_bai1_luyentap1': _activities = _getN1Bai1LuyenTap1Data(); break;
            case 'n1_bai1_luyentap2': _activities = _getN1Bai1LuyenTap2Data(); break;
            case 'n1_bai1_luyentap3': _activities = _getN1Bai1LuyenTap3Data(); break;
            case 'n1_bai1_luyennoi': _activities = _getN1Bai1LuyenNoiData(); break;
            case 'n1_bai1_luyenviet': _activities = _getN1Bai1LuyenVietData(); break;

            case 'n1_bai2_lythuyet': _activities = _getN1Bai2LyThuyetData(); break;
            case 'n1_bai2_luyentap1': _activities = _getN1Bai2LuyenTap1Data(); break;
            case 'n1_bai2_luyentap2': _activities = _getN1Bai2LuyenTap2Data(); break;
            case 'n1_bai2_luyentap3': _activities = _getN1Bai2LuyenTap3Data(); break;
            case 'n1_bai2_luyennoi': _activities = _getN1Bai2LuyenNoiData(); break;
            case 'n1_bai2_luyenviet': _activities = _getN1Bai2LuyenVietData(); break;

            case 'n1_bai3_lythuyet': _activities = _getN1Bai3LyThuyetData(); break;
            case 'n1_bai3_luyentap1': _activities = _getN1Bai3LuyenTap1Data(); break;
            case 'n1_bai3_luyentap2': _activities = _getN1Bai3LuyenTap2Data(); break;
            case 'n1_bai3_luyentap3': _activities = _getN1Bai3LuyenTap3Data(); break;
            case 'n1_bai3_luyennoi': _activities = _getN1Bai3LuyenNoiData(); break;
            case 'n1_bai3_luyenviet': _activities = _getN1Bai3LuyenVietData(); break;

            case 'n1_bai4_lythuyet': _activities = _getN1Bai4LyThuyetData(); break;
            case 'n1_bai4_luyentap1': _activities = _getN1Bai4LuyenTap1Data(); break;
            case 'n1_bai4_luyentap2': _activities = _getN1Bai4LuyenTap2Data(); break;
            case 'n1_bai4_luyentap3': _activities = _getN1Bai4LuyenTap3Data(); break;
            case 'n1_bai4_luyennoi': _activities = _getN1Bai4LuyenNoiData(); break;
            case 'n1_bai4_luyenviet': _activities = _getN1Bai4LuyenVietData(); break;

            case 'n1_bai5_lythuyet': _activities = _getN1Bai5LyThuyetData(); break;
            case 'n1_bai5_luyentap1': _activities = _getN1Bai5LuyenTap1Data(); break;
            case 'n1_bai5_luyentap2': _activities = _getN1Bai5LuyenTap2Data(); break;
            case 'n1_bai5_luyentap3': _activities = _getN1Bai5LuyenTap3Data(); break;
            case 'n1_bai5_luyennoi': _activities = _getN1Bai5LuyenNoiData(); break;
            case 'n1_bai5_luyenviet': _activities = _getN1Bai5LuyenVietData(); break;

            case 'n1_bai6_lythuyet': _activities = _getN1Bai6LyThuyetData(); break;
            case 'n1_bai6_luyentap1': _activities = _getN1Bai6LuyenTap1Data(); break;
            case 'n1_bai6_luyentap2': _activities = _getN1Bai6LuyenTap2Data(); break;
            case 'n1_bai6_luyentap3': _activities = _getN1Bai6LuyenTap3Data(); break;
            case 'n1_bai6_luyennoi': _activities = _getN1Bai6LuyenNoiData(); break;
            case 'n1_bai6_luyenviet': _activities = _getN1Bai6LuyenVietData(); break;

            case 'n1_bai7_lythuyet': _activities = _getN1Bai7LyThuyetData(); break;
            case 'n1_bai7_luyentap1': _activities = _getN1Bai7LuyenTap1Data(); break;
            case 'n1_bai7_luyentap2': _activities = _getN1Bai7LuyenTap2Data(); break;
            case 'n1_bai7_luyentap3': _activities = _getN1Bai7LuyenTap3Data(); break;
            case 'n1_bai7_luyennoi': _activities = _getN1Bai7LuyenNoiData(); break;
            case 'n1_bai7_luyenviet': _activities = _getN1Bai7LuyenVietData(); break;

            case 'n1_bai8_lythuyet': _activities = _getN1Bai8LyThuyetData(); break;
            case 'n1_bai8_luyentap1': _activities = _getN1Bai8LuyenTap1Data(); break;
            case 'n1_bai8_luyentap2': _activities = _getN1Bai8LuyenTap2Data(); break;
            case 'n1_bai8_luyentap3': _activities = _getN1Bai8LuyenTap3Data(); break;
            case 'n1_bai8_luyennoi': _activities = _getN1Bai8LuyenNoiData(); break;
            case 'n1_bai8_luyenviet': _activities = _getN1Bai8LuyenVietData(); break;

            case 'n1_bai9_lythuyet': _activities = _getN1Bai9LyThuyetData(); break;
            case 'n1_bai9_luyentap1': _activities = _getN1Bai9LuyenTap1Data(); break;
            case 'n1_bai9_luyentap2': _activities = _getN1Bai9LuyenTap2Data(); break;
            case 'n1_bai9_luyentap3': _activities = _getN1Bai9LuyenTap3Data(); break;
            case 'n1_bai9_luyennoi': _activities = _getN1Bai9LuyenNoiData(); break;
            case 'n1_bai9_luyenviet': _activities = _getN1Bai9LuyenVietData(); break;

            case 'n1_bai10_lythuyet': _activities = _getN1Bai10LyThuyetData(); break;
            case 'n1_bai10_luyentap1': _activities = _getN1Bai10LuyenTap1Data(); break;
            case 'n1_bai10_luyentap2': _activities = _getN1Bai10LuyenTap2Data(); break;
            case 'n1_bai10_luyentap3': _activities = _getN1Bai10LuyenTap3Data(); break;
            case 'n1_bai10_luyennoi': _activities = _getN1Bai10LuyenNoiData(); break;
            case 'n1_bai10_luyenviet': _activities = _getN1Bai10LuyenVietData(); break;
      default: _activities = [];
    }
  }

  List<Map<String, dynamic>> _getCb1LyThuyetData(){
    return [
      {
        'type': LessonType.vocabListIntro,
        'words': [
          {'kanji': 'こんにちは', 'hiragana': 'こんにちは', 'romaji': 'konnichiwa', 'meaning': 'Xin chào'},
          {'kanji': 'さようなら', 'hiragana': 'さようなら', 'romaji': 'sayounara', 'meaning': 'Tạm biệt'},
          {'kanji': '娘', 'hiragana': 'むすめ', 'romaji': 'musume', 'meaning': 'Con gái'},
          {'kanji': '息子', 'hiragana': 'むすこ', 'romaji': 'musuko', 'meaning': 'Con trai'},
          {'kanji': '父', 'hiragana': 'ちち', 'romaji': 'chichi', 'meaning': 'Bố'},
          {'kanji': '母', 'hiragana': 'はは', 'romaji': 'haha', 'meaning': 'Mẹ'},
          {'kanji': '彼', 'hiragana': 'かれ', 'romaji': 'kare', 'meaning': 'Anh ấy / Bạn trai'},
          {'kanji': '彼女', 'hiragana': 'かのじょ', 'romaji': 'kanojo', 'meaning': 'Cô ấy / Bạn gái'},
          {'kanji': '私', 'hiragana': 'わたし', 'romaji': 'watashi', 'meaning': 'Tôi'},
          {'kanji': 'あなた', 'hiragana': 'あなた', 'romaji': 'anata', 'meaning': 'Bạn / Anh / Chị'},
        ]
      },
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

      {'type': LessonType.vocabQuiz, 'kanji': '', 'hiragana': 'こんにちは', 'romaji': 'konnichiwa', 'options': ['tạm biệt', 'xin chào', 'cảm ơn', 'xin lỗi'], 'answer': 'xin chào'},
      {'type': LessonType.vocabQuiz, 'kanji': '娘', 'hiragana': 'むすめ', 'romaji': 'musume', 'options': ['con trai', 'vợ', 'chồng', 'con gái'], 'answer': 'con gái'},
      {'type': LessonType.listening, 'options': ['こんにちは', 'さようなら', 'むすめ', 'むすこ'], 'answer': 'さようなら'},

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

      {'type': LessonType.vocabQuiz, 'kanji': '母', 'hiragana': 'はは', 'romaji': 'haha', 'options': ['bố', 'mẹ', 'anh trai', 'chị gái'], 'answer': 'mẹ'},
      {'type': LessonType.vocabQuiz, 'kanji': '彼', 'hiragana': 'かれ', 'romaji': 'kare', 'options': ['cô ấy', 'tôi', 'bạn', 'anh ấy'], 'answer': 'anh ấy'},
      {'type': LessonType.listening, 'options': ['ちち', 'はは', 'かれ', 'かのじょ'], 'answer': 'かのじょ'},

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
      {'type': LessonType.vocabQuiz, 'kanji': '私', 'hiragana': 'わたし', 'romaji': 'watashi', 'options': ['bạn', 'cô ấy', 'tôi', 'anh ấy'], 'answer': 'tôi'},
        {'type': LessonType.listening, 'options': ['わたし', 'あなた', 'かれ', 'かのじょ'], 'answer': 'あなた'},

      // NGỮ PHÁP
      {
        'type': LessonType.grammarListIntro,
        'grammars': [
          {'title': 'Danh từ です', 'meaning': 'là ~'},
          {'title': 'Trợ từ 「は」', 'meaning': 'thì, là (chủ ngữ)'},
        ]
      },
      {
        'type': LessonType.grammarStructure,
        'title': 'DANH TỪ です',
        'formula': 'N + です',
        'meaning': 'là ~'
      },
      {
        'type': LessonType.grammarUsage,
        'title': 'DANH TỪ です',
        'notes': [
          '「です」 trong tiếng Nhật thường mang ý nghĩa gần giống với từ "là" trong tiếng Việt. Tuy nhiên thay vì đặt ở giữa câu, tiếng Nhật đặt nó ở cuối câu.',
          '「です」 đặt sau danh từ làm vị ngữ để thể hiện sự phán đoán hoặc khẳng định điều gì đó.',
          'Thể hiện sự lịch sự của người nói đối với người nghe.'
        ]
      },
      {
        'type': LessonType.grammarExample,
        'title': 'DANH TỪ です',
        'img': 'assets/images/example_kim.png',
        'jp': 'キムです。',
        'rmj': 'Kimu desu.',
        'vn': 'Tôi là Kim.'
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
        ]
      }
    ];
  }

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

  List<Map<String, dynamic>> _getCb1LuyenTap2Data() {
    return [
      {
        'type': LessonType.flashCard,
        'kanji': 'Nです', 'hiragana': 'です', 'romaji': 'desu',
        'meaning': 'Ngữ pháp: Danh từ + です (Là ~)',
        'example_img': 'assets/images/example_chichi.png',
        'example_jp': '父です。', 'example_rmj': 'Chichi desu.', 'example_vn': 'Là bố.'
      },
      {
        'type': LessonType.quiz,
        'question': '', // Bỏ trống để UI tự chuyển sang chế độ "Chỉ nghe"
        'audio_text': 'こんにちは、お父さん',
        'options': ['Xin chào, bố.', 'Tôi là bố.'],
        'answer': 'Xin chào, bố.'
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
        'rmj': 'chichi / o tou sa n'
      },

      // === PHẦN 2: NGỮ PHÁP "TRỢ TỪ は" ===
      {
        'type': LessonType.flashCard,
        'kanji': 'N1はN2です', 'hiragana': 'は', 'romaji': 'wa',
        'meaning': 'Ngữ pháp: N1 là N2 (は đóng vai trò trợ từ chủ ngữ)',
        'example_img': 'assets/images/example_watashi.png',
        'example_jp': '私は父です。', 'example_rmj': 'Watashi wa chichi desu.', 'example_vn': 'Tôi là bố.'
      },
      // Hình 1000015511: Hình ảnh
      {
        'type': LessonType.imageQuiz,
        'question': 'tôi.',
        'answerIndex': 0,
        'options': [
          {'img': 'assets/images/example_watashi.png', 'jp': '私', 'rmj': 'watashi'},
          {'img': 'assets/images/example_konbanwa.png', 'jp': 'こんばんは', 'rmj': 'konbanwa'},
          {'img': 'assets/images/example_konnichiwa.png', 'jp': 'こんにちは', 'rmj': 'konnichiwa'},
          {'img': 'assets/images/example_ohayou.png', 'jp': 'おはようございます', 'rmj': 'ohayougozaimasu'},
        ]
      },
      // Hình 1000015513: Dịch câu
      {
        'type': LessonType.quiz,
        'question': '私は父です。',
        'audio_text': '私は父です。',
        'options': ['Tôi là con trai.', 'Xin chào, tôi là bố.', 'Tôi là bố.', 'Xin chào, tôi là con trai.'],
        'answer': 'Tôi là bố.'
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
        'rmj': 'watashi'
      },
      // Hình 1000015521: Luyện nói
      {
        'type': LessonType.speaking,
        'jp': '私は息子です。',
        'answer': '私は息子です。',
      },
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
          {'img': 'assets/images/example_kanojo.png', 'jp': 'かのじょ', 'rmj': 'kanojo'},
          {'img': 'assets/images/example_anata.png', 'jp': 'あなた', 'rmj': 'anata'},
        ]
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
        'answer': '彼女' // Kanojo
      },

      // 3. CÂU HỎI HÌNH ẢNH (Focus: Bạn / Anh / Chị)
      {
        'type': LessonType.imageQuiz,
        'question': 'Bạn / Anh / Chị.',
        'answerIndex': 2,
        'options': [
          {'img': 'assets/images/example_kare.png', 'jp': 'かれ', 'rmj': 'kare'},
          {'img': 'assets/images/example_watashi.png', 'jp': 'わたし', 'rmj': 'watashi'},
          {'img': 'assets/images/example_anata.png', 'jp': 'あなた', 'rmj': 'anata'},
          {'img': 'assets/images/example_haha.png', 'jp': 'はは', 'rmj': 'haha'},
        ]
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
        'answer': '彼' // Kare
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
        'rmj': 'haha'
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
  List<Map<String, dynamic>> _getCb1LuyenNoiData() {
    return [
      // 1. Chào hỏi
      {
        'type': LessonType.speaking,
        'jp': 'こんにちは',
        'answer': 'こんにちは',
      },
      // 2. Bố
      {
        'type': LessonType.speaking,
        'jp': '父',
        'answer': 'ちち', // AI Whisper đôi khi bắt Kanji thành Hiragana, nên để answer là dạng đọc chuẩn nhất
      },
      // 3. Mẹ
      {
        'type': LessonType.speaking,
        'jp': '母',
        'answer': 'はは',
      },
      // 4. Con trai
      {
        'type': LessonType.speaking,
        'jp': '息子',
        'answer': 'むすこ',
      },
      // 5. Con gái
      {
        'type': LessonType.speaking,
        'jp': '娘',
        'answer': 'むすめ',
      },
      // 6. Tôi
      {
        'type': LessonType.speaking,
        'jp': '私',
        'answer': 'わたし',
      },
      // 7. Bạn / Anh / Chị
      {
        'type': LessonType.speaking,
        'jp': 'あなた',
        'answer': 'あなた',
      },
      // 8. Anh ấy
      {
        'type': LessonType.speaking,
        'jp': '彼',
        'answer': 'かれ',
      },
      // 9. Cô ấy
      {
        'type': LessonType.speaking,
        'jp': '彼女',
        'answer': 'かのじょ',
      },
      // 10. Tạm biệt
      {
        'type': LessonType.speaking,
        'jp': 'さようなら',
        'answer': 'さようなら',
      },
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
        'rmj': 'watashi'
      },
      // 2. Tập viết chữ Bố (父)
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '父',
        'kanji_target': '父',
        'meaning': 'Bố (Phụ)',
        'rmj': 'chichi'
      },
      // 3. Tập viết chữ Mẹ (母)
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '母',
        'kanji_target': '母',
        'meaning': 'Mẹ (Mẫu)',
        'rmj': 'haha'
      },
      // 4. Tập viết chữ Con gái (娘)
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '娘',
        'kanji_target': '娘',
        'meaning': 'Con gái (Nương)',
        'rmj': 'musume'
      },
      // 5. Tập viết chữ Tử (trong Con trai - 息子)
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '息子',
        'kanji_target': '子',
        'meaning': 'Tử (Con)',
        'rmj': 'ko / shi'
      },
      // 6. Tập viết chữ Anh ấy (彼)
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '彼',
        'kanji_target': '彼',
        'meaning': 'Anh ấy (Bỉ)',
        'rmj': 'kare'
      },
      // 7. Tập viết chữ Nữ (trong Cô ấy - 彼女)
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '彼女',
        'kanji_target': '女',
        'meaning': 'Nữ (Phụ nữ)',
        'rmj': 'onna / jo'
      },
      // 8. Chốt lại bằng Game ghép Kanji
      {
        'type': LessonType.matching,
        'pairs': [
          {'left': 'Tôi', 'right': '私'},
          {'left': 'Bố', 'right': '父'},
          {'left': 'Mẹ', 'right': '母'},
          {'left': 'Con gái', 'right': '娘'},
          {'left': 'Anh ấy', 'right': '彼'}
        ]
      },
    ];
  }
  List<Map<String, dynamic>> _getCb1OnTapData() {
    List<Map<String, dynamic>> data = [];
    data.addAll(_getLuyenTap1Data());
    data.addAll(_getCb1LuyenTap2Data());
    data.addAll(_getCb1LuyenTap3Data());
    List<Map<String, dynamic>> quizzes = data.where((e) => 
      e['type'] != LessonType.learn && 
      e['type'] != LessonType.flashCard && 
      e['type'] != LessonType.vocabListIntro && 
      e['type'] != LessonType.grammarListIntro && 
      e['type'] != LessonType.grammarStructure && 
      e['type'] != LessonType.grammarUsage && 
      e['type'] != LessonType.grammarExample && 
      e['type'] != LessonType.vocabSummary).toList();
    quizzes.shuffle();
    return quizzes.take(15).toList();
  }

  List<Map<String, dynamic>> _getCb2LyThuyetData() {
    return [
      // ================= PHẦN 1: TỪ VỰNG =================
      {
        'type': LessonType.vocabListIntro,
        'words': [
          {'kanji': 'アメリカ', 'hiragana': 'アメリカ', 'romaji': 'amerika', 'meaning': 'Mỹ'},
          {'kanji': '日本', 'hiragana': 'にほん', 'romaji': 'nihon', 'meaning': 'Nhật Bản'},
          {'kanji': '〜人', 'hiragana': '〜じん', 'romaji': '~jin', 'meaning': 'Hậu tố mang nghĩa "người (nước) ~"'},
          {'kanji': '好き [な]', 'hiragana': 'すき', 'romaji': 'suki [na]', 'meaning': 'Thích (tính từ đuôi な)'},
          {'kanji': '犬', 'hiragana': 'いぬ', 'romaji': 'inu', 'meaning': 'Chó'},
          {'kanji': '猫', 'hiragana': 'ねこ', 'romaji': 'neko', 'meaning': 'Mèo'},
        ]
      },

      // --- NHÓM TỪ 1: QUỐC GIA & NGƯỜI (3 TỪ) ---
      {
        'type': LessonType.flashCard, 'kanji': 'アメリカ', 'hiragana': 'アメリカ', 'romaji': 'amerika', 'meaning': 'Mỹ',
        'example_img': 'assets/images/example_amerika.png',
        'example_jp': 'アメリカから来ました。', 'example_rmj': 'Amerika kara kimashita.', 'example_vn': 'Tôi đến từ Mỹ.'
      },
      {
        'type': LessonType.flashCard, 'kanji': '日本', 'hiragana': 'にほん', 'romaji': 'nihon', 'meaning': 'Nhật Bản',
        'example_img': 'assets/images/example_nihon.png',
        'example_jp': '日本はきれいです。', 'example_rmj': 'Nihon wa kirei desu.', 'example_vn': 'Nhật Bản rất đẹp.'
      },
      {
        'type': LessonType.flashCard, 'kanji': '〜人', 'hiragana': '〜じん', 'romaji': '~jin', 'meaning': 'Người (nước) ~',
        'example_img': 'assets/images/example_jin.png',
        'example_jp': '私はベトナム人です。', 'example_rmj': 'Watashi wa Betonamujin desu.', 'example_vn': 'Tôi là người Việt Nam.'
      },
      {'type': LessonType.vocabQuiz, 'kanji': '日本', 'hiragana': 'にほん', 'romaji': 'nihon', 'options': ['Việt Nam', 'Mỹ', 'Hàn Quốc', 'Nhật Bản'], 'answer': 'Nhật Bản'},
      {'type': LessonType.vocabQuiz, 'kanji': 'アメリカ', 'hiragana': 'アメリカ', 'romaji': 'amerika', 'options': ['Anh', 'Mỹ', 'Pháp', 'Đức'], 'answer': 'Mỹ'},
      {'type': LessonType.listening, 'options': ['アメリカ', 'にほん', 'ベトナム', 'じん'], 'answer': 'にほん'},

      // --- NHÓM TỪ 2: ĐỘNG VẬT & SỞ THÍCH (3 TỪ) ---
      {
        'type': LessonType.flashCard, 'kanji': '好き', 'hiragana': 'すき', 'romaji': 'suki', 'meaning': 'Thích',
        'example_img': 'assets/images/example_suki.png',
        'example_jp': '私はスポーツが好きです。', 'example_rmj': 'Watashi wa supo-tsu ga suki desu.', 'example_vn': 'Tôi thích thể thao.'
      },
      {
        'type': LessonType.flashCard, 'kanji': '犬', 'hiragana': 'いぬ', 'romaji': 'inu', 'meaning': 'Chó',
        'example_img': 'assets/images/example_inu.png',
        'example_jp': '犬が可愛いです。', 'example_rmj': 'Inu ga kawaii desu.', 'example_vn': 'Con chó thật dễ thương.'
      },
      {
        'type': LessonType.flashCard, 'kanji': '猫', 'hiragana': 'ねこ', 'romaji': 'neko', 'meaning': 'Mèo',
        'example_img': 'assets/images/example_neko.png',
        'example_jp': '猫がいます。', 'example_rmj': 'Neko ga imasu.', 'example_vn': 'Có con mèo.'
      },
      {'type': LessonType.vocabQuiz, 'kanji': '犬', 'hiragana': 'いぬ', 'romaji': 'inu', 'options': ['mèo', 'chó', 'chim', 'cá'], 'answer': 'chó'},
      {'type': LessonType.vocabQuiz, 'kanji': '好き', 'hiragana': 'すき', 'romaji': 'suki', 'options': ['ghét', 'đẹp', 'thích', 'tốt'], 'answer': 'thích'},
      {'type': LessonType.listening, 'options': ['いぬ', 'ねこ', 'すき', 'きらい'], 'answer': 'ねこ'},

      // ================= PHẦN 2: NGỮ PHÁP =================
      {
        'type': LessonType.grammarListIntro,
        'grammars': [
          {'title': 'Danh từ じゃありません', 'meaning': 'không phải là ~'},
          {'title': 'Hậu tố chỉ số nhiều「〜たち」', 'meaning': 'các ~, những ~'},
          {'title': 'Hậu tố chỉ số nhiều「〜ら」', 'meaning': 'bọn ~, các ~'},
          {'title': 'Tính từ です / じゃありません', 'meaning': 'thì ~ / thì không ~'},
          {'title': 'Trợ từ「も」', 'meaning': 'cũng ~'},
        ]
      },

      // NGỮ PHÁP 1: Danh từ じゃありません
      {
        'type': LessonType.grammarStructure,
        'title': 'DANH TỪ じゃありません',
        'formula': 'N + じゃありません',
        'meaning': 'Không phải là ~'
      },
      {
        'type': LessonType.grammarUsage,
        'title': 'DANH TỪ じゃありません',
        'notes': [
          'Dùng để phủ định một danh từ, mang ý nghĩa "không phải là...".',
          'Đây là dạng phủ định của 「です」.',
          'Trong văn nói trang trọng hoặc văn viết, người ta hay dùng 「ではありません」 (dewa arimasen).'
        ]
      },
      {
        'type': LessonType.grammarExample,
        'title': 'DANH TỪ じゃありません',
        'img': 'assets/images/example_ja_arimasen.png',
        'jp': '私はアメリカ人じゃありません。',
        'rmj': 'Watashi wa Amerikajin ja arimasen.',
        'vn': 'Tôi không phải là người Mỹ.'
      },

      // NGỮ PHÁP 2: Hậu tố 〜たち
      {
        'type': LessonType.grammarStructure,
        'title': 'HẬU TỐ「〜たち」',
        'formula': 'N (người) + たち',
        'meaning': 'Các ~, những ~ (Số nhiều)'
      },
      {
        'type': LessonType.grammarUsage,
        'title': 'HẬU TỐ「〜たち」',
        'notes': [
          'Thêm vào sau danh từ hoặc đại từ chỉ người để biểu thị số nhiều.',
          'Ví dụ phổ biến: 私 (Tôi) ➔ 私たち (Chúng tôi).',
          'Lưu ý: Không dùng 「たち」 cho đồ vật vô tri vô giác.'
        ]
      },
      {
        'type': LessonType.grammarExample,
        'title': 'HẬU TỐ「〜たち」',
        'img': 'assets/images/example_watashitachi.png',
        'jp': '私たちは日本人です。',
        'rmj': 'Watashitachi wa Nihonjin desu.',
        'vn': 'Chúng tôi là người Nhật Bản.'
      },

      // NGỮ PHÁP 3: Hậu tố 〜ら
      {
        'type': LessonType.grammarStructure,
        'title': 'HẬU TỐ「〜ら」',
        'formula': 'Đại từ + ら',
        'meaning': 'Bọn ~, các ~ (Số nhiều)'
      },
      {
        'type': LessonType.grammarUsage,
        'title': 'HẬU TỐ「〜ら」',
        'notes': [
          'Tương tự như 「〜たち」, hậu tố này cũng dùng để chỉ số nhiều.',
          'Thường được gắn cố định với một số đại từ nhất định. Ví dụ: 彼 (Kare - anh ấy) ➔ 彼ら (Karera - bọn họ).',
        ]
      },
      {
        'type': LessonType.grammarExample,
        'title': 'HẬU TỐ「〜ら」',
        'img': 'assets/images/example_karera.png',
        'jp': '彼らはアメリカ人です。',
        'rmj': 'Karera wa Amerikajin desu.',
        'vn': 'Bọn họ là người Mỹ.'
      },

      // NGỮ PHÁP 4: Tính từ です / じゃありません
      {
        'type': LessonType.grammarStructure,
        'title': 'TÍNH TỪ です / じゃありません',
        'formula': 'Tính từ (đuôi な) + です / じゃありません',
        'meaning': 'Thì ~ / Thì không ~'
      },
      {
        'type': LessonType.grammarUsage,
        'title': 'TÍNH TỪ です / じゃありません',
        'notes': [
          'Khác với tiếng Việt, tính từ trong tiếng Nhật cũng phải chia thì giống như Động từ và Danh từ.',
          'Khi khẳng định một đặc điểm ở hiện tại, ta thêm 「です」.',
          'Khi phủ định (đối với tính từ đuôi な như 好き), ta dùng 「じゃありません」 (Thì không thích).'
        ]
      },
      {
        'type': LessonType.grammarExample,
        'title': 'TÍNH TỪ です / じゃありません',
        'img': 'assets/images/example_suki.png',
        'jp': '私は猫が好きじゃありません。',
        'rmj': 'Watashi wa neko ga suki ja arimasen.',
        'vn': 'Tôi thì không thích mèo.'
      },

      // NGỮ PHÁP 5: Trợ từ も
      {
        'type': LessonType.grammarStructure,
        'title': 'TRỢ TỪ「も」',
        'formula': 'N + も',
        'meaning': 'Cũng ~'
      },
      {
        'type': LessonType.grammarUsage,
        'title': 'TRỢ TỪ「も」',
        'notes': [
          'Trợ từ 「も」 được dùng để thay thế hoàn toàn cho trợ từ 「は」.',
          'Nó mang ý nghĩa tương đồng với một sự vật, sự việc đã được nhắc đến trước đó (N cũng...).',
        ]
      },
      {
        'type': LessonType.grammarExample,
        'title': 'TRỢ TỪ「も」',
        'img': 'assets/images/example_mo.png',
        'jp': '私も犬が好きです。',
        'rmj': 'Watashi mo inu ga suki desu.',
        'vn': 'Tôi CŨNG thích chó.'
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
        ]
      }
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
          {'img': 'assets/images/example_amerika.png', 'jp': 'アメリカ', 'rmj': 'amerika'},
          {'img': 'assets/images/example_nihon.png', 'jp': '日本', 'rmj': 'nihon'},
          {'img': 'assets/images/example_inu.png', 'jp': '犬', 'rmj': 'inu'},
          {'img': 'assets/images/example_jin.png', 'jp': '人', 'rmj': 'jin'},
        ]
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
        'answer': '日本'
      },
      // 3. Hình ảnh: Người (nước) ~
      {
        'type': LessonType.imageQuiz,
        'question': 'Hậu tố "người (nước)".',
        'answerIndex': 3,
        'options': [
          {'img': 'assets/images/example_nihon.png', 'jp': '日本', 'rmj': 'nihon'},
          {'img': 'assets/images/example_amerika.png', 'jp': 'アメリカ', 'rmj': 'amerika'},
          {'img': 'assets/images/example_chichi.png', 'jp': '父', 'rmj': 'chichi'},
          {'img': 'assets/images/example_jin.png', 'jp': '人', 'rmj': 'jin'},
        ]
      },
      // 4. Trắc nghiệm chữ: アメリカ
      {
        'type': LessonType.vocabQuiz,
        'kanji': 'アメリカ', 'hiragana': 'アメリカ', 'romaji': 'amerika',
        'options': ['Mỹ', 'Nhật Bản', 'Việt Nam', 'Hàn Quốc'],
        'answer': 'Mỹ'
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
          {'kanji': '私はアメリカ人です。', 'hiragana': 'わたしはアメリカ人です。'}
        ],
        'answer': '私はアメリカ人じゃありません。'
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
          {'kanji': '彼女は母です。', 'hiragana': 'かのじょは母です。'}
        ],
        'answer': '彼女は母じゃありません。'
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
        'rmj': 'jin'
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
          {'img': 'assets/images/example_watashitachi.png', 'jp': '私たち', 'rmj': 'watashitachi'},
        ]
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
        'answer': '犬'
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
          {'img': 'assets/images/example_nihon.png', 'jp': '日本', 'rmj': 'nihon'},
        ]
      },
      // 4. Trắc nghiệm chữ: Chúng tôi (Ứng dụng たち)
      {
        'type': LessonType.vocabQuiz,
        'kanji': '私たち', 'hiragana': 'わたしたち', 'romaji': 'watashitachi',
        'options': ['các bạn', 'chúng tôi', 'bọn họ', 'bạn bè'],
        'answer': 'chúng tôi'
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
          {'kanji': '私たちは犬が好きです。', 'hiragana': 'わたしたちはいぬがすきです。'}
        ],
        'answer': '私たちは犬が好きです。'
      },
      // 6. Đọc và dịch câu: Các bạn là học sinh
      {
        'type': LessonType.sentenceBuilder,
        'jp': 'あなたたちは学生です。',
        'rmj': 'Anatatachi wa gakusei desu.',
        'audio_text': 'あなたたちは学生です。',
        'words': ['các bạn', 'là', 'học sinh', 'giáo viên', 'chúng tôi', 'không phải'],
        'answer': 'các bạn là học sinh',
      },
      // 7. Nghe và chọn câu: Chúng tôi không phải là người Mỹ
      {
        'type': LessonType.quiz,
        'question': 'Chúng tôi không phải là người Mỹ.',
        'audio_text': '私たちはアメリカ人じゃありません。',
        'options': [
          {'kanji': '私たちはアメリカ人じゃありません。', 'hiragana': 'わたしたちはアメリカ人じゃありません。'},
          {'kanji': '私たちは日本人じゃありません。', 'hiragana': 'わたしたちは日本人じゃありません。'}
        ],
        'answer': '私たちはアメリカ人じゃありません。'
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
      {
        'type': LessonType.speaking,
        'jp': '犬が好きです',
        'answer': 'いぬがすきです',
      },
      // 14. Luyện nói: Chúng tôi
      {
        'type': LessonType.speaking,
        'jp': '私たち',
        'answer': 'わたしたち',
      },
      // 15. Vẽ Kanji: Chữ Khuyển (犬)
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '犬',
        'kanji_target': '犬',
        'meaning': 'Khuyển (Chó)',
        'rmj': 'inu'
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
        'answer': 'も (mo)'
      },
      // 2. Điền từ (Gây nhiễu は và も)
      {
        'type': LessonType.quiz,
        'question': 'Điền trợ từ: \n私は日本人です。彼 ( ... ) 日本人です。',
        'options': ['は', 'も', 'が', 'に'],
        'answer': 'も'
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
        'words': ['彼', 'ら', 'も', 'アメリカ', '人', 'です', 'は', 'たち'], // Nhiễu "は" và "たち"
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
          'Bọn họ cũng không phải người Nhật Bản.'
        ],
        'answer': 'Chúng tôi cũng không phải người Nhật Bản.'
      },
      // 6. Ghép câu tiếng Nhật (Ẩn chữ): Cô ấy cũng không phải là người Mỹ
      {
        'type': LessonType.sentenceBuilder,
        'jp': '',
        'rmj': '',
        'audio_text': '彼女もアメリカ人じゃありません。',
        'words': ['彼女', 'も', 'アメリカ', '人', 'じゃありません', 'は', 'です'], // Nhiễu "は" và "です"
        'answer': '彼女 も アメリカ 人 じゃありません',
      },
      // 7. Nghe chọn đáp án tiếng Nhật (Phân biệt Bạn / Anh ấy / Tôi)
      {
        'type': LessonType.listening,
        'options': [
          {'kanji': '彼も日本人ですか。', 'hiragana': 'かれもにほんじんですか。'},
          {'kanji': 'あなたも日本人ですか。', 'hiragana': 'あなたもにほんじんですか。'},
          {'kanji': '私も日本人です。', 'hiragana': 'わたしもにほんじんです。'}
        ],
        'answer': 'あなたも日本人ですか。' // Bạn cũng là người Nhật à?
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
        'words': ['彼', 'ら', 'も', 'アメリカ', '人', 'じゃありません', 'たち'], // Phân biệt ら và たち
        'answer': '彼 ら も アメリカ 人 じゃありません',
      },
      // 11. Nghe và chọn câu tương ứng (So sánh は và も)
      {
        'type': LessonType.quiz,
        'question': 'Tôi cũng thích chó.',
        'audio_text': '私も犬が好きです。',
        'options': [
          {'kanji': '私は犬が好きです。', 'hiragana': 'わたしはいぬがすきです。'},
          {'kanji': '私も犬が好きです。', 'hiragana': 'わたしもいぬがすきです。'}
        ],
        'answer': '私も犬が好きです。'
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
      {
        'type': LessonType.speaking,
        'jp': '私も好きです',
        'answer': 'わたしもすきです',
      },
      // 14. Vẽ Kanji: 猫 (Mèo)
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '猫',
        'kanji_target': '猫',
        'meaning': 'Miêu (Mèo)',
        'rmj': 'neko'
      },
      // 15. Vẽ Kanji: 好き (Thích)
      {
        'type': LessonType.kanjiDraw,
        'kanji_word': '好き',
        'kanji_target': '好',
        'meaning': 'Hảo (Thích)',
        'rmj': 'su(ki)'
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
          'rmj': 'ni'
        },
        // 2. Chữ Bản
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '日本',
          'kanji_target': '本',
          'meaning': 'Bản (Gốc / Sách)',
          'rmj': 'hon'
        },
        // 3. Chữ Nhân
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '〜人',
          'kanji_target': '人',
          'meaning': 'Nhân (Người)',
          'rmj': 'jin / hito'
        },
        // 4. Chữ Khuyển
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '犬',
          'kanji_target': '犬',
          'meaning': 'Khuyển (Chó)',
          'rmj': 'inu'
        },
        // 5. Chữ Miêu
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '猫',
          'kanji_target': '猫',
          'meaning': 'Miêu (Mèo)',
          'rmj': 'neko'
        },
        // 6. Chữ Hảo (Thích)
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '好き',
          'kanji_target': '好',
          'meaning': 'Hảo (Thích)',
          'rmj': 'su(ki)'
        },
        // 7. Chốt lại bằng Game ghép Kanji
        {
          'type': LessonType.matching,
          'pairs': [
            {'left': 'Nhật Bản', 'right': '日本'},
            {'left': 'Người', 'right': '人'},
            {'left': 'Chó', 'right': '犬'},
            {'left': 'Mèo', 'right': '猫'},
            {'left': 'Thích', 'right': '好き'}
          ]
        },
      ];
    }
  List<Map<String, dynamic>> _getCb3LyThuyetData() {
      return [
        // ================= PHẦN 1: TỪ VỰNG =================
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': 'これ', 'hiragana': 'これ', 'romaji': 'kore', 'meaning': 'Cái này (gần người nói)'},
            {'kanji': 'それ', 'hiragana': 'それ', 'romaji': 'sore', 'meaning': 'Cái đó (gần người nghe)'},
            {'kanji': 'あれ', 'hiragana': 'あれ', 'romaji': 'are', 'meaning': 'Cái kia (xa cả hai)'},
            {'kanji': '本', 'hiragana': 'ほん', 'romaji': 'hon', 'meaning': 'Quyển sách'},
            {'kanji': '傘', 'hiragana': 'かさ', 'romaji': 'kasa', 'meaning': 'Cái ô (dù)'},
            {'kanji': '車', 'hiragana': 'くるま', 'romaji': 'kuruma', 'meaning': 'Ô tô'},
            {'kanji': 'いくら', 'hiragana': 'いくら', 'romaji': 'ikura', 'meaning': 'Bao nhiêu (tiền)'},
            {'kanji': '円', 'hiragana': 'えん', 'romaji': 'en', 'meaning': 'Yên (tiền Nhật)'},
          ]
        },

        // --- NHÓM TỪ 1: CHỈ ĐỊNH TỪ ---
        {
          'type': LessonType.flashCard, 'kanji': 'これ', 'hiragana': 'これ', 'romaji': 'kore', 'meaning': 'Cái này',
          'example_img': 'assets/images/example_kore.png',
          'example_jp': 'これは本です。', 'example_rmj': 'Kore wa hon desu.', 'example_vn': 'Cái này là quyển sách.'
        },
        {
          'type': LessonType.flashCard, 'kanji': 'それ', 'hiragana': 'それ', 'romaji': 'sore', 'meaning': 'Cái đó',
          'example_img': 'assets/images/example_sore.png',
          'example_jp': 'それは傘ですか。', 'example_rmj': 'Sore wa kasa desu ka.', 'example_vn': 'Cái đó là cái ô phải không?'
        },
        {
          'type': LessonType.flashCard, 'kanji': 'あれ', 'hiragana': 'あれ', 'romaji': 'are', 'meaning': 'Cái kia',
          'example_img': 'assets/images/example_are.png',
          'example_jp': 'あれは車です。', 'example_rmj': 'Are wa kuruma desu.', 'example_vn': 'Cái kia là ô tô.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': 'これ', 'hiragana': 'これ', 'romaji': 'kore', 'options': ['cái kia', 'cái này', 'cái đó', 'ở đâu'], 'answer': 'cái này'},
        {'type': LessonType.listening, 'options': ['これ', 'それ', 'あれ', 'どれ'], 'answer': 'あれ'},

        // --- NHÓM TỪ 2: ĐỒ VẬT & TIỀN TỆ ---
        {
          'type': LessonType.flashCard, 'kanji': '本', 'hiragana': 'ほん', 'romaji': 'hon', 'meaning': 'Quyển sách',
          'example_img': 'assets/images/example_hon.png',
          'example_jp': '私の本です。', 'example_rmj': 'Watashi no hon desu.', 'example_vn': 'Là sách của tôi.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '傘', 'hiragana': 'かさ', 'romaji': 'kasa', 'meaning': 'Cái ô (dù)',
          'example_img': 'assets/images/example_kasa.png',
          'example_jp': 'これは傘です。', 'example_rmj': 'Kore wa kasa desu.', 'example_vn': 'Cái này là cái ô.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '車', 'hiragana': 'くるま', 'romaji': 'kuruma', 'meaning': 'Ô tô',
          'example_img': 'assets/images/example_kuruma.png',
          'example_jp': '日本の車です。', 'example_rmj': 'Nihon no kuruma desu.', 'example_vn': 'Là ô tô của Nhật Bản.'
        },
        {
          'type': LessonType.flashCard, 'kanji': 'いくら', 'hiragana': 'いくら', 'romaji': 'ikura', 'meaning': 'Bao nhiêu tiền',
          'example_img': 'assets/images/example_ikura.png',
          'example_jp': 'これはいくらですか。', 'example_rmj': 'Kore wa ikura desu ka.', 'example_vn': 'Cái này giá bao nhiêu tiền?'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '車', 'hiragana': 'くるま', 'romaji': 'kuruma', 'options': ['ô tô', 'xe đạp', 'quyển sách', 'cái ô'], 'answer': 'ô tô'},
        {'type': LessonType.listening, 'options': ['ほん', 'かさ', 'くるま', 'いくら'], 'answer': 'いくら'},

        // ================= PHẦN 2: NGỮ PHÁP =================
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'これ / それ / あれ', 'meaning': 'Cái này / Cái đó / Cái kia'},
            {'title': 'Trợ từ 「の」', 'meaning': 'Của (Sở hữu) / Xuất xứ'},
            {'title': '〜はいくらですか', 'meaning': '~ giá bao nhiêu tiền?'},
          ]
        },

        // NGỮ PHÁP 1: Đại từ chỉ thị
        {
          'type': LessonType.grammarStructure,
          'title': 'ĐẠI TỪ CHỈ THỊ',
          'formula': 'これ / それ / あれ + は + N + です',
          'meaning': 'Cái này / đó / kia là N'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'これ / それ / あれ',
          'notes': [
            'これ (Kore): Chỉ vật ở gần người nói.',
            'それ (Sore): Chỉ vật ở gần người nghe.',
            'あれ (Are): Chỉ vật ở xa cả người nói và người nghe.',
            'Chúng đóng vai trò như một danh từ độc lập làm chủ ngữ trong câu.'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'ĐẠI TỪ CHỈ THỊ',
          'img': 'assets/images/example_kore.png',
          'jp': 'これは本です。',
          'rmj': 'Kore wa hon desu.',
          'vn': 'Cái này là quyển sách.'
        },

        // NGỮ PHÁP 2: Trợ từ の
        {
          'type': LessonType.grammarStructure,
          'title': 'TRỢ TỪ 「の」',
          'formula': 'N1 + の + N2',
          'meaning': 'N2 của N1 / N2 xuất xứ từ N1'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'TRỢ TỪ 「の」',
          'notes': [
            'Dùng để nối 2 danh từ. N1 giải thích, bổ nghĩa cho N2.',
            'Thường mang nghĩa sở hữu (Sách CỦA tôi) hoặc xuất xứ (Ô tô CỦA Nhật Bản).',
            'Dịch ngược từ N2 về N1 so với tiếng Việt.'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'TRỢ TỪ 「の」',
          'img': 'assets/images/example_watashinohon.png',
          'jp': '私の本です。',
          'rmj': 'Watashi no hon desu.',
          'vn': 'Là quyển sách CỦA tôi.'
        },

        // NGỮ PHÁP 3: Hỏi giá
        {
          'type': LessonType.grammarStructure,
          'title': 'HỎI GIÁ TIỀN',
          'formula': 'N + は + いくら + ですか',
          'meaning': 'N giá bao nhiêu tiền?'
        },
        {
          'type': LessonType.grammarUsage,
          'title': '〜はいくらですか',
          'notes': [
            'Dùng từ để hỏi「いくら」để hỏi giá cả của một món đồ.',
            'Kết thúc câu hỏi luôn phải có trợ từ 「か」 ở cuối.'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'HỎI GIÁ TIỀN',
          'img': 'assets/images/example_ikura.png',
          'jp': 'それはいくらですか。',
          'rmj': 'Sore wa ikura desu ka.',
          'vn': 'Cái đó giá bao nhiêu tiền?'
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
          ]
        }
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
            {'img': 'assets/images/example_kuruma.png', 'jp': '車', 'rmj': 'kuruma'},
            {'img': 'assets/images/example_kasa.png', 'jp': '傘', 'rmj': 'kasa'},
            {'img': 'assets/images/example_inu.png', 'jp': '犬', 'rmj': 'inu'},
          ]
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
          'answer': '車'
        },
        // 3. CHỌN CÂU DÀI (Test UI nút dài)
        {
          'type': LessonType.quiz,
          'question': 'Cái này là cái ô.',
          'audio_text': 'これは傘です。',
          'options': [
            {'kanji': 'あれは傘です。', 'hiragana': 'あれはかさです。'},
            {'kanji': 'これは傘です。', 'hiragana': 'これはかさです。'}
          ],
          'answer': 'これは傘です。'
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
        {
          'type': LessonType.speaking,
          'jp': 'いくらですか',
          'answer': 'いくらですか',
        },
        // 7. VẼ KANJI (Sách)
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '本',
          'kanji_target': '本',
          'meaning': 'Bản (Sách)',
          'rmj': 'hon'
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
          'kanji': 'これ', 'hiragana': 'これ', 'romaji': 'kore',
          'options': ['cái kia', 'cái đó', 'cái này', 'ở đâu'],
          'answer': 'cái này'
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
          'answer': 'それ'
        },
        // 3. Trắc nghiệm chữ: Bao nhiêu tiền
        {
          'type': LessonType.vocabQuiz,
          'kanji': 'いくら', 'hiragana': 'いくら', 'romaji': 'ikura',
          'options': ['bao nhiêu tiền', 'như thế nào', 'cái nào', 'bao nhiêu tuổi'],
          'answer': 'bao nhiêu tiền'
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
          'answer': 'あれ'
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
            {'kanji': 'これはいくらですか。', 'hiragana': 'これはいくらですか。'}
          ],
          'answer': 'これはいくらですか。'
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
            {'kanji': 'これは傘じゃありません。', 'hiragana': 'これはかさじゃありません。'}
          ],
          'answer': 'あれは傘じゃありません。'
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
        {
          'type': LessonType.speaking,
          'jp': 'あれは車です',
          'answer': 'あれはくるまです',
        },
        // 14. Vẽ Kanji: Chữ Xa (車 - Ô tô)
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '車',
          'kanji_target': '車',
          'meaning': 'Xa (Ô tô)',
          'rmj': 'kuruma'
        },
        // 15. Vẽ Kanji: Chữ Viên (円 - Tiền Yên)
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '円',
          'kanji_target': '円',
          'meaning': 'Viên (Đơn vị tiền)',
          'rmj': 'en'
        },
      ];
    }
  List<Map<String, dynamic>> _getCb3LuyenTap3Data() {
    return [
      {
        'type': LessonType.quiz,
        'question': 'Điền trợ từ thích hợp (mang nghĩa sở hữu): \n私 ( ... ) 本です。',
        'options': ['が', 'は', 'の', 'も'],
        'answer': 'の'
      },
      // 2. Trắc nghiệm chữ: Yên (Tiền tệ)
      {
        'type': LessonType.vocabQuiz,
        'kanji': '円', 'hiragana': 'えん', 'romaji': 'en',
        'options': ['Đô la', 'Yên', 'Việt Nam Đồng', 'Won'],
        'answer': 'Yên'
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
          'Cái đó không phải là cái ô của bố.'
        ],
        'answer': 'Cái đó không phải là cái ô của bố.'
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
          {'kanji': 'それはいくらですか。', 'hiragana': 'それはいくらですか。'}
        ],
        'answer': 'これはいくらですか。' // Cái này giá bao nhiêu?
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
          {'kanji': 'それは私の犬じゃありません。', 'hiragana': 'それはわたしのいぬじゃありません。'}
        ],
        'answer': 'それは私の犬じゃありません。'
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
      {
        'type': LessonType.speaking,
        'jp': '私の本です',
        'answer': 'わたしのほんです',
      },
      // 14. Luyện nói: Bao nhiêu tiền
      {
        'type': LessonType.speaking,
        'jp': 'いくらですか',
        'answer': 'いくらですか',
      },
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
        ]
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
          'rmj': 'hon'
        },
        // 2. Chữ Xa (Ô tô)
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '車',
          'kanji_target': '車',
          'meaning': 'Xa (Ô tô)',
          'rmj': 'kuruma'
        },
        // 3. Chữ Viên (Tiền Yên)
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '円',
          'kanji_target': '円',
          'meaning': 'Viên (Tiền Yên Nhật)',
          'rmj': 'en'
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
          ]
        },
      ];
    }
  List<Map<String, dynamic>> _getCb4LyThuyetData() {
      return [
        // ================= PHẦN 1: TỪ VỰNG =================
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': '今', 'hiragana': 'いま', 'romaji': 'ima', 'meaning': 'Bây giờ'},
            {'kanji': '〜時', 'hiragana': '〜じ', 'romaji': '~ji', 'meaning': 'Giờ'},
            {'kanji': '〜分', 'hiragana': '〜ふん / ぷん', 'romaji': '~fun / pun', 'meaning': 'Phút'},
            {'kanji': '毎日', 'hiragana': 'まいにち', 'romaji': 'mainichi', 'meaning': 'Mỗi ngày'},
            {'kanji': '起きます', 'hiragana': 'おきます', 'romaji': 'okimasu', 'meaning': 'Thức dậy'},
            {'kanji': '寝ます', 'hiragana': 'ねます', 'romaji': 'nemasu', 'meaning': 'Ngủ'},
          ]
        },

        // --- NHÓM TỪ 1: THỜI GIAN ---
        {
          'type': LessonType.flashCard, 'kanji': '今', 'hiragana': 'いま', 'romaji': 'ima', 'meaning': 'Bây giờ',
          'example_img': 'assets/images/example_ima.png',
          'example_jp': '今は何時ですか。', 'example_rmj': 'Ima wa nanji desu ka.', 'example_vn': 'Bây giờ là mấy giờ?'
        },
        {
          'type': LessonType.flashCard, 'kanji': '〜時', 'hiragana': '〜じ', 'romaji': '~ji', 'meaning': 'Giờ',
          'example_img': 'assets/images/example_ji.png',
          'example_jp': '今は８時です。', 'example_rmj': 'Ima wa hachiji desu.', 'example_vn': 'Bây giờ là 8 giờ.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '〜分', 'hiragana': '〜ふん / ぷん', 'romaji': '~fun / pun', 'meaning': 'Phút',
          'example_img': 'assets/images/example_fun.png',
          'example_jp': '１０分です。', 'example_rmj': 'Juppun desu.', 'example_vn': 'Là 10 phút.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '今', 'hiragana': 'いま', 'romaji': 'ima', 'options': ['hôm nay', 'bây giờ', 'ngày mai', 'mỗi ngày'], 'answer': 'bây giờ'},
        {'type': LessonType.listening, 'options': ['いま', 'じ', 'ふん', 'なん'], 'answer': 'じ'},

        // --- NHÓM TỪ 2: HOẠT ĐỘNG ---
        {
          'type': LessonType.flashCard, 'kanji': '毎日', 'hiragana': 'まいにち', 'romaji': 'mainichi', 'meaning': 'Mỗi ngày',
          'example_img': 'assets/images/example_mainichi.png',
          'example_jp': '毎日、勉強します。', 'example_rmj': 'Mainichi, benkyou shimasu.', 'example_vn': 'Mỗi ngày tôi đều học bài.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '起きます', 'hiragana': 'おきます', 'romaji': 'okimasu', 'meaning': 'Thức dậy',
          'example_img': 'assets/images/example_okimasu.png',
          'example_jp': '６時に起きます。', 'example_rmj': 'Rokuji ni okimasu.', 'example_vn': 'Tôi thức dậy lúc 6 giờ.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '寝ます', 'hiragana': 'ねます', 'romaji': 'nemasu', 'meaning': 'Ngủ',
          'example_img': 'assets/images/example_nemasu.png',
          'example_jp': '１０時に寝ます。', 'example_rmj': 'Juuji ni nemasu.', 'example_vn': 'Tôi đi ngủ lúc 10 giờ.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '寝ます', 'hiragana': 'ねます', 'romaji': 'nemasu', 'options': ['thức dậy', 'ăn', 'ngủ', 'uống'], 'answer': 'ngủ'},
        {'type': LessonType.listening, 'options': ['おきます', 'ねます', 'まいにち', 'いま'], 'answer': 'おきます'},

        // ================= PHẦN 2: NGỮ PHÁP =================
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': '今は〜時です', 'meaning': 'Bây giờ là ~ giờ'},
            {'title': 'Động từ đuôi 「〜ます」', 'meaning': 'Thì hiện tại / Tương lai'},
            {'title': 'Thời gian + に + Vます', 'meaning': 'Làm gì đó vào lúc ~'},
          ]
        },

        // NGỮ PHÁP 1
        {
          'type': LessonType.grammarStructure,
          'title': 'NÓI GIỜ',
          'formula': '今 + は + Số đếm + 時 + です',
          'meaning': 'Bây giờ là ~ giờ'
        },
        {
          'type': LessonType.grammarUsage,
          'title': '今は〜時です',
          'notes': [
            'Dùng để thông báo thời gian hiện tại.',
            'Để hỏi giờ, ta dùng từ để hỏi 「何時」(Nanji - Mấy giờ): 今は何時ですか (Bây giờ là mấy giờ?).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'NÓI GIỜ',
          'img': 'assets/images/example_ima.png',
          'jp': '今は９時です。',
          'rmj': 'Ima wa kuji desu.',
          'vn': 'Bây giờ là 9 giờ.'
        },

        // NGỮ PHÁP 2
        {
          'type': LessonType.grammarStructure,
          'title': 'ĐỘNG TỪ 〜ます',
          'formula': 'V + ます',
          'meaning': 'Thì hiện tại / Tương lai khẳng định'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'ĐỘNG TỪ 〜ます',
          'notes': [
            'Khác với tính từ đi với です, các hành động trong tiếng Nhật được biểu hiện bằng động từ kết thúc bằng đuôi 「〜ます」.',
            'Nó mang sắc thái lịch sự, dùng để diễn tả một thói quen hàng ngày (ví dụ: Mỗi ngày tôi đều thức dậy) hoặc một hành động sẽ xảy ra trong tương lai.'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'ĐỘNG TỪ 〜ます',
          'img': 'assets/images/example_mainichi.png',
          'jp': '毎日、起きます。',
          'rmj': 'Mainichi, okimasu.',
          'vn': 'Mỗi ngày tôi đều thức dậy.'
        },

        // NGỮ PHÁP 3
        {
          'type': LessonType.grammarStructure,
          'title': 'TRỢ TỪ 「に」',
          'formula': 'Danh từ (Thời gian) + に + Vます',
          'meaning': 'Làm việc gì đó vào lúc ~'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'TRỢ TỪ 「に」',
          'notes': [
            'Trợ từ 「に」 được đặt ngay sau danh từ chỉ thời gian cụ thể (có con số như giờ, phút, ngày, tháng, năm).',
            'Nó chỉ ra thời điểm mà hành động xảy ra.',
            'Lưu ý: Không dùng 「に」 sau các từ thời gian chung chung như: Hôm nay, Ngày mai, Mỗi ngày (毎日).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'TRỢ TỪ 「に」',
          'img': 'assets/images/example_okimasu.png',
          'jp': '６時に起きます。',
          'rmj': 'Rokuji ni okimasu.',
          'vn': 'Tôi thức dậy lúc 6 giờ.'
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
          ]
        }
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
            {'img': 'assets/images/example_okimasu.png', 'jp': '起きます', 'rmj': 'okimasu'},
            {'img': 'assets/images/example_nemasu.png', 'jp': '寝ます', 'rmj': 'nemasu'},
          ]
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
          'answer': '時'
        },
        // 3. Chọn câu dài: Bây giờ là 9 giờ
        {
          'type': LessonType.quiz,
          'question': 'Bây giờ là 9 giờ.',
          'audio_text': '今は９時です。',
          'options': [
            {'kanji': '今は８時です。', 'hiragana': 'いまははちじです。'},
            {'kanji': '今は９時です。', 'hiragana': 'いまはくじです。'}
          ],
          'answer': '今は９時です。'
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
          'kanji': '起きます', 'hiragana': 'おきます', 'romaji': 'okimasu',
          'options': ['ngủ', 'ăn', 'thức dậy', 'uống'],
          'answer': 'thức dậy'
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
          'answer': '寝ます'
        },
        // 3. Chọn câu dài: Tôi thức dậy lúc 6 giờ
        {
          'type': LessonType.quiz,
          'question': 'Tôi thức dậy lúc 6 giờ.',
          'audio_text': '私は６時に起きます。',
          'options': [
            {'kanji': '私は６時に寝ます。', 'hiragana': 'わたしはろくじにねます。'},
            {'kanji': '私は６時に起きます。', 'hiragana': 'わたしはろくじにおきます。'}
          ],
          'answer': '私は６時に起きます。'
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
          'answer': 'は'
        },
        // 2. Điền trợ từ thời gian
        {
          'type': LessonType.quiz,
          'question': 'Điền trợ từ: \n私は１０時 ( ... ) 寝ます。',
          'options': ['に', 'は', 'も', 'が'],
          'answer': 'に'
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
            'Chúng tôi cũng thức dậy lúc 6 giờ.'
          ],
          'answer': 'Bọn họ cũng thức dậy lúc 6 giờ.'
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
          ]
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
          'rmj': 'ima'
        },
        // 2. Chữ Thời (Giờ)
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '〜時',
          'kanji_target': '時',
          'meaning': 'Thời (Thời gian / Giờ)',
          'rmj': 'ji'
        },
        // 3. Chữ Phân (Phút)
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '〜分',
          'kanji_target': '分',
          'meaning': 'Phân (Phút)',
          'rmj': 'fun / pun'
        },
        // 4. Chữ Mỗi (Mỗi ngày)
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '毎日',
          'kanji_target': '毎',
          'meaning': 'Mỗi (Mỗi ngày)',
          'rmj': 'mai'
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
          ]
        },
      ];
    }
  List<Map<String, dynamic>> _getCb5LyThuyetData() {
      return [
        // ================= PHẦN 1: TỪ VỰNG =================
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': '行きます', 'hiragana': 'いきます', 'romaji': 'ikimasu', 'meaning': 'Đi'},
            {'kanji': '来ます', 'hiragana': 'きます', 'romaji': 'kimasu', 'meaning': 'Đến'},
            {'kanji': '帰ります', 'hiragana': 'かえります', 'romaji': 'kaerimasu', 'meaning': 'Về'},
            {'kanji': '学校', 'hiragana': 'がっこう', 'romaji': 'gakkou', 'meaning': 'Trường học'},
            {'kanji': '電車', 'hiragana': 'でんしゃ', 'romaji': 'densha', 'meaning': 'Tàu điện'},
            {'kanji': '自転車', 'hiragana': 'じてんしゃ', 'romaji': 'jitensha', 'meaning': 'Xe đạp'},
          ]
        },

        // --- NHÓM TỪ 1: ĐỘNG TỪ DI CHUYỂN ---
        {
          'type': LessonType.flashCard, 'kanji': '行きます', 'hiragana': 'いきます', 'romaji': 'ikimasu', 'meaning': 'Đi',
          'example_img': 'assets/images/example_ikimasu.png',
          'example_jp': '学校へ行きます。', 'example_rmj': 'Gakkou e ikimasu.', 'example_vn': 'Tôi đi đến trường.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '来ます', 'hiragana': 'きます', 'romaji': 'kimasu', 'meaning': 'Đến',
          'example_img': 'assets/images/example_kimasu.png',
          'example_jp': '日本へ来ました。', 'example_rmj': 'Nihon e kimashita.', 'example_vn': 'Tôi đã đến Nhật Bản.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '帰ります', 'hiragana': 'かえります', 'romaji': 'kaerimasu', 'meaning': 'Về',
          'example_img': 'assets/images/example_kaerimasu.png',
          'example_jp': 'うちへ帰ります。', 'example_rmj': 'Uchi e kaerimasu.', 'example_vn': 'Tôi đi về nhà.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '行きます', 'hiragana': 'いきます', 'romaji': 'ikimasu', 'options': ['đến', 'đi', 'về', 'ngủ'], 'answer': 'đi'},
        {'type': LessonType.listening, 'options': ['いきます', 'きます', 'かえります', 'おきます'], 'answer': 'かえります'},

        // --- NHÓM TỪ 2: ĐỊA ĐIỂM & PHƯƠNG TIỆN ---
        {
          'type': LessonType.flashCard, 'kanji': '学校', 'hiragana': 'がっこう', 'romaji': 'gakkou', 'meaning': 'Trường học',
          'example_img': 'assets/images/example_gakkou.png',
          'example_jp': '毎日、学校へ行きます。', 'example_rmj': 'Mainichi, gakkou e ikimasu.', 'example_vn': 'Mỗi ngày tôi đều đi đến trường.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '電車', 'hiragana': 'でんしゃ', 'romaji': 'densha', 'meaning': 'Tàu điện',
          'example_img': 'assets/images/example_densha.png',
          'example_jp': '電車で行きます。', 'example_rmj': 'Densha de ikimasu.', 'example_vn': 'Tôi đi bằng tàu điện.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '自転車', 'hiragana': 'じてんしゃ', 'romaji': 'jitensha', 'meaning': 'Xe đạp',
          'example_img': 'assets/images/example_jitensha.png',
          'example_jp': '自転車で帰ります。', 'example_rmj': 'Jitensha de kaerimasu.', 'example_vn': 'Tôi về bằng xe đạp.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '電車', 'hiragana': 'でんしゃ', 'romaji': 'densha', 'options': ['xe đạp', 'ô tô', 'tàu điện', 'trường học'], 'answer': 'tàu điện'},
        {'type': LessonType.listening, 'options': ['がっこう', 'でんしゃ', 'じてんしゃ', 'くるま'], 'answer': 'じてんしゃ'},

        // ================= PHẦN 2: NGỮ PHÁP =================
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'N(địa điểm) + へ + 行きます', 'meaning': 'Đi / Đến / Về nơi nào đó'},
            {'title': 'N(phương tiện) + で + 行きます', 'meaning': 'Đi bằng phương tiện gì'},
            {'title': 'N(người) + と + 行きます', 'meaning': 'Đi cùng với ai'},
          ]
        },

        // NGỮ PHÁP 1
        {
          'type': LessonType.grammarStructure,
          'title': 'TRỢ TỪ CHỈ HƯỚNG「へ」',
          'formula': 'Danh từ (Địa điểm) + へ + 行きます / 来ます / 帰ります',
          'meaning': 'Đi / Đến / Về (địa điểm nào đó)'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'TRỢ TỪ「へ」',
          'notes': [
            'Dùng để chỉ phương hướng của sự di chuyển.',
            'Lưu ý cực kỳ quan trọng: Trợ từ này viết là 「へ」 (he) nhưng luôn luôn được phát âm là 「え」 (e).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'TRỢ TỪ「へ」',
          'img': 'assets/images/example_ikimasu.png',
          'jp': '学校へ行きます。',
          'rmj': 'Gakkou e ikimasu.',
          'vn': 'Tôi đi đến trường.'
        },

        // NGỮ PHÁP 2
        {
          'type': LessonType.grammarStructure,
          'title': 'TRỢ TỪ CHỈ PHƯƠNG TIỆN「で」',
          'formula': 'Danh từ (Phương tiện) + で + Hành động',
          'meaning': 'Làm gì đó bằng phương tiện / công cụ gì'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'TRỢ TỪ「で」',
          'notes': [
            'Đặt trợ từ「で」sau danh từ chỉ phương tiện giao thông để diễn tả cách thức di chuyển.',
            'Ngoại lệ: Nếu đi bộ, ta dùng từ 「歩いて」(aruite) và KHÔNG dùng trợ từ で.'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'TRỢ TỪ「で」',
          'img': 'assets/images/example_densha.png',
          'jp': '電車で学校へ行きます。',
          'rmj': 'Densha de gakkou e ikimasu.',
          'vn': 'Tôi đi đến trường BẰNG tàu điện.'
        },

        // NGỮ PHÁP 3
        {
          'type': LessonType.grammarStructure,
          'title': 'TRỢ TỪ ĐỒNG HÀNH「と」',
          'formula': 'Danh từ (Người) + と + Hành động',
          'meaning': 'Làm gì đó CÙNG VỚI ai'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'TRỢ TỪ「と」',
          'notes': [
            'Biểu thị người (hoặc động vật) cùng thực hiện hành động với mình.',
            'Nếu làm một mình, ta dùng từ 「一人で」(hitori de - một mình) và không dùng trợ từ と.'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'TRỢ TỪ「と」',
          'img': 'assets/images/example_tomodachi.png',
          'jp': '友達と日本へ来ました。',
          'rmj': 'Tomodachi to Nihon e kimashita.',
          'vn': 'Tôi đã đến Nhật VỚI bạn.'
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
          ]
        }
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
            {'img': 'assets/images/example_ikimasu.png', 'jp': '行きます', 'rmj': 'ikimasu'},
            {'img': 'assets/images/example_densha.png', 'jp': '電車', 'rmj': 'densha'},
            {'img': 'assets/images/example_jitensha.png', 'jp': '自転車', 'rmj': 'jitensha'},
            {'img': 'assets/images/example_gakkou.png', 'jp': '学校', 'rmj': 'gakkou'},
          ]
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
          'answer': '行きます'
        },
        // 3. Chọn câu: Tôi đi đến trường
        {
          'type': LessonType.quiz,
          'question': 'Tôi đi đến trường.',
          'audio_text': '私は学校へ行きます。',
          'options': [
            {'kanji': '私は学校へ帰ります。', 'hiragana': 'わたしはがっこうへかえります。'},
            {'kanji': '私は学校へ行きます。', 'hiragana': 'わたしはがっこうへいきます。'}
          ],
          'answer': '私は学校へ行きます。'
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
          'kanji': '電車', 'hiragana': 'でんしゃ', 'romaji': 'densha',
          'options': ['ô tô', 'tàu điện', 'xe đạp', 'trường học'],
          'answer': 'tàu điện'
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
          'answer': '自転車'
        },
        // 3. Chọn câu: Đi bằng tàu điện
        {
          'type': LessonType.quiz,
          'question': 'Tôi đi bằng tàu điện.',
          'audio_text': '電車で行きます。',
          'options': [
            {'kanji': '電車で行きます。', 'hiragana': 'でんしゃでいきます。'},
            {'kanji': '自転車で行きます。', 'hiragana': 'じてんしゃでいきます。'}
          ],
          'answer': '電車で行きます。'
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
          'answer': 'と'
        },
        // 2. Điền trợ từ (Bằng tàu điện)
        {
          'type': LessonType.quiz,
          'question': 'Điền trợ từ (bằng phương tiện): \n電車 ( ... ) 帰ります。',
          'options': ['で', 'は', 'へ', 'と'],
          'answer': 'で'
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
            'Tôi đi xe đạp đến trường với bạn.'
          ],
          'answer': 'Tôi về bằng xe đạp với bạn.'
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
          'rmj': 'i(kimasu)'
        },
        // 2. Chữ Lai (Đến)
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '来ます',
          'kanji_target': '来',
          'meaning': 'Lai (Đến)',
          'rmj': 'ki(masu)'
        },
        // 3. Chữ Quy (Về)
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '帰ります',
          'kanji_target': '帰',
          'meaning': 'Quy (Về)',
          'rmj': 'kae(rimasu)'
        },
        // 4. Chữ Học (Trường học)
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '学校',
          'kanji_target': '学',
          'meaning': 'Học (Học tập / Trường học)',
          'rmj': 'gaku / ga'
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
          ]
        },
      ];
    }
  List<Map<String, dynamic>> _getCb6LyThuyetData() {
      return [
        // ================= PHẦN 1: TỪ VỰNG =================
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': '食べます', 'hiragana': 'たべます', 'romaji': 'tabemasu', 'meaning': 'Ăn'},
            {'kanji': '飲みます', 'hiragana': 'のみます', 'romaji': 'nomimasu', 'meaning': 'Uống'},
            {'kanji': '見ます', 'hiragana': 'みます', 'romaji': 'mimasu', 'meaning': 'Xem / Nhìn'},
            {'kanji': 'ご飯', 'hiragana': 'ごはん', 'romaji': 'gohan', 'meaning': 'Cơm / Bữa ăn'},
            {'kanji': '水', 'hiragana': 'みず', 'romaji': 'mizu', 'meaning': 'Nước'},
            {'kanji': 'お酒', 'hiragana': 'おさけ', 'romaji': 'osake', 'meaning': 'Rượu / Đồ uống có cồn'},
            {'kanji': '一緒に', 'hiragana': 'いっしょに', 'romaji': 'isshoni', 'meaning': 'Cùng nhau'},
          ]
        },

        // --- NHÓM TỪ 1: ĐỘNG TỪ ---
        {
          'type': LessonType.flashCard, 'kanji': '食べます', 'hiragana': 'たべます', 'romaji': 'tabemasu', 'meaning': 'Ăn',
          'example_img': 'assets/images/example_tabemasu.png',
          'example_jp': 'ご飯を食べます。', 'example_rmj': 'Gohan o tabemasu.', 'example_vn': 'Tôi ăn cơm.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '飲みます', 'hiragana': 'のみます', 'romaji': 'nomimasu', 'meaning': 'Uống',
          'example_img': 'assets/images/example_nomimasu.png',
          'example_jp': '水を飲みます。', 'example_rmj': 'Mizu o nomimasu.', 'example_vn': 'Tôi uống nước.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '見ます', 'hiragana': 'みます', 'romaji': 'mimasu', 'options': ['ăn', 'ngủ', 'xem', 'uống'], 'answer': 'xem'},

        // --- NHÓM TỪ 2: ĐỒ ĂN & TRẠNG TỪ ---
        {
          'type': LessonType.flashCard, 'kanji': 'ご飯', 'hiragana': 'ごはん', 'romaji': 'gohan', 'meaning': 'Cơm',
          'example_img': 'assets/images/example_gohan.png',
          'example_jp': '朝ご飯を食べます。', 'example_rmj': 'Asagohan o tabemasu.', 'example_vn': 'Tôi ăn bữa sáng.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '一緒に', 'hiragana': 'いっしょに', 'romaji': 'isshoni', 'meaning': 'Cùng nhau',
          'example_img': 'assets/images/example_isshoni.png',
          'example_jp': '一緒に食べませんか。', 'example_rmj': 'Isshoni tabemasenka.', 'example_vn': 'Cùng ăn với tôi không?'
        },
        {'type': LessonType.listening, 'options': ['ごはん', 'みず', 'おさけ', 'いっしょに'], 'answer': 'おさけ'},

        // ================= PHẦN 2: NGỮ PHÁP =================
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'N + を + V(ngoại động từ)', 'meaning': 'Làm gì đó với cái gì (Ăn cơm, uống nước)'},
            {'title': 'Địa điểm + で + V', 'meaning': 'Làm gì đó TẠI đâu'},
            {'title': 'V-ませんか', 'meaning': 'Rủ rê (Cùng làm ~ với tôi không?)'},
          ]
        },

        // NGỮ PHÁP 1: Trợ từ を
        {
          'type': LessonType.grammarStructure,
          'title': 'TRỢ TỪ TÂN NGỮ「を」',
          'formula': 'Danh từ + を + Động từ',
          'meaning': 'Ăn / Uống / Xem (một cái gì đó)'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'TRỢ TỪ「を」',
          'notes': [
            'Dùng để chỉ đối tượng chịu tác động của hành động.',
            'Ví dụ: Ăn (V) cái gì? -> Ăn cơm (N). Cơm là đối tượng nên đi với を.',
            'Lưu ý: Chữ này viết là 「を」(wo) nhưng chỉ phát âm là 「o」.'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'TRỢ TỪ「を」',
          'img': 'assets/images/example_tabemasu.png',
          'jp': '魚を食べます。',
          'rmj': 'Sakana o tabemasu.',
          'vn': 'Tôi ăn cá.'
        },

        // NGỮ PHÁP 2: Trợ từ で (Địa điểm hành động)
        {
          'type': LessonType.grammarStructure,
          'title': 'TRỢ TỪ ĐỊA ĐIỂM「で」',
          'formula': 'Địa điểm + で + Động từ',
          'meaning': 'Làm gì đó TẠI địa điểm nào đó'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'PHÂN BIỆT で VÀ へ',
          'notes': [
            'へ (e): Chỉ hướng di chuyển (Đi ĐẾN đâu).',
            'で (de): Chỉ nơi xảy ra hành động (Ăn cơm TẠI đâu).',
            'Ví dụ: 学校で勉強します (Học bài TẠI trường).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'TRỢ TỪ「で」',
          'img': 'assets/images/example_gakkou_taberu.png',
          'jp': '学校でご飯を食べます。',
          'rmj': 'Gakkou de gohan o tabemasu.',
          'vn': 'Tôi ăn cơm TẠI trường học.'
        },

        // NGỮ PHÁP 3: Rủ rê
        {
          'type': LessonType.grammarStructure,
          'title': 'CÂU RỦ RÊ「〜ませんか」',
          'formula': 'V-ます ➔ V-ませんか',
          'meaning': 'Cùng làm ~ với tôi không?'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'CÁCH RỦ RÊ LỊCH SỰ',
          'notes': [
            'Dùng để mời hoặc rủ người nghe cùng thực hiện hành động với mình.',
            'Thường đi kèm với phó từ 「一緒に」(isshoni - cùng nhau).',
            'Cách trả lời đồng ý: 「ええ、しましょう」(Vâng, cùng làm thôi).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'CÂU RỦ RÊ',
          'img': 'assets/images/example_isshoni.png',
          'jp': '一緒に飲みませんか。',
          'rmj': 'Isshoni nomimasenka.',
          'vn': 'Cùng uống với tôi không?'
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
          ]
        }
      ];
    }
  List<Map<String, dynamic>> _getCb6LuyenTap1Data() {
      return [
        {
          'type': LessonType.imageQuiz,
          'question': 'Ăn cơm.',
          'answerIndex': 0,
          'options': [
            {'img': 'assets/images/example_tabemasu.png', 'jp': '食べます', 'rmj': 'tabemasu'},
            {'img': 'assets/images/example_nomimasu.png', 'jp': '飲みます', 'rmj': 'nomimasu'},
            {'img': 'assets/images/example_mizu.png', 'jp': '水', 'rmj': 'mizu'},
            {'img': 'assets/images/example_isshoni.png', 'jp': '一緒に', 'rmj': 'isshoni'},
          ]
        },
        {
          'type': LessonType.listening,
          'options': [
            {'kanji': '食べます', 'hiragana': 'たべます'},
            {'kanji': '飲みます', 'hiragana': 'のみます'},
            {'kanji': '見ます', 'hiragana': 'みます'},
            {'kanji': 'ご飯', 'hiragana': 'ごはん'},
          ],
          'answer': '飲みます'
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
          'answer': 'で'
        },
        {
          'type': LessonType.quiz,
          'question': 'Tôi xem TV ở nhà.',
          'audio_text': 'うちでテレビを見ます。',
          'options': [
            {'kanji': 'うちでテレビを見ます。', 'hiragana': 'うちでテレビをみます。'},
            {'kanji': 'うちへテレビを見ます。', 'hiragana': 'うちへテレビをみます。'}
          ],
          'answer': 'うちでテレビを見ます。'
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
          'options': [
            '一緒にご飯を食べますか。',
            '一緒にご飯を食べませんか。',
            '一緒にご飯を食べました。'
          ],
          'answer': '一緒にご飯を食べませんか。'
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
          ]
        },
      ];
    }
  List<Map<String, dynamic>> _getCb6LuyenNoiData() {
      return [
        {
          'type': LessonType.speaking,
          'jp': '水を飲みます。',
          'answer': 'みずをのみます',
        },
        {
          'type': LessonType.speaking,
          'jp': '魚を食べます。',
          'answer': 'さかなをたべます',
        },
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
        {
          'type': LessonType.speaking,
          'jp': 'ええ、食べましょう。',
          'answer': 'ええたべましょう',
        },
      ];
    }
  List<Map<String, dynamic>> _getCb6LuyenVietData() {
      return [
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '食べます',
          'kanji_target': '食',
          'meaning': 'Thực (Ăn)',
          'rmj': 'ta(beru)'
        },
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '飲みます',
          'kanji_target': '飲',
          'meaning': 'Ẩm (Uống)',
          'rmj': 'no(mu)'
        },
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '見ます',
          'kanji_target': '見',
          'meaning': 'Kiến (Nhìn/Xem)',
          'rmj': 'mi(ru)'
        },
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '水',
          'kanji_target': '水',
          'meaning': 'Thủy (Nước)',
          'rmj': 'mizu'
        },
        {
          'type': LessonType.matching,
          'pairs': [
            {'left': 'Ăn', 'right': '食'},
            {'left': 'Uống', 'right': '飲'},
            {'left': 'Xem', 'right': '見'},
            {'left': 'Nước', 'right': '水'},
            {'left': 'Cơm', 'right': '飯'},
          ]
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
            {'kanji': '日本語', 'hiragana': 'にほんご', 'romaji': 'nihongo', 'meaning': 'Tiếng Nhật'},
            {'kanji': '英語', 'hiragana': 'えいご', 'romaji': 'eigo', 'meaning': 'Tiếng Anh'},
            {'kanji': 'あげます', 'hiragana': 'あげます', 'romaji': 'agemasu', 'meaning': 'Cho / Tặng'},
            {'kanji': 'もらいます', 'hiragana': 'もらいます', 'romaji': 'moraimasu', 'meaning': 'Nhận'},
            {'kanji': '教えます', 'hiragana': 'おしえます', 'romaji': 'oshiemasu', 'meaning': 'Dạy'},
            {'kanji': '習います', 'hiragana': 'ならいます', 'romaji': 'naraimasu', 'meaning': 'Học / Được dạy'},
          ]
        },

        // --- NHÓM TỪ 1: CÔNG CỤ & NGÔN NGỮ ---
        {
          'type': LessonType.flashCard, 'kanji': '手', 'hiragana': 'て', 'romaji': 'te', 'meaning': 'Tay',
          'example_img': 'assets/images/example_te.png',
          'example_jp': '手で食べます。', 'example_rmj': 'Te de tabemasu.', 'example_vn': 'Ăn bằng tay.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '日本語', 'hiragana': 'にほんご', 'romaji': 'nihongo', 'meaning': 'Tiếng Nhật',
          'example_img': 'assets/images/example_nihongo.png',
          'example_jp': '日本語で話します。', 'example_rmj': 'Nihongo de hanashimasu.', 'example_vn': 'Nói chuyện bằng tiếng Nhật.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '箸', 'hiragana': 'はし', 'romaji': 'hashi', 'options': ['ô tô', 'đũa', 'thìa', 'tay'], 'answer': 'đũa'},

        // --- NHÓM TỪ 2: CHO - NHẬN ---
        {
          'type': LessonType.flashCard, 'kanji': 'あげます', 'hiragana': 'あげます', 'romaji': 'agemasu', 'meaning': 'Cho / Tặng',
          'example_img': 'assets/images/example_agemasu.png',
          'example_jp': '母にプレゼントをあげます。', 'example_rmj': 'Haha ni purezento o agemasu.', 'example_vn': 'Tôi tặng quà cho mẹ.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '習います', 'hiragana': 'ならいます', 'romaji': 'naraimasu', 'meaning': 'Học (từ ai đó)',
          'example_img': 'assets/images/example_naraimasu.png',
          'example_jp': '先生に日本語を習います。', 'example_rmj': 'Sensei ni nihongo o naraimasu.', 'example_vn': 'Tôi học tiếng Nhật từ thầy giáo.'
        },
        {'type': LessonType.listening, 'options': ['あげます', 'もらいます', 'おしえます', 'ならいます'], 'answer': 'もらいます'},

        // ================= PHẦN 2: NGỮ PHÁP =================
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'Công cụ/Ngôn ngữ + で + V', 'meaning': 'Làm gì bằng công cụ / ngôn ngữ gì'},
            {'title': 'N(người) + に + あげます', 'meaning': 'Làm gì CHO ai đó'},
            {'title': 'N(người) + に + もらいます', 'meaning': 'NHẬN gì từ ai đó'},
          ]
        },

        // NGỮ PHÁP 1: Trợ từ で (Công cụ)
        {
          'type': LessonType.grammarStructure,
          'title': 'TRỢ TỪ CÔNG CỤ「で」',
          'formula': 'Công cụ / Ngôn ngữ + で + Động từ',
          'meaning': 'Bằng ~'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'CÁCH DÙNG TRỢ TỪ「で」',
          'notes': [
            'Biểu thị phương tiện hoặc cách thức thực hiện hành động.',
            'Dùng cho công cụ: 箸で食べます (Ăn bằng đũa).',
            'Dùng cho ngôn ngữ: 日本語でレポートを書きます (Viết báo cáo bằng tiếng Nhật).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'TRỢ TỪ CÔNG CỤ「で」',
          'img': 'assets/images/example_hashi.png',
          'jp': '箸で食べます。',
          'rmj': 'Hashi de tabemasu.',
          'vn': 'Tôi ăn bằng đũa.'
        },

        // NGỮ PHÁP 2: Trợ từ に (Đối tượng nhận/cho)
        {
          'type': LessonType.grammarStructure,
          'title': 'TRỢ TỪ ĐỐI TƯỢNG「に」',
          'formula': 'Đối tượng (Người) + に + Động từ (Cho/Nhận)',
          'meaning': 'Cho ai / Từ ai'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'PHÂN BIỆT CHO VÀ NHẬN',
          'notes': [
            'Với các từ "Cho/Dạy/Cho mượn": Trợ từ に chỉ người nhận.',
            'Với các từ "Nhận/Học/Mượn": Trợ từ に chỉ người cho (đối tượng mà mình nhận từ họ).',
            'Riêng với "Nhận từ ai đó", có thể dùng 「から」 thay cho 「に」.'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'TRỢ TỪ ĐỐI TƯỢNG「に」',
          'img': 'assets/images/example_agemasu.png',
          'jp': '友達に本をあげます。',
          'rmj': 'Tomodachi ni hon o agemasu.',
          'vn': 'Tôi tặng sách cho bạn.'
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
          ]
        }
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
            {'img': 'assets/images/example_nihongo.png', 'jp': '日本語', 'rmj': 'nihongo'},
            {'img': 'assets/images/example_eigo.png', 'jp': '英語', 'rmj': 'eigo'},
          ]
        },
        {
          'type': LessonType.listening,
          'options': [
            {'kanji': '日本語', 'hiragana': 'にほんご'},
            {'kanji': '英語', 'hiragana': 'えいご'},
            {'kanji': '手', 'hiragana': 'て'},
            {'kanji': '箸', 'hiragana': 'はし'},
          ],
          'answer': '英語'
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
            {'kanji': '母に花をもらいます。', 'hiragana': 'ははにはなをもらいます。'}
          ],
          'answer': '母に花 को あげます。'
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
          'answer': 'に'
        },
      ];
    }
  List<Map<String, dynamic>> _getCb7LuyenTap3Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Câu nào nghĩa là: "Tôi học tiếng Nhật từ bạn"?',
          'options': [
            '友達に日本語を教えます。',
            '友達に日本語を習います。',
            '友達も日本語を習います。'
          ],
          'answer': '友達に日本語を習います。'
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
          ]
        },
      ];
    }
  List<Map<String, dynamic>> _getCb7LuyenNoiData() {
      return [
        {
          'type': LessonType.speaking,
          'jp': '箸で食べます。',
          'answer': 'はしでたべます',
        },
        {
          'type': LessonType.speaking,
          'jp': '日本語で話します。',
          'answer': 'にほんごではなします',
        },
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
          'rmj': 'te'
        },
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '日本語',
          'kanji_target': '語',
          'meaning': 'Ngữ (Ngôn ngữ)',
          'rmj': 'go'
        },
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '英語',
          'kanji_target': '英',
          'meaning': 'Anh (Tiếng Anh / Anh hùng)',
          'rmj': 'ei'
        },
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '教えます',
          'kanji_target': '教',
          'meaning': 'Giáo (Dạy / Giáo dục)',
          'rmj': 'oshi(eru)'
        },
        {
          'type': LessonType.matching,
          'pairs': [
            {'left': 'Tay', 'right': '手'},
            {'left': 'Ngôn ngữ', 'right': '語'},
            {'left': 'Dạy', 'right': '教'},
            {'left': 'Học', 'right': '習'},
            {'left': 'Viết', 'right': '書'},
          ]
        },
      ];
    }
  List<Map<String, dynamic>> _getCb8LyThuyetData() {
      return [
        // ================= PHẦN 1: TỪ VỰNG =================
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': '大きい', 'hiragana': 'おおきい', 'romaji': 'ookii', 'meaning': 'To / Lớn (Tính từ đuôi い)'},
            {'kanji': '小さい', 'hiragana': 'ちいさい', 'romaji': 'chiisai', 'meaning': 'Nhỏ / Bé (Tính từ đuôi い)'},
            {'kanji': '暑い', 'hiragana': 'あつい', 'romaji': 'atsui', 'meaning': 'Nóng (Thời tiết) (Tính từ đuôi い)'},
            {'kanji': '寒い', 'hiragana': 'さむい', 'romaji': 'samui', 'meaning': 'Lạnh (Thời tiết) (Tính từ đuôi い)'},
            {'kanji': 'きれい[な]', 'hiragana': 'きれい[な]', 'romaji': 'kirei [na]', 'meaning': 'Đẹp / Sạch sẽ (Tính từ đuôi な)'},
            {'kanji': '静か[な]', 'hiragana': 'しずか[な]', 'romaji': 'shizuka [na]', 'meaning': 'Yên tĩnh (Tính từ đuôi な)'},
            {'kanji': '町', 'hiragana': 'まち', 'romaji': 'machi', 'meaning': 'Thành phố / Thị trấn'},
            {'kanji': '山', 'hiragana': 'やま', 'romaji': 'yama', 'meaning': 'Núi'},
          ]
        },

        // --- NHÓM TỪ 1: TÍNH TỪ ĐUÔI い ---
        {
          'type': LessonType.flashCard, 'kanji': '大きい', 'hiragana': 'おおきい', 'romaji': 'ookii', 'meaning': 'To / Lớn',
          'example_img': 'assets/images/example_ookii.png',
          'example_jp': '大きい車です。', 'example_rmj': 'Ookii kuruma desu.', 'example_vn': 'Là chiếc ô tô lớn.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '小さい', 'hiragana': 'ちいさい', 'romaji': 'chiisai', 'meaning': 'Nhỏ / Bé',
          'example_img': 'assets/images/example_chiisai.png',
          'example_jp': '小さい犬です。', 'example_rmj': 'Chiisai inu desu.', 'example_vn': 'Là con chó nhỏ.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '暑い', 'hiragana': 'あつい', 'romaji': 'atsui', 'meaning': 'Nóng',
          'example_img': 'assets/images/example_atsui.png',
          'example_jp': '今日は暑いです。', 'example_rmj': 'Kyou wa atsui desu.', 'example_vn': 'Hôm nay trời nóng.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '寒い', 'hiragana': 'さむい', 'romaji': 'samui', 'meaning': 'Lạnh',
          'example_img': 'assets/images/example_samui.png',
          'example_jp': '日本は寒いです。', 'example_rmj': 'Nihon wa samui desu.', 'example_vn': 'Nhật Bản thì lạnh.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '大きい', 'hiragana': 'おおきい', 'romaji': 'ookii', 'options': ['nhỏ', 'to / lớn', 'nóng', 'lạnh'], 'answer': 'to / lớn'},
        {'type': LessonType.listening, 'options': ['おおきい', 'ちいさい', 'あつい', 'さむい'], 'answer': 'あつい'},

        // --- NHÓM TỪ 2: TÍNH TỪ ĐUÔI な & DANH TỪ ---
        {
          'type': LessonType.flashCard, 'kanji': 'きれい[な]', 'hiragana': 'きれい[な]', 'romaji': 'kirei [na]', 'meaning': 'Đẹp / Sạch sẽ',
          'example_img': 'assets/images/example_kirei.png',
          'example_jp': 'きれいな町です。', 'example_rmj': 'Kirei na machi desu.', 'example_vn': 'Là một thành phố đẹp.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '静か[な]', 'hiragana': 'しずか[な]', 'romaji': 'shizuka [na]', 'meaning': 'Yên tĩnh',
          'example_img': 'assets/images/example_shizuka.png',
          'example_jp': '静かな山です。', 'example_rmj': 'Shizuka na yama desu.', 'example_vn': 'Là ngọn núi yên tĩnh.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '町', 'hiragana': 'まち', 'romaji': 'machi', 'meaning': 'Thành phố / Thị trấn',
          'example_img': 'assets/images/example_machi.png',
          'example_jp': '私の町です。', 'example_rmj': 'Watashi no machi desu.', 'example_vn': 'Là thành phố của tôi.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '山', 'hiragana': 'やま', 'romaji': 'yama', 'meaning': 'Núi',
          'example_img': 'assets/images/example_yama.png',
          'example_jp': '日本の山です。', 'example_rmj': 'Nihon no yama desu.', 'example_vn': 'Là núi của Nhật Bản.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '町', 'hiragana': 'まち', 'romaji': 'machi', 'options': ['núi', 'biển', 'thành phố', 'sông'], 'answer': 'thành phố'},
        {'type': LessonType.listening, 'options': ['きれい', 'しずか', 'まち', 'やま'], 'answer': 'やま'},

        // ================= PHẦN 2: NGỮ PHÁP =================
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'N + は + Tính từ + です', 'meaning': 'N thì (Đẹp, Nóng, To...)'},
            {'title': 'Tính từ + Danh từ', 'meaning': 'Bổ nghĩa cho danh từ (Người đẹp, Ô tô to)'},
          ]
        },

        // NGỮ PHÁP 1: N は Tính từ です
        {
          'type': LessonType.grammarStructure,
          'title': 'CÂU MIÊU TẢ SỰ VẬT',
          'formula': 'Danh từ + は + Tính từ + です',
          'meaning': 'Danh từ thì (như thế nào đó)'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'N + は + Adj + です',
          'notes': [
            'Dùng để miêu tả tính chất, trạng thái của sự vật, sự việc.',
            'Đối với tính từ đuôi い: Giữ nguyên đuôi い + です (Ví dụ: 大きいです - thì to).',
            'Đối với tính từ đuôi な: Bỏ đuôi な + です (Ví dụ: きれいです - thì đẹp).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'CÂU MIÊU TẢ SỰ VẬT',
          'img': 'assets/images/example_ookii.png',
          'jp': 'この町は大きいです。',
          'rmj': 'Kono machi wa ookii desu.',
          'vn': 'Thành phố này thì lớn.'
        },

        // NGỮ PHÁP 2: Tính từ bổ nghĩa Danh từ
        {
          'type': LessonType.grammarStructure,
          'title': 'TÍNH TỪ BỔ NGHĨA',
          'formula': 'Tính từ + Danh từ',
          'meaning': 'Danh từ (như thế nào đó)'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'Adj + N',
          'notes': [
            'Dùng tính từ đặt TRƯỚC danh từ để làm rõ nghĩa cho danh từ đó.',
            'Tính từ đuôi い: Giữ nguyên đuôi い + Danh từ (Ví dụ: 大きい山 - Ngọn núi to).',
            'Tính từ đuôi な: PHẢI GIỮ LẠI đuôi な + Danh từ (Ví dụ: きれいな町 - Thành phố đẹp).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'TÍNH TỪ BỔ NGHĨA',
          'img': 'assets/images/example_kirei.png',
          'jp': 'きれいな町です。',
          'rmj': 'Kirei na machi desu.',
          'vn': 'Là một thành phố đẹp.'
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
          ]
        }
      ];
    }
  List<Map<String, dynamic>> _getCb8LuyenTap1Data() {
      return [
        {
          'type': LessonType.imageQuiz,
          'question': 'To / Lớn.',
          'answerIndex': 0,
          'options': [
            {'img': 'assets/images/example_ookii.png', 'jp': '大きい', 'rmj': 'ookii'},
            {'img': 'assets/images/example_chiisai.png', 'jp': '小さい', 'rmj': 'chiisai'},
            {'img': 'assets/images/example_atsui.png', 'jp': '暑い', 'rmj': 'atsui'},
            {'img': 'assets/images/example_samui.png', 'jp': '寒い', 'rmj': 'samui'},
          ]
        },
        {
          'type': LessonType.listening,
          'options': [
            {'kanji': '大きい', 'hiragana': 'おおきい'},
            {'kanji': '小さい', 'hiragana': 'ちいさい'},
            {'kanji': '暑い', 'hiragana': 'あつい'},
            {'kanji': '寒い', 'hiragana': 'さむい'},
          ],
          'answer': '小さい'
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
          'answer': '静かな' // Nhấn mạnh đuôi な phải giữ lại khi bổ nghĩa cho danh từ
        },
        {
          'type': LessonType.quiz,
          'question': 'Đây là ngọn núi to.',
          'audio_text': 'これは大きい山です。',
          'options': [
            {'kanji': 'これは小さい山です。', 'hiragana': 'これはちいさいやまです。'},
            {'kanji': 'これは大きい山です。', 'hiragana': 'これはおおきいやまです。'}
          ],
          'answer': 'これは大きい山です。'
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
            '小さい本はこれです。'
          ],
          'answer': 'この本は小さいです。'
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
          ]
        },
      ];
    }
  List<Map<String, dynamic>> _getCb8LuyenNoiData() {
      return [
        {
          'type': LessonType.speaking,
          'jp': '日本は寒いです。',
          'answer': 'にほんはさむいです',
        },
        {
          'type': LessonType.speaking,
          'jp': '大きい犬です。',
          'answer': 'おおきいいぬです',
        },
        {
          'type': LessonType.speaking,
          'jp': 'きれいな町です。',
          'answer': 'きれいなまちです',
        },
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
          'rmj': 'oo(kii) / dai'
        },
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '小さい',
          'kanji_target': '小',
          'meaning': 'Tiểu (Nhỏ / Bé)',
          'rmj': 'chii(sai) / shou'
        },
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '町',
          'kanji_target': '町',
          'meaning': 'Đinh (Thành phố / Thị trấn)',
          'rmj': 'machi'
        },
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '山',
          'kanji_target': '山',
          'meaning': 'Sơn (Núi)',
          'rmj': 'yama / san'
        },
        {
          'type': LessonType.matching,
          'pairs': [
            {'left': 'Đại', 'right': '大'},
            {'left': 'Tiểu', 'right': '小'},
            {'left': 'Đinh', 'right': '町'},
            {'left': 'Sơn', 'right': '山'},
            {'left': 'Thủy', 'right': '水'}, // Ôn lại bài 6
          ]
        },
      ];
    }
  List<Map<String, dynamic>> _getCb9LyThuyetData() {
      return [
        // ================= PHẦN 1: TỪ VỰNG =================
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': 'わかります', 'hiragana': 'わかります', 'romaji': 'wakarimasu', 'meaning': 'Hiểu / Nắm được'},
            {'kanji': '上手[な]', 'hiragana': 'じょうず[な]', 'romaji': 'jouzu [na]', 'meaning': 'Giỏi / Khéo'},
            {'kanji': '下手[な]', 'hiragana': 'へた[な]', 'romaji': 'heta [na]', 'meaning': 'Kém / Dở'},
            {'kanji': '歌', 'hiragana': 'うた', 'romaji': 'uta', 'meaning': 'Bài hát / Việc ca hát'},
            {'kanji': '料理', 'hiragana': 'りょうり', 'romaji': 'ryouri', 'meaning': 'Món ăn / Việc nấu ăn'},
            {'kanji': '忙しい', 'hiragana': 'いそがしい', 'romaji': 'isogashii', 'meaning': 'Bận rộn'},
          ]
        },

        // --- NHÓM TỪ 1: NĂNG LỰC ---
        {
          'type': LessonType.flashCard, 'kanji': 'わかります', 'hiragana': 'わかります', 'romaji': 'wakarimasu', 'meaning': 'Hiểu',
          'example_img': 'assets/images/example_wakarimasu.png',
          'example_jp': '日本語がわかります。', 'example_rmj': 'Nihongo ga wakarimasu.', 'example_vn': 'Tôi hiểu tiếng Nhật.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '上手[な]', 'hiragana': 'じょうず[な]', 'romaji': 'jouzu [na]', 'meaning': 'Giỏi',
          'example_img': 'assets/images/example_jouzu.png',
          'example_jp': '料理が上手です。', 'example_rmj': 'Ryouri ga jouzu desu.', 'example_vn': 'Tôi nấu ăn giỏi.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '下手[な]', 'hiragana': 'へた[な]', 'romaji': 'heta [na]', 'meaning': 'Kém / Dở',
          'example_img': 'assets/images/example_heta.png',
          'example_jp': '歌が下手です。', 'example_rmj': 'Uta ga heta desu.', 'example_vn': 'Tôi hát dở.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '上手', 'hiragana': 'じょうず', 'romaji': 'jouzu', 'options': ['kém', 'giỏi', 'bận rộn', 'hiểu'], 'answer': 'giỏi'},
        {'type': LessonType.listening, 'options': ['わかります', 'じょうず', 'へた', 'いそがしい'], 'answer': 'わかります'},

        // --- NHÓM TỪ 2: DANH TỪ & LÝ DO ---
        {
          'type': LessonType.flashCard, 'kanji': '歌', 'hiragana': 'うた', 'romaji': 'uta', 'meaning': 'Bài hát',
          'example_img': 'assets/images/example_uta.png',
          'example_jp': '日本の歌です。', 'example_rmj': 'Nihon no uta desu.', 'example_vn': 'Là bài hát Nhật Bản.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '料理', 'hiragana': 'りょうり', 'romaji': 'ryouri', 'meaning': 'Việc nấu ăn',
          'example_img': 'assets/images/example_ryouri.png',
          'example_jp': '母の料理です。', 'example_rmj': 'Haha no ryouri desu.', 'example_vn': 'Là món ăn của mẹ.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '忙しい', 'hiragana': 'いそがしい', 'romaji': 'isogashii', 'meaning': 'Bận rộn',
          'example_img': 'assets/images/example_isogashii.png',
          'example_jp': '今日は忙しいです。', 'example_rmj': 'Kyou wa isogashii desu.', 'example_vn': 'Hôm nay tôi bận.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '料理', 'hiragana': 'りょうり', 'romaji': 'ryouri', 'options': ['bài hát', 'việc nấu ăn', 'thành phố', 'công việc'], 'answer': 'việc nấu ăn'},
        {'type': LessonType.listening, 'options': ['うた', 'りょうり', 'いそがしい', 'じょうず'], 'answer': 'いそがしい'},

        // ================= PHẦN 2: NGỮ PHÁP =================
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'N + が + わかります', 'meaning': 'Hiểu / Biết về N'},
            {'title': 'N + が + 上手/下手です', 'meaning': 'Giỏi / Kém về N'},
            {'title': 'Câu 1 + から、Câu 2', 'meaning': 'Vì (Câu 1) nên (Câu 2)'},
          ]
        },

        // NGỮ PHÁP 1: Trợ từ が chỉ năng lực
        {
          'type': LessonType.grammarStructure,
          'title': 'TRỢ TỪ NĂNG LỰC「が」',
          'formula': 'Danh từ + が + わかります / 上手です / 下手です',
          'meaning': 'Hiểu / Giỏi / Kém (cái gì đó)'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'CÁCH DÙNG TRỢ TỪ「が」',
          'notes': [
            'Khác với các động từ hành động dùng trợ từ を, các từ chỉ trạng thái, năng lực (Hiểu, Giỏi, Kém, Thích, Ghét) bắt buộc phải đi với trợ từ が.',
            'Ví dụ: 日本語がわかります (Hiểu tiếng Nhật - Không dùng を).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'TRỢ TỪ「が」',
          'img': 'assets/images/example_jouzu.png',
          'jp': '料理が上手です。',
          'rmj': 'Ryouri ga jouzu desu.',
          'vn': 'Tôi nấu ăn giỏi.'
        },

        // NGỮ PHÁP 2: Liên từ から
        {
          'type': LessonType.grammarStructure,
          'title': 'LIÊN TỪ LÝ DO「から」',
          'formula': 'Mệnh đề 1 (Lý do) + から、Mệnh đề 2 (Kết quả).',
          'meaning': 'Vì... nên...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'CÁCH DÙNG「から」',
          'notes': [
            'Từ 「から」 đặt ở cuối câu lý do để giải thích nguyên nhân.',
            'Chú ý: Trong tiếng Nhật, Lý do luôn đứng trước, Kết quả đứng sau. (Trái ngược với "Nên... Vì..." trong tiếng Việt).',
            'Có thể đứng độc lập: 忙しいですから。(Vì tôi bận.)'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'LIÊN TỪ「から」',
          'img': 'assets/images/example_isogashii.png',
          'jp': '忙しいですから、行きません。',
          'rmj': 'Isogashii desu kara, ikimasen.',
          'vn': 'Vì bận rộn nên tôi không đi.'
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
          ]
        }
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
            {'img': 'assets/images/example_wakarimasu.png', 'jp': 'わかります', 'rmj': 'wakarimasu'},
            {'img': 'assets/images/example_ryouri.png', 'jp': '料理', 'rmj': 'ryouri'},
            {'img': 'assets/images/example_isogashii.png', 'jp': '忙しい', 'rmj': 'isogashii'},
          ]
        },
        {
          'type': LessonType.listening,
          'options': [
            {'kanji': '上手', 'hiragana': 'じょうず'},
            {'kanji': '下手', 'hiragana': 'へた'},
            {'kanji': '忙しい', 'hiragana': 'いそがしい'},
            {'kanji': '歌', 'hiragana': 'うた'},
          ],
          'answer': '下手'
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
          'answer': 'が' // Bẫy kinh điển: nhiều người sẽ chọn を vì nghĩ là hành động
        },
        {
          'type': LessonType.quiz,
          'question': 'Tôi hát dở.',
          'audio_text': '私は歌が下手です。',
          'options': [
            {'kanji': '私は歌が上手です。', 'hiragana': 'わたしはうたがじょうずです。'},
            {'kanji': '私は歌が下手です。', 'hiragana': 'わたしはうたがへたです。'}
          ],
          'answer': '私は歌が下手です。'
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
            '忙しいですから、行きます。'
          ],
          'answer': '忙しいですから、行きません。'
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
          ]
        },
      ];
    }
  List<Map<String, dynamic>> _getCb9LuyenNoiData() {
      return [
        {
          'type': LessonType.speaking,
          'jp': '日本語がわかります。',
          'answer': 'にほんごがわかります',
        },
        {
          'type': LessonType.speaking,
          'jp': '料理が上手です。',
          'answer': 'りょうりがじょうずです',
        },
        {
          'type': LessonType.speaking,
          'jp': '歌が下手です。',
          'answer': 'うたがへたです',
        },
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
          'rmj': 'jou / ue'
        },
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '下手',
          'kanji_target': '下',
          'meaning': 'Hạ (Dưới / Kém)',
          'rmj': 'he / shita'
        },
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '歌',
          'kanji_target': '歌',
          'meaning': 'Ca (Ca hát / Bài hát)',
          'rmj': 'uta'
        },
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '料理',
          'kanji_target': '料',
          'meaning': 'Liệu (Nguyên liệu / Nấu ăn)',
          'rmj': 'ryou'
        },
        {
          'type': LessonType.matching,
          'pairs': [
            {'left': 'Thượng', 'right': '上'},
            {'left': 'Hạ', 'right': '下'},
            {'left': 'Ca', 'right': '歌'},
            {'left': 'Liệu', 'right': '料'},
            {'left': 'Thủ', 'right': '手'}, // Ôn lại chữ "Thủ - Tay" đã học, ghép thành Thượng Thủ (Giỏi)
          ]
        },
      ];
    }
  List<Map<String, dynamic>> _getCb10LyThuyetData() {
      return [
        // ================= PHẦN 1: TỪ VỰNG =================
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': 'あります', 'hiragana': 'あります', 'romaji': 'arimasu', 'meaning': 'Có (Dùng cho đồ vật, cây cối)'},
            {'kanji': 'います', 'hiragana': 'います', 'romaji': 'imasu', 'meaning': 'Có / Ở (Dùng cho người, động vật)'},
            {'kanji': '上', 'hiragana': 'うえ', 'romaji': 'ue', 'meaning': 'Trên'},
            {'kanji': '下', 'hiragana': 'した', 'romaji': 'shita', 'meaning': 'Dưới'},
            {'kanji': '中', 'hiragana': 'なか', 'romaji': 'naka', 'meaning': 'Trong'},
            {'kanji': '外', 'hiragana': 'そと', 'romaji': 'soto', 'meaning': 'Ngoài'},
            {'kanji': '箱', 'hiragana': 'はこ', 'romaji': 'hako', 'meaning': 'Cái hộp'},
          ]
        },

        // --- NHÓM TỪ 1: ĐỘNG TỪ TỒN TẠI ---
        {
          'type': LessonType.flashCard, 'kanji': 'あります', 'hiragana': 'あります', 'romaji': 'arimasu', 'meaning': 'Có (Đồ vật)',
          'example_img': 'assets/images/example_arimasu.png',
          'example_jp': '本があります。', 'example_rmj': 'Hon ga arimasu.', 'example_vn': 'Có quyển sách.'
        },
        {
          'type': LessonType.flashCard, 'kanji': 'います', 'hiragana': 'います', 'romaji': 'imasu', 'meaning': 'Có (Người/Động vật)',
          'example_img': 'assets/images/example_imasu.png',
          'example_jp': '犬がいます。', 'example_rmj': 'Inu ga imasu.', 'example_vn': 'Có con chó.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': 'あります', 'hiragana': 'あります', 'romaji': 'arimasu', 'options': ['có (người)', 'không có', 'có (đồ vật)', 'ăn'], 'answer': 'có (đồ vật)'},

        // --- NHÓM TỪ 2: VỊ TRÍ ---
        {
          'type': LessonType.flashCard, 'kanji': '上', 'hiragana': 'うえ', 'romaji': 'ue', 'meaning': 'Trên',
          'example_img': 'assets/images/example_ue.png',
          'example_jp': '箱の上です。', 'example_rmj': 'Hako no ue desu.', 'example_vn': 'Ở trên cái hộp.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '中', 'hiragana': 'なか', 'romaji': 'naka', 'meaning': 'Trong',
          'example_img': 'assets/images/example_naka.png',
          'example_jp': '箱の中です。', 'example_rmj': 'Hako no naka desu.', 'example_vn': 'Ở trong cái hộp.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '外', 'hiragana': 'そと', 'romaji': 'soto', 'meaning': 'Ngoài',
          'example_img': 'assets/images/example_soto.png',
          'example_jp': '外に犬がいます。', 'example_rmj': 'Soto ni inu ga imasu.', 'example_vn': 'Bên ngoài có con chó.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '中', 'hiragana': 'なか', 'romaji': 'naka', 'options': ['trên', 'ngoài', 'dưới', 'trong'], 'answer': 'trong'},
        {'type': LessonType.listening, 'options': ['うえ', 'した', 'なか', 'そと'], 'answer': 'うえ'},

        // ================= PHẦN 2: NGỮ PHÁP =================
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'N + が + あります / います', 'meaning': 'Có cái gì / Có ai đó'},
            {'title': 'Địa điểm + に + N + が + あります', 'meaning': 'Ở đâu có cái gì'},
            {'title': 'Danh từ + の + Vị trí', 'meaning': 'Trên/Dưới/Trong/Ngoài của cái gì'},
          ]
        },

        // NGỮ PHÁP 1: あります vs います
        {
          'type': LessonType.grammarStructure,
          'title': 'CÂU TỒN TẠI',
          'formula': 'Danh từ + が + あります / います',
          'meaning': 'Có N'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'あります VÀ います',
          'notes': [
            'Dùng để diễn tả sự hiện diện, tồn tại của người hoặc vật. Bắt buộc đi với trợ từ が.',
            'あります: Dùng cho đồ vật vô tri vô giác, cây cối (Sách, xe, cây, nhà).',
            'います: Dùng cho người và động vật có thể tự chuyển động (Bạn bè, chó, mèo).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'CÂU TỒN TẠI',
          'img': 'assets/images/example_imasu.png',
          'jp': '犬がいます。',
          'rmj': 'Inu ga imasu.',
          'vn': 'Có con chó.'
        },

        // NGỮ PHÁP 2: N に N が あります
        {
          'type': LessonType.grammarStructure,
          'title': 'ĐỊA ĐIỂM TỒN TẠI',
          'formula': 'Địa điểm + に + Vật/Người + が + あります/います',
          'meaning': 'Ở (địa điểm) có (vật/người)'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'TRỢ TỪ「に」',
          'notes': [
            'Trợ từ に lúc này mang nghĩa là "Ở / Tại". Nó chỉ ra không gian tồn tại của sự vật.',
            'Ví dụ: 部屋にベッドがあります (Trong phòng có cái giường).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'ĐỊA ĐIỂM TỒN TẠI',
          'img': 'assets/images/example_soto.png',
          'jp': '外に犬がいます。',
          'rmj': 'Soto ni inu ga imasu.',
          'vn': 'Ở bên ngoài có con chó.'
        },

        // NGỮ PHÁP 3: N の Vị trí
        {
          'type': LessonType.grammarStructure,
          'title': 'TỪ CHỈ VỊ TRÍ',
          'formula': 'Danh từ + の + 上 / 下 / 中 / 外',
          'meaning': 'Phía trên/dưới/trong/ngoài của N'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'CÁCH ĐỊNH VỊ',
          'notes': [
            'Trong tiếng Nhật, để nói "Trong cái hộp", ta phải lật ngược lại thành "Cái hộp CỦA bên trong": 箱の中.',
            'Cụm từ này đóng vai trò như một danh từ chỉ địa điểm, có thể đi kèm với trợ từ に.'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'TỪ CHỈ VỊ TRÍ',
          'img': 'assets/images/example_naka.png',
          'jp': '箱の中に本があります。',
          'rmj': 'Hako no naka ni hon ga arimasu.',
          'vn': 'Ở trong hộp có quyển sách.'
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
          ]
        }
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
          ]
        },
        {
          'type': LessonType.listening,
          'options': [
            {'kanji': 'あります', 'hiragana': 'あります'},
            {'kanji': 'います', 'hiragana': 'います'},
            {'kanji': '箱', 'hiragana': 'はこ'},
            {'kanji': '中', 'hiragana': 'なか'},
          ],
          'answer': '箱'
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
          'answer': 'います' // Mèo là động vật
        },
        {
          'type': LessonType.quiz,
          'question': 'Điền từ đúng (Có ô tô): \n車が ( ... )。',
          'options': ['あります', 'います', 'です', 'わかります'],
          'answer': 'あります' // Ô tô là vật vô tri
        },
        {
          'type': LessonType.quiz,
          'question': 'Bên ngoài có con chó.',
          'audio_text': '外に犬がいます。',
          'options': [
            {'kanji': '外に犬があります。', 'hiragana': 'そとにいぬがあります。'},
            {'kanji': '外に犬がいます。', 'hiragana': 'そとにいぬがいます。'}
          ],
          'answer': '外に犬がいます。'
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
          'answer': 'に'
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
          ]
        },
      ];
    }
  List<Map<String, dynamic>> _getCb10LuyenNoiData() {
      return [
        {
          'type': LessonType.speaking,
          'jp': '本があります。',
          'answer': 'ほんがあります',
        },
        {
          'type': LessonType.speaking,
          'jp': '犬がいます。',
          'answer': 'いぬがいます',
        },
        {
          'type': LessonType.speaking,
          'jp': '箱の中です。',
          'answer': 'はこのなかです',
        },
        {
          'type': LessonType.speaking,
          'jp': '箱の上に本があります。',
          'answer': 'はこのうえにほんがあります',
        },
        {
          'type': LessonType.speaking,
          'jp': '外に犬がいます。',
          'answer': 'そとにいぬがいます',
        },
      ];
    }
  List<Map<String, dynamic>> _getCb10LuyenVietData() {
      return [
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '上',
          'kanji_target': '上',
          'meaning': 'Thượng (Trên)',
          'rmj': 'ue / jou'
        },
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '下',
          'kanji_target': '下',
          'meaning': 'Hạ (Dưới)',
          'rmj': 'shita / ge'
        },
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '中',
          'kanji_target': '中',
          'meaning': 'Trung (Trong / Giữa)',
          'rmj': 'naka / chuu'
        },
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '外',
          'kanji_target': '外',
          'meaning': 'Ngoại (Ngoài)',
          'rmj': 'soto / gai'
        },
        {
          'type': LessonType.matching,
          'pairs': [
            {'left': 'Thượng', 'right': '上'},
            {'left': 'Hạ', 'right': '下'},
            {'left': 'Trung', 'right': '中'},
            {'left': 'Ngoại', 'right': '外'},
            {'left': 'Hộp', 'right': '箱'}, // Có thể vẽ thêm hoặc chỉ ghép chữ
          ]
        },
      ];
    }
  List<Map<String, dynamic>> _getN4Bai1LyThuyetData() {
      return [
        // ================= PHẦN 1: TỪ VỰNG =================
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': '泳ぎます', 'hiragana': 'およぎます', 'romaji': 'oyogimasu', 'meaning': 'Bơi'},
            {'kanji': '弾きます', 'hiragana': 'ひきます', 'romaji': 'hikimasu', 'meaning': 'Chơi (nhạc cụ)'},
            {'kanji': '走ります', 'hiragana': 'はしります', 'romaji': 'hashirimasu', 'meaning': 'Chạy'},
            {'kanji': 'ピアノ', 'hiragana': 'ピアノ', 'romaji': 'piano', 'meaning': 'Đàn Piano'},
            {'kanji': 'ギター', 'hiragana': 'ギター', 'romaji': 'gitaa', 'meaning': 'Đàn Guitar'},
            {'kanji': '海', 'hiragana': 'うみ', 'romaji': 'umi', 'meaning': 'Biển'},
          ]
        },

        // --- NHÓM TỪ 1: ĐỘNG TỪ ---
        {
          'type': LessonType.flashCard, 'kanji': '泳ぎます', 'hiragana': 'およぎます', 'romaji': 'oyogimasu', 'meaning': 'Bơi',
          'example_img': 'assets/images/example_oyogimasu.png',
          'example_jp': '海で泳ぎます。', 'example_rmj': 'Umi de oyogimasu.', 'example_vn': 'Tôi bơi ở biển.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '弾きます', 'hiragana': 'ひきます', 'romaji': 'hikimasu', 'meaning': 'Chơi (nhạc cụ)',
          'example_img': 'assets/images/example_hikimasu.png',
          'example_jp': 'ギターを弾きます。', 'example_rmj': 'Gitaa o hikimasu.', 'example_vn': 'Tôi chơi đàn guitar.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '走ります', 'hiragana': 'はしります', 'romaji': 'hashirimasu', 'options': ['bơi', 'đi bộ', 'chạy', 'hát'], 'answer': 'chạy'},

        // --- NHÓM TỪ 2: DANH TỪ ---
        {
          'type': LessonType.flashCard, 'kanji': '海', 'hiragana': 'うみ', 'romaji': 'umi', 'meaning': 'Biển',
          'example_img': 'assets/images/example_umi.png',
          'example_jp': 'きれいな海です。', 'example_rmj': 'Kirei na umi desu.', 'example_vn': 'Là bãi biển đẹp.'
        },
        {
          'type': LessonType.flashCard, 'kanji': 'ピアノ', 'hiragana': 'ピアノ', 'romaji': 'piano', 'meaning': 'Đàn Piano',
          'example_img': 'assets/images/example_piano.png',
          'example_jp': 'これはピアノです。', 'example_rmj': 'Kore wa piano desu.', 'example_vn': 'Đây là đàn piano.'
        },
        {'type': LessonType.listening, 'options': ['うみ', 'ピアノ', 'ギター', 'はしります'], 'answer': 'ギター'},

        // ================= PHẦN 2: NGỮ PHÁP =================
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'V (Thể Khả năng)', 'meaning': 'Cách chia động từ Thể Khả Năng'},
            {'title': 'N + が + V(Khả năng)', 'meaning': 'Có thể làm N'},
          ]
        },

        // NGỮ PHÁP 1: Cách chia Thể Khả Năng
        {
          'type': LessonType.grammarStructure,
          'title': 'CÁCH CHIA THỂ KHẢ NĂNG',
          'formula': 'Nhóm 1: cột [i] ➔ [e] ます\nNhóm 2: bỏ ます ➔ られます',
          'meaning': 'Có thể ~'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'THỂ KHẢ NĂNG (可能形)',
          'notes': [
            'Dùng để diễn tả năng lực hoặc một khả năng có thể thực hiện được.',
            'Ví dụ Nhóm 1: 泳ぎます (oyogi-masu) ➔ 泳げます (oyoge-masu): Có thể bơi.',
            'Ví dụ Nhóm 2: 食べます (tabe-masu) ➔ 食べられます (taberare-masu): Có thể ăn.',
            'Nhóm 3: します ➔ できます (Có thể làm) / 来ます ➔ 来られます (Có thể đến).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'THỂ KHẢ NĂNG',
          'img': 'assets/images/example_oyogemasu.png',
          'jp': '私は泳げます。',
          'rmj': 'Watashi wa oyogemasu.',
          'vn': 'Tôi CÓ THỂ bơi.'
        },

        // NGỮ PHÁP 2: Trợ từ が
        {
          'type': LessonType.grammarStructure,
          'title': 'TRỢ TỪ TRONG THỂ KHẢ NĂNG',
          'formula': 'Danh từ + が + V-khả năng',
          'meaning': 'Có thể làm (cái gì đó)'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'ĐỔI TRỢ TỪ を THÀNH が',
          'notes': [
            'Đây là quy tắc cực kỳ quan trọng của N4!',
            'Khi động từ chuyển sang thể khả năng, tân ngữ đi kèm sẽ KHÔNG dùng trợ từ を nữa, mà phải đổi sang trợ từ が.',
            'Các trợ từ khác (như に, で, へ) vẫn giữ nguyên.'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'TRỢ TỪ 「が」',
          'img': 'assets/images/example_piano.png',
          'jp': 'ピアノが弾けます。',
          'rmj': 'Piano ga hikemasu.',
          'vn': 'Tôi có thể chơi piano. (Không dùng ピアノを)'
        },

        // ================= PHẦN 3: TỔNG KẾT =================
        {
          'type': LessonType.vocabSummary,
          'words': [
            {'kanji': '泳ぎます', 'romaji': 'oyogimasu', 'meaning': 'bơi'},
            {'kanji': '泳げます', 'romaji': 'oyogemasu', 'meaning': 'có thể bơi'},
            {'kanji': '弾きます', 'romaji': 'hikimasu', 'meaning': 'chơi nhạc cụ'},
            {'kanji': '弾けます', 'romaji': 'hikemasu', 'meaning': 'có thể chơi'},
            {'kanji': 'ピアノ', 'romaji': 'piano', 'meaning': 'đàn piano'},
            {'kanji': '海', 'romaji': 'umi', 'meaning': 'biển'},
          ]
        }
      ];
    }
  List<Map<String, dynamic>> _getN4Bai1LuyenTap1Data() {
      return [
        {
          'type': LessonType.imageQuiz,
          'question': 'Biển.',
          'answerIndex': 3,
          'options': [
            {'img': 'assets/images/example_piano.png', 'jp': 'ピアノ', 'rmj': 'piano'},
            {'img': 'assets/images/example_gitaa.png', 'jp': 'ギター', 'rmj': 'gitaa'},
            {'img': 'assets/images/example_oyogimasu.png', 'jp': '泳ぎます', 'rmj': 'oyogimasu'},
            {'img': 'assets/images/example_umi.png', 'jp': '海', 'rmj': 'umi'},
          ]
        },
        {
          'type': LessonType.listening,
          'options': [
            {'kanji': '泳ぎます', 'hiragana': 'およぎます'},
            {'kanji': '弾きます', 'hiragana': 'ひきます'},
            {'kanji': '走ります', 'hiragana': 'はしります'},
            {'kanji': 'ギター', 'hiragana': 'ギター'},
          ],
          'answer': '弾きます'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '海で泳ぎます。',
          'rmj': 'Umi de oyogimasu.',
          'audio_text': '海で泳ぎます。',
          'words': ['biển', 'tại', 'bơi', 'chạy', 'đàn'],
          'answer': 'bơi tại biển',
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': 'ギターを弾きます。',
          'words': ['ギター', 'を', '弾きます', 'ピアノ', 'が'],
          'answer': 'ギター を 弾きます',
        },
      ];
    }
  List<Map<String, dynamic>> _getN4Bai1LuyenTap2Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Thể khả năng của 泳ぎます (Bơi) là gì?',
          'options': ['泳ぎられます', '泳げます', '泳ぐます', '泳ぎません'],
          'answer': '泳げます'
        },
        {
          'type': LessonType.quiz,
          'question': 'Tôi có thể chạy.',
          'audio_text': '私は走れます。',
          'options': [
            {'kanji': '私は走ります。', 'hiragana': 'わたしははしります。'},
            {'kanji': '私は走れます。', 'hiragana': 'わたしははしれます。'}
          ],
          'answer': '私は走れます。'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '海で泳げます。',
          'words': ['海', 'で', '泳げます', '泳ぎます', 'に'],
          'answer': '海 で 泳げます',
        },
      ];
    }
  List<Map<String, dynamic>> _getN4Bai1LuyenTap3Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền trợ từ đúng (Có thể chơi Piano): \nピアノ ( ... ) 弾けます。',
          'options': ['を', 'に', 'が', 'で'],
          'answer': 'が' // Bẫy kinh điển:を đổi thành が
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '私はギターが弾けます。',
          'words': ['私', 'は', 'ギター', 'が', '弾けます', 'を', '弾きます'], // Gây nhiễu bằng を và động từ thường
          'answer': '私 は ギター が 弾けます',
        },
        {
          'type': LessonType.matching,
          'pairs': [
            {'left': 'Bơi', 'right': '泳ぎます'},
            {'left': 'Có thể bơi', 'right': '泳げます'},
            {'left': 'Chơi đàn', 'right': '弾きます'},
            {'left': 'Có thể chơi', 'right': '弾けます'},
            {'left': 'Biển', 'right': '海'},
          ]
        },
      ];
    }
  List<Map<String, dynamic>> _getN4Bai1LuyenNoiData() {
      return [
        {
          'type': LessonType.speaking,
          'jp': '海で泳ぎます。',
          'answer': 'うみでおよぎます',
        },
        {
          'type': LessonType.speaking,
          'jp': '海で泳げます。',
          'answer': 'うみでおよげます', // Luyện phát âm khác biệt oyogimasu vs oyogemasu
        },
        {
          'type': LessonType.speaking,
          'jp': 'ギターを弾きます。',
          'answer': 'ぎたーをひきます',
        },
        {
          'type': LessonType.speaking,
          'jp': 'ギターが弾けます。',
          'answer': 'ぎたーがひけます', // Luyện đổi trợ từ o thành ga
        },
        {
          'type': LessonType.speaking,
          'jp': '私は走れます。',
          'answer': 'わたしははしれます',
        },
      ];
    }
  List<Map<String, dynamic>> _getN4Bai1LuyenVietData() {
      return [
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '泳ぎます',
          'kanji_target': '泳',
          'meaning': 'Vịnh (Bơi lội)',
          'rmj': 'oyo(gimasu)'
        },
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '弾きます',
          'kanji_target': '弾',
          'meaning': 'Đàn (Đánh đàn)',
          'rmj': 'hi(kimasu)'
        },
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '走ります',
          'kanji_target': '走',
          'meaning': 'Tẩu (Chạy)',
          'rmj': 'hashi(rimasu)'
        },
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '海',
          'kanji_target': '海',
          'meaning': 'Hải (Biển)',
          'rmj': 'umi / kai'
        },
        {
          'type': LessonType.matching,
          'pairs': [
            {'left': 'Vịnh (Bơi)', 'right': '泳'},
            {'left': 'Đàn (Chơi)', 'right': '弾'},
            {'left': 'Tẩu (Chạy)', 'right': '走'},
            {'left': 'Hải (Biển)', 'right': '海'},
            {'left': 'Thủy (Nước)', 'right': '水'}, // Ôn tập liên kết (Nước -> Biển, Bơi)
          ]
        },
      ];
    }
  List<Map<String, dynamic>> _getN4Bai2LyThuyetData() {
      return [
        // ================= PHẦN 1: TỪ VỰNG =================
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': '音楽', 'hiragana': 'おんがく', 'romaji': 'ongaku', 'meaning': 'Âm nhạc'},
            {'kanji': '聞きます', 'hiragana': 'ききます', 'romaji': 'kikimasu', 'meaning': 'Nghe'},
            {'kanji': '歩きます', 'hiragana': 'あるきます', 'romaji': 'arukimasu', 'meaning': 'Đi bộ'},
            {'kanji': '働きます', 'hiragana': 'はたらきます', 'romaji': 'hatarakimasu', 'meaning': 'Làm việc'},
            {'kanji': '熱心[な]', 'hiragana': 'ねっしん[な]', 'romaji': 'nesshin [na]', 'meaning': 'Nhiệt tình / Chăm chỉ'},
            {'kanji': '真面目[な]', 'hiragana': 'まじめ[な]', 'romaji': 'majime [na]', 'meaning': 'Nghiêm túc / Đứng đắn'},
          ]
        },

        // --- NHÓM TỪ 1: ĐỘNG TỪ & DANH TỪ ---
        {
          'type': LessonType.flashCard, 'kanji': '音楽', 'hiragana': 'おんがく', 'romaji': 'ongaku', 'meaning': 'Âm nhạc',
          'example_img': 'assets/images/example_ongaku.png',
          'example_jp': '音楽が好きです。', 'example_rmj': 'Ongaku ga suki desu.', 'example_vn': 'Tôi thích âm nhạc.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '聞きます', 'hiragana': 'ききます', 'romaji': 'kikimasu', 'meaning': 'Nghe',
          'example_img': 'assets/images/example_kikimasu.png',
          'example_jp': '音楽を聞きます。', 'example_rmj': 'Ongaku o kikimasu.', 'example_vn': 'Tôi nghe nhạc.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '歩きます', 'hiragana': 'あるきます', 'romaji': 'arukimasu', 'meaning': 'Đi bộ',
          'example_img': 'assets/images/example_arukimasu.png',
          'example_jp': '公園を歩きます。', 'example_rmj': 'Kouen o arukimasu.', 'example_vn': 'Tôi đi bộ ở công viên.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '働きます', 'hiragana': 'はたらきます', 'romaji': 'hatarakimasu', 'options': ['ngủ', 'làm việc', 'đi bộ', 'nghe'], 'answer': 'làm việc'},

        // --- NHÓM TỪ 2: TÍNH TỪ ---
        {
          'type': LessonType.flashCard, 'kanji': '熱心[な]', 'hiragana': 'ねっしん', 'romaji': 'nesshin', 'meaning': 'Nhiệt tình',
          'example_img': 'assets/images/example_nesshin.png',
          'example_jp': '熱心な先生です。', 'example_rmj': 'Nesshin na sensei desu.', 'example_vn': 'Là giáo viên nhiệt tình.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '真面目[な]', 'hiragana': 'まじめ', 'romaji': 'majime', 'meaning': 'Nghiêm túc',
          'example_img': 'assets/images/example_majime.png',
          'example_jp': '彼は真面目です。', 'example_rmj': 'Kare wa majime desu.', 'example_vn': 'Anh ấy rất nghiêm túc.'
        },
        {'type': LessonType.listening, 'options': ['おんがく', 'ねっしん', 'まじめ', 'ききます'], 'answer': 'まじめ'},

        // ================= PHẦN 2: NGỮ PHÁP =================
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'V1(bỏ ます) + ながら V2', 'meaning': 'Vừa làm V1 vừa làm V2'},
            {'title': 'V-ています', 'meaning': 'Thói quen lặp đi lặp lại'},
            {'title': 'Câu 1 + し、Câu 2 + し、~', 'meaning': 'Không những... mà còn...'},
          ]
        },

        // NGỮ PHÁP 1: ながら
        {
          'type': LessonType.grammarStructure,
          'title': 'HÀNH ĐỘNG ĐỒNG THỜI',
          'formula': 'V1 (bỏ ます) + ながら、V2',
          'meaning': 'Vừa làm V1 vừa làm V2'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'CẤU TRÚC ながら',
          'notes': [
            'Dùng để diễn tả một chủ thể thực hiện đồng thời hai hành động.',
            'Hành động chính sẽ được đặt ở V2 (phía sau). Hành động phụ đặt ở V1.',
            'Ví dụ: 聞きます (Nghe) -> 聞きながら (Vừa nghe...).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'HÀNH ĐỘNG ĐỒNG THỜI',
          'img': 'assets/images/example_nagara.png',
          'jp': '音楽を聞きながら、歩きます。',
          'rmj': 'Ongaku o kikinagara, arukimasu.',
          'vn': 'Tôi VỪA nghe nhạc VỪA đi bộ.'
        },

        // NGỮ PHÁP 2: Liệt kê し
        {
          'type': LessonType.grammarStructure,
          'title': 'CẤU TRÚC LIỆT KÊ 「し」',
          'formula': 'Thể thông thường + し、~',
          'meaning': 'Vừa... vừa... / Không những... mà còn...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'CÁCH DÙNG TRỢ TỪ「し」',
          'notes': [
            'Dùng để liệt kê nhiều lý do, hoặc nhiều đặc điểm của một sự vật/sự việc.',
            'Tính từ đuôi [な] và Danh từ phải thêm [だ] trước [し]: 真面目だ + し.',
            'Thường đi kèm với trợ từ も (cũng).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'CẤU TRÚC LIỆT KÊ 「し」',
          'img': 'assets/images/example_shi.png',
          'jp': '彼は熱心だし、真面目です。',
          'rmj': 'Kare wa nesshin da shi, majime desu.',
          'vn': 'Anh ấy KHÔNG NHỮNG nhiệt tình MÀ CÒN nghiêm túc.'
        },

        // ================= PHẦN 3: TỔNG KẾT =================
        {
          'type': LessonType.vocabSummary,
          'words': [
            {'kanji': '音楽', 'romaji': 'ongaku', 'meaning': 'âm nhạc'},
            {'kanji': '聞きます', 'romaji': 'kikimasu', 'meaning': 'nghe'},
            {'kanji': '歩きます', 'romaji': 'arukimasu', 'meaning': 'đi bộ'},
            {'kanji': '働きます', 'romaji': 'hatarakimasu', 'meaning': 'làm việc'},
            {'kanji': '熱心', 'romaji': 'nesshin', 'meaning': 'nhiệt tình'},
            {'kanji': '真面目', 'romaji': 'majime', 'meaning': 'nghiêm túc'},
          ]
        }
      ];
    }
  List<Map<String, dynamic>> _getN4Bai2LuyenTap1Data() {
      return [
        {
          'type': LessonType.imageQuiz,
          'question': 'Âm nhạc.',
          'answerIndex': 0,
          'options': [
            {'img': 'assets/images/example_ongaku.png', 'jp': '音楽', 'rmj': 'ongaku'},
            {'img': 'assets/images/example_kikimasu.png', 'jp': '聞きます', 'rmj': 'kikimasu'},
            {'img': 'assets/images/example_arukimasu.png', 'jp': '歩きます', 'rmj': 'arukimasu'},
            {'img': 'assets/images/example_hatarakimasu.png', 'jp': '働きます', 'rmj': 'hatarakimasu'},
          ]
        },
        {
          'type': LessonType.listening,
          'options': [
            {'kanji': '音楽', 'hiragana': 'おんがく'},
            {'kanji': '熱心', 'hiragana': 'ねっしん'},
            {'kanji': '真面目', 'hiragana': 'まじめ'},
            {'kanji': '聞きます', 'hiragana': 'ききます'},
          ],
          'answer': '熱心'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '音楽を聞きながら歩きます。',
          'rmj': 'Ongaku o kikinagara arukimasu.',
          'audio_text': '音楽を聞きながら歩きます。',
          'words': ['vừa', 'nghe', 'nhạc', 'đi bộ', 'làm việc'],
          'answer': 'vừa nghe nhạc vừa đi bộ',
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': 'テレビを見ながらご飯を食べます。', // Dùng từ bài cũ để test ながら
          'words': ['テレビ', 'を', '見ながら', 'ご飯', 'を', '食べます', '見ます'],
          'answer': 'テレビ を 見ながら ご飯 を 食べます',
        },
      ];
    }
  List<Map<String, dynamic>> _getN4Bai2LuyenTap2Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Cấu trúc し ghép với tính từ đuôi [な] như thế nào?',
          'options': ['真面目し', '真面目だだし', '真面目だし', '真面目なし'],
          'answer': '真面目だし'
        },
        {
          'type': LessonType.quiz,
          'question': 'Anh ấy vừa nhiệt tình vừa nghiêm túc.',
          'audio_text': '彼は熱心だし、真面目です。',
          'options': [
            {'kanji': '彼は熱心だし、真面目です。', 'hiragana': 'かれはねっしんだし、まじめです。'},
            {'kanji': '彼は熱心し、真面目です。', 'hiragana': 'かれはねっしんし、まじめです。'}
          ],
          'answer': '彼は熱心だし、真面目です。'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '彼は真面目だし、働きます。',
          'words': ['彼', 'は', '真面目だ', 'し', '働きます', '歩きます', 'が'],
          'answer': '彼 は 真面目だ し 働きます',
        },
      ];
    }
  List<Map<String, dynamic>> _getN4Bai2LuyenTap3Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền từ đúng (Vừa làm việc vừa nghe nhạc): \n音楽を ( ... ) 働きます。',
          'options': ['聞くながら', '聞きながら', '聞こながら', '聞いてながら'],
          'answer': '聞きながら'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '音楽が好きだし、歌が上手です。', // Ghép kiến thức bài 9 (N5) với し
          'words': ['音楽', 'が', '好きだ', 'し', '歌', 'が', '上手', 'です'],
          'answer': '音楽 が 好きだ し 歌 が 上手 です',
        },
        {
          'type': LessonType.matching,
          'pairs': [
            {'left': 'Âm nhạc', 'right': '音楽'},
            {'left': 'Nghe', 'right': '聞きます'},
            {'left': 'Đi bộ', 'right': '歩きます'},
            {'left': 'Làm việc', 'right': '働きます'},
            {'left': 'Nghiêm túc', 'right': '真面目'},
          ]
        },
      ];
    }
  List<Map<String, dynamic>> _getN4Bai2LuyenNoiData() {
      return [
        {
          'type': LessonType.speaking,
          'jp': '音楽を聞きます。',
          'answer': 'おんがくをききます',
        },
        {
          'type': LessonType.speaking,
          'jp': '音楽を聞きながら歩きます。',
          'answer': 'おんがくをききながらあるきます',
        },
        {
          'type': LessonType.speaking,
          'jp': '毎日働きます。',
          'answer': 'まいにちはたらきます',
        },
        {
          'type': LessonType.speaking,
          'jp': '熱心な人です。',
          'answer': 'ねっしんなひとです',
        },
        {
          'type': LessonType.speaking,
          'jp': '彼は熱心だし、真面目です。',
          'answer': 'かれはねっしんだしまじめです',
        },
      ];
    }
  List<Map<String, dynamic>> _getN4Bai2LuyenVietData() {
      return [
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '音楽',
          'kanji_target': '音',
          'meaning': 'Âm (Âm thanh)',
          'rmj': 'on / oto'
        },
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '音楽',
          'kanji_target': '楽',
          'meaning': 'Nhạc (Âm nhạc / Vui vẻ)',
          'rmj': 'gaku / tano(shii)'
        },
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '聞きます',
          'kanji_target': '聞',
          'meaning': 'Văn (Nghe / Hỏi)',
          'rmj': 'ki(kimasu) / bun'
        },
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '歩きます',
          'kanji_target': '歩',
          'meaning': 'Bộ (Đi bộ)',
          'rmj': 'aru(kimasu) / ho'
        },
        {
          'type': LessonType.matching,
          'pairs': [
            {'left': 'Âm', 'right': '音'},
            {'left': 'Nhạc', 'right': '楽'},
            {'left': 'Văn (Nghe)', 'right': '聞'},
            {'left': 'Bộ (Đi bộ)', 'right': '歩'},
            {'left': 'Tẩu (Chạy)', 'right': '走'}, // Ôn chữ của Bài 1 N4
          ]
        },
      ];
    }
  List<Map<String, dynamic>> _getN4Bai3LyThuyetData() {
      return [
        // ================= PHẦN 1: TỪ VỰNG =================
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': '調べます', 'hiragana': 'しらべます', 'romaji': 'shirabemasu', 'meaning': 'Tìm hiểu / Điều tra'},
            {'kanji': '作ります', 'hiragana': 'つくります', 'romaji': 'tsukurimasu', 'meaning': 'Làm / Chế tạo / Sáng lập'},
            {'kanji': '辞めます', 'hiragana': 'やめます', 'romaji': 'yamemasu', 'meaning': 'Nghỉ (việc) / Bỏ'},
            {'kanji': '将来', 'hiragana': 'しょうらい', 'romaji': 'shourai', 'meaning': 'Tương lai'},
            {'kanji': '夢', 'hiragana': 'ゆめ', 'romaji': 'yume', 'meaning': 'Giấc mơ'},
            {'kanji': '会社', 'hiragana': 'かいしゃ', 'romaji': 'kaisha', 'meaning': 'Công ty'},
          ]
        },

        // --- NHÓM TỪ 1: ĐỘNG TỪ ---
        {
          'type': LessonType.flashCard, 'kanji': '調べます', 'hiragana': 'しらべます', 'romaji': 'shirabemasu', 'meaning': 'Tìm hiểu',
          'example_img': 'assets/images/example_shirabemasu.png',
          'example_jp': '自分で調べます。', 'example_rmj': 'Jibun de shirabemasu.', 'example_vn': 'Tôi tự mình tìm hiểu.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '作ります', 'hiragana': 'つくります', 'romaji': 'tsukurimasu', 'meaning': 'Làm / Chế tạo',
          'example_img': 'assets/images/example_tsukurimasu.png',
          'example_jp': '会社を作ります。', 'example_rmj': 'Kaisha o tsukurimasu.', 'example_vn': 'Tôi thành lập công ty.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '辞めます', 'hiragana': 'やめます', 'romaji': 'yamemasu', 'options': ['nghỉ (việc)', 'tìm hiểu', 'làm việc', 'chế tạo'], 'answer': 'nghỉ (việc)'},

        // --- NHÓM TỪ 2: DANH TỪ ---
        {
          'type': LessonType.flashCard, 'kanji': '将来', 'hiragana': 'しょうらい', 'romaji': 'shourai', 'meaning': 'Tương lai',
          'example_img': 'assets/images/example_shourai.png',
          'example_jp': '将来、日本へ行きます。', 'example_rmj': 'Shourai, Nihon e ikimasu.', 'example_vn': 'Tương lai tôi sẽ đi Nhật.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '夢', 'hiragana': 'ゆめ', 'romaji': 'yume', 'meaning': 'Giấc mơ',
          'example_img': 'assets/images/example_yume.png',
          'example_jp': '私の夢です。', 'example_rmj': 'Watashi no yume desu.', 'example_vn': 'Đó là giấc mơ của tôi.'
        },
        {'type': LessonType.listening, 'options': ['しょうらい', 'ゆめ', 'かいしゃ', 'しらべます'], 'answer': 'かいしゃ'},

        // ================= PHẦN 2: NGỮ PHÁP =================
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'Thể ý hướng (〜よう)', 'meaning': 'Cùng làm... nào! (Thể ngắn của ましょう)'},
            {'title': 'V(ý hướng) + と思っています', 'meaning': 'Đang định làm gì'},
            {'title': 'V(rự/nai) + つもりです', 'meaning': 'Định làm / Không định làm gì'},
          ]
        },

        // NGỮ PHÁP 1: Thể ý hướng
        {
          'type': LessonType.grammarStructure,
          'title': 'THỂ Ý HƯỚNG (〜よう)',
          'formula': 'Nhóm 1: cột [i] ➔ [o] + う\nNhóm 2: bỏ ます ➔ よう',
          'meaning': 'Cùng làm... / Sẽ làm...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'CÁCH DÙNG THỂ Ý HƯỚNG',
          'notes': [
            'Là cách nói thân mật của 〜ましょう (Cùng làm nhé).',
            'Dùng để tự nhủ với bản thân hoặc rủ rê bạn bè thân thiết.',
            'Ví dụ: 行きます ➔ 行こう (Đi thôi!)',
            'Ví dụ: 食べます ➔ 食べよう (Ăn thôi!)'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'THỂ Ý HƯỚNG',
          'img': 'assets/images/example_ikou.png',
          'jp': '将来、日本へ行こう。',
          'rmj': 'Shourai, Nihon e ikou.',
          'vn': 'Tương lai, hãy đến Nhật Bản nào!'
        },

        // NGỮ PHÁP 2: と思っています
        {
          'type': LessonType.grammarStructure,
          'title': 'NÓI VỀ DỰ ĐỊNH',
          'formula': 'V (Thể ý hướng) + と思っています',
          'meaning': 'Tôi (đang) định làm...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': '〜と思っています',
          'notes': [
            'Dùng để bày tỏ ý định, kế hoạch đã được suy nghĩ từ trước và hiện tại vẫn đang giữ ý định đó.',
            'Ví dụ: 作ろうと思っています (Tôi đang định tạo ra...).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'DỰ ĐỊNH',
          'img': 'assets/images/example_omotteimasu.png',
          'jp': '会社を作ろうと思っています。',
          'rmj': 'Kaisha o tsukurou to omotteimasu.',
          'vn': 'Tôi đang định thành lập công ty.'
        },

        // NGỮ PHÁP 3: つもりです
        {
          'type': LessonType.grammarStructure,
          'title': 'Ý ĐỊNH CHẮC CHẮN',
          'formula': 'V(từ điển) / V(ない) + つもりです',
          'meaning': 'Tôi định / Tôi không định làm...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': '〜つもりです',
          'notes': [
            'Giống với と思っています nhưng つもり mang sắc thái chắc chắn hơn, là một kế hoạch rõ ràng.',
            'Để nói "Không định làm", ta dùng động từ chia về thể ない + つもりです.',
            'Ví dụ: 辞めるつもりです (Tôi định nghỉ việc).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'Ý ĐỊNH CHẮC CHẮN',
          'img': 'assets/images/example_tsumori.png',
          'jp': '会社を辞めるつもりです。',
          'rmj': 'Kaisha o yameru tsumori desu.',
          'vn': 'Tôi định nghỉ việc ở công ty.'
        },

        // ================= PHẦN 3: TỔNG KẾT =================
        {
          'type': LessonType.vocabSummary,
          'words': [
            {'kanji': '調べます', 'romaji': 'shirabemasu', 'meaning': 'tìm hiểu'},
            {'kanji': '作ります', 'romaji': 'tsukurimasu', 'meaning': 'làm/chế tạo'},
            {'kanji': '辞めます', 'romaji': 'yamemasu', 'meaning': 'nghỉ (việc)'},
            {'kanji': '将来', 'romaji': 'shourai', 'meaning': 'tương lai'},
            {'kanji': '夢', 'romaji': 'yume', 'meaning': 'giấc mơ'},
            {'kanji': '会社', 'romaji': 'kaisha', 'meaning': 'công ty'},
          ]
        }
      ];
    }
  List<Map<String, dynamic>> _getN4Bai3LuyenTap1Data() {
      return [
        {
          'type': LessonType.imageQuiz,
          'question': 'Công ty.',
          'answerIndex': 2,
          'options': [
            {'img': 'assets/images/example_yume.png', 'jp': '夢', 'rmj': 'yume'},
            {'img': 'assets/images/example_shourai.png', 'jp': '将来', 'rmj': 'shourai'},
            {'img': 'assets/images/example_kaisha.png', 'jp': '会社', 'rmj': 'kaisha'},
            {'img': 'assets/images/example_shirabemasu.png', 'jp': '調べます', 'rmj': 'shirabemasu'},
          ]
        },
        {
          'type': LessonType.listening,
          'options': [
            {'kanji': '作ります', 'hiragana': 'つくります'},
            {'kanji': '辞めます', 'hiragana': 'やめます'},
            {'kanji': '将来', 'hiragana': 'しょうらい'},
            {'kanji': '夢', 'hiragana': 'ゆめ'},
          ],
          'answer': '夢'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '会社を作ります。',
          'rmj': 'Kaisha o tsukurimasu.',
          'audio_text': '会社を作ります。',
          'words': ['công ty', 'thành lập', 'giấc mơ', 'của', 'tương lai'],
          'answer': 'thành lập công ty',
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '自分で調べます。',
          'words': ['自分', 'で', '調べます', '作ります', 'が'],
          'answer': '自分 で 調べます',
        },
      ];
    }
  List<Map<String, dynamic>> _getN4Bai3LuyenTap2Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Thể ý hướng của 行きます (Đi) là gì?',
          'options': ['行こう', '行くよう', '行かよう', '行こ'],
          'answer': '行こう'
        },
        {
          'type': LessonType.quiz,
          'question': 'Tôi định thành lập công ty.',
          'audio_text': '会社を作ろうと思っています。',
          'options': [
            {'kanji': '会社を作ろうと思っています。', 'hiragana': 'かいしゃをつくろうとおもっています。'},
            {'kanji': '会社を作ると思っています。', 'hiragana': 'かいしゃをつくるとおもっています。'}
          ],
          'answer': '会社を作ろうと思っています。'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '日本へ行こう。',
          'words': ['日本', 'へ', '行こう', '行きます', 'が'],
          'answer': '日本 へ 行こう',
        },
      ];
    }
  List<Map<String, dynamic>> _getN4Bai3LuyenTap3Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền từ đúng (Tôi định nghỉ việc): \n会社を辞める ( ... ) です。',
          'options': ['よう', 'つもり', 'から', 'し'],
          'answer': 'つもり'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '将来、会社を辞めるつもりです。',
          'words': ['将来', '会社', 'を', '辞める', 'つもり', 'です', '辞めよう'],
          'answer': '将来 会社 を 辞める つもり です',
        },
        {
          'type': LessonType.matching,
          'pairs': [
            {'left': 'Tìm hiểu', 'right': '調べます'},
            {'left': 'Thành lập', 'right': '作ります'},
            {'left': 'Nghỉ việc', 'right': '辞めます'},
            {'left': 'Tương lai', 'right': '将来'},
            {'left': 'Giấc mơ', 'right': '夢'},
          ]
        },
      ];
    }
  List<Map<String, dynamic>> _getN4Bai3LuyenNoiData() {
      return [
        {
          'type': LessonType.speaking,
          'jp': '将来、日本へ行こう。',
          'answer': 'しょうらいにほんへいこう',
        },
        {
          'type': LessonType.speaking,
          'jp': '会社を作ろうと思っています。',
          'answer': 'かいしゃをつくろうとおもっています',
        },
        {
          'type': LessonType.speaking,
          'jp': '会社を辞めるつもりです。',
          'answer': 'かいしゃをやめるつもりです',
        },
        {
          'type': LessonType.speaking,
          'jp': '夢は何ですか。',
          'answer': 'ゆめはなんですか',
        },
        {
          'type': LessonType.speaking,
          'jp': '自分で調べます。',
          'answer': 'じぶんでしらべます',
        },
      ];
    }
  List<Map<String, dynamic>> _getN4Bai3LuyenVietData() {
      return [
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '夢',
          'kanji_target': '夢',
          'meaning': 'Mộng (Giấc mơ)',
          'rmj': 'yume'
        },
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '会社',
          'kanji_target': '会',
          'meaning': 'Hội (Gặp gỡ / Hội họp)',
          'rmj': 'kai / a(imasu)'
        },
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '会社',
          'kanji_target': '社',
          'meaning': 'Xã (Công ty / Xã hội)',
          'rmj': 'sha'
        },
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '作ります',
          'kanji_target': '作',
          'meaning': 'Tác (Chế tạo / Làm)',
          'rmj': 'tsuku(rimasu)'
        },
        {
          'type': LessonType.matching,
          'pairs': [
            {'left': 'Mộng', 'right': '夢'},
            {'left': 'Hội', 'right': '会'},
            {'left': 'Xã', 'right': '社'},
            {'left': 'Tác', 'right': '作'},
            {'left': 'Lai (Tương lai)', 'right': '来'}, // Ôn chữ "Lai" (Đến) đã học ở N5, ghép thành Tương Lai
          ]
        },
      ];
    }
  List<Map<String, dynamic>> _getN4Bai4LyThuyetData() {
      return [
        // ================= PHẦN 1: TỪ VỰNG =================
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': '運動します', 'hiragana': 'うんどうします', 'romaji': 'undoushimasu', 'meaning': 'Vận động / Tập thể dục'},
            {'kanji': '休みます', 'hiragana': 'やすみます', 'romaji': 'yasumimasu', 'meaning': 'Nghỉ ngơi'},
            {'kanji': '薬', 'hiragana': 'くすり', 'romaji': 'kusuri', 'meaning': 'Thuốc'},
            {'kanji': '病気', 'hiragana': 'びょうき', 'romaji': 'byouki', 'meaning': 'Ốm / Bệnh'},
            {'kanji': '熱', 'hiragana': 'ねつ', 'romaji': 'netsu', 'meaning': 'Sốt'},
            {'kanji': '多分', 'hiragana': 'たぶん', 'romaji': 'tabun', 'meaning': 'Có lẽ'},
          ]
        },

        // --- NHÓM TỪ 1: ĐỘNG TỪ ---
        {
          'type': LessonType.flashCard, 'kanji': '運動します', 'hiragana': 'うんどうします', 'romaji': 'undoushimasu', 'meaning': 'Vận động',
          'example_img': 'assets/images/example_undou.png',
          'example_jp': '毎日、運動します。', 'example_rmj': 'Mainichi, undou shimasu.', 'example_vn': 'Mỗi ngày tôi đều tập thể dục.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '休みます', 'hiragana': 'やすみます', 'romaji': 'yasumimasu', 'meaning': 'Nghỉ ngơi',
          'example_img': 'assets/images/example_yasumimasu.png',
          'example_jp': '少し休みます。', 'example_rmj': 'Sukoshi yasumimasu.', 'example_vn': 'Tôi nghỉ ngơi một chút.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '運動します', 'hiragana': 'うんどうします', 'romaji': 'undoushimasu', 'options': ['nghỉ ngơi', 'vận động', 'uống thuốc', 'bệnh'], 'answer': 'vận động'},

        // --- NHÓM TỪ 2: SỨC KHỎE & TÌNH TRẠNG ---
        {
          'type': LessonType.flashCard, 'kanji': '薬', 'hiragana': 'くすり', 'romaji': 'kusuri', 'meaning': 'Thuốc',
          'example_img': 'assets/images/example_kusuri.png',
          'example_jp': '薬を飲みます。', 'example_rmj': 'Kusuri o nomimasu.', 'example_vn': 'Tôi uống thuốc.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '熱', 'hiragana': 'ねつ', 'romaji': 'netsu', 'meaning': 'Sốt',
          'example_img': 'assets/images/example_netsu.png',
          'example_jp': '熱があります。', 'example_rmj': 'Netsu ga arimasu.', 'example_vn': 'Tôi bị sốt.'
        },
        {'type': LessonType.listening, 'options': ['くすり', 'ねつ', 'びょうき', 'たぶん'], 'answer': 'くすり'},

        // ================= PHẦN 2: NGỮ PHÁP =================
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'V(た) / V(ない) + ほうがいいです', 'meaning': 'Nên / Không nên làm gì'},
            {'title': 'Thể thông thường + かもしれません', 'meaning': 'Có lẽ là... / Biết đâu là...'},
          ]
        },

        // NGỮ PHÁP 1: LỜI KHUYÊN
        {
          'type': LessonType.grammarStructure,
          'title': 'LỜI KHUYÊN',
          'formula': 'V(た) + ほうがいいです\nV(ない) + ほうがいいです',
          'meaning': 'Nên / Không nên...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': '〜ほうがいいです',
          'notes': [
            'Dùng để khuyên bảo ai đó một cách nhẹ nhàng nhưng mang tính cảnh báo nếu không làm theo thì sẽ không tốt.',
            'Nên làm: Dùng động từ chia ở thể QUÁ KHỨ (た) + ほうがいいです.',
            'Không nên làm: Dùng động từ chia ở thể PHỦ ĐỊNH (ない) + ほうがいいです.'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'LỜI KHUYÊN',
          'img': 'assets/images/example_yasunda.png',
          'jp': '少し休んだほうがいいです。',
          'rmj': 'Sukoshi yasunda hou ga ii desu.',
          'vn': 'Bạn nên nghỉ ngơi một chút.'
        },

        // NGỮ PHÁP 2: PHỎNG ĐOÁN
        {
          'type': LessonType.grammarStructure,
          'title': 'PHỎNG ĐOÁN',
          'formula': 'Động từ/Tính từ/Danh từ (thể thông thường) + かもしれません',
          'meaning': 'Có lẽ là... (Khả năng 50%)'
        },
        {
          'type': LessonType.grammarUsage,
          'title': '〜かもしれません',
          'notes': [
            'Dùng để phỏng đoán một việc gì đó có thể xảy ra, dù xác suất không cao (khoảng 50%).',
            'Lưu ý: Với Danh từ và Tính từ đuôi [な], ta bỏ [だ] rồi ghép trực tiếp với かもしれません.',
            'Ví dụ: 病気かもしれません (Có lẽ là bị bệnh).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'PHỎNG ĐOÁN',
          'img': 'assets/images/example_tabun.png',
          'jp': '明日は雨かもしれません。',
          'rmj': 'Ashita wa ame kamo shiremasen.',
          'vn': 'Ngày mai có lẽ trời sẽ mưa.'
        },

        // ================= PHẦN 3: TỔNG KẾT =================
        {
          'type': LessonType.vocabSummary,
          'words': [
            {'kanji': '運動します', 'romaji': 'undoushimasu', 'meaning': 'vận động'},
            {'kanji': '休みます', 'romaji': 'yasumimasu', 'meaning': 'nghỉ ngơi'},
            {'kanji': '薬', 'romaji': 'kusuri', 'meaning': 'thuốc'},
            {'kanji': '病気', 'romaji': 'byouki', 'meaning': 'bệnh'},
            {'kanji': '熱', 'romaji': 'netsu', 'meaning': 'sốt'},
            {'kanji': '多分', 'romaji': 'tabun', 'meaning': 'có lẽ'},
          ]
        }
      ];
    }
  List<Map<String, dynamic>> _getN4Bai4LuyenTap1Data() {
      return [
        {
          'type': LessonType.imageQuiz,
          'question': 'Thuốc.',
          'answerIndex': 1,
          'options': [
            {'img': 'assets/images/example_netsu.png', 'jp': '熱', 'rmj': 'netsu'},
            {'img': 'assets/images/example_kusuri.png', 'jp': '薬', 'rmj': 'kusuri'},
            {'img': 'assets/images/example_byouki.png', 'jp': '病気', 'rmj': 'byouki'},
            {'img': 'assets/images/example_yasumimasu.png', 'jp': '休みます', 'rmj': 'yasumimasu'},
          ]
        },
        {
          'type': LessonType.listening,
          'options': [
            {'kanji': '休んだ', 'hiragana': 'やすんだ'},
            {'kanji': '飲んだ', 'hiragana': 'のんだ'},
            {'kanji': '多分', 'hiragana': 'たぶん'},
            {'kanji': '熱', 'hiragana': 'ねつ'},
          ],
          'answer': '休んだ'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '薬を飲みます。',
          'rmj': 'Kusuri o nomimasu.',
          'audio_text': '薬を飲みます。',
          'words': ['thuốc', 'uống', 'sốt', 'bệnh', 'nghỉ ngơi'],
          'answer': 'uống thuốc',
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '熱があります。',
          'words': ['熱', 'が', 'あります', '薬', '病気'],
          'answer': '熱 が あります',
        },
      ];
    }
  List<Map<String, dynamic>> _getN4Bai4LuyenTap2Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền vào chỗ trống (Bạn NÊN uống thuốc): \n薬を ( ... ) ほうがいいです。',
          'options': ['飲む', '飲んだ', '飲んで', '飲まない'],
          'answer': '飲んだ' // Bẫy: Khuyên NÊN thì phải dùng thể TA
        },
        {
          'type': LessonType.quiz,
          'question': 'Bạn không nên vận động.',
          'audio_text': '運動しないほうがいいです。',
          'options': [
            {'kanji': '運動したほうがいいです。', 'hiragana': 'うんどうしたほうがいいです。'},
            {'kanji': '運動しないほうがいいです。', 'hiragana': 'うんどうしないほうがいいです。'}
          ],
          'answer': '運動しないほうがいいです。'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '少し休んだほうがいいです。',
          'words': ['少し', '休んだ', 'ほう', 'が', 'いい', 'です', '休まない'],
          'answer': '少し 休んだ ほう が いい です',
        },
      ];
    }
  List<Map<String, dynamic>> _getN4Bai4LuyenTap3Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền từ đúng (Có lẽ là bị bệnh): \n病気 ( ... )。',
          'options': ['だかもしれません', 'かもしれません', 'なかもしれません', 'のかもしれません'],
          'answer': 'かもしれません' // Nhấn mạnh danh từ ghép thẳng, không thêm だ hay な
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '多分、明日は雨かもしれません。',
          'words': ['多分', '明日', 'は', '雨', 'かもしれません', 'です', 'が'],
          'answer': '多分 明日 は 雨 かもしれません',
        },
        {
          'type': LessonType.matching,
          'pairs': [
            {'left': 'Vận động', 'right': '運動します'},
            {'left': 'Nghỉ ngơi', 'right': '休みます'},
            {'left': 'Sốt', 'right': '熱'},
            {'left': 'Bệnh', 'right': '病気'},
            {'left': 'Có lẽ', 'right': '多分'},
          ]
        },
      ];
    }
  List<Map<String, dynamic>> _getN4Bai4LuyenNoiData() {
      return [
        {
          'type': LessonType.speaking,
          'jp': '熱があります。',
          'answer': 'ねつがあります',
        },
        {
          'type': LessonType.speaking,
          'jp': '休んだほうがいいです。',
          'answer': 'やすんだほうがいいです',
        },
        {
          'type': LessonType.speaking,
          'jp': '運動しないほうがいいです。',
          'answer': 'うんどうしないほうがいいです',
        },
        {
          'type': LessonType.speaking,
          'jp': '病気かもしれません。',
          'answer': 'びょうきかもしれません',
        },
        {
          'type': LessonType.speaking,
          'jp': '多分、雨かもしれません。',
          'answer': 'たぶんあめかもしれません',
        },
      ];
    }
  List<Map<String, dynamic>> _getN4Bai4LuyenVietData() {
      return [
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '運動',
          'kanji_target': '運',
          'meaning': 'Vận (Vận chuyển / Vận mệnh)',
          'rmj': 'un / hako(bu)'
        },
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '運動',
          'kanji_target': '動',
          'meaning': 'Động (Chuyển động)',
          'rmj': 'dou / ugo(ku)'
        },
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '薬',
          'kanji_target': '薬',
          'meaning': 'Dược (Thuốc)',
          'rmj': 'kusuri / yaku'
        },
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '病気',
          'kanji_target': '病',
          'meaning': 'Bệnh (Ốm / Bệnh tật)',
          'rmj': 'byou / ya(mai)'
        },
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '病気',
          'kanji_target': '気',
          'meaning': 'Khí (Không khí / Tinh thần)',
          'rmj': 'ki'
        },
        {
          'type': LessonType.matching,
          'pairs': [
            {'left': 'Vận', 'right': '運'},
            {'left': 'Động', 'right': '動'},
            {'left': 'Dược', 'right': '薬'},
            {'left': 'Bệnh', 'right': '病'},
            {'left': 'Khí', 'right': '気'},
          ]
        },
      ];
    }
    List<Map<String, dynamic>> _getN4Bai5LyThuyetData() {
      return [
        // ================= PHẦN 1: TỪ VỰNG =================
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': '降ります', 'hiragana': 'ふります', 'romaji': 'furimasu', 'meaning': 'Rơi (mưa, tuyết)'},
            {'kanji': '考えます', 'hiragana': 'かんがえます', 'romaji': 'kangaemasu', 'meaning': 'Suy nghĩ'},
            {'kanji': '足ります', 'hiragana': 'たります', 'romaji': 'tarimasu', 'meaning': 'Đủ'},
            {'kanji': '雨', 'hiragana': 'あめ', 'romaji': 'ame', 'meaning': 'Mưa'},
            {'kanji': 'お金', 'hiragana': 'おかね', 'romaji': 'okane', 'meaning': 'Tiền'},
            {'kanji': 'いくら', 'hiragana': 'いくら', 'romaji': 'ikura', 'meaning': 'Bao nhiêu (giá cả / mức độ)'},
          ]
        },

        // --- NHÓM TỪ 1: ĐỘNG TỪ ---
        {
          'type': LessonType.flashCard, 'kanji': '降ります', 'hiragana': 'ふります', 'romaji': 'furimasu', 'meaning': 'Rơi',
          'example_img': 'assets/images/example_ame.png',
          'example_jp': '雨が降ります。', 'example_rmj': 'Ame ga furimasu.', 'example_vn': 'Trời mưa (Mưa rơi).'
        },
        {
          'type': LessonType.flashCard, 'kanji': '考えます', 'hiragana': 'かんがえます', 'romaji': 'kangaemasu', 'meaning': 'Suy nghĩ',
          'example_img': 'assets/images/example_kangaemasu.png',
          'example_jp': '自分で考えます。', 'example_rmj': 'Jibun de kangaemasu.', 'example_vn': 'Tôi tự mình suy nghĩ.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '足ります', 'hiragana': 'たります', 'romaji': 'tarimasu', 'meaning': 'Đủ',
          'example_img': 'assets/images/example_tarimasu.png',
          'example_jp': 'お金が足ります。', 'example_rmj': 'Okane ga tarimasu.', 'example_vn': 'Tiền đã đủ.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '考えます', 'hiragana': 'かんがえます', 'romaji': 'kangaemasu', 'options': ['rơi', 'suy nghĩ', 'đủ', 'vận động'], 'answer': 'suy nghĩ'},

        // --- NHÓM TỪ 2: DANH TỪ & PHÓ TỪ ---
        {
          'type': LessonType.flashCard, 'kanji': 'お金', 'hiragana': 'おかね', 'romaji': 'okane', 'meaning': 'Tiền',
          'example_img': 'assets/images/example_okane.png',
          'example_jp': 'お金がありません。', 'example_rmj': 'Okane ga arimasen.', 'example_vn': 'Tôi không có tiền.'
        },
        {
          'type': LessonType.flashCard, 'kanji': 'いくら', 'hiragana': 'いくら', 'romaji': 'ikura', 'meaning': 'Cho dù bao nhiêu...',
          'example_img': 'assets/images/example_ikura_temo.png',
          'example_jp': 'いくら考えても...', 'example_rmj': 'Ikura kangaetemo...', 'example_vn': 'Cho dù nghĩ bao nhiêu đi nữa...'
        },
        {'type': LessonType.listening, 'options': ['あめ', 'おかね', 'いくら', 'たります'], 'answer': 'おかね'},

        // ================= PHẦN 2: NGỮ PHÁP =================
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'V(た) + ら', 'meaning': 'Nếu... / Sau khi...'},
            {'title': 'V(て) + も', 'meaning': 'Cho dù... thì vẫn...'},
          ]
        },

        // NGỮ PHÁP 1: Điều kiện たら
        {
          'type': LessonType.grammarStructure,
          'title': 'CÂU ĐIỀU KIỆN (たら)',
          'formula': 'Động từ thể QUÁ KHỨ (た) + ら、～',
          'meaning': 'Nếu (điều kiện) / Sau khi (thời gian)'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'CẤU TRÚC 〜たら',
          'notes': [
            'Dùng để giả định một điều kiện. Nếu điều kiện đó xảy ra thì kết quả phía sau sẽ xảy ra.',
            'Ví dụ: 降ります ➔ 降った ➔ 降ったら (Nếu trời mưa...).',
            'Còn mang nghĩa "Sau khi": 10時になったら、寝ます (Sau khi đến 10 giờ, tôi sẽ ngủ).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'ĐIỀU KIỆN',
          'img': 'assets/images/example_futtara.png',
          'jp': '雨が降ったら、行きません。',
          'rmj': 'Ame ga futtara, ikimasen.',
          'vn': 'Nếu trời mưa, tôi sẽ không đi.'
        },

        // NGỮ PHÁP 2: Nhượng bộ ても
        {
          'type': LessonType.grammarStructure,
          'title': 'CÂU NHƯỢNG BỘ (ても)',
          'formula': 'Động từ thể TE (て) + も、～',
          'meaning': 'Cho dù... thì vẫn...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'CẤU TRÚC 〜ても',
          'notes': [
            'Ý nghĩa hoàn toàn trái ngược với 〜たら. Diễn tả một hành động vẫn xảy ra bất chấp điều kiện bất lợi.',
            'Ví dụ: 降ります ➔ 降って ➔ 降っても (Cho dù trời mưa...).',
            'Thường đi kèm với từ để hỏi「いくら」(Cho dù... bao nhiêu đi nữa).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'NHƯỢNG BỘ',
          'img': 'assets/images/example_futtemo.png',
          'jp': '雨が降っても、行きます。',
          'rmj': 'Ame ga futtemo, ikimasu.',
          'vn': 'Cho dù trời mưa, tôi vẫn sẽ đi.'
        },

        // ================= PHẦN 3: TỔNG KẾT =================
        {
          'type': LessonType.vocabSummary,
          'words': [
            {'kanji': '降ります', 'romaji': 'furimasu', 'meaning': 'rơi (mưa)'},
            {'kanji': '考えます', 'romaji': 'kangaemasu', 'meaning': 'suy nghĩ'},
            {'kanji': '足ります', 'romaji': 'tarimasu', 'meaning': 'đủ'},
            {'kanji': '雨', 'romaji': 'ame', 'meaning': 'mưa'},
            {'kanji': 'お金', 'romaji': 'okane', 'meaning': 'tiền'},
            {'kanji': 'いくら', 'romaji': 'ikura', 'meaning': 'bao nhiêu'},
          ]
        }
      ];
    }
  List<Map<String, dynamic>> _getN4Bai5LuyenTap1Data() {
      return [
        {
          'type': LessonType.imageQuiz,
          'question': 'Tiền.',
          'answerIndex': 2,
          'options': [
            {'img': 'assets/images/example_ame.png', 'jp': '雨', 'rmj': 'ame'},
            {'img': 'assets/images/example_kangaemasu.png', 'jp': '考えます', 'rmj': 'kangaemasu'},
            {'img': 'assets/images/example_okane.png', 'jp': 'お金', 'rmj': 'okane'},
            {'img': 'assets/images/example_tarimasu.png', 'jp': '足ります', 'rmj': 'tarimasu'},
          ]
        },
        {
          'type': LessonType.listening,
          'options': [
            {'kanji': '雨', 'hiragana': 'あめ'},
            {'kanji': '降ります', 'hiragana': 'ふります'},
            {'kanji': '考えます', 'hiragana': 'かんがえます'},
            {'kanji': 'お金', 'hiragana': 'おかね'},
          ],
          'answer': '降ります'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': 'お金が足ります。',
          'rmj': 'Okane ga tarimasu.',
          'audio_text': 'お金が足ります。',
          'words': ['tiền', 'thì', 'đủ', 'mưa', 'suy nghĩ'],
          'answer': 'tiền thì đủ',
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '自分で考えます。',
          'words': ['自分', 'で', '考えます', 'お金', 'が'],
          'answer': '自分 で 考えます',
        },
      ];
    }
  List<Map<String, dynamic>> _getN4Bai5LuyenTap2Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Cấu trúc "Nếu có tiền" là gì?',
          'options': ['お金があってら', 'お金があったら', 'お金があるたら', 'お金がありましたら'],
          'answer': 'お金があったら' // Chuyển あります -> あった -> あったら
        },
        {
          'type': LessonType.quiz,
          'question': 'Nếu trời mưa, tôi sẽ không đi.',
          'audio_text': '雨が降ったら、行きません。',
          'options': [
            {'kanji': '雨が降ったら、行きません。', 'hiragana': 'あめがふったら、いきません。'},
            {'kanji': '雨が降っても、行きません。', 'hiragana': 'あめがふっても、いきません。'}
          ],
          'answer': '雨が降ったら、行きません。'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': 'お金があったら、車を買います。',
          'words': ['お金', 'が', 'あったら', '車', 'を', '買います', '降ったら'],
          'answer': 'お金 が あったら 車 を 買います',
        },
      ];
    }
  List<Map<String, dynamic>> _getN4Bai5LuyenTap3Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền từ đúng (Cho dù mưa, vẫn đi): \n雨が ( ... ) 、行きます。',
          'options': ['降ったら', '降って', '降っても', '降るも'],
          'answer': '降っても'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': 'いくら考えても、わかりません。', // Khớp với từ vựng wakarimasu đã học ở N5
          'words': ['いくら', '考えても', 'わかりません', 'お金', '足ります'],
          'answer': 'いくら 考えても わかりません',
        },
        {
          'type': LessonType.matching,
          'pairs': [
            {'left': 'Rơi (Mưa)', 'right': '降ります'},
            {'left': 'Suy nghĩ', 'right': '考えます'},
            {'left': 'Đủ', 'right': '足ります'},
            {'left': 'Mưa', 'right': '雨'},
            {'left': 'Tiền', 'right': 'お金'},
          ]
        },
      ];
    }
  List<Map<String, dynamic>> _getN4Bai5LuyenNoiData() {
      return [
        {
          'type': LessonType.speaking,
          'jp': '雨が降ります。',
          'answer': 'あめがふります',
        },
        {
          'type': LessonType.speaking,
          'jp': '雨が降ったら、行きません。',
          'answer': 'あめがふったらいきません',
        },
        {
          'type': LessonType.speaking,
          'jp': '雨が降っても、行きます。',
          'answer': 'あめがふってもいきます', // So sánh trực tiếp たら và ても
        },
        {
          'type': LessonType.speaking,
          'jp': 'お金があったら、買います。',
          'answer': 'おかねがあったらかいます',
        },
        {
          'type': LessonType.speaking,
          'jp': 'いくら考えても、わかりません。',
          'answer': 'いくらかんがえてもわかりません',
        },
      ];
    }
  List<Map<String, dynamic>> _getN4Bai5LuyenVietData() {
      return [
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '雨',
          'kanji_target': '雨',
          'meaning': 'Vũ (Mưa)',
          'rmj': 'ame / u'
        },
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '降ります',
          'kanji_target': '降',
          'meaning': 'Giáng (Rơi xuống / Giáng chức)',
          'rmj': 'fu(rimasu) / o(rimasu)'
        },
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '考えます',
          'kanji_target': '考',
          'meaning': 'Khảo (Suy nghĩ / Khảo sát)',
          'rmj': 'kanga(emasu) / kou'
        },
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': 'お金',
          'kanji_target': '金',
          'meaning': 'Kim (Tiền / Vàng)',
          'rmj': 'kane / kin'
        },
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '足ります',
          'kanji_target': '足',
          'meaning': 'Túc (Đầy đủ / Cái chân)',
          'rmj': 'ta(rimasu) / ashi'
        },
        {
          'type': LessonType.matching,
          'pairs': [
            {'left': 'Vũ', 'right': '雨'},
            {'left': 'Giáng', 'right': '降'},
            {'left': 'Khảo', 'right': '考'},
            {'left': 'Kim', 'right': '金'},
            {'left': 'Túc', 'right': '足'},
          ]
        },
      ];
    }
  List<Map<String, dynamic>> _getN4Bai6LyThuyetData() {
      return [
        // ================= PHẦN 1: TỪ VỰNG =================
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': '褒めます', 'hiragana': 'ほめます', 'romaji': 'homemasu', 'meaning': 'Khen ngợi'},
            {'kanji': '叱ります', 'hiragana': 'しかります', 'romaji': 'shikarimasu', 'meaning': 'Mắng / La'},
            {'kanji': '踏みます', 'hiragana': 'ふみます', 'romaji': 'fumimasu', 'meaning': 'Giẫm / Đạp lên'},
            {'kanji': '先生', 'hiragana': 'せんせい', 'romaji': 'sensei', 'meaning': 'Giáo viên'},
            {'kanji': '子供', 'hiragana': 'こども', 'romaji': 'kodomo', 'meaning': 'Trẻ con'},
            {'kanji': '足', 'hiragana': 'あし', 'romaji': 'ashi', 'meaning': 'Chân'},
          ]
        },

        // --- NHÓM TỪ 1: ĐỘNG TỪ TƯƠNG TÁC ---
        {
          'type': LessonType.flashCard, 'kanji': '褒めます', 'hiragana': 'ほめます', 'romaji': 'homemasu', 'meaning': 'Khen',
          'example_img': 'assets/images/example_homemasu.png',
          'example_jp': '先生が褒めます。', 'example_rmj': 'Sensei ga homemasu.', 'example_vn': 'Giáo viên khen ngợi.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '叱ります', 'hiragana': 'しかります', 'romaji': 'shikarimasu', 'meaning': 'Mắng',
          'example_img': 'assets/images/example_shikarimasu.png',
          'example_jp': '母が叱ります。', 'example_rmj': 'Haha ga shikarimasu.', 'example_vn': 'Mẹ mắng.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '踏みます', 'hiragana': 'ふみます', 'romaji': 'fumimasu', 'options': ['ngủ', 'khen', 'giẫm / đạp', 'mắng'], 'answer': 'giẫm / đạp'},

        // --- NHÓM TỪ 2: ĐỐI TƯỢNG ---
        {
          'type': LessonType.flashCard, 'kanji': '先生', 'hiragana': 'せんせい', 'romaji': 'sensei', 'meaning': 'Giáo viên',
          'example_img': 'assets/images/example_sensei.png',
          'example_jp': '日本語の先生です。', 'example_rmj': 'Nihongo no sensei desu.', 'example_vn': 'Là giáo viên tiếng Nhật.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '足', 'hiragana': 'あし', 'romaji': 'ashi', 'meaning': 'Chân',
          'example_img': 'assets/images/example_ashi.png',
          'example_jp': '私の足です。', 'example_rmj': 'Watashi no ashi desu.', 'example_vn': 'Là chân của tôi.'
        },
        {'type': LessonType.listening, 'options': ['せんせい', 'こども', 'あし', 'ほめます'], 'answer': 'こども'},

        // ================= PHẦN 2: NGỮ PHÁP =================
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'V (Thể Bị động)', 'meaning': 'Cách chia động từ Thể Bị Động'},
            {'title': 'A は B に + V(bị động)', 'meaning': 'A bị/được B làm gì'},
            {'title': 'A は B に (Bộ phận) を + V(bị động)', 'meaning': 'Bị tác động vào bộ phận cơ thể'},
          ]
        },

        // NGỮ PHÁP 1: CÁCH CHIA THỂ BỊ ĐỘNG
        {
          'type': LessonType.grammarStructure,
          'title': 'THỂ BỊ ĐỘNG',
          'formula': 'Nhóm 1: cột [i] ➔ [a] + れます\nNhóm 2: bỏ ます ➔ られます',
          'meaning': 'Bị... / Được...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'CÁCH CHIA',
          'notes': [
            'Ví dụ Nhóm 1: 叱ります ➔ 叱られます (Bị mắng). 踏みます ➔ 踏まれます (Bị giẫm).',
            'Ví dụ Nhóm 2: 褒めます ➔ 褒められます (Được khen).',
            'Nhóm 3: します ➔ されます / 来ます ➔ 来られます (Koraremasu).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'THỂ BỊ ĐỘNG',
          'img': 'assets/images/example_homeraremasu.png',
          'jp': '褒められます。',
          'rmj': 'Homeraremasu.',
          'vn': 'Được khen ngợi.'
        },

        // NGỮ PHÁP 2: CẤU TRÚC BỊ ĐỘNG CƠ BẢN
        {
          'type': LessonType.grammarStructure,
          'title': 'CÂU BỊ ĐỘNG TRỰC TIẾP',
          'formula': 'Người nhận + は + Người làm + に + V(bị động)',
          'meaning': 'Bị / Được ai đó làm gì'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG TRỢ TỪ に',
          'notes': [
            'Chủ ngữ (đi với は) là người chịu tác động.',
            'Người gây ra hành động được đánh dấu bằng trợ từ に.',
            'Dịch là "Được" nếu là việc tốt (khen), dịch là "Bị" nếu là việc xấu (mắng).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'BỊ ĐỘNG',
          'img': 'assets/images/example_shikararemasu.png',
          'jp': '私は母に叱られました。',
          'rmj': 'Watashi wa haha ni shikararemashita.',
          'vn': 'Tôi bị mẹ mắng.'
        },

        // NGỮ PHÁP 3: BỊ ĐỘNG GIÁN TIẾP (BỘ PHẬN)
        {
          'type': LessonType.grammarStructure,
          'title': 'BỊ ĐỘNG BỘ PHẬN',
          'formula': 'A は + B に + Danh từ (bộ phận) を + V(bị động)',
          'meaning': 'A bị B làm gì đó vào (bộ phận)'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'TÁC ĐỘNG VÀO SỞ HỮU',
          'notes': [
            'Khi ai đó làm gì ảnh hưởng đến bộ phận cơ thể hoặc đồ vật của mình, ta dùng cấu trúc này.',
            'Bộ phận cơ thể hoặc đồ vật đi với trợ từ を.'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'BỊ ĐỘNG BỘ PHẬN',
          'img': 'assets/images/example_fumaremasu.png',
          'jp': '私は犬に足を踏まれました。',
          'rmj': 'Watashi wa inu ni ashi o fumaremashita.',
          'vn': 'Tôi bị con chó giẫm vào chân.'
        },

        // ================= PHẦN 3: TỔNG KẾT =================
        {
          'type': LessonType.vocabSummary,
          'words': [
            {'kanji': '褒めます', 'romaji': 'homemasu', 'meaning': 'khen'},
            {'kanji': '叱ります', 'romaji': 'shikarimasu', 'meaning': 'mắng'},
            {'kanji': '踏みます', 'romaji': 'fumimasu', 'meaning': 'giẫm'},
            {'kanji': '先生', 'romaji': 'sensei', 'meaning': 'giáo viên'},
            {'kanji': '子供', 'romaji': 'kodomo', 'meaning': 'trẻ con'},
            {'kanji': '足', 'romaji': 'ashi', 'meaning': 'chân'},
          ]
        }
      ];
    }
  List<Map<String, dynamic>> _getN4Bai6LuyenTap1Data() {
      return [
        {
          'type': LessonType.imageQuiz,
          'question': 'Giáo viên.',
          'answerIndex': 0,
          'options': [
            {'img': 'assets/images/example_sensei.png', 'jp': '先生', 'rmj': 'sensei'},
            {'img': 'assets/images/example_kodomo.png', 'jp': '子供', 'rmj': 'kodomo'},
            {'img': 'assets/images/example_ashi.png', 'jp': '足', 'rmj': 'ashi'},
            {'img': 'assets/images/example_homemasu.png', 'jp': '褒めます', 'rmj': 'homemasu'},
          ]
        },
        {
          'type': LessonType.listening,
          'options': [
            {'kanji': '褒めます', 'hiragana': 'ほめます'},
            {'kanji': '叱ります', 'hiragana': 'しかります'},
            {'kanji': '踏みます', 'hiragana': 'ふみます'},
            {'kanji': '先生', 'hiragana': 'せんせい'},
          ],
          'answer': '叱ります'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '先生が褒めます。',
          'rmj': 'Sensei ga homemasu.',
          'audio_text': '先生が褒めます。',
          'words': ['giáo viên', 'thì', 'khen', 'mắng', 'giẫm'],
          'answer': 'giáo viên khen',
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '犬が足を踏みます。',
          'words': ['犬', 'が', '足', 'を', '踏みます', '褒めます'],
          'answer': '犬 が 足 を 踏みます',
        },
      ];
    }
  List<Map<String, dynamic>> _getN4Bai6LuyenTap2Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Thể bị động của 叱ります (Mắng) là gì?',
          'options': ['叱らます', '叱られます', '叱れます', '叱りられます'],
          'answer': '叱られます'
        },
        {
          'type': LessonType.quiz,
          'question': 'Tôi ĐƯỢC giáo viên khen.',
          'audio_text': '私は先生に褒められました。',
          'options': [
            {'kanji': '私は先生に褒めました。', 'hiragana': 'わたしはせんせいにほめました。'},
            {'kanji': '私は先生に褒められました。', 'hiragana': 'わたしはせんせいにほめられました。'}
          ],
          'answer': '私は先生に褒められました。'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '母に叱られました。',
          'words': ['母', 'に', '叱られました', '叱りました', 'が'],
          'answer': '母 に 叱られました',
        },
      ];
    }
  List<Map<String, dynamic>> _getN4Bai6LuyenTap3Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền trợ từ đúng (Bị chó giẫm VÀO CHÂN): \n犬に足 ( ... ) 踏まれました。',
          'options': ['に', 'が', 'を', 'で'],
          'answer': 'を'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '私は子供に足を踏まれました。',
          'words': ['私', 'は', '子供', 'に', '足', 'を', '踏まれました'],
          'answer': '私 は 子供 に 足 を 踏まれました',
        },
        {
          'type': LessonType.matching,
          'pairs': [
            {'left': 'Khen', 'right': '褒めます'},
            {'left': 'Được khen', 'right': '褒められます'},
            {'left': 'Mắng', 'right': '叱ります'},
            {'left': 'Bị mắng', 'right': '叱られます'},
            {'left': 'Chân', 'right': '足'},
          ]
        },
      ];
    }
  List<Map<String, dynamic>> _getN4Bai6LuyenNoiData() {
      return [
        {
          'type': LessonType.speaking,
          'jp': '先生に褒められました。',
          'answer': 'せんせいにほめられました',
        },
        {
          'type': LessonType.speaking,
          'jp': '母に叱られました。',
          'answer': 'ははにしかられました',
        },
        {
          'type': LessonType.speaking,
          'jp': '足を踏まれました。',
          'answer': 'あしをふまれました',
        },
        {
          'type': LessonType.speaking,
          'jp': '犬に足を踏まれました。',
          'answer': 'いぬにあしをふまれました',
        },
        {
          'type': LessonType.speaking,
          'jp': '私は子供に褒められました。',
          'answer': 'わたしはこどもにほめられました',
        },
      ];
    }
  List<Map<String, dynamic>> _getN4Bai6LuyenVietData() {
      return [
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '先生',
          'kanji_target': '先',
          'meaning': 'Tiên (Trước / Tiên sinh)',
          'rmj': 'sen / saki'
        },
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '先生',
          'kanji_target': '生',
          'meaning': 'Sinh (Học sinh / Sinh ra)',
          'rmj': 'sei / u(mareru)'
        },
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '子供',
          'kanji_target': '子',
          'meaning': 'Tử (Con / Trẻ em)',
          'rmj': 'ko'
        },
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '足',
          'kanji_target': '足',
          'meaning': 'Túc (Chân / Đầy đủ)',
          'rmj': 'ashi / ta(rimasu)'
        },
        {
          'type': LessonType.matching,
          'pairs': [
            {'left': 'Tiên', 'right': '先'},
            {'left': 'Sinh', 'right': '生'},
            {'left': 'Tử', 'right': '子'},
            {'left': 'Túc', 'right': '足'},
            {'left': 'Khảo', 'right': '考'}, // Ôn lại chữ "Khảo" của Bài 5
          ]
        },
      ];
    }
  List<Map<String, dynamic>> _getN4Bai7LyThuyetData() {
      return [
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': '案内します', 'hiragana': 'あんないします', 'romaji': 'annaishimasu', 'meaning': 'Hướng dẫn'},
            {'kanji': '説明します', 'hiragana': 'せつめいします', 'romaji': 'setsumeishimasu', 'meaning': 'Giải thích'},
            {'kanji': '準備します', 'hiragana': 'じゅんびします', 'romaji': 'junbishimasu', 'meaning': 'Chuẩn bị'},
            {'kanji': '荷物', 'hiragana': 'にもつ', 'romaji': 'nimotsu', 'meaning': 'Hành lý'},
            {'kanji': 'お婆さん', 'hiragana': 'おばあさん', 'romaji': 'obaasan', 'meaning': 'Bà cụ / Người bà'},
          ]
        },
        {
          'type': LessonType.flashCard, 'kanji': '案内します', 'hiragana': 'あんないします', 'romaji': 'annaishimasu', 'meaning': 'Hướng dẫn',
          'example_img': 'assets/images/example_annai.png',
          'example_jp': '町を案内します。', 'example_rmj': 'Machi o annai shimasu.', 'example_vn': 'Hướng dẫn (đi tham quan) thành phố.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '説明します', 'hiragana': 'せつめいします', 'romaji': 'setsumeishimasu', 'meaning': 'Giải thích',
          'example_img': 'assets/images/example_setsumei.png',
          'example_jp': '文法を説明します。', 'example_rmj': 'Bunpou o setsumei shimasu.', 'example_vn': 'Giải thích ngữ pháp.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '荷物', 'hiragana': 'にもつ', 'romaji': 'nimotsu', 'options': ['hướng dẫn', 'hành lý', 'bà cụ', 'chuẩn bị'], 'answer': 'hành lý'},
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'V(て) + あげます', 'meaning': 'Làm (cái gì) cho ai đó'},
            {'title': 'V(て) + もらいます', 'meaning': 'Được ai đó làm cho'},
            {'title': 'V(て) + くれます', 'meaning': 'Ai đó làm (cái gì) cho MÌNH'},
          ]
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'LÀM GIÚP AI ĐÓ',
          'formula': 'Tôi は + Người nhận に + V(て) + あげます',
          'meaning': 'Tôi làm ~ cho (ai đó)'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG てあげる',
          'notes': [
            'Dùng khi mình (hoặc người phe mình) làm giúp một việc gì đó cho người khác.',
            'Lưu ý: Hạn chế dùng trực tiếp với người lớn tuổi hoặc cấp trên vì nghe có vẻ bề trên, áp đặt.'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'LÀM CHO',
          'img': 'assets/images/example_teageru.png',
          'jp': '私はお婆さんに道を案内してあげました。',
          'rmj': 'Watashi wa obaasan ni michi o annai shite agemashita.',
          'vn': 'Tôi đã chỉ đường cho bà cụ.'
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'ĐƯỢC LÀM CHO',
          'formula': 'Tôi は + Người làm に + V(て) + もらいます\nNgười làm は + Tôi に + V(て) + くれます',
          'meaning': 'Tôi được ai làm cho / Ai đó làm cho tôi'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'MORAIMASU VÀ KUREMASU',
          'notes': [
            'てもらう: Chủ ngữ là TÔI. Lấy TÔI làm trung tâm nhận hành động từ người khác.',
            'てくれる: Chủ ngữ là NGƯỜI KHÁC. Người khác tự nguyện làm cho TÔI.',
            'Cả hai đều thể hiện sự biết ơn của người nói.'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'ĐƯỢC LÀM CHO',
          'img': 'assets/images/example_tekureru.png',
          'jp': '先生は（私に）文法を説明してくれました。',
          'rmj': 'Sensei wa (watashi ni) bunpou o setsumei shite kuremashita.',
          'vn': 'Thầy giáo đã giải thích ngữ pháp cho tôi.'
        },
        {
          'type': LessonType.vocabSummary,
          'words': [
            {'kanji': '案内する', 'romaji': 'annaisuru', 'meaning': 'hướng dẫn'},
            {'kanji': '準備する', 'romaji': 'junbisuru', 'meaning': 'chuẩn bị'},
            {'kanji': 'てあげる', 'romaji': 'te ageru', 'meaning': 'làm cho'},
            {'kanji': 'てもらう', 'romaji': 'te morau', 'meaning': 'được làm cho'},
            {'kanji': 'てくれる', 'romaji': 'te kureru', 'meaning': 'ai đó làm cho mình'},
          ]
        }
      ];
    }

    List<Map<String, dynamic>> _getN4Bai7LuyenTap1Data() {
      return [
        {
          'type': LessonType.imageQuiz,
          'question': 'Hành lý.',
          'answerIndex': 1,
          'options': [
            {'img': 'assets/images/example_junbi.png', 'jp': '準備', 'rmj': 'junbi'},
            {'img': 'assets/images/example_nimotsu.png', 'jp': '荷物', 'rmj': 'nimotsu'},
            {'img': 'assets/images/example_annai.png', 'jp': '案内', 'rmj': 'annai'},
            {'img': 'assets/images/example_obaasan.png', 'jp': 'お婆さん', 'rmj': 'obaasan'},
          ]
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '文法を説明します。',
          'rmj': 'Bunpou o setsumei shimasu.',
          'audio_text': '文法を説明します。',
          'words': ['ngữ pháp', 'giải thích', 'chuẩn bị', 'hành lý', 'hướng dẫn'],
          'answer': 'giải thích ngữ pháp',
        },
      ];
    }

    List<Map<String, dynamic>> _getN4Bai7LuyenTap2Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền từ (Bạn A đã Xách hành lý cho TÔI): \nAさんは荷物を持って ( ... )。',
          'options': ['くれました', 'もらいました', 'あげました', 'しました'],
          'answer': 'くれました' // Chủ ngữ là Aさん làm cho mình
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '私は母に服を買ってもらいました。',
          'words': ['私', 'は', '母に', '服を', '買って', 'もらいました', 'くれました'],
          'answer': '私 は 母に 服を 買って もらいました',
        },
      ];
    }

    List<Map<String, dynamic>> _getN4Bai7LuyenTap3Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền trợ từ đúng: \n私は妹 ( ... ) 日本語を教えてあげました。',
          'options': ['に', 'が', 'を', 'で'],
          'answer': 'に' // Làm cho ai đó dùng に
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '先生が説明してくれました。',
          'words': ['先生', 'が', '説明して', 'くれました', 'もらいました'],
          'answer': '先生 が 説明して くれました',
        },
      ];
    }
    List<Map<String, dynamic>> _getN4Bai7LuyenNoiData() {
      return [
        {'type': LessonType.speaking, 'jp': '町を案内してあげました。', 'answer': 'まちをあんないしてあげました'},
        {'type': LessonType.speaking, 'jp': '服を買ってもらいました。', 'answer': 'ふくをかってもらいました'},
        {'type': LessonType.speaking, 'jp': '先生が説明してくれました。', 'answer': 'せんせいがせつめいしてくれました'},
      ];
    }
    List<Map<String, dynamic>> _getN4Bai7LuyenVietData() {
      return [
        {'type': LessonType.kanjiDraw, 'kanji_word': '案内', 'kanji_target': '案', 'meaning': 'Án (Phương án / Đề án)', 'rmj': 'an'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '荷物', 'kanji_target': '荷', 'meaning': 'Hà (Hành lý)', 'rmj': 'ni / ka'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '荷物', 'kanji_target': '物', 'meaning': 'Vật (Đồ vật)', 'rmj': 'mono / butsu'},
      ];
    }
  List<Map<String, dynamic>> _getN4Bai8LyThuyetData() {
      return [
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': '落ちます', 'hiragana': 'おちます', 'romaji': 'ochimasu', 'meaning': 'Rơi / Rớt'},
            {'kanji': '破れます', 'hiragana': 'やぶれます', 'romaji': 'yaburemasu', 'meaning': 'Rách'},
            {'kanji': '悲しい', 'hiragana': 'かなしい', 'romaji': 'kanashii', 'meaning': 'Buồn bã'},
            {'kanji': '嬉しい', 'hiragana': 'うれしい', 'romaji': 'ureshii', 'meaning': 'Vui vẻ'},
            {'kanji': '財布', 'hiragana': 'さいふ', 'romaji': 'saifu', 'meaning': 'Cái ví'},
          ]
        },
        {
          'type': LessonType.flashCard, 'kanji': '落ちます', 'hiragana': 'おちます', 'romaji': 'ochimasu', 'meaning': 'Rơi',
          'example_img': 'assets/images/example_ochiru.png',
          'example_jp': '荷物が落ちそうです。', 'example_rmj': 'Nimotsu ga ochisou desu.', 'example_vn': 'Hành lý có vẻ sắp rơi.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '破れます', 'hiragana': 'やぶれます', 'romaji': 'yaburemasu', 'meaning': 'Rách',
          'example_img': 'assets/images/example_yabureru.png',
          'example_jp': '紙が破れました。', 'example_rmj': 'Kami ga yaburemashita.', 'example_vn': 'Tờ giấy đã bị rách.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '財布', 'hiragana': 'さいふ', 'romaji': 'saifu', 'options': ['vui vẻ', 'cái ví', 'rơi rớt', 'buồn bã'], 'answer': 'cái ví'},
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'V(bỏ ます) / A(bỏ い/な) + そうです', 'meaning': 'Trông có vẻ... / Sắp sửa...'},
            {'title': 'V(て) + しまいました', 'meaning': 'Lỡ (làm hỏng) / Xong (hoàn thành)'},
          ]
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'TRÔNG CÓ VẺ',
          'formula': 'Động từ (bỏ ます) + そうです\nTính từ (bỏ い / な) + そうです',
          'meaning': 'Trông có vẻ... / Sắp sửa...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜そうです',
          'notes': [
            'Đưa ra phán đoán dựa trên những gì mình NHÌN THẤY trực tiếp bằng mắt.',
            'Với Động từ: Biểu thị một sự việc sắp sửa xảy ra (Sắp rơi, sắp đứt).',
            'Với Tính từ: Biểu thị cảm nhận bề ngoài (Trông có vẻ ngon, trông có vẻ buồn).',
            'Ngoại lệ: いい ➔ よさそうです.'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ そうです',
          'img': 'assets/images/example_oishisou.png',
          'jp': 'このケーキは美味しそうです。',
          'rmj': 'Kono keeki wa oishisou desu.',
          'vn': 'Cái bánh này trông có vẻ ngon.'
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'LỠ LÀM / HOÀN THÀNH',
          'formula': 'Động từ (thể て) + しまいました (shimaimashita)',
          'meaning': 'Đã lỡ... / Đã làm xong...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜てしまいます',
          'notes': [
            'Nghĩa 1: Thể hiện sự tiếc nuối, hối hận vì đã lỡ làm hỏng việc gì hoặc làm mất cái gì.',
            'Nghĩa 2: Nhấn mạnh việc đã hoàn thành xong xuôi một hành động nào đó.'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ てしまいます',
          'img': 'assets/images/example_shimaimashita.png',
          'jp': '財布を落としてしまいました。',
          'rmj': 'Saifu o otoshite shimaimashita.',
          'vn': 'Tôi lỡ làm rơi mất cái ví rồi.'
        },
        {
          'type': LessonType.vocabSummary,
          'words': [
            {'kanji': '落ちる', 'romaji': 'ochiru', 'meaning': 'rơi'},
            {'kanji': '破れる', 'romaji': 'yabureru', 'meaning': 'rách'},
            {'kanji': '美味しそう', 'romaji': 'oishisou', 'meaning': 'trông có vẻ ngon'},
            {'kanji': '落としてしまう', 'romaji': 'otoshite shimau', 'meaning': 'lỡ đánh rơi'},
          ]
        }
      ];
    }

    List<Map<String, dynamic>> _getN4Bai8LuyenTap1Data() {
      return [
        {
          'type': LessonType.imageQuiz,
          'question': 'Buồn bã.',
          'answerIndex': 3,
          'options': [
            {'img': 'assets/images/example_ureshii.png', 'jp': '嬉しい', 'rmj': 'ureshii'},
            {'img': 'assets/images/example_saifu.png', 'jp': '財布', 'rmj': 'saifu'},
            {'img': 'assets/images/example_ochiru.png', 'jp': '落ちます', 'rmj': 'ochimasu'},
            {'img': 'assets/images/example_kanashii.png', 'jp': '悲しい', 'rmj': 'kanashii'},
          ]
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '紙が破れました。',
          'rmj': 'Kami ga yaburemashita.',
          'audio_text': '紙が破れました。',
          'words': ['giấy', 'đã', 'bị rách', 'rơi', 'ví'],
          'answer': 'giấy đã bị rách',
        },
      ];
    }

    List<Map<String, dynamic>> _getN4Bai8LuyenTap2Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Chia "Trông có vẻ vui" (嬉しい) sang cấu trúc そうです:',
          'options': ['嬉しいそうです', '嬉しそうです', '嬉しだそうです', '嬉しくてそうです'],
          'answer': '嬉しそうです' // Tính từ đuôi i bỏ i
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '荷物が落ちそうです。',
          'words': ['荷物', 'が', '落ち', 'そうです', '落ちます'],
          'answer': '荷物 が 落ち そうです',
        },
      ];
    }

    List<Map<String, dynamic>> _getN4Bai8LuyenTap3Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền từ (Lỡ để quên đồ ở xe điện mất rồi): \n電車に忘れ物を ( ... )。',
          'options': ['してしまいました', 'しそうです', 'してあげました', 'してくれました'],
          'answer': 'してしまいました'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '宿題を全部やってしまいました。',
          'words': ['宿題', 'を', '全部', 'やって', 'しまいました', 'そうです'],
          'answer': '宿題 を 全部 やって しまいました',
        },
      ];
    }
    List<Map<String, dynamic>> _getN4Bai8LuyenNoiData() {
      return [
        {'type': LessonType.speaking, 'jp': 'ケーキは美味しそうです。', 'answer': 'けーきはおいしそうです'},
        {'type': LessonType.speaking, 'jp': '荷物が落ちそうです。', 'answer': 'にもつがおちそうです'},
        {'type': LessonType.speaking, 'jp': '財布を落としてしまいました。', 'answer': 'さいふをおとしてしまいました'},
      ];
    }
    List<Map<String, dynamic>> _getN4Bai8LuyenVietData() {
      return [
        {'type': LessonType.kanjiDraw, 'kanji_word': '悲しい', 'kanji_target': '悲', 'meaning': 'Bi (Sầu bi / Buồn bã)', 'rmj': 'kana(shii) / hi'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '財布', 'kanji_target': '財', 'meaning': 'Tài (Tài sản / Tiền tài)', 'rmj': 'zai / sai'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '財布', 'kanji_target': '布', 'meaning': 'Bố (Vải vóc)', 'rmj': 'nuno / fu'},
      ];
    }
  List<Map<String, dynamic>> _getN4Bai9LyThuyetData() {
      return [
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': '押します', 'hiragana': 'おします', 'romaji': 'oshimasu', 'meaning': 'Ấn / Đẩy'},
            {'kanji': '動きます', 'hiragana': 'うごきます', 'romaji': 'ugokimasu', 'meaning': 'Chuyển động / Hoạt động'},
            {'kanji': '機械', 'hiragana': 'きかい', 'romaji': 'kikai', 'meaning': 'Máy móc'},
            {'kanji': '道', 'hiragana': 'みち', 'romaji': 'michi', 'meaning': 'Con đường'},
            {'kanji': '交差点', 'hiragana': 'こうさてん', 'romaji': 'kousaten', 'meaning': 'Ngã tư'},
          ]
        },
        {
          'type': LessonType.flashCard, 'kanji': '押します', 'hiragana': 'おします', 'romaji': 'oshimasu', 'meaning': 'Ấn / Đẩy',
          'example_img': 'assets/images/example_oshimasu.png',
          'example_jp': 'ボタンを押します。', 'example_rmj': 'Botan o oshimasu.', 'example_vn': 'Ấn nút.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '動きます', 'hiragana': 'うごきます', 'romaji': 'ugokimasu', 'meaning': 'Hoạt động',
          'example_img': 'assets/images/example_ugokimasu.png',
          'example_jp': '機械が動きます。', 'example_rmj': 'Kikai ga ugokimasu.', 'example_vn': 'Máy móc hoạt động.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '交差点', 'hiragana': 'こうさてん', 'romaji': 'kousaten', 'options': ['con đường', 'máy móc', 'ngã tư', 'ấn nút'], 'answer': 'ngã tư'},
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'V(ru) + と', 'meaning': 'Hễ... thì... (Điều kiện tất yếu / Máy móc)'},
            {'title': 'V(た) + ら', 'meaning': 'Nếu... / Sau khi... (Dùng rộng rãi nhất)'},
          ]
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'ĐIỀU KIỆN TẤT YẾU',
          'formula': 'Động từ (thể từ điển) + と',
          'meaning': 'Hễ... thì / Cứ... thì'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜と',
          'notes': [
            'Dùng cho các hiện tượng tự nhiên (hễ mùa xuân đến thì hoa nở) hoặc cách dùng máy móc (hễ ấn nút thì điện sáng).',
            'Vế sau KHÔNG đi kèm với ý chí, nguyện vọng hay mệnh lệnh của người nói.'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ 〜と',
          'img': 'assets/images/example_to.png',
          'jp': 'このボタンを押すと、機械が動きます。',
          'rmj': 'Kono botan o osu to, kikai ga ugokimasu.',
          'vn': 'Hễ ấn cái nút này thì máy sẽ hoạt động.'
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'ĐIỀU KIỆN (NẾU / SAU KHI)',
          'formula': 'Động từ (thể た) + ら',
          'meaning': 'Nếu... / Sau khi...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜たら',
          'notes': [
            'Đây là mẫu câu điều kiện dùng phổ biến nhất trong giao tiếp.',
            'Có thể dùng cho cả trường hợp giả định (Nếu có tiền, tôi sẽ mua xe) hoặc một sự việc chắc chắn sẽ xảy ra (Sau khi đến Nhật, tôi sẽ gọi điện).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ 〜たら',
          'img': 'assets/images/example_tara.png',
          'jp': '日本へ行ったら、連絡します。',
          'rmj': 'Nihon e ittara, renraku shimasu.',
          'vn': 'Sau khi đến Nhật, tôi sẽ liên lạc.'
        },
        {
          'type': LessonType.vocabSummary,
          'words': [
            {'kanji': '押す', 'romaji': 'osu', 'meaning': 'ấn / đẩy'},
            {'kanji': '動く', 'romaji': 'ugoku', 'meaning': 'chuyển động'},
            {'kanji': '押すと', 'romaji': 'osu to', 'meaning': 'hễ ấn thì'},
            {'kanji': '行ったら', 'romaji': 'ittara', 'meaning': 'nếu đi / sau khi đi'},
          ]
        }
      ];
    }

    List<Map<String, dynamic>> _getN4Bai9LuyenTap1Data() {
      return [
        {
          'type': LessonType.imageQuiz,
          'question': 'Máy móc.',
          'answerIndex': 0,
          'options': [
            {'img': 'assets/images/example_kikai.png', 'jp': '機械', 'rmj': 'kikai'},
            {'img': 'assets/images/example_michi.png', 'jp': '道', 'rmj': 'michi'},
            {'img': 'assets/images/example_kousaten.png', 'jp': '交差点', 'rmj': 'kousaten'},
            {'img': 'assets/images/example_ugokimasu.png', 'jp': '動きます', 'rmj': 'ugokimasu'},
          ]
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': 'ボタンを押します。',
          'rmj': 'Botan o oshimasu.',
          'audio_text': 'ボタンを押します。',
          'words': ['nút', 'ấn', 'chuyển động', 'ngã tư', 'hễ'],
          'answer': 'ấn nút',
        },
      ];
    }

    List<Map<String, dynamic>> _getN4Bai9LuyenTap2Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền từ (Hễ rẽ phải sẽ có ngân hàng): \n右へ曲がる ( ... )、銀行があります。',
          'options': ['と', 'たら', 'なら', 'ば'],
          'answer': 'と' // Chỉ đường dùng と
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': 'お金があったら、旅行します。',
          'words': ['お金', 'が', 'あったら', '旅行', 'します', 'あると'],
          'answer': 'お金 が あったら 旅行 します',
        },
      ];
    }

    List<Map<String, dynamic>> _getN4Bai9LuyenTap3Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Mẫu câu nào mang nghĩa "SAU KHI" một việc chắc chắn xảy ra?',
          'options': ['〜たら', '〜と', '〜なら', '〜ば'],
          'answer': '〜たら'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '駅に着いたら、電話してください。',
          'words': ['駅', 'に', '着いたら', '電話', 'してください', '着くと'],
          'answer': '駅 に 着いたら 電話 してください',
        },
      ];
    }

    List<Map<String, dynamic>> _getN4Bai9LuyenNoiData() {
      return [
        {'type': LessonType.speaking, 'jp': 'ボタンを押すと、動きます。', 'answer': 'ぼたんをおすとうごきます'},
        {'type': LessonType.speaking, 'jp': '日本へ行ったら連絡します。', 'answer': 'にほんへいったられんらくします'},
        {'type': LessonType.speaking, 'jp': '右へ曲がると、あります。', 'answer': 'みぎへまがるとあります'},
      ];
    }

    List<Map<String, dynamic>> _getN4Bai9LuyenVietData() {
      return [
        {'type': LessonType.kanjiDraw, 'kanji_word': '押します', 'kanji_target': '押', 'meaning': 'Áp (Ấn / Đẩy)', 'rmj': 'o(su) / ou'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '動きます', 'kanji_target': '動', 'meaning': 'Động (Chuyển động)', 'rmj': 'ugo(ku) / dou'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '機械', 'kanji_target': '機', 'meaning': 'Cơ (Máy móc / Cơ hội)', 'rmj': 'ki'},
      ];
    }
  List<Map<String, dynamic>> _getN4Bai10LyThuyetData() {
      return [
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': '逃げます', 'hiragana': 'にげます', 'romaji': 'nigemasu', 'meaning': 'Chạy trốn'},
            {'kanji': '投げます', 'hiragana': 'なげます', 'romaji': 'nagemasu', 'meaning': 'Ném'},
            {'kanji': '守ります', 'hiragana': 'まもります', 'romaji': 'mamorimasu', 'meaning': 'Bảo vệ / Tuân thủ'},
            {'kanji': '規則', 'hiragana': 'きそく', 'romaji': 'kisoku', 'meaning': 'Quy tắc'},
            {'kanji': '危ない', 'hiragana': 'あぶない', 'romaji': 'abunai', 'meaning': 'Nguy hiểm'},
          ]
        },
        {
          'type': LessonType.flashCard, 'kanji': '逃げます', 'hiragana': 'にげます', 'romaji': 'nigemasu', 'meaning': 'Chạy trốn',
          'example_img': 'assets/images/example_nigeru.png',
          'example_jp': '早く逃げろ！', 'example_rmj': 'Hayaku nigero!', 'example_vn': 'Chạy trốn nhanh lên!'
        },
        {
          'type': LessonType.flashCard, 'kanji': '危ない', 'hiragana': 'あぶない', 'romaji': 'abunai', 'meaning': 'Nguy hiểm',
          'example_img': 'assets/images/example_abunai.png',
          'example_jp': '危ないから、入るな。', 'example_rmj': 'Abunai kara, hairu na.', 'example_vn': 'Vì nguy hiểm nên không được vào.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '規則', 'hiragana': 'きそく', 'romaji': 'kisoku', 'options': ['nguy hiểm', 'chạy trốn', 'quy tắc', 'tuân thủ'], 'answer': 'quy tắc'},
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'Thể mệnh lệnh (しろ / 飲め)', 'meaning': 'Làm đi! (Ra lệnh mạnh mẽ)'},
            {'title': 'V(ru) + な', 'meaning': 'Không được làm! (Cấm chỉ)'},
            {'title': 'V(た) + ほうがいい', 'meaning': 'Nên làm... (Lời khuyên)'},
          ]
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'THỂ MỆNH LỆNH',
          'formula': 'Nhóm 1: cột [i] ➔ [e] (飲みます ➔ 飲め)\nNhóm 2: bỏ ます ➔ ろ (食べます ➔ 食べろ)\nNhóm 3: します ➔ しろ / 来ます ➔ 来い',
          'meaning': 'Làm việc đó đi!'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG MỆNH LỆNH',
          'notes': [
            'Dùng khi tức giận, ra lệnh trong quân đội, thể thao, hoặc tình huống khẩn cấp (hỏa hoạn, tai nạn).',
            'Đàn ông hay dùng với bạn bè thân thiết. Tuyệt đối không dùng với người lớn tuổi hơn.'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ MỆNH LỆNH',
          'img': 'assets/images/example_nigero.png',
          'jp': '火事だ！逃げろ！',
          'rmj': 'Kaji da! Nigero!',
          'vn': 'Hỏa hoạn! Chạy đi!'
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'THỂ CẤM CHỈ',
          'formula': 'Động từ (thể từ điển) + な',
          'meaning': 'Cấm / Không được làm!'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜な',
          'notes': [
            'Cấm đoán mạnh mẽ, thường thấy trên các biển báo nguy hiểm (Cấm vào, Cấm đỗ xe).',
            'Ví dụ: 触るな (Cấm sờ).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ 〜な',
          'img': 'assets/images/example_hairuna.png',
          'jp': 'ここは危ない。入るな！',
          'rmj': 'Koko wa abunai. Hairu na!',
          'vn': 'Chỗ này nguy hiểm. Cấm vào!'
        },
        {
          'type': LessonType.vocabSummary,
          'words': [
            {'kanji': '逃げる', 'romaji': 'nigeru', 'meaning': 'chạy trốn'},
            {'kanji': '守る', 'romaji': 'mamoru', 'meaning': 'tuân thủ / bảo vệ'},
            {'kanji': '飲め', 'romaji': 'nome', 'meaning': 'uống đi!'},
            {'kanji': '飲むな', 'romaji': 'nomu na', 'meaning': 'cấm uống!'},
          ]
        }
      ];
    }

    List<Map<String, dynamic>> _getN4Bai10LuyenTap1Data() {
      return [
        {
          'type': LessonType.imageQuiz,
          'question': 'Nguy hiểm.',
          'answerIndex': 2,
          'options': [
            {'img': 'assets/images/example_kisoku.png', 'jp': '規則', 'rmj': 'kisoku'},
            {'img': 'assets/images/example_nigeru.png', 'jp': '逃げます', 'rmj': 'nigemasu'},
            {'img': 'assets/images/example_abunai.png', 'jp': '危ない', 'rmj': 'abunai'},
            {'img': 'assets/images/example_nageru.png', 'jp': '投げます', 'rmj': 'nagemasu'},
          ]
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '規則を守ります。',
          'rmj': 'Kisoku o mamorimasu.',
          'audio_text': '規則を守ります。',
          'words': ['quy tắc', 'tuân thủ', 'nguy hiểm', 'cấm', 'chạy trốn'],
          'answer': 'tuân thủ quy tắc',
        },
      ];
    }

    List<Map<String, dynamic>> _getN4Bai10LuyenTap2Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Chia "CẤM VÀO" (入る):',
          'options': ['入らな', '入るな', '入ってな', '入りな'],
          'answer': '入るな' // V-ru + na
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': 'ここは危ないから、入るな。',
          'words': ['ここ', 'は', '危ない', 'から', '入るな', '入れ'],
          'answer': 'ここ は 危ない から 入るな',
        },
      ];
    }

    List<Map<String, dynamic>> _getN4Bai10LuyenTap3Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Thể mệnh lệnh (LÀM ĐI) của します (Làm) là gì?',
          'options': ['しめ', 'しまれ', 'しろ', 'しれ'],
          'answer': 'しろ'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': 'もっと早く走れ！',
          'words': ['もっと', '早く', '走れ', '走るな', 'から'],
          'answer': 'もっと 早く 走れ',
        },
      ];
    }

    List<Map<String, dynamic>> _getN4Bai10LuyenNoiData() {
      return [
        {'type': LessonType.speaking, 'jp': '早く逃げろ！', 'answer': 'はやくにげろ'},
        {'type': LessonType.speaking, 'jp': 'ここに入るな。', 'answer': 'ここにはいるな'},
        {'type': LessonType.speaking, 'jp': 'もっと勉強しろ！', 'answer': 'もっとべんきょうしろ'},
      ];
    }

    List<Map<String, dynamic>> _getN4Bai10LuyenVietData() {
      return [
        {'type': LessonType.kanjiDraw, 'kanji_word': '逃げます', 'kanji_target': '逃', 'meaning': 'Đào (Chạy trốn)', 'rmj': 'ni(geru) / tou'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '規則', 'kanji_target': '則', 'meaning': 'Tắc (Quy tắc)', 'rmj': 'soku'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '危ない', 'kanji_target': '危', 'meaning': 'Nguy (Nguy hiểm)', 'rmj': 'abu(nai) / ki'},
      ];
    }
  List<Map<String, dynamic>> _getN3Bai1LyThuyetData() {
      return [
        // ================= PHẦN 1: TỪ VỰNG =================
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': '社長', 'hiragana': 'しゃちょう', 'romaji': 'shachou', 'meaning': 'Giám đốc'},
            {'kanji': 'いらっしゃいます', 'hiragana': 'いらっしゃいます', 'romaji': 'irasshaimasu', 'meaning': 'Đi / Đến / Ở (Tôn kính của 行く, 来る, いる)'},
            {'kanji': '召し上がります', 'hiragana': 'めしあがります', 'romaji': 'meshiagarimasu', 'meaning': 'Ăn / Uống (Tôn kính của 食べる, 飲む)'},
            {'kanji': '参ります', 'hiragana': 'まいります', 'romaji': 'mairimasu', 'meaning': 'Đi / Đến (Khiêm nhường của 行く, 来る)'},
            {'kanji': '拝見します', 'hiragana': 'はいけんします', 'romaji': 'haikenshimasu', 'meaning': 'Xem / Nhìn (Khiêm nhường của 見る)'},
            {'kanji': '申します', 'hiragana': 'もうします', 'romaji': 'moushimasu', 'meaning': 'Nói / Tên là (Khiêm nhường của 言う)'},
          ]
        },

        // --- NHÓM TỪ 1: TÔN KÍNH NGỮ (Dùng cho người khác) ---
        {
          'type': LessonType.flashCard, 'kanji': '社長', 'hiragana': 'しゃちょう', 'romaji': 'shachou', 'meaning': 'Giám đốc',
          'example_img': 'assets/images/example_shachou.png',
          'example_jp': '社長が来ます。', 'example_rmj': 'Shachou ga kimasu.', 'example_vn': 'Giám đốc đến.'
        },
        {
          'type': LessonType.flashCard, 'kanji': 'いらっしゃいます', 'hiragana': 'いらっしゃいます', 'romaji': 'irasshaimasu', 'meaning': 'Đi/Đến/Ở (Tôn kính)',
          'example_img': 'assets/images/example_irasshaimasu.png',
          'example_jp': '社長がいらっしゃいます。', 'example_rmj': 'Shachou ga irasshaimasu.', 'example_vn': 'Giám đốc đang ở đây / đang đến.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '召し上がります', 'hiragana': 'めしあがります', 'romaji': 'meshiagarimasu', 'meaning': 'Ăn/Uống (Tôn kính)',
          'example_img': 'assets/images/example_meshiagarimasu.png',
          'example_jp': '先生が召し上がります。', 'example_rmj': 'Sensei ga meshiagarimasu.', 'example_vn': 'Thầy giáo dùng bữa.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '社長', 'hiragana': 'しゃちょう', 'romaji': 'shachou', 'options': ['nhân viên', 'giáo viên', 'giám đốc', 'học sinh'], 'answer': 'giám đốc'},

        // --- NHÓM TỪ 2: KHIÊM NHƯỜNG NGỮ (Dùng cho bản thân) ---
        {
          'type': LessonType.flashCard, 'kanji': '参ります', 'hiragana': 'まいります', 'romaji': 'mairimasu', 'meaning': 'Đi/Đến (Khiêm nhường)',
          'example_img': 'assets/images/example_mairimasu.png',
          'example_jp': '私が参ります。', 'example_rmj': 'Watashi ga mairimasu.', 'example_vn': 'Tôi sẽ đi đến đó.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '拝見します', 'hiragana': 'はいけんします', 'romaji': 'haikenshimasu', 'meaning': 'Xem (Khiêm nhường)',
          'example_img': 'assets/images/example_haikenshimasu.png',
          'example_jp': '資料を拝見します。', 'example_rmj': 'Shiryou o haikenshimasu.', 'example_vn': 'Tôi xin phép xem tài liệu.'
        },
        {'type': LessonType.listening, 'options': ['いらっしゃいます', 'まいります', 'はいけんします', 'めしあがります'], 'answer': 'まいります'},

        // ================= PHẦN 2: NGỮ PHÁP =================
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': '尊敬語 (Tôn kính ngữ)', 'meaning': 'Dùng để nâng cao hành động của cấp trên/đối tác.'},
            {'title': '謙譲語 (Khiêm nhường ngữ)', 'meaning': 'Dùng để hạ thấp hành động của bản thân mình.'},
          ]
        },

        // NGỮ PHÁP 1: TÔN KÍNH NGỮ
        {
          'type': LessonType.grammarStructure,
          'title': 'TÔN KÍNH NGỮ',
          'formula': 'Dùng các Động từ đặc biệt (いらっしゃる, 召し上がる...)\nHoặc: お + V(bỏ ます) + になります',
          'meaning': 'Ngài ~ làm gì đó'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG TÔN KÍNH NGỮ',
          'notes': [
            'Tuyệt đối KHÔNG dùng Tôn kính ngữ cho hành động của bản thân mình.',
            'Chỉ dùng cho Chủ ngữ là người bề trên: Giám đốc, Khách hàng, Thầy cô giáo.',
            'Ví dụ: 先生は帰りました ➔ 先生はお帰りになりました (Thầy đã về rồi ạ).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'TÔN KÍNH NGỮ',
          'img': 'assets/images/example_meshiagarimasu.png',
          'jp': '社長がパンを召し上がります。',
          'rmj': 'Shachou ga pan o meshiagarimasu.',
          'vn': 'Giám đốc dùng (ăn) bánh mì.'
        },

        // NGỮ PHÁP 2: KHIÊM NHƯỜNG NGỮ
        {
          'type': LessonType.grammarStructure,
          'title': 'KHIÊM NHƯỜNG NGỮ',
          'formula': 'Dùng các Động từ đặc biệt (参る, 拝見する, 申す...)\nHoặc: お + V(bỏ ます) + します',
          'meaning': 'Tôi xin phép làm...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG KHIÊM NHƯỜNG NGỮ',
          'notes': [
            'Dùng để thể hiện sự khiêm tốn, hạ thấp bản thân để tôn người nghe lên.',
            'Chủ ngữ BẮT BUỘC phải là "Tôi" (私) hoặc người cùng phe với mình (nhân viên công ty mình).',
            'Ví dụ: 私が持ちます ➔ 私がお持ちします (Để tôi mang giúp cho ạ).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'KHIÊM NHƯỜNG NGỮ',
          'img': 'assets/images/example_mairimasu.png',
          'jp': '明日、私が参ります。',
          'rmj': 'Ashita, watashi ga mairimasu.',
          'vn': 'Ngày mai, tôi sẽ đến ạ.'
        },

        // ================= PHẦN 3: TỔNG KẾT =================
        {
          'type': LessonType.vocabSummary,
          'words': [
            {'kanji': '社長', 'romaji': 'shachou', 'meaning': 'giám đốc'},
            {'kanji': 'いらっしゃる', 'romaji': 'irassharu', 'meaning': 'đi/đến/ở (tôn kính)'},
            {'kanji': '召し上がる', 'romaji': 'meshiagaru', 'meaning': 'ăn/uống (tôn kính)'},
            {'kanji': '参る', 'romaji': 'mairu', 'meaning': 'đi/đến (khiêm nhường)'},
            {'kanji': '拝見する', 'romaji': 'haikensuru', 'meaning': 'xem (khiêm nhường)'},
            {'kanji': '申す', 'romaji': 'mousu', 'meaning': 'nói (khiêm nhường)'},
          ]
        }
      ];
    }
  List<Map<String, dynamic>> _getN3Bai1LuyenTap1Data() {
      return [
        {
          'type': LessonType.imageQuiz,
          'question': 'Giám đốc.',
          'answerIndex': 0,
          'options': [
            {'img': 'assets/images/example_shachou.png', 'jp': '社長', 'rmj': 'shachou'},
            {'img': 'assets/images/example_sensei.png', 'jp': '先生', 'rmj': 'sensei'},
            {'img': 'assets/images/example_irasshaimasu.png', 'jp': 'いらっしゃいます', 'rmj': 'irasshaimasu'},
            {'img': 'assets/images/example_mairimasu.png', 'jp': '参ります', 'rmj': 'mairimasu'},
          ]
        },
        {
          'type': LessonType.listening,
          'options': [
            {'kanji': 'いらっしゃいます', 'hiragana': 'いらっしゃいます'},
            {'kanji': '召し上がります', 'hiragana': 'めしあがります'},
            {'kanji': '拝見します', 'hiragana': 'はいけんします'},
            {'kanji': '申します', 'hiragana': 'もうします'},
          ],
          'answer': '召し上がります'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '社長がいらっしゃいます。',
          'rmj': 'Shachou ga irasshaimasu.',
          'audio_text': '社長がいらっしゃいます。',
          'words': ['giám đốc', 'đến', 'tôi', 'ăn', 'khiêm nhường'],
          'answer': 'giám đốc đến',
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '私が参ります。',
          'words': ['私', 'が', '参ります', 'いらっしゃいます', '社長'],
          'answer': '私 が 参ります',
        },
      ];
    }
  List<Map<String, dynamic>> _getN3Bai1LuyenTap2Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Tôn kính ngữ của "食べる" (Ăn) là gì?',
          'options': ['参ります', '拝見します', '召し上がります', '申します'],
          'answer': '召し上がります'
        },
        {
          'type': LessonType.quiz,
          'question': 'Giám đốc dùng bữa.',
          'audio_text': '社長が召し上がります。',
          'options': [
            {'kanji': '社長が召し上がります。', 'hiragana': 'しゃちょうがめしあがります。'},
            {'kanji': '私が召し上がります。', 'hiragana': 'わたしがめしあがります。'} // Bẫy: Tôn kính không dùng cho Watashi
          ],
          'answer': '社長が召し上がります。'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '先生がいらっしゃいます。',
          'words': ['先生', 'が', 'いらっしゃいます', '参ります', '私'],
          'answer': '先生 が いらっしゃいます',
        },
      ];
    }
  List<Map<String, dynamic>> _getN3Bai1LuyenTap3Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền từ đúng (Tôi xin phép xem tài liệu): \n私が資料を ( ... )。',
          'options': ['見ます', '拝見します', '召し上がります', 'いらっしゃいます'],
          'answer': '拝見します'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': 'サングと申します。', // Câu giới thiệu tên kinh điển ở Nhật
          'words': ['サング', 'と', '申します', '社長', '拝見します'],
          'answer': 'サング と 申します',
        },
        {
          'type': LessonType.matching,
          'pairs': [
            {'left': 'Đến (Tôn kính)', 'right': 'いらっしゃいます'},
            {'left': 'Ăn (Tôn kính)', 'right': '召し上がります'},
            {'left': 'Đến (Khiêm nhường)', 'right': '参ります'},
            {'left': 'Xem (Khiêm nhường)', 'right': '拝見します'},
            {'left': 'Giám đốc', 'right': '社長'},
          ]
        },
      ];
    }
  List<Map<String, dynamic>> _getN3Bai1LuyenNoiData() {
      return [
        {
          'type': LessonType.speaking,
          'jp': '社長がいらっしゃいます。',
          'answer': 'しゃちょうがいらっしゃいます',
        },
        {
          'type': LessonType.speaking,
          'jp': '先生が召し上がります。',
          'answer': 'せんせいがめしあがります',
        },
        {
          'type': LessonType.speaking,
          'jp': '私が参ります。',
          'answer': 'わたしがまいります',
        },
        {
          'type': LessonType.speaking,
          'jp': '資料を拝見します。',
          'answer': 'しりょうをはいけんします',
        },
        {
          'type': LessonType.speaking,
          'jp': 'サングと申します。', // Thay bằng tên Sang để demo cực ngầu
          'answer': 'さんぐともうします',
        },
      ];
    }
  List<Map<String, dynamic>> _getN3Bai1LuyenVietData() {
      return [
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '社長',
          'kanji_target': '長',
          'meaning': 'Trưởng (Trưởng phòng / Dài)',
          'rmj': 'chou / naga(i)'
        },
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '参ります',
          'kanji_target': '参',
          'meaning': 'Tham (Tham gia / Đi đến)',
          'rmj': 'mai(rimasu) / san'
        },
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '拝見します',
          'kanji_target': '拝',
          'meaning': 'Bái (Bái kiến / Chắp tay)',
          'rmj': 'hai / oga(mu)'
        },
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '申します',
          'kanji_target': '申',
          'meaning': 'Thân (Xưng tên / Nói)',
          'rmj': 'mou(shimasu) / shin'
        },
        {
          'type': LessonType.matching,
          'pairs': [
            {'left': 'Trưởng', 'right': '長'},
            {'left': 'Tham', 'right': '参'},
            {'left': 'Bái', 'right': '拝'},
            {'left': 'Thân', 'right': '申'},
            {'left': 'Xã', 'right': '社'}, // Xã Trưởng = Giám đốc
          ]
        },
      ];
    }
  List<Map<String, dynamic>> _getN3Bai2LyThuyetData() {
      return [
        // ================= PHẦN 1: TỪ VỰNG =================
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': '成功します', 'hiragana': 'せいこうします', 'romaji': 'seikoushimasu', 'meaning': 'Thành công'},
            {'kanji': '失敗します', 'hiragana': 'しっぱいします', 'romaji': 'shippaishimasu', 'meaning': 'Thất bại'},
            {'kanji': '事故', 'hiragana': 'じこ', 'romaji': 'jiko', 'meaning': 'Tai nạn'},
            {'kanji': '渋滞', 'hiragana': 'じゅうたい', 'romaji': 'juutai', 'meaning': 'Tắc đường / Kẹt xe'},
            {'kanji': 'おかげで', 'hiragana': 'おかげで', 'romaji': 'okagede', 'meaning': 'Nhờ có... (Mang nghĩa biết ơn)'},
            {'kanji': 'せいで', 'hiragana': 'せいで', 'romaji': 'seide', 'meaning': 'Tại vì... (Mang nghĩa trách móc)'},
          ]
        },

        // --- NHÓM TỪ 1: KẾT QUẢ ---
        {
          'type': LessonType.flashCard, 'kanji': '成功します', 'hiragana': 'せいこうします', 'romaji': 'seikoushimasu', 'meaning': 'Thành công',
          'example_img': 'assets/images/example_seikou.png',
          'example_jp': 'テストに成功しました。', 'example_rmj': 'Tesuto ni seikoushimashita.', 'example_vn': 'Tôi đã thành công trong bài kiểm tra.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '失敗します', 'hiragana': 'しっぱいします', 'romaji': 'shippaishimasu', 'meaning': 'Thất bại',
          'example_img': 'assets/images/example_shippai.png',
          'example_jp': '仕事に失敗しました。', 'example_rmj': 'Shigoto ni shippaishimashita.', 'example_vn': 'Tôi đã thất bại trong công việc.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '成功します', 'hiragana': 'せいこうします', 'romaji': 'seikoushimasu', 'options': ['thất bại', 'tắc đường', 'thành công', 'tai nạn'], 'answer': 'thành công'},

        // --- NHÓM TỪ 2: NGUYÊN NHÂN ---
        {
          'type': LessonType.flashCard, 'kanji': '事故', 'hiragana': 'じこ', 'romaji': 'jiko', 'meaning': 'Tai nạn',
          'example_img': 'assets/images/example_jiko.png',
          'example_jp': '事故がありました。', 'example_rmj': 'Jiko ga arimashita.', 'example_vn': 'Đã xảy ra tai nạn.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '渋滞', 'hiragana': 'じゅうたい', 'romaji': 'juutai', 'meaning': 'Tắc đường',
          'example_img': 'assets/images/example_juutai.png',
          'example_jp': '渋滞のせいで遅れました。', 'example_rmj': 'Juutai no seide okuremashita.', 'example_vn': 'Tôi đến muộn tại vì tắc đường.'
        },
        {'type': LessonType.listening, 'options': ['せいこう', 'しっぱい', 'じこ', 'じゅうたい'], 'answer': 'じこ'},

        // ================= PHẦN 2: NGỮ PHÁP =================
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': '〜おかげで', 'meaning': 'Nhờ có ~ (Dẫn đến kết quả TỐT)'},
            {'title': '〜せいで', 'meaning': 'Tại vì ~ (Dẫn đến kết quả XẤU)'},
          ]
        },

        // NGỮ PHÁP 1: おかげで
        {
          'type': LessonType.grammarStructure,
          'title': 'KẾT QUẢ TÍCH CỰC',
          'formula': 'V(た) / A(な) / N(の) + おかげで、〜',
          'meaning': 'Nhờ có...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜おかげで',
          'notes': [
            'Dùng để biểu thị lòng biết ơn vì một nguyên nhân nào đó đã mang lại kết quả tốt đẹp.',
            'Chú ý: Danh từ phải thêm 「の」 trước おかげで.',
            'Ví dụ: 先生のおかげで (Nhờ có thầy giáo).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'KẾT QUẢ TÍCH CỰC',
          'img': 'assets/images/example_okagede.png',
          'jp': '先生のおかげで、成功しました。',
          'rmj': 'Sensei no okage de, seikoushimashita.',
          'vn': 'Nhờ có thầy giáo, tôi đã thành công.'
        },

        // NGỮ PHÁP 2: せいで
        {
          'type': LessonType.grammarStructure,
          'title': 'KẾT QUẢ TIÊU CỰC',
          'formula': 'V(た) / A(な) / N(の) + せいで、〜',
          'meaning': 'Tại vì... / Lỗi tại...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜せいで',
          'notes': [
            'Dùng để đổ lỗi, phàn nàn vì một nguyên nhân nào đó đã dẫn đến kết quả tồi tệ.',
            'Tuyệt đối không dùng せいで cho những việc có kết quả tốt.',
            'Ví dụ: 事故のせいで (Tại vì tai nạn).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'KẾT QUẢ TIÊU CỰC',
          'img': 'assets/images/example_seide.png',
          'jp': '事故のせいで、遅れました。',
          'rmj': 'Jiko no sei de, okuremashita.',
          'vn': 'Tại vì tai nạn nên tôi đã đến muộn.'
        },

        // ================= PHẦN 3: TỔNG KẾT =================
        {
          'type': LessonType.vocabSummary,
          'words': [
            {'kanji': '成功する', 'romaji': 'seikousuru', 'meaning': 'thành công'},
            {'kanji': '失敗する', 'romaji': 'shippaisuru', 'meaning': 'thất bại'},
            {'kanji': '事故', 'romaji': 'jiko', 'meaning': 'tai nạn'},
            {'kanji': '渋滞', 'romaji': 'juutai', 'meaning': 'tắc đường'},
            {'kanji': 'おかげで', 'romaji': 'okagede', 'meaning': 'nhờ có'},
            {'kanji': 'せいで', 'romaji': 'seide', 'meaning': 'tại vì'},
          ]
        }
      ];
    }
  List<Map<String, dynamic>> _getN3Bai2LuyenTap1Data() {
      return [
        {
          'type': LessonType.imageQuiz,
          'question': 'Thất bại.',
          'answerIndex': 1,
          'options': [
            {'img': 'assets/images/example_seikou.png', 'jp': '成功します', 'rmj': 'seikoushimasu'},
            {'img': 'assets/images/example_shippai.png', 'jp': '失敗します', 'rmj': 'shippaishimasu'},
            {'img': 'assets/images/example_jiko.png', 'jp': '事故', 'rmj': 'jiko'},
            {'img': 'assets/images/example_juutai.png', 'jp': '渋滞', 'rmj': 'juutai'},
          ]
        },
        {
          'type': LessonType.listening,
          'options': [
            {'kanji': '渋滞', 'hiragana': 'じゅうたい'},
            {'kanji': '成功', 'hiragana': 'せいこう'},
            {'kanji': 'おかげで', 'hiragana': 'おかげで'},
            {'kanji': 'せいで', 'hiragana': 'せいで'},
          ],
          'answer': '渋滞'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': 'テストに成功しました。',
          'rmj': 'Tesuto ni seikoushimashita.',
          'audio_text': 'テストに成功しました。',
          'words': ['bài kiểm tra', 'trong', 'thành công', 'thất bại', 'tắc đường'],
          'answer': 'thành công trong bài kiểm tra',
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '事故がありました。',
          'words': ['事故', 'が', 'ありました', '渋滞', 'せいで'],
          'answer': '事故 が ありました',
        },
      ];
    }
  List<Map<String, dynamic>> _getN3Bai2LuyenTap2Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền từ đúng (Nhờ có bạn bè giúp đỡ...): \n友達の ( ... )、成功しました。',
          'options': ['せいで', 'おかげで', 'ために', 'から'],
          'answer': 'おかげで'
        },
        {
          'type': LessonType.quiz,
          'question': 'Tại vì trời mưa nên tôi không đi.',
          'audio_text': '雨のせいで行きません。',
          'options': [
            {'kanji': '雨のせいで行きません。', 'hiragana': 'あめのせいでいきません。'},
            {'kanji': '雨のおかげで行きません。', 'hiragana': 'あめのおかげでいきません。'} // Bẫy logic
          ],
          'answer': '雨のせいで行きません。'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '先生のおかげで、成功しました。',
          'words': ['先生', 'の', 'おかげで', '成功しました', 'せいで', '失敗しました'],
          'answer': '先生 の おかげで 成功しました',
        },
      ];
    }
  List<Map<String, dynamic>> _getN3Bai2LuyenTap3Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền từ đúng (Tại vì tai nạn nên đường tắc): \n事故 ( ... ) 渋滞です。',
          'options': ['のおかげで', 'のせいで', 'せいで', 'おかげで'],
          'answer': 'のせいで' // Nhấn mạnh danh từ phải có の
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '渋滞のせいで、遅れました。',
          'words': ['渋滞', 'の', 'せいで', '遅れました', 'おかげで'],
          'answer': '渋滞 の せいで 遅れました',
        },
        {
          'type': LessonType.matching,
          'pairs': [
            {'left': 'Thành công', 'right': '成功します'},
            {'left': 'Thất bại', 'right': '失敗します'},
            {'left': 'Tắc đường', 'right': '渋滞'},
            {'left': 'Nhờ có', 'right': 'おかげで'},
            {'left': 'Tại vì', 'right': 'せいで'},
          ]
        },
      ];
    }
  List<Map<String, dynamic>> _getN3Bai2LuyenNoiData() {
      return [
        {
          'type': LessonType.speaking,
          'jp': 'テストに成功しました。',
          'answer': 'てすとになりこうしました', // Nhận diện seikoushimashita
        },
        {
          'type': LessonType.speaking,
          'jp': '仕事に失敗しました。',
          'answer': 'しごとにしっぱいしました',
        },
        {
          'type': LessonType.speaking,
          'jp': '先生のおかげで成功しました。',
          'answer': 'せんせいのおかげでせいこうしました',
        },
        {
          'type': LessonType.speaking,
          'jp': '事故のせいで遅れました。',
          'answer': 'じこのせいで おくれました',
        },
        {
          'type': LessonType.speaking,
          'jp': '渋滞のせいで疲なりました。',
          'answer': 'じゅうたいのせいでつかれました',
        },
      ];
    }
  List<Map<String, dynamic>> _getN3Bai2LuyenVietData() {
      return [
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '成功',
          'kanji_target': '成',
          'meaning': 'Thành (Trở thành / Thành công)',
          'rmj': 'sei / na(ru)'
        },
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '成功',
          'kanji_target': '功',
          'meaning': 'Công (Công lao / Thành công)',
          'rmj': 'kou'
        },
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '失敗',
          'kanji_target': '失',
          'meaning': 'Thất (Mất / Thất bại)',
          'rmj': 'shitsu / ushina(u)'
        },
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '失敗',
          'kanji_target': '敗',
          'meaning': 'Bại (Thua / Bại trận)',
          'rmj': 'hai / yabu(reru)'
        },
        {
          'type': LessonType.matching,
          'pairs': [
            {'left': 'Thành', 'right': '成'},
            {'left': 'Công', 'right': '功'},
            {'left': 'Thất', 'right': '失'},
            {'left': 'Bại', 'right': '敗'},
            {'left': 'Trưởng', 'right': '長'}, // Ôn lại chữ Trưởng (Giám đốc) ở Bài 1 N3
          ]
        },
      ];
    }
  List<Map<String, dynamic>> _getN3Bai3LyThuyetData() {
      return [
        // ================= PHẦN 1: TỪ VỰNG =================
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': '約束', 'hiragana': 'やくそく', 'romaji': 'yakusoku', 'meaning': 'Lời hứa / Cuộc hẹn'},
            {'kanji': '守ります', 'hiragana': 'まもります', 'romaji': 'mamorimasu', 'meaning': 'Bảo vệ / Giữ (lời hứa)'},
            {'kanji': '嘘', 'hiragana': 'うそ', 'romaji': 'uso', 'meaning': 'Lời nói dối'},
            {'kanji': 'つきます', 'hiragana': 'つきます', 'romaji': 'tsukimasu', 'meaning': 'Nói (đi kèm với dối)'},
            {'kanji': '絶対', 'hiragana': 'ぜったい', 'romaji': 'zettai', 'meaning': 'Tuyệt đối / Chắc chắn'},
            {'kanji': '会議', 'hiragana': 'かいぎ', 'romaji': 'kaigi', 'meaning': 'Cuộc họp'},
          ]
        },

        // --- NHÓM TỪ 1: HÀNH ĐỘNG ---
        {
          'type': LessonType.flashCard, 'kanji': '約束', 'hiragana': 'やくそく', 'romaji': 'yakusoku', 'meaning': 'Lời hứa',
          'example_img': 'assets/images/example_yakusoku.png',
          'example_jp': '約束を守ります。', 'example_rmj': 'Yakusoku o mamorimasu.', 'example_vn': 'Tôi giữ lời hứa.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '嘘', 'hiragana': 'うそ', 'romaji': 'uso', 'meaning': 'Nói dối',
          'example_img': 'assets/images/example_uso.png',
          'example_jp': '嘘をつきます。', 'example_rmj': 'Uso o tsukimasu.', 'example_vn': 'Nói dối.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '守ります', 'hiragana': 'まもります', 'romaji': 'mamorimasu', 'options': ['bảo vệ', 'nói dối', 'cuộc họp', 'tuyệt đối'], 'answer': 'bảo vệ'},

        // --- NHÓM TỪ 2: TÌNH HUỐNG ---
        {
          'type': LessonType.flashCard, 'kanji': '絶対', 'hiragana': 'ぜったい', 'romaji': 'zettai', 'meaning': 'Tuyệt đối',
          'example_img': 'assets/images/example_zettai.png',
          'example_jp': '絶対に勝つ。', 'example_rmj': 'Zettai ni katsu.', 'example_vn': 'Tuyệt đối (chắc chắn) sẽ thắng.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '会議', 'hiragana': 'かいぎ', 'romaji': 'kaigi', 'meaning': 'Cuộc họp',
          'example_img': 'assets/images/example_kaigi.png',
          'example_jp': '会議に出ます。', 'example_rmj': 'Kaigi ni demasu.', 'example_vn': 'Tham gia cuộc họp.'
        },
        {'type': LessonType.listening, 'options': ['やくそく', 'うそ', 'ぜったい', 'かいぎ'], 'answer': 'かいぎ'},

        // ================= PHẦN 2: NGỮ PHÁP =================
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'Thể thông thường + はずです', 'meaning': 'Chắc chắn là... (Phán đoán có căn cứ)'},
            {'title': 'V(từ điển) + べきです', 'meaning': 'Nên / Cần phải... (Đạo lý, bổn phận)'},
          ]
        },

        // NGỮ PHÁP 1: はずです
        {
          'type': LessonType.grammarStructure,
          'title': 'PHÁN ĐOÁN CHẮC CHẮN',
          'formula': 'V/A/N (thể thông thường) + はずです',
          'meaning': 'Chắc chắn là / Lẽ ra là...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜はずです',
          'notes': [
            'Dùng để đưa ra phán đoán, kết luận có mức độ chắc chắn rất cao, dựa trên một căn cứ khách quan nào đó.',
            'Chú ý: Tính từ (な) giữ nguyên (な), Danh từ thêm (の) trước はず.',
            'Ví dụ: 彼は来るはずです (Anh ấy chắc chắn sẽ đến - vì đã hứa).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'PHÁN ĐOÁN CHẮC CHẮN',
          'img': 'assets/images/example_hazu.png',
          'jp': '今日は会議があるはずです。',
          'rmj': 'Kyou wa kaigi ga aru hazu desu.',
          'vn': 'Hôm nay chắc chắn là có cuộc họp.'
        },

        // NGỮ PHÁP 2: べきです
        {
          'type': LessonType.grammarStructure,
          'title': 'BỔN PHẬN / LỜI KHUYÊN',
          'formula': 'V (thể từ điển) + べきです',
          'meaning': 'Cần phải / Nên làm...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜べきです',
          'notes': [
            'Dùng để nói về những việc mà theo lẽ thường tình, theo đạo đức là "nên làm" hoặc "phải làm".',
            'Mạnh mẽ hơn ほうがいいです (N4), thường dùng để phê phán hoặc nhắc nhở bổn phận.',
            'Ngoại lệ: する (Làm) -> すべきです (Nên làm).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'BỔN PHẬN / LỜI KHUYÊN',
          'img': 'assets/images/example_beki.png',
          'jp': '約束は守るべきです。',
          'rmj': 'Yakusoku wa mamoru beki desu.',
          'vn': 'Lời hứa thì cần phải được giữ.'
        },

        // ================= PHẦN 3: TỔNG KẾT =================
        {
          'type': LessonType.vocabSummary,
          'words': [
            {'kanji': '約束', 'romaji': 'yakusoku', 'meaning': 'lời hứa'},
            {'kanji': '守ります', 'romaji': 'mamorimasu', 'meaning': 'bảo vệ'},
            {'kanji': '嘘', 'romaji': 'uso', 'meaning': 'nói dối'},
            {'kanji': '絶対', 'romaji': 'zettai', 'meaning': 'tuyệt đối'},
            {'kanji': 'はずです', 'romaji': 'hazu desu', 'meaning': 'chắc chắn là'},
            {'kanji': 'べきです', 'romaji': 'beki desu', 'meaning': 'cần phải'},
          ]
        }
      ];
    }
  List<Map<String, dynamic>> _getN3Bai3LuyenTap1Data() {
      return [
        {
          'type': LessonType.imageQuiz,
          'question': 'Lời hứa.',
          'answerIndex': 0,
          'options': [
            {'img': 'assets/images/example_yakusoku.png', 'jp': '約束', 'rmj': 'yakusoku'},
            {'img': 'assets/images/example_uso.png', 'jp': '嘘', 'rmj': 'uso'},
            {'img': 'assets/images/example_kaigi.png', 'jp': '会議', 'rmj': 'kaigi'},
            {'img': 'assets/images/example_zettai.png', 'jp': '絶対', 'rmj': 'zettai'},
          ]
        },
        {
          'type': LessonType.listening,
          'options': [
            {'kanji': '守ります', 'hiragana': 'まもります'},
            {'kanji': '嘘', 'hiragana': 'うそ'},
            {'kanji': '会議', 'hiragana': 'かいぎ'},
            {'kanji': '約束', 'hiragana': 'やくそく'},
          ],
          'answer': '嘘'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '約束を守ります。',
          'rmj': 'Yakusoku o mamorimasu.',
          'audio_text': '約束を守ります。',
          'words': ['lời hứa', 'giữ', 'nói dối', 'tuyệt đối', 'cuộc họp'],
          'answer': 'giữ lời hứa',
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '絶対に会議に出ます。',
          'words': ['絶対', 'に', '会議', 'に', '出ます', '嘘'],
          'answer': '絶対 に 会議 に 出ます',
        },
      ];
    }
  List<Map<String, dynamic>> _getN3Bai3LuyenTap2Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền từ đúng (Anh ấy CHẮC CHẮN sẽ đến): \n彼は来る ( ... ) です。',
          'options': ['べき', 'はず', 'つもり', 'おかげで'],
          'answer': 'はず'
        },
        {
          'type': LessonType.quiz,
          'question': 'Hôm nay chắc chắn là có cuộc họp.',
          'audio_text': '今日は会議があるはずです。',
          'options': [
            {'kanji': '今日は会議があるはずです。', 'hiragana': 'きょうはかいぎがあるはずです。'},
            {'kanji': '今日は会議があるべきです。', 'hiragana': 'きょうはかいぎがあるべきです。'} // Bẫy logic
          ],
          'answer': '今日は会議があるはずです。'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '先生は忙しいはずです。',
          'words': ['先生', 'は', '忙しい', 'はず', 'です', 'べき'],
          'answer': '先生 は 忙しい はず です',
        },
      ];
    }
  List<Map<String, dynamic>> _getN3Bai3LuyenTap3Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền từ đúng (Không được nói dối): \n嘘をつく ( ... ) ではない。',
          'options': ['はず', 'べき', 'つもり', 'ため'],
          'answer': 'べき'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '約束は守るべきです。',
          'words': ['約束', 'は', '守る', 'べき', 'です', 'はず'],
          'answer': '約束 は 守る べき です',
        },
        {
          'type': LessonType.matching,
          'pairs': [
            {'left': 'Lời hứa', 'right': '約束'},
            {'left': 'Giữ / Bảo vệ', 'right': '守ります'},
            {'left': 'Nói dối', 'right': '嘘'},
            {'left': 'Chắc chắn là', 'right': 'はずです'},
            {'left': 'Cần phải', 'right': 'べきです'},
          ]
        },
      ];
    }
  List<Map<String, dynamic>> _getN3Bai3LuyenNoiData() {
      return [
        {
          'type': LessonType.speaking,
          'jp': '約束を守ります。',
          'answer': 'やくそくをまもります',
        },
        {
          'type': LessonType.speaking,
          'jp': '嘘をつきません。',
          'answer': 'うそをつきません',
        },
        {
          'type': LessonType.speaking,
          'jp': '今日は会議があるはずです。',
          'answer': 'きょうはかいぎがあるはずです',
        },
        {
          'type': LessonType.speaking,
          'jp': '約束は守るべきです。',
          'answer': 'やくそくはまもるべきです',
        },
        {
          'type': LessonType.speaking,
          'jp': '嘘をつくべきではありません。', // Phủ định của beki
          'answer': 'うそをつくべきではありません',
        },
      ];
    }
  List<Map<String, dynamic>> _getN3Bai3LuyenVietData() {
      return [
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '約束',
          'kanji_target': '約',
          'meaning': 'Ước (Lời hứa / Ước lượng)',
          'rmj': 'yaku'
        },
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '約束',
          'kanji_target': '束',
          'meaning': 'Thúc (Bó / Buộc)',
          'rmj': 'soku / taba'
        },
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '守ります',
          'kanji_target': '守',
          'meaning': 'Thủ (Bảo vệ / Giữ gìn)',
          'rmj': 'mamo(rimasu) / shu'
        },
        {
          'type': LessonType.kanjiDraw,
          'kanji_word': '会議',
          'kanji_target': '議',
          'meaning': 'Nghị (Hội nghị / Thảo luận)',
          'rmj': 'gi'
        },
        {
          'type': LessonType.matching,
          'pairs': [
            {'left': 'Ước', 'right': '約'},
            {'left': 'Thúc', 'right': '束'},
            {'left': 'Thủ', 'right': '守'},
            {'left': 'Nghị', 'right': '議'},
            {'left': 'Hội', 'right': '会'}, // Ôn lại Hội trong Công ty (N4) -> Hội Nghị (N3)
          ]
        },
      ];
    }
  List<Map<String, dynamic>> _getN3Bai4LyThuyetData() {
      return [
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': '試合', 'hiragana': 'しあい', 'romaji': 'shiai', 'meaning': 'Trận đấu'},
            {'kanji': '勝ちます', 'hiragana': 'かちます', 'romaji': 'kachimasu', 'meaning': 'Thắng'},
            {'kanji': '負けます', 'hiragana': 'まけます', 'romaji': 'makemasu', 'meaning': 'Thua'},
            {'kanji': 'ニュース', 'hiragana': 'ニュース', 'romaji': 'nyuusu', 'meaning': 'Tin tức'},
            {'kanji': '噂', 'hiragana': 'うわさ', 'romaji': 'uwasa', 'meaning': 'Tin đồn'},
            {'kanji': '厳しい', 'hiragana': 'きびしい', 'romaji': 'kibishii', 'meaning': 'Nghiêm khắc / Khắt khe'},
          ]
        },
        {
          'type': LessonType.flashCard, 'kanji': '試合', 'hiragana': 'しあい', 'romaji': 'shiai', 'meaning': 'Trận đấu',
          'example_img': 'assets/images/example_shiai.png',
          'example_jp': 'サッカーの試合です。', 'example_rmj': 'Sakkā no shiai desu.', 'example_vn': 'Trận đấu bóng đá.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '勝ちます', 'hiragana': 'かちます', 'romaji': 'kachimasu', 'meaning': 'Thắng',
          'example_img': 'assets/images/example_kachimasu.png',
          'example_jp': '試合に勝ちました。', 'example_rmj': 'Shiai ni kachimashita.', 'example_vn': 'Đã thắng trận đấu.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '負けます', 'hiragana': 'まけます', 'romaji': 'makemasu', 'options': ['thắng', 'nghiêm khắc', 'thua', 'tin đồn'], 'answer': 'thua'},
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'Thể thông thường + そうです', 'meaning': 'Nghe nói là... (Truyền đạt lại 100%)'},
            {'title': 'Thể thông thường + らしいです', 'meaning': 'Nghe đồn là / Có vẻ như là...'},
          ]
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'TRUYỀN ĐẠT THÔNG TIN',
          'formula': 'Động từ/Tính từ/Danh từ (Thể thông thường) + そうです',
          'meaning': 'Nghe nói là...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜そうです',
          'notes': [
            'Truyền đạt lại chính xác thông tin mình đã nghe, đọc được từ nguồn khác.',
            'Chú ý: Khác với そうです (trông có vẻ) ở N4. Ở N3, ta phải chia động từ về THỂ THÔNG THƯỜNG.',
            'Nguồn thông tin thường đi kèm với: 〜によると (Theo như...)'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'NGHE NÓI',
          'img': 'assets/images/example_sou_desu.png',
          'jp': 'ニュースによると、明日雨が降るそうです。',
          'rmj': 'Nyuusu ni yoru to, ashita ame ga furu sou desu.',
          'vn': 'Theo tin tức, nghe nói ngày mai trời sẽ mưa.'
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'TIN ĐỒN / CẢM NHẬN',
          'formula': 'Danh từ / Thể thông thường + らしいです',
          'meaning': 'Nghe đồn là / Hình như là...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜らしいです',
          'notes': [
            'Dùng để đưa ra phán đoán dựa trên những gì mình nghe được (tin đồn) hoặc cảm nhận được.',
            'Danh từ và Tính từ (な) ghép trực tiếp, KHÔNG thêm だ.',
            'Ví dụ: 彼は先生らしいです (Nghe đồn anh ấy là giáo viên).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'TIN ĐỒN',
          'img': 'assets/images/example_rashii.png',
          'jp': 'あの先生は厳しいらしいです。',
          'rmj': 'Ano sensei wa kibishii rashii desu.',
          'vn': 'Nghe đồn giáo viên đó nghiêm khắc lắm.'
        },
        {
          'type': LessonType.vocabSummary,
          'words': [
            {'kanji': '試合', 'romaji': 'shiai', 'meaning': 'trận đấu'},
            {'kanji': '勝ちます', 'romaji': 'kachimasu', 'meaning': 'thắng'},
            {'kanji': '負けます', 'romaji': 'makemasu', 'meaning': 'thua'},
            {'kanji': '噂', 'romaji': 'uwasa', 'meaning': 'tin đồn'},
            {'kanji': 'そうです', 'romaji': 'sou desu', 'meaning': 'nghe nói'},
            {'kanji': 'らしいです', 'romaji': 'rashii desu', 'meaning': 'nghe đồn / có vẻ'},
          ]
        }
      ];
    }
  List<Map<String, dynamic>> _getN3Bai4LuyenTap1Data() {
      return [
        {
          'type': LessonType.imageQuiz,
          'question': 'Trận đấu.',
          'answerIndex': 0,
          'options': [
            {'img': 'assets/images/example_shiai.png', 'jp': '試合', 'rmj': 'shiai'},
            {'img': 'assets/images/example_kachimasu.png', 'jp': '勝ちます', 'rmj': 'kachimasu'},
            {'img': 'assets/images/example_makemasu.png', 'jp': '負けます', 'rmj': 'makemasu'},
            {'img': 'assets/images/example_uwasa.png', 'jp': '噂', 'rmj': 'uwasa'},
          ]
        },
        {
          'type': LessonType.listening,
          'options': [
            {'kanji': '勝ちます', 'hiragana': 'かちます'},
            {'kanji': '負けます', 'hiragana': 'まけます'},
            {'kanji': '厳しい', 'hiragana': 'きびしい'},
            {'kanji': '噂', 'hiragana': 'うわさ'},
          ],
          'answer': '勝ちます'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '試合に勝ちました。',
          'rmj': 'Shiai ni kachimashita.',
          'audio_text': '試合に勝ちました。',
          'words': ['trận đấu', 'thắng', 'trong', 'tin đồn', 'thua'],
          'answer': 'thắng trong trận đấu',
        },
      ];
    }
  List<Map<String, dynamic>> _getN3Bai4LuyenTap2Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Cấu trúc "Nghe nói" (そうだ) đi với loại từ nào?',
          'options': ['Thể thông thường', 'Bỏ ます', 'Thể TE', 'Thể TAI'],
          'answer': 'Thể thông thường'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': 'ニュースによると、雨が降るそうです。',
          'words': ['ニュース', 'によると', '雨', 'が', '降る', 'そう', 'です', 'らしい'],
          'answer': 'ニュース によると 雨 が 降る そう です',
        },
      ];
    }

    List<Map<String, dynamic>> _getN3Bai4LuyenTap3Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền từ (Nghe đồn anh ấy nghiêm khắc): \n彼は厳しい ( ... )。',
          'options': ['らしいです', 'らしいだ', 'そうです', 'そうします'],
          'answer': 'らしいです'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': 'あの先生は厳しいらしいです。',
          'words': ['あの', '先生', 'は', '厳しい', 'らしい', 'です', 'そう'],
          'answer': 'あの 先生 は 厳しい らしい です',
        },
      ];
    }

    List<Map<String, dynamic>> _getN3Bai4LuyenNoiData() {
      return [
        {
          'type': LessonType.speaking,
          'jp': '試合に勝ちました。',
          'answer': 'しあいにかちました',
        },
        {
          'type': LessonType.speaking,
          'jp': '試合に負けるそうです。',
          'answer': 'しあいまけるそうです',
        },
        {
          'type': LessonType.speaking,
          'jp': '明日は雨が降るそうです。',
          'answer': 'あしたはあめがふるそうです',
        },
        {
          'type': LessonType.speaking,
          'jp': 'あの先生は厳しいらしいです。',
          'answer': 'あのせんせいはきびしいらしいです',
        },
      ];
    }

    List<Map<String, dynamic>> _getN3Bai4LuyenVietData() {
      return [
        {
          'type': LessonType.kanjiDraw, 'kanji_word': '試合', 'kanji_target': '試', 'meaning': 'Thí (Thử nghiệm / Thi cử)', 'rmj': 'shi / kokoro(miru)'
        },
        {
          'type': LessonType.kanjiDraw, 'kanji_word': '試合', 'kanji_target': '合', 'meaning': 'Hợp (Phù hợp / Tập hợp)', 'rmj': 'ai / a(u)'
        },
        {
          'type': LessonType.kanjiDraw, 'kanji_word': '勝ちます', 'kanji_target': '勝', 'meaning': 'Thắng (Chiến thắng)', 'rmj': 'ka(tsu) / shou'
        },
        {
          'type': LessonType.kanjiDraw, 'kanji_word': '負けます', 'kanji_target': '負', 'meaning': 'Phụ (Thua / Mang vác)', 'rmj': 'ma(keru) / fu'
        },
      ];
    }
  List<Map<String, dynamic>> _getN3Bai5LyThuyetData() {
      return [
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': '留学します', 'hiragana': 'りゅうがくします', 'romaji': 'ryuugakushimasu', 'meaning': 'Du học'},
            {'kanji': '転勤します', 'hiragana': 'てんきんします', 'romaji': 'tenkinshimasu', 'meaning': 'Chuyển công tác'},
            {'kanji': '決めます', 'hiragana': 'きめます', 'romaji': 'kimemasu', 'meaning': 'Quyết định'},
            {'kanji': '規則', 'hiragana': 'きそく', 'romaji': 'kisoku', 'meaning': 'Quy tắc / Nội quy'},
            {'kanji': '法律', 'hiragana': 'ほうりつ', 'romaji': 'houritsu', 'meaning': 'Pháp luật'},
            {'kanji': '守ります', 'hiragana': 'まもります', 'romaji': 'mamorimasu', 'meaning': 'Tuân thủ (quy tắc)'},
          ]
        },
        {
          'type': LessonType.flashCard, 'kanji': '留学します', 'hiragana': 'りゅうがくします', 'romaji': 'ryuugakushimasu', 'meaning': 'Du học',
          'example_img': 'assets/images/example_ryuugaku.png',
          'example_jp': '日本へ留学します。', 'example_rmj': 'Nihon e ryuugakushimasu.', 'example_vn': 'Tôi đi du học Nhật Bản.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '転勤します', 'hiragana': 'てんきんします', 'romaji': 'tenkinshimasu', 'meaning': 'Chuyển công tác',
          'example_img': 'assets/images/example_tenkin.png',
          'example_jp': '東京へ転勤します。', 'example_rmj': 'Toukyou e tenkinshimasu.', 'example_vn': 'Tôi chuyển công tác đến Tokyo.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '規則', 'hiragana': 'きそく', 'romaji': 'kisoku', 'options': ['pháp luật', 'quy tắc', 'du học', 'quyết định'], 'answer': 'quy tắc'},
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'V(ru/nai) + ことにする', 'meaning': 'Tự mình quyết định làm gì'},
            {'title': 'V(ru/nai) + ことになる', 'meaning': 'Được quyết định là / Trở thành quy định'},
          ]
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'TỰ QUYẾT ĐỊNH',
          'formula': 'Động từ (thể từ điển / thể ない) + ことにする',
          'meaning': 'Tôi quyết định sẽ...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜ことにする',
          'notes': [
            'Dùng để diễn tả một quyết định do chính bản thân người nói đưa ra sau khi đã suy nghĩ.',
            'Ví dụ: 毎日運動することにする (Tôi quyết định mỗi ngày sẽ vận động).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'TỰ QUYẾT ĐỊNH',
          'img': 'assets/images/example_kotonisuru.png',
          'jp': '日本へ留学することにしました。',
          'rmj': 'Nihon e ryuugaku suru koto ni shimashita.',
          'vn': 'Tôi ĐÃ QUYẾT ĐỊNH đi du học Nhật Bản.'
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'ĐƯỢC QUYẾT ĐỊNH',
          'formula': 'Động từ (thể từ điển / thể ない) + ことになる',
          'meaning': 'Bị/Được quyết định là... / Thành ra là...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜ことになる',
          'notes': [
            'Dùng để diễn tả một quyết định, quy định mang tính khách quan (do công ty, nhà nước, hoặc số phận sắp đặt), bản thân không quyết định được.',
            'Thể tiếp diễn (ことになっている) thường dùng để chỉ các nội quy, pháp luật.'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'ĐƯỢC QUYẾT ĐỊNH',
          'img': 'assets/images/example_kotoninaru.png',
          'jp': '東京へ転勤することになりました。',
          'rmj': 'Toukyou e tenkin suru koto ni narimashita.',
          'vn': 'Tôi ĐÃ ĐƯỢC QUYẾT ĐỊNH là sẽ chuyển công tác đến Tokyo (lệnh công ty).'
        },
        {
          'type': LessonType.vocabSummary,
          'words': [
            {'kanji': '留学する', 'romaji': 'ryuugakusuru', 'meaning': 'du học'},
            {'kanji': '転勤する', 'romaji': 'tenkinsuru', 'meaning': 'chuyển công tác'},
            {'kanji': '規則', 'romaji': 'kisoku', 'meaning': 'quy tắc'},
            {'kanji': 'ことにする', 'romaji': 'koto ni suru', 'meaning': 'tự quyết định'},
            {'kanji': 'ことになる', 'romaji': 'koto ni naru', 'meaning': 'được quyết định'},
          ]
        }
      ];
    }

    List<Map<String, dynamic>> _getN3Bai5LuyenTap1Data() {
      return [
        {
          'type': LessonType.imageQuiz,
          'question': 'Du học.',
          'answerIndex': 2,
          'options': [
            {'img': 'assets/images/example_tenkin.png', 'jp': '転勤します', 'rmj': 'tenkinshimasu'},
            {'img': 'assets/images/example_kimemasu.png', 'jp': '決めます', 'rmj': 'kimemasu'},
            {'img': 'assets/images/example_ryuugaku.png', 'jp': '留学します', 'rmj': 'ryuugakushimasu'},
            {'img': 'assets/images/example_kisoku.png', 'jp': '規則', 'rmj': 'kisoku'},
          ]
        },
        {
          'type': LessonType.listening,
          'options': [
            {'kanji': '転勤します', 'hiragana': 'てんきんします'},
            {'kanji': '留学します', 'hiragana': 'りゅうがくします'},
            {'kanji': '規則', 'hiragana': 'きそく'},
            {'kanji': '法律', 'hiragana': 'ほうりつ'},
          ],
          'answer': '転勤します'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '日本へ留学します。',
          'rmj': 'Nihon e ryuugakushimasu.',
          'audio_text': '日本へ留学します。',
          'words': ['Nhật Bản', 'đến', 'du học', 'chuyển công tác', 'quy định'],
          'answer': 'du học đến Nhật Bản',
        },
      ];
    }

    List<Map<String, dynamic>> _getN3Bai5LuyenTap2Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Cấu trúc "TỰ MÌNH QUYẾT ĐỊNH" là gì?',
          'options': ['ことにある', 'ことになる', 'ことにする', 'ようとする'],
          'answer': 'ことにする'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '留学することにしました。',
          'words': ['留学', 'する', 'こと', 'に', 'しました', 'なりました'],
          'answer': '留学 する こと に しました',
        },
      ];
    }

    List<Map<String, dynamic>> _getN3Bai5LuyenTap3Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Công ty ra lệnh chuyển công tác. Dùng cấu trúc nào?',
          'options': ['ことにします', 'ことになります', 'はずです', 'べきです'],
          'answer': 'ことになります'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '転勤することになりました。',
          'words': ['転勤', 'する', 'こと', 'に', 'なりました', 'しました'],
          'answer': '転勤 する こと に なりました',
        },
      ];
    }

    List<Map<String, dynamic>> _getN3Bai5LuyenNoiData() {
      return [
        {
          'type': LessonType.speaking,
          'jp': '日本へ留学します。',
          'answer': 'にほんへりゅうがくします',
        },
        {
          'type': LessonType.speaking,
          'jp': '留学することにしました。',
          'answer': 'りゅうがくすることにしました',
        },
        {
          'type': LessonType.speaking,
          'jp': '東京へ転勤します。',
          'answer': 'とうきょうへてんきんします',
        },
        {
          'type': LessonType.speaking,
          'jp': '転勤することになりました。',
          'answer': 'てんきんすることになりました',
        },
      ];
    }

    List<Map<String, dynamic>> _getN3Bai5LuyenVietData() {
      return [
        {
          'type': LessonType.kanjiDraw, 'kanji_word': '留学', 'kanji_target': '留', 'meaning': 'Lưu (Lưu lại / Du học)', 'rmj': 'ryuu / to(meru)'
        },
        {
          'type': LessonType.kanjiDraw, 'kanji_word': '転勤', 'kanji_target': '転', 'meaning': 'Chuyển (Luân chuyển)', 'rmj': 'ten / koro(bu)'
        },
        {
          'type': LessonType.kanjiDraw, 'kanji_word': '転勤', 'kanji_target': '勤', 'meaning': 'Cần (Làm việc / Chuyên cần)', 'rmj': 'kin / tsuto(meru)'
        },
        {
          'type': LessonType.kanjiDraw, 'kanji_word': '規則', 'kanji_target': '規', 'meaning': 'Quy (Quy tắc)', 'rmj': 'ki'
        },
        {
          'type': LessonType.matching,
          'pairs': [
            {'left': 'Lưu', 'right': '留'},
            {'left': 'Chuyển', 'right': '転'},
            {'left': 'Cần', 'right': '勤'},
            {'left': 'Quy', 'right': '規'},
            {'left': 'Học', 'right': '学'}, // Lưu + Học = Du học
          ]
        },
      ];
    }
  List<Map<String, dynamic>> _getN3Bai6LyThuyetData() {
      return [
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': '泣きます', 'hiragana': 'なきます', 'romaji': 'nakimasu', 'meaning': 'Khóc'},
            {'kanji': '怒ります', 'hiragana': 'おこります', 'romaji': 'okorimasu', 'meaning': 'Tức giận'},
            {'kanji': '心配します', 'hiragana': 'しんぱいします', 'romaji': 'shinpaishimasu', 'meaning': 'Lo lắng'},
            {'kanji': '自由', 'hiragana': 'じゆう', 'romaji': 'jiyuu', 'meaning': 'Tự do'},
            {'kanji': '意見', 'hiragana': 'いけん', 'romaji': 'iken', 'meaning': 'Ý kiến'},
          ]
        },
        {
          'type': LessonType.flashCard, 'kanji': '泣きます', 'hiragana': 'なきます', 'romaji': 'nakimasu', 'meaning': 'Khóc',
          'example_img': 'assets/images/example_nakimasu.png',
          'example_jp': '子供が泣きます。', 'example_rmj': 'Kodomo ga nakimasu.', 'example_vn': 'Đứa trẻ khóc.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '心配します', 'hiragana': 'しんぱいします', 'romaji': 'shinpaishimasu', 'meaning': 'Lo lắng',
          'example_img': 'assets/images/example_shinpai.png',
          'example_jp': '親を心配させます。', 'example_rmj': 'Oya o shinpai sasemasu.', 'example_vn': 'Làm cho bố mẹ lo lắng.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '怒ります', 'hiragana': 'おこります', 'romaji': 'okorimasu', 'options': ['khóc', 'tức giận', 'tự do', 'lo lắng'], 'answer': 'tức giận'},
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'V (Thể Sai khiến)', 'meaning': 'Nhóm 1: a+せる, Nhóm 2: させる'},
            {'title': 'A は B を/に + V(sai khiến)', 'meaning': 'A bắt/cho phép B làm gì'},
          ]
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'THỂ SAI KHIẾN',
          'formula': 'Nhóm 1: cột [i] ➔ [a] + せます\nNhóm 2: bỏ ます ➔ させます',
          'meaning': 'Bắt / Cho phép làm gì'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'CÁCH DÙNG SAI KHIẾN',
          'notes': [
            'Dùng khi người bề trên (Giám đốc, Bố mẹ, Giáo viên) bắt hoặc cho phép người bề dưới làm gì.',
            'Ngoại động từ: A は B に N を V-sai khiến. (Giám đốc bắt nhân viên làm báo cáo).',
            'Nội động từ: A は B を V-sai khiến. (Mẹ bắt con chạy bộ).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'SAI KHIẾN',
          'img': 'assets/images/example_sasemasu.png',
          'jp': '母は子供に本を読ませます。',
          'rmj': 'Haha wa kodomo ni hon o yomasemasu.',
          'vn': 'Mẹ bắt con đọc sách.'
        },
        {
          'type': LessonType.vocabSummary,
          'words': [
            {'kanji': '泣かせる', 'romaji': 'nakaseru', 'meaning': 'làm cho khóc'},
            {'kanji': '怒らせる', 'romaji': 'okoraseru', 'meaning': 'làm cho tức giận'},
            {'kanji': '心配させる', 'romaji': 'shinpaisaseru', 'meaning': 'làm cho lo lắng'},
          ]
        }
      ];
    }

    List<Map<String, dynamic>> _getN3Bai6LuyenTap1Data() {
      return [
        {
          'type': LessonType.imageQuiz,
          'question': 'Làm cho lo lắng.',
          'answerIndex': 2,
          'options': [
            {'img': 'assets/images/example_nakimasu.png', 'jp': '泣きます', 'rmj': 'nakimasu'},
            {'img': 'assets/images/example_okorimasu.png', 'jp': '怒ります', 'rmj': 'okorimasu'},
            {'img': 'assets/images/example_shinpai.png', 'jp': '心配させます', 'rmj': 'shinpaisasemasu'},
            {'img': 'assets/images/example_jiyuu.png', 'jp': '自由', 'rmj': 'jiyuu'},
          ]
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '母は子供を泣かせます。',
          'rmj': 'Haha wa kodomo o nakasemasu.',
          'audio_text': '母は子供を泣かせます。',
          'words': ['mẹ', 'làm cho', 'con', 'khóc', 'tức giận'],
          'answer': 'mẹ làm cho con khóc',
        },
      ];
    }

    List<Map<String, dynamic>> _getN3Bai6LuyenTap2Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Thể sai khiến của 読む (Đọc) là gì?',
          'options': ['読まれます', '読ませます', '読めます', '読まります'],
          'answer': '読ませます'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '先生は学生に意見を言わせます。',
          'words': ['先生', 'は', '学生', 'に', '意見', 'を', '言わせます'],
          'answer': '先生 は 学生 に 意見 を 言わせます',
        },
      ];
    }

    List<Map<String, dynamic>> _getN3Bai6LuyenTap3Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Giám đốc bắt tôi làm việc. Điền trợ từ: \n社長は私 ( ... ) 働かせます。',
          'options': ['に', 'が', 'を', 'で'],
          'answer': 'を' // Nội động từ (Làm việc) dùng を
        },
        {
          'type': LessonType.matching,
          'pairs': [
            {'left': 'Khóc', 'right': '泣きます'},
            {'left': 'Làm cho khóc', 'right': '泣かせます'},
            {'left': 'Tức giận', 'right': '怒ります'},
            {'left': 'Làm cho lo lắng', 'right': '心配させます'},
            {'left': 'Ý kiến', 'right': '意見'},
          ]
        },
      ];
    }

    List<Map<String, dynamic>> _getN3Bai6LuyenNoiData() {
      return [
        {'type': LessonType.speaking, 'jp': '子供を泣かせます。', 'answer': 'こどもをなかせます'},
        {'type': LessonType.speaking, 'jp': '親を心配させます。', 'answer': 'おやをしんぱいさせます'},
        {'type': LessonType.speaking, 'jp': '意見を言わせます。', 'answer': 'いけんをいわせます'},
      ];
    }

    List<Map<String, dynamic>> _getN3Bai6LuyenVietData() {
      return [
        {'type': LessonType.kanjiDraw, 'kanji_word': '泣きます', 'kanji_target': '泣', 'meaning': 'Khấp (Khóc)', 'rmj': 'na(kimasu)'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '怒ります', 'kanji_target': '怒', 'meaning': 'Nộ (Tức giận)', 'rmj': 'oko(rimasu) / ikari'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '心配', 'kanji_target': '心', 'meaning': 'Tâm (Trái tim / Tâm trí)', 'rmj': 'shin / kokoro'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '心配', 'kanji_target': '配', 'meaning': 'Phối (Phân phối)', 'rmj': 'pai / kuba(ru)'},
      ];
    }
  List<Map<String, dynamic>> _getN3Bai7LyThuyetData() {
      return [
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': '待ちます', 'hiragana': 'まちます', 'romaji': 'machimasu', 'meaning': 'Chờ đợi'},
            {'kanji': '掃除します', 'hiragana': 'そうじします', 'romaji': 'soujishimasu', 'meaning': 'Dọn dẹp'},
            {'kanji': '無理', 'hiragana': 'むり', 'romaji': 'muri', 'meaning': 'Vô lý / Quá sức'},
            {'kanji': '嫌', 'hiragana': 'いや', 'romaji': 'iya', 'meaning': 'Chán ghét / Không thích'},
          ]
        },
        {
          'type': LessonType.flashCard, 'kanji': '待ちます', 'hiragana': 'まちます', 'romaji': 'machimasu', 'meaning': 'Chờ đợi',
          'example_img': 'assets/images/example_matsu.png',
          'example_jp': '１時間待たされました。', 'example_rmj': 'Ichijikan matasaremashita.', 'example_vn': 'Tôi BỊ BẮT CHỜ 1 tiếng đồng hồ.'
        },
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'V(bị động sai khiến)', 'meaning': 'Cách chia: a+される / させられる'},
            {'title': 'A は B に V(bđ-sk)', 'meaning': 'A BỊ B bắt làm việc gì đó (không muốn)'},
          ]
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'BỊ ĐỘNG SAI KHIẾN',
          'formula': 'Nhóm 1: cột [i] ➔ [a] + されます\nNhóm 2: bỏ ます ➔ させられます',
          'meaning': 'Bị bắt phải làm gì...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG BỊ ĐỘNG SAI KHIẾN',
          'notes': [
            'Dùng để than phiền việc mình KHÔNG MUỐN LÀM nhưng BỊ NGƯỜI KHÁC ÉP BUỘC.',
            'Ví dụ Nhóm 1: 飲む ➔ 飲まされる (Bị bắt uống - ép rượu).',
            'Ví dụ Nhóm 2: 食べる ➔ 食べさせられる (Bị bắt ăn).',
            'Nhóm 3: される ➔ させられる (Bị bắt làm).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'BỊ BẮT LÀM',
          'img': 'assets/images/example_soujisasareru.png',
          'jp': '私は母に部屋を掃除させられました。',
          'rmj': 'Watashi wa haha ni heya o souji saseraremashita.',
          'vn': 'Tôi bị mẹ bắt dọn dẹp phòng.'
        },
        {
          'type': LessonType.vocabSummary,
          'words': [
            {'kanji': '待たされる', 'romaji': 'matasareru', 'meaning': 'bị bắt chờ'},
            {'kanji': '飲まされる', 'romaji': 'nomasareru', 'meaning': 'bị ép uống'},
            {'kanji': '掃除させられる', 'romaji': 'soujidasaserareru', 'meaning': 'bị bắt dọn dẹp'},
          ]
        }
      ];
    }

    List<Map<String, dynamic>> _getN3Bai7LuyenTap1Data() {
      return [
        {
          'type': LessonType.imageQuiz,
          'question': 'Dọn dẹp.',
          'answerIndex': 1,
          'options': [
            {'img': 'assets/images/example_matsu.png', 'jp': '待ちます', 'rmj': 'machimasu'},
            {'img': 'assets/images/example_souji.png', 'jp': '掃除します', 'rmj': 'soujishimasu'},
            {'img': 'assets/images/example_muri.png', 'jp': '無理', 'rmj': 'muri'},
            {'img': 'assets/images/example_iya.png', 'jp': '嫌', 'rmj': 'iya'},
          ]
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '母に掃除させられました。',
          'rmj': 'Haha ni souji saseraremashita.',
          'audio_text': '母に掃除させられました。',
          'words': ['mẹ', 'bị', 'bắt', 'dọn dẹp', 'khen'],
          'answer': 'bị mẹ bắt dọn dẹp',
        },
      ];
    }

    List<Map<String, dynamic>> _getN3Bai7LuyenTap2Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Thể Bị động sai khiến của 飲む (Uống) là gì?',
          'options': ['飲ませられます', '飲まされます', '飲まれます', '飲ませます'],
          'answer': '飲まされます'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '部長にお酒を飲まされました。',
          'words': ['部長', 'に', 'お酒', 'を', '飲まされました', '飲みました'],
          'answer': '部長 に お酒 を 飲まされました',
        },
      ];
    }

    List<Map<String, dynamic>> _getN3Bai7LuyenTap3Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Tôi bị bạn bắt chờ 1 tiếng. Chọn câu đúng:',
          'options': ['友達に１時間待たされました。', '友達を１時間待たせました。', '友達が１時間待ちました。'],
          'answer': '友達に１時間待たされました。'
        },
        {
          'type': LessonType.matching,
          'pairs': [
            {'left': 'Chờ đợi', 'right': '待ちます'},
            {'left': 'Bị bắt chờ', 'right': '待たされます'},
            {'left': 'Uống', 'right': '飲みます'},
            {'left': 'Bị ép uống', 'right': '飲まされます'},
            {'left': 'Vô lý', 'right': '無理'},
          ]
        },
      ];
    }

    List<Map<String, dynamic>> _getN3Bai7LuyenNoiData() {
      return [
        {'type': LessonType.speaking, 'jp': '１時間待たされました。', 'answer': 'いちじかんまたされました'},
        {'type': LessonType.speaking, 'jp': 'お酒を飲まされました。', 'answer': 'おさけをのまされました'},
        {'type': LessonType.speaking, 'jp': '部屋を掃除させられました。', 'answer': 'へやをそうじさせられました'},
      ];
    }

    List<Map<String, dynamic>> _getN3Bai7LuyenVietData() {
      return [
        {'type': LessonType.kanjiDraw, 'kanji_word': '待ちます', 'kanji_target': '待', 'meaning': 'Đãi (Chờ đợi / Đối đãi)', 'rmj': 'ma(tsu) / tai'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '無理', 'kanji_target': '無', 'meaning': 'Vô (Không có)', 'rmj': 'mu / na(i)'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '無理', 'kanji_target': '理', 'meaning': 'Lý (Lý do / Logic)', 'rmj': 'ri'},
      ];
    }
  List<Map<String, dynamic>> _getN3Bai8LyThuyetData() {
      return [
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': '咲きます', 'hiragana': 'さきます', 'romaji': 'sakimasu', 'meaning': 'Nở (hoa)'},
            {'kanji': '春', 'hiragana': 'はる', 'romaji': 'haru', 'meaning': 'Mùa xuân'},
            {'kanji': '桜', 'hiragana': 'さくら', 'romaji': 'sakura', 'meaning': 'Hoa anh đào'},
            {'kanji': '温泉', 'hiragana': 'おんせん', 'romaji': 'onsen', 'meaning': 'Suối nước nóng'},
            {'kanji': '都合', 'hiragana': 'つごう', 'romaji': 'tsugou', 'meaning': 'Điều kiện / Thuận tiện'},
          ]
        },
        {
          'type': LessonType.flashCard, 'kanji': '咲きます', 'hiragana': 'さきます', 'romaji': 'sakimasu', 'meaning': 'Nở (hoa)',
          'example_img': 'assets/images/example_sakimasu.png',
          'example_jp': '桜が咲けば...。', 'example_rmj': 'Sakura ga sakeba...', 'example_vn': 'Nếu hoa anh đào nở...'
        },
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'V(ば) / A(ければ)', 'meaning': 'Nếu... (Điều kiện tự nhiên, tất yếu)'},
            {'title': 'N / A(な) + なら', 'meaning': 'Nếu là... (Đưa ra lời khuyên)'},
          ]
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'ĐIỀU KIỆN ば',
          'formula': 'Động từ: cột [i] ➔ [e] + ば\nTính từ [i]: bỏ い ➔ ければ',
          'meaning': 'Nếu...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜ば',
          'notes': [
            'Dùng cho các điều kiện mang tính tự nhiên, hiển nhiên.',
            'Ví dụ Động từ: 行く ➔ 行けば (Nếu đi).',
            'Ví dụ Tính từ: 安い ➔ 安ければ (Nếu rẻ).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'ĐIỀU KIỆN ば',
          'img': 'assets/images/example_haru.png',
          'jp': '春になれば、桜が咲きます。',
          'rmj': 'Haru ni nareba, sakura ga sakimasu.',
          'vn': 'Nếu mùa xuân đến, hoa anh đào sẽ nở.'
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'ĐIỀU KIỆN なら',
          'formula': 'Danh từ / Tính từ (な) + なら',
          'meaning': 'Nếu là (cái đó) thì...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜なら',
          'notes': [
            'Dùng để tiếp nhận chủ đề từ người nghe và đưa ra lời khuyên, nhận định của mình.',
            'Ví dụ: 温泉なら、箱根がいいですよ (Nếu là suối nước nóng thì Hakone là nhất đấy).'
          ]
        },
        {
          'type': LessonType.vocabSummary,
          'words': [
            {'kanji': '行けば', 'romaji': 'ikeba', 'meaning': 'nếu đi'},
            {'kanji': '安ければ', 'romaji': 'yasukereba', 'meaning': 'nếu rẻ'},
            {'kanji': '温泉なら', 'romaji': 'onsen nara', 'meaning': 'nếu là suối nước nóng'},
          ]
        }
      ];
    }

    List<Map<String, dynamic>> _getN3Bai8LuyenTap1Data() {
      return [
        {
          'type': LessonType.imageQuiz,
          'question': 'Hoa anh đào.',
          'answerIndex': 1,
          'options': [
            {'img': 'assets/images/example_haru.png', 'jp': '春', 'rmj': 'haru'},
            {'img': 'assets/images/example_sakura.png', 'jp': '桜', 'rmj': 'sakura'},
            {'img': 'assets/images/example_onsen.png', 'jp': '温泉', 'rmj': 'onsen'},
            {'img': 'assets/images/example_sakimasu.png', 'jp': '咲きます', 'rmj': 'sakimasu'},
          ]
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '春になれば桜が咲きます。',
          'rmj': 'Haru ni nareba sakura ga sakimasu.',
          'audio_text': '春になれば桜が咲きます。',
          'words': ['nếu', 'mùa xuân', 'hoa', 'anh đào', 'sẽ nở'],
          'answer': 'nếu mùa xuân hoa anh đào sẽ nở',
        },
      ];
    }

    List<Map<String, dynamic>> _getN3Bai8LuyenTap2Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Chia "Nếu rẻ" (安い) sang cấu trúc ば:',
          'options': ['安くば', '安ければ', '安いなら', '安ならば'],
          'answer': '安ければ'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '安ければ、買います。',
          'words': ['安ければ', '買います', '安い', 'ば'],
          'answer': '安ければ 買います',
        },
      ];
    }

    List<Map<String, dynamic>> _getN3Bai8LuyenTap3Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền từ đúng (Nếu là suối nước nóng thì...): \n温泉 ( ... ) 箱根がいいです。',
          'options': ['なら', 'ば', 'たら', 'ならは'],
          'answer': 'なら'
        },
        {
          'type': LessonType.matching,
          'pairs': [
            {'left': 'Mùa xuân', 'right': '春'},
            {'left': 'Nở', 'right': '咲きます'},
            {'left': 'Nếu đi', 'right': '行けば'},
            {'left': 'Nếu rẻ', 'right': '安ければ'},
            {'left': 'Nếu là suối', 'right': '温泉なら'},
          ]
        },
      ];
    }

    List<Map<String, dynamic>> _getN3Bai8LuyenNoiData() {
      return [
        {'type': LessonType.speaking, 'jp': '春になれば、桜が咲きます。', 'answer': 'はるになればさくらがさきます'},
        {'type': LessonType.speaking, 'jp': '安ければ買います。', 'answer': 'やすければかいます'},
        {'type': LessonType.speaking, 'jp': '温泉なら、ここがいいです。', 'answer': 'おんせんならここがいいです'},
      ];
    }

    List<Map<String, dynamic>> _getN3Bai8LuyenVietData() {
      return [
        {'type': LessonType.kanjiDraw, 'kanji_word': '春', 'kanji_target': '春', 'meaning': 'Xuân (Mùa xuân)', 'rmj': 'haru / shun'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '桜', 'kanji_target': '桜', 'meaning': 'Anh (Hoa anh đào)', 'rmj': 'sakura / ou'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '温泉', 'kanji_target': '温', 'meaning': 'Ôn (Ấm áp)', 'rmj': 'on / atata(kai)'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '温泉', 'kanji_target': '泉', 'meaning': 'Tuyền (Suối)', 'rmj': 'sen / izumi'},
      ];
    }
  List<Map<String, dynamic>> _getN3Bai9LyThuyetData() {
      return [
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': '貯金します', 'hiragana': 'ちょきんします', 'romaji': 'chokinshimasu', 'meaning': 'Tiết kiệm tiền'},
            {'kanji': '合格します', 'hiragana': 'ごうかくします', 'romaji': 'goukakushimasu', 'meaning': 'Đỗ / Đậu (kỳ thi)'},
            {'kanji': '痩せます', 'hiragana': 'やせます', 'romaji': 'yasemasu', 'meaning': 'Giảm cân / Gầy đi'},
            {'kanji': '健康', 'hiragana': 'けんこう', 'romaji': 'kenkou', 'meaning': 'Sức khỏe'},
            {'kanji': '目的', 'hiragana': 'もくてき', 'romaji': 'mokuteki', 'meaning': 'Mục đích'},
          ]
        },
        {
          'type': LessonType.flashCard, 'kanji': '貯金します', 'hiragana': 'ちょきんします', 'romaji': 'chokinshimasu', 'meaning': 'Tiết kiệm',
          'example_img': 'assets/images/example_chokin.png',
          'example_jp': '車を買うために貯金します。', 'example_rmj': 'Kuruma o kau tame ni chokin shimasu.', 'example_vn': 'Tôi tiết kiệm tiền để mua xe.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '合格します', 'hiragana': 'ごうかくします', 'romaji': 'goukakushimasu', 'meaning': 'Đỗ (kỳ thi)',
          'example_img': 'assets/images/example_goukaku.png',
          'example_jp': '試験に合格するように...。', 'example_rmj': 'Shiken ni goukaku suru you ni...', 'example_vn': 'Để có thể đỗ kỳ thi...'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '健康', 'hiragana': 'けんこう', 'romaji': 'kenkou', 'options': ['sức khỏe', 'giảm cân', 'mục đích', 'tiết kiệm'], 'answer': 'sức khỏe'},
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'V(ru) / N(の) + ために', 'meaning': 'Để... (Mục đích rõ ràng, ý chí mạnh)'},
            {'title': 'V(khả năng/nai) + ように', 'meaning': 'Để có thể... (Hướng tới trạng thái)'},
          ]
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'MỤC ĐÍCH (ために)',
          'formula': 'V(từ điển) / Danh từ + の + ために',
          'meaning': 'Để / Vì lợi ích của...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜ために',
          'notes': [
            'Chủ ngữ trước và sau ために phải là CÙNG MỘT NGƯỜI.',
            'Động từ đứng trước ために phải là động từ mang ý chí (Mua, Học, Đi...).',
            'Ví dụ: 家族のために働きます (Tôi làm việc vì gia đình).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'MỤC ĐÍCH',
          'img': 'assets/images/example_tame_ni.png',
          'jp': '家を買うために、貯金します。',
          'rmj': 'Ie o kau tame ni, chokin shimasu.',
          'vn': 'Tôi tiết kiệm tiền ĐỂ mua nhà.'
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'TRẠNG THÁI (ように)',
          'formula': 'V(khả năng / ない) + ように',
          'meaning': 'Để có thể... / Để không...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜ように',
          'notes': [
            'Dùng với các động từ KHÔNG MANG Ý CHÍ (như thể khả năng: Có thể mua, Có thể hiểu) hoặc thể ない.',
            'Mục tiêu là đạt được một trạng thái nào đó.',
            'Ví dụ: 忘れないように、メモします (Tôi ghi chú để không bị quên).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'TRẠNG THÁI',
          'img': 'assets/images/example_you_ni.png',
          'jp': '日本語が話せるように、勉強します。',
          'rmj': 'Nihongo ga hanaseru you ni, benkyou shimasu.',
          'vn': 'Tôi học bài ĐỂ CÓ THỂ nói được tiếng Nhật.'
        },
        {
          'type': LessonType.vocabSummary,
          'words': [
            {'kanji': '貯金する', 'romaji': 'chokinsuru', 'meaning': 'tiết kiệm'},
            {'kanji': '合格する', 'romaji': 'goukakusuru', 'meaning': 'đỗ kỳ thi'},
            {'kanji': '痩せる', 'romaji': 'yaseru', 'meaning': 'giảm cân'},
            {'kanji': 'ために', 'romaji': 'tame ni', 'meaning': 'để (chủ ý)'},
            {'kanji': 'ように', 'romaji': 'you ni', 'meaning': 'để có thể'},
          ]
        }
      ];
    }

    List<Map<String, dynamic>> _getN3Bai9LuyenTap1Data() {
      return [
        {
          'type': LessonType.imageQuiz,
          'question': 'Tiết kiệm tiền.',
          'answerIndex': 3,
          'options': [
            {'img': 'assets/images/example_goukaku.png', 'jp': '合格します', 'rmj': 'goukakushimasu'},
            {'img': 'assets/images/example_kenkou.png', 'jp': '健康', 'rmj': 'kenkou'},
            {'img': 'assets/images/example_yasemasu.png', 'jp': '痩せます', 'rmj': 'yasemasu'},
            {'img': 'assets/images/example_chokin.png', 'jp': '貯金します', 'rmj': 'chokinshimasu'},
          ]
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '家族のために働きます。',
          'rmj': 'Kazoku no tame ni hatarakimasu.',
          'audio_text': '家族のために働きます。',
          'words': ['gia đình', 'vì', 'làm việc', 'sức khỏe', 'để'],
          'answer': 'làm việc vì gia đình',
        },
      ];
    }

    List<Map<String, dynamic>> _getN3Bai9LuyenTap2Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền từ đúng (Để MUA nhà thì tiết kiệm): \n家を ( ... ) ために、貯金します。',
          'options': ['買う', '買える', '買って', '買いたい'],
          'answer': '買う' // ために đi với V-ý chí
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '健康のために、野菜を食べます。',
          'words': ['健康', 'の', 'ために', '野菜', 'を', '食べます', 'ように'],
          'answer': '健康 の ために 野菜 を 食べます',
        },
      ];
    }

    List<Map<String, dynamic>> _getN3Bai9LuyenTap3Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền từ đúng (Để CÓ THỂ ĐỌC được báo Nhật): \n日本の新聞が ( ... ) ように、勉強します。',
          'options': ['読む', '読める', '読んで', '読み'],
          'answer': '読める' // ように đi với V-khả năng
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '試験に合格するように、頑張ります。',
          'words': ['試験', 'に', '合格する', 'ように', '頑張ります', 'ために'],
          'answer': '試験 に 合格する ように 頑張ります',
        },
      ];
    }

    List<Map<String, dynamic>> _getN3Bai9LuyenNoiData() {
      return [
        {'type': LessonType.speaking, 'jp': '車を買うために貯金します。', 'answer': 'くるまをかうためにちょきんします'},
        {'type': LessonType.speaking, 'jp': '家族のために働きます。', 'answer': 'かぞくのためにはたらきます'},
        {'type': LessonType.speaking, 'jp': '日本語が話せるように勉強します。', 'answer': 'にほんごがはなせるようにべんきょうします'},
      ];
    }

    List<Map<String, dynamic>> _getN3Bai9LuyenVietData() {
      return [
        {'type': LessonType.kanjiDraw, 'kanji_word': '貯金', 'kanji_target': '貯', 'meaning': 'Trữ (Tích trữ)', 'rmj': 'cho / ta(meru)'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '健康', 'kanji_target': '健', 'meaning': 'Kiện (Tráng kiện / Khỏe mạnh)', 'rmj': 'ken / suko(yaka)'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '健康', 'kanji_target': '康', 'meaning': 'Khang (An khang)', 'rmj': 'kou'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '目的', 'kanji_target': '的', 'meaning': 'Đích (Mục đích)', 'rmj': 'teki / mato'},
      ];
    }
  List<Map<String, dynamic>> _getN3Bai10LyThuyetData() {
      return [
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': '変わります', 'hiragana': 'かわります', 'romaji': 'kawarimasu', 'meaning': 'Thay đổi'},
            {'kanji': '慣れます', 'hiragana': 'なれます', 'romaji': 'naremasu', 'meaning': 'Quen với'},
            {'kanji': '増えます', 'hiragana': 'ふえます', 'romaji': 'fuemasu', 'meaning': 'Tăng lên'},
            {'kanji': '減ります', 'hiragana': 'へります', 'romaji': 'herimasu', 'meaning': 'Giảm đi'},
            {'kanji': 'だんだん', 'hiragana': 'だんだん', 'romaji': 'dandan', 'meaning': 'Dần dần'},
            {'kanji': 'どんどん', 'hiragana': 'どんどん', 'romaji': 'dondon', 'meaning': 'Nhanh chóng / Vù vù'},
          ]
        },
        {
          'type': LessonType.flashCard, 'kanji': '慣れます', 'hiragana': 'なれます', 'romaji': 'naremasu', 'meaning': 'Quen với',
          'example_img': 'assets/images/example_naremasu.png',
          'example_jp': '日本の生活に慣れました。', 'example_rmj': 'Nihon no seikatsu ni naremashita.', 'example_vn': 'Tôi đã quen với cuộc sống ở Nhật.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '増えます', 'hiragana': 'ふえます', 'romaji': 'fuemasu', 'meaning': 'Tăng lên',
          'example_img': 'assets/images/example_fuemasu.png',
          'example_jp': '外国人が増えています。', 'example_rmj': 'Gaikokujin ga fueteimasu.', 'example_vn': 'Người nước ngoài đang tăng lên.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '減ります', 'hiragana': 'へります', 'romaji': 'herimasu', 'options': ['thay đổi', 'quen với', 'tăng lên', 'giảm đi'], 'answer': 'giảm đi'},
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'V(khả năng/ru) + ようになる', 'meaning': 'Trở nên (thay đổi trạng thái/khả năng)'},
            {'title': 'V(て) + いく / くる', 'meaning': 'Sự biến đổi (Tiếp diễn ra xa / Tiến lại gần)'},
          ]
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'SỰ THAY ĐỔI TRẠNG THÁI',
          'formula': 'Động từ (thể khả năng / từ điển) + ようになる',
          'meaning': 'Trở nên có thể... / Bắt đầu thói quen...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜ようになる',
          'notes': [
            'Biểu thị sự biến đổi từ trạng thái KHÔNG THỂ sang CÓ THỂ.',
            'Hoặc biểu thị một thói quen mới được hình thành.',
            'Ví dụ: 日本語が話せるようになりました (Đã trở nên CÓ THỂ nói tiếng Nhật).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'SỰ THAY ĐỔI',
          'img': 'assets/images/example_youninaru.png',
          'jp': '刺身が食べられるようになりました。',
          'rmj': 'Sashimi ga taberareru you ni narimashita.',
          'vn': 'Tôi ĐÃ CÓ THỂ ăn được Sashimi (trước đây không ăn được).'
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'QUÁ TRÌNH BIẾN ĐỔI',
          'formula': 'V(て) + いきます\nV(て) + きます',
          'meaning': 'Sẽ tiếp tục... / Đã... cho đến nay'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG ていく / てくる',
          'notes': [
            'ていく (Đi ra xa): Biểu thị sự thay đổi sẽ TIẾP TỤC DIỄN RA từ hiện tại tới tương lai.',
            'てくる (Đến gần): Biểu thị sự thay đổi đã BẮT ĐẦU TỪ QUÁ KHỨ và tiếp diễn đến hiện tại.'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'QUÁ TRÌNH',
          'img': 'assets/images/example_teiku.png',
          'jp': 'これからも、日本語を勉強していきます。',
          'rmj': 'Korekara mo, nihongo o benkyou shite ikimasu.',
          'vn': 'Từ nay về sau, tôi SẼ TIẾP TỤC học tiếng Nhật.'
        },
        {
          'type': LessonType.vocabSummary,
          'words': [
            {'kanji': '変わる', 'romaji': 'kawaru', 'meaning': 'thay đổi'},
            {'kanji': '慣れる', 'romaji': 'nareru', 'meaning': 'quen với'},
            {'kanji': '増える', 'romaji': 'fueru', 'meaning': 'tăng'},
            {'kanji': 'ようになる', 'romaji': 'you ni naru', 'meaning': 'trở nên có thể'},
            {'kanji': 'ていく', 'romaji': 'te iku', 'meaning': 'sẽ tiếp tục'},
          ]
        }
      ];
    }

    List<Map<String, dynamic>> _getN3Bai10LuyenTap1Data() {
      return [
        {
          'type': LessonType.imageQuiz,
          'question': 'Tăng lên.',
          'answerIndex': 0,
          'options': [
            {'img': 'assets/images/example_fuemasu.png', 'jp': '増えます', 'rmj': 'fuemasu'},
            {'img': 'assets/images/example_herimasu.png', 'jp': '減ります', 'rmj': 'herimasu'},
            {'img': 'assets/images/example_kawarimasu.png', 'jp': '変わります', 'rmj': 'kawarimasu'},
            {'img': 'assets/images/example_naremasu.png', 'jp': '慣れます', 'rmj': 'naremasu'},
          ]
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '日本の生活に慣れました。',
          'rmj': 'Nihon no seikatsu ni naremashita.',
          'audio_text': '日本の生活に慣れました。',
          'words': ['cuộc sống', 'Nhật Bản', 'quen với', 'thay đổi', 'tăng lên'],
          'answer': 'quen với cuộc sống Nhật Bản', // Nghĩa tương đương
        },
      ];
    }

    List<Map<String, dynamic>> _getN3Bai10LuyenTap2Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền từ đúng (Đã CÓ THỂ nói được tiếng Nhật): \n日本語が話せる ( ... ) なりました。',
          'options': ['こと', 'よう', 'ため', 'はず'],
          'answer': 'よう'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '刺身が食べられるようになりました。',
          'words': ['刺身', 'が', '食べられる', 'ように', 'なりました', 'こと'],
          'answer': '刺身 が 食べられる ように なりました',
        },
      ];
    }

    List<Map<String, dynamic>> _getN3Bai10LuyenTap3Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Từ nay về sau, tôi sẽ tiếp tục cố gắng. Chọn cấu trúc đúng:',
          'options': ['頑張ってきます', '頑張っていきます', '頑張るようになります'],
          'answer': '頑張っていきます' // Hướng tới tương lai dùng ていく
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': 'だんだん暖かくなってきました。', // Thay đổi từ quá khứ đến hiện tại
          'words': ['だんだん', '暖かく', 'なって', 'きました', 'いきます'],
          'answer': 'だんだん 暖かく なって きました',
        },
      ];
    }

    List<Map<String, dynamic>> _getN3Bai10LuyenNoiData() {
      return [
        {'type': LessonType.speaking, 'jp': '生活に慣れました。', 'answer': 'せいかつになれました'},
        {'type': LessonType.speaking, 'jp': '日本語が話せるようになりました。', 'answer': 'にほんごがはなせるようになりました'},
        {'type': LessonType.speaking, 'jp': 'これからも頑張っていきます。', 'answer': 'これからもがんばっていきます'},
      ];
    }

    List<Map<String, dynamic>> _getN3Bai10LuyenVietData() {
      return [
        {'type': LessonType.kanjiDraw, 'kanji_word': '変わります', 'kanji_target': '変', 'meaning': 'Biến (Biến đổi / Kỳ lạ)', 'rmj': 'ka(waru) / hen'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '慣れます', 'kanji_target': '慣', 'meaning': 'Quán (Tập quán / Quen)', 'rmj': 'na(reru) / kan'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '増えます', 'kanji_target': '増', 'meaning': 'Tăng (Tăng lên)', 'rmj': 'fu(eru) / zou'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '減ります', 'kanji_target': '減', 'meaning': 'Giảm (Giảm đi)', 'rmj': 'he(ru) / gen'},
      ];
    }
  // ==========================================
    // LÝ THUYẾT (N2 - BÀI 1)
    // Chủ đề: Nhân dịp / Khi (Cấu trúc trang trọng)
    // ==========================================
    List<Map<String, dynamic>> _getN2Bai1LyThuyetData() {
      return [
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': '契約', 'hiragana': 'けいやく', 'romaji': 'keiyaku', 'meaning': 'Hợp đồng'},
            {'kanji': '開店', 'hiragana': 'かいてん', 'romaji': 'kaiten', 'meaning': 'Mở cửa hàng / Khai trương'},
            {'kanji': '出発', 'hiragana': 'しゅっぱつ', 'romaji': 'shuppatsu', 'meaning': 'Xuất phát'},
            {'kanji': '際', 'hiragana': 'さい', 'romaji': 'sai', 'meaning': 'Dịp / Khi (Trang trọng của 時)'},
            {'kanji': '挨拶', 'hiragana': 'あいさつ', 'romaji': 'aisatsu', 'meaning': 'Chào hỏi / Lời phát biểu'},
          ]
        },
        {
          'type': LessonType.flashCard, 'kanji': '契約', 'hiragana': 'けいやく', 'romaji': 'keiyaku', 'meaning': 'Hợp đồng',
          'example_img': 'assets/images/example_keiyaku.png',
          'example_jp': '契約にサインします。', 'example_rmj': 'Keiyaku ni sain shimasu.', 'example_vn': 'Ký vào hợp đồng.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '開店', 'hiragana': 'かいてん', 'romaji': 'kaiten', 'meaning': 'Khai trương',
          'example_img': 'assets/images/example_kaiten.png',
          'example_jp': '新しい店が開店します。', 'example_rmj': 'Atarashii mise ga kaiten shimasu.', 'example_vn': 'Cửa hàng mới khai trương.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '出発', 'hiragana': 'しゅっぱつ', 'romaji': 'shuppatsu', 'options': ['hợp đồng', 'chào hỏi', 'xuất phát', 'dịp'], 'answer': 'xuất phát'},
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'N / V(ru) + に際して', 'meaning': 'Khi / Nhân dịp (Trang trọng)'},
            {'title': 'N / V(ru) + にあたって', 'meaning': 'Nhân dịp (Hướng tới điều tích cực)'},
          ]
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'KHI / NHÂN DỊP',
          'formula': 'Danh từ / Động từ (thể từ điển) + に際して (ni saishite)',
          'meaning': 'Khi tiến hành... / Nhân dịp...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜に際して',
          'notes': [
            'Đây là cách nói rất trang trọng của 「〜するとき」 (Khi làm gì đó).',
            'Thường dùng trong các văn bản thông báo, hướng dẫn, hoặc lời phát biểu chính thức.',
            'Đi kèm với các từ chỉ sự kiện lớn: Hợp đồng, Kết hôn, Chuyển việc...'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ に際して',
          'img': 'assets/images/example_saishite.png',
          'jp': '契約に際して、説明をお読みください。',
          'rmj': 'Keiyaku ni saishite, setsumei o oyomi kudasai.',
          'vn': 'KHI ký hợp đồng, xin vui lòng đọc phần giải thích.'
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'NHÂN DỊP (TÍCH CỰC)',
          'formula': 'Danh từ / Động từ (thể từ điển) + にあたって (ni atatte)',
          'meaning': 'Nhân dịp... / Trước khi...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜にあたって',
          'notes': [
            'Giống với に際して, nhưng にあたって THƯỜNG mang ý nghĩa tích cực, hướng tới một sự bắt đầu mới.',
            'Ví dụ: Khai trương, Mở hội nghị, Bắt đầu dự án mới.',
            'Không dùng cho những việc tiêu cực như: Nhập viện, Phá sản...'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ にあたって',
          'img': 'assets/images/example_atatte.png',
          'jp': '開店にあたって、ご挨拶を申し上げます。',
          'rmj': 'Kaiten ni atatte, go-aisatsu o moushiagemasu.',
          'vn': 'NHÂN DỊP khai trương, tôi xin có đôi lời phát biểu.'
        },
        {
          'type': LessonType.vocabSummary,
          'words': [
            {'kanji': '契約', 'romaji': 'keiyaku', 'meaning': 'hợp đồng'},
            {'kanji': '開店', 'romaji': 'kaiten', 'meaning': 'khai trương'},
            {'kanji': '挨拶', 'romaji': 'aisatsu', 'meaning': 'chào hỏi'},
            {'kanji': 'に際して', 'romaji': 'ni saishite', 'meaning': 'khi / nhân dịp'},
            {'kanji': 'にあたって', 'romaji': 'ni atatte', 'meaning': 'nhân dịp (tích cực)'},
          ]
        }
      ];
    }

    List<Map<String, dynamic>> _getN2Bai1LuyenTap1Data() {
      return [
        {
          'type': LessonType.imageQuiz,
          'question': 'Hợp đồng.',
          'answerIndex': 3,
          'options': [
            {'img': 'assets/images/example_kaiten.png', 'jp': '開店', 'rmj': 'kaiten'},
            {'img': 'assets/images/example_shuppatsu.png', 'jp': '出発', 'rmj': 'shuppatsu'},
            {'img': 'assets/images/example_aisatsu.png', 'jp': '挨拶', 'rmj': 'aisatsu'},
            {'img': 'assets/images/example_keiyaku.png', 'jp': '契約', 'rmj': 'keiyaku'},
          ]
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '新しい店が開店します。',
          'rmj': 'Atarashii mise ga kaiten shimasu.',
          'audio_text': '新しい店が開店します。',
          'words': ['cửa hàng', 'mới', 'khai trương', 'hợp đồng', 'khi'],
          'answer': 'cửa hàng mới khai trương',
        },
      ];
    }

    List<Map<String, dynamic>> _getN2Bai1LuyenTap2Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Cấu trúc nào mang ý nghĩa tích cực, dùng cho sự kiện bắt đầu (Khai trương, Xây dựng...)?',
          'options': ['に際して', 'にあたって', 'において', 'によって'],
          'answer': 'にあたって'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '契約に際して、説明をお読みください。',
          'words': ['契約', 'に', '際して', '説明', 'を', 'お読みください', 'あたって'],
          'answer': '契約 に 際して 説明 を お読みください',
        },
      ];
    }

    List<Map<String, dynamic>> _getN2Bai1LuyenTap3Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền từ đúng (Nhân dịp xuất phát): \n出発 ( ... )、準備をします。',
          'options': ['にあたって', 'のあたって', 'があたって', 'をあたって'],
          'answer': 'にあたって' // Đi trực tiếp với Danh từ chỉ hành động
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '開店にあたって、ご挨拶をします。',
          'words': ['開店', 'に', 'あたって', 'ご挨拶', 'を', 'します', '際して'],
          'answer': '開店 に あたって ご挨拶 を します',
        },
      ];
    }

    List<Map<String, dynamic>> _getN2Bai1LuyenNoiData() {
      return [
        {'type': LessonType.speaking, 'jp': '契約にサインします。', 'answer': 'けいやくにさいんします'},
        {'type': LessonType.speaking, 'jp': '契約に際して、説明を読みます。', 'answer': 'けいやくにさいしてせつめいをよみます'},
        {'type': LessonType.speaking, 'jp': '開店にあたって、挨拶をします。', 'answer': 'かいてんにあたってあいさつをします'},
      ];
    }

    List<Map<String, dynamic>> _getN2Bai1LuyenVietData() {
      return [
        {'type': LessonType.kanjiDraw, 'kanji_word': '契約', 'kanji_target': '契', 'meaning': 'Khế (Khế ước / Hợp đồng)', 'rmj': 'kei / chigi(ru)'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '開店', 'kanji_target': '開', 'meaning': 'Khai (Mở ra / Khai trương)', 'rmj': 'kai / a(ku)'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '出発', 'kanji_target': '発', 'meaning': 'Phát (Xuất phát / Phát kiến)', 'rmj': 'hatsu'},
      ];
    }
  List<Map<String, dynamic>> _getN2Bai2LyThuyetData() {
      return [
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': '優勝します', 'hiragana': 'ゆうしょうします', 'romaji': 'yuushoushimasu', 'meaning': 'Vô địch'},
            {'kanji': '信じます', 'hiragana': 'しんじます', 'romaji': 'shinjimasu', 'meaning': 'Tin tưởng'},
            {'kanji': '犯人', 'hiragana': 'はんにん', 'romaji': 'hannin', 'meaning': 'Thủ phạm / Tội phạm'},
            {'kanji': '嘘', 'hiragana': 'うそ', 'romaji': 'uso', 'meaning': 'Nói dối'},
            {'kanji': '真面目[な]', 'hiragana': 'まじめ[な]', 'romaji': 'majime [na]', 'meaning': 'Nghiêm túc'},
          ]
        },
        {
          'type': LessonType.flashCard, 'kanji': '優勝します', 'hiragana': 'ゆうしょうします', 'romaji': 'yuushoushimasu', 'meaning': 'Vô địch',
          'example_img': 'assets/images/example_yuushou.png',
          'example_jp': '試合に優勝しました。', 'example_rmj': 'Shiai ni yuushoushimashita.', 'example_vn': 'Đã vô địch trận đấu.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '犯人', 'hiragana': 'はんにん', 'romaji': 'hannin', 'meaning': 'Thủ phạm',
          'example_img': 'assets/images/example_hannin.png',
          'example_jp': '彼が犯人です。', 'example_rmj': 'Kare ga hannin desu.', 'example_vn': 'Hắn ta là thủ phạm.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '信じます', 'hiragana': 'しんじます', 'romaji': 'shinjimasu', 'options': ['nói dối', 'nghiêm túc', 'tin tưởng', 'vô địch'], 'answer': 'tin tưởng'},
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'Thể thông thường + わけがない', 'meaning': 'Tuyệt đối không / Không thể nào có chuyện...'},
            {'title': 'Thể thông thường + はずがない', 'meaning': 'Chắc chắn không...'},
          ]
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'BÁC BỎ MẠNH MẼ',
          'formula': 'Thể thông thường + わけがない (wake ga nai)',
          'meaning': 'Làm gì có chuyện / Tuyệt đối không...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜わけがない',
          'notes': [
            'Dùng để phủ định hoàn toàn một sự việc, thể hiện sự nghi ngờ hoặc không thể tin được của người nói.',
            'Tính từ [な] giữ nguyên [な], Danh từ thêm [の].',
            'Ví dụ: 負けるわけがない (Không thể nào có chuyện thua được).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ わけがない',
          'img': 'assets/images/example_wakeganai.png',
          'jp': '彼が犯人のわけがない。',
          'rmj': 'Kare ga hannin no wake ga nai.',
          'vn': 'Không thể nào có chuyện anh ấy là thủ phạm được.'
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'PHÁN ĐOÁN PHỦ ĐỊNH',
          'formula': 'Thể thông thường + はずがない (hazu ga nai)',
          'meaning': 'Chắc chắn không...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜はずがない',
          'notes': [
            'Dựa trên một căn cứ logic để khẳng định rằng một việc CHẮC CHẮN KHÔNG xảy ra.',
            'Ý nghĩa và cách chia tương đương với わけがない, có thể dùng thay thế cho nhau trong hầu hết trường hợp.'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ はずがない',
          'img': 'assets/images/example_hazuganai.png',
          'jp': 'あんな弱いチームが、優勝するはずがない。',
          'rmj': 'Anna yowai chiimu ga, yuushou suru hazu ga nai.',
          'vn': 'Một đội yếu như thế, chắc chắn không thể vô địch được.'
        },
        {
          'type': LessonType.vocabSummary,
          'words': [
            {'kanji': '優勝する', 'romaji': 'yuushousuru', 'meaning': 'vô địch'},
            {'kanji': '犯人', 'romaji': 'hannin', 'meaning': 'thủ phạm'},
            {'kanji': '信じる', 'romaji': 'shinjiru', 'meaning': 'tin tưởng'},
            {'kanji': 'わけがない', 'romaji': 'wake ga nai', 'meaning': 'không thể nào có chuyện'},
            {'kanji': 'はずがない', 'romaji': 'hazu ga nai', 'meaning': 'chắc chắn không'},
          ]
        }
      ];
    }

    List<Map<String, dynamic>> _getN2Bai2LuyenTap1Data() {
      return [
        {
          'type': LessonType.imageQuiz,
          'question': 'Thủ phạm.',
          'answerIndex': 2,
          'options': [
            {'img': 'assets/images/example_yuushou.png', 'jp': '優勝します', 'rmj': 'yuushoushimasu'},
            {'img': 'assets/images/example_uso.png', 'jp': '嘘', 'rmj': 'uso'},
            {'img': 'assets/images/example_hannin.png', 'jp': '犯人', 'rmj': 'hannin'},
            {'img': 'assets/images/example_shinjimasu.png', 'jp': '信じます', 'rmj': 'shinjimasu'},
          ]
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '試合に優勝しました。',
          'rmj': 'Shiai ni yuushoushimashita.',
          'audio_text': '試合に優勝しました。',
          'words': ['trận đấu', 'trong', 'vô địch', 'tin tưởng', 'thủ phạm'],
          'answer': 'vô địch trong trận đấu',
        },
      ];
    }

    List<Map<String, dynamic>> _getN2Bai2LuyenTap2Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền từ đúng (Không thể nào có chuyện anh ấy là thủ phạm): \n彼が犯人 ( ... ) わけがない。',
          'options': ['の', 'な', 'だ', 'で'],
          'answer': 'の' // Danh từ + の + わけがない
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '彼が犯人のわけがない。',
          'words': ['彼', 'が', '犯人', 'の', 'わけがない', 'はずがない'],
          'answer': '彼 が 犯人 の わけがない',
        },
      ];
    }

    List<Map<String, dynamic>> _getN2Bai2LuyenTap3Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Cấu trúc nào mang ý nghĩa "Chắc chắn KHÔNG"?',
          'options': ['はずです', 'はずがない', 'べきです', 'かもしれない'],
          'answer': 'はずがない'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': 'あのチームが優勝するはずがない。',
          'words': ['あの', 'チーム', 'が', '優勝する', 'はずがない', 'わけがない'],
          'answer': 'あの チーム が 優勝する はずがない',
        },
      ];
    }

    List<Map<String, dynamic>> _getN2Bai2LuyenNoiData() {
      return [
        {'type': LessonType.speaking, 'jp': '彼が犯人です。', 'answer': 'かれがはんにんです'},
        {'type': LessonType.speaking, 'jp': '彼が犯人のわけがない。', 'answer': 'かれがはんにんのわけがない'},
        {'type': LessonType.speaking, 'jp': 'あのチームが優勝するはずがない。', 'answer': 'あのちーむがゆうしょうするはずがない'},
      ];
    }

    List<Map<String, dynamic>> _getN2Bai2LuyenVietData() {
      return [
        {'type': LessonType.kanjiDraw, 'kanji_word': '優勝', 'kanji_target': '優', 'meaning': 'Ưu (Xuất sắc / Hiền lành)', 'rmj': 'yuu / sugu(reru)'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '犯人', 'kanji_target': '犯', 'meaning': 'Phạm (Tội phạm / Vi phạm)', 'rmj': 'han / oka(su)'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '信じます', 'kanji_target': '信', 'meaning': 'Tín (Tin tưởng)', 'rmj': 'shin'},
      ];
    }
  // ==========================================
    // LÝ THUYẾT (N2 - BÀI 3)
    // Chủ đề: Nhượng bộ & Đối lập (にもかかわらず / つつ)
    // ==========================================
    List<Map<String, dynamic>> _getN2Bai3LyThuyetData() {
      return [
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': '悪天候', 'hiragana': 'あくてんこう', 'romaji': 'akutenkou', 'meaning': 'Thời tiết xấu'},
            {'kanji': '努力します', 'hiragana': 'どりょくします', 'romaji': 'doryokushimasu', 'meaning': 'Nỗ lực'},
            {'kanji': '危険', 'hiragana': 'きけん', 'romaji': 'kiken', 'meaning': 'Nguy hiểm'},
            {'kanji': '知ります', 'hiragana': 'しります', 'romaji': 'shirimasu', 'meaning': 'Biết'},
            {'kanji': '無理', 'hiragana': 'むり', 'romaji': 'muri', 'meaning': 'Quá sức / Vô lý'},
          ]
        },
        {
          'type': LessonType.flashCard, 'kanji': '悪天候', 'hiragana': 'あくてんこう', 'romaji': 'akutenkou', 'meaning': 'Thời tiết xấu',
          'example_img': 'assets/images/example_akutenkou.png',
          'example_jp': '悪天候のせいで...。', 'example_rmj': 'Akutenkou no sei de...', 'example_vn': 'Tại vì thời tiết xấu...'
        },
        {
          'type': LessonType.flashCard, 'kanji': '努力します', 'hiragana': 'どりょくします', 'romaji': 'doryokushimasu', 'meaning': 'Nỗ lực',
          'example_img': 'assets/images/example_doryoku.png',
          'example_jp': '毎日努力します。', 'example_rmj': 'Mainichi doryokushimasu.', 'example_vn': 'Nỗ lực mỗi ngày.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '危険', 'hiragana': 'きけん', 'romaji': 'kiken', 'options': ['biết', 'nỗ lực', 'nguy hiểm', 'quá sức'], 'answer': 'nguy hiểm'},
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'V/A/N + にもかかわらず', 'meaning': 'Bất chấp / Mặc dù... (Trái với dự đoán)'},
            {'title': 'V(bỏ ます) + つつ(も)', 'meaning': 'Mặc dù (biết là vậy) nhưng vẫn...'},
          ]
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'BẤT CHẤP / MẶC DÙ',
          'formula': 'V/A/N (thể thông thường) + にもかかわらず',
          'meaning': 'Bất chấp / Mặc dù...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG にもかかわらず',
          'notes': [
            'Dùng để diễn tả một hành động xảy ra bất chấp một điều kiện bất lợi.',
            'Tính từ (な) và Danh từ có thể thêm (である) trước にもかかわらず.',
            'Mang sắc thái bất ngờ, ngạc nhiên hoặc trách móc.'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ にもかかわらず',
          'img': 'assets/images/example_nimokakawarazu.png',
          'jp': '悪天候にもかかわらず、試合が行われた。',
          'rmj': 'Akutenkou ni mo kakawarazu, shiai ga okonawareta.',
          'vn': 'Bất chấp thời tiết xấu, trận đấu vẫn được diễn ra.'
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'HÀNH ĐỘNG TRÁI LƯƠNG TÂM',
          'formula': 'Động từ (bỏ ます) + つつ（も）',
          'meaning': 'Mặc dù biết là vậy nhưng...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG つつ（も）',
          'notes': [
            'Chủ yếu đi kèm với các động từ liên quan đến nhận thức: 知る (biết), 思う (nghĩ), 分かる (hiểu).',
            'Diễn tả sự hối hận: Mặc dù trong lòng biết là không tốt nhưng hành động lại làm ngược lại.'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ つつ',
          'img': 'assets/images/example_tsutsu.png',
          'jp': '危険だと知りつつ、山に登った。',
          'rmj': 'Kiken da to shiritsutsu, yama ni nobotta.',
          'vn': 'Mặc dù BIẾT là nguy hiểm nhưng vẫn leo núi.'
        },
        {
          'type': LessonType.vocabSummary,
          'words': [
            {'kanji': '悪天候', 'romaji': 'akutenkou', 'meaning': 'thời tiết xấu'},
            {'kanji': '努力', 'romaji': 'doryoku', 'meaning': 'nỗ lực'},
            {'kanji': '危険', 'romaji': 'kiken', 'meaning': 'nguy hiểm'},
            {'kanji': 'にもかかわらず', 'romaji': 'ni mo kakawarazu', 'meaning': 'bất chấp'},
            {'kanji': 'つつ', 'romaji': 'tsutsu', 'meaning': 'mặc dù biết'},
          ]
        }
      ];
    }

    List<Map<String, dynamic>> _getN2Bai3LuyenTap1Data() {
      return [
        {
          'type': LessonType.imageQuiz,
          'question': 'Thời tiết xấu.',
          'answerIndex': 0,
          'options': [
            {'img': 'assets/images/example_akutenkou.png', 'jp': '悪天候', 'rmj': 'akutenkou'},
            {'img': 'assets/images/example_kiken.png', 'jp': '危険', 'rmj': 'kiken'},
            {'img': 'assets/images/example_doryoku.png', 'jp': '努力', 'rmj': 'doryoku'},
            {'img': 'assets/images/example_muri.png', 'jp': '無理', 'rmj': 'muri'},
          ]
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '毎日努力します。',
          'rmj': 'Mainichi doryokushimasu.',
          'audio_text': '毎日努力します。',
          'words': ['mỗi ngày', 'nỗ lực', 'thời tiết', 'nguy hiểm', 'quá sức'],
          'answer': 'nỗ lực mỗi ngày',
        },
      ];
    }

    List<Map<String, dynamic>> _getN2Bai3LuyenTap2Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền từ (Bất chấp thời tiết xấu, vẫn ra ngoài): \n悪天候 ( ... )、出かけました。',
          'options': ['にあたって', 'にもかかわらず', 'のせいで', 'おかげで'],
          'answer': 'にもかかわらず'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '雨にもかかわらず、試合がありました。',
          'words': ['雨', 'に', 'もかかわらず', '試合', 'が', 'ありました', 'つつ'],
          'answer': '雨 に もかかわらず 試合 が ありました',
        },
      ];
    }

    List<Map<String, dynamic>> _getN2Bai3LuyenTap3Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Cách chia của つつ (Mặc dù biết) là gì?',
          'options': ['V(て) + つつ', 'V(た) + つつ', 'V(bỏ ます) + つつ', 'V(る) + つつ'],
          'answer': 'V(bỏ ます) + つつ'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '無理だと知りつつ、頑張りました。',
          'words': ['無理', 'だ', 'と', '知り', 'つつ', '頑張りました', '知る'],
          'answer': '無理 だ と 知り つつ 頑張りました',
        },
      ];
    }

    List<Map<String, dynamic>> _getN2Bai3LuyenNoiData() {
      return [
        {'type': LessonType.speaking, 'jp': '悪天候にもかかわらず。', 'answer': 'あくてんこうにもかかわらず'},
        {'type': LessonType.speaking, 'jp': '雨にもかかわらず出かけました。', 'answer': 'あめにもかかわらずでかけました'},
        {'type': LessonType.speaking, 'jp': '悪いと知りつつ、嘘をついた。', 'answer': 'わるいとしりつつうそをついた'},
      ];
    }

    List<Map<String, dynamic>> _getN2Bai3LuyenVietData() {
      return [
        {'type': LessonType.kanjiDraw, 'kanji_word': '悪天候', 'kanji_target': '悪', 'meaning': 'Ác (Xấu / Tồi tệ)', 'rmj': 'aku / waru(i)'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '努力', 'kanji_target': '努', 'meaning': 'Nỗ (Nỗ lực)', 'rmj': 'do / tsuto(meru)'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '危険', 'kanji_target': '危', 'meaning': 'Nguy (Nguy hiểm)', 'rmj': 'ki / abu(nai)'},
      ];
    }
  List<Map<String, dynamic>> _getN2Bai4LyThuyetData() {
      return [
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': '泥', 'hiragana': 'どろ', 'romaji': 'doro', 'meaning': 'Bùn'},
            {'kanji': '傷', 'hiragana': 'きず', 'romaji': 'kizu', 'meaning': 'Vết thương / Vết xước'},
            {'kanji': '間違い', 'hiragana': 'まちがい', 'romaji': 'machigai', 'meaning': 'Lỗi sai'},
            {'kanji': '遊びます', 'hiragana': 'あそびます', 'romaji': 'asobimasu', 'meaning': 'Chơi đùa'},
            {'kanji': '文句', 'hiragana': 'もんく', 'romaji': 'monku', 'meaning': 'Phàn nàn / Than vãn'},
          ]
        },
        {
          'type': LessonType.flashCard, 'kanji': '泥', 'hiragana': 'どろ', 'romaji': 'doro', 'meaning': 'Bùn',
          'example_img': 'assets/images/example_doro.png',
          'example_jp': '服が泥だらけです。', 'example_rmj': 'Fuku ga dorodarake desu.', 'example_vn': 'Quần áo đầy bùn.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '間違い', 'hiragana': 'まちがい', 'romaji': 'machigai', 'meaning': 'Lỗi sai',
          'example_img': 'assets/images/example_machigai.png',
          'example_jp': '間違いが多いです。', 'example_rmj': 'Machigai ga ooi desu.', 'example_vn': 'Có nhiều lỗi sai.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '傷', 'hiragana': 'きず', 'romaji': 'kizu', 'options': ['bùn', 'vết thương', 'lỗi sai', 'chơi đùa'], 'answer': 'vết thương'},
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'Danh từ + だらけ', 'meaning': 'Đầy / Toàn là (Mang nghĩa tiêu cực, bẩn)'},
            {'title': 'V(て) / N + ばかり', 'meaning': 'Toàn là / Chỉ mãi làm gì đó'},
          ]
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'ĐẦY (TIÊU CỰC)',
          'formula': 'Danh từ + だらけ (darake)',
          'meaning': 'Đầy / Toàn là...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜だらけ',
          'notes': [
            'Dùng để miêu tả một bề mặt bị bao phủ bởi một thứ gì đó, thường là những thứ không sạch sẽ, tiêu cực.',
            'Các từ hay đi kèm: 泥 (bùn), 血 (máu), 埃 (bụi), 傷 (vết thương), 間違い (lỗi sai).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ だらけ',
          'img': 'assets/images/example_darake.png',
          'jp': 'このテストは間違いだらけだ。',
          'rmj': 'Kono tesuto wa machigai darake da.',
          'vn': 'Bài kiểm tra này đầy lỗi sai.'
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'TOÀN LÀ / MÃI LÀM GÌ',
          'formula': 'Danh từ + ばかり\nĐộng từ (て) + ばかりいる',
          'meaning': 'Chỉ toàn là / Suốt ngày...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜ばかり',
          'notes': [
            'Biểu thị việc gì đó lặp đi lặp lại rất nhiều lần, hoặc chỉ có duy nhất một trạng thái đó.',
            'Thường mang ý nghĩa phàn nàn, khó chịu (VD: Suốt ngày chơi game, Chỉ toàn ăn thịt).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ ばかり',
          'img': 'assets/images/example_bakari.png',
          'jp': '弟は遊んでばかりいる。',
          'rmj': 'Otouto wa asonde bakari iru.',
          'vn': 'Em trai tôi suốt ngày chỉ toàn chơi.'
        },
        {
          'type': LessonType.vocabSummary,
          'words': [
            {'kanji': '泥だらけ', 'romaji': 'doro darake', 'meaning': 'đầy bùn'},
            {'kanji': '傷だらけ', 'romaji': 'kizu darake', 'meaning': 'đầy vết thương'},
            {'kanji': '間違いだらけ', 'romaji': 'machigai darake', 'meaning': 'đầy lỗi sai'},
            {'kanji': '遊んでばかり', 'romaji': 'asonde bakari', 'meaning': 'toàn chơi'},
            {'kanji': '文句ばかり', 'romaji': 'monku bakari', 'meaning': 'toàn phàn nàn'},
          ]
        }
      ];
    }

    List<Map<String, dynamic>> _getN2Bai4LuyenTap1Data() {
      return [
        {
          'type': LessonType.imageQuiz,
          'question': 'Lỗi sai.',
          'answerIndex': 2,
          'options': [
            {'img': 'assets/images/example_doro.png', 'jp': '泥', 'rmj': 'doro'},
            {'img': 'assets/images/example_kizu.png', 'jp': '傷', 'rmj': 'kizu'},
            {'img': 'assets/images/example_machigai.png', 'jp': '間違い', 'rmj': 'machigai'},
            {'img': 'assets/images/example_monku.png', 'jp': '文句', 'rmj': 'monku'},
          ]
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '文句を言います。',
          'rmj': 'Monku o iimasu.',
          'audio_text': '文句を言います。',
          'words': ['nói', 'phàn nàn', 'bùn', 'toàn là', 'chơi'],
          'answer': 'nói phàn nàn',
        },
      ];
    }

    List<Map<String, dynamic>> _getN2Bai4LuyenTap2Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Cấu trúc だらけ (Đầy) thường KHÔNG dùng với từ nào sau đây?',
          'options': ['泥 (Bùn)', '間違い (Lỗi sai)', 'お金 (Tiền)', '傷 (Vết thương)'],
          'answer': 'お金 (Tiền)' // Tiền là điều tốt, không dùng darake
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': 'このテストは間違いだらけだ。',
          'words': ['この', 'テスト', 'は', '間違い', 'だらけ', 'だ', 'ばかり'],
          'answer': 'この テスト は 間違い だらけ だ',
        },
      ];
    }

    List<Map<String, dynamic>> _getN2Bai4LuyenTap3Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Suốt ngày chỉ toàn ăn. Chọn cấu trúc đúng:',
          'options': ['食べてだらけいる', '食べるばかりいる', '食べてばかりいる', '食べばかりいる'],
          'answer': '食べてばかりいる'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '弟は遊んでばかりいる。',
          'words': ['弟', 'は', '遊んで', 'ばかり', 'いる', 'だらけ'],
          'answer': '弟 は 遊んで ばかり いる',
        },
      ];
    }

    List<Map<String, dynamic>> _getN2Bai4LuyenNoiData() {
      return [
        {'type': LessonType.speaking, 'jp': '服が泥だらけです。', 'answer': 'ふくがどろだらけです'},
        {'type': LessonType.speaking, 'jp': '間違いだらけのテスト。', 'answer': 'まちがいだらけのてすと'},
        {'type': LessonType.speaking, 'jp': '遊んでばかりいる。', 'answer': 'あそんでばかりいる'},
      ];
    }

    List<Map<String, dynamic>> _getN2Bai4LuyenVietData() {
      return [
        {'type': LessonType.kanjiDraw, 'kanji_word': '泥', 'kanji_target': '泥', 'meaning': 'Nê (Bùn)', 'rmj': 'doro / dei'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '傷', 'kanji_target': '傷', 'meaning': 'Thương (Vết thương)', 'rmj': 'kizu / shou'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '文句', 'kanji_target': '句', 'meaning': 'Cú (Câu / Phàn nàn)', 'rmj': 'ku'},
      ];
    }
  List<Map<String, dynamic>> _getN2Bai5LyThuyetData() {
      return [
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': '都市', 'hiragana': 'とし', 'romaji': 'toshi', 'meaning': 'Thành phố / Đô thị'},
            {'kanji': '田舎', 'hiragana': 'いなか', 'romaji': 'inaka', 'meaning': 'Nông thôn / Quê'},
            {'kanji': '賛成します', 'hiragana': 'さんせいします', 'romaji': 'sanseishimasu', 'meaning': 'Tán thành / Đồng ý'},
            {'kanji': '反対します', 'hiragana': 'はんたいします', 'romaji': 'hantaishimasu', 'meaning': 'Phản đối'},
            {'kanji': '効果', 'hiragana': 'こうか', 'romaji': 'kouka', 'meaning': 'Hiệu quả'},
            {'kanji': '副作用', 'hiragana': 'ふくさよう', 'romaji': 'fukusayou', 'meaning': 'Tác dụng phụ'},
          ]
        },
        {
          'type': LessonType.flashCard, 'kanji': '賛成します', 'hiragana': 'さんせいします', 'romaji': 'sanseishimasu', 'meaning': 'Tán thành',
          'example_img': 'assets/images/example_sansei.png',
          'example_jp': 'その意見に賛成です。', 'example_rmj': 'Sono iken ni sansei desu.', 'example_vn': 'Tôi tán thành ý kiến đó.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '反対します', 'hiragana': 'はんたいします', 'romaji': 'hantaishimasu', 'meaning': 'Phản đối',
          'example_img': 'assets/images/example_hantai.png',
          'example_jp': '計画に反対します。', 'example_rmj': 'Keikaku ni hantai shimasu.', 'example_vn': 'Tôi phản đối kế hoạch này.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '田舎', 'hiragana': 'いなか', 'romaji': 'inaka', 'options': ['đô thị', 'hiệu quả', 'tác dụng phụ', 'nông thôn'], 'answer': 'nông thôn'},
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'A に対して B', 'meaning': 'Trái ngược với A thì B...'},
            {'title': 'Thể thông thường + 反面', 'meaning': 'Mặt khác... (Hai mặt của 1 vấn đề)'},
          ]
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'SỰ ĐỐI LẬP',
          'formula': 'Danh từ / Thể thông thường (の) + に対して',
          'meaning': 'Trái ngược với...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜に対して',
          'notes': [
            'Dùng để so sánh sự khác biệt rõ rệt, trái ngược nhau giữa 2 sự vật, sự việc.',
            'Lưu ý: Đối với Danh từ hoặc Tính từ [な], ta dùng なの hoặc である + に対して.',
            'Ví dụ: 兄が静かなのに対して、弟は元気だ (Trái với anh trai trầm tính, em trai lại rất hiếu động).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ に対して',
          'img': 'assets/images/example_taishite.png',
          'jp': '都市が便利なのに対して、田舎は不便だ。',
          'rmj': 'Toshi ga benri na no ni taishite, inaka wa fuben da.',
          'vn': 'Trái ngược với thành phố tiện lợi, nông thôn thì lại bất tiện.'
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'HAI MẶT CỦA VẤN ĐỀ',
          'formula': 'Thể thông thường + 反面 (hanmen)',
          'meaning': 'Nhưng mặt khác...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜反面',
          'notes': [
            'Dùng để miêu tả 2 mặt (thường là mặt tốt và mặt xấu) của CÙNG MỘT sự vật, sự việc.',
            'Giống với に対して, Danh từ và Tính từ [な] đi với である/な + 反面.',
            'Ví dụ: Thuốc này có hiệu quả cao, nhưng mặt khác lại gây buồn ngủ.'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ 反面',
          'img': 'assets/images/example_hanmen.png',
          'jp': 'この薬は効果がある反面、副作用もある。',
          'rmj': 'Kono kusuri wa kouka ga aru hanmen, fukusayou mo aru.',
          'vn': 'Thuốc này có hiệu quả, nhưng mặt khác cũng có tác dụng phụ.'
        },
        {
          'type': LessonType.vocabSummary,
          'words': [
            {'kanji': '都市', 'romaji': 'toshi', 'meaning': 'thành phố'},
            {'kanji': '田舎', 'romaji': 'inaka', 'meaning': 'nông thôn'},
            {'kanji': '賛成', 'romaji': 'sansei', 'meaning': 'tán thành'},
            {'kanji': '反対', 'romaji': 'hantai', 'meaning': 'phản đối'},
            {'kanji': 'に対して', 'romaji': 'ni taishite', 'meaning': 'trái ngược với'},
            {'kanji': '反面', 'romaji': 'hanmen', 'meaning': 'nhưng mặt khác'},
          ]
        }
      ];
    }

    List<Map<String, dynamic>> _getN2Bai5LuyenTap1Data() {
      return [
        {
          'type': LessonType.imageQuiz,
          'question': 'Nông thôn.',
          'answerIndex': 1,
          'options': [
            {'img': 'assets/images/example_toshi.png', 'jp': '都市', 'rmj': 'toshi'},
            {'img': 'assets/images/example_inaka.png', 'jp': '田舎', 'rmj': 'inaka'},
            {'img': 'assets/images/example_sansei.png', 'jp': '賛成', 'rmj': 'sansei'},
            {'img': 'assets/images/example_hantai.png', 'jp': '反対', 'rmj': 'hantai'},
          ]
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': 'その意見に賛成です。',
          'rmj': 'Sono iken ni sansei desu.',
          'audio_text': 'その意見に賛成です。',
          'words': ['ý kiến', 'đó', 'tán thành', 'phản đối', 'hiệu quả'],
          'answer': 'tán thành ý kiến đó',
        },
      ];
    }

    List<Map<String, dynamic>> _getN2Bai5LuyenTap2Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền từ (Trái với anh trai, em gái lại hiếu động): \n兄が静かなの ( ... )、妹は元気だ。',
          'options': ['にあたって', 'に対して', '反面', 'のせいで'],
          'answer': 'に対して' // So sánh 2 người khác nhau
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '都市が便利なのに対して、田舎は不便だ。',
          'words': ['都市', 'が', '便利', 'なの', 'に対して', '田舎', '反面'],
          'answer': '都市 が 便利 なの に対して 田舎',
        },
      ];
    }

    List<Map<String, dynamic>> _getN2Bai5LuyenTap3Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Thuốc có hiệu quả nhưng mặt khác có tác dụng phụ. Điền từ:',
          'options': ['効果がある反面', '効果があるに対して', '効果だ反面', '効果な反面'],
          'answer': '効果がある反面'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '便利な反面、危ないです。',
          'words': ['便利', 'な', '反面', '危ない', 'です', 'に対して'],
          'answer': '便利 な 反面 危ない です',
        },
      ];
    }

    List<Map<String, dynamic>> _getN2Bai5LuyenNoiData() {
      return [
        {'type': LessonType.speaking, 'jp': '意見に賛成します。', 'answer': 'いけんにさんせいします'},
        {'type': LessonType.speaking, 'jp': '計画に反対します。', 'answer': 'けいかくにはんたいします'},
        {'type': LessonType.speaking, 'jp': '便利な反面、副作用がある。', 'answer': 'べんりなはんめんふくさようがある'},
      ];
    }

    List<Map<String, dynamic>> _getN2Bai5LuyenVietData() {
      return [
        {'type': LessonType.kanjiDraw, 'kanji_word': '都市', 'kanji_target': '都', 'meaning': 'Đô (Đô thị / Thủ đô)', 'rmj': 'to / miyako'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '反対', 'kanji_target': '反', 'meaning': 'Phản (Phản đối / Trái lại)', 'rmj': 'han / so(ru)'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '効果', 'kanji_target': '効', 'meaning': 'Hiệu (Hiệu quả)', 'rmj': 'kou / ki(ku)'},
      ];
    }
  List<Map<String, dynamic>> _getN2Bai6LyThuyetData() {
      return [
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': '会いたい', 'hiragana': 'あいたい', 'romaji': 'aitai', 'meaning': 'Muốn gặp'},
            {'kanji': '寂しい', 'hiragana': 'さびしい', 'romaji': 'sabishii', 'meaning': 'Buồn / Cô đơn'},
            {'kanji': '悔しい', 'hiragana': 'くやしい', 'romaji': 'kuyashii', 'meaning': 'Tiếc nuối / Cay cú'},
            {'kanji': '心配', 'hiragana': 'しんぱい', 'romaji': 'shinpai', 'meaning': 'Lo lắng'},
            {'kanji': '眠い', 'hiragana': 'ねむい', 'romaji': 'nemui', 'meaning': 'Buồn ngủ'},
          ]
        },
        {
          'type': LessonType.flashCard, 'kanji': '寂しい', 'hiragana': 'さびしい', 'romaji': 'sabishii', 'meaning': 'Buồn / Cô đơn',
          'example_img': 'assets/images/example_sabishii.png',
          'example_jp': '一人で寂しいです。', 'example_rmj': 'Hitori de sabishii desu.', 'example_vn': 'Tôi buồn vì ở một mình.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '悔しい', 'hiragana': 'くやしい', 'romaji': 'kuyashii', 'meaning': 'Cay cú / Tiếc nuối',
          'example_img': 'assets/images/example_kuyashii.png',
          'example_jp': '負けて悔しいです。', 'example_rmj': 'Makete kuyashii desu.', 'example_vn': 'Thua trận nên tôi rất cay cú.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '眠い', 'hiragana': 'ねむい', 'romaji': 'nemui', 'options': ['cô đơn', 'tiếc nuối', 'lo lắng', 'buồn ngủ'], 'answer': 'buồn ngủ'},
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'V/A(て) + たまらない', 'meaning': 'Vô cùng... / ... không chịu nổi'},
            {'title': 'V/A(て) + しかたがない', 'meaning': 'Rất... / Không biết làm sao'},
          ]
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'CẢM XÚC KHÔNG KIỀM CHẾ ĐƯỢC',
          'formula': 'Động từ / Tính từ (chia về thể て) + たまらない (tamaranai)',
          'meaning': 'Vô cùng... / ... không chịu nổi'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜てたまらない',
          'notes': [
            'Dùng để diễn tả một cảm giác, cảm xúc cá nhân mạnh mẽ đến mức không thể kiềm chế được.',
            'Động từ thường chia ở dạng muốn làm gì đó (〜たい ➔ 〜たくてたまらない).',
            'Ví dụ: Nóng không chịu nổi (暑くてたまらない).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ たまらない',
          'img': 'assets/images/example_tamaranai.png',
          'jp': '家族に会いたくてたまらない。',
          'rmj': 'Kazoku ni aitakute tamaranai.',
          'vn': 'Tôi muốn gặp gia đình đến mức không chịu nổi.'
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'TRẠNG THÁI VÔ CÙNG',
          'formula': 'Động từ / Tính từ (chia về thể て) + しかたがない (shikata ga nai)',
          'meaning': 'Vô cùng... / Rất...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜てしかたがない',
          'notes': [
            'Ý nghĩa gần như giống hệt với てたまらない nhưng mang sắc thái "bất lực, không biết làm sao để thoát khỏi cảm giác đó".',
            'Rất hay dùng với các tính từ chỉ cảm xúc hoặc thể trạng.',
            'Ví dụ: Lo lắng vô cùng (心配でしかたがない).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ しかたがない',
          'img': 'assets/images/example_shikataganai.png',
          'jp': '試合に負けて、悔しくてしかたがない。',
          'rmj': 'Shiai ni makete, kuyashikute shikata ga nai.',
          'vn': 'Thua trận nên tôi cay cú không biết để đâu cho hết.'
        },
        {
          'type': LessonType.vocabSummary,
          'words': [
            {'kanji': '会いたい', 'romaji': 'aitai', 'meaning': 'muốn gặp'},
            {'kanji': '寂しい', 'romaji': 'sabishii', 'meaning': 'cô đơn'},
            {'kanji': '悔しい', 'romaji': 'kuyashii', 'meaning': 'cay cú'},
            {'kanji': 'たまらない', 'romaji': 'tamaranai', 'meaning': 'không chịu nổi'},
            {'kanji': 'しかたがない', 'romaji': 'shikata ga nai', 'meaning': 'rất / không biết làm sao'},
          ]
        }
      ];
    }

    List<Map<String, dynamic>> _getN2Bai6LuyenTap1Data() {
      return [
        {
          'type': LessonType.imageQuiz,
          'question': 'Cay cú / Tiếc nuối.',
          'answerIndex': 2,
          'options': [
            {'img': 'assets/images/example_sabishii.png', 'jp': '寂しい', 'rmj': 'sabishii'},
            {'img': 'assets/images/example_nemui.png', 'jp': '眠い', 'rmj': 'nemui'},
            {'img': 'assets/images/example_kuyashii.png', 'jp': '悔しい', 'rmj': 'kuyashii'},
            {'img': 'assets/images/example_shinpai.png', 'jp': '心配', 'rmj': 'shinpai'},
          ]
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '負けて悔しいです。',
          'rmj': 'Makete kuyashii desu.',
          'audio_text': '負けて悔しいです。',
          'words': ['thua', 'cay cú', 'vì', 'cô đơn', 'buồn ngủ'],
          'answer': 'cay cú vì thua',
        },
      ];
    }

    List<Map<String, dynamic>> _getN2Bai6LuyenTap2Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Muốn gặp KHÔNG CHỊU NỔI. Chia từ 会いたい:',
          'options': ['会いたいてたまらない', '会いたくてたまらない', '会いたいでたまらない', '会うてたまらない'],
          'answer': '会いたくてたまらない' // Đuôi たい chia giống tính từ đuôi い
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '家族に会いたくてたまらない。',
          'words': ['家族', 'に', '会いたくて', 'たまらない', 'しかたがない'],
          'answer': '家族 に 会いたくて たまらない',
        },
      ];
    }

    List<Map<String, dynamic>> _getN2Bai6LuyenTap3Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền từ (Lo lắng không biết làm sao): \nテストの結果が心配 ( ... ) しかたがない。',
          'options': ['で', 'て', 'くて', 'だ'],
          'answer': 'で' // 心配 là danh từ/tính từ Na -> で
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '悔しくてしかたがない。',
          'words': ['悔しく', 'て', 'しかた', 'が', 'ない', 'たまらない'],
          'answer': '悔しく て しかた が ない',
        },
      ];
    }

    List<Map<String, dynamic>> _getN2Bai6LuyenNoiData() {
      return [
        {'type': LessonType.speaking, 'jp': '一人で寂しいです。', 'answer': 'ひとりでさびしいです'},
        {'type': LessonType.speaking, 'jp': '会いたくてたまらない。', 'answer': 'あいたくてたまらない'},
        {'type': LessonType.speaking, 'jp': '悔しくてしかたがない。', 'answer': 'くやしくてしかたがない'},
      ];
    }

    List<Map<String, dynamic>> _getN2Bai6LuyenVietData() {
      return [
        {'type': LessonType.kanjiDraw, 'kanji_word': '寂しい', 'kanji_target': '寂', 'meaning': 'Tịch (Tĩnh mịch / Cô đơn)', 'rmj': 'sabi(shii) / jaku'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '悔しい', 'kanji_target': '悔', 'meaning': 'Hối (Hối hận / Cay cú)', 'rmj': 'kuya(shii) / kou'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '眠い', 'kanji_target': '眠', 'meaning': 'Miên (Ngủ / Buồn ngủ)', 'rmj': 'nemu(i) / min'},
      ];
    }
  List<Map<String, dynamic>> _getN2Bai7LyThuyetData() {
      return [
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': '急ぎます', 'hiragana': 'いそぎます', 'romaji': 'isogimasu', 'meaning': 'Vội vã / Gấp gáp'},
            {'kanji': '忘れます', 'hiragana': 'わすれます', 'romaji': 'wasuremasu', 'meaning': 'Quên'},
            {'kanji': '油断します', 'hiragana': 'ゆだんします', 'romaji': 'yudanshimasu', 'meaning': 'Lơ là / Chủ quan'},
            {'kanji': '傘', 'hiragana': 'かさ', 'romaji': 'kasa', 'meaning': 'Cái ô / Cây dù'},
            {'kanji': '忘れ物', 'hiragana': 'わすれもの', 'romaji': 'wasuremono', 'meaning': 'Đồ bỏ quên'},
          ]
        },
        {
          'type': LessonType.flashCard, 'kanji': '急ぎます', 'hiragana': 'いそぎます', 'romaji': 'isogimasu', 'meaning': 'Vội vã',
          'example_img': 'assets/images/example_isogimasu.png',
          'example_jp': '急いで行きます。', 'example_rmj': 'Isoide ikimasu.', 'example_vn': 'Tôi vội vàng đi.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '油断します', 'hiragana': 'ゆだんします', 'romaji': 'yudanshimasu', 'meaning': 'Chủ quan',
          'example_img': 'assets/images/example_yudan.png',
          'example_jp': '油断して負けた。', 'example_rmj': 'Yudan shite maketa.', 'example_vn': 'Vì chủ quan nên đã thua.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '傘', 'hiragana': 'かさ', 'romaji': 'kasa', 'options': ['đồ bỏ quên', 'cái ô', 'vội vã', 'chủ quan'], 'answer': 'cái ô'},
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'V(た) + ばかりに', 'meaning': 'Chỉ vì... (Mà dẫn đến kết quả xấu, hối hận)'},
            {'title': 'Danh từ + に限って', 'meaning': 'Đúng lúc / Riêng cái (ngày, người) đó thì lại...'},
          ]
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'SỰ HỐI HẬN (ばかりに)',
          'formula': 'V(た) / A(い) / A(な) / N(である) + ばかりに',
          'meaning': 'Chỉ vì...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜ばかりに',
          'notes': [
            'Dùng để diễn tả sự hối hận, tiếc nuối: "Chỉ vì một nguyên nhân nhỏ bé, lãng xẹt mà dẫn đến hậu quả tồi tệ".',
            'Kết quả phía sau luôn là điều không tốt.',
            'Ví dụ: Cả tin (信じたばかりに) nên bị lừa.'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ ばかりに',
          'img': 'assets/images/example_bakarini.png',
          'jp': '急いだばかりに、忘れ物をした。',
          'rmj': 'Isoida bakari ni, wasuremono o shita.',
          'vn': 'Chỉ vì vội vàng mà tôi đã để quên đồ.'
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'SỰ XUI XẺO (に限って)',
          'formula': 'Danh từ + に限って (ni kagitte)',
          'meaning': 'Đúng lúc... thì lại / Riêng... thì...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜に限って',
          'notes': [
            'Dùng để phàn nàn về sự xui xẻo: Đúng vào cái lúc mình không mong muốn nhất thì sự việc lại xảy ra.',
            'Hoặc diễn tả sự tin tưởng tuyệt đối: "Riêng anh ấy thì tuyệt đối không làm chuyện xấu đó đâu".'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ に限って',
          'img': 'assets/images/example_nikagitte.png',
          'jp': '傘がない日に限って、雨が降る。',
          'rmj': 'Kasa ga nai hi ni kagitte, ame ga furu.',
          'vn': 'Đúng cái ngày không mang ô thì trời lại mưa.'
        },
        {
          'type': LessonType.vocabSummary,
          'words': [
            {'kanji': '急ぐ', 'romaji': 'isogu', 'meaning': 'vội vã'},
            {'kanji': '油断する', 'romaji': 'yudansuru', 'meaning': 'chủ quan'},
            {'kanji': '傘', 'romaji': 'kasa', 'meaning': 'cái ô'},
            {'kanji': 'ばかりに', 'romaji': 'bakari ni', 'meaning': 'chỉ vì (hối hận)'},
            {'kanji': 'に限って', 'romaji': 'ni kagitte', 'meaning': 'đúng lúc thì lại'},
          ]
        }
      ];
    }

    List<Map<String, dynamic>> _getN2Bai7LuyenTap1Data() {
      return [
        {
          'type': LessonType.imageQuiz,
          'question': 'Đồ bỏ quên.',
          'answerIndex': 2,
          'options': [
            {'img': 'assets/images/example_isogimasu.png', 'jp': '急ぎます', 'rmj': 'isogimasu'},
            {'img': 'assets/images/example_kasa.png', 'jp': '傘', 'rmj': 'kasa'},
            {'img': 'assets/images/example_wasuremono.png', 'jp': '忘れ物', 'rmj': 'wasuremono'},
            {'img': 'assets/images/example_yudan.png', 'jp': '油断します', 'rmj': 'yudanshimasu'},
          ]
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '急いで行きます。',
          'rmj': 'Isoide ikimasu.',
          'audio_text': '急いで行きます。',
          'words': ['vội vã', 'đi', 'quên', 'chủ quan', 'đúng lúc'],
          'answer': 'vội vã đi',
        },
      ];
    }

    List<Map<String, dynamic>> _getN2Bai7LuyenTap2Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền từ (Chỉ vì chủ quan mà thất bại): \n油断した ( ... )、失敗した。',
          'options': ['に限って', 'ばかりに', '反面', 'に対して'],
          'answer': 'ばかりに'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '急いだばかりに、忘れ物をした。',
          'words': ['急いだ', 'ばかりに', '忘れ物', 'を', 'した', '限って'],
          'answer': '急いだ ばかりに 忘れ物 を した',
        },
      ];
    }

    List<Map<String, dynamic>> _getN2Bai7LuyenTap3Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền từ (Đúng lúc vội thì xe buýt không tới): \n急いでいる時に ( ... )、バスが来ない。',
          'options': ['限って', 'ばかりに', 'あたって', '際して'],
          'answer': '限って'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '傘がない日に限って、雨が降る。',
          'words': ['傘', 'が', 'ない', '日', 'に', '限って', '雨'],
          'answer': '傘 が ない 日 に 限って',
        },
      ];
    }

    List<Map<String, dynamic>> _getN2Bai7LuyenNoiData() {
      return [
        {'type': LessonType.speaking, 'jp': '油断して負けた。', 'answer': 'ゆだんしてまけた'},
        {'type': LessonType.speaking, 'jp': '急いだばかりに、忘れ物をした。', 'answer': 'いそいだばかりにわすれものをした'},
        {'type': LessonType.speaking, 'jp': '傘がない日に限って、雨が降る。', 'answer': 'かさがないひにかぎってあめがふる'},
      ];
    }

    List<Map<String, dynamic>> _getN2Bai7LuyenVietData() {
      return [
        {'type': LessonType.kanjiDraw, 'kanji_word': '急ぎます', 'kanji_target': '急', 'meaning': 'Cấp (Khẩn cấp / Vội vã)', 'rmj': 'iso(gu) / kyuu'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '忘れます', 'kanji_target': '忘', 'meaning': 'Vong (Lãng quên)', 'rmj': 'wasu(reru) / bou'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '傘', 'kanji_target': '傘', 'meaning': 'Tản (Cái ô)', 'rmj': 'kasa / san'},
      ];
    }
  List<Map<String, dynamic>> _getN2Bai8LyThuyetData() {
      return [
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': '経営者', 'hiragana': 'けいえいしゃ', 'romaji': 'keieisha', 'meaning': 'Nhà kinh doanh / Quản lý'},
            {'kanji': '消費者', 'hiragana': 'しょうひしゃ', 'romaji': 'shouhisha', 'meaning': 'Người tiêu dùng'},
            {'kanji': '留学生', 'hiragana': 'りゅうがくせい', 'romaji': 'ryuugakusei', 'meaning': 'Du học sinh'},
            {'kanji': '代表', 'hiragana': 'だいひょう', 'romaji': 'daihyou', 'meaning': 'Đại biểu / Đại diện'},
            {'kanji': '立場', 'hiragana': 'たちば', 'romaji': 'tachiba', 'meaning': 'Lập trường / Vị thế'},
          ]
        },
        {
          'type': LessonType.flashCard, 'kanji': '消費者', 'hiragana': 'しょうひしゃ', 'romaji': 'shouhisha', 'meaning': 'Người tiêu dùng',
          'example_img': 'assets/images/example_shouhisha.png',
          'example_jp': '消費者の意見を聞く。', 'example_rmj': 'Shouhisha no iken o kiku.', 'example_vn': 'Nghe ý kiến của người tiêu dùng.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '留学生', 'hiragana': 'りゅうがくせい', 'romaji': 'ryuugakusei', 'meaning': 'Du học sinh',
          'example_img': 'assets/images/example_ryuugakusei.png',
          'example_jp': '日本に来た留学生です。', 'example_rmj': 'Nihon ni kita ryuugakusei desu.', 'example_vn': 'Là du học sinh đến Nhật.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '代表', 'hiragana': 'だいひょう', 'romaji': 'daihyou', 'options': ['người tiêu dùng', 'nhà quản lý', 'đại diện', 'lập trường'], 'answer': 'đại diện'},
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'Danh từ + からいうと', 'meaning': 'Xét từ góc độ / Lập trường của...'},
            {'title': 'Danh từ + として', 'meaning': 'Với tư cách là / Nhằm mục đích...'},
          ]
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'GÓC ĐỘ / LẬP TRƯỜNG',
          'formula': 'Danh từ + からいうと / からいえば (kara iu to)',
          'meaning': 'Xét từ góc độ của...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜からいうと',
          'notes': [
            'Dùng để đưa ra nhận định, đánh giá khi đứng trên lập trường của một người hoặc một khía cạnh nào đó.',
            'Ví dụ: Xét từ góc độ năng lực, Xét từ góc độ của khách hàng...'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ からいうと',
          'img': 'assets/images/example_karaiuto.png',
          'jp': '消費者の立場からいうと、安いほうがいい。',
          'rmj': 'Shouhisha no tachiba kara iu to, yasui hou ga ii.',
          'vn': 'Xét từ lập trường của người tiêu dùng thì rẻ sẽ tốt hơn.'
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'TƯ CÁCH / VAI TRÒ',
          'formula': 'Danh từ + として (to shite)',
          'meaning': 'Với tư cách là / Như là...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜として',
          'notes': [
            'Chỉ định rõ tư cách, vị trí, chức danh hoặc mục đích của một người/sự vật.',
            'Ví dụ: Làm việc VỚI TƯ CÁCH LÀ giám đốc, Dùng cái cốc này NHƯ LÀ bình hoa.'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ として',
          'img': 'assets/images/example_toshite.png',
          'jp': '彼は留学生として日本に来ました。',
          'rmj': 'Kare wa ryuugakusei to shite Nihon ni kimashita.',
          'vn': 'Anh ấy đến Nhật Bản VỚI TƯ CÁCH LÀ du học sinh.'
        },
        {
          'type': LessonType.vocabSummary,
          'words': [
            {'kanji': '経営者', 'romaji': 'keieisha', 'meaning': 'nhà quản lý'},
            {'kanji': '消費者', 'romaji': 'shouhisha', 'meaning': 'người tiêu dùng'},
            {'kanji': '代表', 'romaji': 'daihyou', 'meaning': 'đại diện'},
            {'kanji': 'からいうと', 'romaji': 'kara iu to', 'meaning': 'xét từ góc độ'},
            {'kanji': 'として', 'romaji': 'to shite', 'meaning': 'với tư cách là'},
          ]
        }
      ];
    }

    List<Map<String, dynamic>> _getN2Bai8LuyenTap1Data() {
      return [
        {
          'type': LessonType.imageQuiz,
          'question': 'Du học sinh.',
          'answerIndex': 1,
          'options': [
            {'img': 'assets/images/example_shouhisha.png', 'jp': '消費者', 'rmj': 'shouhisha'},
            {'img': 'assets/images/example_ryuugakusei.png', 'jp': '留学生', 'rmj': 'ryuugakusei'},
            {'img': 'assets/images/example_keieisha.png', 'jp': '経営者', 'rmj': 'keieisha'},
            {'img': 'assets/images/example_daihyou.png', 'jp': '代表', 'rmj': 'daihyou'},
          ]
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '消費者の意見を聞く。',
          'rmj': 'Shouhisha no iken o kiku.',
          'audio_text': '消費者の意見を聞く。',
          'words': ['người tiêu dùng', 'của', 'ý kiến', 'nghe', 'tư cách'],
          'answer': 'nghe ý kiến của người tiêu dùng',
        },
      ];
    }

    List<Map<String, dynamic>> _getN2Bai8LuyenTap2Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền từ (Xét từ góc độ năng lực thì anh ấy là số 1): \n能力 ( ... )、彼が一番だ。',
          'options': ['として', 'からいうと', 'に限って', 'ばかりに'],
          'answer': 'からいうと'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '消費者の立場からいうと、安いほうがいい。',
          'words': ['消費者', 'の', '立場', 'から', 'いうと', '安い'],
          'answer': '消費者 の 立場 から いうと',
        },
      ];
    }

    List<Map<String, dynamic>> _getN2Bai8LuyenTap3Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền từ (Đến Nhật với TƯ CÁCH LÀ đại diện): \n代表 ( ... ) 日本へ来ました。',
          'options': ['からいうと', 'として', 'にあたって', 'に対して'],
          'answer': 'として'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '彼は留学生として日本に来ました。',
          'words': ['彼', 'は', '留学生', 'として', '日本に', '来ました', 'からいうと'],
          'answer': '彼 は 留学生 として 日本に 来ました',
        },
      ];
    }

    List<Map<String, dynamic>> _getN2Bai8LuyenNoiData() {
      return [
        {'type': LessonType.speaking, 'jp': '消費者の意見を聞く。', 'answer': 'しょうひしゃのいけんをきく'},
        {'type': LessonType.speaking, 'jp': '消費者の立場からいうと。', 'answer': 'しょうひしゃのたちばからいうと'},
        {'type': LessonType.speaking, 'jp': '留学生として日本に来ました。', 'answer': 'りゅうがくせいとしてにほんにきました'},
      ];
    }

    List<Map<String, dynamic>> _getN2Bai8LuyenVietData() {
      return [
        {'type': LessonType.kanjiDraw, 'kanji_word': '経営', 'kanji_target': '経', 'meaning': 'Kinh (Kinh doanh / Kinh tế)', 'rmj': 'kei / he(ru)'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '経営', 'kanji_target': '営', 'meaning': 'Doanh (Kinh doanh / Quản lý)', 'rmj': 'ei / itona(mu)'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '消費', 'kanji_target': '費', 'meaning': 'Phí (Tiêu phí / Chi phí)', 'rmj': 'hi / tsui(yasu)'},
      ];
    }
  List<Map<String, dynamic>> _getN2Bai9LyThuyetData() {
      return [
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': '謝ります', 'hiragana': 'あやまります', 'romaji': 'ayamarimasu', 'meaning': 'Xin lỗi'},
            {'kanji': '諦めます', 'hiragana': 'あきらめます', 'romaji': 'akiramemasu', 'meaning': 'Từ bỏ / Bỏ cuộc'},
            {'kanji': '感動します', 'hiragana': 'かんどうします', 'romaji': 'kandoushimasu', 'meaning': 'Cảm động'},
            {'kanji': '中止', 'hiragana': 'ちゅうし', 'romaji': 'chuushi', 'meaning': 'Hủy bỏ / Đình chỉ'},
            {'kanji': '仕方なく', 'hiragana': 'しかたなく', 'romaji': 'shikatanaku', 'meaning': 'Không còn cách nào khác'},
          ]
        },
        {
          'type': LessonType.flashCard, 'kanji': '謝ります', 'hiragana': 'あやまります', 'romaji': 'ayamarimasu', 'meaning': 'Xin lỗi',
          'example_img': 'assets/images/example_ayamarimasu.png',
          'example_jp': '彼に謝ります。', 'example_rmj': 'Kare ni ayamarimasu.', 'example_vn': 'Xin lỗi anh ấy.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '諦めます', 'hiragana': 'あきらめます', 'romaji': 'akiramemasu', 'meaning': 'Từ bỏ',
          'example_img': 'assets/images/example_akiramemasu.png',
          'example_jp': '夢を諦めます。', 'example_rmj': 'Yume o akiramemasu.', 'example_vn': 'Từ bỏ giấc mơ.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '感動します', 'hiragana': 'かんどうします', 'romaji': 'kandoushimasu', 'options': ['xin lỗi', 'cảm động', 'từ bỏ', 'hủy bỏ'], 'answer': 'cảm động'},
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'V(ない) + ざるを得ない', 'meaning': 'Đành phải / Buộc phải (dù không muốn)'},
            {'title': 'V(ない) + ずにはいられない', 'meaning': 'Không thể không / Bất giác...'},
          ]
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'SỰ ÉP BUỘC TỪ HOÀN CẢNH',
          'formula': 'Động từ thể (ない) bỏ [ない] + ざるを得ない\n*Ngoại lệ: する ➔ せざるを得ない',
          'meaning': 'Đành phải...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜ざるを得ない',
          'notes': [
            'Dùng khi bản thân không hề muốn làm, nhưng vì tình thế, hoàn cảnh bắt buộc nên KHÔNG CÒN CÁCH NÀO KHÁC là phải làm.',
            'Rất hay dùng trong văn bản công việc hoặc thông báo.',
            'Ví dụ: 行かない ➔ 行かざるを得ない (Đành phải đi).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ ざるを得ない',
          'img': 'assets/images/example_zaruwoenai.png',
          'jp': '台風で、試合を中止せざるを得ない。',
          'rmj': 'Taifuu de, shiai o chuushi sezaru o enai.',
          'vn': 'Do bão nên đành phải hủy bỏ trận đấu.'
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'CẢM XÚC TRÀO DÂNG',
          'formula': 'Động từ thể (ない) bỏ [ない] + ずにはいられない\n*Ngoại lệ: する ➔ せずにはいられない',
          'meaning': 'Không thể không... / Bất giác...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜ずにはいられない',
          'notes': [
            'Diễn tả một cảm xúc mạnh mẽ hoặc hành động tự nhiên bộc phát từ bên trong mà bản thân KHÔNG THỂ KIỀM CHẾ được.',
            'Thường đi kèm với các động từ chỉ cảm xúc: Khóc, Cười, Cảm động, Lo lắng.',
            'Ví dụ: 泣かない ➔ 泣かずにはいられない (Không thể không khóc / Bất giác rơi nước mắt).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ ずにはいられない',
          'img': 'assets/images/example_zunihairarenai.png',
          'jp': 'その映画を見て、感動せずにはいられなかった。',
          'rmj': 'Sono eiga o mite, kandou sezu ni wa irarenakatta.',
          'vn': 'Xem bộ phim đó, tôi không thể không cảm động.'
        },
        {
          'type': LessonType.vocabSummary,
          'words': [
            {'kanji': '謝る', 'romaji': 'ayamaru', 'meaning': 'xin lỗi'},
            {'kanji': '諦める', 'romaji': 'akirameru', 'meaning': 'từ bỏ'},
            {'kanji': '中止', 'romaji': 'chuushi', 'meaning': 'hủy bỏ'},
            {'kanji': 'ざるを得ない', 'romaji': 'zaru o enai', 'meaning': 'đành phải'},
            {'kanji': 'ずにはいられない', 'romaji': 'zu ni wa irarenai', 'meaning': 'không thể không'},
          ]
        }
      ];
    }

    List<Map<String, dynamic>> _getN2Bai9LuyenTap1Data() {
      return [
        {
          'type': LessonType.imageQuiz,
          'question': 'Từ bỏ / Bỏ cuộc.',
          'answerIndex': 1,
          'options': [
            {'img': 'assets/images/example_ayamarimasu.png', 'jp': '謝ります', 'rmj': 'ayamarimasu'},
            {'img': 'assets/images/example_akiramemasu.png', 'jp': '諦めます', 'rmj': 'akiramemasu'},
            {'img': 'assets/images/example_chuushi.png', 'jp': '中止', 'rmj': 'chuushi'},
            {'img': 'assets/images/example_kandou.png', 'jp': '感動します', 'rmj': 'kandoushimasu'},
          ]
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '夢を諦めます。',
          'rmj': 'Yume o akiramemasu.',
          'audio_text': '夢を諦めます。',
          'words': ['giấc mơ', 'từ bỏ', 'cảm động', 'xin lỗi', 'đành phải'],
          'answer': 'từ bỏ giấc mơ',
        },
      ];
    }

    List<Map<String, dynamic>> _getN2Bai9LuyenTap2Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Chia "Đành phải đi" (行く) sang cấu trúc ざるを得ない:',
          'options': ['行きざるを得ない', '行くざるを得ない', '行かざるを得ない', '行けざるを得ない'],
          'answer': '行かざるを得ない' // Dùng thể ない bỏ ない
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '試合を中止せざるを得ない。',
          'words': ['試合', 'を', '中止', 'せざる', 'を得ない', 'ずにはいられない'],
          'answer': '試合 を 中止 せざる を得ない',
        },
      ];
    }

    List<Map<String, dynamic>> _getN2Bai9LuyenTap3Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền từ (Cảm động không thể kìm nén được): \n感動 ( ... ) にはいられない。',
          'options': ['せざる', 'せず', 'しず', 'しないで'],
          'answer': 'せず' // する chuyển thành せず
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '泣かずにはいられなかった。',
          'words': ['泣かず', 'には', 'いられなかった', '泣かざる', 'を得ない'],
          'answer': '泣かず には いられなかった',
        },
      ];
    }

    List<Map<String, dynamic>> _getN2Bai9LuyenNoiData() {
      return [
        {'type': LessonType.speaking, 'jp': '夢を諦めます。', 'answer': 'ゆめをあきらめます'},
        {'type': LessonType.speaking, 'jp': '中止せざるを得ない。', 'answer': 'ちゅうしせざるをえない'},
        {'type': LessonType.speaking, 'jp': '泣かずにはいられない。', 'answer': 'なかずにはいられない'},
      ];
    }

    List<Map<String, dynamic>> _getN2Bai9LuyenVietData() {
      return [
        {'type': LessonType.kanjiDraw, 'kanji_word': '謝ります', 'kanji_target': '謝', 'meaning': 'Tạ (Tạ lỗi / Cảm tạ)', 'rmj': 'ayama(ru) / sha'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '感動', 'kanji_target': '感', 'meaning': 'Cảm (Cảm giác / Cảm động)', 'rmj': 'kan'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '中止', 'kanji_target': '止', 'meaning': 'Chỉ (Dừng lại)', 'rmj': 'to(maru) / shi'},
      ];
    }
  List<Map<String, dynamic>> _getN2Bai10LyThuyetData() {
      return [
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': '冗談', 'hiragana': 'じょうだん', 'romaji': 'joudan', 'meaning': 'Trò đùa / Nói đùa'},
            {'kanji': '誤解', 'hiragana': 'ごかい', 'romaji': 'gokai', 'meaning': 'Hiểu lầm'},
            {'kanji': '結果', 'hiragana': 'けっか', 'romaji': 'kekka', 'meaning': 'Kết quả'},
            {'kanji': '愛', 'hiragana': 'あい', 'romaji': 'ai', 'meaning': 'Tình yêu'},
            {'kanji': '単なる', 'hiragana': 'たんなる', 'romaji': 'tannaru', 'meaning': 'Đơn thuần / Chỉ là'},
          ]
        },
        {
          'type': LessonType.flashCard, 'kanji': '冗談', 'hiragana': 'じょうだん', 'romaji': 'joudan', 'meaning': 'Trò đùa',
          'example_img': 'assets/images/example_joudan.png',
          'example_jp': '単なる冗談です。', 'example_rmj': 'Tannaru joudan desu.', 'example_vn': 'Đơn thuần chỉ là một trò đùa thôi.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '誤解', 'hiragana': 'ごかい', 'romaji': 'gokai', 'meaning': 'Hiểu lầm',
          'example_img': 'assets/images/example_gokai.png',
          'example_jp': 'それは誤解です。', 'example_rmj': 'Sore wa gokai desu.', 'example_vn': 'Đó là sự hiểu lầm.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '結果', 'hiragana': 'けっか', 'romaji': 'kekka', 'options': ['trò đùa', 'tình yêu', 'kết quả', 'hiểu lầm'], 'answer': 'kết quả'},
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'V/N + にすぎない', 'meaning': 'Chẳng qua chỉ là... (Đánh giá thấp mức độ)'},
            {'title': 'N + にほかならない', 'meaning': 'Chính là... / Không gì khác ngoài... (Nhấn mạnh tuyệt đối)'},
          ]
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'MỨC ĐỘ THẤP',
          'formula': 'Danh từ / Động từ (thể thông thường) + にすぎない',
          'meaning': 'Chẳng qua chỉ là... / Không quá...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜にすぎない',
          'notes': [
            'Dùng để hạ thấp mức độ của một sự việc, cho rằng nó "chỉ ở mức độ đó thôi, không có gì to tát cả".',
            'Rất hay đi kèm với từ 「単なる」 (Đơn thuần chỉ là...).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ にすぎない',
          'img': 'assets/images/example_nisuginai.png',
          'jp': 'これは単なる誤解にすぎない。',
          'rmj': 'Kore wa tannaru gokai ni suginai.',
          'vn': 'Đây đơn thuần CHỈ LÀ một sự hiểu lầm (chứ không có ác ý gì).'
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'NHẤN MẠNH TUYỆT ĐỐI',
          'formula': 'Danh từ + にほかならない (ni hoka naranai)',
          'meaning': 'Chính là... / Không gì khác ngoài...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜にほかならない',
          'notes': [
            'Dùng để đưa ra một kết luận đanh thép, khẳng định 100% nguyên nhân hoặc bản chất của vấn đề.',
            'Mang nghĩa: "Ngoài cái đó ra thì không còn cái nào khác". Thường dùng trong văn nghị luận.'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ にほかならない',
          'img': 'assets/images/example_nihokanaranai.png',
          'jp': 'この結果は、努力にほかならない。',
          'rmj': 'Kono kekka wa, doryoku ni hoka naranai.',
          'vn': 'Kết quả này KHÔNG GÌ KHÁC NGOÀI sự nỗ lực.'
        },
        {
          'type': LessonType.vocabSummary,
          'words': [
            {'kanji': '冗談', 'romaji': 'joudan', 'meaning': 'trò đùa'},
            {'kanji': '結果', 'romaji': 'kekka', 'meaning': 'kết quả'},
            {'kanji': '愛', 'romaji': 'ai', 'meaning': 'tình yêu'},
            {'kanji': 'にすぎない', 'romaji': 'ni suginai', 'meaning': 'chẳng qua chỉ là'},
            {'kanji': 'にほかならない', 'romaji': 'ni hoka naranai', 'meaning': 'chính là'},
          ]
        }
      ];
    }

    List<Map<String, dynamic>> _getN2Bai10LuyenTap1Data() {
      return [
        {
          'type': LessonType.imageQuiz,
          'question': 'Kết quả.',
          'answerIndex': 2,
          'options': [
            {'img': 'assets/images/example_joudan.png', 'jp': '冗談', 'rmj': 'joudan'},
            {'img': 'assets/images/example_gokai.png', 'jp': '誤解', 'rmj': 'gokai'},
            {'img': 'assets/images/example_kekka.png', 'jp': '結果', 'rmj': 'kekka'},
            {'img': 'assets/images/example_ai.png', 'jp': '愛', 'rmj': 'ai'},
          ]
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '単なる冗談です。',
          'rmj': 'Tannaru joudan desu.',
          'audio_text': '単なる冗談です。',
          'words': ['đơn thuần', 'chỉ là', 'trò đùa', 'tình yêu', 'hiểu lầm'],
          'answer': 'đơn thuần chỉ là trò đùa',
        },
      ];
    }

    List<Map<String, dynamic>> _getN2Bai10LuyenTap2Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền từ (Đây chỉ là sự hiểu lầm): \nこれは誤解 ( ... )。',
          'options': ['にすぎない', 'にほかならない', 'ざるを得ない', 'に限って'],
          'answer': 'にすぎない'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '単なる誤解にすぎない。',
          'words': ['単なる', '誤解', 'に', 'すぎない', 'ほかならない'],
          'answer': '単なる 誤解 に すぎない',
        },
      ];
    }

    List<Map<String, dynamic>> _getN2Bai10LuyenTap3Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Cấu trúc mang ý nghĩa nhấn mạnh tuyệt đối (Chính là / Không gì khác ngoài):',
          'options': ['にすぎない', 'にほかならない', 'に対して', 'からいうと'],
          'answer': 'にほかならない'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': 'この結果は、努力にほかならない。',
          'words': ['この', '結果', 'は', '努力', 'に', 'ほかならない', 'すぎない'],
          'answer': 'この 結果 は 努力 に ほかならない',
        },
      ];
    }

    List<Map<String, dynamic>> _getN2Bai10LuyenNoiData() {
      return [
        {'type': LessonType.speaking, 'jp': 'それは誤解です。', 'answer': 'それはごかいです'},
        {'type': LessonType.speaking, 'jp': '単なる誤解にすぎない。', 'answer': 'たんなるごかいにすぎない'},
        {'type': LessonType.speaking, 'jp': '努力にほかならない。', 'answer': 'どりょくにほかならない'},
      ];
    }

    List<Map<String, dynamic>> _getN2Bai10LuyenVietData() {
      return [
        {'type': LessonType.kanjiDraw, 'kanji_word': '冗談', 'kanji_target': '冗', 'meaning': 'Nhũng (Dư thừa / Nói đùa)', 'rmj': 'jou'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '冗談', 'kanji_target': '談', 'meaning': 'Đàm (Đàm thoại / Thảo luận)', 'rmj': 'dan'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '結果', 'kanji_target': '結', 'meaning': 'Kết (Kết quả / Buộc)', 'rmj': 'ketsu / musu(bu)'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '結果', 'kanji_target': '果', 'meaning': 'Quả (Kết quả / Trái cây)', 'rmj': 'ka / ha(tasu)'},
      ];
    }
  List<Map<String, dynamic>> _getN1Bai1LyThuyetData() {
      return [
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': '無礼', 'hiragana': 'ぶれい', 'romaji': 'burei', 'meaning': 'Vô lễ / Thất lễ'},
            {'kanji': '危険', 'hiragana': 'きけん', 'romaji': 'kiken', 'meaning': 'Nguy hiểm'},
            {'kanji': '記録', 'hiragana': 'きろく', 'romaji': 'kiroku', 'meaning': 'Kỷ lục'},
            {'kanji': '黒', 'hiragana': 'くろ', 'romaji': 'kuro', 'meaning': 'Màu đen'},
            {'kanji': '幸せ', 'hiragana': 'しあわせ', 'romaji': 'shiawase', 'meaning': 'Hạnh phúc'},
          ]
        },
        {
          'type': LessonType.flashCard, 'kanji': '無礼', 'hiragana': 'ぶれい', 'romaji': 'burei', 'meaning': 'Vô lễ',
          'example_img': 'assets/images/example_burei.png',
          'example_jp': '無礼な態度です。', 'example_rmj': 'Burei na taido desu.', 'example_vn': 'Đó là một thái độ vô lễ.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '記録', 'hiragana': 'きろく', 'romaji': 'kiroku', 'meaning': 'Kỷ lục',
          'example_img': 'assets/images/example_kiroku.png',
          'example_jp': '記録ずくめです。', 'example_rmj': 'Kiroku zukume desu.', 'example_vn': 'Toàn là kỷ lục mới.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '危険', 'hiragana': 'きけん', 'romaji': 'kiken', 'options': ['vô lễ', 'kỷ lục', 'nguy hiểm', 'màu đen'], 'answer': 'nguy hiểm'},
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'A(な) + 極まる / 極まりない', 'meaning': 'Cực kỳ... / Vô cùng... (Đạt đến giới hạn)'},
            {'title': 'N + ずくめ', 'meaning': 'Toàn là... (Sự việc, màu sắc)'},
          ]
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'CỰC HẠN (TIÊU CỰC)',
          'formula': 'Tính từ [な] (bỏ な) + 極まる (kiwamaru) / 極まりない (kiwamarinai)',
          'meaning': 'Vô cùng... / Hết sức...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜極まりない',
          'notes': [
            'Dùng trong văn viết, thể hiện sự việc đã đạt đến mức độ tận cùng, không thể hơn được nữa.',
            'Thường mang ý nghĩa đánh giá tiêu cực.',
            'Ví dụ: 危険極まりない (Nguy hiểm tột độ), 失礼極まりない (Hết sức thất lễ).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ 極まりない',
          'img': 'assets/images/example_kiwamarinai.png',
          'jp': '彼の態度は無礼極まりない。',
          'rmj': 'Kare no taido wa burei kiwamarinai.',
          'vn': 'Thái độ của anh ta vô cùng thất lễ.'
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'TOÀN LÀ...',
          'formula': 'Danh từ + ずくめ (zukume)',
          'meaning': 'Toàn là... / Toàn bộ là...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜ずくめ',
          'notes': [
            'Dùng để miêu tả một tình trạng mà xung quanh chỉ toàn là một thứ gì đó.',
            'Chỉ đi kèm với một số danh từ cố định: 黒 (đen), いいこと (chuyện tốt), 記録 (kỷ lục).',
            'Khác với だらけ (mang nghĩa bẩn thỉu), ずくめ có thể dùng cho chuyện vui.'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ ずくめ',
          'img': 'assets/images/example_zukume.png',
          'jp': '今年はいいことずくめの一年だった。',
          'rmj': 'Kotoshi wa ii koto zukume no ichinen datta.',
          'vn': 'Năm nay là một năm toàn những chuyện tốt lành.'
        },
        {
          'type': LessonType.vocabSummary,
          'words': [
            {'kanji': '無礼極まりない', 'romaji': 'burei kiwamarinai', 'meaning': 'hết sức vô lễ'},
            {'kanji': '危険極まりない', 'romaji': 'kiken kiwamarinai', 'meaning': 'cực kỳ nguy hiểm'},
            {'kanji': '黒ずくめ', 'romaji': 'kuro zukume', 'meaning': 'toàn màu đen'},
            {'kanji': '記録ずくめ', 'romaji': 'kiroku zukume', 'meaning': 'toàn là kỷ lục'},
          ]
        }
      ];
    }

    List<Map<String, dynamic>> _getN1Bai1LuyenTap1Data() {
      return [
        {
          'type': LessonType.imageQuiz,
          'question': 'Vô lễ.',
          'answerIndex': 0,
          'options': [
            {'img': 'assets/images/example_burei.png', 'jp': '無礼', 'rmj': 'burei'},
            {'img': 'assets/images/example_kiken.png', 'jp': '危険', 'rmj': 'kiken'},
            {'img': 'assets/images/example_kiroku.png', 'jp': '記録', 'rmj': 'kiroku'},
            {'img': 'assets/images/example_shiawase.png', 'jp': '幸せ', 'rmj': 'shiawase'},
          ]
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '彼の態度は無礼だ。',
          'rmj': 'Kare no taido wa burei da.',
          'audio_text': '彼の態度は無礼だ。',
          'words': ['thái độ', 'của anh ấy', 'vô lễ', 'nguy hiểm', 'kỷ lục'],
          'answer': 'thái độ của anh ấy vô lễ',
        },
      ];
    }

    List<Map<String, dynamic>> _getN1Bai1LuyenTap2Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền từ (Nguy hiểm tột độ): \n飲酒運転は危険 ( ... )。',
          'options': ['にすぎない', '極まりない', 'ずくめ', 'にあたって'],
          'answer': '極まりない'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': 'あの男の態度は、無礼極まる。',
          'words': ['あの男の', '態度', 'は', '無礼', '極まる', 'ずくめ'],
          'answer': 'あの男の 態度 は 無礼 極まる',
        },
      ];
    }

    List<Map<String, dynamic>> _getN1Bai1LuyenTap3Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền từ (Người đàn ông mặc toàn đồ đen): \n黒 ( ... ) の男が立っている。',
          'options': ['だらけ', 'ばかり', 'ずくめ', 'のみ'],
          'answer': 'ずくめ' // Màu sắc toàn bộ đi với zukume
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '今年はいいことずくめでした。',
          'words': ['今年', 'は', 'いいこと', 'ずくめ', 'でした', '極まる'],
          'answer': '今年 は いいこと ずくめ でした',
        },
      ];
    }

    List<Map<String, dynamic>> _getN1Bai1LuyenNoiData() {
      return [
        {'type': LessonType.speaking, 'jp': '態度は無礼極まりない。', 'answer': 'たいどはぶれいきわまりない'},
        {'type': LessonType.speaking, 'jp': '危険極まりない行為だ。', 'answer': 'きけんきわまりないこういだ'},
        {'type': LessonType.speaking, 'jp': '黒ずくめの男。', 'answer': 'くろずくめのおとこ'},
      ];
    }

    List<Map<String, dynamic>> _getN1Bai1LuyenVietData() {
      return [
        {'type': LessonType.kanjiDraw, 'kanji_word': '無礼', 'kanji_target': '無', 'meaning': 'Vô (Không có)', 'rmj': 'mu / na(i)'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '危険', 'kanji_target': '危', 'meaning': 'Nguy (Nguy hiểm)', 'rmj': 'ki / abu(nai)'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '記録', 'kanji_target': '録', 'meaning': 'Lục (Ghi chép / Kỷ lục)', 'rmj': 'roku'},
      ];
    }
  List<Map<String, dynamic>> _getN1Bai2LyThuyetData() {
      return [
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': '涙', 'hiragana': 'なみだ', 'romaji': 'namida', 'meaning': 'Nước mắt'},
            {'kanji': '同情', 'hiragana': 'どうじょう', 'romaji': 'doujou', 'meaning': 'Đồng tình / Thương cảm'},
            {'kanji': '辞任', 'hiragana': 'じにん', 'romaji': 'jinin', 'meaning': 'Từ chức'},
            {'kanji': '災害', 'hiragana': 'さいがい', 'romaji': 'saigai', 'meaning': 'Thảm họa'},
            {'kanji': '避難', 'hiragana': 'ひなん', 'romaji': 'hinan', 'meaning': 'Tị nạn / Lãnh nạn'},
          ]
        },
        {
          'type': LessonType.flashCard, 'kanji': '涙', 'hiragana': 'なみだ', 'romaji': 'namida', 'meaning': 'Nước mắt',
          'example_img': 'assets/images/example_namida.png',
          'example_jp': '涙が流れる。', 'example_rmj': 'Namida ga nagareru.', 'example_vn': 'Nước mắt tuôn rơi.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '辞任', 'hiragana': 'じにん', 'romaji': 'jinin', 'meaning': 'Từ chức',
          'example_img': 'assets/images/example_jinin.png',
          'example_jp': '社長が辞任した。', 'example_rmj': 'Shachou ga jinin shita.', 'example_vn': 'Giám đốc đã từ chức.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '災害', 'hiragana': 'さいがい', 'romaji': 'saigai', 'options': ['đồng tình', 'nước mắt', 'thảm họa', 'từ chức'], 'answer': 'thảm họa'},
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'N + を禁じ得ない', 'meaning': 'Không thể kìm nén được (Cảm xúc)'},
            {'title': 'N + を余儀なくされる', 'meaning': 'Bị buộc phải... (Tình thế bất khả kháng)'},
          ]
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'CẢM XÚC TRÀO DÂNG',
          'formula': 'Danh từ (chỉ cảm xúc) + を禁じ得ない (o kinjienai)',
          'meaning': 'Không thể kìm nén được...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜を禁じ得ない',
          'notes': [
            'Văn phong cực kỳ trang trọng, thường dùng trong văn viết.',
            'Đi kèm với các danh từ như: 涙 (Nước mắt), 同情 (Sự cảm thương), 怒り (Sự tức giận), 驚き (Sự kinh ngạc).',
            'Biểu đạt việc cảm xúc tự động trào ra, lý trí không ngăn lại được.'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ 禁じ得ない',
          'img': 'assets/images/example_kinjienai.png',
          'jp': '被害者の話を聞いて、涙を禁じ得なかった。',
          'rmj': 'Higaisha no hanashi o kiite, namida o kinjienakatta.',
          'vn': 'Nghe câu chuyện của nạn nhân, tôi đã không kìm được nước mắt.'
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'TÌNH THẾ BẮT BUỘC',
          'formula': 'Danh từ (chỉ hành động) + を余儀なくされる (o yoginaku sareru)',
          'meaning': 'Bị buộc phải... / Đành phải...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜を余儀なくされる',
          'notes': [
            'Vì hoàn cảnh nằm ngoài tầm kiểm soát (thảm họa, bão, dư luận) nên buộc phải đưa ra quyết định mà mình không muốn.',
            'Tương tự như ざるを得ない (N2) nhưng cấu trúc này chỉ đi với Danh từ.',
            'Ví dụ: 辞任 (Từ chức), 帰国 (Về nước), 中止 (Hủy bỏ).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ 余儀なくされる',
          'img': 'assets/images/example_yoginakusareru.png',
          'jp': '災害により、避難を余儀なくされた。',
          'rmj': 'Saigai ni yori, hinan o yoginaku sareta.',
          'vn': 'Do thảm họa, chúng tôi bị buộc phải đi tị nạn.'
        },
        {
          'type': LessonType.vocabSummary,
          'words': [
            {'kanji': '涙', 'romaji': 'namida', 'meaning': 'nước mắt'},
            {'kanji': '同情', 'romaji': 'doujou', 'meaning': 'đồng tình / thương cảm'},
            {'kanji': '辞任', 'romaji': 'jinin', 'meaning': 'từ chức'},
            {'kanji': '禁じ得ない', 'romaji': 'kinjienai', 'meaning': 'không kìm nén được'},
            {'kanji': '余儀なくされる', 'romaji': 'yoginaku sareru', 'meaning': 'bị buộc phải'},
          ]
        }
      ];
    }

    List<Map<String, dynamic>> _getN1Bai2LuyenTap1Data() {
      return [
        {
          'type': LessonType.imageQuiz,
          'question': 'Từ chức.',
          'answerIndex': 2,
          'options': [
            {'img': 'assets/images/example_namida.png', 'jp': '涙', 'rmj': 'namida'},
            {'img': 'assets/images/example_saigai.png', 'jp': '災害', 'rmj': 'saigai'},
            {'img': 'assets/images/example_jinin.png', 'jp': '辞任', 'rmj': 'jinin'},
            {'img': 'assets/images/example_doujou.png', 'jp': '同情', 'rmj': 'doujou'},
          ]
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '涙が流れる。',
          'rmj': 'Namida ga nagareru.',
          'audio_text': '涙が流れる。',
          'words': ['nước mắt', 'chảy', 'từ chức', 'thảm họa', 'kìm nén'],
          'answer': 'nước mắt chảy',
        },
      ];
    }

    List<Map<String, dynamic>> _getN1Bai2LuyenTap2Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền từ (Không kìm được sự thương cảm): \n同情 ( ... )。',
          'options': ['を禁じ得ない', 'を余儀なくされる', '極まりない', 'ずくめ'],
          'answer': 'を禁じ得ない'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '涙を禁じ得なかった。',
          'words': ['涙', 'を', '禁じ得なかった', '余儀なく', 'された'],
          'answer': '涙 を 禁じ得なかった',
        },
      ];
    }

    List<Map<String, dynamic>> _getN1Bai2LuyenTap3Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Giám đốc bị dư luận ép phải từ chức. Chọn cấu trúc:',
          'options': ['辞任を禁じ得ない', '辞任を余儀なくされた', '辞任極まる', '辞任ずくめ'],
          'answer': '辞任を余儀なくされた'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '避難を余儀なくされた。',
          'words': ['避難', 'を', '余儀なく', 'された', '禁じ得ない'],
          'answer': '避難 を 余儀なく された',
        },
      ];
    }

    List<Map<String, dynamic>> _getN1Bai2LuyenNoiData() {
      return [
        {'type': LessonType.speaking, 'jp': '涙を禁じ得ない。', 'answer': 'なみだをきんじえない'},
        {'type': LessonType.speaking, 'jp': '同情を禁じ得ない。', 'answer': 'どうじょうをきんじえない'},
        {'type': LessonType.speaking, 'jp': '辞任を余儀なくされた。', 'answer': 'じにんをよぎなくされた'},
      ];
    }

    List<Map<String, dynamic>> _getN1Bai2LuyenVietData() {
      return [
        {'type': LessonType.kanjiDraw, 'kanji_word': '涙', 'kanji_target': '涙', 'meaning': 'Lệ (Nước mắt)', 'rmj': 'namida / rui'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '辞任', 'kanji_target': '辞', 'meaning': 'Từ (Từ bỏ / Từ ngữ)', 'rmj': 'ji / ya(meru)'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '災害', 'kanji_target': '災', 'meaning': 'Tai (Tai họa)', 'rmj': 'sai / wazawa(i)'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '災害', 'kanji_target': '害', 'meaning': 'Hại (Tổn hại)', 'rmj': 'gai'},
      ];
    }
  List<Map<String, dynamic>> _getN1Bai3LyThuyetData() {
      return [
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': '感謝', 'hiragana': 'かんしゃ', 'romaji': 'kansha', 'meaning': 'Biết ơn / Cảm tạ'},
            {'kanji': '孤独', 'hiragana': 'こどく', 'romaji': 'kodoku', 'meaning': 'Cô độc'},
            {'kanji': '嬉しい', 'hiragana': 'うれしい', 'romaji': 'ureshii', 'meaning': 'Vui sướng'},
            {'kanji': '春', 'hiragana': 'はる', 'romaji': 'haru', 'meaning': 'Mùa xuân'},
            {'kanji': '寒い', 'hiragana': 'さむい', 'romaji': 'samui', 'meaning': 'Lạnh'},
          ]
        },
        {
          'type': LessonType.flashCard, 'kanji': '感謝', 'hiragana': 'かんしゃ', 'romaji': 'kansha', 'meaning': 'Biết ơn',
          'example_img': 'assets/images/example_kansha.png',
          'example_jp': '感謝の気持ちを伝える。', 'example_rmj': 'Kansha no kimochi o tsutaeru.', 'example_vn': 'Truyền đạt lòng biết ơn.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '孤独', 'hiragana': 'こどく', 'romaji': 'kodoku', 'meaning': 'Cô độc',
          'example_img': 'assets/images/example_kodoku.png',
          'example_jp': '孤独を感じる。', 'example_rmj': 'Kodoku o kanjiru.', 'example_vn': 'Cảm thấy cô độc.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '嬉しい', 'hiragana': 'うれしい', 'romaji': 'ureshii', 'options': ['cô độc', 'lạnh', 'biết ơn', 'vui sướng'], 'answer': 'vui sướng'},
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'Danh từ / Thể thông thường + とはいえ', 'meaning': 'Mặc dù nói là... nhưng...'},
            {'title': 'Tính từ + 限りだ', 'meaning': 'Cực kỳ... / Rất... (Cảm xúc tối đa)'},
          ]
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'NHƯỢNG BỘ (とはいえ)',
          'formula': 'Danh từ / Thể thông thường + とはいえ (to wa ie)',
          'meaning': 'Mặc dù nói là... nhưng sự thật lại...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜とはいえ',
          'notes': [
            'Dùng để công nhận một sự thật nào đó, nhưng ngay sau đó đưa ra một kết quả hoặc tình trạng trái ngược với suy nghĩ thông thường.',
            'Ví dụ: 春とはいえ (Mặc dù nói là mùa xuân rồi đấy, nhưng...).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ とはいえ',
          'img': 'assets/images/example_towaie.png',
          'jp': '春とはいえ、まだ寒い。',
          'rmj': 'Haru to wa ie, mada samui.',
          'vn': 'Mặc dù nói là mùa xuân rồi, nhưng trời vẫn còn lạnh.'
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'CẢM XÚC TỘT ĐỈNH',
          'formula': 'Tính từ [い] / Tính từ [な] + 限りだ (kagiri da)',
          'meaning': 'Cực kỳ... / Vô cùng...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜限りだ',
          'notes': [
            'Dùng để nhấn mạnh cảm xúc của người nói đang ở mức độ cao nhất, không thể hơn được nữa.',
            'Rất hay đi kèm với các tính từ chỉ cảm xúc: 嬉しい (vui sướng), 寂しい (buồn/cô đơn), 羨ましい (ghen tị).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ 限りだ',
          'img': 'assets/images/example_kagirida.png',
          'jp': '優勝できて、嬉しい限りだ。',
          'rmj': 'Yuushou dekite, ureshii kagiri da.',
          'vn': 'Có thể giành chức vô địch, tôi cực kỳ vui sướng.'
        },
        {
          'type': LessonType.vocabSummary,
          'words': [
            {'kanji': '感謝', 'romaji': 'kansha', 'meaning': 'biết ơn'},
            {'kanji': '孤独', 'romaji': 'kodoku', 'meaning': 'cô độc'},
            {'kanji': 'とはいえ', 'romaji': 'to wa ie', 'meaning': 'mặc dù nói là'},
            {'kanji': '限りだ', 'romaji': 'kagiri da', 'meaning': 'cực kỳ / vô cùng'},
          ]
        }
      ];
    }

    List<Map<String, dynamic>> _getN1Bai3LuyenTap1Data() {
      return [
        {
          'type': LessonType.imageQuiz,
          'question': 'Vui sướng.',
          'answerIndex': 2,
          'options': [
            {'img': 'assets/images/example_kansha.png', 'jp': '感謝', 'rmj': 'kansha'},
            {'img': 'assets/images/example_kodoku.png', 'jp': '孤独', 'rmj': 'kodoku'},
            {'img': 'assets/images/example_ureshii.png', 'jp': '嬉しい', 'rmj': 'ureshii'},
            {'img': 'assets/images/example_haru.png', 'jp': '春', 'rmj': 'haru'},
          ]
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '孤独を感じる。',
          'rmj': 'Kodoku o kanjiru.',
          'audio_text': '孤独を感じる。',
          'words': ['cảm thấy', 'cô độc', 'lạnh', 'vui sướng', 'mặc dù'],
          'answer': 'cảm thấy cô độc',
        },
      ];
    }

    List<Map<String, dynamic>> _getN1Bai3LuyenTap2Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền từ (Mặc dù nói là mùa xuân nhưng vẫn lạnh): \n春 ( ... )、まだ寒い。',
          'options': ['とはいえ', '限りだ', 'ずくめ', '極まりない'],
          'answer': 'とはいえ'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '日本人とはいえ、漢字が書けない人もいる。',
          'words': ['日本人', 'とはいえ', '漢字が', '書けない', '人もいる', '限りだ'],
          'answer': '日本人 とはいえ 漢字が 書けない 人もいる',
        },
      ];
    }

    List<Map<String, dynamic>> _getN1Bai3LuyenTap3Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Cấu trúc diễn tả cảm xúc ở mức độ tột đỉnh:',
          'options': ['限りだ', 'とはいえ', 'を禁じ得ない', 'にすぎない'],
          'answer': '限りだ'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '一人で生活するのは孤独な限りだ。',
          'words': ['一人で', '生活する', 'のは', '孤独な', '限りだ', 'とはいえ'],
          'answer': '一人で 生活する のは 孤独な 限りだ',
        },
      ];
    }

    List<Map<String, dynamic>> _getN1Bai3LuyenNoiData() {
      return [
        {'type': LessonType.speaking, 'jp': '春とはいえ、まだ寒い。', 'answer': 'はるとはいえまださむい'},
        {'type': LessonType.speaking, 'jp': '優勝できて嬉しい限りだ。', 'answer': 'ゆうしょうできてうれしいかぎりだ'},
        {'type': LessonType.speaking, 'jp': '孤独な限りだ。', 'answer': 'こどくなかぎりだ'},
      ];
    }

    List<Map<String, dynamic>> _getN1Bai3LuyenVietData() {
      return [
        {'type': LessonType.kanjiDraw, 'kanji_word': '感謝', 'kanji_target': '謝', 'meaning': 'Tạ (Cảm tạ / Xin lỗi)', 'rmj': 'sha / ayama(ru)'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '孤独', 'kanji_target': '孤', 'meaning': 'Cô (Cô đơn)', 'rmj': 'ko'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '孤独', 'kanji_target': '独', 'meaning': 'Độc (Độc lập / Một mình)', 'rmj': 'doku / hitori'},
      ];
    }
  List<Map<String, dynamic>> _getN1Bai4LyThuyetData() {
      return [
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': '天候', 'hiragana': 'てんこう', 'romaji': 'tenkou', 'meaning': 'Thời tiết / Khí hậu'},
            {'kanji': '出席', 'hiragana': 'しゅっせき', 'romaji': 'shusseki', 'meaning': 'Tham dự / Có mặt'},
            {'kanji': '傾向', 'hiragana': 'けいこう', 'romaji': 'keikou', 'meaning': 'Khuynh hướng / Xu hướng'},
            {'kanji': '怠ける', 'hiragana': 'なまける', 'romaji': 'namakeru', 'meaning': 'Lười biếng'},
            {'kanji': '批判', 'hiragana': 'ひはん', 'romaji': 'hihan', 'meaning': 'Phê phán / Chỉ trích'},
          ]
        },
        {
          'type': LessonType.flashCard, 'kanji': '天候', 'hiragana': 'てんこう', 'romaji': 'tenkou', 'meaning': 'Thời tiết',
          'example_img': 'assets/images/example_tenkou.png',
          'example_jp': '天候に恵まれる。', 'example_rmj': 'Tenkou ni megumareru.', 'example_vn': 'Được thời tiết ưu ái.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '怠ける', 'hiragana': 'なまける', 'romaji': 'namakeru', 'meaning': 'Lười biếng',
          'example_img': 'assets/images/example_namakeru.png',
          'example_jp': '仕事を怠ける。', 'example_rmj': 'Shigoto o namakeru.', 'example_vn': 'Lười biếng trong công việc.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '批判', 'hiragana': 'ひはん', 'romaji': 'hihan', 'options': ['thời tiết', 'tham dự', 'lười biếng', 'phê phán'], 'answer': 'phê phán'},
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'Danh từ + にかかわらず', 'meaning': 'Bất kể... / Không liên quan đến...'},
            {'title': 'V(ru) / N(の) + きらいがある', 'meaning': 'Có khuynh hướng... (Thường là thói quen xấu)'},
          ]
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'SỰ KHÔNG LIÊN QUAN',
          'formula': 'Danh từ + にかかわらず (ni kakawarazu)',
          'meaning': 'Bất kể... / Bất chấp...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜にかかわらず',
          'notes': [
            'Thường đi kèm với các danh từ mang tính đối lập (晴雨 - nắng mưa, 男女 - nam nữ, 有無 - có không) hoặc các từ chỉ mức độ rộng (天候 - thời tiết, 年齢 - tuổi tác).',
            'Biểu thị việc hành động vế sau vẫn diễn ra mà không bị ảnh hưởng bởi vế trước.'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ にかかわらず',
          'img': 'assets/images/example_nikakawarazu.png',
          'jp': '天候にかかわらず、試合を行います。',
          'rmj': 'Tenkou ni kakawarazu, shiai o okonaimasu.',
          'vn': 'Bất kể thời tiết thế nào, trận đấu vẫn sẽ được tiến hành.'
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'KHUYNH HƯỚNG TIÊU CỰC',
          'formula': 'Động từ (thể từ điển) / Danh từ (の) + きらいがある',
          'meaning': 'Có tật... / Có khuynh hướng...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜きらいがある',
          'notes': [
            'Dùng để phê phán, chỉ trích một thói quen xấu hoặc một khuynh hướng tiêu cực thường xuyên lặp lại của ai đó.',
            'Không dùng để nói về khuynh hướng tích cực.'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ きらいがある',
          'img': 'assets/images/example_kiraigaaru.png',
          'jp': '彼は怠けるきらいがある。',
          'rmj': 'Kare wa namakeru kirai ga aru.',
          'vn': 'Anh ta có tật hay lười biếng.'
        },
        {
          'type': LessonType.vocabSummary,
          'words': [
            {'kanji': '天候', 'romaji': 'tenkou', 'meaning': 'thời tiết'},
            {'kanji': '怠ける', 'romaji': 'namakeru', 'meaning': 'lười biếng'},
            {'kanji': 'にかかわらず', 'romaji': 'ni kakawarazu', 'meaning': 'bất kể'},
            {'kanji': 'きらいがある', 'romaji': 'kirai ga aru', 'meaning': 'có khuynh hướng (xấu)'},
          ]
        }
      ];
    }

    List<Map<String, dynamic>> _getN1Bai4LuyenTap1Data() {
      return [
        {
          'type': LessonType.imageQuiz,
          'question': 'Lười biếng.',
          'answerIndex': 3,
          'options': [
            {'img': 'assets/images/example_tenkou.png', 'jp': '天候', 'rmj': 'tenkou'},
            {'img': 'assets/images/example_shusseki.png', 'jp': '出席', 'rmj': 'shusseki'},
            {'img': 'assets/images/example_hihan.png', 'jp': '批判', 'rmj': 'hihan'},
            {'img': 'assets/images/example_namakeru.png', 'jp': '怠ける', 'rmj': 'namakeru'},
          ]
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '仕事を怠ける。',
          'rmj': 'Shigoto o namakeru.',
          'audio_text': '仕事を怠ける。',
          'words': ['công việc', 'lười biếng', 'thời tiết', 'trong', 'phê phán'],
          'answer': 'lười biếng trong công việc',
        },
      ];
    }

    List<Map<String, dynamic>> _getN1Bai4LuyenTap2Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền từ (Bất kể nam nữ đều có thể tham gia): \n男女 ( ... ) 参加できる。',
          'options': ['にかかわらず', 'きらいがある', 'とはいえ', '限りだ'],
          'answer': 'にかかわらず'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '天候にかかわらず、出発します。',
          'words': ['天候', 'に', 'かかわらず', '出発', 'します', 'きらいがある'],
          'answer': '天候 に かかわらず 出発 します',
        },
      ];
    }

    List<Map<String, dynamic>> _getN1Bai4LuyenTap3Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Cấu trúc chỉ một "tật xấu" hay một "khuynh hướng tiêu cực":',
          'options': ['きらいがある', 'にかかわらず', 'にすぎない', 'ずくめ'],
          'answer': 'きらいがある'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '彼は怠けるきらいがある。',
          'words': ['彼', 'は', '怠ける', 'きらいが', 'ある', 'かかわらず'],
          'answer': '彼 は 怠ける きらいが ある',
        },
      ];
    }

    List<Map<String, dynamic>> _getN1Bai4LuyenNoiData() {
      return [
        {'type': LessonType.speaking, 'jp': '天候にかかわらず、試合を行います。', 'answer': 'てんこうにかかわらずしあいをおこないます'},
        {'type': LessonType.speaking, 'jp': '彼は怠けるきらいがある。', 'answer': 'かれはなまけるきらいがある'},
        {'type': LessonType.speaking, 'jp': '男女にかかわらず参加できます。', 'answer': 'だんじょにかかわらずさんかできます'},
      ];
    }

    List<Map<String, dynamic>> _getN1Bai4LuyenVietData() {
      return [
        {'type': LessonType.kanjiDraw, 'kanji_word': '天候', 'kanji_target': '候', 'meaning': 'Hậu (Khí hậu / Thời tiết)', 'rmj': 'kou'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '怠ける', 'kanji_target': '怠', 'meaning': 'Đãi (Lười biếng / Lơ đễnh)', 'rmj': 'nama(keru) / tai'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '批判', 'kanji_target': '批', 'meaning': 'Phê (Phê bình)', 'rmj': 'hi'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '批判', 'kanji_target': '判', 'meaning': 'Phán (Phán đoán / Đánh giá)', 'rmj': 'han / ban'},
      ];
    }
  List<Map<String, dynamic>> _getN1Bai5LyThuyetData() {
      return [
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': '散歩', 'hiragana': 'さんぽ', 'romaji': 'sanpo', 'meaning': 'Tản bộ / Đi dạo'},
            {'kanji': '挨拶', 'hiragana': 'あいさつ', 'romaji': 'aisatsu', 'meaning': 'Chào hỏi'},
            {'kanji': '報告', 'hiragana': 'ほうこく', 'romaji': 'houkoku', 'meaning': 'Báo cáo'},
            {'kanji': 'お見舞い', 'hiragana': 'おみまい', 'romaji': 'omimai', 'meaning': 'Thăm bệnh'},
            {'kanji': '兼ねて', 'hiragana': 'かねて', 'romaji': 'kanete', 'meaning': 'Kết hợp'},
          ]
        },
        {
          'type': LessonType.flashCard, 'kanji': '散歩', 'hiragana': 'さんぽ', 'romaji': 'sanpo', 'meaning': 'Đi dạo',
          'example_img': 'assets/images/example_sanpo.png',
          'example_jp': '公園を散歩する。', 'example_rmj': 'Kouen o sanpo suru.', 'example_vn': 'Đi dạo công viên.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '報告', 'hiragana': 'ほうこく', 'romaji': 'houkoku', 'meaning': 'Báo cáo',
          'example_img': 'assets/images/example_houkoku.png',
          'example_jp': '結果を報告します。', 'example_rmj': 'Kekka o houkoku shimasu.', 'example_vn': 'Báo cáo kết quả.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': 'お見舞い', 'hiragana': 'おみまい', 'romaji': 'omimai', 'options': ['chào hỏi', 'đi dạo', 'thăm bệnh', 'báo cáo'], 'answer': 'thăm bệnh'},
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'V(bỏ ます) / N + がてら', 'meaning': 'Nhân tiện... thì (Văn nói/viết chung)'},
            {'title': 'N + かたがた', 'meaning': 'Nhân tiện... (Văn phong vô cùng trang trọng)'},
          ]
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'NHÂN TIỆN (THÔNG DỤNG)',
          'formula': 'Động từ (bỏ ます) / Danh từ hành động + がてら',
          'meaning': 'Nhân tiện làm A thì kết hợp làm B'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜がてら',
          'notes': [
            'Dùng để biểu thị việc mượn cơ hội làm việc A để kết hợp làm luôn việc B.',
            'Hành động A là mục đích chính, B là hành động phụ đi kèm.',
            'Ví dụ: 散歩がてら (Nhân tiện đi dạo thì...).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ がてら',
          'img': 'assets/images/example_gatera.png',
          'jp': '散歩がてら、パンを買ってきた。',
          'rmj': 'Sanpo gatera, pan o katte kita.',
          'vn': 'Nhân tiện đi dạo, tôi đã mua bánh mì về.'
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'NHÂN TIỆN (TRANG TRỌNG)',
          'formula': 'Danh từ (chỉ hành động) + かたがた (katagata)',
          'meaning': 'Nhân dịp / Nhân tiện...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜かたがた',
          'notes': [
            'Ý nghĩa giống hệt がてら nhưng dùng trong môi trường kinh doanh (Business), viết thư, hoặc nói chuyện với đối tác.',
            'Thường chỉ đi kèm với một số danh từ như: 挨拶 (Chào hỏi), 報告 (Báo cáo), お見舞い (Thăm bệnh).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ かたがた',
          'img': 'assets/images/example_katagata.png',
          'jp': 'ご挨拶かたがた、お伺いしました。',
          'rmj': 'Go-aisatsu katagata, o-ukagai shimashita.',
          'vn': 'Nhân tiện đến chào hỏi, tôi xin phép ghé thăm văn phòng ngài.'
        },
        {
          'type': LessonType.vocabSummary,
          'words': [
            {'kanji': '散歩がてら', 'romaji': 'sanpo gatera', 'meaning': 'nhân tiện đi dạo'},
            {'kanji': '挨拶かたがた', 'romaji': 'aisatsu katagata', 'meaning': 'nhân tiện chào hỏi'},
            {'kanji': '報告', 'romaji': 'houkoku', 'meaning': 'báo cáo'},
            {'kanji': 'お見舞い', 'romaji': 'omimai', 'meaning': 'thăm bệnh'},
          ]
        }
      ];
    }

    List<Map<String, dynamic>> _getN1Bai5LuyenTap1Data() {
      return [
        {
          'type': LessonType.imageQuiz,
          'question': 'Báo cáo.',
          'answerIndex': 2,
          'options': [
            {'img': 'assets/images/example_sanpo.png', 'jp': '散歩', 'rmj': 'sanpo'},
            {'img': 'assets/images/example_aisatsu.png', 'jp': '挨拶', 'rmj': 'aisatsu'},
            {'img': 'assets/images/example_houkoku.png', 'jp': '報告', 'rmj': 'houkoku'},
            {'img': 'assets/images/example_omimai.png', 'jp': 'お見舞い', 'rmj': 'omimai'},
          ]
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '結果を報告します。',
          'rmj': 'Kekka o houkoku shimasu.',
          'audio_text': '結果を報告します。',
          'words': ['kết quả', 'báo cáo', 'chào hỏi', 'nhân tiện', 'của'],
          'answer': 'báo cáo kết quả',
        },
      ];
    }

    List<Map<String, dynamic>> _getN1Bai5LuyenTap2Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền từ (Nhân tiện đi dạo thì mua đồ): \n散歩 ( ... )、買い物をする。',
          'options': ['かたがた', 'がてら', '極まる', 'ずくめ'],
          'answer': 'がてら'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '散歩がてら、パンを買ってきた。',
          'words': ['散歩', 'がてら', 'パン', 'を', '買って', 'きた', 'かたがた'],
          'answer': '散歩 がてら パン を 買って きた',
        },
      ];
    }

    List<Map<String, dynamic>> _getN1Bai5LuyenTap3Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Cấu trúc "Nhân tiện" nào mang tính chất TRANG TRỌNG (Business) nhất?',
          'options': ['ついでに', 'がてら', 'かたがた', 'ながら'],
          'answer': 'かたがた'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': 'ご挨拶かたがた、伺いました。',
          'words': ['ご挨拶', 'かたがた', '伺いました', 'がてら', '報告'],
          'answer': 'ご挨拶 かたがた 伺いました',
        },
      ];
    }

    List<Map<String, dynamic>> _getN1Bai5LuyenNoiData() {
      return [
        {'type': LessonType.speaking, 'jp': '散歩がてら買い物をする。', 'answer': 'さんぽがてらかいものをすること'},
        {'type': LessonType.speaking, 'jp': 'ご挨拶かたがた、伺いました。', 'answer': 'ごあいさつかたがたうかがいました'},
        {'type': LessonType.speaking, 'jp': '報告かたがたお会いしたいです。', 'answer': 'ほうこくかたがたおあいしたいです'},
      ];
    }

    List<Map<String, dynamic>> _getN1Bai5LuyenVietData() {
      return [
        {'type': LessonType.kanjiDraw, 'kanji_word': '散歩', 'kanji_target': '散', 'meaning': 'Tản (Tản mạn / Phân tán)', 'rmj': 'chi(ru) / san'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '挨拶', 'kanji_target': '挨', 'meaning': 'Ai (Chào hỏi)', 'rmj': 'ai'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '挨拶', 'kanji_target': '拶', 'meaning': 'Tạt (Chào hỏi)', 'rmj': 'satsu'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '報告', 'kanji_target': '報', 'meaning': 'Báo (Báo cáo / Báo đáp)', 'rmj': 'muku(iru) / hou'},
      ];
    }
  List<Map<String, dynamic>> _getN1Bai6LyThuyetData() {
      return [
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': '限界', 'hiragana': 'げんかい', 'romaji': 'genkai', 'meaning': 'Giới hạn'},
            {'kanji': '辞める', 'hiragana': 'やめる', 'romaji': 'yameru', 'meaning': 'Nghỉ việc / Bỏ'},
            {'kanji': '影響', 'hiragana': 'えいきょう', 'romaji': 'eikyou', 'meaning': 'Ảnh hưởng'},
            {'kanji': '頭', 'hiragana': 'あたま', 'romaji': 'atama', 'meaning': 'Đầu'},
            {'kanji': 'つま先', 'hiragana': 'つまさき', 'romaji': 'tsumasaki', 'meaning': 'Đầu ngón chân'},
          ]
        },
        {
          'type': LessonType.flashCard, 'kanji': '限界', 'hiragana': 'げんかい', 'romaji': 'genkai', 'meaning': 'Giới hạn',
          'example_img': 'assets/images/example_genkai.png',
          'example_jp': '体力の限界です。', 'example_rmj': 'Tairyoku no genkai desu.', 'example_vn': 'Đã đến giới hạn của thể lực.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '影響', 'hiragana': 'えいきょう', 'romaji': 'eikyou', 'meaning': 'Ảnh hưởng',
          'example_img': 'assets/images/example_eikyou.png',
          'example_jp': '影響を与える。', 'example_rmj': 'Eikyou o ataeru.', 'example_vn': 'Gây ảnh hưởng.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': 'つま先', 'hiragana': 'つまさき', 'romaji': 'tsumasaki', 'options': ['giới hạn', 'ảnh hưởng', 'đầu ngón chân', 'nghỉ việc'], 'answer': 'đầu ngón chân'},
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'N(thời gian) + を限りに', 'meaning': 'Đến hết... (Làm mốc kết thúc)'},
            {'title': 'N + に至るまで', 'meaning': 'Đến tận... (Phạm vi lan rộng)'},
          ]
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'MỐC KẾT THÚC',
          'formula': 'Danh từ (chỉ thời gian) + を限りに (o kagiri ni)',
          'meaning': 'Đến hết... / Lấy... làm giới hạn'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜を限りに',
          'notes': [
            'Dùng để tuyên bố chấm dứt một việc gì đó đang tiếp diễn. Lấy thời điểm đó làm giới hạn cuối cùng.',
            'Thường đi với các từ: 今日 (hôm nay), 今回 (lần này), 本年度 (năm nay).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ を限りに',
          'img': 'assets/images/example_okagirini.png',
          'jp': '今日を限りに、タバコを辞めます。',
          'rmj': 'Kyou o kagiri ni, tabako o yamemasu.',
          'vn': 'Đến hết hôm nay, tôi sẽ bỏ thuốc lá.'
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'PHẠM VI ĐẾN TẬN CÙNG',
          'formula': 'Danh từ + に至るまで (ni itaru made)',
          'meaning': 'Đến tận... / Thậm chí cả...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜に至るまで',
          'notes': [
            'Nhấn mạnh mức độ, phạm vi lan rộng đến mức những thứ tưởng chừng nhỏ bé/xa xôi nhất cũng bị ảnh hưởng.',
            'Nghĩa tương tự như "まで" nhưng trang trọng và mức độ bao trùm mạnh hơn rất nhiều.'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ に至るまで',
          'img': 'assets/images/example_niitarumade.png',
          'jp': '頭からつま先に至るまで、泥だらけだ。',
          'rmj': 'Atama kara tsumasaki ni itaru made, doro darake da.',
          'vn': 'Từ đầu đến tận ngón chân toàn là bùn.'
        },
        {
          'type': LessonType.vocabSummary,
          'words': [
            {'kanji': '限界', 'romaji': 'genkai', 'meaning': 'giới hạn'},
            {'kanji': '影響', 'romaji': 'eikyou', 'meaning': 'ảnh hưởng'},
            {'kanji': 'を限りに', 'romaji': 'o kagiri ni', 'meaning': 'đến hết (thời gian)'},
            {'kanji': 'に至るまで', 'romaji': 'ni itaru made', 'meaning': 'đến tận'},
          ]
        }
      ];
    }

    List<Map<String, dynamic>> _getN1Bai6LuyenTap1Data() {
      return [
        {
          'type': LessonType.imageQuiz,
          'question': 'Ảnh hưởng.',
          'answerIndex': 1,
          'options': [
            {'img': 'assets/images/example_genkai.png', 'jp': '限界', 'rmj': 'genkai'},
            {'img': 'assets/images/example_eikyou.png', 'jp': '影響', 'rmj': 'eikyou'},
            {'img': 'assets/images/example_atama.png', 'jp': '頭', 'rmj': 'atama'},
            {'img': 'assets/images/example_tsumasaki.png', 'jp': 'つま先', 'rmj': 'tsumasaki'},
          ]
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '影響を与える。',
          'rmj': 'Eikyou o ataeru.',
          'audio_text': '影響を与える。',
          'words': ['gây', 'ảnh hưởng', 'đến tận', 'nghỉ việc', 'cho'],
          'answer': 'gây ảnh hưởng',
        },
      ];
    }

    List<Map<String, dynamic>> _getN1Bai6LuyenTap2Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền từ (Đến hết hôm nay thì bỏ thuốc): \n今日 ( ... ) タバコを辞める。',
          'options': ['を限りに', 'に至るまで', 'がてら', 'かたがた'],
          'answer': 'を限りに'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '今日を限りに、会社を辞めます。',
          'words': ['今日', 'を', '限りに', '会社', 'を', '辞めます', '至るまで'],
          'answer': '今日 を 限りに 会社 を 辞めます',
        },
      ];
    }

    List<Map<String, dynamic>> _getN1Bai6LuyenTap3Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền từ (Lan rộng đến tận ngón chân): \nつま先 ( ... ) 泥だらけだ。',
          'options': ['に至るまで', 'を限りに', '極まりない', 'ずくめ'],
          'answer': 'に至るまで'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '頭からつま先に至るまで。',
          'words': ['頭', 'から', 'つま先', 'に', '至るまで', '限りに'],
          'answer': '頭 から つま先 に 至るまで',
        },
      ];
    }

    List<Map<String, dynamic>> _getN1Bai6LuyenNoiData() {
      return [
        {'type': LessonType.speaking, 'jp': '今日を限りに辞めます。', 'answer': 'きょうをかぎりにやめます'},
        {'type': LessonType.speaking, 'jp': '今年を限りに引退します。', 'answer': 'ことしをかぎりにいんたいします'},
        {'type': LessonType.speaking, 'jp': 'つま先に至るまで。', 'answer': 'つまさきにいたるまで'},
      ];
    }

    List<Map<String, dynamic>> _getN1Bai6LuyenVietData() {
      return [
        {'type': LessonType.kanjiDraw, 'kanji_word': '限界', 'kanji_target': '限', 'meaning': 'Hạn (Giới hạn / Hạn chế)', 'rmj': 'kagi(ru) / gen'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '限界', 'kanji_target': '界', 'meaning': 'Giới (Thế giới / Ranh giới)', 'rmj': 'kai'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '影響', 'kanji_target': '影', 'meaning': 'Ảnh (Cái bóng / Ảnh hưởng)', 'rmj': 'kage / ei'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '影響', 'kanji_target': '響', 'meaning': 'Hưởng (Âm vang / Ảnh hưởng)', 'rmj': 'hibi(ku) / kyou'},
      ];
    }
  List<Map<String, dynamic>> _getN1Bai7LyThuyetData() {
      return [
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': '貧しさ', 'hiragana': 'まずしさ', 'romaji': 'mazushisa', 'meaning': 'Sự nghèo đói'},
            {'kanji': '犯罪', 'hiragana': 'はんざい', 'romaji': 'hanzai', 'meaning': 'Tội phạm / Tội ác'},
            {'kanji': '罰', 'hiragana': 'ばつ', 'romaji': 'batsu', 'meaning': 'Hình phạt'},
            {'kanji': '優秀', 'hiragana': 'ゆうしゅう', 'romaji': 'yuushuu', 'meaning': 'Xuất sắc / Ưu tú'},
            {'kanji': '当然', 'hiragana': 'とうぜん', 'romaji': 'touzen', 'meaning': 'Đương nhiên'},
          ]
        },
        {
          'type': LessonType.flashCard, 'kanji': '犯罪', 'hiragana': 'はんざい', 'romaji': 'hanzai', 'meaning': 'Tội phạm',
          'example_img': 'assets/images/example_hanzai.png',
          'example_jp': '犯罪を犯す。', 'example_rmj': 'Hanzai o okasu.', 'example_vn': 'Phạm tội.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '罰', 'hiragana': 'ばつ', 'romaji': 'batsu', 'meaning': 'Hình phạt',
          'example_img': 'assets/images/example_batsu.png',
          'example_jp': '罰を受ける。', 'example_rmj': 'Batsu o ukeru.', 'example_vn': 'Chịu phạt.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '優秀', 'hiragana': 'ゆうしゅう', 'romaji': 'yuushuu', 'options': ['đương nhiên', 'tội phạm', 'xuất sắc', 'hình phạt'], 'answer': 'xuất sắc'},
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'N (の) / V + ゆえ（に）', 'meaning': 'Do / Vì... (Văn phong cổ, học thuật)'},
            {'title': 'V(て) + しかるべきだ', 'meaning': 'Đáng lẽ phải / Làm thế là đương nhiên'},
          ]
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'NGUYÊN NHÂN (TRANG TRỌNG)',
          'formula': 'Danh từ (の) / Thể thông thường + ゆえ（に） (yue ni)',
          'meaning': 'Do... / Vì... / Bởi vì...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜ゆえに',
          'notes': [
            'Giống với 「〜から / 〜ため」 nhưng mang sắc thái văn viết rất trang trọng, có tính hơi cổ.',
            'Thường dùng trong các bài diễn văn, báo cáo, văn học.',
            'Tính từ [な] giữ nguyên [な] hoặc [である].'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ ゆえに',
          'img': 'assets/images/example_yueni.png',
          'jp': '貧しさゆえに、犯罪を犯した。',
          'rmj': 'Mazushisa yue ni, hanzai o okashita.',
          'vn': 'Chỉ VÌ sự nghèo đói mà đã phạm tội.'
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'LẼ ĐƯƠNG NHIÊN',
          'formula': 'Động từ (thể て) + しかるべきだ (shikarubeki da)',
          'meaning': 'Đáng lẽ phải... / Làm thế là chuyện đương nhiên'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜てしかるべきだ',
          'notes': [
            'Dùng để đưa ra nhận định mạnh mẽ rằng việc ai đó làm một hành động hoặc chịu một kết quả là hoàn toàn hợp lý, đương nhiên.',
            'Thường mang ý trách móc khi thực tế không diễn ra như thế.'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ てしかるべきだ',
          'img': 'assets/images/example_shikarubeki.png',
          'jp': '彼は罰を受けてしかるべきだ。',
          'rmj': 'Kare wa batsu o ukete shikarubeki da.',
          'vn': 'Anh ta phải chịu phạt là ĐIỀU ĐƯƠNG NHIÊN.'
        },
        {
          'type': LessonType.vocabSummary,
          'words': [
            {'kanji': '貧しさ', 'romaji': 'mazushisa', 'meaning': 'sự nghèo đói'},
            {'kanji': '犯罪', 'romaji': 'hanzai', 'meaning': 'tội phạm'},
            {'kanji': 'ゆえに', 'romaji': 'yue ni', 'meaning': 'vì / do (trang trọng)'},
            {'kanji': 'てしかるべきだ', 'romaji': 'te shikarubeki da', 'meaning': 'làm thế là đương nhiên'},
          ]
        }
      ];
    }

    List<Map<String, dynamic>> _getN1Bai7LuyenTap1Data() {
      return [
        {
          'type': LessonType.imageQuiz,
          'question': 'Hình phạt.',
          'answerIndex': 2,
          'options': [
            {'img': 'assets/images/example_mazushisa.png', 'jp': '貧しさ', 'rmj': 'mazushisa'},
            {'img': 'assets/images/example_hanzai.png', 'jp': '犯罪', 'rmj': 'hanzai'},
            {'img': 'assets/images/example_batsu.png', 'jp': '罰', 'rmj': 'batsu'},
            {'img': 'assets/images/example_yuushuu.png', 'jp': '優秀', 'rmj': 'yuushuu'},
          ]
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '罰を受ける。',
          'rmj': 'Batsu o ukeru.',
          'audio_text': '罰を受ける。',
          'words': ['chịu', 'hình phạt', 'xuất sắc', 'phạm tội', 'vì'],
          'answer': 'chịu hình phạt',
        },
      ];
    }

    List<Map<String, dynamic>> _getN1Bai7LuyenTap2Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền từ (Vì quá xuất sắc nên bị ghen tị): \n優秀である ( ... )、嫉妬される。',
          'options': ['がてら', 'ゆえに', 'に至るまで', 'ずくめ'],
          'answer': 'ゆえに'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '貧しさゆえに、犯罪を犯した。',
          'words': ['貧しさ', 'ゆえに', '犯罪', 'を', '犯した', '限りに'],
          'answer': '貧しさ ゆえに 犯罪 を 犯した',
        },
      ];
    }

    List<Map<String, dynamic>> _getN1Bai7LuyenTap3Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền từ (Thắng là chuyện đương nhiên): \n勝って ( ... )。',
          'options': ['しかるべきだ', '極まりない', 'にすぎない', 'ゆえに'],
          'answer': 'しかるべきだ'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '彼は罰を受けてしかるべきだ。',
          'words': ['彼', 'は', '罰', 'を', '受けて', 'しかるべきだ'],
          'answer': '彼 は 罰 を 受けて しかるべきだ',
        },
      ];
    }

    List<Map<String, dynamic>> _getN1Bai7LuyenNoiData() {
      return [
        {'type': LessonType.speaking, 'jp': '貧しさゆえに。', 'answer': 'まずしさゆえに'},
        {'type': LessonType.speaking, 'jp': '罰を受けてしかるべきだ。', 'answer': 'ばつをうけてしかるべきだ'},
        {'type': LessonType.speaking, 'jp': '優秀であるゆえに。', 'answer': 'ゆうしゅうであるゆえに'},
      ];
    }

    List<Map<String, dynamic>> _getN1Bai7LuyenVietData() {
      return [
        {'type': LessonType.kanjiDraw, 'kanji_word': '貧しさ', 'kanji_target': '貧', 'meaning': 'Bần (Nghèo đói)', 'rmj': 'mazu(shii) / hin'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '犯罪', 'kanji_target': '罪', 'meaning': 'Tội (Tội ác / Tội lỗi)', 'rmj': 'tsumi / zai'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '罰', 'kanji_target': '罰', 'meaning': 'Phạt (Hình phạt)', 'rmj': 'batsu'},
      ];
    }
  List<Map<String, dynamic>> _getN1Bai8LyThuyetData() {
      return [
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': '命', 'hiragana': 'いのち', 'romaji': 'inochi', 'meaning': 'Sinh mệnh / Mạng sống'},
            {'kanji': '恐れる', 'hiragana': 'おそれる', 'romaji': 'osoreru', 'meaning': 'Sợ hãi / E sợ'},
            {'kanji': '信頼', 'hiragana': 'しんらい', 'romaji': 'shinrai', 'meaning': 'Sự tin cậy / Tín nhiệm'},
            {'kanji': '推薦', 'hiragana': 'すいせん', 'romaji': 'suisen', 'meaning': 'Tiến cử / Giới thiệu'},
            {'kanji': '人物', 'hiragana': 'じんぶつ', 'romaji': 'jinbutsu', 'meaning': 'Nhân vật / Con người'},
          ]
        },
        {
          'type': LessonType.flashCard, 'kanji': '命', 'hiragana': 'いのち', 'romaji': 'inochi', 'meaning': 'Mạng sống',
          'example_img': 'assets/images/example_inochi.png',
          'example_jp': '命を大切にする。', 'example_rmj': 'Inochi o taisetsu ni suru.', 'example_vn': 'Trân trọng mạng sống.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '信頼', 'hiragana': 'しんらい', 'romaji': 'shinrai', 'meaning': 'Tin cậy',
          'example_img': 'assets/images/example_shinrai.png',
          'example_jp': '彼を信頼している。', 'example_rmj': 'Kare o shinrai shite iru.', 'example_vn': 'Tôi tin cậy anh ấy.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '恐れる', 'hiragana': 'おそれる', 'romaji': 'osoreru', 'options': ['tiến cử', 'tin cậy', 'mạng sống', 'sợ hãi'], 'answer': 'sợ hãi'},
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'N / V(ru) + とあれば', 'meaning': 'Nếu là (vì) ... thì đành chịu (chấp nhận)'},
            {'title': 'V(ru) / N + に足る', 'meaning': 'Xứng đáng để / Đáng để...'},
          ]
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'GIẢ ĐỊNH TỘT ĐỘ',
          'formula': 'Danh từ / Động từ (thể thông thường) + とあれば (to areba)',
          'meaning': 'Nếu là vì... thì (có làm gì cũng chịu)'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜とあれば',
          'notes': [
            'Dùng để đưa ra một điều kiện đặc biệt. Nếu điều kiện đó xảy ra thì người nói sẵn sàng làm những việc phi thường hoặc bất đắc dĩ phải chấp nhận.',
            'Ví dụ: Nếu là vì con cái thì việc gì tôi cũng làm.'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ とあれば',
          'img': 'assets/images/example_toareba.png',
          'jp': '家族のためとあれば、命も恐れない。',
          'rmj': 'Kazoku no tame to areba, inochi mo osorenai.',
          'vn': 'NẾU LÀ VÌ gia đình, mạng sống tôi cũng không sợ (đánh đổi).'
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'ĐÁNH GIÁ GIÁ TRỊ',
          'formula': 'Động từ (từ điển) / Danh từ (hành động) + に足る (ni taru)',
          'meaning': 'Đáng để... / Xứng đáng...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜に足る',
          'notes': [
            'Dùng để đánh giá một người hay sự vật có đủ giá trị, tư cách để nhận được một hành động nào đó.',
            'Thường đi kèm với: 信頼に足る (đáng tin), 推薦に足る (đáng để tiến cử).',
            'Phủ định là: に足らない (Không đáng để...).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ に足る',
          'img': 'assets/images/example_nitaru.png',
          'jp': '彼は信頼に足る人物だ。',
          'rmj': 'Kare wa shinrai ni taru jinbutsu da.',
          'vn': 'Anh ấy là một nhân vật ĐÁNG ĐỂ tin cậy.'
        },
        {
          'type': LessonType.vocabSummary,
          'words': [
            {'kanji': '命', 'romaji': 'inochi', 'meaning': 'mạng sống'},
            {'kanji': '信頼', 'romaji': 'shinrai', 'meaning': 'sự tin cậy'},
            {'kanji': '推薦', 'romaji': 'suisen', 'meaning': 'tiến cử'},
            {'kanji': 'とあれば', 'romaji': 'to areba', 'meaning': 'nếu là vì...'},
            {'kanji': 'に足る', 'romaji': 'ni taru', 'meaning': 'đáng để'},
          ]
        }
      ];
    }

    List<Map<String, dynamic>> _getN1Bai8LuyenTap1Data() {
      return [
        {
          'type': LessonType.imageQuiz,
          'question': 'Sợ hãi.',
          'answerIndex': 0,
          'options': [
            {'img': 'assets/images/example_osoreru.png', 'jp': '恐れる', 'rmj': 'osoreru'},
            {'img': 'assets/images/example_shinrai.png', 'jp': '信頼', 'rmj': 'shinrai'},
            {'img': 'assets/images/example_suisen.png', 'jp': '推薦', 'rmj': 'suisen'},
            {'img': 'assets/images/example_inochi.png', 'jp': '命', 'rmj': 'inochi'},
          ]
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '彼を信頼している。',
          'rmj': 'Kare o shinrai shite iru.',
          'audio_text': '彼を信頼している。',
          'words': ['anh ấy', 'đang', 'tin cậy', 'sợ hãi', 'tiến cử'],
          'answer': 'đang tin cậy anh ấy',
        },
      ];
    }

    List<Map<String, dynamic>> _getN1Bai8LuyenTap2Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền từ (Nếu là vì công việc thì đành chịu): \n仕事のため ( ... )、仕方がない。',
          'options': ['とあれば', 'ゆえに', 'にすぎない', 'に至るまで'],
          'answer': 'とあれば'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '家族のためとあれば、命も恐れない。',
          'words': ['家族', 'のため', 'とあれば', '命', 'も', '恐れない'],
          'answer': '家族 のため とあれば 命 も 恐れない',
        },
      ];
    }

    List<Map<String, dynamic>> _getN1Bai8LuyenTap3Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền từ (Một người đáng để tiến cử): \n推薦する ( ... ) 人物。',
          'options': ['に足る', 'とあれば', 'しかるべき', 'がてら'],
          'answer': 'に足る'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '彼は信頼に足る人物だ。',
          'words': ['彼', 'は', '信頼', 'に', '足る', '人物', 'だ'],
          'answer': '彼 は 信頼 に 足る 人物 だ',
        },
      ];
    }

    List<Map<String, dynamic>> _getN1Bai8LuyenNoiData() {
      return [
        {'type': LessonType.speaking, 'jp': '家族のためとあれば。', 'answer': 'かぞくのためとあれば'},
        {'type': LessonType.speaking, 'jp': '信頼に足る人物だ。', 'answer': 'しんらいにたるじんぶつだ'},
        {'type': LessonType.speaking, 'jp': '推薦に足る。', 'answer': 'すいせんにたる'},
      ];
    }

    List<Map<String, dynamic>> _getN1Bai8LuyenVietData() {
      return [
        {'type': LessonType.kanjiDraw, 'kanji_word': '命', 'kanji_target': '命', 'meaning': 'Mệnh (Sinh mệnh / Ra lệnh)', 'rmj': 'inochi / mei'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '信頼', 'kanji_target': '信', 'meaning': 'Tín (Tin tưởng)', 'rmj': 'shin'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '信頼', 'kanji_target': '頼', 'meaning': 'Lại (Ỷ lại / Dựa dẫm)', 'rmj': 'tano(mu) / rai'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '推薦', 'kanji_target': '推', 'meaning': 'Suy (Suy luận / Tiến cử)', 'rmj': 'o(su) / sui'},
      ];
    }
  List<Map<String, dynamic>> _getN1Bai9LyThuyetData() {
      return [
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': '借金', 'hiragana': 'しゃっきん', 'romaji': 'shakkin', 'meaning': 'Tiền nợ / Vay nợ'},
            {'kanji': '崩壊', 'hiragana': 'ほうかい', 'romaji': 'houkai', 'meaning': 'Sụp đổ'},
            {'kanji': '批判', 'hiragana': 'ひはん', 'romaji': 'hihan', 'meaning': 'Phê phán'},
            {'kanji': '始末', 'hiragana': 'しまつ', 'romaji': 'shimatsu', 'meaning': 'Kết cục'},
            {'kanji': '堪える', 'hiragana': 'たえる', 'romaji': 'taeru', 'meaning': 'Chịu đựng / Đáng để'},
          ]
        },
        {
          'type': LessonType.flashCard, 'kanji': '借金', 'hiragana': 'しゃっきん', 'romaji': 'shakkin', 'meaning': 'Nợ nần',
          'example_img': 'assets/images/example_shakkin.png',
          'example_jp': '借金をする。', 'example_rmj': 'Shakkin o suru.', 'example_vn': 'Vay nợ.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '崩壊', 'hiragana': 'ほうかい', 'romaji': 'houkai', 'meaning': 'Sụp đổ',
          'example_img': 'assets/images/example_houkai.png',
          'example_jp': '家族が崩壊する。', 'example_rmj': 'Kazoku ga houkai suru.', 'example_vn': 'Gia đình sụp đổ.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '批判', 'hiragana': 'ひはん', 'romaji': 'hihan', 'options': ['nợ nần', 'chịu đựng', 'phê phán', 'kết cục'], 'answer': 'phê phán'},
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'V(ru) + しまつだ', 'meaning': 'Kết cục là... / Rốt cuộc thì... (Rất tồi tệ)'},
            {'title': 'V(ru) / N + に堪えない', 'meaning': 'Không đáng để... / Không thể chịu nổi...'},
          ]
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'KẾT CỤC TỒI TỆ',
          'formula': 'Động từ (thể từ điển / thể ない) + しまつだ (shimatsu da)',
          'meaning': 'Kết cục là... / Rốt cuộc lại thành ra...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜しまつだ',
          'notes': [
            'Diễn tả một quá trình tồi tệ cứ tiếp diễn, và cuối cùng dẫn đến một kết quả cực kỳ xấu.',
            'Thường đi kèm với các từ chỉ quá trình như: とうとう (cuối cùng thì), ついに (rốt cuộc).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ しまつだ',
          'img': 'assets/images/example_shimatsu.png',
          'jp': '借金を重ねて、家を売るしまつだ。',
          'rmj': 'Shakkin o kasanete, ie o uru shimatsu da.',
          'vn': 'Nợ nần chồng chất, kết cục là phải bán nhà.'
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'SỰ ĐÁNH GIÁ THẤP',
          'formula': 'Động từ (từ điển) / Danh từ + に堪えない (ni taenai)',
          'meaning': 'Không đáng để... / Vô cùng (cảm xúc)...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜に堪えない',
          'notes': [
            'Cách dùng 1: Đánh giá một sự vật tồi tệ đến mức "Không đáng để xem/nghe". (見るに堪えない: Không đáng xem).',
            'Cách dùng 2: Đi với danh từ chỉ cảm xúc mang nghĩa "Vô cùng..." (感謝に堪えない: Vô cùng biết ơn).'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ に堪えない',
          'img': 'assets/images/example_taenai.png',
          'jp': '彼の言い訳は、聞くに堪えない。',
          'rmj': 'Kare no iiwake wa, kiku ni taenai.',
          'vn': 'Những lời ngụy biện của anh ta thật không đáng để nghe.'
        },
        {
          'type': LessonType.vocabSummary,
          'words': [
            {'kanji': '借金', 'romaji': 'shakkin', 'meaning': 'tiền nợ'},
            {'kanji': '崩壊', 'romaji': 'houkai', 'meaning': 'sụp đổ'},
            {'kanji': 'しまつだ', 'romaji': 'shimatsu da', 'meaning': 'kết cục là'},
            {'kanji': 'に堪えない', 'romaji': 'ni taenai', 'meaning': 'không đáng để'},
          ]
        }
      ];
    }

    List<Map<String, dynamic>> _getN1Bai9LuyenTap1Data() {
      return [
        {
          'type': LessonType.imageQuiz,
          'question': 'Sụp đổ.',
          'answerIndex': 3,
          'options': [
            {'img': 'assets/images/example_shakkin.png', 'jp': '借金', 'rmj': 'shakkin'},
            {'img': 'assets/images/example_taeru.png', 'jp': '堪える', 'rmj': 'taeru'},
            {'img': 'assets/images/example_hihan.png', 'jp': '批判', 'rmj': 'hihan'},
            {'img': 'assets/images/example_houkai.png', 'jp': '崩壊', 'rmj': 'houkai'},
          ]
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '借金をする。',
          'rmj': 'Shakkin o suru.',
          'audio_text': '借金をする。',
          'words': ['nợ', 'vay', 'đáng để', 'kết cục', 'sụp đổ'],
          'answer': 'vay nợ',
        },
      ];
    }

    List<Map<String, dynamic>> _getN1Bai9LuyenTap2Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền từ (Nợ nần chồng chất, KẾT CỤC là bán nhà): \n家を売る ( ... )。',
          'options': ['しまつだ', 'に堪えない', 'ばかりに', 'に限って'],
          'answer': 'しまつだ'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '親と喧嘩して、家を出るしまつだ。',
          'words': ['親と', '喧嘩して', '家を', '出る', 'しまつだ', '堪えない'],
          'answer': '親と 喧嘩して 家を 出る しまつだ',
        },
      ];
    }

    List<Map<String, dynamic>> _getN1Bai9LuyenTap3Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền từ (Lý do tồi tệ KHÔNG ĐÁNG ĐỂ nghe): \n聞く ( ... )。',
          'options': ['に堪えない', 'しまつだ', 'ずくめ', 'がてら'],
          'answer': 'に堪えない'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '彼の言葉は聞くに堪えない。',
          'words': ['彼の', '言葉', 'は', '聞く', 'に', '堪えない', 'しまつだ'],
          'answer': '彼の 言葉 は 聞く に 堪えない',
        },
      ];
    }

    List<Map<String, dynamic>> _getN1Bai9LuyenNoiData() {
      return [
        {'type': LessonType.speaking, 'jp': '家を売るしまつだ。', 'answer': 'いえをうるしまつだ'},
        {'type': LessonType.speaking, 'jp': '聞くに堪えない。', 'answer': 'きくにたえない'},
        {'type': LessonType.speaking, 'jp': '感謝に堪えません。', 'answer': 'かんしゃにたえません'},
      ];
    }

    List<Map<String, dynamic>> _getN1Bai9LuyenVietData() {
      return [
        {'type': LessonType.kanjiDraw, 'kanji_word': '借金', 'kanji_target': '借', 'meaning': 'Tá (Vay mượn)', 'rmj': 'ka(riru) / shaku'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '崩壊', 'kanji_target': '崩', 'meaning': 'Băng (Sụp đổ)', 'rmj': 'kuzu(reru) / hou'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '崩壊', 'kanji_target': '壊', 'meaning': 'Hoại (Phá hoại / Hỏng)', 'rmj': 'kowa(su) / kai'},
      ];
    }
  List<Map<String, dynamic>> _getN1Bai10LyThuyetData() {
      return [
        {
          'type': LessonType.vocabListIntro,
          'words': [
            {'kanji': '想像', 'hiragana': 'そうぞう', 'romaji': 'souzou', 'meaning': 'Tưởng tượng'},
            {'kanji': '一瞬', 'hiragana': 'いっしゅん', 'romaji': 'isshun', 'meaning': 'Một khoảnh khắc / Chốc lát'},
            {'kanji': '無駄', 'hiragana': 'むだ', 'romaji': 'muda', 'meaning': 'Lãng phí / Vô ích'},
            {'kanji': '敵', 'hiragana': 'てき', 'romaji': 'teki', 'meaning': 'Kẻ thù'},
            {'kanji': '許す', 'hiragana': 'ゆるす', 'romaji': 'yurusu', 'meaning': 'Tha thứ'},
          ]
        },
        {
          'type': LessonType.flashCard, 'kanji': '想像', 'hiragana': 'そうぞう', 'romaji': 'souzou', 'meaning': 'Tưởng tượng',
          'example_img': 'assets/images/example_souzou.png',
          'example_jp': '想像できない。', 'example_rmj': 'Souzou dekinai.', 'example_vn': 'Không thể tưởng tượng được.'
        },
        {
          'type': LessonType.flashCard, 'kanji': '一瞬', 'hiragana': 'いっしゅん', 'romaji': 'isshun', 'meaning': 'Một khoảnh khắc',
          'example_img': 'assets/images/example_isshun.png',
          'example_jp': '一瞬の出来事。', 'example_rmj': 'Isshun no dekigoto.', 'example_vn': 'Sự việc xảy ra trong chốc lát.'
        },
        {'type': LessonType.vocabQuiz, 'kanji': '無駄', 'hiragana': 'むだ', 'romaji': 'muda', 'options': ['kẻ thù', 'tưởng tượng', 'lãng phí', 'tha thứ'], 'answer': 'lãng phí'},
        {
          'type': LessonType.grammarListIntro,
          'grammars': [
            {'title': 'N + (で)すら', 'meaning': 'Ngay cả... (Nhấn mạnh một điều hiển nhiên)'},
            {'title': '1+Từ đếm + たりとも...ない', 'meaning': 'Dù chỉ là (1)... cũng không...'},
          ]
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'SỰ NHẤN MẠNH (すら)',
          'formula': 'Danh từ + (で)すら (sura)',
          'meaning': 'Ngay cả... / Thậm chí...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜すら',
          'notes': [
            'Đồng nghĩa với さえ (Ngay cả), nhưng mang sắc thái văn viết và thường dùng trong câu phủ định.',
            'Đưa ra một ví dụ rất cơ bản, hiển nhiên để ám chỉ "Cái cơ bản thế mà không làm được thì những cái khác càng không thể".'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ すら',
          'img': 'assets/images/example_sura.png',
          'jp': '忙しくて、寝る時間すらありません。',
          'rmj': 'Isogashikute, neru jikan sura arimasen.',
          'vn': 'Bận đến mức NGAY CẢ thời gian ngủ cũng không có.'
        },
        {
          'type': LessonType.grammarStructure,
          'title': 'PHỦ ĐỊNH TỐI THIỂU',
          'formula': '1 + Từ đếm + たりとも + V(ない)',
          'meaning': 'Dù chỉ là (1)... thì cũng tuyệt đối không...'
        },
        {
          'type': LessonType.grammarUsage,
          'title': 'SỬ DỤNG 〜たりとも',
          'notes': [
            'Dùng kèm với số đếm nhỏ nhất (1 ngày, 1 phút, 1 yên, 1 người).',
            'Biểu thị ý chí mạnh mẽ: "Tuyệt đối không nhượng bộ dù chỉ là một chút".',
            'Thường dùng trong văn phong quân đội, cảnh cáo, quyết tâm cao.'
          ]
        },
        {
          'type': LessonType.grammarExample,
          'title': 'VÍ DỤ たりとも',
          'img': 'assets/images/example_taritomo.png',
          'jp': '一瞬たりとも、敵を許さない。',
          'rmj': 'Isshun taritomo, teki o yurusanai.',
          'vn': 'DÙ CHỈ LÀ một khoảnh khắc, tôi cũng sẽ không tha thứ cho kẻ thù.'
        },
        {
          'type': LessonType.vocabSummary,
          'words': [
            {'kanji': '想像', 'romaji': 'souzou', 'meaning': 'tưởng tượng'},
            {'kanji': '一瞬', 'romaji': 'isshun', 'meaning': 'một chốc lát'},
            {'kanji': 'すら', 'romaji': 'sura', 'meaning': 'ngay cả'},
            {'kanji': 'たりとも...ない', 'romaji': 'taritomo...nai', 'meaning': 'dù chỉ là... cũng không'},
          ]
        }
      ];
    }

    List<Map<String, dynamic>> _getN1Bai10LuyenTap1Data() {
      return [
        {
          'type': LessonType.imageQuiz,
          'question': 'Lãng phí / Vô ích.',
          'answerIndex': 1,
          'options': [
            {'img': 'assets/images/example_souzou.png', 'jp': '想像', 'rmj': 'souzou'},
            {'img': 'assets/images/example_muda.png', 'jp': '無駄', 'rmj': 'muda'},
            {'img': 'assets/images/example_teki.png', 'jp': '敵', 'rmj': 'teki'},
            {'img': 'assets/images/example_yurusu.png', 'jp': '許す', 'rmj': 'yurusu'},
          ]
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '想像できない。',
          'rmj': 'Souzou dekinai.',
          'audio_text': '想像できない。',
          'words': ['tưởng tượng', 'không thể', 'ngay cả', 'kẻ thù', 'lãng phí'],
          'answer': 'không thể tưởng tượng',
        },
      ];
    }

    List<Map<String, dynamic>> _getN1Bai10LuyenTap2Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Điền từ (Ngay cả tên mình cũng không viết được): \n自分の名前 ( ... ) 書けない。',
          'options': ['すら', 'たりとも', 'しまつだ', 'に堪えない'],
          'answer': 'すら'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '寝る時間すらありません。',
          'words': ['寝る', '時間', 'すら', 'ありません', 'たりとも'],
          'answer': '寝る 時間 すら ありません',
        },
      ];
    }

    List<Map<String, dynamic>> _getN1Bai10LuyenTap3Data() {
      return [
        {
          'type': LessonType.quiz,
          'question': 'Cấu trúc luôn đi với số "1" và mang nghĩa phủ định hoàn toàn:',
          'options': ['すら', 'たりとも', 'ゆえに', 'がてら'],
          'answer': 'たりとも'
        },
        {
          'type': LessonType.sentenceBuilder,
          'jp': '',
          'rmj': '',
          'audio_text': '一日たりとも無駄にしない。',
          'words': ['一日', 'たりとも', '無駄に', 'しない', 'すら'],
          'answer': '一日 たりとも 無駄に しない',
        },
      ];
    }

    List<Map<String, dynamic>> _getN1Bai10LuyenNoiData() {
      return [
        {'type': LessonType.speaking, 'jp': '名前すら書けない。', 'answer': 'なまえすらかけない'},
        {'type': LessonType.speaking, 'jp': '一瞬たりとも忘れない。', 'answer': 'いっしゅんたりともわすれない'},
        {'type': LessonType.speaking, 'jp': '一日たりとも無駄にしない。', 'answer': 'いちにちたりともむだにしない'},
      ];
    }

    List<Map<String, dynamic>> _getN1Bai10LuyenVietData() {
      return [
        {'type': LessonType.kanjiDraw, 'kanji_word': '想像', 'kanji_target': '想', 'meaning': 'Tưởng (Tư tưởng / Tưởng tượng)', 'rmj': 'sou'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '想像', 'kanji_target': '像', 'meaning': 'Tượng (Hình tượng / Tưởng tượng)', 'rmj': 'zou'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '一瞬', 'kanji_target': '瞬', 'meaning': 'Thuấn (Chốc lát)', 'rmj': 'matata(ku) / shun'},
        {'type': LessonType.kanjiDraw, 'kanji_word': '無駄', 'kanji_target': '駄', 'meaning': 'Đà (Vô ích / Lãng phí)', 'rmj': 'da'},
      ];
    }
  List<Map<String, dynamic>> _generateAlphabetData(List<Map<String, String>> chars) {
      List<Map<String, dynamic>> data = [];

      for (var c in chars) {
        String gifName = c['romaji'] == 'ne' ? 'ne1' : c['romaji']!;

        // --- HIRAGANA ---
        data.add({
          'type': LessonType.learn,
          'char': c['hira'],
          'romaji': c['romaji'],
          'gif': 'assets/gifs/$gifName.gif'
        });

        List<String> hiraOptions = chars.map((e) => e['hira']!).toList();
        hiraOptions.remove(c['hira']);
        hiraOptions.shuffle();
        List<String> finalHiraOptions = [c['hira']!, ...hiraOptions.take(3)]..shuffle();

        data.add({
          'type': LessonType.quiz,
          'question': '',
          'audio_text': c['hira'],
          'options': finalHiraOptions,
          'answer': c['hira']
        });

        // --- KATAKANA ---
        data.add({
          'type': LessonType.learn,
          'char': c['kata'],
          'romaji': c['romaji'],
          'gif': 'assets/gifs/${gifName}k.gif'
        });

        List<String> kataOptions = chars.map((e) => e['kata']!).toList();
        kataOptions.remove(c['kata']);
        kataOptions.shuffle();
        List<String> finalKataOptions = [c['kata']!, ...kataOptions.take(3)]..shuffle();

        data.add({
          'type': LessonType.quiz,
          'question': '',
          'audio_text': c['kata'],
          'options': finalKataOptions,
          'answer': c['kata']
        });
      }

      // --- GAME NỐI CHỮ (ROMAGI - HIRAGANA) ---
      data.add({
        'type': LessonType.matching,
        'pairs': chars.map((c) => {
          'left': c['romaji']!,
          'right': c['hira']!
        }).toList()
      });

      // --- GAME NỐI CHỮ (HIRAGANA - KATAKANA) ---
      data.add({
        'type': LessonType.matching,
        'pairs': chars.map((c) => {
          'left': c['hira']!,
          'right': c['kata']!
        }).toList()
      });

      return data;
    }
  List<Map<String, dynamic>> _getHangAData() {
      return _generateAlphabetData([
        {'hira': 'あ', 'kata': 'ア', 'romaji': 'a'},
              {'hira': 'い', 'kata': 'イ', 'romaji': 'i'},
              {'hira': 'う', 'kata': 'ウ', 'romaji': 'u'},
              {'hira': 'え', 'kata': 'エ', 'romaji': 'e'},
              {'hira': 'お', 'kata': 'オ', 'romaji': 'o'},
      ]);
    }

    List<Map<String, dynamic>> _getHangKaData() {
      return _generateAlphabetData([
        {'hira': 'か', 'kata': 'カ', 'romaji': 'ka'},
              {'hira': 'き', 'kata': 'キ', 'romaji': 'ki'},
              {'hira': 'く', 'kata': 'ク', 'romaji': 'ku'},
              {'hira': 'け', 'kata': 'ケ', 'romaji': 'ke'},
              {'hira': 'こ', 'kata': 'コ', 'romaji': 'ko'},
      ]);
    }

    List<Map<String, dynamic>> _getHangSaData() {
        return _generateAlphabetData([
          {'hira': 'さ', 'kata': 'サ', 'romaji': 'sa'},
          {'hira': 'し', 'kata': 'シ', 'romaji': 'shi'},
          {'hira': 'す', 'kata': 'ス', 'romaji': 'su'},
          {'hira': 'せ', 'kata': 'セ', 'romaji': 'se'},
          {'hira': 'そ', 'kata': 'ソ', 'romaji': 'so'},
        ]);
      }

      List<Map<String, dynamic>> _getHangTaData() {
        return _generateAlphabetData([
          {'hira': 'た', 'kata': 'タ', 'romaji': 'ta'},
          {'hira': 'ち', 'kata': 'チ', 'romaji': 'chi'},
          {'hira': 'つ', 'kata': 'ツ', 'romaji': 'tsu'},
          {'hira': 'て', 'kata': 'テ', 'romaji': 'te'},
          {'hira': 'と', 'kata': 'ト', 'romaji': 'to'},
        ]);
      }

      List<Map<String, dynamic>> _getHangNaData() {
        return _generateAlphabetData([
          {'hira': 'な', 'kata': 'ナ', 'romaji': 'na'},
          {'hira': 'に', 'kata': 'ニ', 'romaji': 'ni'},
          {'hira': 'ぬ', 'kata': 'ヌ', 'romaji': 'nu'},
          {'hira': 'ね', 'kata': 'ネ', 'romaji': 'ne'},
          {'hira': 'の', 'kata': 'ノ', 'romaji': 'no'},
        ]);
      }

      List<Map<String, dynamic>> _getHangHaData() {
        return _generateAlphabetData([
          {'hira': 'は', 'kata': 'ハ', 'romaji': 'ha'},
          {'hira': 'ひ', 'kata': 'ヒ', 'romaji': 'hi'},
          {'hira': 'ふ', 'kata': 'フ', 'romaji': 'fu'},
          {'hira': 'へ', 'kata': 'ヘ', 'romaji': 'he'},
          {'hira': 'ほ', 'kata': 'ホ', 'romaji': 'ho'},
        ]);
      }

      List<Map<String, dynamic>> _getHangMaData() {
        return _generateAlphabetData([
          {'hira': 'ま', 'kata': 'マ', 'romaji': 'ma'},
          {'hira': 'み', 'kata': 'ミ', 'romaji': 'mi'},
          {'hira': 'む', 'kata': 'ム', 'romaji': 'mu'},
          {'hira': 'め', 'kata': 'メ', 'romaji': 'me'},
          {'hira': 'も', 'kata': 'モ', 'romaji': 'mo'},
        ]);
      }

      List<Map<String, dynamic>> _getHangYaData() {
        return _generateAlphabetData([
          {'hira': 'や', 'kata': 'ヤ', 'romaji': 'ya'},
          {'hira': 'ゆ', 'kata': 'ユ', 'romaji': 'yu'},
          {'hira': 'よ', 'kata': 'ヨ', 'romaji': 'yo'},
        ]);
      }

      List<Map<String, dynamic>> _getHangRaData() {
        return _generateAlphabetData([
          {'hira': 'ら', 'kata': 'ラ', 'romaji': 'ra'},
          {'hira': 'り', 'kata': 'リ', 'romaji': 'ri'},
          {'hira': 'る', 'kata': 'ル', 'romaji': 'ru'},
          {'hira': 'れ', 'kata': 'レ', 'romaji': 're'},
          {'hira': 'ろ', 'kata': 'ロ', 'romaji': 'ro'},
        ]);
      }

      List<Map<String, dynamic>> _getHangWaNData() {
        return _generateAlphabetData([
          {'hira': 'わ', 'kata': 'ワ', 'romaji': 'wa'},
          {'hira': 'を', 'kata': 'ヲ', 'romaji': 'wo'},
          {'hira': 'ん', 'kata': 'ン', 'romaji': 'n'},
        ]);
      }

    List<Map<String, dynamic>> _getFinalReviewData() {
        List<Map<String, dynamic>> data = [];
        List<Map<String, String>> allChars = [
          {'hira': 'あ', 'kata': 'ア', 'romaji': 'a'},
          {'hira': 'か', 'kata': 'カ', 'romaji': 'ka'},
          {'hira': 'さ', 'kata': 'サ', 'romaji': 'sa'},
          {'hira': 'た', 'kata': 'タ', 'romaji': 'ta'},
          {'hira': 'な', 'kata': 'ナ', 'romaji': 'na'},
          {'hira': 'は', 'kata': 'ハ', 'romaji': 'ha'},
          {'hira': 'ま', 'kata': 'マ', 'romaji': 'ma'},
          {'hira': 'や', 'kata': 'ヤ', 'romaji': 'ya'},
          {'hira': 'ら', 'kata': 'ラ', 'romaji': 'ra'},
          {'hira': 'わ', 'kata': 'ワ', 'romaji': 'wa'},
          {'hira': 'ん', 'kata': 'ン', 'romaji': 'n'}
        ];
        allChars.shuffle();

        for (var c in allChars.take(8)) {
          bool isHira = (DateTime.now().millisecondsSinceEpoch % 2 == 0);
          String targetChar = isHira ? c['hira']! : c['kata']!;

          List<String> options = allChars.map((e) => isHira ? e['hira']! : e['kata']!).toList();
          options.remove(targetChar);
          options.shuffle();

          List<String> finalOptions = [targetChar, ...options.take(3)]..shuffle();

          data.add({
            'type': LessonType.quiz,
            'question': '',
            'audio_text': targetChar,
            'options': finalOptions,
            'answer': targetChar
          });
        }
        allChars.shuffle();
            data.add({
              'type': LessonType.matching,
              'pairs': allChars.take(5).map((c) => {
                'left': c['romaji']!,
                'right': c['hira']!
              }).toList()
        });
        allChars.shuffle();
            data.add({
              'type': LessonType.matching,
              'pairs': allChars.take(5).map((c) => {
                'left': c['romaji']!,
                'right': c['kata']!
              }).toList()
        });
        allChars.shuffle();
            data.add({
              'type': LessonType.matching,
              'pairs': allChars.take(5).map((c) => {
                'left': c['hira']!,
                'right': c['kata']!
              }).toList()
        });
        return data;
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
      _wrongAnswers.add(correctAnswer.toLowerCase());

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
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: 20 + MediaQuery.of(context).padding.bottom
            ),
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
            onPressed: _showSettingsSheet,
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
  final currentKey = ValueKey(_currentIndex);
    switch (data['type'] as LessonType) {
      case LessonType.vocabListIntro:
        return VocabListIntroView(words: data['words'], onNext: _nextActivity);
      case LessonType.grammarListIntro:
        return GrammarListIntroView(grammars: data['grammars'], onNext: _nextActivity);
      case LessonType.grammarStructure:
        return GrammarStructureView(data: data, onNext: _nextActivity);
      case LessonType.grammarUsage:
        return GrammarUsageView(data: data, onNext: _nextActivity);
      case LessonType.grammarExample:
        return GrammarExampleView(data: data, onNext: _nextActivity);
      case LessonType.learn: return _buildLearnView(data);
      case LessonType.quiz: return StandardQuizView(
        key: currentKey,
        data: data,
        onCheckResult: (isCorrect, correctAns, userAns) => _showResultSheet(isCorrect, correctAns, userAns),
      );
      case LessonType.matching: return _buildMatchingView(data);
      case LessonType.imageQuiz: return _buildImageQuizView(data);
      case LessonType.listening:
        return ListeningQuizView(
          key: currentKey,
          data: data,
          onCheckResult: (isCorrect, correctAns, userAns) => _showResultSheet(isCorrect, correctAns, userAns),
        );
      case LessonType.sentenceBuilder:
        return SentenceBuilderView(
            key: currentKey,
            data: data,
            onCheckResult: (isCorrect, correctAns, userAns) => _showResultSheet(isCorrect, correctAns, userAns)
        );
      case LessonType.speaking:
        return SpeakingPracticeView(
            key: currentKey,
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
            key: currentKey,
            data: data,
            onCheckResult: (isCorrect, correctAns, userAns) => _showResultSheet(isCorrect, correctAns, userAns)
        );
      case LessonType.vocabSummary:
        return VocabSummaryView(words: data['words'], wrongAnswers: _wrongAnswers, onNext: _nextActivity, onExit: _finishLesson,);
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
  List<Map<String, String>> matchingPairs =
    (data['pairs'] as List).map((e) => Map<String, String>.from(e)).toList();
  return MatchingGame(
          key: ValueKey(data.toString()),
          pairs: matchingPairs,
          onCompleted: () {
            _correctAnswers++;
            _nextActivity();
          }
      );
  }

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
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                          child: Image.asset(opt['img'], fit: BoxFit.cover, width: double.infinity,
                              errorBuilder: (_,__,___) => Container(color: Colors.grey.shade100, child: const Icon(Icons.image, size: 50, color: Colors.grey))),
                        ),
                      ),
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

// ==========================================================
// CÁC MÀN HÌNH MỚI: LÝ THUYẾT & NGỮ PHÁP (HÌNH 1 ĐẾN 5)
// ==========================================================
class VocabListIntroView extends StatelessWidget {
  final List<dynamic> words;
  final VoidCallback onNext;

  const VocabListIntroView({super.key, required this.words, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("👉 Từ vựng bạn sẽ học", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: words.length,
            itemBuilder: (context, index) {
              final w = words[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFF7F7F7), borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                              text: TextSpan(
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                                  children: [
                                    TextSpan(text: w['kanji'] != '' ? w['kanji'] : w['hiragana']),
                                    TextSpan(text: "  (${w['romaji']})", style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.normal)),
                                  ]
                              )
                          ),
                          const SizedBox(height: 5),
                          Text(w['meaning'], style: const TextStyle(color: Colors.black54, fontSize: 16)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => SoundManager.instance.speakJapanese(w['kanji'] != '' ? w['kanji'] : w['hiragana']),
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
          width: double.infinity, height: 55,
          child: ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF78C850), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), elevation: 0),
            child: const Text("Học từ vựng", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        )
      ],
    );
  }
}

class GrammarListIntroView extends StatelessWidget {
  final List<dynamic> grammars;
  final VoidCallback onNext;

  const GrammarListIntroView({super.key, required this.grammars, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("👉 Ngữ pháp bạn sẽ học", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: grammars.length,
            itemBuilder: (context, index) {
              final g = grammars[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFFF7F7F7), borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(g['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 5),
                    Text(g['meaning'], style: const TextStyle(color: Colors.black54, fontSize: 15)),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity, height: 55,
          child: ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF78C850), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), elevation: 0),
            child: const Text("Học ngữ pháp", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        )
      ],
    );
  }
}

class GrammarStructureView extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onNext;

  const GrammarStructureView({super.key, required this.data, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(child: Text("《 NGỮ PHÁP MỚI 》", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14))),
        const SizedBox(height: 15),
        Center(child: Text(data['title'], style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold))),
        const SizedBox(height: 40),

        Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), decoration: BoxDecoration(color: const Color(0xFF78C850), borderRadius: BorderRadius.circular(16)), child: const Text("Cấu trúc", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        const SizedBox(height: 15),
        Text("●  " + data['formula'], style: const TextStyle(fontSize: 20, color: Color(0xFF78C850), fontWeight: FontWeight.bold)),

        const SizedBox(height: 40),
        Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(16)), child: const Text("Nghĩa", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        const SizedBox(height: 15),
        Text(data['meaning'], style: const TextStyle(fontSize: 18, color: Colors.black87)),

        const Spacer(),
        Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: onNext,
              child: Container(
                  padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300)),
                  child: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20)
              ),
            )
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
        Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(16)), child: const Text("Cách sử dụng", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        const SizedBox(height: 15),
        Text(data['title'], style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
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
                    const Padding(padding: EdgeInsets.only(top: 6), child: Icon(Icons.circle, size: 10, color: Colors.grey)),
                    const SizedBox(width: 10),
                    Expanded(child: Text(notes[index], style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5))),
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
                  padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300)),
                  child: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20)
              ),
            )
        ),
      ],
    );
  }
}

class GrammarExampleView extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onNext;

  const GrammarExampleView({super.key, required this.data, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), decoration: BoxDecoration(color: const Color(0xFF4285F4), borderRadius: BorderRadius.circular(16)), child: const Text("Ví dụ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        const SizedBox(height: 15),
        Text(data['title'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF78C850))),
        const SizedBox(height: 30),

        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(data['img'], fit: BoxFit.cover, width: double.infinity, errorBuilder: (_,__,___)=> Container(color: Colors.grey.shade200, child: const Icon(Icons.image, size: 50))),
          ),
        ),
        const SizedBox(height: 30),

        GestureDetector(
          onTap: () => SoundManager.instance.speakJapanese(data['jp']),
          child: Text(data['jp'], style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87), textAlign: TextAlign.center),
        ),
        const SizedBox(height: 10),
        Text(data['rmj'], style: const TextStyle(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center),
        const SizedBox(height: 10),
        Text(data['vn'], style: const TextStyle(fontSize: 18, color: Color(0xFF78C850), fontWeight: FontWeight.bold), textAlign: TextAlign.center),

        const SizedBox(height: 40),
        Row(
          children: [
            Expanded(child: ElevatedButton.icon(onPressed: onNext, icon: const Icon(Icons.check_circle, color: Color(0xFF78C850)), label: const Text("Đã hiểu", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF7F7F7), elevation: 0, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))))),
            const SizedBox(width: 15),
            Expanded(child: ElevatedButton.icon(onPressed: onNext, icon: const Icon(Icons.cancel, color: Colors.redAccent), label: const Text("Nhắc tôi sau", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF7F7F7), elevation: 0, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))))),
          ],
        )
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

  const SentenceBuilderView({super.key, required this.data, required this.onCheckResult});

  @override
  State<SentenceBuilderView> createState() => _SentenceBuilderViewState();
}

class _SentenceBuilderViewState extends State<SentenceBuilderView> {
  List<String> poolWords = [];
  List<String> selectedWords = [];

  String _normalize(String s) => s.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  @override
  void initState() {
    super.initState();
    poolWords = List<String>.from(widget.data['words'])..shuffle();
  }

  @override
  Widget build(BuildContext context) {
    // Kiểm tra xem có phải dạng ẩn chữ chỉ hiện audio không
    bool isAudioOnly = widget.data['jp'] == null || widget.data['jp'].toString().isEmpty;

    return Column(
      children: [
        Text(
            isAudioOnly ? "Nghe và ghép từ thành câu" : "Nghe và dịch câu sau",
            style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold)
        ),
        const SizedBox(height: 20),

        if (!isAudioOnly) ...[
          Text(widget.data['jp'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
          Text(widget.data['rmj'], style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 20),

          GestureDetector(
            onTap: () => SoundManager.instance.speakJapanese(widget.data['audio_text'] ?? widget.data['jp']),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: const BoxDecoration(color: Color(0xFFF1F8E9), shape: BoxShape.circle),
              child: const Icon(Icons.volume_up, color: Color(0xFF58CC02), size: 40),
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
                  SoundManager.instance.speakJapanese(widget.data['audio_text'] ?? widget.data['answer']);
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
                  SoundManager.instance.speakJapanese(widget.data['audio_text'] ?? widget.data['answer'], isSlow: true);
                },
                child: Container(
                  width: 60, height: 60,
                  decoration: const BoxDecoration(color: Color(0xFFEEF7E8), shape: BoxShape.circle),
                  child: const Icon(Icons.pets, color: Color(0xFF58CC02), size: 28),
                ),
              ),
            ],
          )
        ],

        const SizedBox(height: 30),
        Divider(color: Colors.grey.shade300, thickness: 2),
        const SizedBox(height: 30),

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

        Wrap(
          spacing: 12, runSpacing: 12, alignment: WrapAlignment.center,
          children: poolWords.map((word) => _buildWordChip(word, false)).toList(),
        ),

        const SizedBox(height: 40),

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
              Center(child: Container(width: double.infinity, height: 1, color: Colors.grey.shade200)),
              Center(child: Container(height: double.infinity, width: 1, color: Colors.grey.shade200)),
              Center(
                child: Text(widget.data['kanji_target'], style: TextStyle(fontSize: 220, color: Colors.grey.shade200, height: 1.1)),
              ),
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

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle), child: const Icon(Icons.visibility_off, color: Colors.green)),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: () => setState(() => points.clear()),
              child: Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(color: Color(0xFF58CC02), shape: BoxShape.circle), child: const Icon(Icons.cleaning_services, color: Colors.white, size: 30)),
            ),
            const SizedBox(width: 20),
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle), child: const Icon(Icons.visibility, color: Colors.green)),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: widget.onNext,
              child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle), child: const Icon(Icons.keyboard_double_arrow_right, color: Colors.black54)),
            ),
          ],
        ),
        const SizedBox(height: 20),

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
                      physics: const BouncingScrollPhysics(),
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
          width: double.infinity, height: 55,
          child: ElevatedButton(
            onPressed: _isFlipped ? widget.onNext : _toggleFlip,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF58CC02),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 0,
            ),
            child: Text(
                _isFlipped ? "Tiếp tục" : "Lật thẻ",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)
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
              Text("《 TỪ MỚI 》", style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF5A6275), fontSize: 16)),
            ],
          ),

          const Spacer(),

          if (showFurigana)
            Text(hiragana, style: const TextStyle(fontSize: 20, color: Colors.black54)),

          Text(
              mainText,
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
                borderRadius: BorderRadius.circular(20)
            ),
            child: const Text("Ví dụ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
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
    double dynamicFontSize = mainText.length > 4 ? 24 : (mainText.length > 2 ? 40 : 48);
    return Column(
      children: [
        const Text(
            "Chọn nghĩa của từ dưới đây",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF777777))
        ),
        const SizedBox(height: 30),

        if (showFurigana)
          Text(hiragana, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                        mainText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black87)
                    ),
                  ),
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

        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.3
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
                    color: isThisSelected ? const Color(0xFFE5F6D5) : const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                      options[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isThisSelected ? const Color(0xFF58CC02) : Colors.black87
                      )
                  ),
                ),
              );
            },
          ),
        ),

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
              elevation: 0,
            ),
            child: Text(
                "Kiểm tra",
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

class VocabSummaryView extends StatefulWidget {
  final List<dynamic> words;
  final Set<String> wrongAnswers; // Nhận danh sách những câu làm sai
  final VoidCallback onNext;
  final VoidCallback onExit;

  const VocabSummaryView({super.key, required this.words, required this.wrongAnswers, required this.onNext, required this.onExit});

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

      if (widget.wrongAnswers.contains(meaningLower) || widget.wrongAnswers.contains(kanjiLower)) {
        needsReview.add(w);
      } else {
        mastered.add(w);
      }
    }

    // Danh sách sẽ hiển thị theo Tab
    List<dynamic> displayList = _selectedTab == 0 ? needsReview : mastered;

    return Column(
      children: [
        const Text("Tổng kết bài học", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 20),

        // TAB SELECTOR
        Container(
          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20)),
          child: Row(
            children: [
              Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 0),
                    child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                            color: _selectedTab == 0 ? Colors.orange : Colors.transparent,
                            borderRadius: BorderRadius.circular(20)
                        ),
                        child: Center(
                            child: Text("Cần ôn tập (${needsReview.length})", style: TextStyle(color: _selectedTab == 0 ? Colors.white : Colors.grey, fontWeight: FontWeight.bold))
                        )
                    ),
                  )
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTab = 1),
                  child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                          color: _selectedTab == 1 ? const Color(0xFF58CC02) : Colors.transparent,
                          borderRadius: BorderRadius.circular(20)
                      ),
                      child: Center(
                          child: Text("Đã nắm vững (${mastered.length})", style: TextStyle(color: _selectedTab == 1 ? Colors.white : Colors.grey, fontWeight: FontWeight.bold))
                      )
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        const Align(alignment: Alignment.centerLeft, child: Text("TỪ VỰNG", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
        const SizedBox(height: 10),

        Expanded(
          child: displayList.isEmpty
              ? Center(child: Text(_selectedTab == 0 ? "Quá tuyệt! Bạn không làm sai câu nào." : "Chưa có từ nào hoàn thành.", style: TextStyle(color: Colors.grey.shade500, fontSize: 16)))
              : ListView.builder(
            itemCount: displayList.length,
            itemBuilder: (context, index) {
              final w = displayList[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                // Chuyển icon X đỏ hoặc V xanh tùy tab
                leading: Icon(
                    _selectedTab == 0 ? Icons.cancel : Icons.check_circle,
                    color: _selectedTab == 0 ? Colors.redAccent : const Color(0xFF58CC02),
                    size: 28
                ),
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
                onTap: () => SoundManager.instance.speakJapanese(w['kanji'] != '' ? w['kanji'] : w['romaji']),
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
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Text("Thoát", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: widget.onNext,
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

  void _showCantListenDialog() {
    SoundManager.instance.vibrate('light');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFFFFF4C7),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
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
                      LessonScreen.audioDisabledUntil = DateTime.now().add(const Duration(minutes: 15));
                      Navigator.pop(context);
                      widget.onCheckResult(true, widget.data['answer'], widget.data['answer']);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF78C850),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    child: const Text("Đồng ý", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
                      if (hiragana.isNotEmpty)
                        Text(hiragana, style: TextStyle(fontSize: 14, color: isSelected ? const Color(0xFF58CC02) : Colors.grey.shade600)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                         kanji,
                         style: TextStyle(
                         fontSize: 32,
                         fontWeight: FontWeight.bold,
                         color: isSelected ? const Color(0xFF58CC02) : Colors.black87
                         )
                      ),
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
          child: const Text("Bạn đang không thể nghe", style: TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.bold)),
        ),

        const SizedBox(height: 10),

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
      setState(() => _selectedOption = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> options = widget.data['options'];
    bool canCheck = _selectedOption != null;

    // Kiểm tra xem có phải dạng ẩn chữ chỉ hiện audio không
    bool isAudioOnly = widget.data['question'] == null || widget.data['question'].toString().isEmpty;

    return Column(
      children: [
        Text(
            isAudioOnly ? "Nghe và chọn đáp án đúng" : "Chọn đáp án đúng",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF777777))
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
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)
                ),
              ),
              GestureDetector(
                onTap: () => SoundManager.instance.speakJapanese(widget.data['audio_text'] ?? widget.data['question']),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(color: Color(0xFFEEF7E8), shape: BoxShape.circle),
                  child: const Icon(Icons.volume_up, color: Color(0xFF58CC02), size: 30),
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
                  SoundManager.instance.speakJapanese(widget.data['audio_text'] ?? widget.data['answer']);
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
                  SoundManager.instance.speakJapanese(widget.data['audio_text'] ?? widget.data['answer'], isSlow: true);
                },
                child: Container(
                  width: 60, height: 60,
                  decoration: const BoxDecoration(color: Color(0xFFEEF7E8), shape: BoxShape.circle),
                  child: const Icon(Icons.pets, color: Color(0xFF58CC02), size: 28),
                ),
              ),
            ],
          )
        ],

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
                      if (hiragana.isNotEmpty)
                        Text(hiragana, style: TextStyle(fontSize: 14, color: isSelected ? const Color(0xFF58CC02) : Colors.grey.shade600)),
                        Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    kanji,
                                                    style: TextStyle(
                                                      fontSize: 32,
                                                      fontWeight: FontWeight.bold,
                                                      color: isSelected ? const Color(0xFF58CC02) : Colors.black87
                                                    )
                                                  ),
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
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io' as io;

class AdminPanelScreen extends StatefulWidget {
  final int? externalSelectedTab; // Dùng để nhận dữ liệu tab từ Sidebar của Web
  final bool showAppBar;           // Ẩn/Hiện AppBar tùy thuộc Mobile hay Web

  const AdminPanelScreen({
    super.key,
    this.externalSelectedTab,
    this.showAppBar = true,
  });

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  int _selectedTab = 0;
  bool _isSaving = false;

  // --- TRẠNG THÁI EDIT ĐỘNG ---
  String? _editingJlptActivityId;
  String? _editingJlptLessonId;
  String? _editingJlptOldImageUrl;

  String? _editingListenQuestionId;
  String? _editingListenLessonId;
  String? _editingListenOldImageUrl;
  String? _editingListenOldAudioUrl;

  String? _editingReadPartId;
  String? _editingReadLessonId;

  @override
  void initState() {
    super.initState();
    if (widget.externalSelectedTab != null) {
      _selectedTab = widget.externalSelectedTab!;
    }
  }

  @override
  void didUpdateWidget(covariant AdminPanelScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.externalSelectedTab != null && widget.externalSelectedTab != oldWidget.externalSelectedTab) {
      setState(() {
        _selectedTab = widget.externalSelectedTab!;
      });
    }
  }
    Future<String?> _uploadToCloudinary(Uint8List fileBytes, String fileName) async {
      try {
        final String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? "";
        final String uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? "";

        if (cloudName.isEmpty || uploadPreset.isEmpty) {
          _showSnackBar("Lỗi: Chưa cấu hình biến môi trường .env");
          return null;
        }
        final isAudio = fileName.toLowerCase().endsWith('.mp3') || fileName.toLowerCase().endsWith('.wav');
        final resourceType = isAudio ? 'video' : 'image';
        final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload');

        final request = http.MultipartRequest('POST', url)
          ..fields['upload_preset'] = uploadPreset
          ..files.add(
            http.MultipartFile.fromBytes(
              'file',
              fileBytes,
              filename: fileName,
            ),
          );

        final response = await request.send();
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);

        if (response.statusCode == 200 || response.statusCode == 201) {
          final Map<String, dynamic> responseJson = json.decode(responseString);
          return responseJson['secure_url'];
        } else {
          print("Lỗi Cloudinary: $responseString");
          _showSnackBar("Upload media lên Cloudinary thất bại.");
          return null;
        }
      } catch (e) {
        print("Lỗi hệ thống khi upload: $e");
        _showSnackBar("Lỗi kết nối upload: $e");
        return null;
      }
    }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // ==========================================================
  // XÓA DỮ LIỆU ĐĂNG KÝ TRÊN MÁY CHỦ (CONFIRMS & DELETIONS)
  // ==========================================================
  void _confirmDeleteLesson(String collectionPath, String lessonId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận xóa bài học"),
        content: const Text("Bạn có chắc chắn muốn xóa bài học này cùng tất cả nội dung bên trong không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isSaving = true);
              try {
                final mainRef = FirebaseFirestore.instance.collection(collectionPath).doc(lessonId);
                String subColl = "";
                if (collectionPath == 'jlpt_lessons') {
                  subColl = 'activities';
                } else if (collectionPath == 'listening_lessons') {
                  subColl = 'questions';
                } else if (collectionPath == 'reading_lessons') {
                  subColl = 'parts';
                }

                final subSnapshot = await mainRef.collection(subColl).get();
                for (var doc in subSnapshot.docs) {
                  await doc.reference.delete();
                }
                await mainRef.delete();
                _showSnackBar("Đã xóa bài học thành công!");
              } catch (e) {
                _showSnackBar("Lỗi khi xóa bài học: $e");
              } finally {
                setState(() => _isSaving = false);
              }
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteActivity(String lessonId, String actId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc chắn muốn xóa Activity này không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await FirebaseFirestore.instance
                    .collection('jlpt_lessons')
                    .doc(lessonId)
                    .collection('activities')
                    .doc(actId)
                    .delete();
                _showSnackBar("Đã xóa Activity thành công!");
              } catch (e) {
                _showSnackBar("Lỗi khi xóa: $e");
              }
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteActivityByOrder(String lessonId, int orderNum) {
      String displayLessonName = lessonId.replaceAll('_lesson_', ' ').toUpperCase();

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Xác nhận xóa Hoạt động"),
          content: Text("Bạn có chắc chắn muốn xóa [Activity có thứ tự số $orderNum] thuộc bài [$displayLessonName] không?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy", style: TextStyle(color: Colors.grey))),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                setState(() => _isSaving = true);
                try {
                  // Tìm tài liệu con trong sub-collection 'activities' có trường 'order' trùng với số nhập vào
                  final snapshot = await FirebaseFirestore.instance
                      .collection('jlpt_lessons')
                      .doc(lessonId)
                      .collection('activities')
                      .where('order', isEqualTo: orderNum)
                      .get();

                  if (snapshot.docs.isEmpty) {
                    _showSnackBar("Không tìm thấy Activity nào có số thứ tự bằng $orderNum trong bài này!");
                  } else {
                    for (var doc in snapshot.docs) {
                      await doc.reference.delete();
                    }
                    _showSnackBar("Đã xóa Activity thứ tự số $orderNum thành công!");
                  }
                } catch (e) {
                  _showSnackBar("Lỗi khi xóa Activity: $e");
                } finally {
                  setState(() => _isSaving = false);
                }
              },
              child: const Text("Xóa", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    }

  void _confirmDeleteQuestion(String lessonId, String qDocId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc chắn muốn xóa câu hỏi này không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await FirebaseFirestore.instance
                    .collection('listening_lessons')
                    .doc(lessonId)
                    .collection('questions')
                    .doc(qDocId)
                    .delete();
                _showSnackBar("Đã xóa câu hỏi thành công!");
              } catch (e) {
                _showSnackBar("Lỗi khi xóa: $e");
              }
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmDeletePart(String lessonId, String pDocId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc chắn muốn xóa phân đoạn đọc này không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await FirebaseFirestore.instance
                    .collection('reading_lessons')
                    .doc(lessonId)
                    .collection('parts')
                    .doc(pDocId)
                    .delete();
                _showSnackBar("Đã xóa phân đoạn thành công!");
              } catch (e) {
                _showSnackBar("Lỗi khi xóa: $e");
              }
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // 1. PHẦN TAB 0: QUẢN LÝ BÀI HỌC JLPT (TỪ VỰNG / NGỮ PHÁP)
  // ==========================================================
  final _jlptFormKey = GlobalKey<FormState>();
  final _jlptLessonIdController = TextEditingController();
  final _jlptOrderController = TextEditingController();
  final _jlptTitleController = TextEditingController();

  String _jlptLevel = 'N5';
  String _listeningLevel = 'N5';
  String _readingLevel = 'N5';
  String _jlptActivityType = 'vocabListIntro';

  // Biến lưu trữ File hỗ trợ Web
  XFile? _jlptSelectedXFile;
  Uint8List? _jlptWebImageBytes;

  // Các Controller động tùy thuộc loại Activity được chọn
  final _jlptWordController = TextEditingController();
  final _jlptHiraganaController = TextEditingController();
  final _jlptMeaningController = TextEditingController();
  final _jlptKanjiController = TextEditingController();
  final _jlptGrammarStructureController = TextEditingController();
  final _jlptGrammarUsageController = TextEditingController();
  final _jlptGrammarExampleController = TextEditingController();
  final _jlptGrammarExampleMeaningController = TextEditingController();

  // --- Controller cho các LessonType mới ---
  final _jlptQuizQuestionController = TextEditingController();
  final _jlptQuizAnswerController = TextEditingController();
  final _jlptQuizOptionsController = TextEditingController();
  final _jlptQuizExplanationController = TextEditingController();
  final _jlptMatchingPairsController = TextEditingController();
  final _jlptImageQuizAnswerController = TextEditingController();
  final _jlptImageQuizOptionsController = TextEditingController();
  XFile? _jlptImageQuizXFile;
  Uint8List? _jlptImageQuizWebBytes;
  String? _jlptImageQuizOldUrl;
  final _jlptSbJpController = TextEditingController();
  final _jlptSbWordsController = TextEditingController();
  final _jlptSbAnswerController = TextEditingController();
  final _jlptKanjiCharController = TextEditingController();
  final _jlptKanjiMeaningController = TextEditingController();
  final _jlptKanjiStrokesController = TextEditingController();
  final _jlptFcHiraganaController = TextEditingController();
  final _jlptFcKanjiController = TextEditingController();
  final _jlptFcMeaningController = TextEditingController();
  final _jlptVqHiraganaController = TextEditingController();
  final _jlptVqKanjiController = TextEditingController();
  final _jlptVqOptionsController = TextEditingController();
  final _jlptVqAnswerController = TextEditingController();
  final _jlptVsWordsController = TextEditingController();
  final _jlptSpkJpController = TextEditingController();
  final _jlptSpkAnswerController = TextEditingController();
  final _jlptGliWordController = TextEditingController();
  final _jlptGliMeaningController = TextEditingController();
  final _jlptAudioTextController = TextEditingController();
  final _jlptDeleteOrderController = TextEditingController();

  Future<void> _pickJlptImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        setState(() {
          _jlptSelectedXFile = image;
          _jlptWebImageBytes = bytes;
        });
      } else {
        setState(() {
          _jlptSelectedXFile = image;
        });
      }
    }
  }

  Future<void> _pickImageQuizImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        setState(() {
          _jlptImageQuizXFile = image;
          _jlptImageQuizWebBytes = bytes;
        });
      } else {
        setState(() {
          _jlptImageQuizXFile = image;
        });
      }
    }
  }

  Future<void> _submitJlpt() async {
    if (!_jlptFormKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      String imageUrl = "";
      if (_jlptActivityType == 'vocabListIntro' || _jlptActivityType == 'learn' || _jlptActivityType == 'grammarListIntro') {
        if (_jlptSelectedXFile != null) {
          final Uint8List imgBytes = await _jlptSelectedXFile!.readAsBytes();
          final uploadedUrl = await _uploadToCloudinary(imgBytes, _jlptSelectedXFile!.name);
          if (uploadedUrl != null) imageUrl = uploadedUrl;
        } else if (_editingJlptActivityId != null) {
          imageUrl = _editingJlptOldImageUrl ?? "";
        }
      }

      final String lessonDocId = "${_jlptLevel.toLowerCase()}_lesson_${_jlptLessonIdController.text.trim()}";
      final int orderIndex = int.tryParse(_jlptOrderController.text.trim()) ?? 0;

      await FirebaseFirestore.instance.collection('jlpt_lessons').doc(lessonDocId).set({
        'id': lessonDocId,
        'level': _jlptLevel,
        'title': _jlptTitleController.text.trim(),
        'order': orderIndex,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      Map<String, dynamic> activityData = {
        'type': _jlptActivityType,
        'order': orderIndex,
      };

      final String audioText = _jlptAudioTextController.text.trim();
      if (audioText.isNotEmpty) {
        activityData['audio_text'] = audioText;
      }

      if (_jlptActivityType == 'vocabListIntro' || _jlptActivityType == 'learn') {
        activityData.addAll({
          'word': _jlptWordController.text.trim(),
          'hiragana': _jlptHiraganaController.text.trim(),
          'meaning': _jlptMeaningController.text.trim(),
          'kanji': _jlptKanjiController.text.trim(),
          'image': imageUrl,
        });
      } else if (_jlptActivityType == 'grammarListIntro') {
        activityData.addAll({
          'word': _jlptGliWordController.text.trim(),
          'meaning': _jlptGliMeaningController.text.trim(),
          'image': imageUrl,
        });
      } else if (_jlptActivityType == 'grammarStructure') {
        activityData.addAll({
          'structure': _jlptGrammarStructureController.text.trim(),
          'meaning': _jlptMeaningController.text.trim(),
        });
      } else if (_jlptActivityType == 'grammarUsage') {
        activityData.addAll({
          'usage': _jlptGrammarUsageController.text.trim(),
        });
      } else if (_jlptActivityType == 'grammarExample') {
        activityData.addAll({
          'example': _jlptGrammarExampleController.text.trim(),
          'meaning': _jlptGrammarExampleMeaningController.text.trim(),
        });
      } else if (_jlptActivityType == 'quiz') {
        final List<String> opts = _jlptQuizOptionsController.text
            .split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        activityData.addAll({
          'question': _jlptQuizQuestionController.text.trim(),
          'answer': _jlptQuizAnswerController.text.trim(),
          'options': opts,
          'explanation': _jlptQuizExplanationController.text.trim(),
        });
      } else if (_jlptActivityType == 'matching') {
        final List<Map<String, String>> pairs = _jlptMatchingPairsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.contains(':'))
            .map((e) {
              final parts = e.split(':');
              return {'word': parts[0].trim(), 'meaning': parts.sublist(1).join(':').trim()};
            }).toList();
        activityData['pairs'] = pairs;
      } else if (_jlptActivityType == 'imageQuiz') {
        String iqImageUrl = _jlptImageQuizOldUrl ?? "";
        if (_jlptImageQuizXFile != null) {
          final Uint8List iqBytes = await _jlptImageQuizXFile!.readAsBytes();
          final up = await _uploadToCloudinary(iqBytes, _jlptImageQuizXFile!.name);
          if (up != null) iqImageUrl = up;
        }
        final List<String> opts = _jlptImageQuizOptionsController.text
            .split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        activityData.addAll({
          'image': iqImageUrl,
          'options': opts,
          'answer': _jlptImageQuizAnswerController.text.trim(),
        });
      } else if (_jlptActivityType == 'sentenceBuilder') {
        final List<String> words = _jlptSbWordsController.text
            .split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        activityData.addAll({
          'jp': _jlptSbJpController.text.trim(),
          'words': words,
          'answer': _jlptSbAnswerController.text.trim(),
        });
      } else if (_jlptActivityType == 'kanjiDraw') {
        activityData.addAll({
          'char': _jlptKanjiCharController.text.trim(),
          'meaning': _jlptKanjiMeaningController.text.trim(),
          'strokes': int.tryParse(_jlptKanjiStrokesController.text.trim()) ?? 0,
        });
      } else if (_jlptActivityType == 'flashCard') {
        activityData.addAll({
          'hiragana': _jlptFcHiraganaController.text.trim(),
          'kanji': _jlptFcKanjiController.text.trim(),
          'meaning': _jlptFcMeaningController.text.trim(),
        });
      } else if (_jlptActivityType == 'vocabQuiz') {
        final List<String> opts = _jlptVqOptionsController.text
            .split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        activityData.addAll({
          'hiragana': _jlptVqHiraganaController.text.trim(),
          'kanji': _jlptVqKanjiController.text.trim(),
          'options': opts,
          'answer': _jlptVqAnswerController.text.trim(),
        });
      } else if (_jlptActivityType == 'vocabSummary') {
        final List<Map<String, String>> words = _jlptVsWordsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .map((e) {
              final parts = e.split(':');
              return {
                'word': parts.isNotEmpty ? parts[0].trim() : '',
                'hiragana': parts.length > 1 ? parts[1].trim() : '',
                'meaning': parts.length > 2 ? parts.sublist(2).join(':').trim() : '',
              };
            }).toList();
        activityData['list'] = words;
      } else if (_jlptActivityType == 'speaking') {
        activityData.addAll({
          'jp': _jlptSpkJpController.text.trim(),
          'answer': _jlptSpkAnswerController.text.trim(),
        });
      } else if (_jlptActivityType == 'listening') {
        final List<String> opts = _jlptQuizOptionsController.text
            .split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        activityData.addAll({
          'answer': _jlptQuizAnswerController.text.trim(),
          'options': opts,
          'explanation': _jlptQuizExplanationController.text.trim(),
        });
      }

      if (_editingJlptActivityId != null) {
        await FirebaseFirestore.instance
            .collection('jlpt_lessons')
            .doc(_editingJlptLessonId)
            .collection('activities')
            .doc(_editingJlptActivityId)
            .set(activityData, SetOptions(merge: true));
        _showSnackBar("Đã cập nhật khung bài học JLPT thành công!");
      } else {
        await FirebaseFirestore.instance
            .collection('jlpt_lessons')
            .doc(lessonDocId)
            .collection('activities')
            .add(activityData);
        _showSnackBar("Đã lưu khung bài học JLPT thành công!");
      }

      _resetJlptFields();
      setState(() {
        _editingJlptActivityId = null;
        _editingJlptLessonId = null;
        _editingJlptOldImageUrl = null;
        _jlptImageQuizOldUrl = null;
      });
    } catch (e) {
      _showSnackBar("Lỗi ghi Firestore: $e");
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _resetJlptFields() {
    _jlptWordController.clear();
    _jlptHiraganaController.clear();
    _jlptMeaningController.clear();
    _jlptKanjiController.clear();
    _jlptGrammarStructureController.clear();
    _jlptGrammarUsageController.clear();
    _jlptGrammarExampleController.clear();
    _jlptGrammarExampleMeaningController.clear();
    _jlptAudioTextController.clear();
    _jlptQuizQuestionController.clear();
    _jlptQuizAnswerController.clear();
    _jlptQuizOptionsController.clear();
    _jlptQuizExplanationController.clear();
    _jlptMatchingPairsController.clear();
    _jlptImageQuizAnswerController.clear();
    _jlptImageQuizOptionsController.clear();
    _jlptSbJpController.clear();
    _jlptSbWordsController.clear();
    _jlptSbAnswerController.clear();
    _jlptKanjiCharController.clear();
    _jlptKanjiMeaningController.clear();
    _jlptKanjiStrokesController.clear();
    _jlptFcHiraganaController.clear();
    _jlptFcKanjiController.clear();
    _jlptFcMeaningController.clear();
    _jlptVqHiraganaController.clear();
    _jlptVqKanjiController.clear();
    _jlptVqOptionsController.clear();
    _jlptVqAnswerController.clear();
    _jlptVsWordsController.clear();
    _jlptSpkJpController.clear();
    _jlptSpkAnswerController.clear();
    _jlptGliWordController.clear();
    _jlptGliMeaningController.clear();
    setState(() {
      _jlptSelectedXFile = null;
      _jlptWebImageBytes = null;
      _jlptImageQuizXFile = null;
      _jlptImageQuizWebBytes = null;
    });
  }

  // ==========================================================
  // 2. PHẦN TAB 1: QUẢN LÝ LUYỆN NGHE (LISTENING) - ĐÃ ĐỒNG BỘ BÀI HỌC
  // ==========================================================
  final _listenFormKey = GlobalKey<FormState>();
  final _listenLessonTitleIdController = TextEditingController();
  final _listenOrderController = TextEditingController();
  final _listenQuestionIdController = TextEditingController();
  final _listenOptionsController = TextEditingController();
  final _listenCorrectController = TextEditingController();
  final _listenExplainController = TextEditingController();
  final _listenDeleteQuestionIdController = TextEditingController();

  XFile? _listenSelectedAudioXFile;
  XFile? _listenSelectedImageXFile;
  Uint8List? _listenWebImageBytes;
  Uint8List? _listenAudioBytes;
  String _listenAudioName = "";


    Future<void> _pickListenAudio() async {
      try {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.audio,
          withData: true,
        );

        if (result != null && result.files.single.bytes != null) {
          setState(() {
            _listenAudioBytes = result.files.single.bytes;
            _listenAudioName = result.files.single.name;
            _listenSelectedAudioXFile = XFile(result.files.single.path ?? '');
          });
          _showSnackBar("Đã chọn file âm thanh: ${result.files.single.name}");
        } else if (result != null && result.files.single.path != null) {
          final io.File localFile = io.File(result.files.single.path!);
          final bytes = await localFile.readAsBytes();
          setState(() {
            _listenAudioBytes = bytes;
            _listenAudioName = result.files.single.name;
            _listenSelectedAudioXFile = XFile(result.files.single.path!);
          });
          _showSnackBar("Đã chọn file âm thanh: ${result.files.single.name}");
        }
      } catch (e) {
        print("Lỗi chọn file audio: $e");
        _showSnackBar("Không thể mở trình quản lý âm thanh: $e");
      }
    }

  Future<void> _pickListenQuestionImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        setState(() {
          _listenSelectedImageXFile = image;
          _listenWebImageBytes = bytes;
        });
      } else {
        setState(() {
          _listenSelectedImageXFile = image;
        });
      }
    }
  }

  Future<void> _submitListening() async {
    if (!_listenFormKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      String audioUrl = "";
      String questionImageUrl = "";

      if (_listenSelectedAudioXFile != null) {
        final upAudio = await _uploadToCloudinary(_listenAudioBytes!, _listenAudioName);
        if (upAudio != null) audioUrl = upAudio;
      } else if (_editingListenLessonId != null) {
        audioUrl = _editingListenOldAudioUrl ?? "";
      }

      if (_listenSelectedImageXFile != null) {
        final Uint8List imgBytes = await _listenSelectedImageXFile!.readAsBytes();
        final upImg = await _uploadToCloudinary(imgBytes, _listenSelectedImageXFile!.name);
        if (upImg != null) questionImageUrl = upImg;
      } else if (_editingListenQuestionId != null) {
        questionImageUrl = _editingListenOldImageUrl ?? "";
      }

      final String rawTitle = _listenLessonTitleIdController.text.trim();
      final String listenDocId = "listening_lesson_${rawTitle.replaceAll(' ', '_')}";
      final int orderIndex = int.tryParse(_listenOrderController.text.trim()) ?? 0;
      final int qId = int.tryParse(_listenQuestionIdController.text.trim()) ?? 1;

      List<String> optionsList = _listenOptionsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      Map<String, dynamic> mainLessonData = {
        'id': listenDocId,
        'title': "$rawTitle ($_listeningLevel)",
        'level': _listeningLevel,
        'order': orderIndex,
        'audio_text': _jlptAudioTextController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (audioUrl.isNotEmpty) {
        mainLessonData['audioAsset'] = audioUrl;
      }

      final String activeLessonId = _editingListenLessonId ?? listenDocId;
      final String activeQuestionId = _editingListenQuestionId ?? "question_$qId";

      await FirebaseFirestore.instance
          .collection('listening_lessons')
          .doc(activeLessonId)
          .set(mainLessonData, SetOptions(merge: true));

      await FirebaseFirestore.instance
          .collection('listening_lessons')
          .doc(activeLessonId)
          .collection('questions')
          .doc(activeQuestionId)
          .set({
        'id': qId,
        'q_image': questionImageUrl.isNotEmpty ? questionImageUrl : null,
        'options': optionsList,
        'correct': _listenCorrectController.text.trim().toUpperCase(),
        'explanation': _listenExplainController.text.trim(),
      });

      // SỬA LỖI: Đổi thông báo hiển thị từ "bài đọc" thành "bài nghe" cho đúng phân hệ
      _showSnackBar(_editingListenQuestionId != null ? "Đã cập nhật câu hỏi luyện nghe!" : "Đã lưu câu hỏi nghe thành công!");

      // SỬA LỖI: Xóa nội dung các ô nhập câu hỏi nghe, KHÔNG xóa nhầm ô của bài đọc
      _listenOptionsController.clear();
      _listenCorrectController.clear();
      _listenExplainController.clear();

      // BỔ SUNG BƯỚC 2: Tự động tăng Mã số câu hỏi nghe (qId) lên thêm 1 số để phục vụ nhập chuỗi 24 câu
      int currentQId = int.tryParse(_listenQuestionIdController.text.trim()) ?? 1;
      _listenQuestionIdController.text = (currentQId + 1).toString();

      setState(() {
        _listenSelectedImageXFile = null; // Xóa ảnh cũ của câu hỏi trước, giữ lại file nghe tổng
        _listenWebImageBytes = null;
        _editingListenQuestionId = null;
        _editingListenLessonId = null;
        _editingListenOldImageUrl = null;
        _editingListenOldAudioUrl = null;
      });
    } catch (e) {
      _showSnackBar("Lỗi ghi bài nghe: $e"); // SỬA LỖI: Log chuẩn thông báo lỗi phần Nghe
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // Hàm dọn dẹp sạch form hoàn toàn (chỉ gọi khi bấm nút HỦY hoặc reset toàn bộ bài nghe mới)
  void _resetListeningFields() {
    _listenLessonTitleIdController.clear(); // Xóa sạch cả tiêu đề[cite: 1]
    _listenOrderController.clear();
    _listenQuestionIdController.clear();
    _listenOptionsController.clear();
    _listenCorrectController.clear();
    _listenExplainController.clear();
    _jlptAudioTextController.clear(); // Xóa sạch ô nhập Script hội thoại[cite: 1]
    setState(() {
      _listenSelectedImageXFile = null;
      _listenSelectedAudioXFile = null;
      _listenWebImageBytes = null;
    });
  }

  // ==========================================================
  // 3. PHẦN TAB 2: QUẢN LÝ LUYỆN ĐỌC (READING) - ĐÃ ĐỒNG BỘ BÀI HỌC
  // ==========================================================
  final _readFormKey = GlobalKey<FormState>();
  final _readLessonTitleIdController = TextEditingController();
  final _readOrderController = TextEditingController();
  final _readPartOrderController = TextEditingController();
  final _readDeleteQuestionIdController = TextEditingController();

  String _readType = 'instruction'; // instruction hoặc question

  final _readInstructionController = TextEditingController();
  final _readPassageController = TextEditingController();
  final _readQuestionController = TextEditingController();
  final _readCorrectController = TextEditingController();
  final _readExplainController = TextEditingController();
  final _readOptionsController = TextEditingController();

  Future<void> _submitReading() async {
    if (!_readFormKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
        String readImageUrl = "";
        if (_jlptSelectedXFile != null) {
            final Uint8List imgBytes = await _jlptSelectedXFile!.readAsBytes();
            final uploadedUrl = await _uploadToCloudinary(imgBytes, _jlptSelectedXFile!.name);
            if (uploadedUrl != null) readImageUrl = uploadedUrl;
        } else if (_editingReadPartId != null) {
            readImageUrl = _editingJlptOldImageUrl ?? "";
        }
      final String rawReadTitle = _readLessonTitleIdController.text.trim();
      final String readDocId = "reading_lesson_${rawReadTitle.replaceAll(' ', '_')}";
      final int mainOrder = int.tryParse(_readOrderController.text.trim()) ?? 0;
      final int partOrder = int.tryParse(_readPartOrderController.text.trim()) ?? 1;

      await FirebaseFirestore.instance.collection('reading_lessons').doc(_editingReadLessonId ?? readDocId).set({
        'id': _editingReadLessonId ?? readDocId,
        'title': "$rawReadTitle ($_readingLevel)",
        'level': _readingLevel,
        'order': mainOrder,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      Map<String, dynamic> partData = {
        'type': _readType,
        'partOrder': partOrder,
      };

      if (_readType == 'instruction') {
        partData['text'] = _readInstructionController.text.trim();
      } else {
        List<String> rOptions = _readOptionsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        partData.addAll({
          'id': partOrder,
          'read_image': readImageUrl,
          'passage': _readPassageController.text.trim(),
          'question': _readQuestionController.text.trim(),
          'options': rOptions,
          'correct': _readCorrectController.text.trim().toUpperCase(),
          'explanation': _readExplainController.text.trim(),
        });
      }

      final String activeLessonId = _editingReadLessonId ?? readDocId;
      final String activePartId = _editingReadPartId ?? "part_$partOrder";

      await FirebaseFirestore.instance
          .collection('reading_lessons')
          .doc(activeLessonId)
          .collection('parts')
          .doc(activePartId)
          .set(partData);

      _showSnackBar(_editingReadPartId != null ? "Đã cập nhật phân đoạn bài đọc!" : "Đã lưu cấu trúc khung đọc hiểu thành công!");
      _resetReadingFields();
      setState(() {
        _jlptSelectedXFile = null; // Reset file ảnh sau khi lưu
        _jlptWebImageBytes = null;
      });

      int currentPartOrder = int.tryParse(_readPartOrderController.text.trim()) ?? 1;
      _readPartOrderController.text = (currentPartOrder + 1).toString();
      setState(() {
        _editingReadPartId = null;
        _editingReadLessonId = null;
      });
    } catch (e) {
      _showSnackBar("Lỗi ghi bài đọc: $e");
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _resetReadingFields() {
    _readInstructionController.clear();
    _readPassageController.clear();
    _readQuestionController.clear();
    _readCorrectController.clear();
    _readExplainController.clear();
    _readOptionsController.clear();
  }

  // ==========================================================
  // HÀM BUILD GIAO DIỆN CHÍNH
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    Widget contentBody;
    switch (_selectedTab) {
      case 0:
        contentBody = _buildJlptTab();
        break;
      case 1:
        contentBody = _buildListeningTab();
        break;
      case 2:
        contentBody = _buildReadingTab();
        break;
      default:
        contentBody = const Center(child: Text("Không tìm thấy trang"));
    }

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text("ADMIN PANEL SYSTEM", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              backgroundColor: const Color(0xFF3366FF),
              centerTitle: true,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: Container(
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildBottomNavButton(0, Icons.menu_book, "JLPT"),
                      _buildBottomNavButton(1, Icons.headphones, "Luyện Nghe"),
                      _buildBottomNavButton(2, Icons.chrome_reader_mode, "Luyện Đọc"),
                    ],
                  ),
                ),
              ),
            )
          : null,
      body: _isSaving
          ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(height: 16), Text("Đang đồng bộ dữ liệu & upload đám mây...", style: TextStyle(fontWeight: FontWeight.w500))]))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: contentBody,
            ),
    );
  }

  Widget _buildBottomNavButton(int index, IconData icon, String label) {
    bool isSelected = _selectedTab == index;
    return TextButton.icon(
      onPressed: () => setState(() => _selectedTab = index),
      icon: Icon(icon, color: isSelected ? const Color(0xFF3366FF) : Colors.grey),
      label: Text(label, style: TextStyle(color: isSelected ? const Color(0xFF3366FF) : Colors.grey, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
    );
  }

  // ==========================================================
  // WIDGET GIAO DIỆN CHI TIẾT TỪNG TAB (GIỮ NGUYÊN GIAO DIỆN UI CŨ)
  // ==========================================================
  Widget _buildJlptTab() {
    return Form(
      key: _jlptFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_editingJlptActivityId != null ? "CẬP NHẬT HOẠT ĐỘNG BÀI HỌC JLPT" : "THÊM NỘI DUNG BÀI HỌC TỪ VỰNG & NGỮ PHÁP JLPT", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3366FF))),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _jlptLevel,
                  decoration: const InputDecoration(labelText: "Cấp độ JLPT", border: OutlineInputBorder()),
                  items: ['N5', 'N4', 'N3'].map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                  onChanged: (val) => setState(() => _jlptLevel = val!),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _jlptLessonIdController,
                  decoration: const InputDecoration(labelText: "Mã số bài (Ví dụ: 1, 2)", border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? "Không được bỏ trống" : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _jlptTitleController,
                  decoration: const InputDecoration(labelText: "Tên tiêu đề bài học (Ví dụ: Bài 1: Chào hỏi)", border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? "Không được bỏ trống" : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _jlptOrderController,
                  decoration: const InputDecoration(labelText: "Thứ tự hiển thị Activity (Số nguyên)", border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? "Không được bỏ trống" : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            value: _jlptActivityType,
            decoration: const InputDecoration(labelText: "Loại Activity thiết kế", border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'vocabListIntro', child: Text("📖 Giới thiệu từ vựng chính")),
              DropdownMenuItem(value: 'learn', child: Text("🃏 Thẻ học từ vựng chi tiết")),
              DropdownMenuItem(value: 'flashCard', child: Text("⚡ FlashCard lật thẻ")),
              DropdownMenuItem(value: 'vocabSummary', child: Text("📋 Tổng kết danh sách từ vựng")),
              DropdownMenuItem(value: 'quiz', child: Text("❓ Quiz trắc nghiệm")),
              DropdownMenuItem(value: 'vocabQuiz', child: Text("🔤 Quiz từ vựng (chọn nghĩa)")),
              DropdownMenuItem(value: 'imageQuiz', child: Text("🖼️ Quiz nhìn ảnh đoán từ")),
              DropdownMenuItem(value: 'matching', child: Text("🔗 Nối từ với nghĩa")),
              DropdownMenuItem(value: 'sentenceBuilder', child: Text("🔀 Sắp xếp câu")),
              DropdownMenuItem(value: 'listening', child: Text("🎧 Nghe và chọn đáp án")),
              DropdownMenuItem(value: 'speaking', child: Text("🎤 Nói lại câu")),
              DropdownMenuItem(value: 'kanjiDraw', child: Text("✏️ Viết chữ Kanji")),
              DropdownMenuItem(value: 'grammarListIntro', child: Text("📗 Giới thiệu ngữ pháp chính")),
              DropdownMenuItem(value: 'grammarStructure', child: Text("🏗️ Ngữ pháp: Cấu trúc mẫu")),
              DropdownMenuItem(value: 'grammarUsage', child: Text("📝 Ngữ pháp: Cách dùng")),
              DropdownMenuItem(value: 'grammarExample', child: Text("💬 Ngữ pháp: Ví dụ minh họa")),
            ],
            onChanged: (val) => setState(() => _jlptActivityType = val!),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),

          if (_jlptActivityType == 'vocabListIntro' || _jlptActivityType == 'learn') ...[
            TextFormField(controller: _jlptWordController, decoration: const InputDecoration(labelText: "Từ vựng / Chữ Kanji chính", border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextFormField(controller: _jlptHiraganaController, decoration: const InputDecoration(labelText: "Cách đọc Hiragana / Furigana", border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextFormField(controller: _jlptMeaningController, decoration: const InputDecoration(labelText: "Ý nghĩa tiếng Việt", border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextFormField(controller: _jlptKanjiController, decoration: const InputDecoration(labelText: "Giải nghĩa các bộ Kanji đi kèm (nếu có)", border: OutlineInputBorder())),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton.icon(onPressed: _pickJlptImage, icon: const Icon(Icons.image), label: const Text("Chọn ảnh minh họa")),
                const SizedBox(width: 16),
                _jlptSelectedXFile != null
                    ? (kIsWeb && _jlptWebImageBytes != null
                        ? Image.memory(_jlptWebImageBytes!, width: 100, height: 100, fit: BoxFit.cover)
                        : const Text("Đã chọn file trên thiết bị mobile"))
                    : (_editingJlptOldImageUrl != null && _editingJlptOldImageUrl!.isNotEmpty
                        ? Image.network(_editingJlptOldImageUrl!, width: 100, height: 100, fit: BoxFit.cover)
                        : const Text("Chưa chọn hình ảnh", style: TextStyle(color: Colors.grey))),
              ],
            )
          ] else if (_jlptActivityType == 'grammarStructure') ...[
            TextFormField(controller: _jlptGrammarStructureController, decoration: const InputDecoration(labelText: "Mẫu câu cấu trúc ngữ pháp", border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextFormField(controller: _jlptMeaningController, decoration: const InputDecoration(labelText: "Ý nghĩa mẫu câu", border: OutlineInputBorder())),
          ] else if (_jlptActivityType == 'grammarUsage') ...[
            TextFormField(controller: _jlptGrammarUsageController, maxLines: 3, decoration: const InputDecoration(labelText: "Giải thích chi tiết cách dùng ngữ pháp", border: OutlineInputBorder())),
          ] else if (_jlptActivityType == 'grammarListIntro') ...[
            TextFormField(controller: _jlptGliWordController, decoration: const InputDecoration(labelText: "Mẫu ngữ pháp / Từ khóa chính", border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextFormField(controller: _jlptGliMeaningController, decoration: const InputDecoration(labelText: "Ý nghĩa tiếng Việt", border: OutlineInputBorder())),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton.icon(onPressed: _pickJlptImage, icon: const Icon(Icons.image), label: const Text("Chọn ảnh minh họa")),
                const SizedBox(width: 16),
                _jlptSelectedXFile != null
                    ? (kIsWeb && _jlptWebImageBytes != null
                        ? Image.memory(_jlptWebImageBytes!, width: 100, height: 100, fit: BoxFit.cover)
                        : const Text("Đã chọn file"))
                    : (_editingJlptOldImageUrl != null && _editingJlptOldImageUrl!.isNotEmpty
                        ? Image.network(_editingJlptOldImageUrl!, width: 100, height: 100, fit: BoxFit.cover)
                        : const Text("Chưa chọn hình ảnh", style: TextStyle(color: Colors.grey))),
              ],
            ),
          ] else if (_jlptActivityType == 'quiz') ...[
            TextFormField(
              controller: _jlptQuizQuestionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Nội dung câu hỏi",
                hintText: "Ví dụ: 「＿＿」に正しいものを選んでください。",
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? "Nhập câu hỏi" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _jlptQuizOptionsController,
              decoration: const InputDecoration(
                labelText: "Các đáp án (ngăn cách bằng dấu phẩy)",
                hintText: "Ví dụ: が, を, に, で",
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? "Nhập các đáp án" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _jlptQuizAnswerController,
              decoration: const InputDecoration(
                labelText: "Đáp án đúng (chính xác như một trong các đáp án trên)",
                hintText: "Ví dụ: が",
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? "Nhập đáp án đúng" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _jlptQuizExplanationController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: "Giải thích đáp án (tùy chọn)", border: OutlineInputBorder()),
            ),
          ] else if (_jlptActivityType == 'vocabQuiz') ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
              child: const Text("💡 Quiz từ vựng: hiển thị chữ Kanji/Hiragana, người học chọn nghĩa đúng.", style: TextStyle(color: Colors.blueGrey, fontSize: 13)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: TextFormField(controller: _jlptVqHiraganaController, decoration: const InputDecoration(labelText: "Hiragana", hintText: "Ví dụ: たべます", border: OutlineInputBorder()))),
                const SizedBox(width: 16),
                Expanded(child: TextFormField(controller: _jlptVqKanjiController, decoration: const InputDecoration(labelText: "Kanji (nếu có)", hintText: "Ví dụ: 食べます", border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _jlptVqOptionsController,
              decoration: const InputDecoration(
                labelText: "Các nghĩa để chọn (ngăn cách bằng dấu phẩy)",
                hintText: "Ví dụ: ăn, uống, ngủ, đọc",
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? "Nhập các đáp án nghĩa" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _jlptVqAnswerController,
              decoration: const InputDecoration(
                labelText: "Đáp án đúng (chính xác như một trong các nghĩa trên)",
                hintText: "Ví dụ: ăn",
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? "Nhập đáp án đúng" : null,
            ),
          ] else if (_jlptActivityType == 'imageQuiz') ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
              child: const Text("💡 Quiz ảnh: hiển thị ảnh, người học chọn từ/nghĩa phù hợp.", style: TextStyle(color: Colors.deepOrange, fontSize: 13)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(onPressed: _pickImageQuizImage, icon: const Icon(Icons.image), label: const Text("Chọn ảnh câu hỏi")),
                const SizedBox(width: 16),
                _jlptImageQuizXFile != null
                    ? (kIsWeb && _jlptImageQuizWebBytes != null
                        ? Image.memory(_jlptImageQuizWebBytes!, width: 100, height: 100, fit: BoxFit.cover)
                        : const Text("Đã chọn ảnh"))
                    : (_jlptImageQuizOldUrl != null && _jlptImageQuizOldUrl!.isNotEmpty
                        ? Image.network(_jlptImageQuizOldUrl!, width: 100, height: 100, fit: BoxFit.cover)
                        : const Text("Chưa chọn ảnh *", style: TextStyle(color: Colors.redAccent))),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _jlptImageQuizOptionsController,
              decoration: const InputDecoration(
                labelText: "Các đáp án để chọn (ngăn cách bằng dấu phẩy)",
                hintText: "Ví dụ: りんご, みかん, ぶどう, もも",
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? "Nhập các đáp án" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _jlptImageQuizAnswerController,
              decoration: const InputDecoration(
                labelText: "Đáp án đúng",
                hintText: "Ví dụ: りんご",
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? "Nhập đáp án đúng" : null,
            ),
          ] else if (_jlptActivityType == 'matching') ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(8)),
              child: const Text("💡 Mỗi cặp viết theo định dạng: từ:nghĩa — ngăn cách các cặp bằng dấu phẩy.\nVí dụ: 食べる:ăn, 飲む:uống, 寝る:ngủ", style: TextStyle(color: Colors.purple, fontSize: 13)),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _jlptMatchingPairsController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Các cặp từ ↔ nghĩa",
                hintText: "食べる:ăn, 飲む:uống, 寝る:ngủ, 読む:đọc",
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? "Nhập ít nhất 2 cặp" : null,
            ),
          ] else if (_jlptActivityType == 'sentenceBuilder') ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(8)),
              child: const Text("💡 Sắp xếp câu: người học kéo các từ để ghép thành câu hoàn chỉnh. Nhập các từ token sẽ được xáo trộn.", style: TextStyle(color: Colors.teal, fontSize: 13)),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _jlptSbJpController,
              decoration: const InputDecoration(
                labelText: "Câu tiếng Nhật hoàn chỉnh",
                hintText: "Ví dụ: 私は毎日学校に行きます。",
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? "Nhập câu hoàn chỉnh" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _jlptSbWordsController,
              decoration: const InputDecoration(
                labelText: "Các từ/cụm từ (token) để xáo trộn — ngăn cách bằng dấu phẩy",
                hintText: "Ví dụ: 私は, 毎日, 学校に, 行きます",
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? "Nhập các token từ" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _jlptSbAnswerController,
              decoration: const InputDecoration(
                labelText: "Đáp án đúng (thứ tự token ghép lại)",
                hintText: "Ví dụ: 私は 毎日 学校に 行きます",
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? "Nhập đáp án" : null,
            ),
          ] else if (_jlptActivityType == 'listening') ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
              child: const Text("💡 Activity nghe trong bài JLPT: nhập đoạn text sẽ được TTS đọc, người học nghe và chọn đáp án.", style: TextStyle(color: Colors.green, fontSize: 13)),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _jlptAudioTextController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Nội dung audio (Text-to-Speech sẽ đọc đoạn này)",
                hintText: "Ví dụ: 田中さんはどこに行きますか。",
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? "Nhập nội dung audio" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _jlptQuizOptionsController,
              decoration: const InputDecoration(
                labelText: "Các đáp án để chọn (ngăn cách bằng dấu phẩy)",
                hintText: "Ví dụ: コンビニ, 学校, 図書館, 公園",
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? "Nhập các đáp án" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _jlptQuizAnswerController,
              decoration: const InputDecoration(
                labelText: "Đáp án đúng",
                hintText: "Ví dụ: 学校",
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? "Nhập đáp án đúng" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _jlptQuizExplanationController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: "Giải thích đáp án (tùy chọn)", border: OutlineInputBorder()),
            ),
          ] else if (_jlptActivityType == 'speaking') ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
              child: const Text("💡 Luyện nói: hiển thị câu tiếng Nhật, người học nghe rồi nhấn mic để nói lại.", style: TextStyle(color: Colors.redAccent, fontSize: 13)),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _jlptSpkJpController,
              decoration: const InputDecoration(
                labelText: "Câu tiếng Nhật để luyện nói",
                hintText: "Ví dụ: おはようございます。",
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? "Nhập câu luyện nói" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _jlptSpkAnswerController,
              decoration: const InputDecoration(
                labelText: "Đáp án chuẩn để so sánh nhận dạng giọng nói",
                hintText: "Ví dụ: おはようございます",
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? "Nhập đáp án chuẩn" : null,
            ),
          ] else if (_jlptActivityType == 'grammarExample') ...[
            TextFormField(controller: _jlptGrammarExampleController, decoration: const InputDecoration(labelText: "Câu ví dụ tiếng Nhật", border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextFormField(controller: _jlptGrammarExampleMeaningController, decoration: const InputDecoration(labelText: "Ý nghĩa ví dụ tiếng Việt", border: OutlineInputBorder())),
          ] else if (_jlptActivityType == 'kanjiDraw') ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.brown.shade50, borderRadius: BorderRadius.circular(8)),
              child: const Text("💡 Luyện viết Kanji: người học nhìn nghĩa và viết chữ trên màn hình cảm ứng.", style: TextStyle(color: Colors.brown, fontSize: 13)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _jlptKanjiCharController,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      labelText: "Chữ Kanji cần viết",
                      hintText: "日",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? "Nhập chữ Kanji" : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _jlptKanjiStrokesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Số nét (strokes)",
                      hintText: "4",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _jlptKanjiMeaningController,
              decoration: const InputDecoration(
                labelText: "Ý nghĩa tiếng Việt",
                hintText: "Ví dụ: mặt trời, ngày",
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? "Nhập ý nghĩa" : null,
            ),
          ] else if (_jlptActivityType == 'flashCard') ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(8)),
              child: const Text("💡 FlashCard: người học xem mặt trước (Hiragana/Kanji) rồi lật để xem nghĩa.", style: TextStyle(color: Colors.indigo, fontSize: 13)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: TextFormField(controller: _jlptFcHiraganaController, decoration: const InputDecoration(labelText: "Hiragana (mặt trước)", hintText: "Ví dụ: たべる", border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? "Nhập hiragana" : null)),
                const SizedBox(width: 16),
                Expanded(child: TextFormField(controller: _jlptFcKanjiController, decoration: const InputDecoration(labelText: "Kanji (mặt trước — tùy chọn)", hintText: "Ví dụ: 食べる", border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _jlptFcMeaningController,
              decoration: const InputDecoration(
                labelText: "Nghĩa tiếng Việt (mặt sau)",
                hintText: "Ví dụ: ăn",
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? "Nhập nghĩa" : null,
            ),
          ] else if (_jlptActivityType == 'vocabSummary') ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.cyan.shade50, borderRadius: BorderRadius.circular(8)),
              child: Text("💡 Tổng kết từ vựng: hiển thị danh sách toàn bộ từ đã học.\nĐịnh dạng mỗi từ: từ:hiragana:nghĩa — ngăn cách bằng dấu phẩy.\nVí dụ: 食べる:たべる:ăn, 飲む:のむ:uống", style: TextStyle(color: Colors.cyan.shade800, fontSize: 13)),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _jlptVsWordsController,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: "Danh sách từ vựng",
                hintText: "食べる:たべる:ăn, 飲む:のむ:uống, 寝る:ねる:ngủ",
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? "Nhập danh sách từ vựng" : null,
            ),
          ],

          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitJlpt,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3366FF)),
                  child: Text(_editingJlptActivityId != null ? "CẬP NHẬT JLPT" : "LƯU KHUNG JLPT", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              if (_editingJlptActivityId != null) ...[
                const SizedBox(width: 16),
                SizedBox(
                  width: 120,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      _resetJlptFields();
                      setState(() {
                        _editingJlptActivityId = null;
                        _editingJlptLessonId = null;
                        _editingJlptOldImageUrl = null;
                      });
                    },
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.grey)),
                    child: const Text("HỦY", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          const Divider(thickness: 1.5),
          const SizedBox(height: 10),
          const Text("CÔNG CỤ QUẢN LÝ & XÓA DỮ LIỆU JLPT", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _jlptDeleteOrderController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Thứ tự Activity cần xóa nhanh",
                          hintText: "Ví dụ: 1, 2, 5",
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final String lessonNum = _jlptLessonIdController.text.trim();
                          final String rawOrder = _jlptDeleteOrderController.text.trim();

                          if (lessonNum.isEmpty) {
                            _showSnackBar("Vui lòng điền 'Mã số bài' ở phía trên để xác định bài cần xóa!");
                            return;
                          }
                          if (rawOrder.isEmpty) {
                            _showSnackBar("Vui lòng điền số thứ tự Activity cần xóa!");
                            return;
                          }

                          final int? orderNum = int.tryParse(rawOrder);
                          if (orderNum == null) {
                            _showSnackBar("Số thứ tự phải là số nguyên hợp lệ!");
                            return;
                          }

                          final String lessonDocId = "${_jlptLevel.toLowerCase()}_lesson_$lessonNum";
                          _confirmDeleteActivityByOrder(lessonDocId, orderNum);
                          _jlptDeleteOrderController.clear();
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
                        icon: const Icon(Icons.delete, color: Colors.white, size: 18),
                        label: const Text("XÓA NHANH CÂU", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    final String lessonNum = _jlptLessonIdController.text.trim();
                    if (lessonNum.isEmpty) {
                      _showSnackBar("Vui lòng điền 'Mã số bài' ở phía trên trước!");
                      return;
                    }
                    final String lessonDocId = "${_jlptLevel.toLowerCase()}_lesson_$lessonNum";
                    // Gọi hàm xóa toàn bộ bài học cha + các activity con có sẵn của bạn
                    _confirmDeleteLesson('jlpt_lessons', lessonDocId);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade800,
                    minimumSize: const Size(double.infinity, 40),
                  ),
                  icon: const Icon(Icons.delete_forever, color: Colors.white, size: 18),
                  label: const Text("XÓA TOÀN BỘ BÀI HỌC JLPT NÀY", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListeningTab() {
    return Form(
      key: _listenFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_editingListenQuestionId != null ? "CẬP NHẬT CÂU HỎI LUYỆN NGHE" : "QUẢN LÝ BÀI TẬP LUYỆN NGHE", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
          const SizedBox(height: 20),
          Row(
            children: [
            Expanded(
             child: DropdownButtonFormField<String>(
                value: _listeningLevel,
                decoration: const InputDecoration(labelText: "Cấp độ", border: OutlineInputBorder()),
                items: ['N5', 'N4', 'N3', 'N2', 'N1'].map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                onChanged: (val) => setState(() => _listeningLevel = val!),
               ),
             ),
             const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _listenLessonTitleIdController,
                  decoration: const InputDecoration(labelText: "Tiêu đề bài nghe", border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? "Không được bỏ trống" : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _listenOrderController,
                  decoration: const InputDecoration(labelText: "Thứ tự", border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? "Không được bỏ trống" : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              ElevatedButton.icon(onPressed: _pickListenAudio, icon: const Icon(Icons.audiotrack, color: Colors.green), label: const Text("Tải file Audio lên")),
              const SizedBox(width: 16),
              Expanded(child: Text(_listenSelectedAudioXFile != null ? "Đã chọn: ${_listenSelectedAudioXFile!.name}" : (_editingListenOldAudioUrl != null ? "Đang lưu trữ liên kết: $_editingListenOldAudioUrl" : "Chưa chọn file nghe"), style: const TextStyle(color: Colors.grey, fontSize: 13), overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),
          const Text("CHI TIẾT CÂU HỎI TRẮC NGHIỆM ĐÍNH KÈM", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 16),
          Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _listenQuestionIdController,
                            decoration: const InputDecoration(
                              labelText: "Mã số câu hỏi",
                              hintText: "Ví dụ: 1, 2",
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? "Không bỏ trống" : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _listenCorrectController,
                            maxLength: 1,
                            decoration: const InputDecoration(
                              labelText: "Ký tự đáp án",
                              hintText: "A/B/C/D",
                              border: OutlineInputBorder(),
                              counterText: "", // Ẩn dòng đếm chữ "0/1" để không bị phình to làm lệch hàng
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            ),
                            validator: (v) => v!.isEmpty ? "Yêu cầu điền" : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _listenOptionsController,
                      decoration: const InputDecoration(labelText: "Mảng đáp án (Ngăn cách bởi dấu phẩy, Ví dụ: Đáp án A, Đáp án B, Đáp án C, Đáp án D)", border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? "Vui lòng điền các phương án" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(controller: _listenExplainController, maxLines: 2, decoration: const InputDecoration(labelText: "Lời giải thích đáp án chi tiết", border: OutlineInputBorder())),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickListenQuestionImage,
                          icon: const Icon(Icons.image),
                          label: const Text("Chọn ảnh câu hỏi")
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _listenSelectedImageXFile != null
                              ? (kIsWeb && _listenWebImageBytes != null
                                  ? Image.memory(_listenWebImageBytes!, width: 80, height: 80, fit: BoxFit.cover)
                                  : const Text("Đã chọn ảnh thành công", style: TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.bold)))
                              : (_editingListenOldImageUrl != null && _editingListenOldImageUrl!.isNotEmpty
                                  ? Image.network(_editingListenOldImageUrl!, width: 80, height: 80, fit: BoxFit.cover)
                                  : const Text("Chưa có ảnh minh họa", style: TextStyle(color: Colors.grey, fontSize: 13, overflow: TextOverflow.ellipsis))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 200,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _submitListening,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            child: Text(_editingListenQuestionId != null ? "CẬP NHẬT CÂU HỎI" : "LƯU CÂU HỎI NGHE", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                        if (_editingListenQuestionId != null) ...[
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 120,
                            height: 50,
                            child: OutlinedButton(
                              onPressed: () {
                                _resetListeningFields();
                                setState(() {
                                  _editingListenQuestionId = null;
                                  _editingListenLessonId = null;
                                  _editingListenOldImageUrl = null;
                                  _editingListenOldAudioUrl = null;
                                });
                              },
                              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.grey)),
                              child: const Text("HỦY", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ],
                    ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _listenDeleteQuestionIdController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Số câu nghe cần xóa nhanh",
                      hintText: "Ví dụ: 1, 2, 24",
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final String rawTitle = _listenLessonTitleIdController.text.trim();
                      final String qNum = _listenDeleteQuestionIdController.text.trim();

                      if (rawTitle.isEmpty) {
                        _showSnackBar("Vui lòng điền 'Tiêu đề bài nghe' ở trên để xác định bài cần xóa!");
                        return;
                      }
                      if (qNum.isEmpty) {
                        _showSnackBar("Vui lòng điền số câu nghe cần xóa!");
                        return;
                      }

                      final String listenDocId = "listening_lesson_${rawTitle.replaceAll(' ', '_')}";
                      // Định dạng chính xác ID câu hỏi con (question_1, question_2...) để kích hoạt hàm xóa
                      _confirmDeleteQuestion(listenDocId, "question_$qNum");
                      _listenDeleteQuestionIdController.clear();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
                    icon: const Icon(Icons.delete_sweep, color: Colors.white, size: 18),
                    label: const Text("XÓA NHANH CÂU", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingTab() {
    return Form(
      key: _readFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _editingReadPartId != null ? "CẬP NHẬT CẤU TRÚC ĐỌC HIỂU" : "QUẢN LÝ BÀI TẬP LUYỆN ĐỌC HIỂU",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple)
          ),
          const SizedBox(height: 20),

          // CẢI TIẾN ĐỘ RỘNG (FLEX): Chia tỷ lệ hợp lý cho thiết bị di động để tránh bị lỗi tràn viền (Overflow)
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _readingLevel,
                  decoration: const InputDecoration(
                    labelText: "Cấp độ",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  ),
                  items: ['N5', 'N4', 'N3', 'N2', 'N1'].map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                  onChanged: (val) => setState(() => _readingLevel = val!),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _readLessonTitleIdController,
                  decoration: const InputDecoration(
                    labelText: "Tiêu đề bài đọc",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  ),
                  validator: (v) => v!.isEmpty ? "Không được bỏ trống" : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _readOrderController,
                  decoration: const InputDecoration(
                    labelText: "Thứ tự bài",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? "Không bỏ trống" : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _readPartOrderController,
            decoration: const InputDecoration(labelText: "Thứ tự phân đoạn bên trong bài đọc (partOrder - Số nguyên)", border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
            validator: (v) => v!.isEmpty ? "Cần điền thứ tự phân đoạn" : null,
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            value: _readType,
            isExpanded: true, // Giúp nội dung chữ dài tự động xuống dòng, không làm hỏng cấu trúc form
            decoration: const InputDecoration(labelText: "Phân loại định dạng phân đoạn", border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'instruction', child: Text("Chuỗi chỉ dẫn tổng quát (instruction)", overflow: TextOverflow.ellipsis)),
              DropdownMenuItem(value: 'question', child: Text("Đoạn văn đọc hiểu và câu hỏi trắc nghiệm (question)", overflow: TextOverflow.ellipsis)),
            ],
            onChanged: (val) => setState(() => _readType = val!),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),

          if (_readType == 'instruction')
            TextFormField(
              controller: _readInstructionController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: "Nhập chuỗi văn bản chỉ dẫn (instruction)", border: OutlineInputBorder()),
              validator: (v) => _readType == 'instruction' && v!.isEmpty ? "Không được để trống" : null,
            )
          else ...[
            TextFormField(
              controller: _readPassageController,
              maxLines: 5,
              decoration: const InputDecoration(labelText: "Nhập đoạn văn tiếng Nhật dài (passage) - Có thể để trống nếu dùng ảnh hoặc chung bài", border: OutlineInputBorder()),
            ),

            // BỔ SUNG: Khu vực chọn ảnh sơ đồ, bảng biểu cho các dạng bài tra cứu thông tin (Mondai 10)
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickJlptImage,
                  icon: const Icon(Icons.image, color: Colors.purple),
                  label: const Text("Chọn ảnh sơ đồ / bảng biểu (nếu có)")
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _jlptSelectedXFile != null
                      ? (kIsWeb && _jlptWebImageBytes != null
                          ? Image.memory(_jlptWebImageBytes!, width: 80, height: 80, fit: BoxFit.cover)
                          : Text("Đã chọn ảnh sơ đồ: ${_jlptSelectedXFile!.name}", style: const TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis)))
                      : const Text("Không có ảnh sơ đồ bài đọc", style: TextStyle(color: Colors.grey, fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _readQuestionController,
              decoration: const InputDecoration(labelText: "Nhập câu hỏi đọc hiểu cụ thể", border: OutlineInputBorder()),
              validator: (v) => _readType == 'question' && v!.isEmpty ? "Không được để trống" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _readOptionsController,
              decoration: const InputDecoration(labelText: "Các lựa chọn trắc nghiệm (Ngăn cách bằng dấu phẩy. Ví dụ: Lựa chọn A, Lựa chọn B, Lựa chọn C, Lựa chọn D)", border: OutlineInputBorder()),
              validator: (v) => _readType == 'question' && v!.isEmpty ? "Không được để trống" : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _readCorrectController,
                    maxLength: 1,
                    decoration: const InputDecoration(labelText: "Đáp án đúng (A/B/C/D)", border: OutlineInputBorder()),
                    validator: (v) => _readType == 'question' && v!.isEmpty ? "Không được để trống" : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _readExplainController,
                    decoration: const InputDecoration(labelText: "Giải thích đáp án đọc hiểu", border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitReading,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                  child: Text(_editingReadPartId != null ? "CẬP NHẬT BÀI ĐỌC" : "LƯU ĐỌC HIỂU", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              if (_editingReadPartId != null) ...[
                const SizedBox(width: 16),
                SizedBox(
                  width: 120,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      _resetReadingFields();
                      setState(() {
                        _editingReadPartId = null;
                        _editingReadLessonId = null;
                      });
                    },
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.grey)),
                    child: const Text("HỦY", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ],
          ),
// ==========================================
          // BỔ SUNG: TIỆN ÍCH XÓA NHANH CÂU HỎI THEO SỐ
          // ==========================================
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _readDeleteQuestionIdController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Số câu cần xóa nhanh",
                      hintText: "Ví dụ: 1, 2, 3",
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final String rawTitle = _readLessonTitleIdController.text.trim();
                      final String qNum = _readDeleteQuestionIdController.text.trim();

                      if (rawTitle.isEmpty) {
                        _showSnackBar("Vui lòng điền 'Tiêu đề bài đọc' ở phía trên trước để xác định bài cần xóa!");
                        return;
                      }
                      if (qNum.isEmpty) {
                        _showSnackBar("Vui lòng điền số câu cần xóa!");
                        return;
                      }

                      final String lessonDocId = "reading_lesson_${rawTitle.replaceAll(' ', '_')}";
                      // Gọi hàm xác nhận xóa phân đoạn (part) với ID chính là số câu bạn nhập
                      _confirmDeletePart(lessonDocId, "part_$qNum");
                      _readDeleteQuestionIdController.clear();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
                    icon: const Icon(Icons.delete, color: Colors.white, size: 18),
                    label: const Text("XÓA NHANH CÂU", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

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

  // ==========================================================
  // HÀM UPLOAD MEDIA LÊN CLOUDINARY (DÙNG ĐƯỢC CẢ WEB & MOBILE)
  // ==========================================================
  Future<String?> _uploadToCloudinary(XFile xFile) async {
    try {
      final String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? "";
      final String uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? "";

      if (cloudName.isEmpty || uploadPreset.isEmpty) {
        _showSnackBar("Lỗi: Chưa cấu hình biến môi trường .env");
        return null;
      }

      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

      // Đọc file dưới dạng Bytes để tương thích với nền tảng Web
      final Uint8List bytes = await xFile.readAsBytes();
      final int length = bytes.length;

      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            length: length,
            filename: xFile.name,
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
  // 1. PHẦN TAB 0: QUẢN LÝ BÀI HỌC JLPT (TỪ VỰNG / NGỮ PHÁP)
  // ==========================================================
  final _jlptFormKey = GlobalKey<FormState>();
  final _jlptLessonIdController = TextEditingController();
  final _jlptOrderController = TextEditingController();
  final _jlptTitleController = TextEditingController();

  String _jlptLevel = 'N5';
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

  Future<void> _submitJlpt() async {
    if (!_jlptFormKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      String imageUrl = "";
      if (_jlptSelectedXFile != null) {
        final uploadedUrl = await _uploadToCloudinary(_jlptSelectedXFile!);
        if (uploadedUrl != null) {
          imageUrl = uploadedUrl;
        }
      }

      final String lessonDocId = "${_jlptLevel.toLowerCase()}_lesson_${_jlptLessonIdController.text.trim()}";
      final int orderIndex = int.tryParse(_jlptOrderController.text.trim()) ?? 0;

      // 1. Tạo hoặc cập nhật thông tin chung của bài học chính
      await FirebaseFirestore.instance.collection('jlpt_lessons').doc(lessonDocId).set({
        'id': lessonDocId,
        'level': _jlptLevel,
        'title': _jlptTitleController.text.trim(),
        'order': orderIndex,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 2. Thu thập dữ liệu cấu trúc activity tương ứng
      Map<String, dynamic> activityData = {
        'type': _jlptActivityType,
        'order': orderIndex,
      };

      if (_jlptActivityType == 'vocabListIntro' || _jlptActivityType == 'learn') {
        activityData.addAll({
          'word': _jlptWordController.text.trim(),
          'hiragana': _jlptHiraganaController.text.trim(),
          'meaning': _jlptMeaningController.text.trim(),
          'kanji': _jlptKanjiController.text.trim(),
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
      }

      // 3. Đẩy vào sub-collection 'activities' của bài học đó
      await FirebaseFirestore.instance
          .collection('jlpt_lessons')
          .doc(lessonDocId)
          .collection('activities')
          .add(activityData);

      _showSnackBar("Đã lưu khung bài học JLPT thành công!");
      _resetJlptFields();
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
    setState(() {
      _jlptSelectedXFile = null;
      _jlptWebImageBytes = null;
    });
  }

  // ==========================================================
  // 2. PHẦN TAB 1: QUẢN LÝ LUYỆN NGHE (LISTENING)
  // ==========================================================
  final _listenFormKey = GlobalKey<FormState>();
  final _listenLessonTitleIdController = TextEditingController();
  final _listenOrderController = TextEditingController();
  final _listenQuestionIdController = TextEditingController();
  final _listenOptionsController = TextEditingController();
  final _listenCorrectController = TextEditingController();
  final _listenExplainController = TextEditingController();

  XFile? _listenSelectedAudioXFile;
  XFile? _listenSelectedImageXFile;
  Uint8List? _listenWebImageBytes;

  Future<void> _pickListenAudio() async {
    final ImagePicker picker = ImagePicker();
    // Khuyên dùng pickVideo vì trên Web định dạng file âm thanh .mp3/.m4a
    // đôi khi được phân loại chung làm phương tiện truyền thông trực quan hoặc chọn tự do
    final XFile? audio = await picker.pickVideo(source: ImageSource.gallery);
    if (audio != null) {
      setState(() {
        _listenSelectedAudioXFile = audio;
      });
      _showSnackBar("Đã chọn file audio/video: ${audio.name}");
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
        final upAudio = await _uploadToCloudinary(_listenSelectedAudioXFile!);
        if (upAudio != null) audioUrl = upAudio;
      }
      if (_listenSelectedImageXFile != null) {
        final upImg = await _uploadToCloudinary(_listenSelectedImageXFile!);
        if (upImg != null) questionImageUrl = upImg;
      }

      final String listenDocId = "listening_lesson_${_listenLessonTitleIdController.text.trim().replaceAll(' ', '_')}";
      final int orderIndex = int.tryParse(_listenOrderController.text.trim()) ?? 0;
      final int qId = int.tryParse(_listenQuestionIdController.text.trim()) ?? 1;

      // Phân tách mảng các đáp án bằng dấu phẩy
      List<String> optionsList = _listenOptionsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      // 1. Cập nhật thông tin gốc bài nghe
      Map<String, dynamic> mainLessonData = {
        'id': listenDocId,
        'title': _listenLessonTitleIdController.text.trim(),
        'order': orderIndex,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (audioUrl.isNotEmpty) {
        mainLessonData['audioAsset'] = audioUrl;
      }

      await FirebaseFirestore.instance
          .collection('listening_lessons')
          .doc(listenDocId)
          .set(mainLessonData, SetOptions(merge: true));

      // 2. Đẩy danh sách câu hỏi trắc nghiệm đính kèm hình ảnh vào sub-collection 'questions'
      await FirebaseFirestore.instance
          .collection('listening_lessons')
          .doc(listenDocId)
          .collection('questions')
          .doc("question_$qId")
          .set({
        'id': qId,
        'q_image': questionImageUrl,
        'options': optionsList,
        'correct': _listenCorrectController.text.trim().toUpperCase(),
        'explanation': _listenExplainController.text.trim(),
      });

      _showSnackBar("Đã lưu câu hỏi luyện nghe thành công!");
      _resetListeningFields();
    } catch (e) {
      _showSnackBar("Lỗi ghi bài nghe: $e");
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _resetListeningFields() {
    _listenQuestionIdController.clear();
    _listenOptionsController.clear();
    _listenCorrectController.clear();
    _listenExplainController.clear();
    setState(() {
      _listenSelectedImageXFile = null;
      _listenWebImageBytes = null;
    });
  }

  // ==========================================================
  // 3. PHẦN TAB 2: QUẢN LÝ LUYỆN ĐỌC (READING)
  // ==========================================================
  final _readFormKey = GlobalKey<FormState>();
  final _readLessonTitleIdController = TextEditingController();
  final _readOrderController = TextEditingController();
  final _readPartOrderController = TextEditingController();

  String _readType = 'instruction'; // instruction hoặc question

  final _readInstructionController = TextEditingController();
  final _readPassageController = TextEditingController();
  final _readQuestionController = TextEditingController();
  final _readCorrectController = TextEditingController();
  final _readExplainController = TextEditingController();
  final _readOptionsController = TextEditingController(); // Phân tách mảng bằng dấu phẩy

  Future<void> _submitReading() async {
    if (!_readFormKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final String readDocId = "reading_lesson_${_readLessonTitleIdController.text.trim().replaceAll(' ', '_')}";
      final int mainOrder = int.tryParse(_readOrderController.text.trim()) ?? 0;
      final int partOrder = int.tryParse(_readPartOrderController.text.trim()) ?? 1;

      // 1. Khởi tạo bài đọc chính
      await FirebaseFirestore.instance.collection('reading_lessons').doc(readDocId).set({
        'id': readDocId,
        'title': _readLessonTitleIdController.text.trim(),
        'order': mainOrder,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 2. Thiết lập cấu trúc dữ liệu theo phân loại (Instruction / Question)
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
          'passage': _readPassageController.text.trim(),
          'question': _readQuestionController.text.trim(),
          'options': rOptions,
          'correct': _readCorrectController.text.trim().toUpperCase(),
          'explanation': _readExplainController.text.trim(),
        });
      }

      // 3. Đẩy vào sub-collection 'parts' chuyên biệt quản lý tuần tự bài đọc
      await FirebaseFirestore.instance
          .collection('reading_lessons')
          .doc(readDocId)
          .collection('parts')
          .doc("part_$partOrder")
          .set(partData);

      _showSnackBar("Đã lưu cấu trúc khung đọc hiểu thành công!");
      _resetReadingFields();
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
                      _buildBottomNavButton(0, Icons.menu_book, "JLPT N5"),
                      _buildBottomNavButton(1, Icons.headphones, "Luyện Nghe"),
                      _buildBottomNavButton(2, Icons.chrome_reader_mode, "Luyện Đọc"),
                    ],
                  ),
                ),
              ),
            )
          : null, // Nếu dùng trên Web Dashboard, Sidebar sẽ lo nhiệm vụ chuyển Tab, không cần AppBar này
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
  // WIDGET GIAO DIỆN CHI TIẾT TỪNG TAB
  // ==========================================================
  Widget _buildJlptTab() {
    return Form(
      key: _jlptFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("THÊM NỘI DUNG BÀI HỌC TỪ VỰNG & NGỮ PHÁP JLPT", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3366FF))),
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
              DropdownMenuItem(value: 'vocabListIntro', child: Text("Giới thiệu từ vựng chính")),
              DropdownMenuItem(value: 'learn', child: Text("Thẻ học từ vựng chi tiết")),
              DropdownMenuItem(value: 'grammarStructure', child: Text("Ngữ pháp: Cấu trúc mẫu")),
              DropdownMenuItem(value: 'grammarUsage', child: Text("Ngữ pháp: Cách dùng")),
              DropdownMenuItem(value: 'grammarExample', child: Text("Ngữ pháp: Ví dụ minh họa")),
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
                    : const Text("Chưa chọn hình ảnh", style: TextStyle(color: Colors.grey)),
              ],
            )
          ] else if (_jlptActivityType == 'grammarStructure') ...[
            TextFormField(controller: _jlptGrammarStructureController, decoration: const InputDecoration(labelText: "Mẫu câu cấu trúc ngữ pháp", border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextFormField(controller: _jlptMeaningController, decoration: const InputDecoration(labelText: "Ý nghĩa mẫu câu", border: OutlineInputBorder())),
          ] else if (_jlptActivityType == 'grammarUsage') ...[
            TextFormField(controller: _jlptGrammarUsageController, maxLines: 3, decoration: const InputDecoration(labelText: "Giải thích chi tiết cách dùng ngữ pháp", border: OutlineInputBorder())),
          ] else if (_jlptActivityType == 'grammarExample') ...[
            TextFormField(controller: _jlptGrammarExampleController, decoration: const InputDecoration(labelText: "Câu ví dụ tiếng Nhật", border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextFormField(controller: _jlptGrammarExampleMeaningController, decoration: const InputDecoration(labelText: "Giải nghĩa câu ví dụ", border: OutlineInputBorder())),
          ],

          const SizedBox(height: 32),
          Center(
            child: SizedBox(
              width: 250,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitJlpt,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3366FF)),
                child: const Text("LƯU KHUNG JLPT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          )
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
          const Text("QUẢN LÝ BÀI TẬP LUYỆN NGHE", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _listenLessonTitleIdController,
                  decoration: const InputDecoration(labelText: "Tiêu đề bài nghe (Ví dụ: Bài nghe số 1)", border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? "Không được bỏ trống" : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _listenOrderController,
                  decoration: const InputDecoration(labelText: "Thứ tự sắp xếp bài nghe", border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? "Không được bỏ trống" : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              ElevatedButton.icon(onPressed: _pickListenAudio, icon: const Icon(Icons.audiotrack, color: Colors.green), label: const Text("Tải file Audio lên Cloudinary")),
              const SizedBox(width: 16),
              Expanded(child: Text(_listenSelectedAudioXFile != null ? "Đã chọn: ${_listenSelectedAudioXFile!.name}" : "Chưa cập nhật file nghe chính", style: const TextStyle(color: Colors.grey, fontSize: 13), overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),
          const Text("CHI TIẾT CÂU HỎI TRẮC NGHIỆM ĐÍNH KÈM", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _listenQuestionIdController,
                  decoration: const InputDecoration(labelText: "Mã số câu hỏi (Số nguyên: 1, 2, 3)", border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? "Không bỏ trống" : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _listenCorrectController,
                  maxLength: 1,
                  decoration: const InputDecoration(labelText: "Ký tự đáp án đúng (A/B/C/D)", border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? "Yêu cầu điền đáp án đúng" : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _listenOptionsController,
            decoration: const InputDecoration(labelText: "Mảng các phương án lựa chọn (Cắt nhau bởi dấu phẩy, Ví dụ: Đáp án 1, Đáp án 2, Đáp án 3, Đáp án 4)", border: OutlineInputBorder()),
            validator: (v) => v!.isEmpty ? "Vui lòng điền các phương án" : null,
          ),
          const SizedBox(height: 16),
          TextFormField(controller: _listenExplainController, maxLines: 2, decoration: const InputDecoration(labelText: "Lời giải thích đáp án chi tiết", border: OutlineInputBorder())),
          const SizedBox(height: 20),
          Row(
            children: [
              ElevatedButton.icon(onPressed: _pickListenQuestionImage, icon: const Icon(Icons.image), label: const Text("Chọn ảnh câu hỏi (nếu có)")),
              const SizedBox(width: 16),
              _listenSelectedImageXFile != null
                  ? (kIsWeb && _listenWebImageBytes != null
                      ? Image.memory(_listenWebImageBytes!, width: 100, height: 100, fit: BoxFit.cover)
                      : const Text("Đã chọn ảnh trên mobile"))
                  : const Text("Chưa chọn ảnh minh họa câu hỏi", style: TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: SizedBox(
              width: 250,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitListening,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("LƯU CÂU HỎI NGHE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          )
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
          const Text("QUẢN LÝ BÀI TẬP LUYỆN ĐỌC HIỂU", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _readLessonTitleIdController,
                  decoration: const InputDecoration(labelText: "Tiêu đề bài đọc (Ví dụ: Bài đọc N5 số 1)", border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? "Không được bỏ trống" : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _readOrderController,
                  decoration: const InputDecoration(labelText: "Thứ tự sắp xếp bài đọc tổng quát", border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? "Không bỏ trống" : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _readPartOrderController,
            decoration: const InputDecoration(labelText: "Thứ tự hiển thị phân đoạn bên trong bài đọc (partOrder - Số nguyên)", border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
            validator: (v) => v!.isEmpty ? "Cần điền thứ tự phân đoạn" : null,
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            value: _readType,
            decoration: const InputDecoration(labelText: "Phân loại định dạng phân đoạn", border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'instruction', child: Text("Chuỗi chỉ dẫn tổng quát (instruction)")),
              DropdownMenuItem(value: 'question', child: Text("Đoạn văn đọc hiểu và câu hỏi trắc nghiệm (question)")),
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
              decoration: const InputDecoration(labelText: "Nhập đoạn văn tiếng Nhật dài (passage)", border: OutlineInputBorder()),
              validator: (v) => _readType == 'question' && v!.isEmpty ? "Không được để trống" : null,
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
          Center(
            child: SizedBox(
              width: 250,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitReading,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                child: const Text("LƯU KHUNG ĐỌC HIỂU", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
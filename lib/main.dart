import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_screen.dart';
import 'survey_screen.dart';
import 'sound_manager.dart';
import 'recognition_manager.dart';
import 'database_helper.dart';
import 'user_progress.dart';
import 'lesson_screen.dart';
import 'achievements_screen.dart';
import 'leaderboard_screen.dart';
import 'settings_screen.dart';
import 'tips_screen.dart';
import 'vocabulary_notebook_screen.dart';
import 'reading_practice_screen.dart';
import 'listening_practice_screen.dart';
import 'forum_screen.dart';
import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:cloudinary_flutter/cloudinary_context.dart';
import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

const Color kPrimaryBlue = Color(0xFF3366FF);
const Color kAccentCyan = Color(0xFF56CCF2);
const Color kSoftBackground = Color(0xFFF4F8FF);
const Color kSurfaceWhite = Color(0xFFFFFFFF);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  await RecognitionManager.instance.checkAndDownloadModel();

  CloudinaryContext.cloudinary = Cloudinary.fromCloudName(cloudName: dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? "",);
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    try {
      await UserProgress().syncFromFirebase().timeout(const Duration(seconds: 3));
    } catch (e) {
      print("Không thể đồng bộ nhanh tiến độ khi khởi động: $e");
    }
  }

  runApp(const MyApp());
}

// Màn hình hiển thị ảnh Cloudinary của bạn
class ImageDisplayScreen extends StatelessWidget {
  const ImageDisplayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cloudinary Image")),
      body: Center(
        child: CldImageWidget(
          publicId: "sample", // Tên ID ảnh trên Cloudinary của bạn
          width: 300,
          height: 300,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JapaGo',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: kPrimaryBlue,
        scaffoldBackgroundColor: kSoftBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryBlue,
          primary: kPrimaryBlue,
          secondary: kAccentCyan,
          // Đã sửa: Cập nhật đúng chuẩn Material 3 thay vì dùng thuộc tính cũ lỗi thời
          surface: kSurfaceWhite,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: kSoftBackground,
          foregroundColor: Colors.black87,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: kPrimaryBlue),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: kPrimaryBlue, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          hintStyle: TextStyle(color: Colors.grey[500]),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryBlue,
            foregroundColor: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
        cardTheme: CardThemeData(
          color: kSurfaceWhite,
          elevation: 4,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: kPrimaryBlue,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          elevation: 12,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          type: BottomNavigationBarType.fixed,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: kPrimaryBlue,
              ),
            ),
          );
        }
        final User? user = snapshot.data;
        if (user != null) {
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
            builder: (context, docSnapshot) {
              if (docSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(
                      color: kPrimaryBlue,
                    ),
                  ),
                );
              }
              if (docSnapshot.hasData && docSnapshot.data!.exists) {
                final data = docSnapshot.data!.data() as Map<String, dynamic>?;
                if (data != null) {
                  final bool hasSurvey = data.containsKey('surveyLevel');
                  final List<dynamic>? completed = data['completedLessons'];
                  final bool hasProgress = completed != null && completed.isNotEmpty;
                  if (hasSurvey || hasProgress) {
                    return const MainScreen();
                  }
                }
              }
              return SurveyScreen(uid: user.uid);
            },
          );
        } else {
          return const AuthScreen();
        }
      },
    );
  }
}

// ==========================================================
// 1. MÀN HÌNH CHÍNH (TAB BAR)
// ==========================================================
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final ValueNotifier<int> _activeTabNotifier = ValueNotifier<int>(0);

  late final List<Widget> _screens = [
    SummonerHomePage(activeTabNotifier: _activeTabNotifier),
    const AlphabetScreen(),
    const ForumScreen(),
    LeaderboardScreen(activeTabNotifier: _activeTabNotifier),
    ProfileScreen(activeTabNotifier: _activeTabNotifier),
    const ImageDisplayScreen(),
  ];

  @override
  void dispose() {
    _activeTabNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final User? user = snapshot.data;
        final String userKey = user != null ? user.uid : 'guest';

        return Scaffold(
          body: IndexedStack(
            key: ValueKey(userKey),
            index: _currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 18,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  AlphabetScreen.readingSessionId++;
                  try {
                    SoundManager.instance.stop();
                  } catch (e) {}
                  setState(() => _currentIndex = index);
                  _activeTabNotifier.value = index;
                  SoundManager.instance.vibrate('light');
                },
                backgroundColor: Colors.white,
                selectedItemColor: kPrimaryBlue,
                unselectedItemColor: Colors.grey.shade500,
                showUnselectedLabels: true,
                type: BottomNavigationBarType.fixed,
                elevation: 0,
                items: [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.school),
                    activeIcon: Icon(Icons.school, size: 30),
                    label: "Học tập",
                  ),
                  BottomNavigationBarItem(
                    icon: SizedBox(
                      width: 24,
                      height: 24,
                      child: Center(
                        child: Text(
                          "あ",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade500,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                    activeIcon: const SizedBox(
                      width: 30,
                      height: 30,
                      child: Center(
                        child: Text(
                          "あ",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryBlue,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                    label: "Chữ cái",
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.forum),
                    activeIcon: Icon(Icons.forum, size: 30),
                    label: "Diễn đàn",
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.emoji_events),
                    activeIcon: Icon(Icons.emoji_events, size: 30),
                    label: "Xếp hạng",
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    activeIcon: Icon(Icons.person, size: 30),
                    label: "Tôi",
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ==========================================================
// 2. MÀN HÌNH CHỮ CÁI (DẠNG BẢNG - TABLE)
// ==========================================================
class AlphabetScreen extends StatelessWidget {
  static int readingSessionId = 0;

  const AlphabetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: kSoftBackground,
        appBar: AppBar(
          backgroundColor: kSoftBackground,
          elevation: 0,
          centerTitle: true,
          title: const Text("Bảng Chữ Cái"),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 18,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: const TabBar(
                labelColor: kPrimaryBlue,
                unselectedLabelColor: Colors.grey,
                indicatorColor: kPrimaryBlue,
                indicatorWeight: 4,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                tabs: [
                  Tab(text: "GOJŪON"),
                  Tab(text: "HỮU THANH"),
                  Tab(text: "YŌON"),
                ],
              ),
            ),
          ),
        ),
        body: Container(
          color: kSoftBackground,
          child: const TabBarView(
            children: [
              JapaneseGrid(type: GridType.gojuon),
              JapaneseGrid(type: GridType.dakuon),
              JapaneseGrid(type: GridType.yoon),
            ],
          ),
        ),
      ),
    );
  }
}

enum GridType { gojuon, dakuon, yoon }

class JapaneseGrid extends StatefulWidget {
  final GridType type;
  const JapaneseGrid({super.key, required this.type});

  @override
  State<JapaneseGrid> createState() => _JapaneseGridState();
}

class _JapaneseGridState extends State<JapaneseGrid> {
  List<List<Map<String, String>>> _getData() {
    switch (widget.type) {
      case GridType.gojuon:
        return [
          [
            {'h': 'あ', 'k': 'ア', 'r': 'a'},
            {'h': 'い', 'k': 'イ', 'r': 'i'},
            {'h': 'う', 'k': 'ウ', 'r': 'u'},
            {'h': 'え', 'k': 'エ', 'r': 'e'},
            {'h': 'お', 'k': 'オ', 'r': 'o'},
          ],
          [
            {'h': 'か', 'k': 'カ', 'r': 'ka'},
            {'h': 'き', 'k': 'キ', 'r': 'ki'},
            {'h': 'く', 'k': 'ク', 'r': 'ku'},
            {'h': 'け', 'k': 'ケ', 'r': 'ke'},
            {'h': 'こ', 'k': 'コ', 'r': 'ko'},
          ],
          [
            {'h': 'さ', 'k': 'サ', 'r': 'sa'},
            {'h': 'し', 'k': 'シ', 'r': 'shi'},
            {'h': 'す', 'k': 'ス', 'r': 'su'},
            {'h': 'せ', 'k': 'セ', 'r': 'se'},
            {'h': 'そ', 'k': 'ソ', 'r': 'so'},
          ],
          [
            {'h': 'た', 'k': 'タ', 'r': 'ta'},
            {'h': 'ち', 'k': 'チ', 'r': 'chi'},
            {'h': 'つ', 'k': 'ツ', 'r': 'tsu'},
            {'h': 'て', 'k': 'テ', 'r': 'te'},
            {'h': 'と', 'k': 'ト', 'r': 'to'},
          ],
          [
            {'h': 'な', 'k': 'ナ', 'r': 'na'},
            {'h': 'に', 'k': 'ニ', 'r': 'ni'},
            {'h': 'ぬ', 'k': 'ヌ', 'r': 'nu'},
            {'h': 'ね', 'k': 'ネ', 'r': 'ne'},
            {'h': 'の', 'k': 'ノ', 'r': 'no'},
          ],
          [
            {'h': 'は', 'k': 'ハ', 'r': 'ha'},
            {'h': 'ひ', 'k': 'ヒ', 'r': 'hi'},
            {'h': 'ふ', 'k': 'フ', 'r': 'fu'},
            {'h': 'へ', 'k': 'ヘ', 'r': 'he'},
            {'h': 'ほ', 'k': 'ホ', 'r': 'ho'},
          ],
          [
            {'h': 'ま', 'k': 'マ', 'r': 'ma'},
            {'h': 'み', 'k': 'ミ', 'r': 'mi'},
            {'h': 'む', 'k': 'ム', 'r': 'mu'},
            {'h': 'め', 'k': 'メ', 'r': 'me'},
            {'h': 'も', 'k': 'モ', 'r': 'mo'},
          ],
          [
            {'h': 'や', 'k': 'ヤ', 'r': 'ya'},
            {'h': '', 'k': '', 'r': ''},
            {'h': 'ゆ', 'k': 'ユ', 'r': 'yu'},
            {'h': '', 'k': '', 'r': ''},
            {'h': 'よ', 'k': 'ヨ', 'r': 'yo'},
          ],
          [
            {'h': 'ら', 'k': 'ラ', 'r': 'ra'},
            {'h': 'り', 'k': 'リ', 'r': 'ri'},
            {'h': 'る', 'k': 'ル', 'r': 'ru'},
            {'h': 'れ', 'k': 'レ', 'r': 're'},
            {'h': 'ろ', 'k': 'ロ', 'r': 'ro'},
          ],
          [
            {'h': 'わ', 'k': 'ワ', 'r': 'wa'},
            {'h': '', 'k': '', 'r': ''},
            {'h': '', 'k': '', 'r': ''},
            {'h': '', 'k': '', 'r': ''},
            {'h': 'を', 'k': 'ヲ', 'r': 'wo'},
          ],
          [
            {'h': 'ん', 'k': 'ン', 'r': 'n'},
            {'h': '', 'k': '', 'r': ''},
            {'h': '', 'k': '', 'r': ''},
            {'h': '', 'k': '', 'r': ''},
            {'h': '', 'k': '', 'r': ''},
          ],
        ];
      case GridType.dakuon:
        return [
          [
            {'h': 'が', 'k': 'ガ', 'r': 'ga'},
            {'h': 'ぎ', 'k': 'ギ', 'r': 'gi'},
            {'h': 'ぐ', 'k': 'グ', 'r': 'gu'},
            {'h': 'げ', 'k': 'ゲ', 'r': 'ge'},
            {'h': 'ご', 'k': 'ゴ', 'r': 'go'},
          ],
          [
            {'h': 'ざ', 'k': 'ザ', 'r': 'za'},
            {'h': 'じ', 'k': 'ジ', 'r': 'ji'},
            {'h': 'ず', 'k': 'ズ', 'r': 'zu'},
            {'h': 'ぜ', 'k': 'ゼ', 'r': 'ze'},
            {'h': 'ぞ', 'k': 'ゾ', 'r': 'zo'},
          ],
          [
            {'h': 'だ', 'k': 'ダ', 'r': 'da'},
            {'h': 'ぢ', 'k': 'ヂ', 'r': 'ji'},
            {'h': 'づ', 'k': 'ヅ', 'r': 'zu'},
            {'h': 'で', 'k': 'デ', 'r': 'de'},
            {'h': 'ど', 'k': 'ド', 'r': 'do'},
          ],
          [
            {'h': 'ば', 'k': 'バ', 'r': 'ba'},
            {'h': 'び', 'k': 'ビ', 'r': 'bi'},
            {'h': 'ぶ', 'k': 'ブ', 'r': 'bu'},
            {'h': 'べ', 'k': 'ベ', 'r': 'be'},
            {'h': 'ぼ', 'k': 'ボ', 'r': 'bo'},
          ],
          [
            {'h': 'ぱ', 'k': 'パ', 'r': 'pa'},
            {'h': 'ぴ', 'k': 'ピ', 'r': 'pi'},
            {'h': 'ぷ', 'k': 'プ', 'r': 'pu'},
            {'h': 'ぺ', 'k': 'ペ', 'r': 'pe'},
            {'h': 'ぽ', 'k': 'ポ', 'r': 'po'},
          ],
        ];
      case GridType.yoon:
        return [
          [
            {'h': 'きゃ', 'k': 'キャ', 'r': 'kya'},
            {'h': 'きゅ', 'k': 'キュ', 'r': 'kyu'},
            {'h': 'きょ', 'k': 'キョ', 'r': 'kyo'},
          ],
          [
            {'h': 'しゃ', 'k': 'シャ', 'r': 'sha'},
            {'h': 'しゅ', 'k': 'シュ', 'r': 'shu'},
            {'h': 'しょ', 'k': 'ショ', 'r': 'sho'},
          ],
          [
            {'h': 'ちゃ', 'k': 'チャ', 'r': 'cha'},
            {'h': 'ちゅ', 'k': 'チュ', 'r': 'chu'},
            {'h': 'ちょ', 'k': 'チョ', 'r': 'cho'},
          ],
          [
            {'h': 'にゃ', 'k': 'ニャ', 'r': 'nya'},
            {'h': 'にゅ', 'k': 'ニュ', 'r': 'nyu'},
            {'h': 'にょ', 'k': 'ニョ', 'r': 'nyo'},
          ],
          [
            {'h': 'ひゃ', 'k': 'ヒャ', 'r': 'hya'},
            {'h': 'ひゅ', 'k': 'ヒュ', 'r': 'hyu'},
            {'h': 'ひょ', 'k': 'ヒョ', 'r': 'hyo'},
          ],
          [
            {'h': 'みゃ', 'k': 'ミャ', 'r': 'mya'},
            {'h': 'みゅ', 'k': 'ミュ', 'r': 'myu'},
            {'h': 'みょ', 'k': 'ミョ', 'r': 'myo'},
          ],
          [
            {'h': 'りゃ', 'k': 'リャ', 'r': 'rya'},
            {'h': 'りゅ', 'k': 'リュ', 'r': 'ryu'},
            {'h': 'りょ', 'k': 'リョ', 'r': 'ryo'},
          ],
          [
            {'h': 'ぎゃ', 'k': 'ギャ', 'r': 'gya'},
            {'h': 'ぎゅ', 'k': 'ギュ', 'r': 'gyu'},
            {'h': 'ぎょ', 'k': 'ギョ', 'r': 'gyo'},
          ],
          [
            {'h': 'じゃ', 'k': 'ジャ', 'r': 'ja'},
            {'h': 'じゅ', 'k': 'ジュ', 'r': 'ju'},
            {'h': 'じょ', 'k': 'ジョ', 'r': 'jo'},
          ],
          [
            {'h': 'びゃ', 'k': 'ビャ', 'r': 'bya'},
            {'h': 'びゅ', 'k': 'ビュ', 'r': 'byu'},
            {'h': 'びょ', 'k': 'ビョ', 'r': 'byo'},
          ],
          [
            {'h': 'ぴゃ', 'k': 'ピャ', 'r': 'pya'},
            {'h': 'ぴゅ', 'k': 'ピュ', 'r': 'pyu'},
            {'h': 'ぴょ', 'k': 'ピョ', 'r': 'pyo'},
          ],
        ];
    }
  }

  // 2. HÀM ĐỌC DANH SÁCH MỚI (Tự ngắt siêu nhạy)
  void _speakListSlowly(List<String> chars) async {
    AlphabetScreen.readingSessionId++; // Đánh dấu bắt đầu 1 lệnh đọc mới
    int mySessionId = AlphabetScreen.readingSessionId;

    try {
      SoundManager.instance.stop();
    } catch (e) {} // Cắt đứt âm thanh hiện tại

    for (String char in chars) {
      if (mySessionId != AlphabetScreen.readingSessionId || !mounted) return;

      SoundManager.instance.speakJapanese(char);

      // 3. MẸO CHIA NHỎ DELAY: Đợi 1.5s nhưng băm ra làm 15 phần (mỗi phần 100ms)
      // Nếu trong lúc ngủ mà phát hiện người dùng chuyển tab (đổi SessionId), nó văng ra ngay!
      for (int i = 0; i < 15; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (mySessionId != AlphabetScreen.readingSessionId || !mounted) return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rows = _getData();
    int maxCols = rows.isNotEmpty ? rows[0].length : 0;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 8, bottom: 8, right: 40),
          color: Colors.grey[50],
          child: Row(
            children: List.generate(maxCols, (colIndex) {
              return Expanded(
                child: InkWell(
                  onTap: () {
                    List<String> colChars = [];
                    for (var row in rows) {
                      if (colIndex < row.length &&
                          row[colIndex]['h']!.isNotEmpty) {
                        colChars.add(row[colIndex]['h']!);
                      }
                    }
                    _speakListSlowly(colChars);
                  },
                  child: const Icon(
                    Icons.arrow_drop_down_circle,
                    color: Color(0xFF58CC02),
                    size: 24,
                  ),
                ),
              );
            }),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: rows.length,
            separatorBuilder: (ctx, index) => const Divider(height: 1),
            itemBuilder: (context, rowIndex) {
              final rowChars = rows[rowIndex];
              return SizedBox(
                height: 110,
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: rowChars.map((charData) {
                          if (charData['h']!.isEmpty)
                            return const Expanded(child: SizedBox());

                          return Expanded(
                            child: InkWell(
                              onTap: () {
                                // Ngắt vòng lặp hàng/cột ngay lập tức nếu bấm 1 chữ lẻ
                                AlphabetScreen.readingSessionId++;
                                try {
                                  SoundManager.instance.stop();
                                } catch (e) {}

                                SoundManager.instance.speakJapanese(
                                  charData['h']!,
                                );
                                SoundManager.instance.vibrate('light');
                              },
                              child: Container(
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12.withOpacity(0.05),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      charData['h']!,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      charData['k']!,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      charData['r']!,
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        List<String> rowTexts = rowChars
                            .where((e) => e['h']!.isNotEmpty)
                            .map((e) => e['h']!)
                            .toList();
                        _speakListSlowly(rowTexts);
                      },
                      child: Container(
                        width: 40,
                        color: Colors.grey[100],
                        child: const Icon(
                          Icons.play_circle_fill,
                          color: Color(0xFF58CC02),
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class AvatarWithFrame extends StatelessWidget {
  final double radius;
  final String? frame;
  final Widget child;

  const AvatarWithFrame({
    super.key,
    required this.radius,
    required this.frame,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (frame == null || frame == 'none') {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.white,
        child: child,
      );
    }

    List<Color> gradientColors;
    switch (frame) {
      case 'bronze':
        gradientColors = [const Color(0xFFCD7F32), const Color(0xFFB87333), const Color(0xFF8C5220)];
        break;
      case 'silver':
        gradientColors = [const Color(0xFFC0C0C0), const Color(0xFFE6E6E6), const Color(0xFF8A8A8A)];
        break;
      case 'gold':
        gradientColors = [const Color(0xFFFFD700), const Color(0xFFFFF099), const Color(0xFFB8860B)];
        break;
      case 'diamond':
        gradientColors = [const Color(0xFF00E5FF), const Color(0xFFD500F9), const Color(0xFF3366FF)];
        break;
      default:
        gradientColors = [Colors.grey, Colors.grey];
    }

    return Container(
      padding: EdgeInsets.all(radius * 0.08),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: CircleAvatar(
        radius: radius - (radius * 0.08),
        backgroundColor: Colors.white,
        child: child,
      ),
    );
  }
}

// ==========================================================
// 3. MÀN HÌNH "TÔI" (PROFILE DASHBOARD)
// ==========================================================
class ProfileScreen extends StatefulWidget {
  final ValueNotifier<int> activeTabNotifier;
  const ProfileScreen({super.key, required this.activeTabNotifier});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey _progressChartKey = GlobalKey();
  List<Map<String, dynamic>> previewTips = [];

  String? _equippedFrame;
  String? _equippedTitle;
  int _userExp = 0;
  List<Map<String, dynamic>> _unlockedAchievements = [];
  bool _isLoadingProfileData = true;

  @override
  void initState() {
    super.initState();
    TipsData.sortTips(); // Xếp chuẩn dữ liệu trước
    previewTips = TipsData.list.take(2).toList(); // Lấy 2 cái đầu tiên giữ cố định
    widget.activeTabNotifier.addListener(_handleTabChange);
    _loadProfileData();
  }

  @override
  void dispose() {
    widget.activeTabNotifier.removeListener(_handleTabChange);
    super.dispose();
  }

  void _handleTabChange() {
    if (widget.activeTabNotifier.value == 4) {
      _loadProfileData();
    }
  }

  Future<void> _loadProfileData() async {
    try {
      final results = await Future.wait([
        UserProgress().getExp(),
        UserProgress().getCompletedLessons(),
        DatabaseHelper.instance.getMasteredCount(),
        UserProgress().getEquippedFrameAndTitle(),
      ]);

      final exp = results[0] as int;
      final completed = results[1] as List<String>;
      final masteredCount = results[2] as int;
      final equipped = results[3] as Map<String, String?>;

      final achievements = AchievementData.getCalculatedList(
        exp: exp,
        completedLessons: completed,
        masteredCount: masteredCount,
      );

      final unlocked = achievements.where((a) => (a['progress'] as double) >= 1.0).toList();

      if (mounted) {
        setState(() {
          _userExp = exp;
          _unlockedAchievements = unlocked;
          _equippedFrame = equipped['frame'];
          _equippedTitle = equipped['title'];
          _isLoadingProfileData = false;
        });
      }
    } catch (e) {
      print("Lỗi tải thông tin trang cá nhân: $e");
      if (mounted) {
        setState(() => _isLoadingProfileData = false);
      }
    }
  }

  // Hàm gọi để làm mới lại 2 mẹo bên ngoài khi từ màn hình chi tiết đi ra
  void _refreshTips() {
    setState(() {
      previewTips = TipsData.list.take(2).toList();
    });
  }

  void _showEquipBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.65,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Trang bị của bạn",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const TabBar(
                      labelColor: kPrimaryBlue,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: kPrimaryBlue,
                      tabs: [
                        Tab(text: "Khung Avatar"),
                        Tab(text: "Danh hiệu"),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildFrameSelectionList(setSheetState),
                          _buildTitleSelectionList(setSheetState),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFrameSelectionList(StateSetter setSheetState) {
    final frames = [
      {'id': 'none', 'name': 'Mặc định (Không khung)', 'req': 0, 'desc': 'Khung viền nguyên bản'},
      {'id': 'bronze', 'name': 'Khung Đồng', 'req': 100, 'desc': 'Yêu cầu đạt từ 100 EXP'},
      {'id': 'silver', 'name': 'Khung Bạc', 'req': 300, 'desc': 'Yêu cầu đạt từ 300 EXP'},
      {'id': 'gold', 'name': 'Khung Vàng', 'req': 600, 'desc': 'Yêu cầu đạt từ 600 EXP'},
      {'id': 'diamond', 'name': 'Khung Kim Cương', 'req': 1000, 'desc': 'Yêu cầu đạt từ 1000 EXP'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: frames.length,
      itemBuilder: (context, index) {
        final frame = frames[index];
        final String fId = frame['id'] as String;
        final int reqExp = frame['req'] as int;
        
        final bool isUnlocked = _userExp >= reqExp;
        final bool isEquipped = _equippedFrame == fId;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isEquipped ? kPrimaryBlue : Colors.grey.shade200,
              width: isEquipped ? 2 : 1,
            ),
          ),
          child: ListTile(
            leading: AvatarWithFrame(
              radius: 22,
              frame: fId,
              child: const Icon(Icons.person, color: kPrimaryBlue),
            ),
            title: Text(
              frame['name'] as String,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isUnlocked ? Colors.black87 : Colors.grey,
              ),
            ),
            subtitle: Text(
              isUnlocked ? 'Đã mở khóa' : (frame['desc'] as String),
              style: TextStyle(
                fontSize: 12,
                color: isUnlocked ? Colors.green : Colors.red,
              ),
            ),
            trailing: isEquipped
                ? const Icon(Icons.check_circle, color: kPrimaryBlue)
                : (isUnlocked
                    ? ElevatedButton(
                        onPressed: () async {
                          await UserProgress().updateEquippedFrameAndTitle(fId, _equippedTitle);
                          setSheetState(() {
                            _equippedFrame = fId;
                          });
                          setState(() {
                            _equippedFrame = fId;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryBlue.withOpacity(0.1),
                          foregroundColor: kPrimaryBlue,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Trang bị", style: TextStyle(fontWeight: FontWeight.bold)),
                      )
                    : const Icon(Icons.lock, color: Colors.grey)),
          ),
        );
      },
    );
  }

  Widget _buildTitleSelectionList(StateSetter setSheetState) {
    if (_unlockedAchievements.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            "Bạn chưa mở khóa danh hiệu nào để trang bị.\nHãy làm nhiều bài tập và đăng nhập đều đặn nhé!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, height: 1.5),
          ),
        ),
      );
    }

    final titles = [
      {'id': 'none', 'title': 'Mặc định (Không danh hiệu)'},
      ..._unlockedAchievements.map((a) => {'id': a['title'] as String, 'title': a['title'] as String}),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: titles.length,
      itemBuilder: (context, index) {
        final t = titles[index];
        final String tId = t['id'] as String;
        final bool isEquipped = (_equippedTitle ?? 'none') == tId;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isEquipped ? kPrimaryBlue : Colors.grey.shade200,
              width: isEquipped ? 2 : 1,
            ),
          ),
          child: ListTile(
            title: Text(
              t['title'] as String,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              tId == 'none' ? 'Không hiển thị danh hiệu phụ' : 'Danh hiệu đã mở khóa',
              style: TextStyle(fontSize: 12, color: tId == 'none' ? Colors.grey : Colors.green),
            ),
            trailing: isEquipped
                ? const Icon(Icons.check_circle, color: kPrimaryBlue)
                : ElevatedButton(
                    onPressed: () async {
                      final String? titleToSave = tId == 'none' ? null : tId;
                      await UserProgress().updateEquippedFrameAndTitle(_equippedFrame, titleToSave);
                      setSheetState(() {
                        _equippedTitle = titleToSave;
                      });
                      setState(() {
                        _equippedTitle = titleToSave;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryBlue.withOpacity(0.1),
                      foregroundColor: kPrimaryBlue,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Trang bị", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
          ),
        );
      },
    );
  }

  void _showChangeNameDialog(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final controller = TextEditingController(
      text: user.displayName ?? user.email?.split('@')[0] ?? "",
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Đổi tên hiển thị",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: controller,
            maxLength: 20,
            decoration: const InputDecoration(
              hintText: "Nhập tên hiển thị mới",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  try {
                    await UserProgress().updateDisplayName(newName);
                    await _loadProfileData();
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Đã cập nhật tên hiển thị!"),
                        ),
                      );
                    }
                  } catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          content: Text("Lỗi: $e"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                "Cập nhật",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProfileData) {
      return const Scaffold(
        backgroundColor: kSoftBackground,
        body: Center(child: CircularProgressIndicator(color: kPrimaryBlue)),
      );
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final User? user = FirebaseAuth.instance.currentUser;
        final bool isLoggedIn = user != null;

        return Scaffold(
          backgroundColor: kSoftBackground,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context, user),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildGridMenu(context),
                ),

                const SizedBox(height: 20),

                // 2. Gắn Key vào khung Biểu đồ tiến độ
                Padding(
                  key: _progressChartKey, // <-- GẮN KEY VÀO ĐÂY
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildProgressChart(),
                ),

                const SizedBox(height: 20),

                _buildRankSection(),

                _buildAchievementsSection(context),

                const SizedBox(height: 30),

                _buildTipsSection(context),

                const SizedBox(height: 20),

                if (isLoggedIn)
                  TextButton.icon(
                    onPressed: () => FirebaseAuth.instance.signOut(),
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      "Đăng xuất",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- CÁC HÀM XÂY DỰNG GIAO DIỆN BÊN TRONG ---

  Widget _buildHeader(BuildContext context, User? user) {
    bool isLoggedIn = user != null;
    String displayName = isLoggedIn
        ? (user.displayName != null && user.displayName!.isNotEmpty
            ? user.displayName!
            : (user.email?.split('@')[0] ?? "Summoner"))
        : "Đăng nhập";

    return GestureDetector(
      onTap: () {
        if (!isLoggedIn) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AuthScreen()),
          );
        } else {
          _showEquipBottomSheet(context);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3C78D8), Color(0xFF56CCF2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            AvatarWithFrame(
              radius: 35,
              frame: _equippedFrame,
              child: Image.asset(
                'assets/images/dog_happy.png',
                width: 50,
                errorBuilder: (_, _, _) =>
                    const Icon(Icons.face, size: 40, color: Colors.orange),
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
                      Expanded(
                        child: Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isLoggedIn) ...[
                        GestureDetector(
                          onTap: () => _showChangeNameDialog(context),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white70,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => _showEquipBottomSheet(context),
                          child: const Icon(
                            Icons.shield,
                            color: Colors.white70,
                            size: 20,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 5),
                  if (_equippedTitle != null) ...[
                    Text(
                      _equippedTitle!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.yellowAccent,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 3),
                  ],
                  Text(
                    "Điểm luyện tập: $_userExp exp",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.flash_on, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Giữ nhịp học liên tục 3 ngày',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridMenu(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        'icon': Icons.trending_up,
        'label': 'Tiến độ',
        'color': Colors.amber,
        'bg': 0xFFFFF8E1,
      },
      {
        'icon': Icons.emoji_events,
        'label': 'Danh hiệu',
        'color': Colors.orange,
        'bg': 0xFFFFF3E0,
      },
      {
        'icon': Icons.lightbulb,
        'label': 'Mẹo học',
        'color': Colors.blue,
        'bg': 0xFFE3F2FD,
      },
      {
        'icon': Icons.settings,
        'label': 'Cài đặt',
        'color': Colors.blueGrey,
        'bg': 0xFFECEFF1,
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: menuItems.map((item) {
          return GestureDetector(
            onTap: () {
              if (item['label'] == 'Tiến độ') {
                if (_progressChartKey.currentContext != null) {
                  Scrollable.ensureVisible(
                    _progressChartKey.currentContext!,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOut,
                  );
                }
              } else if (item['label'] == 'Danh hiệu') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AchievementsScreen()),
                );
              } else if (item['label'] == 'Mẹo học') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TipsScreen()),
                ).then((_) => _refreshTips());
              } else if (item['label'] == 'Cài đặt') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color(item['bg']),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item['icon'], color: item['color'], size: 26),
                ),
                const SizedBox(height: 8),
                Text(
                  item['label'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProgressChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPrimaryBlue, kAccentCyan],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tiến trình luyện tập tuần",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Hôm nay",
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _chartBar("T2", 0.0, false),
              _chartBar("T3", 0.0, false),
              _chartBar("T4", 0.0, false),
              _chartBar("T5", 0.4, true),
              _chartBar("T6", 0.6, false),
              _chartBar("T7", 0.6, false),
              _chartBar("CN", 0.6, false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chartBar(String day, double percent, bool isToday) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 60,
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 12,
            height: 60 * (percent == 0 ? 0.1 : percent),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(day, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  Widget _buildRankSection() {
    return FutureBuilder<int>(
      future: UserProgress().getExp(),
      builder: (context, snapshot) {
        int exp = snapshot.data ?? 0;
        final List<String> ranks = [
          "Tân binh",
          "Binh nhất",
          "Thượng sĩ",
          "Đại uý",
          "Đại tá",
          "Đại tướng",
        ];
        final List<int> expThresholds = [0, 50, 150, 300, 600, 1000];

        int currentRankIndex = 0;
        for (int i = 0; i < expThresholds.length; i++) {
          if (exp >= expThresholds[i]) {
            currentRankIndex = i;
          } else {
            break;
          }
        }

        double progressPercent = 0.0;
        if (currentRankIndex >= ranks.length - 1) {
          progressPercent = 1.0;
        } else {
          int currentLevelExp = expThresholds[currentRankIndex];
          int nextLevelExp = expThresholds[currentRankIndex + 1];
          int expEarnedInLevel = exp - currentLevelExp;
          int expNeededForLevel = nextLevelExp - currentLevelExp;

          double levelFraction = expEarnedInLevel / expNeededForLevel;
          progressPercent =
              (currentRankIndex + levelFraction) / (ranks.length - 1);
        }

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Cấp bậc",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    "$exp EXP",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              LayoutBuilder(
                builder: (context, constraints) {
                  double maxWidth = constraints.maxWidth - 20;
                  double activeWidth = maxWidth * progressPercent;

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 4,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        color: Colors.grey.shade200,
                      ),
                      Positioned(
                        left: 10,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          height: 4,
                          width: activeWidth,
                          color: kPrimaryBlue,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(ranks.length, (index) {
                          bool isAchieved = index <= currentRankIndex;
                          return Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: isAchieved
                                  ? kPrimaryBlue
                                  : Colors.grey.shade200,
                              shape: BoxShape.circle,
                              border: isAchieved
                                  ? Border.all(color: Colors.amber, width: 3)
                                  : null,
                            ),
                          );
                        }),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(ranks.length, (index) {
                  bool isAchieved = index <= currentRankIndex;
                  return Expanded(
                    child: Text(
                      ranks[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isAchieved
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isAchieved
                            ? Colors.black87
                            : Colors.grey.shade400,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAchievementsSection(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        UserProgress().getExp(),
        UserProgress().getCompletedLessons(),
        DatabaseHelper.instance.getMasteredCount(),
      ]),
      builder: (context, snapshot) {
        List<Map<String, dynamic>> previewAchievements;
        if (snapshot.connectionState == ConnectionState.waiting) {
          previewAchievements = AchievementData.list.take(4).toList();
        } else if (snapshot.hasError) {
          previewAchievements = AchievementData.list.take(4).toList();
        } else {
          final results = snapshot.data ?? [0, <String>[], 0];
          final int exp = results[0] as int;
          final List<String> completedLessons = results[1] as List<String>;
          final int masteredCount = results[2] as int;

          previewAchievements = AchievementData.getCalculatedList(
            exp: exp,
            completedLessons: completedLessons,
            masteredCount: masteredCount,
          ).take(4).toList();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Danh hiệu sắp đạt được",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AchievementsScreen(),
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              ...previewAchievements.map((item) => _buildAchievementItem(item)),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AchievementsScreen(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFE3F2FD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Xem danh sách danh hiệu",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryBlue,
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

  Widget _buildAchievementItem(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: data['color'],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(data['icon'], color: Colors.white, size: 30),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data['desc'],
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    height: 6,
                    child: LinearProgressIndicator(
                      value: data['progress'] == 0.0 ? 0.05 : data['progress'],
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(data['color']),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Mẹo học tiếng Nhật",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15),

          // Vòng lặp vẽ từ biến previewTips đã bị "khóa" ở initState
          ...previewTips.map((tip) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      tip['text'],
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Nút tim ở ngoài
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        TipsData.toggleLike(tip['id']);
                      });
                    },
                    child: Icon(
                      Icons.favorite,
                      color: tip['isLiked']
                          ? Colors.redAccent
                          : Colors.pink.shade100,
                      size: 28,
                    ),
                  ),
                ],
              ),
            );
          }),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TipsScreen()),
                ).then((_) {
                  _refreshTips();
                });
              },
              child: const Text(
                "Xem danh sách mẹo học tiếng Nhật",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryBlue,
                  decoration: TextDecoration.underline,
                  decorationColor: kPrimaryBlue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// 4. MÀN HÌNH HỌC TẬP (ROADMAP STYLE)
// ==========================================================
class SummonerHomePage extends StatefulWidget {
  final ValueNotifier<int> activeTabNotifier;
  const SummonerHomePage({super.key, required this.activeTabNotifier});

  @override
  State<SummonerHomePage> createState() => _SummonerHomePageState();
}

class _SummonerHomePageState extends State<SummonerHomePage> {
  final ScrollController _scrollController = ScrollController();

  // 1. ĐỊNH NGHĨA CÁC CHẶNG HỌC (CHAPTERS)
  // Sau này muốn thêm Cơ bản 5, 6... bạn chỉ cần thêm 1 dòng vào đây
  final List<Map<String, dynamic>> _sections = [
    {
      'id': 'alphabet',
      'title': 'Bảng chữ cái',
      'subtitle': 'Khởi động',
      'icon': Icons.sort_by_alpha,
      'color': 0xFF4A89F3,
      'bg': 0xFFEDF4FE,
    },
    {
      'id': 'basic1',
      'title': 'Cơ bản 1',
      'subtitle': 'Chào hỏi & Nghề nghiệp',
      'icon': Icons.waving_hand,
      'color': 0xFFFFA000,
      'bg': 0xFFFFF8E1,
    },
    {
      'id': 'basic2',
      'title': 'Cơ bản 2',
      'subtitle': 'Đồ vật & Sở hữu',
      'icon': Icons.business_center,
      'color': 0xFFE91E63,
      'bg': 0xFFFCE4EC,
    },
    {
      'id': 'basic3',
      'title': 'Cơ bản 3',
      'subtitle': 'Địa điểm & Giá tiền',
      'icon': Icons.storefront,
      'color': 0xFF9C27B0,
      'bg': 0xFFF3E5F5,
    },
    {
      'id': 'basic4',
      'title': 'Cơ bản 4',
      'subtitle': 'Thời gian & Sinh hoạt',
      'icon': Icons.access_time_filled,
      'color': 0xFF00BCD4,
      'bg': 0xFFE0F7FA,
    },
    {
      'id': 'basic5',
      'title': 'Cơ bản 5',
      'subtitle': 'Di chuyển & Phương tiện',
      'icon': Icons.directions_transit,
      'color': 0xFF4CAF50,
      'bg': 0xFFE8F5E9,
    },
    {
      'id': 'basic6',
      'title': 'Cơ bản 6',
      'subtitle': 'Ăn uống & Mua sắm',
      'icon': Icons.restaurant,
      'color': 0xFFFF9800,
      'bg': 0xFFFFF3E0,
    },
    {
      'id': 'basic7',
      'title': 'Cơ bản 7',
      'subtitle': 'Cho, Nhận & Công cụ',
      'icon': Icons.card_giftcard,
      'color': 0xFFF44336,
      'bg': 0xFFFFEBEE,
    },
    {
      'id': 'basic8',
      'title': 'Cơ bản 8',
      'subtitle': 'Tính từ (Mô tả)',
      'icon': Icons.auto_awesome,
      'color': 0xFF3F51B5,
      'bg': 0xFFE8EAF6,
    },
    {
      'id': 'basic9',
      'title': 'Cơ bản 9',
      'subtitle': 'Sở thích & Lý do',
      'icon': Icons.favorite,
      'color': 0xFFE91E63,
      'bg': 0xFFFCE4EC,
    },
    {
      'id': 'basic10',
      'title': 'Cơ bản 10',
      'subtitle': 'Sự tồn tại & Vị trí',
      'icon': Icons.location_on,
      'color': 0xFF009688,
      'bg': 0xFFE0F2F1,
    },
  ];

  // 2. DANH SÁCH TOÀN BỘ BÀI HỌC
  late List<Map<String, dynamic>> _lessons;
  String _currentCourse = 'Sơ cấp 1 - N5';

  @override
  void initState() {
    super.initState();
    _initLessons(); // Mặc định là N5
    _refreshProgress();
    widget.activeTabNotifier.addListener(_handleTabChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          100.0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleTabChange() {
    if (widget.activeTabNotifier.value == 0) {
      _refreshProgress();
    }
  }

  // --- CÁC HÀM KHỞI TẠO BÀI HỌC CHO TỪNG CẤP ĐỘ ---

  void _initLessons() {
    _lessons = [
      // --- CHẶNG 1: BẢNG CHỮ CÁI ---
      { 'id': 1, 'key': 'hang_a', 'title': 'Hàng A (あ)', 'icon': Icons.menu_book, 'status': 1, 'section': 'alphabet' },
      { 'id': 2, 'key': 'hang_ka', 'title': 'Hàng Ka (か)', 'icon': Icons.menu_book, 'status': 0, 'section': 'alphabet' },
      { 'id': 3, 'key': 'hang_sa', 'title': 'Hàng Sa (さ)', 'icon': Icons.menu_book, 'status': 0, 'section': 'alphabet' },
      { 'id': 4, 'key': 'hang_ta', 'title': 'Hàng Ta (た)', 'icon': Icons.menu_book, 'status': 0, 'section': 'alphabet' },
      { 'id': 5, 'key': 'hang_na', 'title': 'Hàng Na (な)', 'icon': Icons.menu_book, 'status': 0, 'section': 'alphabet' },
      { 'id': 6, 'key': 'hang_ha', 'title': 'Hàng Ha (は)', 'icon': Icons.menu_book, 'status': 0, 'section': 'alphabet' },
      { 'id': 7, 'key': 'hang_ma', 'title': 'Hàng Ma (ま)', 'icon': Icons.menu_book, 'status': 0, 'section': 'alphabet' },
      { 'id': 8, 'key': 'hang_ya', 'title': 'Hàng Ya (や)', 'icon': Icons.menu_book, 'status': 0, 'section': 'alphabet' },
      { 'id': 9, 'key': 'hang_ra', 'title': 'Hàng Ra (ら)', 'icon': Icons.menu_book, 'status': 0, 'section': 'alphabet' },
      { 'id': 10, 'key': 'hang_wa', 'title': 'Hàng Wa (わ)', 'icon': Icons.menu_book, 'status': 0, 'section': 'alphabet' },
      { 'id': 11, 'key': 'hang_all', 'title': 'TỔNG HỢP', 'icon': Icons.star, 'status': 0, 'isBoss': true, 'section': 'alphabet' },

      // --- CÁC BÀI CƠ BẢN (CB1 - CB10) ---
    ];

    // Tự động sinh ra CB1 đến CB10 cho N5
    for (int i = 1; i <= 10; i++) {
      String sectionId = 'basic$i';
      _lessons.addAll([
        { 'id': 100+i*7+1, 'key': 'cb${i}_lythuyet', 'title': 'Lý thuyết', 'icon': Icons.menu_book, 'status': 0, 'section': sectionId },
        { 'id': 100+i*7+2, 'key': 'cb${i}_luyentap1', 'title': 'Luyện tập 1', 'icon': Icons.import_contacts, 'status': 0, 'section': sectionId },
        { 'id': 100+i*7+3, 'key': 'cb${i}_luyentap2', 'title': 'Luyện tập 2', 'icon': Icons.import_contacts, 'status': 0, 'section': sectionId },
        { 'id': 100+i*7+4, 'key': 'cb${i}_luyentap3', 'title': 'Luyện tập 3', 'icon': Icons.import_contacts, 'status': 0, 'section': sectionId },
        { 'id': 100+i*7+5, 'key': 'cb${i}_luyennoi', 'title': 'Luyện nói', 'icon': Icons.mic, 'status': 0, 'section': sectionId },
        { 'id': 100+i*7+6, 'key': 'cb${i}_luyenviet', 'title': 'Luyện viết', 'icon': Icons.edit, 'status': 0, 'section': sectionId },
        { 'id': 100+i*7+7, 'key': 'cb${i}_ontap', 'title': 'Ôn tập', 'icon': Icons.star, 'status': 0, 'isBoss': true, 'section': sectionId },
      ]);
    }
  }

  void _initNXLessons(String levelPrefix, int startId) {
    _lessons = [];
    int idCounter = startId;
    for (int i = 1; i <= 10; i++) {
      String sectionId = 'basic$i';
      _lessons.addAll([
        { 'id': idCounter++, 'key': '${levelPrefix}_bai${i}_lythuyet', 'title': 'Lý thuyết', 'icon': Icons.menu_book, 'status': 0, 'section': sectionId },
        { 'id': idCounter++, 'key': '${levelPrefix}_bai${i}_luyentap1', 'title': 'Luyện tập 1', 'icon': Icons.import_contacts, 'status': 0, 'section': sectionId },
        { 'id': idCounter++, 'key': '${levelPrefix}_bai${i}_luyentap2', 'title': 'Luyện tập 2', 'icon': Icons.import_contacts, 'status': 0, 'section': sectionId },
        { 'id': idCounter++, 'key': '${levelPrefix}_bai${i}_luyentap3', 'title': 'Luyện tập 3', 'icon': Icons.import_contacts, 'status': 0, 'section': sectionId },
        { 'id': idCounter++, 'key': '${levelPrefix}_bai${i}_luyennoi', 'title': 'Luyện nói', 'icon': Icons.mic, 'status': 0, 'section': sectionId },
        { 'id': idCounter++, 'key': '${levelPrefix}_bai${i}_luyenviet', 'title': 'Luyện viết', 'icon': Icons.edit, 'status': 0, 'section': sectionId },
        { 'id': idCounter++, 'key': '${levelPrefix}_bai${i}_ontap', 'title': 'Ôn tập', 'icon': Icons.star, 'status': 0, 'isBoss': true, 'section': sectionId },
      ]);
    }
  }

  Future<void> _refreshProgress() async {
    List<String> completed = await UserProgress().getCompletedLessons();

    setState(() {
      for (var lesson in _lessons) {
        lesson['status'] = 0;
      }
      if (_lessons.isNotEmpty) _lessons[0]['status'] = 1;

      for (int i = 0; i < _lessons.length; i++) {
        String key = _lessons[i]['key'];
        if (completed.contains(key)) {
          _lessons[i]['status'] = 2;
          if (i + 1 < _lessons.length && _lessons[i + 1]['status'] != 2) {
            _lessons[i + 1]['status'] = 1;
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: kSoftBackground,
        elevation: 0,
        actions: [
          // Luyện đọc
          IconButton(
            icon: const Icon(Icons.chrome_reader_mode, color: kPrimaryBlue),
            tooltip: 'Luyện đọc',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReadingPracticeScreen()),
              );
            },
          ),
          // Luyện nghe
          IconButton(
            icon: const Icon(Icons.headphones, color: kPrimaryBlue),
            tooltip: 'Luyện nghe',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ListeningPracticeScreen()),
              );
            },
          ),
          // Sổ tay từ vựng
          IconButton(
            icon: const Icon(Icons.menu_book, color: kPrimaryBlue),
            tooltip: 'Sổ tay từ vựng',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VocabularyNotebookScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        title: GestureDetector(
          onTap: () {
            SoundManager.instance.vibrate('light');
            CourseSelectionHelper.showCoursePopup(context, _currentCourse, (
              selectedCourse,
            ) {
              setState(() {
                _currentCourse = selectedCourse;
                if (selectedCourse == 'Sơ cấp 1 - N5') {
                  _initLessons();
                } else if (selectedCourse == 'Sơ cấp 2 - N4') {
                  _initNXLessons('n4', 200);
                } else if (selectedCourse == 'Trung cấp 1 - N3') {
                  _initNXLessons('n3', 300);
                } else if (selectedCourse == 'Trung cấp 2 - N2') {
                  _initNXLessons('n2', 400);
                } else if (selectedCourse == 'Cao cấp - N1') {
                  _initNXLessons('n1', 500);
                }
                _refreshProgress();
              });
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: kPrimaryBlue.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.school, color: kPrimaryBlue, size: 20),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                      _currentCourse,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.black54,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Nền xanh nhẹ có hoạ tiết thân thiện
          Positioned.fill(
            child: CustomPaint(
              painter: GreenPatternPainter(),
            ),
          ),

          // Danh sách các chặng học được sinh ra tự động
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: 100),
            child: LayoutBuilder(
              builder: (context, constraints) {
                List<Widget> columnChildren = [];
                int totalNodesSoFar = 0;

                // Vòng lặp duyệt qua tất cả các Chặng (Sections)
                for (var section in _sections) {
                  // Lấy các bài học thuộc Section này
                  final chunkLessons = _lessons
                      .where((l) => l['section'] == section['id'])
                      .toList();
                  if (chunkLessons.isEmpty) continue;

                  // Tính số bài đã học
                  int completed = chunkLessons
                      .where((l) => l['status'] == 2)
                      .length;

                  // 1. Thêm Khung Tiêu Đề
                  columnChildren.add(
                    _buildDynamicSectionHeader(
                      title: section['title'],
                      subtitle:
                          "${section['subtitle']} • $completed/${chunkLessons.length} bài",
                      icon: section['icon'],
                      bgColor: Color(section['bg']),
                      iconColor: Color(section['color']),
                    ),
                  );
                  columnChildren.add(const SizedBox(height: 10));

                  // 2. Thêm Đường zigzag bài học (Truyền totalNodesSoFar để nét đứt nối mượt mà)
                  columnChildren.add(
                    _buildRoadMapChunk(
                      constraints.maxWidth,
                      chunkLessons,
                      totalNodesSoFar,
                    ),
                  );
                  columnChildren.add(const SizedBox(height: 30));

                  // Cộng dồn tổng số node để tính đường zigzag cho chặng tiếp theo
                  totalNodesSoFar += chunkLessons.length;
                }
                return Column(children: columnChildren);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          List<String> completed = await UserProgress().getCompletedLessons();
          List<String> reviewableKeys = completed.where((k) {
            return k.contains('_luyentap') || 
                   k.contains('_ontap') || 
                   k.contains('_luyennoi') || 
                   k.contains('_luyenviet');
          }).toList();
          
          if (!context.mounted) return;
          if (reviewableKeys.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Chưa có bài nào để ôn tập! Hãy học thêm nhé.")),
            );
            return;
          }
          
          String randomKey = reviewableKeys[Random().nextInt(reviewableKeys.length)];
          String prefix = 'Ôn tập';
          if (randomKey.contains('_luyennoi')) {
            prefix = 'Luyện nói';
          } else if (randomKey.contains('_luyenviet')) {
            prefix = 'Luyện viết';
          }

          String lessonTitle = _lessons.firstWhere(
            (l) => l['key'] == randomKey, 
            orElse: () => {'title': 'Ôn tập nhanh'}
          )['title'];

          SoundManager.instance.vibrate('light');
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LessonScreen(
                lessonId: randomKey,
                lessonTitle: '$prefix: $lessonTitle',
              ),
            ),
          );
          if (result == true && context.mounted) {
            _refreshProgress();
          }
        },
        icon: const Icon(Icons.flash_on, color: Colors.white),
        label: const Text(
          "Ôn tập nhanh",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.orange,
        elevation: 6,
      ),
    );
  }

  // Khung tiêu đề linh hoạt màu sắc cho từng Chặng
  Widget _buildDynamicSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildRoadMapChunk(
    double screenWidth,
    List<Map<String, dynamic>> chunkLessons,
    int startZigZagIndex,
  ) {
    return Stack(
      children: [
        CustomPaint(
          size: Size(screenWidth, chunkLessons.length * 120.0),
          painter: DashedPathPainter(
            totalItems: chunkLessons.length,
            startIndex: startZigZagIndex,
          ),
        ),
        Column(
          children: List.generate(chunkLessons.length, (index) {
            final lesson = chunkLessons[index];
            int globalIndex = startZigZagIndex + index;

            double alignX = 0;
            if (globalIndex % 4 == 1) {
              alignX = -0.5;
            } else if (globalIndex % 4 == 3)
              alignX = 0.5;

            return Container(
              height: 120,
              alignment: Alignment(alignX, 0),
              child: _buildLessonNode(lesson),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildLessonNode(Map<String, dynamic> lesson) {
    Color color;
    Color shadowColor;
    double size = 70;

    if (lesson['status'] == 2) {
      color = const Color(0xFFFFC800);
      shadowColor = const Color(0xFFD3A600);
    } else if (lesson['status'] == 1) {
      color = const Color(0xFF58CC02);
      shadowColor = const Color(0xFF46A302);
    } else {
      color = const Color(0xFFE5E5E5);
      shadowColor = const Color(0xFFCECECE);
      size = 65;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () async {
            if (lesson['status'] == 0) {
              SoundManager.instance.vibrate('error');
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Hãy hoàn thành bài trước để mở khóa!"),
                ),
              );
              return;
            }
            String lessonId = lesson['key'];
            if (lessonId.isNotEmpty) {
              SoundManager.instance.vibrate('light');
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LessonScreen(
                    lessonId: lessonId,
                    lessonTitle: lesson['title'],
                  ),
                ),
              );

              if (result == true) {
                _refreshProgress(); // <-- Học xong thì load lại dữ liệu ngay
              }
            }
          },
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  offset: const Offset(0, 6),
                  blurRadius: 0,
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.2),
                  offset: const Offset(0, -3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Center(
              child: lesson['status'] == 2
                  ? const Icon(Icons.check, color: Colors.white, size: 35)
                  : (lesson['isBoss'] == true
                        ? const Icon(Icons.star, color: Colors.white, size: 35)
                        : Icon(lesson['icon'], color: Colors.white, size: 30)),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          lesson['title'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: lesson['status'] == 0
                ? Colors.grey.shade400
                : Colors.black54,
            fontSize: 13,
          ),
        ),
      ],
    );
  }


}

class DashedPathPainter extends CustomPainter {
  final int totalItems;
  final int startIndex;

  DashedPathPainter({required this.totalItems, required this.startIndex});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    double centerX = size.width / 2;
    double itemHeight = 120.0;
    Path path = Path();
    Offset start = Offset(centerX, itemHeight / 2);
    if (startIndex % 4 == 1) {
      start = Offset(centerX - (size.width * 0.25), itemHeight / 2);
    } else if (startIndex % 4 == 3)
      start = Offset(centerX + (size.width * 0.25), itemHeight / 2);

    path.moveTo(start.dx, start.dy);

    for (int i = 0; i < totalItems - 1; i++) {
      int globalI = startIndex + i;

      double currentX = centerX;
      if (globalI % 4 == 1) {
        currentX = centerX - (size.width * 0.25);
      } else if (globalI % 4 == 3)
        currentX = centerX + (size.width * 0.25);
      double currentY = (i * itemHeight) + (itemHeight / 2);

      double nextX = centerX;
      if ((globalI + 1) % 4 == 1) {
        nextX = centerX - (size.width * 0.25);
      } else if ((globalI + 1) % 4 == 3)
        nextX = centerX + (size.width * 0.25);
      double nextY = ((i + 1) * itemHeight) + (itemHeight / 2);

      path.quadraticBezierTo(currentX, nextY, nextX, nextY);
    }

    ui.PathMetrics pathMetrics = path.computeMetrics();
    for (ui.PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        canvas.drawPath(pathMetric.extractPath(distance, distance + 15), paint);
        distance += 30;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}



class GreenPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Vẽ nền xanh nhạt toàn màn hình
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFFF4FAF4),
    );

    // Vẽ hoạ tiết chấm bi thân thiện
    final paint = Paint()
      ..color = const Color(0xFFE2F0E2)
      ..style = PaintingStyle.fill;
    
    double spacing = 40.0;
    double radius = 4.0;
    
    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        double offsetX = ((y / spacing).floor() % 2 == 0) ? 0 : spacing / 2;
        canvas.drawCircle(Offset(x + offsetX, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CourseSelectionHelper {
  static void showCoursePopup(
    BuildContext context,
    String currentCourse,
    Function(String) onSelect,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CourseSelectionPopup(
        currentCourse: currentCourse,
        onSelect: onSelect,
      ),
    );
  }
}

class CourseSelectionPopup extends StatelessWidget {
  final String currentCourse;
  final Function(String) onSelect;

  const CourseSelectionPopup({
    super.key,
    required this.currentCourse,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 12,
              top: 16,
              bottom: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Chọn khóa học',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  _buildMainJLPTCard(context),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ReadingPracticeScreen()),
                      );
                    },
                    child: _buildExtraCourseCard(
                      title: 'Luyện đọc',
                      subtitle: '25 bài',
                      bgColor: const Color(0xFFF3E5F5),
                      iconData: Icons.menu_book_rounded,
                      iconColor: Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ListeningPracticeScreen()),
                      );
                    },
                    child: _buildExtraCourseCard(
                      title: 'Luyện nghe',
                      subtitle: '48 bài',
                      bgColor: const Color(0xFFFFEBEE),
                      iconData: Icons.headphones_rounded,
                      iconColor: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainJLPTCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.school, size: 36, color: Colors.orange),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Lộ trình JLPT',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '5 cấp độ',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.keyboard_arrow_up, color: Colors.black54),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildLevelButton(context, 'Sơ cấp 1 - N5'),
              _buildLevelButton(context, 'Sơ cấp 2 - N4'),
              _buildLevelButton(context, 'Trung cấp 1 - N3'),
              _buildLevelButton(context, 'Trung cấp 2 - N2'),
              _buildLevelButton(context, 'Cao cấp - N1'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelButton(BuildContext context, String text) {
    bool isActive = (text == currentCourse);

    return LayoutBuilder(
      builder: (context, constraints) {
        double width = (MediaQuery.of(context).size.width - 32 - 32 - 12) / 2;
        return GestureDetector(
          onTap: () {
            onSelect(text);
            Navigator.pop(context);
          },
          child: Container(
            width: width,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF58CC02) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                if (!isActive)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bar_chart_rounded,
                  color: isActive ? Colors.white : Colors.grey.shade400,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                      color: isActive ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExtraCourseCard({
    required String title,
    required String subtitle,
    required Color bgColor,
    required IconData iconData,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(iconData, size: 36, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


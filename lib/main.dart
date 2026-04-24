import 'package:flutter/material.dart';
import 'sound_manager.dart';
import 'recognition_manager.dart';
import 'dart:ui' as ui;
import 'lesson_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_screen.dart';
import 'achievements_screen.dart';
import 'user_progress.dart';
import 'settings_screen.dart';
import 'tips_screen.dart';
import 'alphabet_practice_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await RecognitionManager.instance.checkAndDownloadModel();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kanji Summoner',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF58CC02),
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF58CC02),
          primary: const Color(0xFF58CC02),
          secondary: const Color(0xFF1CB0F6),
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
              color: Colors.black87, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF58CC02),
            foregroundColor: Colors.white,
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
      home: const MainScreen(),
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

  final List<Widget> _screens = [
    const SummonerHomePage(),
    const AlphabetScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            AlphabetScreen.readingSessionId++;
            try { SoundManager.instance.stop(); } catch(e) {}
            setState(() => _currentIndex = index);
            SoundManager.instance.vibrate('light');
          },
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF58CC02),
          unselectedItemColor: Colors.grey,
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
              icon: Text(
                "あ",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _currentIndex == 1 ? const Color(0xFF58CC02) : Colors.grey,
                ),
              ),
              label: "Chữ cái",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person),
              activeIcon: Icon(Icons.person, size: 30),
              label: "Tôi",
            ),
          ],
        ),
      ),
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Bảng Chữ Cái"),
          elevation: 0,
          bottom: const TabBar(
            labelColor: Color(0xFF58CC02),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF58CC02),
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: [
              Tab(text: "GOJŪON"),
              Tab(text: "HỮU THANH"),
              Tab(text: "YŌON"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            JapaneseGrid(type: GridType.gojuon),
            JapaneseGrid(type: GridType.dakuon),
            JapaneseGrid(type: GridType.yoon),
          ],
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
          [{'h': 'あ', 'k': 'ア', 'r': 'a'}, {'h': 'い', 'k': 'イ', 'r': 'i'}, {'h': 'う', 'k': 'ウ', 'r': 'u'}, {'h': 'え', 'k': 'エ', 'r': 'e'}, {'h': 'お', 'k': 'オ', 'r': 'o'}],
          [{'h': 'か', 'k': 'カ', 'r': 'ka'}, {'h': 'き', 'k': 'キ', 'r': 'ki'}, {'h': 'く', 'k': 'ク', 'r': 'ku'}, {'h': 'け', 'k': 'ケ', 'r': 'ke'}, {'h': 'こ', 'k': 'コ', 'r': 'ko'}],
          [{'h': 'さ', 'k': 'サ', 'r': 'sa'}, {'h': 'し', 'k': 'シ', 'r': 'shi'}, {'h': 'す', 'k': 'ス', 'r': 'su'}, {'h': 'せ', 'k': 'セ', 'r': 'se'}, {'h': 'そ', 'k': 'ソ', 'r': 'so'}],
          [{'h': 'た', 'k': 'タ', 'r': 'ta'}, {'h': 'ち', 'k': 'チ', 'r': 'chi'}, {'h': 'つ', 'k': 'ツ', 'r': 'tsu'}, {'h': 'て', 'k': 'テ', 'r': 'te'}, {'h': 'と', 'k': 'ト', 'r': 'to'}],
          [{'h': 'な', 'k': 'ナ', 'r': 'na'}, {'h': 'に', 'k': 'ニ', 'r': 'ni'}, {'h': 'ぬ', 'k': 'ヌ', 'r': 'nu'}, {'h': 'ね', 'k': 'ネ', 'r': 'ne'}, {'h': 'の', 'k': 'ノ', 'r': 'no'}],
          [{'h': 'は', 'k': 'ハ', 'r': 'ha'}, {'h': 'ひ', 'k': 'ヒ', 'r': 'hi'}, {'h': 'ふ', 'k': 'フ', 'r': 'fu'}, {'h': 'へ', 'k': 'ヘ', 'r': 'he'}, {'h': 'ほ', 'k': 'ホ', 'r': 'ho'}],
          [{'h': 'ま', 'k': 'マ', 'r': 'ma'}, {'h': 'み', 'k': 'ミ', 'r': 'mi'}, {'h': 'む', 'k': 'ム', 'r': 'mu'}, {'h': 'め', 'k': 'メ', 'r': 'me'}, {'h': 'も', 'k': 'モ', 'r': 'mo'}],
          [{'h': 'や', 'k': 'ヤ', 'r': 'ya'}, {'h': '', 'k': '', 'r': ''}, {'h': 'ゆ', 'k': 'ユ', 'r': 'yu'}, {'h': '', 'k': '', 'r': ''}, {'h': 'よ', 'k': 'ヨ', 'r': 'yo'}],
          [{'h': 'ら', 'k': 'ラ', 'r': 'ra'}, {'h': 'り', 'k': 'リ', 'r': 'ri'}, {'h': 'る', 'k': 'ル', 'r': 'ru'}, {'h': 'れ', 'k': 'レ', 'r': 're'}, {'h': 'ろ', 'k': 'ロ', 'r': 'ro'}],
          [{'h': 'わ', 'k': 'ワ', 'r': 'wa'}, {'h': '', 'k': '', 'r': ''}, {'h': '', 'k': '', 'r': ''}, {'h': '', 'k': '', 'r': ''}, {'h': 'を', 'k': 'ヲ', 'r': 'wo'}],
          [{'h': 'ん', 'k': 'ン', 'r': 'n'}, {'h': '', 'k': '', 'r': ''}, {'h': '', 'k': '', 'r': ''}, {'h': '', 'k': '', 'r': ''}, {'h': '', 'k': '', 'r': ''}],
        ];
      case GridType.dakuon:
        return [
          [{'h': 'が', 'k': 'ガ', 'r': 'ga'}, {'h': 'ぎ', 'k': 'ギ', 'r': 'gi'}, {'h': 'ぐ', 'k': 'グ', 'r': 'gu'}, {'h': 'げ', 'k': 'ゲ', 'r': 'ge'}, {'h': 'ご', 'k': 'ゴ', 'r': 'go'}],
          [{'h': 'ざ', 'k': 'ザ', 'r': 'za'}, {'h': 'じ', 'k': 'ジ', 'r': 'ji'}, {'h': 'ず', 'k': 'ズ', 'r': 'zu'}, {'h': 'ぜ', 'k': 'ゼ', 'r': 'ze'}, {'h': 'ぞ', 'k': 'ゾ', 'r': 'zo'}],
          [{'h': 'だ', 'k': 'ダ', 'r': 'da'}, {'h': 'ぢ', 'k': 'ヂ', 'r': 'ji'}, {'h': 'づ', 'k': 'ヅ', 'r': 'zu'}, {'h': 'で', 'k': 'デ', 'r': 'de'}, {'h': 'ど', 'k': 'ド', 'r': 'do'}],
          [{'h': 'ば', 'k': 'バ', 'r': 'ba'}, {'h': 'び', 'k': 'ビ', 'r': 'bi'}, {'h': 'ぶ', 'k': 'ブ', 'r': 'bu'}, {'h': 'べ', 'k': 'ベ', 'r': 'be'}, {'h': 'ぼ', 'k': 'ボ', 'r': 'bo'}],
          [{'h': 'ぱ', 'k': 'パ', 'r': 'pa'}, {'h': 'ぴ', 'k': 'ピ', 'r': 'pi'}, {'h': 'ぷ', 'k': 'プ', 'r': 'pu'}, {'h': 'ぺ', 'k': 'ペ', 'r': 'pe'}, {'h': 'ぽ', 'k': 'ポ', 'r': 'po'}],
        ];
      case GridType.yoon:
        return [
          [{'h': 'きゃ', 'k': 'キャ', 'r': 'kya'}, {'h': 'きゅ', 'k': 'キュ', 'r': 'kyu'}, {'h': 'きょ', 'k': 'キョ', 'r': 'kyo'}],
          [{'h': 'しゃ', 'k': 'シャ', 'r': 'sha'}, {'h': 'しゅ', 'k': 'シュ', 'r': 'shu'}, {'h': 'しょ', 'k': 'ショ', 'r': 'sho'}],
          [{'h': 'ちゃ', 'k': 'チャ', 'r': 'cha'}, {'h': 'ちゅ', 'k': 'チュ', 'r': 'chu'}, {'h': 'ちょ', 'k': 'チョ', 'r': 'cho'}],
          [{'h': 'にゃ', 'k': 'ニャ', 'r': 'nya'}, {'h': 'にゅ', 'k': 'ニュ', 'r': 'nyu'}, {'h': 'にょ', 'k': 'ニョ', 'r': 'nyo'}],
          [{'h': 'ひゃ', 'k': 'ヒャ', 'r': 'hya'}, {'h': 'ひゅ', 'k': 'ヒュ', 'r': 'hyu'}, {'h': 'ひょ', 'k': 'ヒョ', 'r': 'hyo'}],
          [{'h': 'みゃ', 'k': 'ミャ', 'r': 'mya'}, {'h': 'みゅ', 'k': 'ミュ', 'r': 'myu'}, {'h': 'みょ', 'k': 'ミョ', 'r': 'myo'}],
          [{'h': 'りゃ', 'k': 'リャ', 'r': 'rya'}, {'h': 'りゅ', 'k': 'リュ', 'r': 'ryu'}, {'h': 'りょ', 'k': 'リョ', 'r': 'ryo'}],
          [{'h': 'ぎゃ', 'k': 'ギャ', 'r': 'gya'}, {'h': 'ぎゅ', 'k': 'ギュ', 'r': 'gyu'}, {'h': 'ぎょ', 'k': 'ギョ', 'r': 'gyo'}],
          [{'h': 'じゃ', 'k': 'ジャ', 'r': 'ja'}, {'h': 'じゅ', 'k': 'ジュ', 'r': 'ju'}, {'h': 'じょ', 'k': 'ジョ', 'r': 'jo'}],
          [{'h': 'びゃ', 'k': 'ビャ', 'r': 'bya'}, {'h': 'びゅ', 'k': 'ビュ', 'r': 'byu'}, {'h': 'びょ', 'k': 'ビョ', 'r': 'byo'}],
          [{'h': 'ぴゃ', 'k': 'ピャ', 'r': 'pya'}, {'h': 'ぴゅ', 'k': 'ピュ', 'r': 'pyu'}, {'h': 'ぴょ', 'k': 'ピョ', 'r': 'pyo'}],
        ];
    }
  }

  // 2. HÀM ĐỌC DANH SÁCH MỚI (Tự ngắt siêu nhạy)
  void _speakListSlowly(List<String> chars) async {
    AlphabetScreen.readingSessionId++; // Đánh dấu bắt đầu 1 lệnh đọc mới
    int mySessionId = AlphabetScreen.readingSessionId;

    try { SoundManager.instance.stop(); } catch(e) {} // Cắt đứt âm thanh hiện tại

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
                      if (colIndex < row.length && row[colIndex]['h']!.isNotEmpty) {
                        colChars.add(row[colIndex]['h']!);
                      }
                    }
                    _speakListSlowly(colChars);
                  },
                  child: const Icon(Icons.arrow_drop_down_circle, color: Color(0xFF58CC02), size: 24),
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
                height: 80,
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: rowChars.map((charData) {
                          if (charData['h']!.isEmpty) return const Expanded(child: SizedBox());

                          return Expanded(
                            child: InkWell(
                              onTap: () {
                                // Ngắt vòng lặp hàng/cột ngay lập tức nếu bấm 1 chữ lẻ
                                AlphabetScreen.readingSessionId++;
                                try { SoundManager.instance.stop(); } catch(e) {}

                                SoundManager.instance.speakJapanese(charData['h']!);
                                SoundManager.instance.vibrate('light');
                              },
                              child: Container(
                                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(charData['h']!, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(charData['k']!, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                        const SizedBox(width: 4),
                                        Text(charData['r']!, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                      ],
                                    )
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
                        List<String> rowTexts = rowChars.where((e) => e['h']!.isNotEmpty).map((e) => e['h']!).toList();
                        _speakListSlowly(rowTexts);
                      },
                      child: Container(
                        width: 40,
                        color: Colors.grey[100],
                        child: const Icon(Icons.play_circle_fill, color: Color(0xFF58CC02), size: 24),
                      ),
                    )
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

// ==========================================================
// 3. MÀN HÌNH "TÔI" (PROFILE DASHBOARD)
// ==========================================================
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey _progressChartKey = GlobalKey();
  List<Map<String, dynamic>> previewTips = [];

  @override
  void initState() {
    super.initState();
    TipsData.sortTips(); // Xếp chuẩn dữ liệu trước
    previewTips = TipsData.list.take(2).toList(); // Lấy 2 cái đầu tiên giữ cố định
  }

  // Hàm gọi để làm mới lại 2 mẹo bên ngoài khi từ màn hình chi tiết đi ra
  void _refreshTips() {
    setState(() {
      previewTips = TipsData.list.take(2).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final User? user = snapshot.data;
        final bool isLoggedIn = user != null;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
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
                    label: const Text("Đăng xuất", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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
    String displayName = isLoggedIn ? (user.email?.split('@')[0] ?? "Summoner") : "Đăng nhập";

    return GestureDetector(
      onTap: () {
        if (!isLoggedIn) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF78C850),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: CircleAvatar(
                radius: 35,
                backgroundColor: const Color(0xFFFFF3CD),
                child: Image.asset('assets/images/dog_happy.png', width: 50, errorBuilder: (_,__,___) => const Icon(Icons.face, size: 40, color: Colors.orange)),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(displayName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 5),
                  FutureBuilder<int>(
                      future: UserProgress().getExp(),
                      builder: (context, snapshot) {
                        int exp = snapshot.data ?? 0;
                        return Text("Điểm luyện tập: $exp exp", style: const TextStyle(fontSize: 14, color: Colors.white70));
                      }
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
      {'icon': Icons.trending_up, 'label': 'Tiến độ học', 'color': Colors.amber, 'bg': 0xFFFFF8E1},
      {'icon': Icons.emoji_events, 'label': 'Danh hiệu', 'color': Colors.orange, 'bg': 0xFFFFF3E0},
      {'icon': Icons.lightbulb, 'label': 'Mẹo học', 'color': Colors.blue, 'bg': 0xFFE3F2FD},
      {'icon': Icons.settings, 'label': 'Cài đặt', 'color': Colors.blueGrey, 'bg': 0xFFECEFF1},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: menuItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.75,
        mainAxisSpacing: 20,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return GestureDetector(
          onTap: () {
            // 3. Thêm tính năng cuộn xuống Biểu đồ tiến độ
            if (item['label'] == 'Tiến độ học') {
              if (_progressChartKey.currentContext != null) {
                Scrollable.ensureVisible(
                  _progressChartKey.currentContext!,
                  duration: const Duration(milliseconds: 600), // Thời gian cuộn 0.6s
                  curve: Curves.easeInOut, // Hiệu ứng cuộn mềm mại
                );
              }
            }
            else if (item['label'] == 'Danh hiệu') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AchievementsScreen()));
            }
            else if (item['label'] == 'Mẹo học') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const TipsScreen())).then((_){
                _refreshTips();
              });
            }
            else if (item['label'] == 'Cài đặt') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            }
            else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Tính năng ${item['label']} đang phát triển!")));
            }
          },
          child: Column(
            children: [
              Container(
                width: 55, height: 55,
                decoration: BoxDecoration(color: Color(item['bg']), shape: BoxShape.circle),
                child: Icon(item['icon'], color: item['color'], size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                item['label'],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500),
                maxLines: 2, overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF78C850), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Tiến trình luyện tập tuần", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const Text("Hôm nay", style: TextStyle(color: Colors.white70, fontSize: 12)),
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
          )
        ],
      ),
    );
  }

  Widget _chartBar(String day, double percent, bool isToday) {
    return Column(
      children: [
        Container(
          width: 12, height: 60, alignment: Alignment.bottomCenter,
          child: Container(
            width: 12, height: 60 * (percent == 0 ? 0.1 : percent),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
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
          final List<String> ranks = ["Tân binh", "Binh nhất", "Thượng sĩ", "Đại uý", "Đại tá", "Đại tướng"];
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
            progressPercent = (currentRankIndex + levelFraction) / (ranks.length - 1);
          }

          return Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Cấp bậc", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    Text("$exp EXP", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.amber)),
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
                          Container(height: 4, width: double.infinity, margin: const EdgeInsets.symmetric(horizontal: 10), color: Colors.grey.shade200),
                          Positioned(
                              left: 10,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                height: 4,
                                width: activeWidth,
                                color: const Color(0xFF8BC34A),
                              )
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(ranks.length, (index) {
                              bool isAchieved = index <= currentRankIndex;
                              return Container(
                                width: 20, height: 20,
                                decoration: BoxDecoration(
                                  color: isAchieved ? const Color(0xFF8BC34A) : Colors.grey.shade200,
                                  shape: BoxShape.circle,
                                  border: isAchieved ? Border.all(color: Colors.amber, width: 3) : null,
                                ),
                              );
                            }),
                          ),
                        ],
                      );
                    }
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
                            fontWeight: isAchieved ? FontWeight.bold : FontWeight.normal,
                            color: isAchieved ? Colors.black87 : Colors.grey.shade400
                        ),
                      ),
                    );
                  }),
                )
              ],
            ),
          );
        }
    );
  }

  Widget _buildAchievementsSection(BuildContext context) {
    final List<Map<String, dynamic>> previewAchievements = AchievementData.list.take(4).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Danh hiệu sắp đạt được", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AchievementsScreen()));
                },
                child: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
              )
            ],
          ),
          const SizedBox(height: 20),

          ...previewAchievements.map((item) => _buildAchievementItem(item)).toList(),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AchievementsScreen()));
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFF1F8E9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text(
                "Xem danh sách danh hiệu",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF58CC02)
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(color: data['color'], borderRadius: BorderRadius.circular(16)),
            child: Icon(data['icon'], color: Colors.white, size: 30),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 4),
                Text(data['desc'], style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
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
                )
              ],
            ),
          )
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
          const Text("Mẹo học tiếng Nhật", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 15),

          // Vòng lặp vẽ từ biến previewTips đã bị "khóa" ở initState
          ...previewTips.map((tip) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 5, offset: const Offset(0, 3))],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      tip['text'],
                      style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
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
                      color: tip['isLiked'] ? Colors.redAccent : Colors.pink.shade100,
                      size: 28,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const TipsScreen())).then((_) {
                  _refreshTips();
                });
              },
              child: const Text(
                "Xem danh sách mẹo học tiếng Nhật",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF66BB6A),
                  decoration: TextDecoration.underline,
                  decorationColor: Color(0xFF66BB6A),
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
  const SummonerHomePage({super.key});

  @override
  State<SummonerHomePage> createState() => _SummonerHomePageState();
}

class _SummonerHomePageState extends State<SummonerHomePage> {
  final ScrollController _scrollController = ScrollController();

  // 1. ĐỊNH NGHĨA CÁC CHẶNG HỌC (CHAPTERS)
  // Sau này muốn thêm Cơ bản 5, 6... bạn chỉ cần thêm 1 dòng vào đây
  final List<Map<String, dynamic>> _sections = [
    {'id': 'alphabet', 'title': 'Bảng chữ cái', 'subtitle': 'Khởi động', 'icon': Icons.sort_by_alpha, 'color': 0xFF4A89F3, 'bg': 0xFFEDF4FE},
    {'id': 'basic1', 'title': 'Cơ bản 1', 'subtitle': 'Chào hỏi & Nghề nghiệp', 'icon': Icons.waving_hand, 'color': 0xFFFFA000, 'bg': 0xFFFFF8E1},
    {'id': 'basic2', 'title': 'Cơ bản 2', 'subtitle': 'Đồ vật & Sở hữu', 'icon': Icons.business_center, 'color': 0xFFE91E63, 'bg': 0xFFFCE4EC},
    {'id': 'basic3', 'title': 'Cơ bản 3', 'subtitle': 'Địa điểm & Giá tiền', 'icon': Icons.storefront, 'color': 0xFF9C27B0, 'bg': 0xFFF3E5F5},
    {'id': 'basic4', 'title': 'Cơ bản 4', 'subtitle': 'Thời gian & Sinh hoạt', 'icon': Icons.access_time_filled, 'color': 0xFF00BCD4, 'bg': 0xFFE0F7FA},
    {'id': 'basic5', 'title': 'Cơ bản 5', 'subtitle': 'Di chuyển & Phương tiện', 'icon': Icons.directions_transit, 'color': 0xFF4CAF50, 'bg': 0xFFE8F5E9},
    {'id': 'basic6', 'title': 'Cơ bản 6', 'subtitle': 'Ăn uống & Mua sắm', 'icon': Icons.restaurant, 'color': 0xFFFF9800, 'bg': 0xFFFFF3E0},
    {'id': 'basic7', 'title': 'Cơ bản 7', 'subtitle': 'Cho, Nhận & Công cụ', 'icon': Icons.card_giftcard, 'color': 0xFFF44336, 'bg': 0xFFFFEBEE},
    {'id': 'basic8', 'title': 'Cơ bản 8', 'subtitle': 'Tính từ (Mô tả)', 'icon': Icons.auto_awesome, 'color': 0xFF3F51B5, 'bg': 0xFFE8EAF6},
    {'id': 'basic9', 'title': 'Cơ bản 9', 'subtitle': 'Sở thích & Lý do', 'icon': Icons.favorite, 'color': 0xFFE91E63, 'bg': 0xFFFCE4EC},
    {'id': 'basic10', 'title': 'Cơ bản 10', 'subtitle': 'Sự tồn tại & Vị trí', 'icon': Icons.location_on, 'color': 0xFF009688, 'bg': 0xFFE0F2F1},
  ];

  // 2. DANH SÁCH TOÀN BỘ BÀI HỌC
  late List<Map<String, dynamic>> _lessons;

  @override
  void initState() {
    super.initState();
    _initLessons(); // Khởi tạo dữ liệu
    _refreshProgress();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(100.0, duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
      }
    });
  }

  // Khai báo tập trung toàn bộ bài học tại đây
  void _initLessons() {
    _lessons = [
      // --- CHẶNG 1: BẢNG CHỮ CÁI ---
      {'id': 1, 'key': 'hang_a', 'title': 'Hàng A (あ)', 'icon': Icons.menu_book, 'status': 1, 'section': 'alphabet'},
      {'id': 2, 'key': 'hang_ka', 'title': 'Hàng Ka (か)', 'icon': Icons.menu_book, 'status': 0, 'section': 'alphabet'},
      {'id': 3, 'key': 'hang_sa', 'title': 'Hàng Sa (さ)', 'icon': Icons.menu_book, 'status': 0, 'section': 'alphabet'},
      {'id': 4, 'key': 'hang_ta', 'title': 'Hàng Ta (た)', 'icon': Icons.menu_book, 'status': 0, 'section': 'alphabet'},
      {'id': 5, 'key': 'hang_na', 'title': 'Hàng Na (な)', 'icon': Icons.menu_book, 'status': 0, 'section': 'alphabet'},
      {'id': 6, 'key': 'hang_ha', 'title': 'Hàng Ha (は)', 'icon': Icons.menu_book, 'status': 0, 'section': 'alphabet'},
      {'id': 7, 'key': 'hang_ma', 'title': 'Hàng Ma (ま)', 'icon': Icons.menu_book, 'status': 0, 'section': 'alphabet'},
      {'id': 8, 'key': 'hang_ya', 'title': 'Hàng Ya (や)', 'icon': Icons.menu_book, 'status': 0, 'section': 'alphabet'},
      {'id': 9, 'key': 'hang_ra', 'title': 'Hàng Ra (ら)', 'icon': Icons.menu_book, 'status': 0, 'section': 'alphabet'},
      {'id': 10, 'key': 'hang_wa', 'title': 'Hàng Wa (わ)', 'icon': Icons.menu_book, 'status': 0, 'section': 'alphabet'},
      {'id': 11, 'key': 'hang_all', 'title': 'TỔNG HỢP', 'icon': Icons.star, 'status': 0, 'isBoss': true, 'section': 'alphabet'},

      // --- CHẶNG 2: CƠ BẢN 1 ---
      {'id': 12, 'key': 'cb1_lythuyet', 'title': 'Lý thuyết', 'icon': Icons.menu_book, 'status': 0, 'section': 'basic1'},
      {'id': 13, 'key': 'cb1_luyentap1', 'title': 'Luyện tập 1', 'icon': Icons.import_contacts, 'status': 0, 'section': 'basic1'},
      {'id': 14, 'key': 'cb1_luyentap2', 'title': 'Luyện tập 2', 'icon': Icons.import_contacts, 'status': 0, 'section': 'basic1'},
      {'id': 15, 'key': 'cb1_luyentap3', 'title': 'Luyện tập 3', 'icon': Icons.import_contacts, 'status': 0, 'section': 'basic1'},
      {'id': 16, 'key': 'cb1_luyennoi', 'title': 'Luyện nói', 'icon': Icons.mic, 'status': 0, 'section': 'basic1'},
      {'id': 17, 'key': 'cb1_luyenviet', 'title': 'Luyện viết', 'icon': Icons.edit, 'status': 0, 'section': 'basic1'},
      {'id': 18, 'key': 'cb1_ontap', 'title': 'Ôn tập', 'icon': Icons.star, 'status': 0, 'isBoss': true, 'section': 'basic1'},

      // --- CHẶNG 3: CƠ BẢN 2 ---
      {'id': 19, 'key': 'cb2_lythuyet', 'title': 'Lý thuyết', 'icon': Icons.menu_book, 'status': 0, 'section': 'basic2'},
      {'id': 20, 'key': 'cb2_luyentap1', 'title': 'Luyện tập 1', 'icon': Icons.import_contacts, 'status': 0, 'section': 'basic2'},
      {'id': 21, 'key': 'cb2_luyentap2', 'title': 'Luyện tập 2', 'icon': Icons.import_contacts, 'status': 0, 'section': 'basic2'},
      {'id': 22, 'key': 'cb2_luyentap3', 'title': 'Luyện tập 3', 'icon': Icons.import_contacts, 'status': 0, 'section': 'basic2'},
      {'id': 23, 'key': 'cb2_luyennoi', 'title': 'Luyện nói', 'icon': Icons.mic, 'status': 0, 'section': 'basic2'},
      {'id': 24, 'key': 'cb2_luyenviet', 'title': 'Luyện viết', 'icon': Icons.edit, 'status': 0, 'section': 'basic2'},
      {'id': 25, 'key': 'cb2_ontap', 'title': 'Ôn tập', 'icon': Icons.star, 'status': 0, 'isBoss': true, 'section': 'basic2'},

      // --- CHẶNG 4: CƠ BẢN 3 ---
      {'id': 26, 'key': 'cb3_lythuyet', 'title': 'Lý thuyết', 'icon': Icons.menu_book, 'status': 0, 'section': 'basic3'},
      {'id': 27, 'key': 'cb3_luyentap1', 'title': 'Luyện tập 1', 'icon': Icons.import_contacts, 'status': 0, 'section': 'basic3'},
      {'id': 28, 'key': 'cb3_luyentap2', 'title': 'Luyện tập 2', 'icon': Icons.import_contacts, 'status': 0, 'section': 'basic3'},
      {'id': 29, 'key': 'cb3_luyentap3', 'title': 'Luyện tập 3', 'icon': Icons.import_contacts, 'status': 0, 'section': 'basic3'},
      {'id': 30, 'key': 'cb3_luyennoi', 'title': 'Luyện nói', 'icon': Icons.mic, 'status': 0, 'section': 'basic3'},
      {'id': 31, 'key': 'cb3_luyenviet', 'title': 'Luyện viết', 'icon': Icons.edit, 'status': 0, 'section': 'basic3'},
      {'id': 32, 'key': 'cb3_ontap', 'title': 'Ôn tập', 'icon': Icons.star, 'status': 0, 'isBoss': true, 'section': 'basic3'},

      // --- CHẶNG 5: CƠ BẢN 4 ---
      {'id': 33, 'key': 'cb4_lythuyet', 'title': 'Lý thuyết', 'icon': Icons.menu_book, 'status': 0, 'section': 'basic4'},
      {'id': 34, 'key': 'cb4_luyentap1', 'title': 'Luyện tập 1', 'icon': Icons.import_contacts, 'status': 0, 'section': 'basic4'},
      {'id': 35, 'key': 'cb4_luyentap2', 'title': 'Luyện tập 2', 'icon': Icons.import_contacts, 'status': 0, 'section': 'basic4'},
      {'id': 36, 'key': 'cb4_luyentap3', 'title': 'Luyện tập 3', 'icon': Icons.import_contacts, 'status': 0, 'section': 'basic4'},
      {'id': 37, 'key': 'cb4_luyennoi', 'title': 'Luyện nói', 'icon': Icons.mic, 'status': 0, 'section': 'basic4'},
      {'id': 38, 'key': 'cb4_luyenviet', 'title': 'Luyện viết', 'icon': Icons.edit, 'status': 0, 'section': 'basic4'},
      {'id': 39, 'key': 'cb4_ontap', 'title': 'Ôn tập', 'icon': Icons.star, 'status': 0, 'isBoss': true, 'section': 'basic4'},
      {'id': 40, 'key': 'cb5_lythuyet', 'title': 'Lý thuyết', 'icon': Icons.menu_book, 'status': 0, 'section': 'basic5'},
      {'id': 41, 'key': 'cb5_luyentap1', 'title': 'Luyện tập 1', 'icon': Icons.import_contacts, 'status': 0, 'section': 'basic5'},
      {'id': 42, 'key': 'cb5_luyentap2', 'title': 'Luyện tập 2', 'icon': Icons.import_contacts, 'status': 0, 'section': 'basic5'},
      {'id': 43, 'key': 'cb5_luyentap3', 'title': 'Luyện tập 3', 'icon': Icons.import_contacts, 'status': 0, 'section': 'basic5'},
      {'id': 44, 'key': 'cb5_luyennoi', 'title': 'Luyện nói', 'icon': Icons.mic, 'status': 0, 'section': 'basic5'},
      {'id': 45, 'key': 'cb5_luyenviet', 'title': 'Luyện viết', 'icon': Icons.edit, 'status': 0, 'section': 'basic5'},
      {'id': 46, 'key': 'cb5_ontap', 'title': 'Ôn tập', 'icon': Icons.star, 'status': 0, 'isBoss': true, 'section': 'basic5'},

      // --- CHẶNG 7: CƠ BẢN 6 ---
      {'id': 47, 'key': 'cb6_lythuyet', 'title': 'Lý thuyết', 'icon': Icons.menu_book, 'status': 0, 'section': 'basic6'},
      {'id': 48, 'key': 'cb6_luyentap1', 'title': 'Luyện tập 1', 'icon': Icons.import_contacts, 'status': 0, 'section': 'basic6'},
      {'id': 49, 'key': 'cb6_luyentap2', 'title': 'Luyện tập 2', 'icon': Icons.import_contacts, 'status': 0, 'section': 'basic6'},
      {'id': 50, 'key': 'cb6_luyentap3', 'title': 'Luyện tập 3', 'icon': Icons.import_contacts, 'status': 0, 'section': 'basic6'},
      {'id': 51, 'key': 'cb6_luyennoi', 'title': 'Luyện nói', 'icon': Icons.mic, 'status': 0, 'section': 'basic6'},
      {'id': 52, 'key': 'cb6_luyenviet', 'title': 'Luyện viết', 'icon': Icons.edit, 'status': 0, 'section': 'basic6'},
      {'id': 53, 'key': 'cb6_ontap', 'title': 'Ôn tập', 'icon': Icons.star, 'status': 0, 'isBoss': true, 'section': 'basic6'},

      // --- CHẶNG 8: CƠ BẢN 7 ---
      {'id': 54, 'key': 'cb7_lythuyet', 'title': 'Lý thuyết', 'icon': Icons.menu_book, 'status': 0, 'section': 'basic7'},
      {'id': 55, 'key': 'cb7_luyentap1', 'title': 'Luyện tập 1', 'icon': Icons.import_contacts, 'status': 0, 'section': 'basic7'},
      {'id': 56, 'key': 'cb7_luyentap2', 'title': 'Luyện tập 2', 'icon': Icons.import_contacts, 'status': 0, 'section': 'basic7'},
      {'id': 57, 'key': 'cb7_luyentap3', 'title': 'Luyện tập 3', 'icon': Icons.import_contacts, 'status': 0, 'section': 'basic7'},
      {'id': 58, 'key': 'cb7_luyennoi', 'title': 'Luyện nói', 'icon': Icons.mic, 'status': 0, 'section': 'basic7'},
      {'id': 59, 'key': 'cb7_luyenviet', 'title': 'Luyện viết', 'icon': Icons.edit, 'status': 0, 'section': 'basic7'},
      {'id': 60, 'key': 'cb7_ontap', 'title': 'Ôn tập', 'icon': Icons.star, 'status': 0, 'isBoss': true, 'section': 'basic7'},
      {'id': 61, 'key': 'cb8_lythuyet', 'title': 'Lý thuyết', 'icon': Icons.menu_book, 'status': 0, 'section': 'basic8'},
      {'id': 62, 'key': 'cb8_luyentap1', 'title': 'Luyện tập 1', 'icon': Icons.import_contacts, 'status': 0, 'section': 'basic8'},
      {'id': 63, 'key': 'cb8_luyentap2', 'title': 'Luyện tập 2', 'icon': Icons.import_contacts, 'status': 0, 'section': 'basic8'},
      {'id': 64, 'key': 'cb8_luyentap3', 'title': 'Luyện tập 3', 'icon': Icons.import_contacts, 'status': 0, 'section': 'basic8'},
      {'id': 65, 'key': 'cb8_luyennoi', 'title': 'Luyện nói', 'icon': Icons.mic, 'status': 0, 'section': 'basic8'},
      {'id': 66, 'key': 'cb8_luyenviet', 'title': 'Luyện viết', 'icon': Icons.edit, 'status': 0, 'section': 'basic8'},
      {'id': 67, 'key': 'cb8_ontap', 'title': 'Ôn tập', 'icon': Icons.star, 'status': 0, 'isBoss': true, 'section': 'basic8'},
      {'id': 68, 'key': 'cb9_lythuyet', 'title': 'Lý thuyết', 'icon': Icons.menu_book, 'status': 0, 'section': 'basic9'},
      {'id': 69, 'key': 'cb9_luyentap1', 'title': 'Luyện tập 1', 'icon': Icons.import_contacts, 'status': 0, 'section': 'basic9'},
      {'id': 70, 'key': 'cb9_luyentap2', 'title': 'Luyện tập 2', 'icon': Icons.import_contacts, 'status': 0, 'section': 'basic9'},
      {'id': 71, 'key': 'cb9_luyentap3', 'title': 'Luyện tập 3', 'icon': Icons.import_contacts, 'status': 0, 'section': 'basic9'},
      {'id': 72, 'key': 'cb9_luyennoi', 'title': 'Luyện nói', 'icon': Icons.mic, 'status': 0, 'section': 'basic9'},
      {'id': 73, 'key': 'cb9_luyenviet', 'title': 'Luyện viết', 'icon': Icons.edit, 'status': 0, 'section': 'basic9'},
      {'id': 74, 'key': 'cb9_ontap', 'title': 'Ôn tập', 'icon': Icons.star, 'status': 0, 'isBoss': true, 'section': 'basic9'},
      {'id': 75, 'key': 'cb10_lythuyet', 'title': 'Lý thuyết', 'icon': Icons.menu_book, 'status': 0, 'section': 'basic10'},
      {'id': 76, 'key': 'cb10_luyentap1', 'title': 'Luyện tập 1', 'icon': Icons.import_contacts, 'status': 0, 'section': 'basic10'},
      {'id': 77, 'key': 'cb10_luyentap2', 'title': 'Luyện tập 2', 'icon': Icons.import_contacts, 'status': 0, 'section': 'basic10'},
      {'id': 78, 'key': 'cb10_luyentap3', 'title': 'Luyện tập 3', 'icon': Icons.import_contacts, 'status': 0, 'section': 'basic10'},
      {'id': 79, 'key': 'cb10_luyennoi', 'title': 'Luyện nói', 'icon': Icons.mic, 'status': 0, 'section': 'basic10'},
      {'id': 80, 'key': 'cb10_luyenviet', 'title': 'Luyện viết', 'icon': Icons.edit, 'status': 0, 'section': 'basic10'},
      {'id': 81, 'key': 'cb10_ontap', 'title': 'Ôn tập', 'icon': Icons.star, 'status': 0, 'isBoss': true, 'section': 'basic10'},
    ];
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
          if (i + 1 < _lessons.length && _lessons[i+1]['status'] != 2) {
            _lessons[i+1]['status'] = 1;
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar( /* ... AppBar giữ nguyên như cũ ... */
        backgroundColor: Colors.white,
        elevation: 0,
        title: GestureDetector(
          onTap: () {
            SoundManager.instance.vibrate('light');
            //_showCourseSelection(context); // Bật lại nếu bạn muốn dùng Popup chọn khóa học
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text("Sơ cấp 1 - N5", style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(width: 5),
                Icon(Icons.arrow_drop_down, color: Colors.black54),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Nền lặp lại
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.network(
                "https://i.pinimg.com/originals/e8/6e/13/e86e135165d4bb31e5927c3e566fa199.png",
                repeat: ImageRepeat.repeat,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
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
                  final chunkLessons = _lessons.where((l) => l['section'] == section['id']).toList();
                  if (chunkLessons.isEmpty) continue;

                  // Tính số bài đã học
                  int completed = chunkLessons.where((l) => l['status'] == 2).length;

                  // 1. Thêm Khung Tiêu Đề
                  columnChildren.add(
                      _buildDynamicSectionHeader(
                        title: section['title'],
                        subtitle: "${section['subtitle']} • $completed/${chunkLessons.length} bài",
                        icon: section['icon'],
                        bgColor: Color(section['bg']),
                        iconColor: Color(section['color']),
                      )
                  );
                  columnChildren.add(const SizedBox(height: 10));

                  // 2. Thêm Đường zigzag bài học (Truyền totalNodesSoFar để nét đứt nối mượt mà)
                  columnChildren.add(
                      _buildRoadMapChunk(constraints.maxWidth, chunkLessons, totalNodesSoFar)
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
    );
  }

  // Khung tiêu đề linh hoạt màu sắc cho từng Chặng
  Widget _buildDynamicSectionHeader({required String title, required String subtitle, required IconData icon, required Color bgColor, required Color iconColor}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF5A6275))),
                const SizedBox(height: 5),
                Text(subtitle, style: const TextStyle(fontSize: 14, color: Color(0xFF808B9F), fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 28),
          )
        ],
      ),
    );
  }

  Widget _buildRoadMapChunk(double screenWidth, List<Map<String, dynamic>> chunkLessons, int startZigZagIndex) {
    return Stack(
      children: [
        CustomPaint(
          size: Size(screenWidth, chunkLessons.length * 100.0),
          painter: DashedPathPainter(
              totalItems: chunkLessons.length,
              startIndex: startZigZagIndex
          ),
        ),
        Column(
          children: List.generate(chunkLessons.length, (index) {
            final lesson = chunkLessons[index];
            int globalIndex = startZigZagIndex + index;

            double alignX = 0;
            if (globalIndex % 4 == 1) alignX = -0.5;
            else if (globalIndex % 4 == 3) alignX = 0.5;

            return Container(
              height: 100,
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
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Hãy hoàn thành bài trước để mở khóa!")));
              return;
            }

            // Dùng key trực tiếp thay vì switch case dài dòng
            String lessonId = lesson['key'];

            if (lessonId.isNotEmpty) {
              SoundManager.instance.vibrate('light');
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => LessonScreen(lessonId: lessonId, lessonTitle: lesson['title'])
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
                BoxShadow(color: shadowColor, offset: const Offset(0, 6), blurRadius: 0),
                BoxShadow(color: Colors.white.withOpacity(0.2), offset: const Offset(0, -3), blurRadius: 0),
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
              color: lesson['status'] == 0 ? Colors.grey.shade400 : Colors.black54,
              fontSize: 13
          ),
        ),
      ],
    );
  }

  // --- HÀM TẠO KHUNG TIÊU ĐỀ GIỐNG HÌNH YÊU CẦU ---
  Widget _buildSectionHeader(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF4FE), // Màu nền xanh dương cực nhạt
        borderRadius: BorderRadius.circular(30), // Bo góc tròn xoe
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF5A6275),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF808B9F),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.style,
              color: Color(0xFF4A89F3),
              size: 28,
            ),
          )
        ],
      ),
    );
  }
}

class DashedPathPainter extends CustomPainter {
  final int totalItems;
  final int startIndex;

  DashedPathPainter({required this.totalItems, required this.startIndex});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.grey.shade300..strokeWidth = 8..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    double centerX = size.width / 2;
    double itemHeight = 100.0;
    Path path = Path();
    Offset start = Offset(centerX, itemHeight / 2);
    if (startIndex % 4 == 1) start = Offset(centerX - (size.width * 0.25), itemHeight / 2);
    else if (startIndex % 4 == 3) start = Offset(centerX + (size.width * 0.25), itemHeight / 2);

    path.moveTo(start.dx, start.dy);

    for (int i = 0; i < totalItems - 1; i++) {
      int globalI = startIndex + i;

      double currentX = centerX;
      if (globalI % 4 == 1) currentX = centerX - (size.width * 0.25);
      else if (globalI % 4 == 3) currentX = centerX + (size.width * 0.25);
      double currentY = (i * itemHeight) + (itemHeight / 2);

      double nextX = centerX;
      if ((globalI + 1) % 4 == 1) nextX = centerX - (size.width * 0.25);
      else if ((globalI + 1) % 4 == 3) nextX = centerX + (size.width * 0.25);
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
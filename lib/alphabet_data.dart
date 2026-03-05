import 'dart:ui';

class AlphabetData {
  static const String _sampleVideoUrl = 'https://github.com/newbiecpp/assets-store/raw/refs/heads/main/202602111348.mp4';

  static final List<Map<String, dynamic>> levels = [
    // ========================================================
    // TẦNG 1: NGUYÊN ÂM (A - I - U - E - O)
    // ========================================================
    {
      'id': 'h_a',
      'title': 'Tầng 1: Nguyên âm (A)',
      'isBoss': false,
      'isLocked': false, // Mở sẵn
      'chars': [
        // --- CHỮ A (あ) ---
        {
          'romaji': 'a',
          'kana': 'あ',
          'gifPath': 'assets/gifs/a.gif',
          'videoUrl': _sampleVideoUrl,
          'quizOptions': ['ぬ', 'あ', 'め', 'お'],
          'strokes': [
            [const Offset(80, 110), const Offset(240, 110)], // Ngang
            [const Offset(160, 60), const Offset(160, 240)], // Dọc cong
            [ // Vòng xoắn
              const Offset(150, 140), const Offset(100, 180), const Offset(80, 210),
              const Offset(130, 285), const Offset(220, 250), const Offset(245, 180),
              const Offset(210, 155)
            ]
          ]
        },
        // --- CHỮ I (い) ---
        {
          'romaji': 'i',
          'kana': 'い',
          'gifPath': 'assets/gifs/i.gif',
          'videoUrl': _sampleVideoUrl,
          'quizOptions': ['い', 'こ', 'り', 'は'],
          'strokes': [
            [
              const Offset(100, 80), const Offset(100, 150),
              const Offset(95, 200), const Offset(120, 190)
            ],
            [
              const Offset(200, 100), const Offset(200, 160)
            ]
          ]
        },
        // --- CHỮ U (う) ---
        {
          'romaji': 'u',
          'kana': 'う',
          'gifPath': 'assets/gifs/u.gif',
          'videoUrl': _sampleVideoUrl,
          'quizOptions': ['う', 'つ', 'て', 'ら'],
          'strokes': [
            // Nét 1: Dấu phẩy trên đầu
            [const Offset(150, 60), const Offset(180, 70)],
            // Nét 2: Lưng cong (giống cái tai)
            [
              const Offset(120, 120), const Offset(200, 120),
              const Offset(150, 200), const Offset(120, 250)
            ]
          ]
        },
        // --- CHỮ E (え) ---
        {
          'romaji': 'e',
          'kana': 'え',
          'gifPath': 'assets/gifs/e.gif',
          'videoUrl': _sampleVideoUrl,
          'quizOptions': ['え', 'ん', 'ぬ', 'ね'],
          'strokes': [
            // Nét 1: Dấu phẩy trên đầu
            [const Offset(150, 50), const Offset(180, 60)],
            // Nét 2: Zíc zắc
            [
              const Offset(100, 120), const Offset(220, 120),
              const Offset(120, 200),
              const Offset(180, 200),
              const Offset(220, 250),
            ]
          ]
        },
        // --- CHỮ O (お) ---
        {
          'romaji': 'o',
          'kana': 'お',
          'gifPath': 'assets/gifs/o.gif',
          'videoUrl': _sampleVideoUrl,
          'quizOptions': ['お', 'あ', 'む', 'す'],
          'strokes': [
            // Nét 1: Ngang
            [const Offset(100, 100), const Offset(220, 100)],
            // Nét 2: Dọc kết hợp vòng xoắn (Rất khó)
            [
              const Offset(160, 60), const Offset(160, 180), // Thẳng xuống
              const Offset(120, 220), const Offset(160, 240), // Vòng tròn nhỏ
              const Offset(200, 200), const Offset(220, 240)  // Đuôi cong ra
            ],
            // Nét 3: Dấu phẩy bên phải
            [const Offset(230, 80), const Offset(250, 100)]
          ]
        },
      ],
    },

    // ========================================================
    // TẦNG 2: HÀNG KA (KA - KI - KU - KE - KO)
    // ========================================================
    {
      'id': 'h_ka',
      'title': 'Tầng 2: Hàng Ka',
      'isBoss': false,
      'isLocked': true, // Khóa, cần hoàn thành tầng 1
      'chars': [
        // --- CHỮ KA (か) ---
        {
          'romaji': 'ka',
          'kana': 'か',
          'gifPath': 'assets/gifs/ka.gif',
          'videoUrl': _sampleVideoUrl,
          'quizOptions': ['か', 'が', 'や', 'わ'],
          'strokes': [
            // Nét 1: Ngang rồi móc xuống
            [
              const Offset(80, 100), const Offset(200, 100),
              const Offset(180, 200), const Offset(160, 190) // Móc
            ],
            // Nét 2: Dọc xiên
            [const Offset(140, 80), const Offset(120, 220)],
            // Nét 3: Phẩy phải
            [const Offset(220, 100), const Offset(240, 130)]
          ]
        },
        // --- CHỮ KI (き) ---
        {
          'romaji': 'ki',
          'kana': 'き',
          'gifPath': 'assets/gifs/ke.gif',
          'videoUrl': _sampleVideoUrl,
          'quizOptions': ['き', 'さ', 'ち', 'ら'],
          'strokes': [
            // Nét 1: Ngang trên
            [const Offset(100, 100), const Offset(220, 90)],
            // Nét 2: Ngang dưới
            [const Offset(100, 140), const Offset(220, 130)],
            // Nét 3: Xiên chéo và vòng bụng
            [
              const Offset(160, 60), const Offset(180, 180),
              const Offset(140, 240), const Offset(200, 240)
            ]
          ]
        },
        // --- CHỮ KU (く) ---
        {
          'romaji': 'ku',
          'kana': 'く',
          'gifPath': 'assets/gifs/ku.gif',
          'videoUrl': _sampleVideoUrl,
          'quizOptions': ['く', 'へ', 'し', 'つ'],
          'strokes': [
            // 1 Nét duy nhất: Hình dấu nhỏ hơn <
            [
              const Offset(200, 80),
              const Offset(100, 150), // Đỉnh nhọn
              const Offset(200, 240)
            ]
          ]
        },
        // --- CHỮ KE (け) ---
        {
          'romaji': 'ke',
          'kana': 'け',
          'gifPath': 'assets/gifs/ke.gif',
          'videoUrl': _sampleVideoUrl,
          'quizOptions': ['け', 'は', 'ほ', 'に'],
          'strokes': [
            // Nét 1: Dọc cong trái, móc lên
            [
              const Offset(100, 80), const Offset(100, 200),
              const Offset(120, 190)
            ],
            // Nét 2: Ngang ngắn bên phải
            [const Offset(150, 120), const Offset(230, 120)],
            // Nét 3: Dọc cong phải
            [const Offset(190, 80), const Offset(190, 220)]
          ]
        },
        // --- CHỮ KO (こ) ---
        {
          'romaji': 'ko',
          'kana': 'こ',
          'gifPath': 'assets/gifs/ko.gif',
          'videoUrl': _sampleVideoUrl,
          'quizOptions': ['こ', 'に', 'た', 'い'],
          'strokes': [
            // Nét 1: Ngang trên, móc nhẹ đuôi
            [const Offset(100, 80), const Offset(220, 80), const Offset(220, 100)],
            // Nét 2: Ngang dưới
            [const Offset(100, 200), const Offset(220, 200)]
          ]
        },
      ],
    },
    // ========================================================
    // TẦNG 3: HÀNG SA (Sơ khai - Bạn tự thêm tiếp)
    // ========================================================
    {
      'id': 'h_sa',
      'title': 'Tầng 3: Hàng Sa',
      'isBoss': false,
      'isLocked': true,
      'chars': [
        {'romaji': 'sa', 'kana': 'さ', 'quizOptions': ['さ','き','ち'], 'strokes': []}, // Chưa có nét
        {'romaji': 'shi', 'kana': 'し', 'quizOptions': ['し','つ','ん'], 'strokes': []},
        {'romaji': 'su', 'kana': 'す', 'quizOptions': ['す','む','あ'], 'strokes': []},
        {'romaji': 'se', 'kana': 'せ', 'quizOptions': ['せ','サ','ヒ'], 'strokes': []},
        {'romaji': 'so', 'kana': 'そ', 'quizOptions': ['そ','ろ','る'], 'strokes': []},
      ],
    },
    {
      'id': 'boss_1',
      'title': 'CỔNG QUỶ MÔN (BOSS)',
      'isBoss': true,
      'isLocked': true,
      'chars': [],
    }
  ];
}
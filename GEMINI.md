# Kanji Summoner

## 📖 Giới thiệu

**Kanji Summoner** là một ứng dụng di động hỗ trợ học tiếng Nhật (từ bảng chữ cái đến trình độ sơ cấp N5) được thiết kế theo phong cách Gamification (Game hóa), giúp người dùng duy trì động lực học tập mỗi ngày.

## ✨ Tính năng nổi bật

- **Lộ trình học tập (Roadmap):** Cung cấp các chặng học được chia theo chủ đề rõ ràng (Chào hỏi, Mua sắm, Di chuyển, Tính từ, v.v.) giống phong cách của Duolingo.
- **Bảng chữ cái tương tác:** Hỗ trợ xem cách viết qua GIF/Video và tập viết chữ cái Hiragana/Katakana.
- **Nhận diện chữ viết tay (ML Kit):** Tích hợp công nghệ AI `Google ML Kit Digital Ink` để phân tích và chấm điểm nét chữ mà người dùng vẽ trực tiếp lên màn hình.
- **Luyện phát âm & Giao tiếp (Whisper API):** Tích hợp bộ nhận diện giọng nói `OpenAI Whisper` kết hợp thuật toán tính độ tương đồng chuỗi (Levenshtein Distance) để đánh giá câu hội thoại tiếng Nhật của người dùng.
- **Đa dạng bài tập:** Trắc nghiệm hình ảnh, Nghe hiểu (Text-to-Speech), Thẻ ghi nhớ (Flashcards), Ghép câu (Sentence Builder) và Điền từ.
- **Hệ thống phần thưởng & Danh hiệu:** Tích lũy EXP (Điểm kinh nghiệm) để thăng cấp (Tân binh -> Đại tướng) và mở khóa hàng loạt danh hiệu thú vị.
- **Chế độ theo dõi tiến độ:** Lưu trữ trạng thái hoàn thành bài học và thiết lập nhắc nhở giờ học.

## 🛠 Công nghệ sử dụng

- **Framework:** Flutter / Dart
- **Backend/Database:** Firebase (Auth, Analytics)
- **AI & Machine Learning:** Google ML Kit (Digital Ink Recognition), OpenAI Whisper API
- **Text-To-Speech:** Công cụ đọc tiếng Nhật tự động.

## 📂 Cấu trúc chính nổi bật

- `lesson_screen.dart`: Trái tim của ứng dụng, quản lý mọi giao diện module bài tập tương tác (Nghe, Nói, Đọc, Viết).
- `recognition_manager.dart`: Lớp kết nối trực tiếp với bộ não AI để nhận diện chữ viết tay.
- `main.dart`: Xử lý điều hướng (Navigation) và khởi tạo bản đồ bài học (Roadmap).

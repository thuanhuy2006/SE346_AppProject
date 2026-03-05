import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'user_progress.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // --- GIAO DIỆN CHÍNH ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Nền xám nhạt
      appBar: AppBar(
        backgroundColor: const Color(0xFF78C850), // Xanh lá header
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Cài đặt", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. PHIÊN BẢN ỨNG DỤNG
            _buildSectionContainer(
              children: [
                _buildInfoRow("Phiên bản ứng dụng", "3.4.3"),
                const Divider(height: 1, color: Colors.grey),
                _buildInfoRow("Phiên bản dữ liệu", "v.2046"),
              ],
            ),

            const SizedBox(height: 20),

            // 2. CÀI ĐẶT TÍNH NĂNG
            const Padding(
              padding: EdgeInsets.only(left: 10, bottom: 10),
              child: Text("Cài đặt tính năng", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            _buildSectionContainer(
              children: [
                _buildActionRow(
                  "Nhắc nhở học tập",
                  onTap: () => _showReminderDialog(context),
                ),
                const Divider(height: 1, color: Colors.grey),
                _buildActionRow(
                  "Làm mới tiến độ học",
                  onTap: () => _showResetConfirmDialog(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- CÁC WIDGET CON (Helper) ---

  Widget _buildSectionContainer({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF78C850))),
        ],
      ),
    );
  }

  Widget _buildActionRow(String title, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF78C850))), // Chữ xanh
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // --- POPUP NHẮC NHỞ HỌC TẬP (GIỐNG HÌNH 2) ---
  void _showReminderDialog(BuildContext context) {
    bool isReminderOn = false; // Trạng thái Switch
    DateTime selectedTime = DateTime(2024, 1, 1, 7, 22); // Mặc định 07:22

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF78C850), // Màu nền xanh lá
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tiêu đề
                    const Text(
                      "Nhắc nhở học tập",
                      style: TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // Giờ to + Switch
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}",
                          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        Switch(
                          value: isReminderOn,
                          onChanged: (val) {
                            setState(() => isReminderOn = val);
                          },
                          activeColor: Colors.white,
                          activeTrackColor: Colors.amber,
                        )
                      ],
                    ),

                    const Divider(color: Colors.white54),

                    // Bộ chọn giờ (Style cupertino giống hình)
                    SizedBox(
                      height: 120,
                      child: CupertinoTheme(
                        data: const CupertinoThemeData(
                          textTheme: CupertinoTextThemeData(dateTimePickerTextStyle: TextStyle(color: Colors.white, fontSize: 18)),
                        ),
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.time,
                          initialDateTime: selectedTime,
                          use24hFormat: true,
                          onDateTimeChanged: (val) {
                            setState(() => selectedTime = val);
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Nút Lưu
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        ),
                        child: const Text("Lưu", style: TextStyle(color: Color(0xFF78C850), fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Text cảnh báo đỏ
                    const Text(
                      "Vui lòng bật thông báo Nhắc nhở học tập trong mục Quản lý thông báo",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.redAccent, fontSize: 12),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- POPUP XÁC NHẬN LÀM MỚI ---
  void _showResetConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận"),
        content: const Text("Bạn có chắc chắn muốn xóa toàn bộ tiến độ học tập? Hành động này không thể hoàn tác."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              await UserProgress().resetProgress(); // Gọi hàm xóa
              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã làm mới tiến độ!")));
              }
            },
            child: const Text("Đồng ý", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
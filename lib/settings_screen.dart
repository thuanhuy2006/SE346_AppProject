import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_progress.dart';
import 'admin_panel_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        backgroundColor: const Color(0xFF3366FF), // Xanh dương header
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
                _buildInfoRow("Phiên bản ứng dụng", "1.0.0"),
                const Divider(height: 1, color: Colors.grey),
                _buildInfoRow("Phiên bản dữ liệu", "v.1"),
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
                  "Đổi tên hiển thị",
                  onTap: () => _showChangeNameDialog(context),
                ),
                const Divider(height: 1, color: Colors.grey),
                _buildActionRow(
                  "Làm mới tiến độ học",
                  onTap: () => _showResetConfirmDialog(context),
                ),
                const Divider(height: 1, color: Colors.grey),
                _buildActionRow(
                  "Hệ thống quản trị (Admin)",
                  onTap: () => _handleAdminAccess(context),
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
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3366FF))),
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
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF3366FF))), // Chữ xanh
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
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

  // --- POPUP ĐỔI TÊN HIỂN THỊ ---
  void _showChangeNameDialog(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng đăng nhập để đổi tên hiển thị!")),
      );
      return;
    }

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
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Đã cập nhật tên hiển thị!"),
                        ),
                      );
                    }
                    if (mounted) {
                      setState(() {});
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
                backgroundColor: const Color(0xFF3366FF),
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

  void _handleAdminAccess(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data()?['role'] == 'admin') {
          _navigateToAdminPanel();
          return;
        }
      } catch (e) {
        print("Lỗi kiểm tra quyền Admin: $e");
      }
    }
    _showAdminPasscodeDialog();
  }

  void _navigateToAdminPanel() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminPanelScreen(),
      ),
    );
  }

  void _showAdminPasscodeDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Xác thực quản trị viên", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Vui lòng nhập mật mã quản trị viên hoặc sử dụng tài khoản Admin để truy cập:"),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Mật mã (Passcode)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim() == "1357") {
                Navigator.pop(ctx);
                _navigateToAdminPanel();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Mật mã không đúng!"), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3366FF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text("Xác minh", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
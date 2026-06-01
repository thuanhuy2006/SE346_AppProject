import 'package:flutter/material.dart';
import 'admin_panel_screen.dart'; // File gốc chứa Form Thêm/Sửa của bạn

class AdminWebDashboard extends StatefulWidget {
  const AdminWebDashboard({super.key});

  @override
  State<AdminWebDashboard> createState() => _AdminWebDashboardState();
}

class _AdminWebDashboardState extends State<AdminWebDashboard> {
  int _currentTab = 0; // Để đồng bộ với 3 Tab trong admin_panel_screen của bạn

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Màu nền sáng kiểu Web Admin
      body: Row(
        children: [
          // 1. SIDEBAR cố định bên trái (Bản rộng 260px)
          Container(
            width: 260,
            color: const Color(0xFF1E1E2D), // Màu tối tối thanh lịch
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    "CMS HỌC TIẾNG NHẬT",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                ),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 16),
                _buildSidebarItem(0, Icons.menu_book, "Từ vựng & Ngữ pháp JLPT"),
                _buildSidebarItem(1, Icons.headphones, "Quản lý Luyện Nghe"),
                _buildSidebarItem(2, Icons.chrome_reader_mode, "Quản lý Luyện Đọc"),
              ],
            ),
          ),

          // 2. PHẦN HIỂN THỊ NỘI DUNG CHÍNH BÊN PHẢI
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thanh Header trên cùng
                Container(
                  height: 70,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _currentTab == 0 ? "Thêm bài học JLPT N5" : (_currentTab == 1 ? "Quản lý Bài Nghe" : "Quản lý Bài Đọc"),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),

                // Vùng chứa Form chính
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Card(
                      elevation: 2,
                      shadowColor: Colors.black12,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: AdminPanelScreen(
                          externalSelectedTab: _currentTab,
                          showAppBar: false,
                        ),
                      ),
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

  Widget _buildSidebarItem(int index, IconData icon, String title) {
    bool isSelected = _currentTab == index;
    return ListTile(
      selected: isSelected,
      selectedTileColor: Colors.blue.withOpacity(0.1),
      leading: Icon(icon, color: isSelected ? Colors.blue : Colors.white70),
      title: Text(title, style: TextStyle(color: isSelected ? Colors.blue : Colors.white70, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      onTap: () {
        setState(() {
          _currentTab = index;
        });
      },
    );
  }
}
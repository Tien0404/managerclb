import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../routes.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<Map<String, dynamic>?>(
            future: _getUserData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingHeader();
              }

              final user = snapshot.data;
              return user != null
                  ? _buildUserHeader(context, user)
                  : _buildAuthOptions(context);
            },
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  title: "Sự kiện",
                  icon: Icons.event,
                  showTrailing: false,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.eventList);
                  },
                ),
                _buildMenuItem(
                  title: "Bài viết",
                  icon: Icons.article,
                  showTrailing: false,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.blog);
                  },
                ),
                Divider(
                  color: Colors.grey,
                  height: 40,
                  thickness: 0.5,
                  indent: 16,
                  endIndent: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Hiển thị thông tin người dùng khi đã đăng nhập
  Widget _buildUserHeader(BuildContext context, Map<String, dynamic> user) {
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(
        color: Colors.blue,
      ),
      accountName: Text(
        user['name'] ?? 'Người dùng',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      accountEmail: Text(
        user['email'] ?? '',
        style: TextStyle(fontSize: 14),
      ),
      currentAccountPicture: CircleAvatar(
        backgroundImage: user['avatar'] != null
            ? NetworkImage(user['avatar'])
            : AssetImage('assets/default_avatar.png') as ImageProvider,
      ),
      otherAccountsPictures: [
        IconButton(
          icon: Icon(Icons.logout, color: Colors.white),
          onPressed: () => _logout(context),
        ),
      ],
    );
  }

  // Hiển thị khi chưa đăng nhập
  Widget _buildAuthOptions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Icon(Icons.app_registration, size: 20),
            title: Text(
              "Đăng ký",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegisterScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.login, size: 20),
            title: Text(
              "Đăng nhập",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  // Widget hiển thị trạng thái loading
  Widget _buildLoadingHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  // Kiểm tra người dùng đã đăng nhập chưa
  Future<bool> _isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('user');
  }

  // Lấy thông tin người dùng từ SharedPreferences
  Future<Map<String, dynamic>?> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user');
    if (userDataString == null) return null;
    return Map<String, dynamic>.from(jsonDecode(userDataString));
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.remove('access_token');

    // Điều hướng về màn hình chính và làm mới giao diện
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.home, // Đổi thành route của HomeScreen
      (Route<dynamic> route) => false, // Xóa toàn bộ stack
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Đăng xuất thành công")),
    );
  }

  // Widget tạo các mục menu
  Widget _buildMenuItem({
    required String title,
    required IconData icon,
    bool showTrailing = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      trailing: Icon(
        icon,
        size: 24,
        color: Colors.black,
      ),
      onTap: onTap,
    );
  }
}

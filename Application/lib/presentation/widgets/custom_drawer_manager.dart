import 'package:flutter/material.dart';
import '../../../routes.dart';

class CustomDrawerManager extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phần nội dung chính
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                SizedBox(height: 20), // Khoảng cách trên cùng
                _buildMenuItem(
                  title: "dashboard",
                  icon: Icons.arrow_drop_down,
                  showTrailing: true,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      AppRoutes.homeManager,
                    );
                  },
                ),
                _buildMenuItem(
                  title: "thông tin clb",
                  icon: Icons.arrow_outward,
                  showTrailing: true,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      AppRoutes.information,
                    );
                  },
                ),
                _buildMenuItem(
                  title: "Quản lý Trang đại diện",
                  icon: Icons.arrow_outward,
                  showTrailing: false,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      AppRoutes.clubManager,
                    );
                  },
                ),
                _buildMenuItem(
                  title: "Quản lý Thành viên",
                  icon: Icons.arrow_outward,
                  showTrailing: false,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      AppRoutes.memberManager,
                    );
                  },
                ),
                _buildMenuItem(
                  title: "Quản lý sự kiện",
                  icon: Icons.arrow_outward,
                  showTrailing: false,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      AppRoutes.eventManager,
                    );
                  },
                ),
                _buildMenuItem(
                  title: "Quản lý blog",
                  icon: Icons.arrow_outward,
                  showTrailing: false,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      AppRoutes.blogManager,
                    );
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

  // Widget tạo các mục menu
  Widget _buildMenuItem({
    required String title,
    required IconData icon,
    bool showTrailing = false,
    VoidCallback? onTap, // Thêm tham số onTap
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
      onTap: onTap, // Sử dụng onTap
    );
  }
}

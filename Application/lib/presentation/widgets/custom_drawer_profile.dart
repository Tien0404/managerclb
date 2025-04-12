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
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                SizedBox(height: 20),
                _buildMenuItem(
                  title: "Lịch sử tham gia sự kiện",
                  icon: Icons.arrow_outward,
                  showTrailing: true,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      AppRoutes.historyEvent,
                    );
                  },
                ),
                SizedBox(height: 20),
                _buildMenuItem(
                  title: "Câu lạc bộ đã tham gia",
                  icon: Icons.arrow_outward,
                  showTrailing: true,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      AppRoutes.joinClb,
                    );
                  },
                ),
                SizedBox(height: 20),
                _buildMenuItem(
                  title: "Yêu cầu đã gửi đi",
                  icon: Icons.arrow_outward,
                  showTrailing: true,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      AppRoutes.joinRequest,
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

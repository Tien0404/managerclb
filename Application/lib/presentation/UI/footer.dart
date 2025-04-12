import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes.dart';

Widget buildFooter(BuildContext context) {
  return FutureBuilder<String?>(
    future: _getToken(),
    builder: (context, snapshot) {
      bool isLoggedIn = snapshot.hasData && snapshot.data != null;

      return Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildAnimatedFooterButton(context, Icons.home, 'Home', () {
              Navigator.pushNamed(context, AppRoutes.home);
            }),
            _buildAnimatedFooterButton(context, Icons.search, 'Search', () {
              Navigator.pushNamed(context, AppRoutes.clubSearch);
            }),
            _buildAnimatedFooterButton(context, Icons.event, 'Event', () {
              Navigator.pushNamed(context, AppRoutes.eventList);
            }),
            _buildAnimatedFooterButton(context, Icons.article, 'Blog', () {
              Navigator.pushNamed(context, AppRoutes.blog);
            }),
            _buildAnimatedFooterButton(
              context,
              isLoggedIn ? Icons.person : Icons.login, // Thay đổi icon
              isLoggedIn ? 'Profile' : 'Login', // Thay đổi label
              () {
                Navigator.pushNamed(
                  context,
                  isLoggedIn ? AppRoutes.profile : AppRoutes.login,
                );
              },
            ),
          ],
        ),
      );
    },
  );
}

// Hàm lấy token từ SharedPreferences
Future<String?> _getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('access_token');
}

Widget _buildAnimatedFooterButton(
    BuildContext context, IconData icon, String label, VoidCallback onPressed) {
  return GestureDetector(
    onTap: () {
      onPressed();
      HapticFeedback.lightImpact();
    },
    child: Container(
      width: 70,
      height: 70,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return RadialGradient(
                center: Alignment.topLeft,
                radius: 1.0,
                colors: [Colors.white, Colors.white70],
                tileMode: TileMode.mirror,
              ).createShader(bounds);
            },
            child: Icon(
              icon,
              color: Colors.white,
              size: 25,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  blurRadius: 2.0,
                  color: Colors.black.withOpacity(0.3),
                  offset: Offset(1.0, 1.0),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

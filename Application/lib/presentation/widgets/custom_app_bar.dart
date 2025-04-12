import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import 'badge_icon.dart';

import '../../../routes.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.15),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1.0),
        weight: 50.0,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateAnimation(int unreadCount) {
    if (unreadCount > 0 && !_animationController.isAnimating) {
      _animationController.repeat();
    } else if (unreadCount == 0 && _animationController.isAnimating) {
      _animationController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    _updateAnimation(notificationProvider.unreadCount);

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
      actions: [
        // Notification icon with badge
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.notification);
              print('Notifications tapped');
            },
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: notificationProvider.unreadCount > 0
                      ? _scaleAnimation.value
                      : 1.0,
                  child: BadgeIcon(
                    icon: Icons.notifications_outlined,
                    count: notificationProvider.unreadCount,
                    badgeColor: Colors.red.shade600,
                    size: 28.0,
                  ),
                );
              },
            ),
          ),
        ),
        // Menu icon
        Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            );
          },
        ),
        SizedBox(width: 4.0),
      ],
    );
  }
}

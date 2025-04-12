import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import 'badge_icon.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _shakeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Hiệu ứng rung cho icon
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -3),
        weight: 25.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -3, end: 3),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 3, end: 0),
        weight: 25.0,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Hiệu ứng phóng to cho icon
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
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

  void _updateAnimation(int unreadCount, int currentIndex) {
    // Nếu đang ở tab thông báo hoặc không có thông báo, dừng animation
    if (currentIndex == 3 || unreadCount == 0) {
      _animationController.stop();
    } else if (unreadCount > 0 && !_animationController.isAnimating) {
      // Nếu có thông báo mới và animation chưa chạy, bắt đầu animation
      _animationController.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    // Cập nhật trạng thái animation
    _updateAnimation(notificationProvider.unreadCount, widget.currentIndex);

    return BottomNavigationBar(
      currentIndex: widget.currentIndex,
      onTap: widget.onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Trang chủ',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.event),
          label: 'Sự kiện',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.article),
          label: 'Bài viết',
        ),
        BottomNavigationBarItem(
          icon: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              // Chỉ áp dụng hiệu ứng khi có thông báo chưa đọc và không ở tab thông báo
              if (notificationProvider.unreadCount > 0 &&
                  widget.currentIndex != 3) {
                return Transform.translate(
                  offset: Offset(_shakeAnimation.value, 0),
                  child: Transform.scale(
                    scale: _pulseAnimation.value,
                    child: child,
                  ),
                );
              }
              return child!;
            },
            child: BadgeIcon(
              icon: Icons.notifications,
              count: notificationProvider.unreadCount,
              badgeColor: Colors.red.shade600,
              size: 26.0,
            ),
          ),
          label: 'Thông báo',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Tài khoản',
        ),
      ],
    );
  }
}

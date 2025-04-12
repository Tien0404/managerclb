import 'package:flutter/material.dart';

class BadgeIcon extends StatefulWidget {
  final IconData icon;
  final int count;
  final Color badgeColor;
  final double size;
  final double fontSize;

  const BadgeIcon({
    Key? key,
    required this.icon,
    required this.count,
    this.badgeColor = Colors.red,
    this.size = 24.0,
    this.fontSize = 12.0,
  }) : super(key: key);

  @override
  State<BadgeIcon> createState() => _BadgeIconState();
}

class _BadgeIconState extends State<BadgeIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  int _previousCount = 0;

  @override
  void initState() {
    super.initState();
    _previousCount = widget.count;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.5),
        weight: 40.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.5, end: 1.0),
        weight: 60.0,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _colorAnimation = ColorTween(
      begin: widget.badgeColor,
      end: Colors.white,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    // Nếu có thông báo khi khởi tạo, chạy animation
    if (widget.count > 0) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(BadgeIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Nếu số lượng thông báo tăng lên, chạy animation
    if (widget.count > _previousCount) {
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    } else if (widget.count == 0 && _controller.isAnimating) {
      _controller.stop();
    }
    _previousCount = widget.count;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          widget.icon,
          size: widget.size,
        ),
        if (widget.count > 0)
          Positioned(
            right: -widget.size * 0.3,
            top: -widget.size * 0.1,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: _colorAnimation.value,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    constraints: BoxConstraints(
                      minWidth: widget.size * 0.65,
                      minHeight: widget.size * 0.65,
                    ),
                    child: Center(
                      child: Text(
                        widget.count > 99 ? '99+' : widget.count.toString(),
                        style: TextStyle(
                          color: _colorAnimation.value == Colors.white
                              ? widget.badgeColor
                              : Colors.white,
                          fontSize: widget.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

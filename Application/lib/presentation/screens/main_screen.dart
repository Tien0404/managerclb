import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../services/local_notification_service.dart';
import '../widgets/custom_app_bar.dart';
import 'Notification/Notification.dart';
import 'home_screen.dart';
import 'event/event_explorer_screen.dart';
import 'blog/blog_explorer.dart';
import 'profile/profile.dart';
import '../../routes.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    EventExplorerScreen(),
    BlogExplorer(),
    const NotificationScreen(),
    ProfileScreen(),
  ];

  final List<String> _screenTitles = [
    'Trang chủ',
    'Sự kiện',
    'Bài viết',
    'Thông báo',
    'Tài khoản',
  ];

  @override
  void initState() {
    super.initState();
    // Refresh notifications when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false)
          .fetchNotifications();
    });

    // Lắng nghe khi người dùng nhấp vào thông báo
    listenToNotifications();
  }

  void listenToNotifications() {
    LocalNotificationService.onNotifications.listen((payload) {
      if (payload != null && payload.isNotEmpty) {
        handleNotificationTap(payload);
      }
    });
  }

  void handleNotificationTap(String payload) {
    // Xử lý các loại payload khác nhau
    if (payload.startsWith('event:')) {
      // Xử lý sự kiện
      final eventId = int.tryParse(payload.split(':')[1]);
      if (eventId != null) {
        setState(() {
          _currentIndex = 1; // Chuyển đến tab Sự kiện
        });

        // TODO: Điều hướng đến chi tiết sự kiện
        // Navigator.pushNamed(context, AppRoutes.eventDetail, arguments: eventId);
      }
    } else if (payload.startsWith('blog:')) {
      // Xử lý bài viết
      final blogId = int.tryParse(payload.split(':')[1]);
      if (blogId != null) {
        setState(() {
          _currentIndex = 2; // Chuyển đến tab Bài viết
        });

        // TODO: Điều hướng đến chi tiết bài viết
        // Navigator.pushNamed(context, AppRoutes.blogDetail, arguments: blogId);
      }
    } else if (payload.startsWith('notification:')) {
      // Xử lý thông báo thông thường - mở màn hình thông báo
      setState(() {
        _currentIndex = 3; // Chuyển đến tab Thông báo
      });
    }
  }

  void _changeScreen(int index) {
    setState(() {
      _currentIndex = index;

      // Nếu người dùng chuyển đến tab thông báo, cập nhật lại dữ liệu
      if (index == 3) {
        Provider.of<NotificationProvider>(context, listen: false)
            .fetchNotifications();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 60,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Club Management',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Trang chủ'),
              selected: _currentIndex == 0,
              onTap: () {
                _changeScreen(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Sự kiện'),
              selected: _currentIndex == 1,
              onTap: () {
                _changeScreen(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.article),
              title: const Text('Bài viết'),
              selected: _currentIndex == 2,
              onTap: () {
                _changeScreen(2);
                Navigator.pop(context);
              },
            ),
            Consumer<NotificationProvider>(
              builder: (context, provider, child) {
                return ListTile(
                  leading: const Icon(Icons.notifications),
                  title: Row(
                    children: [
                      const Text('Thông báo'),
                      if (provider.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            provider.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  selected: _currentIndex == 3,
                  onTap: () {
                    _changeScreen(3);
                    Navigator.pop(context);
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Tài khoản'),
              selected: _currentIndex == 4,
              onTap: () {
                _changeScreen(4);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _screens[_currentIndex],
    );
  }
}

import 'package:flutter/material.dart';
import '../../data/repositories/club_repository.dart';
import '../UI/club_card.dart';
import '../UI/footer.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_drawer.dart';
import 'package:provider/provider.dart';

import 'dart:developer' as developer;
import '../../providers/notification_provider.dart';
import '../../services/local_notification_service.dart';
import '../../routes.dart';

import 'club/club_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ClubRepository _clubRepository = ClubRepository();
  bool _isLoading = false;
  String? _error;

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
    // Xử lý trực tiếp thông báo trong HomeScreen
    try {
      final parts = payload.split(':');
      if (parts.length == 2) {
        final type = parts[0];
        final id = int.tryParse(parts[1]);

        if (id != null) {
          switch (type) {
            case 'event':
            case 'new_event':
              Navigator.pushNamed(context, AppRoutes.eventDetail,
                  arguments: id.toString());
              break;
            case 'blog':
            case 'new_blog':
              Navigator.pushNamed(context, AppRoutes.blog,
                  arguments: id.toString());
              break;
            case 'club':
              Navigator.pushNamed(context, AppRoutes.clubDetail,
                  arguments: id.toString());
              break;
            case 'notification':
              Navigator.pushNamed(context, AppRoutes.notification);
              break;
          }
        }
      }
    } catch (e) {
      developer.log('Error handling notification tap: $e', name: 'HomeScreen');
    }
  }

  // Phương thức hiển thị thông báo test
  void _showTestNotification(BuildContext context) {
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    notificationProvider.showLocalNotification(
      'Thông báo thử nghiệm',
      'Đây là thông báo thử nghiệm từ CLB Management. Nhấn để xem chi tiết!',
      'notification',
      999,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã gửi thông báo thử nghiệm!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(),
      endDrawer: CustomDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _isLoading = true;
            _error = null;
          });
          try {
            await _clubRepository.getClubs(forceRefresh: true);
          } catch (e) {
            setState(() {
              _error = e.toString();
            });
          } finally {
            setState(() {
              _isLoading = false;
            });
          }
        },
        child: _buildBody(context),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showTestNotification(context);
        },
        child: Icon(Icons.notifications),
      ),
      bottomNavigationBar: buildFooter(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _clubRepository.getClubs(forceRefresh: true),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          developer.log('Error loading clubs: ${snapshot.error}',
              name: 'HomeScreen');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
                  },
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'Chưa có câu lạc bộ nào',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final club = snapshot.data![index];
            developer.log('Club data at index $index: $club',
                name: 'HomeScreen');
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: buildClubCard(
                context,
                club,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClubDetailScreen(
                        clubId: club['id'].toString(),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

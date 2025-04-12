import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/notification_model.dart';
import '../../../providers/notification_provider.dart';
import '../../../services/local_notification_service.dart';
import '../../../services/AuthService.dart';
import 'notification_card.dart';
import 'notification_detail_screen.dart';
import 'notification_filter.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _currentFilter = 'all';
  bool _isTokenChecked = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Refresh notifications when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTokenAndFetchNotifications();
    });
  }

  // Kiểm tra token và tải thông báo
  Future<void> _checkTokenAndFetchNotifications() async {
    if (_isTokenChecked) return;

    final provider = Provider.of<NotificationProvider>(context, listen: false);

    // Kiểm tra xem provider có token không
    if (provider.hasToken) {
      debugPrint(
          'NotificationScreen: Provider already has token, fetching notifications');
      provider.fetchNotifications();
    } else {
      // Nếu provider không có token, thử lấy từ local storage
      debugPrint(
          'NotificationScreen: Provider has no token, trying to restore');
      final token = await AuthService.getToken();

      if (token != null && token.isNotEmpty) {
        debugPrint(
            'NotificationScreen: Found token in storage, setting to provider');
        provider.setAuthToken(token);
        // fetchNotifications sẽ được gọi tự động trong setAuthToken
      } else {
        debugPrint('NotificationScreen: No token found in storage');
        provider.fetchNotifications(); // Sẽ hiển thị thông báo lỗi
      }
    }

    _isTokenChecked = true;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Chưa đọc'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterOptions(context);
            },
            tooltip: 'Lọc thông báo',
          ),
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () {
              Provider.of<NotificationProvider>(context, listen: false)
                  .markAllAsRead();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã đánh dấu tất cả là đã đọc')),
              );
            },
            tooltip: 'Đánh dấu tất cả đã đọc',
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          if (notificationProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (notificationProvider.hasError) {
            return _buildErrorView(notificationProvider);
          }

          // Lấy danh sách thông báo dựa trên tab và bộ lọc hiện tại
          final allNotifications =
              _getFilteredNotifications(notificationProvider, _currentFilter);
          final unreadNotifications = allNotifications
              .where((notification) => !notification.isRead)
              .toList();

          if (allNotifications.isEmpty) {
            return _buildEmptyView();
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // Tab tất cả thông báo
              _buildNotificationList(
                  context, allNotifications, notificationProvider),

              // Tab chưa đọc
              unreadNotifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.mark_email_read,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Bạn đã đọc tất cả thông báo',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _buildNotificationList(
                      context, unreadNotifications, notificationProvider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _checkTokenAndFetchNotifications();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã làm mới thông báo')),
          );
        },
        child: const Icon(Icons.refresh),
        tooltip: 'Làm mới',
      ),
    );
  }

  Widget _buildErrorView(NotificationProvider notificationProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Lỗi: ${notificationProvider.errorMessage}',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              notificationProvider.fetchNotifications();
            },
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 48,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Bạn không có thông báo nào',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(
    BuildContext context,
    List<NotificationModel> notifications,
    NotificationProvider provider,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        await provider.fetchNotifications();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        itemCount: notifications.length + 1, // +1 for filter chips
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildFilterChips(context, provider);
          }

          final notification = notifications[index - 1];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: NotificationCard(
              notification: notification,
              onTap: () =>
                  _handleNotificationTap(context, notification, provider),
              onMarkAsRead: !notification.isRead
                  ? () => provider.markAsRead(notification.id.toString())
                  : null,
              onLike: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(notification.isLiked
                        ? 'Đã bỏ thích thông báo'
                        : 'Đã thích thông báo'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              onShare: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã chia sẻ thông báo'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChips(
      BuildContext context, NotificationProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _buildFilterChip(context, 'all', 'Tất cả', Icons.list),
          _buildFilterChip(context, 'event', 'Sự kiện', Icons.event),
          _buildFilterChip(context, 'blog', 'Bài viết', Icons.article),
          _buildFilterChip(context, 'club', 'CLB', Icons.people),
          _buildFilterChip(context, 'promotion', 'Ưu đãi', Icons.local_offer),
          _buildFilterChip(context, 'system', 'Hệ thống', Icons.settings),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
      BuildContext context, String filter, String label, IconData icon) {
    final isSelected = _currentFilter == filter;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        avatar: Icon(
          icon,
          size: 18,
          color: isSelected ? Colors.white : Colors.grey[700],
        ),
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _currentFilter = filter;
          });
        },
        showCheckmark: false,
      ),
    );
  }

  void _handleNotificationTap(
    BuildContext context,
    NotificationModel notification,
    NotificationProvider provider,
  ) {
    // Mark as read when tapped and wait for completion
    if (!notification.isRead) {
      provider.markAsRead(notification.id.toString()).then((_) {
        // Find the updated notification with read status
        final updatedNotification = provider.notifications.firstWhere(
          (n) => n.id == notification.id,
          orElse: () => notification, // Fallback to original if not found
        );

        // Navigate to detail screen with updated notification
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationDetailScreen(
              notification: updatedNotification, // Use updated notification
              onNavigate: (type, id) {
                // Đóng tất cả màn hình và điều hướng trực tiếp đến nội dung
                String route = _getRouteByType(type);
                debugPrint(
                    '[DEBUG] Điều hướng từ callback với route: $route, id: $id');

                Navigator.of(context, rootNavigator: true)
                    .pushNamedAndRemoveUntil(
                  route,
                  (route) => false, // Xóa tất cả màn hình khỏi stack
                  arguments: id.toString(),
                );
              },
            ),
          ),
        );
      });
    } else {
      // Navigate directly if already read
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NotificationDetailScreen(
            notification: notification,
            onNavigate: (type, id) {
              // Đóng tất cả màn hình và điều hướng trực tiếp đến nội dung
              String route = _getRouteByType(type);
              debugPrint(
                  '[DEBUG] Điều hướng từ callback với route: $route, id: $id');

              Navigator.of(context, rootNavigator: true)
                  .pushNamedAndRemoveUntil(
                route,
                (route) => false, // Xóa tất cả màn hình khỏi stack
                arguments: id.toString(),
              );
            },
          ),
        ),
      );
    }
  }

  List<NotificationModel> _getFilteredNotifications(
    NotificationProvider provider,
    String filter,
  ) {
    if (filter == 'all') {
      return provider.notifications;
    }

    return provider.notifications.where((notification) {
      String type = notification.notificationType;
      if (type == 'new_event') type = 'event';
      if (type == 'new_blog') type = 'blog';
      return type == filter;
    }).toList();
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => NotificationFilter(
        currentFilter: _currentFilter,
        onFilterChanged: (filter) {
          setState(() {
            _currentFilter = filter;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  String _getRouteByType(String type) {
    switch (type) {
      case 'event':
        return '/event/detail';
      case 'blog':
        return '/blog/detail';
      case 'club':
        return '/club/detail';
      default:
        return '/';
    }
  }
}

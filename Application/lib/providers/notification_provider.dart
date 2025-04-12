import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/NotificationService.dart';
import '../data/models/notification_model.dart';
import '../services/local_notification_service.dart';
import '../routes/app_routes.dart';
import '../services/ApiService.dart';
import 'package:flutter/foundation.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  int _unreadCount = 0;
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  Timer? _refreshTimer;
  int _notificationId = 0;
  bool _isInitialized = false;
  String? _authToken;

  // Lưu trữ ID thông báo đã xem để tránh hiển thị trùng lặp
  Set<int> _processedNotificationIds = {};

  // Categorization
  Map<String, List<NotificationModel>> _categorizedNotifications = {};
  List<String> _activeCategories = [];
  String _currentFilter = 'all';

  // Settings
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  // Getters
  int get unreadCount => _unreadCount;
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  Map<String, List<NotificationModel>> get categorizedNotifications =>
      _categorizedNotifications;
  List<String> get activeCategories => _activeCategories;
  String get currentFilter => _currentFilter;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get hasToken => _authToken != null && _authToken!.isNotEmpty;

  NotificationProvider() {
    _initialize();
  }

  // Set auth token
  void setAuthToken(String token) {
    if (token.isNotEmpty) {
      debugPrint(
          'NotificationProvider: Setting token ${token.substring(0, math.min(10, token.length))}...');
      _authToken = token;
      ApiService.setAuthToken(token);

      // Tải thông báo ngay sau khi token được đặt
      fetchNotifications(silent: true).then((_) {
        debugPrint('Notifications loaded after setting token');

        // Sau khi tải xong thông báo lần đầu, bắt đầu lịch trình kiểm tra thông báo mới
        _startNotificationPolling();
      }).catchError((error) {
        debugPrint('Error fetching notifications after setting token: $error');
      });
    } else {
      debugPrint('NotificationProvider: Empty token provided - ignoring');
    }
  }

  // Clear auth token
  void clearAuthToken() {
    _authToken = null;
    ApiService.clearAuthToken();
    _notifications.clear();
    _unreadCount = 0;
    _stopNotificationPolling();
    notifyListeners();
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;

    // Khởi tạo local notification service
    final bool initialized = await LocalNotificationService.init(
      onNotificationTap: (String? payload) {
        if (payload != null) {
          handleDeepLink(payload);
        }
      },
    );

    if (!initialized) {
      _errorMessage = 'Không thể khởi tạo dịch vụ thông báo';
      notifyListeners();
      return;
    }

    // Lắng nghe sự kiện click thông báo
    LocalNotificationService.onNotificationClick.stream
        .listen(_handleNotificationClick);

    // Khởi tạo categories
    _initializeCategories();

    _isInitialized = true;
  }

  // Bắt đầu lịch trình kiểm tra thông báo mới
  void _startNotificationPolling() {
    // Hủy timer cũ nếu có
    _stopNotificationPolling();

    // Tạo timer mới để kiểm tra thông báo mỗi 30 giây
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      checkForNewNotifications();
    });

    debugPrint('Started notification polling every 30 seconds');
  }

  // Dừng lịch trình kiểm tra
  void _stopNotificationPolling() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  // Kiểm tra và hiển thị thông báo mới
  Future<void> checkForNewNotifications() async {
    if (_authToken == null || !_notificationsEnabled) {
      return;
    }

    try {
      debugPrint('Checking for new notifications...');

      // Lấy thông báo từ server
      final data = await ApiService.getWithCache(
        ApiService.getUrl('/notifications'),
        forceRefresh: true,
      );

      if (data != null && data['unread'] != null) {
        final List<dynamic> unreadNotifications = data['unread'];
        List<NotificationModel> newNotifications = unreadNotifications
            .map((item) => NotificationModel.fromJson({
                  ...item,
                  'read_at': null,
                }))
            .toList();

        // Lọc ra những thông báo chưa được xử lý
        List<NotificationModel> notProcessedNotifications = newNotifications
            .where((notification) =>
                !_processedNotificationIds.contains(notification.id))
            .toList();

        debugPrint(
            'Found ${notProcessedNotifications.length} new notifications');

        // Hiển thị thông báo mới
        for (var notification in notProcessedNotifications) {
          // Thêm ID vào danh sách đã xử lý
          _processedNotificationIds.add(notification.id);

          // Hiển thị thông báo
          await showLocalNotification(
            notification.title,
            notification.content,
            notification.notificationType,
            notification.id,
            imageUrl: notification.senderImageUrl,
          );

          // Đợi ngắn để tránh gửi quá nhiều thông báo một lúc
          await Future.delayed(const Duration(milliseconds: 500));
        }

        // Cập nhật danh sách thông báo đầy đủ
        _notifications.clear();
        _notifications.addAll(newNotifications);

        // Xử lý thông báo đã đọc
        if (data['read'] != null) {
          final List<dynamic> readNotifications = data['read'];
          _notifications.addAll(
            readNotifications
                .map((item) => NotificationModel.fromJson({
                      ...item,
                      'read_at':
                          item['read_at'] ?? DateTime.now().toIso8601String(),
                    }))
                .toList(),
          );
        }

        // Sắp xếp và cập nhật giao diện
        _notifications.sort((a, b) => b.time.compareTo(a.time));
        _updateUnreadCount();
        _categorizeNotifications();

        // Chỉ thông báo listener nếu có thông báo mới
        if (notProcessedNotifications.isNotEmpty) {
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error checking for new notifications: $e');
    }
  }

  // Khởi tạo danh mục thông báo
  void _initializeCategories() {
    _activeCategories = ['all', 'event', 'blog', 'club', 'system', 'promotion'];
    _currentFilter = 'all';
  }

  // Lọc thông báo theo danh mục
  void filterByCategory(String category) {
    _currentFilter = category;
    notifyListeners();
  }

  // Lấy thông báo theo danh mục hiện tại
  List<NotificationModel> getFilteredNotifications() {
    if (_currentFilter == 'all') {
      return _notifications;
    }

    return _notifications.where((notification) {
      String type = notification.notificationType;
      if (type == 'new_event') type = 'event';
      if (type == 'new_blog') type = 'blog';
      return type == _currentFilter;
    }).toList();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  // Xử lý khi click vào thông báo
  void _handleNotificationClick(ReceivedNotification notification) {
    debugPrint(
        'Handling notification click: ${notification.type} - ${notification.targetId}');

    if (notification.type != null && notification.targetId != null) {
      _navigateToContent(notification.type!, notification.targetId!);
    }
  }

  // Xử lý Deep Link từ thông báo
  void handleDeepLink(String payload) {
    debugPrint('Processing deep link: $payload');
    try {
      // Validate payload format
      if (payload.isEmpty) {
        debugPrint('Empty payload received');
        return;
      }

      final parts = payload.split(':');
      if (parts.length != 2) {
        debugPrint('Invalid payload format: $payload');
        return;
      }

      final String type = parts[0].trim();

      // Validate notification type
      final List<String> validTypes = [
        'event',
        'blog',
        'club',
        'notification',
        'new_event',
        'new_blog'
      ];
      if (!validTypes.contains(type)) {
        debugPrint('Invalid notification type in payload: $type');
        return;
      }

      // Safely parse ID
      final int? id = int.tryParse(parts[1]);
      if (id == null || id <= 0) {
        debugPrint('Invalid ID in payload: ${parts[1]}');
        return;
      }

      // Log and navigate
      debugPrint('Navigating from valid deep link: $type - $id');
      _navigateToContent(type, id);
    } catch (e) {
      debugPrint('Error processing deep link: $e');
    }
  }

  // Điều hướng đến nội dung tương ứng
  void _navigateToContent(String type, int id) {
    debugPrint('Navigating to content: $type - $id');

    final context = navigatorKey.currentContext;
    if (context == null) {
      debugPrint('No valid context for navigation');
      return;
    }

    switch (type) {
      case 'event':
      case 'new_event':
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
            AppRoutes.eventDetail, (route) => false,
            arguments: id.toString());
        break;
      case 'blog':
      case 'new_blog':
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
            AppRoutes.blogDetail, (route) => false,
            arguments: id.toString());
        break;
      case 'club':
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
            AppRoutes.clubDetail, (route) => false,
            arguments: id.toString());
        break;
      case 'notification':
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
            AppRoutes.notificationDetail, (route) => false,
            arguments: id.toString());
        break;
      default:
        debugPrint(
            'Unknown or general notification type: $type - redirecting to home');
        Navigator.of(context, rootNavigator: true)
            .pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
    }
  }

  // Fetch notifications từ server
  Future<void> fetchNotifications({bool silent = false}) async {
    if (_authToken == null) {
      debugPrint('Cannot fetch notifications: No auth token');
      _hasError = true;
      _errorMessage = 'Vui lòng đăng nhập để xem thông báo';
      notifyListeners();
      return;
    }

    if (!silent) {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      debugPrint(
          'Fetching notifications with token: ${_authToken?.substring(0, 10)}...');
      final data = await ApiService.getWithCache(
        ApiService.getUrl('/notifications'),
        forceRefresh: true,
      );

      debugPrint('Response data: $data');

      if (data != null) {
        _notifications.clear();

        // Xử lý thông báo chưa đọc
        if (data['unread'] != null) {
          final List<dynamic> unreadNotifications = data['unread'];
          _notifications.addAll(
            unreadNotifications
                .map((item) => NotificationModel.fromJson({
                      ...item,
                      'read_at': null,
                    }))
                .toList(),
          );
        }

        // Xử lý thông báo đã đọc
        if (data['read'] != null) {
          final List<dynamic> readNotifications = data['read'];
          _notifications.addAll(
            readNotifications
                .map((item) => NotificationModel.fromJson({
                      ...item,
                      'read_at':
                          item['read_at'] ?? DateTime.now().toIso8601String(),
                    }))
                .toList(),
          );
        }

        // Sắp xếp thông báo theo thời gian tạo, mới nhất lên đầu
        _notifications.sort((a, b) => b.time.compareTo(a.time));

        _updateUnreadCount();
        _categorizeNotifications();
        debugPrint(
            'Loaded ${_notifications.length} notifications (${_unreadCount} unread)');
      } else {
        _hasError = true;
        _errorMessage = 'Không thể tải thông báo: Dữ liệu không hợp lệ';
        debugPrint('Invalid response data: $data');
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      if (!silent) {
        _hasError = true;
        if (e.toString().contains('401')) {
          _errorMessage = 'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại';
          clearAuthToken();
        } else {
          _errorMessage = 'Đã xảy ra lỗi khi tải thông báo: ${e.toString()}';
        }
      }
    } finally {
      if (!silent) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }

  // Phân loại thông báo theo loại
  void _categorizeNotifications() {
    _categorizedNotifications = {};

    // Khởi tạo các danh mục
    for (var category in _activeCategories) {
      _categorizedNotifications[category] = [];
    }

    // Thêm tất cả thông báo vào danh mục 'all'
    _categorizedNotifications['all'] = _notifications;

    // Phân loại thông báo theo loại
    for (var notification in _notifications) {
      String type = notification.notificationType;

      // Ánh xạ loại thông báo
      if (type == 'new_event') type = 'event';
      if (type == 'new_blog') type = 'blog';

      // Nếu danh mục tồn tại, thêm thông báo vào
      if (_categorizedNotifications.containsKey(type)) {
        _categorizedNotifications[type]!.add(notification);
      }
    }
  }

  // Hiển thị thông báo cục bộ
  Future<void> showLocalNotification(
    String title,
    String body,
    String type,
    int id, {
    String? imageUrl,
  }) async {
    try {
      // Tạo ID ngẫu nhiên cho mỗi thông báo
      final notificationId =
          DateTime.now().millisecondsSinceEpoch.remainder(100000);

      // Log rõ ràng
      debugPrint('NotificationProvider: Showing notification with:');
      debugPrint('  Title: $title');
      debugPrint('  Body: $body');
      debugPrint('  Type: $type');
      debugPrint('  ID: $id');
      debugPrint('  NotificationId: $notificationId');

      // Tạo payload
      String payload = '$type:$id';

      // Chỉ hiển thị thông báo nếu đã bật
      if (_notificationsEnabled) {
        try {
          final bool success = await LocalNotificationService.showNotification(
            id: notificationId,
            title: title,
            body: body,
            payload: payload,
            imageUrl: imageUrl,
          );

          if (!success) {
            debugPrint('LOCAL_NOTIFICATION: Failed to show notification');
          } else {
            debugPrint('LOCAL_NOTIFICATION: Successfully showed notification');
          }
        } catch (e) {
          debugPrint('LOCAL_NOTIFICATION_ERROR: $e');
        }
      } else {
        debugPrint(
            'LOCAL_NOTIFICATION: Notifications are disabled in settings');
      }
    } catch (e) {
      debugPrint('PROVIDER_ERROR: Failed to show notification: $e');
    }
  }

  // Đánh dấu notification đã đọc
  Future<void> markAsRead(String notificationId) async {
    try {
      await ApiService.post(
        ApiService.getUrl('/notifications/$notificationId/read'),
        body: {},
      );

      final int id = int.parse(notificationId);
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _updateUnreadCount();
        _categorizeNotifications();
        notifyListeners();
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Đánh dấu tất cả đã đọc
  Future<void> markAllAsRead() async {
    try {
      await ApiService.post(
        ApiService.getUrl('/notifications/mark-all-read'),
        body: {},
      );

      // Cập nhật trạng thái cục bộ
      for (int i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].isRead) {
          _notifications[i] = _notifications[i].copyWith(isRead: true);
        }
      }

      _updateUnreadCount();
      _categorizeNotifications();
      notifyListeners();
    } catch (e) {
      print('Error marking all as read: $e');
    }
  }

  // Xóa thông báo
  Future<void> deleteNotification(int id) async {
    try {
      await ApiService.delete(
        ApiService.getUrl('/notifications/$id'),
      );

      // Xóa khỏi danh sách cục bộ
      _notifications.removeWhere((n) => n.id == id);
      _updateUnreadCount();
      _categorizeNotifications();
      notifyListeners();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  // Cập nhật cài đặt thông báo
  void updateNotificationSettings({
    bool? enabled,
    bool? sound,
    bool? vibration,
  }) {
    if (enabled != null) _notificationsEnabled = enabled;
    if (sound != null) _soundEnabled = sound;
    if (vibration != null) _vibrationEnabled = vibration;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/notification_model.dart';
import '../../theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../routes/app_routes.dart';
import '../../screens/event/event_detail_screen.dart';
import '../../screens/blog/blog_detail_screen.dart';
import '../../screens/club/club_detail_screen.dart';

class NotificationDetailScreen extends StatelessWidget {
  final NotificationModel notification;
  final Function(String, int)? onNavigate;

  const NotificationDetailScreen({
    Key? key,
    required this.notification,
    this.onNavigate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Xác định các kiểu dáng dựa trên loại thông báo
    Color themeColor;
    IconData headerIcon;
    List<Widget> specialContent = [];

    switch (notification.notificationType) {
      case 'new_event':
        themeColor = Colors.blue;
        headerIcon = Icons.event;
        // Thêm nội dung đặc biệt cho sự kiện
        specialContent = [
          _buildEventDetails(context),
        ];
        break;
      case 'new_blog':
        themeColor = Colors.green;
        headerIcon = Icons.article;
        // Thêm nội dung đặc biệt cho blog
        specialContent = [
          _buildBlogDetails(context),
        ];
        break;
      case 'promotion':
        themeColor = Colors.orange;
        headerIcon = Icons.local_offer;
        break;
      case 'system':
        themeColor = Colors.purple;
        headerIcon = Icons.settings;
        break;
      default:
        themeColor = Theme.of(context).primaryColor;
        headerIcon = Icons.notifications;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết thông báo'),
        elevation: 0,
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              _showDeleteConfirmation(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              color: themeColor,
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: 30,
                top: 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getTypeName(notification.notificationType),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    notification.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDateTime(notification.time),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic content
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon and title
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: themeColor.withOpacity(0.1),
                              radius: 16,
                              child:
                                  Icon(headerIcon, color: themeColor, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Nội dung thông báo",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: themeColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Message content
                        Text(
                          notification.content,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),

                        // View Details Button - Only show if the notification has a navigation ID
                        if (notification.hasNavigationId())
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Center(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.visibility),
                                label: const Text('Xem chi tiết'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: themeColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () => _navigateToContent(context),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Special content based on notification type
                  ...specialContent,

                  // Metadata
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Thông tin bổ sung",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // ... rest of metadata widgets
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị chi tiết cho sự kiện
  Widget _buildEventDetails(BuildContext context) {
    // Lấy dữ liệu chi tiết theo loại
    final details = notification.getDetailsBasedOnType();

    final eventName = details['event_name'] ?? '';
    final eventDate = details['start_date'] ?? '';
    final eventEndDate = details['end_date'] ?? '';
    final eventLocation = details['location'] ?? '';
    final eventDescription = details['description'] ?? '';

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue.withOpacity(0.1),
                radius: 16,
                child: const Icon(Icons.calendar_today,
                    color: Colors.blue, size: 18),
              ),
              const SizedBox(width: 12),
              const Text(
                "Thông tin sự kiện",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.event_note, "Tên sự kiện", eventName),
          _buildInfoRow(Icons.event, "Ngày bắt đầu", eventDate),
          if (eventEndDate.isNotEmpty)
            _buildInfoRow(Icons.event_busy, "Ngày kết thúc", eventEndDate),
          _buildInfoRow(Icons.location_on, "Địa điểm", eventLocation),
          if (eventDescription.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Mô tả:",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    eventDescription,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

          // Thêm nút Xem chi tiết cho sự kiện
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              onPressed: () => _navigateToContent(context),
              icon: const Icon(Icons.visibility),
              label: const Text('Xem chi tiết sự kiện'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị chi tiết cho blog
  Widget _buildBlogDetails(BuildContext context) {
    // Lấy dữ liệu chi tiết theo loại
    final details = notification.getDetailsBasedOnType();

    final blogTitle = details['blog_title'] ?? '';
    final authorName = details['author_name'] ?? '';
    final publishDate = details['publish_date'] ?? '';
    final blogContent = details['content'] ?? '';

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.green.withOpacity(0.1),
                radius: 16,
                child: const Icon(Icons.article, color: Colors.green, size: 18),
              ),
              const SizedBox(width: 12),
              const Text(
                "Thông tin bài viết",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.title, "Tiêu đề", blogTitle),
          _buildInfoRow(Icons.person, "Tác giả", authorName),
          if (publishDate.isNotEmpty)
            _buildInfoRow(Icons.date_range, "Ngày đăng", publishDate),
          if (blogContent.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Nội dung:",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    blogContent,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Widget hiển thị một hàng thông tin
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.visible,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  // Chuyển đổi notification_type thành tên hiển thị
  String _getTypeName(String type) {
    switch (type) {
      case 'new_event':
        return 'Sự kiện';
      case 'new_blog':
        return 'Bài viết';
      case 'promotion':
        return 'Ưu đãi';
      case 'system':
        return 'Hệ thống';
      default:
        return 'Thông báo';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final notificationDate = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
    );

    if (notificationDate == today) {
      return 'Hôm nay, ${DateFormat('HH:mm').format(dateTime)}';
    } else if (notificationDate == yesterday) {
      return 'Hôm qua, ${DateFormat('HH:mm').format(dateTime)}';
    } else {
      return DateFormat('dd/MM/yyyy, HH:mm').format(dateTime);
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa thông báo'),
        content: const Text('Bạn có chắc chắn muốn xóa thông báo này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context)
                  .pop(); // Exit the notification detail screen
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Kiểm tra nếu có thể điều hướng đến nội dung chi tiết
  bool _canNavigateToTarget() {
    return notification.hasNavigationId() && notification.getTargetId() != null;
  }

  // Lấy icon điều hướng dựa trên loại thông báo
  IconData _getNavigationIcon() {
    switch (notification.notificationType) {
      case 'new_event':
        return Icons.event;
      case 'new_blog':
        return Icons.article;
      case 'promotion':
        return Icons.local_offer;
      default:
        return Icons.arrow_forward;
    }
  }

  // Lấy text điều hướng dựa trên loại thông báo
  String _getNavigationText() {
    switch (notification.notificationType) {
      case 'new_event':
        return 'Xem sự kiện';
      case 'new_blog':
        return 'Xem bài viết';
      case 'promotion':
        return 'Xem ưu đãi';
      default:
        return 'Xem chi tiết';
    }
  }

  // Navigate to content based on notification type and target ID
  void _navigateToContent(BuildContext context) {
    try {
      final int? targetId = notification.getTargetId();
      if (targetId == null) {
        _showErrorSnackbar(context, 'Không thể tìm thấy thông tin chi tiết');
        return;
      }

      // Chuyển đổi thành string để truyền làm tham số
      final String idStr = targetId.toString();

      // Log thông tin để debug
      debugPrint('=== THÔNG TIN ĐIỀU HƯỚNG ===');
      debugPrint('Loại thông báo: ${notification.notificationType}');
      debugPrint('ID mục tiêu: $idStr');

      // Kiểm tra xem thông báo có phải là loại liên quan đến sự kiện không
      bool isEventNotification = notification.notificationType == 'new_event' ||
          notification.notificationType == 'event' ||
          notification.notificationType.contains('event') ||
          (notification.rawData.containsKey('target_type') &&
              notification.rawData['target_type'] == 'event') ||
          (notification.rawData.containsKey('event_name'));

      // Sử dụng Navigator với rootNavigator để đảm bảo không có nút back
      if (isEventNotification) {
        debugPrint('Điều hướng đến màn hình chi tiết sự kiện với ID: $idStr');

        // Sử dụng rootNavigator:true để vượt qua các Navigator lồng nhau
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => EventDetailScreen(
              eventId: idStr,
            ),
            // Thiết lập fullscreenDialog:true để không hiển thị nút back
            fullscreenDialog: true,
          ),
        );
      } else if (notification.notificationType == 'new_blog' ||
          notification.notificationType == 'blog') {
        debugPrint('Điều hướng đến màn hình chi tiết blog với ID: $idStr');

        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => BlogDetailScreen(blogId: idStr),
            fullscreenDialog: true,
          ),
        );
      } else if (notification.notificationType == 'club') {
        debugPrint(
            'Điều hướng đến màn hình chi tiết câu lạc bộ với ID: $idStr');

        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => ClubDetailScreen(clubId: idStr),
            fullscreenDialog: true,
          ),
        );
      } else {
        _showErrorSnackbar(context, 'Loại thông báo không được hỗ trợ');
      }
    } catch (e) {
      debugPrint('LỖI khi điều hướng: $e');
      _showErrorSnackbar(context, 'Có lỗi xảy ra khi mở trang chi tiết');
    }
  }

  // Helper method to show error messages
  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .clearSnackBars(); // Clear any existing snackbars
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}

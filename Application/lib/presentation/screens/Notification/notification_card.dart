import 'package:flutter/material.dart';
import '../../../data/models/notification_model.dart';
import '../../../utils/image_utils.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onShare;

  const NotificationCard({
    Key? key,
    required this.notification,
    this.onMarkAsRead,
    this.onTap,
    this.onLike,
    this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color notificationColor = notification.color ?? Colors.grey;
    IconData notificationIcon;

    switch (notification.notificationType) {
      case 'join_request':
        notificationIcon = Icons.person_add;
        break;
      case 'new_event':
        notificationIcon = Icons.event;
        break;
      case 'new_blog':
        notificationIcon = Icons.article;
        break;
      default:
        notificationIcon = Icons.notifications;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(
          color: notification.isRead
              ? Colors.transparent
              : notificationColor.withOpacity(0.5),
          width: 1.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main notification content
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left color indicator
                Container(
                  width: 6,
                  height: 75,
                  color: notification.isRead
                      ? Colors.transparent
                      : notificationColor,
                ),

                // Notification icon or avatar
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: notification.senderImageUrl != null &&
                          notification.senderImageUrl!.isNotEmpty
                      ? ImageUtils.buildCircleAvatar(
                          imageUrl: notification.senderImageUrl,
                          radius: 24,
                          backgroundColor: notificationColor.withOpacity(0.1),
                          placeholder: CircleAvatar(
                            radius: 24,
                            backgroundColor: notificationColor.withOpacity(0.1),
                            child: Icon(notificationIcon,
                                color: notificationColor),
                          ),
                        )
                      : CircleAvatar(
                          radius: 24,
                          backgroundColor: notificationColor.withOpacity(0.1),
                          child:
                              Icon(notificationIcon, color: notificationColor),
                        ),
                ),

                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and type badge
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontWeight: notification.isRead
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Type badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: notificationColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _getTypeDisplay(notification.notificationType),
                                style: TextStyle(
                                  color: notificationColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        // Content
                        Text(
                          notification.content,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Time display
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(notification.time),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeDisplay(String type) {
    switch (type) {
      case 'join_request':
        return 'Yêu cầu';
      case 'new_event':
        return 'Sự kiện';
      case 'new_blog':
        return 'Bài viết';
      default:
        return 'Thông báo';
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}

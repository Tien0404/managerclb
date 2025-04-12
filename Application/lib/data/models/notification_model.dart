import 'dart:convert';
import 'package:flutter/material.dart';

class NotificationModel {
  final int id;
  final String title;
  final String content;
  final DateTime time;
  final bool isRead;
  final String notificationType;
  final String? icon;
  final String? senderImageUrl;
  final String? senderName; // Người gửi thông báo
  final bool isLiked; // Người dùng đã thích thông báo
  final List<String> relatedUserNames; // Người liên quan đến thông báo
  final Map<String, dynamic> rawData;
  Color? color;
  final int? interactionCount; // Số lượng tương tác (bình luận, thích)

  NotificationModel({
    required this.id,
    required this.title,
    required this.content,
    required this.time,
    this.isRead = false,
    this.notificationType = 'unknown',
    this.icon,
    this.color,
    this.senderImageUrl,
    this.senderName,
    this.isLiked = false,
    this.relatedUserNames = const [],
    this.interactionCount,
    required this.rawData,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Trích xuất dữ liệu thông báo với xử lý an toàn
    Map<String, dynamic> data = {};
    if (json['data'] is Map) {
      data = Map<String, dynamic>.from(json['data']);
    } else if (json['data'] is String) {
      try {
        data = jsonDecode(json['data']);
      } catch (e) {
        data = {'message': json['data']};
      }
    }

    // Xác định loại thông báo
    String notificationType = data['notification_type'] ?? 'unknown';

    // Xử lý loại thông báo join_request
    if (notificationType.startsWith('join_request_')) {
      notificationType = 'join_request';
    }

    // Xác định tiêu đề và nội dung
    String title = data['title'] ?? json['title'] ?? 'Thông báo';
    String content = data['content'] ?? json['content'] ?? '';

    // Xác định thời gian
    DateTime time;
    try {
      time = json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : (data['created_at'] != null
              ? DateTime.parse(data['created_at'])
              : DateTime.now());
    } catch (e) {
      time = DateTime.now();
    }

    // Xác định trạng thái đã đọc
    bool isRead = json['read_at'] != null;

    // Xác định sender info
    String? senderImageUrl =
        data['sender_image_url'] ?? json['sender_image_url'];
    String? senderName = data['sender_name'] ?? json['sender_name'];

    return NotificationModel(
      id: json['id'] ?? 0,
      title: title,
      content: content,
      time: time,
      isRead: isRead,
      notificationType: notificationType,
      icon: _getIconForType(notificationType),
      color: _getColorForType(notificationType),
      senderImageUrl: senderImageUrl,
      senderName: senderName,
      rawData: {
        ...data,
        ...json
      }, // Merge cả data và json để đảm bảo không mất thông tin
    );
  }

  // Lấy các thông tin chi tiết theo loại thông báo
  Map<String, dynamic> getDetailsBasedOnType() {
    Map<String, dynamic> details = {};

    switch (notificationType) {
      case 'new_event':
        details = {
          'event_id': rawData['event_id'],
          'event_name': rawData['event_name'] ?? title,
          'start_date': rawData['start_date'] ?? '',
          'end_date': rawData['end_date'] ?? '',
          'location': rawData['location'] ?? '',
          'description': rawData['description'] ?? content,
          'organizer': rawData['organizer'] ?? senderName ?? '',
          'participants_count': rawData['participants_count'] ?? '',
        };
        break;

      case 'new_blog':
        details = {
          'blog_id': rawData['blog_id'],
          'blog_title': rawData['blog_title'] ?? title,
          'author_name': rawData['author_name'] ?? senderName ?? '',
          'publish_date': rawData['publish_date'] ?? '',
          'content': rawData['blog_content'] ?? content,
          'likes_count': rawData['likes_count'] ?? '',
          'comments_count': rawData['comments_count'] ?? '',
        };
        break;

      case 'promotion':
        details = {
          'promotion_id': rawData['promotion_id'],
          'promotion_title': rawData['promotion_title'] ?? title,
          'valid_until': rawData['valid_until'] ?? '',
          'description': rawData['description'] ?? content,
          'discount_amount': rawData['discount_amount'] ?? '',
          'promo_code': rawData['promo_code'] ?? '',
        };
        break;

      case 'club':
        details = {
          'club_id': rawData['club_id'],
          'club_name': rawData['club_name'] ?? title,
          'action': rawData['action'] ?? '',
          'member_count': rawData['member_count'] ?? '',
          'description': rawData['description'] ?? content,
        };
        break;

      default:
        details = {
          'title': title,
          'content': content,
        };
    }

    return details;
  }

  // Kiểm tra xem có ID để điều hướng hay không
  bool hasNavigationId() {
    switch (notificationType) {
      case 'new_event':
        return rawData['event_id'] != null;
      case 'new_blog':
        return rawData['blog_id'] != null;
      case 'club':
        return rawData['club_id'] != null;
      default:
        return false;
    }
  }

  // Lấy ID của đối tượng liên quan (event_id, blog_id, v.v.)
  int? getTargetId() {
    return rawData['target_id'] != null
        ? int.tryParse(rawData['target_id'].toString())
        : null;
  }

  // Lấy loại mục tiêu từ dữ liệu thô
  String? getTargetType() {
    return rawData['target_type'];
  }

  // Tạo nội dung thông báo kiểu Facebook
  String getFacebookStyleContent() {
    String fbContent = '';

    // Format: "Người gửi đã [hành động] về [đối tượng] của bạn"
    switch (notificationType) {
      case 'new_event':
        if (senderName != null) {
          fbContent = "$senderName đã tạo sự kiện mới: \"$title\"";
        } else {
          fbContent = "Một sự kiện mới đã được tạo: \"$title\"";
        }
        break;

      case 'new_blog':
        if (senderName != null) {
          fbContent = "$senderName đã đăng bài viết mới: \"$title\"";
        } else {
          fbContent = "Một bài viết mới đã được đăng: \"$title\"";
        }
        break;

      case 'club':
        String action = rawData['action'] ?? 'cập nhật';
        String clubName = rawData['club_name'] ?? 'CLB';

        if (senderName != null) {
          fbContent = "$senderName đã $action $clubName";
        } else {
          fbContent = "$clubName đã được $action";
        }
        break;

      default:
        fbContent = content;
    }

    // Thêm thông tin về người liên quan
    if (relatedUserNames.isNotEmpty) {
      if (relatedUserNames.length == 1) {
        fbContent += " cùng với ${relatedUserNames[0]}";
      } else if (relatedUserNames.length == 2) {
        fbContent +=
            " cùng với ${relatedUserNames[0]} và ${relatedUserNames[1]}";
      } else {
        fbContent +=
            " cùng với ${relatedUserNames[0]}, ${relatedUserNames[1]} và ${relatedUserNames.length - 2} người khác";
      }
    }

    return fbContent;
  }

  // Tạo bản sao của notification với các thuộc tính được cập nhật
  NotificationModel copyWith({
    int? id,
    String? title,
    String? content,
    DateTime? time,
    bool? isRead,
    String? notificationType,
    String? icon,
    Color? color,
    String? senderImageUrl,
    String? senderName,
    bool? isLiked,
    List<String>? relatedUserNames,
    int? interactionCount,
    Map<String, dynamic>? rawData,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      time: time ?? this.time,
      isRead: isRead ?? this.isRead,
      notificationType: notificationType ?? this.notificationType,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      senderImageUrl: senderImageUrl ?? this.senderImageUrl,
      senderName: senderName ?? this.senderName,
      isLiked: isLiked ?? this.isLiked,
      relatedUserNames: relatedUserNames ?? this.relatedUserNames,
      interactionCount: interactionCount ?? this.interactionCount,
      rawData: rawData ?? this.rawData,
    );
  }

  // Các phương thức static để lấy icon và màu sắc cho từng loại thông báo
  static String _getIconForType(String type) {
    switch (type) {
      case 'new_event':
        return 'assets/icons/event.png';
      case 'new_blog':
        return 'assets/icons/blog.png';
      case 'promotion':
        return 'assets/icons/promotion.png';
      case 'club':
        return 'assets/icons/club.png';
      case 'join_request':
        return 'assets/icons/join_request.png';
      default:
        return 'assets/icons/notification.png';
    }
  }

  static Color _getColorForType(String type) {
    switch (type) {
      case 'new_event':
        return Colors.blue;
      case 'new_blog':
        return Colors.green;
      case 'promotion':
        return Colors.orange;
      case 'club':
        return Colors.indigo;
      case 'join_request':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

// Sample data for notifications - keeping for testing purposes
List<NotificationModel> dummyNotifications = [
  NotificationModel(
    id: 1,
    title: "Khuyến mãi đặc biệt",
    content:
        "Chúng tôi có chương trình khuyến mãi đặc biệt dành cho tất cả khách hàng trong tháng này.",
    time: DateTime.now().subtract(const Duration(hours: 2)),
    notificationType: "promotion",
    senderName: "Ban Quản Trị",
    rawData: {
      'promotion_id': 123,
      'valid_until': '30/04/2024',
      'description': 'Giảm 50% cho tất cả sự kiện trong tháng 4/2024',
      'promo_code': 'SPRING50',
    },
  ),
  NotificationModel(
    id: 2,
    title: "Cập nhật hệ thống",
    content: "Hệ thống sẽ được nâng cấp vào ngày mai từ 22:00 đến 23:00.",
    time: DateTime.now().subtract(const Duration(days: 1)),
    notificationType: "system",
    senderName: "Hệ thống",
    rawData: {
      'message': 'Hệ thống sẽ được nâng cấp vào ngày mai từ 22:00 đến 23:00.'
    },
  ),
  NotificationModel(
    id: 3,
    title: "Sự kiện mới",
    content:
        "Hội thảo kỹ năng mềm sẽ diễn ra vào ngày 25/03/2024 tại Hội trường A1.",
    time: DateTime.now().subtract(const Duration(days: 3)),
    notificationType: "new_event",
    senderName: "Nguyễn Văn A",
    relatedUserNames: ["Trần Thị B", "Lê Văn C"],
    interactionCount: 15,
    rawData: {
      'event_id': 456,
      'event_name': 'Hội thảo kỹ năng mềm',
      'start_date': '25/03/2024',
      'location': 'Hội trường A1',
      'organizer': 'Nguyễn Văn A',
      'participants_count': 45,
      'description':
          'Hội thảo kỹ năng mềm giúp bạn phát triển kỹ năng giao tiếp và làm việc nhóm.'
    },
  ),
  NotificationModel(
    id: 4,
    title: "Bài viết mới",
    content:
        "Bài viết 'Kỹ năng giao tiếp hiệu quả' đã được đăng bởi Nguyễn Văn A.",
    time: DateTime.now().subtract(const Duration(days: 7)),
    notificationType: "new_blog",
    senderName: "Nguyễn Văn A",
    isLiked: true,
    interactionCount: 32,
    rawData: {
      'blog_id': 789,
      'blog_title': 'Kỹ năng giao tiếp hiệu quả',
      'author_name': 'Nguyễn Văn A',
      'likes_count': 25,
      'comments_count': 7,
      'blog_content':
          'Bài viết chi tiết về các kỹ năng giao tiếp hiệu quả trong môi trường làm việc.'
    },
  ),
];

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

    // Xác định tiêu đề dựa trên loại thông báo
    String title = data['title'] ?? 'Thông báo';
    if (notificationType == 'new_event') {
      title = data['event_name'] ?? 'Sự kiện mới';
    } else if (notificationType == 'new_blog') {
      title = data['blog_title'] ?? 'Bài viết mới';
    }

    // Xác định nội dung
    String content = data['message'] ?? '';
    if (content.isEmpty) {
      if (notificationType == 'new_event') {
        content =
            'Sự kiện mới: "${data['event_name'] ?? ''}" sẽ diễn ra vào ${data['start_date'] ?? ''} tại ${data['location'] ?? ''}';
      } else if (notificationType == 'new_blog') {
        content =
            'Bài viết mới: "${data['blog_title'] ?? ''}" bởi ${data['author_name'] ?? ''}';
      }
    }

    // Xác định icon dựa trên loại thông báo
    String icon = '🔔';
    if (notificationType == 'new_event') {
      icon = '📅';
    } else if (notificationType == 'new_blog') {
      icon = '📝';
    }

    // Xác định URL avatar của người gửi
    String? senderImageUrl =
        data['sender_image_url'] ?? data['avatar'] ?? data['image_url'];

    // Lấy tên người gửi
    String? senderName = data['sender_name'] ?? data['author_name'] ?? null;

    // Xác định người liên quan
    List<String> relatedUserNames = [];
    if (data['related_users'] is List) {
      relatedUserNames = List<String>.from(data['related_users']);
    }

    // Trạng thái đã thích
    bool isLiked = data['is_liked'] == true;

    // Số lượng tương tác
    int? interactionCount;
    if (data['interaction_count'] != null) {
      interactionCount = int.tryParse(data['interaction_count'].toString());
    }

    // Tạo ID an toàn
    int id = 0;
    try {
      id = json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0;
    } catch (e) {
      id = 0;
    }

    // Xử lý datetime an toàn
    DateTime time = DateTime.now();
    try {
      if (json['read_at'] != null) {
        time = DateTime.tryParse(json['read_at'].toString()) ?? DateTime.now();
      } else if (json['created_at'] != null) {
        time =
            DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now();
      }
    } catch (e) {
      time = DateTime.now();
    }

    // Xác định trạng thái đã đọc
    bool isRead = false;
    try {
      isRead = json['read_at'] != null;
    } catch (e) {
      isRead = false;
    }

    return NotificationModel(
      id: id,
      title: title,
      content: content,
      time: time,
      isRead: isRead,
      notificationType: notificationType,
      icon: icon,
      senderImageUrl: senderImageUrl,
      senderName: senderName,
      isLiked: isLiked,
      relatedUserNames: relatedUserNames,
      interactionCount: interactionCount,
      rawData: {...json, ...data},
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
    switch (notificationType) {
      case 'new_event':
        return rawData['event_id'] is int
            ? rawData['event_id']
            : int.tryParse(rawData['event_id']?.toString() ?? '');
      case 'new_blog':
        return rawData['blog_id'] is int
            ? rawData['blog_id']
            : int.tryParse(rawData['blog_id']?.toString() ?? '');
      case 'club':
        return rawData['club_id'] is int
            ? rawData['club_id']
            : int.tryParse(rawData['club_id']?.toString() ?? '');
      default:
        return null;
    }
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
          fbContent = "$senderName đã $action câu lạc bộ $clubName";
        } else {
          fbContent = "Câu lạc bộ $clubName đã được $action";
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

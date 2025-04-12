import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ApiService.dart';
import 'AuthService.dart';
import 'package:flutter/material.dart';
import 'local_notification_service.dart';

class NotificationService {
  /// Phương thức để gửi thông báo cục bộ khi có sự kiện từ API
  Future<void> showLocalNotification(
      {required String title, required String body, String? payload}) async {
    try {
      // Sử dụng LocalNotificationService để hiển thị thông báo
      await LocalNotificationService.showNotification(
        id: DateTime.now().millisecond,
        title: title,
        body: body,
        payload: payload ?? 'notification:0',
      );
    } catch (e) {
      debugPrint('Error showing local notification: $e');
    }
  }

  /// Lấy danh sách thông báo
  Future<Map<String, dynamic>> getNotifications() async {
    final url = ApiService.getUrl('/notifications');
    final token = await AuthService.getToken();

    if (token == null) {
      throw Exception('Bạn cần đăng nhập để xem thông báo');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      print('===== NOTIFICATION SERVICE DEBUG =====');
      print('Fetching notifications from: $url');
      print('Using token: ${token.substring(0, 10)}...');

      final response = await http.get(Uri.parse(url), headers: headers);

      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');

      // Full response debugging
      print('FULL RESPONSE BODY:');
      print(response.body);
      print('==================================');

      if (response.statusCode == 200) {
        // Try to decode JSON with error handling
        try {
          final data = jsonDecode(response.body);
          print('Successfully decoded JSON response');

          // Debug the structure
          if (data is Map) {
            print('Data structure: Map with keys: ${data.keys.join(', ')}');
            data.forEach((key, value) {
              print('Key: $key, Type: ${value.runtimeType}');
              if (value is List && value.isNotEmpty) {
                print('  First item type: ${value.first.runtimeType}');
                print('  Sample item: ${json.encode(value.first)}');
              }
            });
          } else if (data is List) {
            print('Data structure: List with ${data.length} items');
            if (data.isNotEmpty) {
              print('  First item type: ${data.first.runtimeType}');
              print('  Sample item: ${json.encode(data.first)}');
            }
          } else {
            print('Data is not a Map or List: ${data.runtimeType}');
          }

          // Normalize response format - different API response formats handling
          Map<String, dynamic> result = {'unread': [], 'read': []};

          // If API returns data in the expected format with 'unread' and 'read' keys
          if (data is Map &&
              data.containsKey('unread') &&
              data.containsKey('read')) {
            result['unread'] = data['unread'] ?? [];
            result['read'] = data['read'] ?? [];
          }
          // If API returns a simple list of notifications
          else if (data is List) {
            result['unread'] = data
                .where((item) =>
                    item is Map &&
                    item.containsKey('read_at') &&
                    item['read_at'] == null)
                .toList();
            result['read'] = data
                .where((item) =>
                    item is Map &&
                    item.containsKey('read_at') &&
                    item['read_at'] != null)
                .toList();
          }
          // If API returns a different structure, try to adapt
          else if (data is Map) {
            // Try to find notification data in different key patterns
            if (data.containsKey('data') && data['data'] is List) {
              var items = data['data'] as List;
              result['unread'] = items
                  .where((item) =>
                      item is Map &&
                      (!item.containsKey('read_at') || item['read_at'] == null))
                  .toList();
              result['read'] = items
                  .where((item) =>
                      item is Map &&
                      item.containsKey('read_at') &&
                      item['read_at'] != null)
                  .toList();
            } else if (data.containsKey('notifications') &&
                data['notifications'] is List) {
              var items = data['notifications'] as List;
              result['unread'] = items
                  .where((item) =>
                      item is Map &&
                      (!item.containsKey('read_at') || item['read_at'] == null))
                  .toList();
              result['read'] = items
                  .where((item) =>
                      item is Map &&
                      item.containsKey('read_at') &&
                      item['read_at'] != null)
                  .toList();
            }
          }

          print(
              'Processed ${result['unread'].length} unread and ${result['read'].length} read notifications');
          print('===== END DEBUG =====');

          return result;
        } catch (e) {
          print('Error decoding JSON: $e');
          throw Exception('Định dạng phản hồi không hợp lệ: $e');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại');
      } else {
        throw Exception('Không thể tải thông báo: ${response.statusCode}');
      }
    } catch (e) {
      print('Network or other error: $e');
      throw Exception('Lỗi kết nối: $e');
    }
  }

  /// Đánh dấu thông báo đã đọc
  Future<void> markAsRead(String notificationId) async {
    final url =
        ApiService.getUrl('/notifications/$notificationId/mark-as-read');
    final token = await AuthService.getToken();

    if (token == null) {
      throw Exception('Bạn cần đăng nhập để thực hiện chức năng này');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      print('Marking notification as read: $notificationId');
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({}),
      );

      print('Response status code: ${response.statusCode}');
      if (response.statusCode != 200) {
        print('Error response body: ${response.body}');
        throw Exception('Không thể đánh dấu đã đọc: ${response.statusCode}');
      }
    } catch (e) {
      print('Error marking as read: $e');
      throw Exception('Lỗi kết nối: $e');
    }
  }

  /// Đánh dấu tất cả thông báo đã đọc
  Future<void> markAllAsRead() async {
    final url = ApiService.getUrl('/notifications/mark-all-read');
    final token = await AuthService.getToken();

    if (token == null) {
      throw Exception('Bạn cần đăng nhập để thực hiện chức năng này');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      print('Marking all notifications as read');
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({}),
      );

      print('Response status code: ${response.statusCode}');
      if (response.statusCode != 200) {
        print('Error response body: ${response.body}');
        throw Exception(
            'Không thể đánh dấu tất cả đã đọc: ${response.statusCode}');
      }
    } catch (e) {
      print('Error marking all as read: $e');
      throw Exception('Lỗi kết nối: $e');
    }
  }

  /// Xóa thông báo
  Future<void> deleteNotification(String notificationId) async {
    final url = ApiService.getUrl('/notifications/$notificationId');
    final token = await AuthService.getToken();

    if (token == null) {
      throw Exception('Bạn cần đăng nhập để thực hiện chức năng này');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      print('Deleting notification: $notificationId');
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );

      print('Response status code: ${response.statusCode}');
      if (response.statusCode != 200 && response.statusCode != 204) {
        print('Error response body: ${response.body}');
        throw Exception('Không thể xóa thông báo: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting notification: $e');
      throw Exception('Lỗi kết nối: $e');
    }
  }

  /// Xóa tất cả thông báo
  Future<void> deleteAllNotifications() async {
    final url = ApiService.getUrl('/notifications');
    final token = await AuthService.getToken();

    if (token == null) {
      throw Exception('Bạn cần đăng nhập để thực hiện chức năng này');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      print('Deleting all notifications');
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );

      print('Response status code: ${response.statusCode}');
      if (response.statusCode != 200 && response.statusCode != 204) {
        print('Error response body: ${response.body}');
        throw Exception(
            'Không thể xóa tất cả thông báo: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting all notifications: $e');
      throw Exception('Lỗi kết nối: $e');
    }
  }

  /// Lấy số lượng thông báo chưa đọc
  Future<int> getUnreadCount() async {
    try {
      final data = await getNotifications();
      final List<dynamic> unread = data['unread'] ?? [];
      return unread.length;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }
}

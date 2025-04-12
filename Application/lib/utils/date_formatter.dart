import 'package:intl/intl.dart';

class DateFormatter {
  /// Format a DateTime object to a readable date-time string
  /// Example: '20 Tháng 5, 2023 - 14:30'
  static String formatDateTime(DateTime dateTime) {
    final DateFormat dateFormatter =
        DateFormat('dd MMMM, yyyy - HH:mm', 'vi_VN');
    try {
      return dateFormatter.format(dateTime);
    } catch (e) {
      return DateFormat('dd/MM/yyyy - HH:mm').format(dateTime);
    }
  }

  /// Format a DateTime object to a readable date string (without time)
  /// Example: '20 Tháng 5, 2023'
  static String formatDate(DateTime dateTime) {
    final DateFormat dateFormatter = DateFormat('dd MMMM, yyyy', 'vi_VN');
    try {
      return dateFormatter.format(dateTime);
    } catch (e) {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }

  /// Format a DateTime object to a readable time string
  /// Example: '14:30'
  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  /// Calculate and return a human-readable time difference
  /// Example: '2 giờ trước', '3 ngày trước', 'Vừa xong'
  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} năm trước';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} tháng trước';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  /// Returns the remaining time until the event as a formatted string
  /// Example: 'Còn 3 ngày', 'Còn 5 giờ', 'Đang diễn ra', 'Đã kết thúc'
  static String getRemainingTime(DateTime startDate, DateTime endDate) {
    final now = DateTime.now();

    if (now.isAfter(endDate)) {
      return 'Đã kết thúc';
    } else if (now.isAfter(startDate) && now.isBefore(endDate)) {
      return 'Đang diễn ra';
    } else {
      final difference = startDate.difference(now);

      if (difference.inDays > 0) {
        return 'Còn ${difference.inDays} ngày';
      } else if (difference.inHours > 0) {
        return 'Còn ${difference.inHours} giờ';
      } else if (difference.inMinutes > 0) {
        return 'Còn ${difference.inMinutes} phút';
      } else {
        return 'Sắp diễn ra';
      }
    }
  }
}

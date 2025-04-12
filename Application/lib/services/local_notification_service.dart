import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';

class ReceivedNotification {
  final int id;
  final String? title;
  final String? body;
  final String? payload;
  final String? type;
  final int? targetId;

  ReceivedNotification({
    required this.id,
    this.title,
    this.body,
    this.payload,
    this.type,
    this.targetId,
  });
}

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String?>();
  static final onNotificationClick = BehaviorSubject<ReceivedNotification>();
  static Function(String?)? _onNotificationTap;

  // Danh sách các kênh thông báo
  static const String highImportanceChannelId = 'high_importance_channel';
  static const String defaultChannelId = 'default_channel';
  static const String eventChannelId = 'event_channel';
  static const String messageChannelId = 'message_channel';
  static const String silentChannelId = 'silent_channel';

  // Khởi tạo notification
  static Future<bool> init({Function(String?)? onNotificationTap}) async {
    try {
      debugPrint('INIT: Starting notification service initialization');
      _onNotificationTap = onNotificationTap;

      // Thiết lập icon cho Android
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      debugPrint('INIT: Set up Android initialization settings');

      // Thiết lập cho iOS
      final DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
        notificationCategories: [
          // Tạo danh mục thông báo có actions
          DarwinNotificationCategory(
            'actionable',
            actions: [
              DarwinNotificationAction.plain(
                'view',
                'Xem',
                options: {DarwinNotificationActionOption.foreground},
              ),
              DarwinNotificationAction.plain(
                'dismiss',
                'Bỏ qua',
              ),
            ],
          ),
        ],
      );
      debugPrint('INIT: Set up iOS initialization settings');

      // Thiết lập cho tất cả nền tảng
      final InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      // Khởi tạo plugin với thiết lập
      final bool? initializationResult = await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
        onDidReceiveBackgroundNotificationResponse:
            onDidReceiveBackgroundNotificationResponse,
      );

      debugPrint('INIT: Plugin initialization result: $initializationResult');

      // Khởi tạo timezone
      tz.initializeTimeZones();
      debugPrint('INIT: Timezones initialized');

      // Tạo các notification channel cho Android
      if (Platform.isAndroid) {
        await _createNotificationChannels();
      }

      // Yêu cầu quyền sau khi khởi tạo
      if (Platform.isAndroid) {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            _notificationsPlugin.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        final bool? granted =
            await androidImplementation?.requestNotificationsPermission();
        debugPrint(
            'PERMISSIONS: Android notification permissions granted: $granted');
      }

      if (Platform.isIOS) {
        final bool? iosGranted = await _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
              critical: true,
            );
        debugPrint(
            'PERMISSIONS: iOS notification permissions granted: $iosGranted');
      }

      debugPrint(
          'INIT: Notification service initialization completed successfully');
      return true;
    } catch (e) {
      debugPrint('INIT_ERROR: Error initializing notifications: $e');
      return false;
    }
  }

  // Tạo các notification channel cho Android
  static Future<void> _createNotificationChannels() async {
    try {
      // Plugin để tạo channel
      final plugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (plugin == null) {
        debugPrint('Could not resolve AndroidFlutterLocalNotificationsPlugin');
        return;
      }

      // 1. Channel thông báo ưu tiên cao
      final highPriorityChannel = AndroidNotificationChannel(
        highImportanceChannelId,
        'Thông báo quan trọng',
        description:
            'Kênh thông báo chứa các thông báo khẩn cấp và quan trọng.',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        showBadge: true,
      );
      await plugin.createNotificationChannel(highPriorityChannel);

      // 2. Channel mặc định
      final defaultChannel = AndroidNotificationChannel(
        defaultChannelId,
        'Thông báo mặc định',
        description: 'Kênh thông báo mặc định cho các thông báo thông thường.',
        importance: Importance.defaultImportance,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );
      await plugin.createNotificationChannel(defaultChannel);

      // 3. Channel thông báo sự kiện
      final eventChannel = AndroidNotificationChannel(
        eventChannelId,
        'Thông báo sự kiện',
        description: 'Kênh thông báo các sự kiện câu lạc bộ.',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        showBadge: true,
      );
      await plugin.createNotificationChannel(eventChannel);

      // 4. Channel tin nhắn
      final messageChannel = AndroidNotificationChannel(
        messageChannelId,
        'Tin nhắn',
        description: 'Kênh thông báo dành cho tin nhắn.',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );
      await plugin.createNotificationChannel(messageChannel);

      // 5. Channel thông báo không âm thanh
      final silentChannel = AndroidNotificationChannel(
        silentChannelId,
        'Thông báo im lặng',
        description: 'Kênh thông báo không phát âm thanh hay rung.',
        importance: Importance.low,
        playSound: false,
        enableVibration: false,
        showBadge: false,
      );
      await plugin.createNotificationChannel(silentChannel);

      debugPrint('Successfully created all notification channels');
    } catch (e) {
      debugPrint('Error creating notification channels: $e');
    }
  }

  // Xử lý khi nhận được thông báo iOS
  static void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    debugPrint(
        'Received iOS notification: id=$id, title=$title, body=$body, payload=$payload');

    Map<String, dynamic> payloadData = _parsePayload(payload);

    onNotificationClick.add(ReceivedNotification(
      id: id,
      title: title,
      body: body,
      payload: payload,
      type: payloadData['type'],
      targetId: payloadData['id'],
    ));
  }

  // Xử lý khi người dùng nhấp vào thông báo
  static void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) {
    debugPrint(
        'Notification clicked: ${notificationResponse.payload}, actionId: ${notificationResponse.actionId}');

    // Call the tap callback if provided
    if (_onNotificationTap != null && notificationResponse.payload != null) {
      _onNotificationTap!(notificationResponse.payload);
    }

    Map<String, dynamic> payloadData =
        _parsePayload(notificationResponse.payload);

    onNotificationClick.add(ReceivedNotification(
      id: notificationResponse.id ?? 0,
      payload: notificationResponse.payload,
      type: payloadData['type'],
      targetId: payloadData['id'],
    ));
  }

  // Xử lý notification trong background
  @pragma('vm:entry-point')
  static void onDidReceiveBackgroundNotificationResponse(
      NotificationResponse notificationResponse) {
    // Phương thức này sẽ được gọi khi ứng dụng ở trạng thái nền
    // và người dùng nhấp vào thông báo hoặc action button
    // Không thực hiện các tác vụ phức tạp ở đây
  }

  // Parse payload string to map
  static Map<String, dynamic> _parsePayload(String? payload) {
    if (payload == null || payload.isEmpty) return {};

    try {
      // First check if it's valid JSON
      try {
        return jsonDecode(payload) as Map<String, dynamic>;
      } catch (_) {
        // If not JSON, try type:id format
        final parts = payload.split(':');
        if (parts.length == 2) {
          final typeStr = parts[0].trim();
          final idStr = parts[1].trim();

          // Validate type and id
          if (typeStr.isEmpty) {
            debugPrint('Empty notification type in payload');
            return {};
          }

          final id = int.tryParse(idStr);
          if (id == null || id <= 0) {
            debugPrint('Invalid ID in payload: $idStr');
            return {};
          }

          return {
            'type': typeStr,
            'id': id,
          };
        }
      }
    } catch (e) {
      debugPrint('Error parsing payload: $e');
    }
    return {};
  }

  // Hiển thị thông báo cơ bản
  static Future<bool> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String? imageUrl,
    String channelId = highImportanceChannelId,
  }) async {
    try {
      // Validate inputs
      if (title.isEmpty && body.isEmpty) {
        debugPrint('Cannot show notification with empty title and body');
        return false;
      }

      // Sanitize inputs
      final sanitizedTitle = _sanitizeText(title);
      final sanitizedBody = _sanitizeText(body);
      final sanitizedPayload = _sanitizePayload(payload);

      NotificationDetails notificationDetails;

      // Nếu có hình ảnh, tạo thông báo với style BigPicture
      if (imageUrl != null &&
          imageUrl.isNotEmpty &&
          _isValidImagePath(imageUrl)) {
        notificationDetails =
            await _getBigPictureNotificationDetails(channelId, imageUrl);
      } else {
        // Nếu không có hình ảnh, sử dụng thông báo với style BigText
        notificationDetails =
            _getBigTextNotificationDetails(channelId, sanitizedBody);
      }

      // Ghi log rõ ràng
      debugPrint('Showing notification with:');
      debugPrint('  ID: $id');
      debugPrint('  Title: $sanitizedTitle');
      debugPrint('  Body: $sanitizedBody');
      debugPrint('  Payload: $sanitizedPayload');
      debugPrint('  Channel: $channelId');

      // Hiển thị thông báo
      await _notificationsPlugin.show(
        id,
        sanitizedTitle,
        sanitizedBody,
        notificationDetails,
        payload: sanitizedPayload,
      );

      debugPrint('Notification show command executed');
      return true;
    } catch (e) {
      debugPrint('Error showing notification: $e');
      return false;
    }
  }

  // Hiển thị thông báo có nút hành động
  static Future<bool> showActionableNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channelId = highImportanceChannelId,
    List<NotificationAction>? actions,
  }) async {
    try {
      // Sanitize inputs
      final sanitizedTitle = _sanitizeText(title);
      final sanitizedBody = _sanitizeText(body);
      final sanitizedPayload = _sanitizePayload(payload);

      // Tạo thông báo với action buttons
      final notificationDetails =
          _getActionableNotificationDetails(channelId, actions);

      // Hiển thị thông báo
      await _notificationsPlugin.show(
        id,
        sanitizedTitle,
        sanitizedBody,
        notificationDetails,
        payload: sanitizedPayload,
      );

      return true;
    } catch (e) {
      debugPrint('Error showing actionable notification: $e');
      return false;
    }
  }

  // Tạo notification với big text style
  static NotificationDetails _getBigTextNotificationDetails(
      String channelId, String body) {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      channelId,
      _getChannelName(channelId),
      channelDescription: _getChannelDescription(channelId),
      importance: _getChannelImportance(channelId),
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(
        body,
        htmlFormatBigText: true,
        contentTitle: '<b>Thông báo mới</b>',
        htmlFormatContentTitle: true,
        summaryText: 'Thông báo',
        htmlFormatSummaryText: true,
      ),
    );

    final DarwinNotificationDetails iosDetails =
        const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.active,
    );

    return NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  // Tạo notification với big picture style
  static Future<NotificationDetails> _getBigPictureNotificationDetails(
      String channelId, String imageUrl) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      channelId,
      _getChannelName(channelId),
      channelDescription: _getChannelDescription(channelId),
      importance: _getChannelImportance(channelId),
      priority: Priority.high,
      styleInformation: const BigTextStyleInformation(
        'Xem thông báo để biết thêm chi tiết',
        htmlFormatBigText: true,
        contentTitle: 'Thông báo có hình ảnh',
        htmlFormatContentTitle: true,
        summaryText: 'Thông báo',
        htmlFormatSummaryText: true,
      ),
    );

    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      attachments: await _getIOSAttachments(imageUrl),
    );

    return NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  // Tạo notification có actions
  static NotificationDetails _getActionableNotificationDetails(
      String channelId, List<NotificationAction>? actions) {
    // Tạo action buttons cho Android
    List<AndroidNotificationAction> androidActions = [];
    if (actions != null) {
      for (var action in actions) {
        androidActions.add(AndroidNotificationAction(
          action.id,
          action.title,
          contextual: false,
          allowGeneratedReplies: false,
          cancelNotification: action.cancelNotification,
          showsUserInterface: action.showsUserInterface,
        ));
      }
    }

    // Android details
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      channelId,
      _getChannelName(channelId),
      channelDescription: _getChannelDescription(channelId),
      importance: _getChannelImportance(channelId),
      priority: Priority.high,
      actions: androidActions,
    );

    // iOS details
    final DarwinNotificationDetails iosDetails =
        const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'actionable',
    );

    return NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  // Lấy danh sách file đính kèm cho iOS
  static Future<List<DarwinNotificationAttachment>> _getIOSAttachments(
      String imageUrl) async {
    try {
      // Đối với iOS, cần lưu hình ảnh vào một file tạm
      // Đây chỉ là một phương thức giả định, bạn cần implement
      // logic tải hình ảnh và lưu vào file tạm thực tế
      return [];
    } catch (e) {
      debugPrint('Error creating iOS attachments: $e');
      return [];
    }
  }

  // Lấy tên kênh từ ID
  static String _getChannelName(String channelId) {
    switch (channelId) {
      case highImportanceChannelId:
        return 'Thông báo quan trọng';
      case eventChannelId:
        return 'Thông báo sự kiện';
      case messageChannelId:
        return 'Tin nhắn';
      case silentChannelId:
        return 'Thông báo im lặng';
      case defaultChannelId:
      default:
        return 'Thông báo mặc định';
    }
  }

  // Lấy mô tả kênh từ ID
  static String _getChannelDescription(String channelId) {
    switch (channelId) {
      case highImportanceChannelId:
        return 'Kênh thông báo chứa các thông báo khẩn cấp và quan trọng.';
      case eventChannelId:
        return 'Kênh thông báo các sự kiện câu lạc bộ.';
      case messageChannelId:
        return 'Kênh thông báo dành cho tin nhắn.';
      case silentChannelId:
        return 'Kênh thông báo không phát âm thanh hay rung.';
      case defaultChannelId:
      default:
        return 'Kênh thông báo mặc định cho các thông báo thông thường.';
    }
  }

  // Lấy mức độ quan trọng từ ID kênh
  static Importance _getChannelImportance(String channelId) {
    switch (channelId) {
      case highImportanceChannelId:
        return Importance.max;
      case eventChannelId:
      case messageChannelId:
        return Importance.high;
      case silentChannelId:
        return Importance.low;
      case defaultChannelId:
      default:
        return Importance.defaultImportance;
    }
  }

  // Sanitize text to prevent injection
  static String _sanitizeText(String text) {
    // Remove any potentially harmful HTML/script tags
    return text.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  // Sanitize payload
  static String? _sanitizePayload(String? payload) {
    if (payload == null || payload.isEmpty) return null;

    // If it's in the type:id format, validate it
    if (payload.contains(':')) {
      final parts = payload.split(':');
      if (parts.length == 2) {
        final type = _sanitizeText(parts[0]);
        final id = parts[1];

        // Ensure ID is numeric
        if (int.tryParse(id) != null) {
          return '$type:$id';
        }
        return null;
      }
    }

    // If it's JSON, sanitize it
    try {
      final json = jsonDecode(payload);
      if (json is Map) {
        // Only allow certain fields
        final sanitized = <String, dynamic>{};
        final allowedFields = ['type', 'id', 'action'];

        for (final key in allowedFields) {
          if (json.containsKey(key)) {
            sanitized[key] = json[key];
          }
        }

        return jsonEncode(sanitized);
      }
    } catch (_) {
      // Not valid JSON, continue
    }

    // If we can't parse it safely, don't use it
    return null;
  }

  // Validate image path
  static bool _isValidImagePath(String path) {
    // Check for common image extensions
    final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    final hasValidExtension =
        validExtensions.any((ext) => path.toLowerCase().endsWith(ext));

    // Check if it's a file path or URL
    final isFilePath =
        path.startsWith('/') || path.startsWith('./') || path.contains('\\');
    final isUrl = path.startsWith('http://') || path.startsWith('https://');

    return (isFilePath || isUrl) && hasValidExtension;
  }

  // Hủy tất cả thông báo
  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  // Hủy một thông báo cụ thể
  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  // Lên lịch thông báo
  static Future<bool> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    String channelId = highImportanceChannelId,
  }) async {
    try {
      // Validate inputs
      if (title.isEmpty || body.isEmpty) {
        debugPrint('Cannot schedule notification with empty title or body');
        return false;
      }

      if (scheduledDate.isBefore(DateTime.now())) {
        debugPrint('Cannot schedule notification in the past');
        return false;
      }

      // Sanitize inputs
      final sanitizedTitle = _sanitizeText(title);
      final sanitizedBody = _sanitizeText(body);
      final sanitizedPayload = _sanitizePayload(payload);

      // Tạo notification details
      final notificationDetails =
          _getBigTextNotificationDetails(channelId, sanitizedBody);

      // Lên lịch thông báo
      await _notificationsPlugin.zonedSchedule(
        id,
        sanitizedTitle,
        sanitizedBody,
        tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: sanitizedPayload,
      );

      debugPrint('Scheduled notification for ${scheduledDate.toString()}');
      return true;
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
      return false;
    }
  }
}

// Lớp để định nghĩa action trong thông báo
class NotificationAction {
  final String id;
  final String title;
  final String? icon;
  final bool cancelNotification;
  final bool showsUserInterface;

  const NotificationAction({
    required this.id,
    required this.title,
    this.icon,
    this.cancelNotification = false,
    this.showsUserInterface = true,
  });
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/notification_provider.dart';
import 'services/local_notification_service.dart';
import 'services/AuthService.dart';
import 'services/NotificationService.dart';

void main() async {
  // Catch all errors in main to prevent crashes
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Khởi tạo dữ liệu locale cho định dạng ngày tháng
    await initializeDateFormatting('vi_VN', null);

    // Khởi tạo notification providers
    final notificationProvider = NotificationProvider();

    // Thiết lập service thông báo mà không cần FCM
    final notificationService = NotificationService();

    // Khôi phục token và đặt vào provider
    final String? token = await AuthService.getToken();
    if (token != null && token.isNotEmpty) {
      debugPrint('Found saved token, setting to notification provider');
      notificationProvider.setAuthToken(token);
    } else {
      debugPrint('No saved token found');
    }

    try {
      debugPrint('Initializing notification services...');

      // Khởi tạo local notification service
      final bool localNotificationInitialized =
          await LocalNotificationService.init(
        onNotificationTap: (String? payload) {
          // Validate payload before processing
          if (payload == null || payload.isEmpty) {
            debugPrint('Empty payload received from notification tap');
            return;
          }

          try {
            // Xử lý khi người dùng nhấp vào thông báo
            // Đảm bảo dẫn đến HomeScreen trước, sau đó mới xử lý deeplink
            // Điều này đảm bảo rằng HomeScreen sẽ được mở đầu tiên
            Future.microtask(() {
              // Điều hướng đến HomeScreen trước
              if (notificationProvider.navigatorKey.currentContext != null) {
                Navigator.of(notificationProvider.navigatorKey.currentContext!,
                        rootNavigator: true)
                    .pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);

                // Sau đó xử lý deeplink để điều hướng chi tiết
                Future.delayed(Duration(milliseconds: 300), () {
                  notificationProvider.handleDeepLink(payload);
                });
              } else {
                // Fallback nếu không có context
                notificationProvider.handleDeepLink(payload);
              }
            });
          } catch (e) {
            debugPrint('Error handling notification tap: $e');
          }
        },
      );

      if (!localNotificationInitialized) {
        debugPrint('Failed to initialize local notification service');
      } else {
        debugPrint('Local notification service initialized successfully');
      }

      // Chủ động kiểm tra thông báo mới khi ứng dụng bắt đầu
      if (token != null && token.isNotEmpty) {
        // Đợi một chút để cho ứng dụng khởi tạo xong
        Future.delayed(Duration(seconds: 2), () {
          notificationProvider.checkForNewNotifications();
          debugPrint('Initial notifications check triggered');
        });
      }
    } catch (e) {
      debugPrint('Error in notification setup: $e');
    }

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: notificationProvider),
        ],
        child: MyApp(),
      ),
    );
  } catch (e) {
    debugPrint('Fatal error in main: $e');
    // Show some UI to the user or attempt recovery
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Fatal error occurred: $e'),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);

    return MaterialApp(
      navigatorKey: notificationProvider.navigatorKey,
      title: 'Club Management',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import './ApiService.dart';

class AuthService {
  static const String _resource = '/auth';
  static String get baseUrl =>
      ApiService.BASE_HOST + ApiService.API_PREFIX + _resource;

  // Hàm gọi API đăng ký
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String password_confirmation,
    required String phone,
    String? username,
  }) async {
    return await ApiService.post(
      '$baseUrl/register',
      body: {
        'email': email,
        'password': password,
        'password_confirmation': password_confirmation,
        'phone': phone,
        if (username != null) 'username': username,
      },
    );
  }

  static Future<Map<String, dynamic>> verify({
    required String email,
    required String otp,
  }) async {
    return await ApiService.post(
      '$baseUrl/verify-email',
      body: {
        'email': email,
        'otp': otp,
      },
    );
  }

  // Đăng nhập và trả về dữ liệu từ server
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    return await ApiService.post(
      '$baseUrl/login',
      body: {
        'email': email,
        'password': password,
      },
    );
  }

  // Lưu thông tin user và token (giả định dùng SharedPreferences)
  static Future<void> saveUserData(String token, dynamic user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
    await prefs.setString('user', jsonEncode(user));
    print('Token saved: $token');
    print('User saved: $user');

    // Đồng bộ token với ApiService
    ApiService.setAuthToken(token);
  }

  // Lấy token đã lưu
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    // Đồng bộ token với ApiService
    if (token != null && token.isNotEmpty) {
      ApiService.setAuthToken(token);
    }

    return token;
  }

  // Đăng xuất
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('user');

    // Xóa token trong ApiService
    ApiService.clearAuthToken();
  }

  static Future<Map<String, dynamic>> sendResetLink(String email) async {
    try {
      final response = await ApiService.post(
        '$baseUrl/forgotpass',
        body: {'email': email},
      );

      return {
        'success': true,
        'message': response['message'] ?? 'Yêu cầu đã được gửi',
        'statusCode': 200,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Không thể kết nối đến server: $e',
        'statusCode': 500,
      };
    }
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final response = await ApiService.post(
        '$baseUrl/reset-password',
        body: {
          'email': email,
          'otp': otp,
          'new_password': newPassword,
          'new_password_confirmation': newPasswordConfirmation,
        },
      );

      return {
        'success': true,
        'message': response['message'] ?? 'Mật khẩu đã được đặt lại',
        'statusCode': 200,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Không thể kết nối đến server: $e',
        'statusCode': 500,
      };
    }
  }
}

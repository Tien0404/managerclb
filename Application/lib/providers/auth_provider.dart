import 'package:flutter/foundation.dart';

class User {
  final int id;
  final String username;
  final String email;
  final String? avatar;
  final String? role;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.avatar,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatar': avatar,
      'role': role,
    };
  }
}

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  // Đăng nhập
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // TODO: Implement actual login API call
      // For now, we'll simulate a successful login
      await Future.delayed(const Duration(seconds: 1));

      _user = User(
        id: 1,
        username: 'Test User',
        email: email,
        role: 'user',
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Đăng xuất
  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      // TODO: Implement actual logout API call
      await Future.delayed(const Duration(seconds: 1));

      _user = null;
      _error = null;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Kiểm tra trạng thái đăng nhập
  Future<void> checkAuthStatus() async {
    try {
      _isLoading = true;
      notifyListeners();

      // TODO: Implement actual auth status check
      // For now, we'll simulate checking auth status
      await Future.delayed(const Duration(seconds: 1));

      // Simulate user is not logged in
      _user = null;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cập nhật thông tin người dùng
  Future<void> updateUserProfile(User updatedUser) async {
    try {
      _isLoading = true;
      notifyListeners();

      // TODO: Implement actual profile update API call
      await Future.delayed(const Duration(seconds: 1));

      _user = updatedUser;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}

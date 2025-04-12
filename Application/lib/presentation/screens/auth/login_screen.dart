import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_drawer.dart';
import '../../../services/AuthService.dart'; // Import AuthService
import '../../../providers/notification_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key}); // Thêm constructor với key

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login(BuildContext context) async {
    // Thêm Future<void> để rõ ràng hơn
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final email =
        _emailController.text.trim(); // Thêm trim() để loại bỏ khoảng trắng
    final password = _passwordController.text;

    try {
      final response = await AuthService.login(email, password);

      // Kiểm tra response có null không
      if (response == null ||
          response['access_token'] == null ||
          response['user'] == null) {
        throw Exception('Phản hồi từ server không hợp lệ');
      }

      final String token = response['access_token'];

      // Lưu token và user data
      await AuthService.saveUserData(token, response['user']);

      // Set token cho NotificationProvider
      if (!mounted) return;
      final notificationProvider =
          Provider.of<NotificationProvider>(context, listen: false);
      notificationProvider.setAuthToken(token);

      if (!mounted)
        return; // Kiểm tra widget còn mounted không trước khi navigate
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return; // Kiểm tra mounted trước khi show SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đăng nhập thất bại: ${e.toString()}'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3), // Thêm thời gian hiển thị
        ),
      );
    } finally {
      if (mounted) {
        // Kiểm tra mounted trước khi setState
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(), // Thêm const nếu CustomAppBar không thay đổi
      endDrawer: CustomDrawer(), // Thêm const nếu CustomDrawer không thay đổi
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: SizedBox(
                      // Thay Container bằng SizedBox để tối ưu hơn
                      width: 150,
                      height: 150,
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Đăng nhập',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      'Chào mừng bạn quay trở lại!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Email field
                  _buildInputField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        // Thêm trim()
                        return 'Vui lòng nhập email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Email không hợp lệ';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  _buildInputField(
                    controller: _passwordController,
                    label: 'Mật khẩu',
                    icon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        // Thêm trim()
                        return 'Vui lòng nhập mật khẩu';
                      }
                      if (value.length < 6) {
                        // Thêm kiểm tra độ dài tối thiểu
                        return 'Mật khẩu phải có ít nhất 6 ký tự';
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Remember me and Forgot password
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false; // Xử lý null safety
                          });
                        },
                        activeColor: Colors.blue.shade600,
                      ),
                      Text(
                        'Ghi nhớ tôi',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                              context, '/reset-mail'); // Thêm route thực tế
                        },
                        child: Text(
                          'Quên mật khẩu?',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Login button
                  GestureDetector(
                    onTap: _isLoading ? null : () => _login(context),
                    child: Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade400, Colors.blue.shade700],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.shade200,
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                'Đăng nhập',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Bạn chưa có tài khoản?',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/register');
                        },
                        child: Text(
                          'Đăng ký',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: Colors.blue.shade600, size: 20),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade400, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade300, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }
}

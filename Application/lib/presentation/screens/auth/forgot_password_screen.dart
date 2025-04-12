import 'package:flutter/material.dart';
import '../../../services/AuthService.dart'; // Đường dẫn đến AuthService

class PasswordRecoveryScreen extends StatefulWidget {
  @override
  _PasswordRecoveryScreenState createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoadingSend = false; // Loading cho gửi mã OTP
  bool _isLoadingReset = false; // Loading cho đặt lại mật khẩu
  bool _isOtpSent = false; // Kiểm tra xem mã OTP đã được gửi chưa

  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Gửi yêu cầu gửi mã OTP
  void _sendOtp() async {
    final email = _emailController.text.trim();

    if (email.isEmpty || !_isValidEmail(email)) {
      _showSnackBar('Vui lòng nhập email hợp lệ', Colors.red.shade400);
      return;
    }

    setState(() {
      _isLoadingSend = true;
    });

    final result = await AuthService.sendResetLink(email);

    setState(() {
      _isLoadingSend = false;
    });

    if (result['success']) {
      setState(() {
        _isOtpSent = true; // Hiển thị các trường OTP và mật khẩu
      });
      _showSnackBar(result['message'], Colors.green.shade400);
    } else {
      _showSnackBar(result['message'], Colors.red.shade400);
    }
  }

  // Gửi yêu cầu đặt lại mật khẩu
  void _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoadingReset = true;
    });

    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    final result = await AuthService.resetPassword(
      email: email,
      otp: otp,
      newPassword: newPassword,
      newPasswordConfirmation: confirmPassword,
    );

    setState(() {
      _isLoadingReset = false;
    });

    if (result['success']) {
      _showSnackBar(result['message'], Colors.green.shade400);
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      _showSnackBar(result['message'], Colors.red.shade400);
    }
  }

  // Kiểm tra định dạng email
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Hiển thị SnackBar
  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Khôi phục mật khẩu'),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Center(
                    child: Container(
                      width: 150,
                      height: 150,
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Khôi phục mật khẩu',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Nhập email để nhận mã OTP và đặt lại mật khẩu',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.email_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Vui lòng nhập email';
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Email không hợp lệ';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: _isLoadingSend ? null : _sendOtp,
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade700,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _isLoadingSend
                              ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : Icon(Icons.send, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                  if (_isOtpSent) ...[
                    SizedBox(height: 20),
                    _buildInputField(
                      controller: _otpController,
                      label: 'Mã OTP',
                      icon: Icons.lock_clock,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Vui lòng nhập mã OTP';
                        if (!RegExp(r'^\d{6}$').hasMatch(value)) return 'Mã OTP phải là 6 chữ số';
                        return null;
                      },
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16),
                    _buildInputField(
                      controller: _newPasswordController,
                      label: 'Mật khẩu mới',
                      icon: Icons.lock_outline,
                      obscureText: _obscureNewPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu mới';
                        if (value.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
                        return null;
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildInputField(
                      controller: _confirmPasswordController,
                      label: 'Xác nhận mật khẩu mới',
                      icon: Icons.lock_outline,
                      obscureText: _obscureConfirmPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Vui lòng xác nhận mật khẩu';
                        if (value != _newPasswordController.text) return 'Mật khẩu không khớp';
                        return null;
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                    ),
                    SizedBox(height: 30),
                    GestureDetector(
                      onTap: _isLoadingReset ? null : _resetPassword,
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
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isLoadingReset
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                            'Đặt lại mật khẩu',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Quay lại đăng nhập',
                        style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
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
          BoxShadow(color: Colors.grey.shade200, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade700, fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.blue.shade600, size: 20),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }
}
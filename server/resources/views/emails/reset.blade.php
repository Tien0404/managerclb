<!DOCTYPE html>
<html>
<head>
    <title>Đặt Lại Mật Khẩu</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
        }
        .otp-container {
            background-color: #f8f9fa;
            border-radius: 5px;
            padding: 20px;
            margin: 20px 0;
            text-align: center;
        }
        .otp-code {
            font-size: 32px;
            font-weight: bold;
            color: #0066cc;
            letter-spacing: 5px;
            margin: 10px 0;
        }
        .warning {
            color: #dc3545;
            font-size: 14px;
            margin-top: 15px;
        }
    </style>
</head>
<body>
    <h1>Đặt Lại Mật Khẩu</h1>
    <p>Xin chào,</p>
    <p>Chúng tôi đã nhận được yêu cầu đặt lại mật khẩu cho tài khoản của bạn. Vui lòng sử dụng mã OTP dưới đây để đặt lại mật khẩu:</p>
    
    <div class="otp-container">
        <p>Mã OTP của bạn là:</p>
        <div class="otp-code">{{ $user->resetPasswordToken }}</div>
    </div>

    <p>Mã OTP này sẽ hết hạn sau 60 phút.</p>
    
    <p class="warning">Lưu ý: Không chia sẻ mã OTP này với bất kỳ ai để bảo vệ tài khoản của bạn.</p>
    
    <p>Nếu bạn không yêu cầu đặt lại mật khẩu, vui lòng bỏ qua email này.</p>
    
    <p>Trân trọng,<br>CLB Management Team</p>
</body>
</html>
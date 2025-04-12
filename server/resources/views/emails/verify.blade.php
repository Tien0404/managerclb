<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Xác thực Email của bạn</title>
</head>
<body style="margin: 0; padding: 20px; background-color: #f4f4f4; font-family: Arial, sans-serif;">
    <div style="max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 8px; padding: 30px; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);">
        <div style="text-align: center; margin-bottom: 30px;">
            <h1 style="color: #333; margin: 0; font-size: 24px;">Xác thực Email của bạn</h1>
        </div>

        <div style="margin-bottom: 30px;">
            <p style="color: #666; font-size: 16px; line-height: 1.5; margin: 0 0 20px;">Xin chào,</p>
            <p style="color: #666; font-size: 16px; line-height: 1.5; margin: 0 0 20px;">Cảm ơn bạn đã đăng ký tài khoản. Để hoàn tất quá trình đăng ký, vui lòng sử dụng mã xác thực sau:</p>
        </div>

        <div style="background-color: #f8f9fa; border-radius: 6px; padding: 20px; text-align: center; margin-bottom: 30px;">
            <h2 style="color: #333; font-size: 32px; letter-spacing: 5px; margin: 0;">{{ $user->verification_token }}</h2>
        </div>

        <div style="margin-bottom: 30px;">
            <p style="color: #666; font-size: 14px; line-height: 1.5; margin: 0;">Mã xác thực này sẽ hết hạn sau 10 phút. Vui lòng không chia sẻ mã này với bất kỳ ai.</p>
        </div>

        <div style="border-top: 1px solid #eee; padding-top: 20px;">
            <p style="color: #999; font-size: 12px; margin: 0;">Email này được gửi tự động. Vui lòng không trả lời email này.</p>
            <p style="color: #999; font-size: 12px; margin: 5px 0 0;">Nếu bạn không yêu cầu xác thực email này, vui lòng bỏ qua email này.</p>
        </div>
    </div>
</body>
</html>
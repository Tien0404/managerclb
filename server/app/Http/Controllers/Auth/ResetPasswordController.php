<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class ResetPasswordController extends Controller
{
    public function resetPassword(Request $request)
    {
        // Kiểm tra đầu vào
        $request->validate([
            'email' => 'required|email',
            'otp' => 'required|numeric',
            'new_password' => 'required|min:6|confirmed'
        ]);

        // Tìm người dùng theo email
        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return response()->json(['message' => 'Email không tồn tại.'], 404);
        }

        // Kiểm tra mã OTP
        if ($user->resetPasswordToken != $request->otp) {
            return response()->json(['message' => 'Mã OTP không chính xác.'], 400);
        }

        // Kiểm tra thời gian hết hạn
        if (now()->gt($user->resetPasswordExpires)) {
            return response()->json(['message' => 'Mã OTP đã hết hạn.'], 400);
        }

        // Đặt lại mật khẩu mới
        $user->password = Hash::make($request->new_password);
        $user->resetPasswordToken = null;
        $user->resetPasswordExpires = null;
        $user->save();

        return response()->json(['message' => 'Mật khẩu đã được đặt lại thành công.']);
    }
}

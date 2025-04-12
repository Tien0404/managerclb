<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;

class VerificationController extends Controller
{
    public function verify(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'otp' => 'required|digits:6',
        ]);

        $user = User::where('email', $request->email)
                    ->where('verification_token', $request->otp)
                    ->first();

        if (!$user) {
            return response()->json(['message' => 'Invalid OTP or email. Please try again.'], 400);
        }

        $user->email_verified = true;
        $user->verification_token = null;
        $user->save();

        return response()->json(['message' => 'Email verified successfully. You can now log in.']);
    }
} 
<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Str;

class ForgotPasswordController extends Controller
{
    public function sendResetLinkEmail(Request $request)
    {
        $request->validate(['email' => 'required|email']);

        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return response()->json(['message' => 'Email not found.'], 404);
        }

        $user->resetPasswordToken = random_int(100000, 999999);
        $user->resetPasswordExpires = now()->addMinutes(10);
        $user->save();

        // Send reset email
        Mail::to($user->email)->send(new \App\Mail\ResetPassword($user));

        return response()->json(['message' => 'Password reset link sent.']);
    }
} 
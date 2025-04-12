<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;

class RegisterController extends Controller
{
    public function register(Request $request)
    {
        $request->validate([
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:8|confirmed',
            'phone' => 'required|string|unique:users,phone',
        ]);

        $verificationCode = random_int(100000, 999999);

        $user = User::create([
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'username' => $request->username ?? 'default_username',
            'phone' => $request->phone,
            'verification_token' => $verificationCode,
        ]);

        Mail::to($user->email)->send(new \App\Mail\VerifyEmail($user));

        return response()->json(['message' => 'Registration successful. Please check your email for the verification code.']);
    }
}
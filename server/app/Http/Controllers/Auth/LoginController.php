<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class LoginController extends Controller
{
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        $credentials = $request->only('email', 'password');

        if (Auth::attempt($credentials)) {
            $user = Auth::user()->load('backgroundImages'); // Load backgroundImages

            if (!$user->email_verified) {
                Auth::logout();
                return response()->json(['message' => 'Please verify your email before logging in.'], 403);
            }

            // Create a token for the user
            $token = $user->createToken('auth_token')->plainTextToken;

            return response()->json([
                'message' => 'Login successful. Welcome back!',
                'access_token' => $token,
                'token_type' => 'Bearer',
                'user' => $user->only([
                    'id',
                    'username',
                    'email',
                    'phone',
                    'gender',
                    'description',
                    'role',
                    'resetPasswordToken',
                    'resetPasswordExpires',
                    'email_verified',
                    'created_at',
                    'updated_at',
                    'backgroundImages'
                ]),
            ]);
        }

        return response()->json(['message' => 'Invalid credentials. Please check your email and password.'], 401);
    }
}

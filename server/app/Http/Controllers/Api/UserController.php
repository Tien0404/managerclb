<?php

namespace App\Http\Controllers\Api;

use App\Models\User;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class UserController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        return User::orderBy('id', 'desc')->get();
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        $request->validate([
            'username' => 'required|string|max:255',
            'password' => 'required|string|min:8',
            'email' => 'required|email|unique:users,email',
            'phone' => 'nullable|string|max:15|unique:users,phone',
        ]);

        $user = User::create([
            'username' => $request->username,
            'password' => Hash::make($request->password),
            'email' => $request->email,
            'phone' => $request->phone,
        ]);

        return response()->json($user, 201);
    }

    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function show(User $user)
    {
        return response()->json($user->load('clubs', 'events', 'backgroundImages'));
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, User $user)
    {
        // Get all request data except files
        $data = $request->all();
        
        // Remove file fields from data array
        unset($data['avatar']);

        // Validate basic data
        $validatedData = validator($data, [
            'username' => 'sometimes|string|max:255|unique:users,username,' . $user->id,
            'password' => 'sometimes|string|min:8',
            'email' => 'sometimes|email|unique:users,email,' . $user->id,
            'phone' => 'nullable|string|max:15',
            'gender' => 'nullable|string|in:male,female,other',
            'description' => 'nullable|string',
        ])->validate();

        // Update password if provided
        if ($request->has('password')) {
            $validatedData['password'] = Hash::make($request->password);
        }

        // Update basic user data
        $user->update($validatedData);

        // Handle avatar upload
        if ($request->hasFile('avatar')) {
            // Delete existing avatar if exists
            $existingAvatar = $user->backgroundImages()
                ->where('is_logo', 1)
                ->first();
            
            if ($existingAvatar) {
                $existingAvatar->deleteImage();
                $existingAvatar->delete();
            }

            // Upload new avatar
            $backgroundImage = new \App\Models\BackgroundImage();
            $backgroundImage->user_id = $user->id;
            $backgroundImage->is_logo = 1; // Đánh dấu là ảnh đại diện
            $backgroundImage->uploadImage($request->file('avatar'));
        }

        return response()->json($user->load('backgroundImages'));
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function destroy(User $user)
    {
        $user->delete();

        return response()->json(null, 204);
    }
}

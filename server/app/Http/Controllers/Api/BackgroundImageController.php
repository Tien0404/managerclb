<?php

namespace App\Http\Controllers\Api;
use App\Models\BackgroundImage;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
class BackgroundImageController extends Controller
{
    public function index()
    {
        $backgroundImages = BackgroundImage::all();
        return response()->json($backgroundImages, 200);
    }

    public function show($id)
    {
        $backgroundImage = BackgroundImage::findOrFail($id);
        return response()->json($backgroundImage, 200);
    }

    public function uploadImage(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'image' => 'required|image|mimes:jpeg,png,jpg,gif',
            'club_id' => 'nullable|exists:clubs,id',
            'event_id' => 'nullable|exists:events,id',
            'user_id' => 'nullable|exists:users,id',
            'blog_id' => 'nullable|exists:blogs,id',
            'is_logo' => 'nullable|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $backgroundImage = new BackgroundImage();
        $backgroundImage->club_id = $request->club_id;
        $backgroundImage->event_id = $request->event_id;
        $backgroundImage->user_id = $request->user_id;
        $backgroundImage->blog_id = $request->blog_id;
        $backgroundImage->is_logo = $request->is_logo ?? false;
        $backgroundImage->uploadImage($request->file('image'));

        return response()->json($backgroundImage, 201);
    }

    public function uploadVideo(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'video' => 'required|mimes:mp4,mov,avi,wmv',
            'club_id' => 'nullable|exists:clubs,id',
            'event_id' => 'nullable|exists:events,id',
            'user_id' => 'nullable|exists:users,id',
            'blog_id' => 'nullable|exists:blogs,id',
            'is_logo' => 'nullable|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $backgroundImage = new BackgroundImage();
        $backgroundImage->club_id = $request->club_id;
        $backgroundImage->event_id = $request->event_id;
        $backgroundImage->user_id = $request->user_id;
        $backgroundImage->blog_id = $request->blog_id;
        $backgroundImage->uploadVideo($request->file('video'));
        $backgroundImage->is_logo = $request->is_logo ?? false;
        return response()->json($backgroundImage, 201);
    }

    public function update(Request $request, $id)
    {
        $backgroundImage = BackgroundImage::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif',
            'video' => 'nullable|mimes:mp4,mov,avi,wmv',
            'club_id' => 'nullable|exists:clubs,id',
            'event_id' => 'nullable|exists:events,id',
            'user_id' => 'nullable|exists:users,id',
            'blog_id' => 'nullable|exists:blogs,id',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        if ($request->hasFile('image')) {
            $backgroundImage->deleteImage();
            $backgroundImage->uploadImage($request->file('image'));
        }

        if ($request->hasFile('video')) {
            $backgroundImage->deleteVideo();
            $backgroundImage->uploadVideo($request->file('video'));
        }

        if ($request->has('club_id')) {
            $backgroundImage->club_id = $request->club_id;
        }

        if ($request->has('event_id')) {
            $backgroundImage->event_id = $request->event_id;
        }

        $backgroundImage->save();

        return response()->json($backgroundImage, 200);
    }

    public function deleteImage($id)
    {
        $backgroundImage = BackgroundImage::findOrFail($id);
        $backgroundImage->deleteImage();
        return response()->json(['message' => 'Image deleted successfully.']);
    }

    public function deleteVideo($id)
    {
        $backgroundImage = BackgroundImage::findOrFail($id);
        $backgroundImage->deleteVideo();
        return response()->json(['message' => 'Video deleted successfully.']);
    }
}

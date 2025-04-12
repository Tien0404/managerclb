<?php

namespace App\Http\Controllers\Api;

use App\Notify\BlogCreated;
use App\Models\Blog;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class BlogController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        return Blog::with([
            'club.backgroundImages' => function ($query) {
                $query->where('is_logo', 1);
            },
            'category',
            'backgroundImages'
        ])->orderBy('id', 'desc')->get();
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
            'title' => 'required|string|max:255',
            'club_id' => 'required|exists:clubs,id',
            'description' => 'nullable|string',
            'category_id' => 'required|exists:categories,id',
            'view_count' => 'integer',
            'content' => 'required|string',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif'
        ]);

        $blogData = $request->except('image');
        $blog = Blog::create($blogData);

        // Handle single image upload if present
        if ($request->hasFile('image')) {
            $backgroundImage = new \App\Models\BackgroundImage();
            $backgroundImage->blog_id = $blog->id;
            $backgroundImage->uploadImage($request->file('image'));
        }

        // Dispatch event
        event(new BlogCreated($blog));

        return response()->json($blog->load(['club', 'category', 'backgroundImages']), 201);
    }

    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function show(Blog $blog)
    {
        return response()->json($blog->load('club', 'category', 'backgroundImages'));
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, Blog $blog)
    {
        // Get all request data except files
        $data = $request->all();

        // Remove file fields from data array
        unset($data['image']);

        // Validate basic data
        $validatedData = validator($data, [
            'title' => 'sometimes|required|string|max:255',
            'club_id' => 'sometimes|required|exists:clubs,id',
            'description' => 'nullable|string',
            'category_id' => 'sometimes|required|exists:categories,id',
            'view_count' => 'sometimes|integer',
            'content' => 'sometimes|required|string',
            'status' => 'nullable|string|in:active,inactive',
        ])->validate();

        // Update basic blog data
        $blog->update($validatedData);

        // Handle single image upload
        if ($request->hasFile('image')) {
            // Delete existing image if exists
            $existingImage = $blog->backgroundImages()->first();
            if ($existingImage) {
                $existingImage->deleteImage();
                $existingImage->delete();
            }

            // Upload new image
            $backgroundImage = new \App\Models\BackgroundImage();
            $backgroundImage->blog_id = $blog->id;
            $backgroundImage->uploadImage($request->file('image'));
        }

        return response()->json($blog->load(['club', 'category', 'backgroundImages']));
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function destroy(Blog $blog)
    {
        $blog->delete();

        return response()->json(null, 204);
    }

    /**
     * Get all blogs by club id
     *
     * @param  int  $club_id
     * @return \Illuminate\Http\Response
     */
    public function getClubBlogs($club_id)
    {
        $blogs = Blog::where('club_id', $club_id)
            ->with(['club', 'category', 'backgroundImages'])
            ->get();

        return response()->json($blogs);
    }
}

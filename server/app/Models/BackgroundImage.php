<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Cloudinary\Cloudinary;

class BackgroundImage extends Model
{
    use HasFactory;
    public $timestamps = false;
    protected $fillable = [
        'user_id',
        'club_id',
        'event_id',
        'blog_id',
        'image_url',
        'video_url',
        'is_logo',
    ];
    protected $cloudinary;

    public function __construct(array $attributes = [])
    {
        parent::__construct($attributes);
        $this->cloudinary = new Cloudinary(); 
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function club()
    {
        return $this->belongsTo(Club::class);
    }

    public function event()
    {
        return $this->belongsTo(Event::class);
    }

    public function blog()
    {
        return $this->belongsTo(Blog::class);
    }

    public function uploadImage($file)
    {
        $uploadedFileUrl = $this->cloudinary->uploadApi()->upload($file->getRealPath(), [
            'folder' => 'images',
        ]);
        $this->image_url = $uploadedFileUrl['secure_url'];
        $this->save();
    }

    public function uploadVideo($file)
    {
        $uploadedFileUrl = $this->cloudinary->uploadApi()->upload($file->getRealPath(), [
            'resource_type' => 'video',
            'folder' => 'videos',
        ]);
        $this->video_url = $uploadedFileUrl['secure_url'];
        $this->save();
    }

    public function deleteImage()
    {
        if ($this->image_url) {
            $publicId = $this->getPublicIdFromUrl($this->image_url);
            $this->cloudinary->uploadApi()->destroy($publicId, [
                'resource_type' => 'image',
            ]);
            $this->image_url = null;
            $this->save();
        }
    }

    public function deleteVideo()
    {
        if ($this->video_url) {
            $publicId = $this->getPublicIdFromUrl($this->video_url);
            $this->cloudinary->uploadApi()->destroy($publicId, [
                'resource_type' => 'video',
            ]);
            $this->video_url = null;
            $this->save();
        }
    }

    private function getPublicIdFromUrl($url)
    {
        $parts = explode('/', $url);
        return str_replace(['https://res.cloudinary.com/dr3oy6b74/image/upload/', 'https://res.cloudinary.com/dr3oy6b74/video/upload/'], '', $parts[count($parts) - 1]);
    }
}
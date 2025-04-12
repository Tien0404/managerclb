<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Blog extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'club_id',
        'category_id',
        'content',
        'status',
    ];

    public function club()
    {
        return $this->belongsTo(Club::class, 'club_id');
    }

    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function backgroundImages()
    {
        return $this->hasMany(BackgroundImage::class);
    }
}
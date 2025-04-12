<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Event extends Model
{
    use HasFactory;
    
    public $timestamps = false;
    
    protected $fillable = [
        'club_id',
        'category_id',
        'name',
        'start_date',
        'end_date',
        'location',
        'max_participants',
        'registered_participants',
        'content',
        'status'
    ];

    public function club()
    {
        return $this->belongsTo(Club::class);
    }

    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function joinRequests()
    {
        return $this->hasMany(JoinRequest::class);
    }

    public function backgroundImages()
    {
        return $this->hasMany(BackgroundImage::class);
    }

    public function users()
    {
        return $this->belongsToMany(User::class);
    }
}
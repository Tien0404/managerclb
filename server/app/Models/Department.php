<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Department extends Model
{
    use HasFactory;
    public $timestamps = false;
    protected $fillable = [
        'club_id',
        'user_id',
        'name',
        'description',
        'manage_blogs',
        'manage_clubs',
        'manage_events',
        'manage_members',
        'manage_feedback'
    ];
    public function user()
    {
        return $this->belongsTo(User::class);
    }
    public function club()
    {
        return $this->belongsTo(Club::class);
    }
}
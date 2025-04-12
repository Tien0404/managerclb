<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Feedback extends Model
{
    use HasFactory;

    protected $fillable = [
        'club_id',
        'name',
        'email',
        'mobile',
        'comment',
        'club_response',
        'status',
        'created_at',
    ];

    public function club()
    {
        return $this->belongsTo(Club::class);
    }
}
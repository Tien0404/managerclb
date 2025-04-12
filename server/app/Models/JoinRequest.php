<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class JoinRequest extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'club_id',
        'event_id',
        'type',
        'status',
        'message',
        'response_message',
        'responded_at',
    ];

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
}
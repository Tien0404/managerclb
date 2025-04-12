<?php

namespace App\Models;

use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable implements MustVerifyEmail
{
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'username',
        'password',
        'email',
        'phone',
        'gender',
        'description',
        'role',
        'resetPasswordToken',
        'resetPasswordExpires',
        'email_verified',
        'verification_token'
    ];

    protected $attributes = [
        'role' => 'User',
        'email_verified' => false
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'email_verified' => 'boolean',
        'resetPasswordExpires' => 'datetime'
    ];

    /**
     * Get the notifications for the user.
     */
    public function notifications()
    {
        return $this->hasMany(Notification::class, 'notifiable_id');
    }

    public function clubs()
    {
        return $this->hasMany(Club::class);
    }

    public function feedbacks()
    {
        return $this->hasMany(Feedback::class);
    }

    public function joinRequests()
    {
        return $this->hasMany(JoinRequest::class);
    }

    public function backgroundImages()
    {
        return $this->hasMany(BackgroundImage::class);
    }

    public function events()
    {
        return $this->hasManyThrough(Event::class, JoinRequest::class, 'user_id', 'id', 'id', 'event_id')
            ->where('join_requests.type', 'event')
            ->where('join_requests.status', 'approved');
    }

    public function departments()
    {
        return $this->hasMany(Department::class);
    }
}

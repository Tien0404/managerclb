<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Category extends Model
{
    use HasFactory;
    public $timestamps = false;
    protected $fillable = [
        'name',
        'description',
        'type',
        'status',
    ];
    protected $attributes = [
        'status' => 'active', 
    ];
    public function clubs()
    {
        return $this->hasMany(Club::class);
    }

    public function events()
    {
        return $this->hasMany(Event::class);
    }

    public function blogs()
    {
        return $this->hasMany(Blog::class);
    }
}
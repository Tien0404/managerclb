<?php

namespace App\Notify;

use App\Models\Blog;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class BlogCreated implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $blog;

    public function __construct(Blog $blog)
    {
        $this->blog = $blog;
    }

    public function broadcastOn()
    {
        return new Channel('blogs');
    }
} 
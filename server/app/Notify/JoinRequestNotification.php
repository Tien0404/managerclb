<?php

namespace App\Notify;

use App\Models\JoinRequest;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class JoinRequestNotification implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $joinRequest;

    public function __construct(JoinRequest $joinRequest)
    {
        $this->joinRequest = $joinRequest;
    }

    public function broadcastOn()
    {
        return new Channel('join-requests');
    }
} 
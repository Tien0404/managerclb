<?php

namespace App\Notify;

use App\Notify\EventCreated;
use App\Models\Event;
use App\Models\Notification;
use App\Models\JoinRequest;
use Illuminate\Contracts\Queue\ShouldQueue;

class SendEventCreatedNotification implements ShouldQueue
{
    public function handle(EventCreated $event)
    {
        $event = $event->event;
        $club = $event->club;

        // Lấy danh sách các thành viên đã được chấp nhận
        $approvedMembers = JoinRequest::where('club_id', $club->id)
            ->where('type', 'club')
            ->where('status', 'approved')
            ->with('user')
            ->get();

        // Tạo thông báo cho từng thành viên
        foreach ($approvedMembers as $member) {
            $notification = new Notification();
            $notification->notifiable_id = $member->user_id;
            $notification->data = [
                'notification_type' => 'new_event',
                'title' => 'Sự kiện mới',
                'content' => "CLB {$club->name} vừa tạo sự kiện mới: {$event->name}",
                'target_id' => $event->id,
                'target_type' => 'event',
                'event_name' => $event->name,
                'club_name' => $club->name,
                'event_start_date' => $event->start_date,
                'event_end_date' => $event->end_date,
                'event_location' => $event->location,
            ];
            $notification->save();
        }
    }
} 
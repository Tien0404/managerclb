<?php

namespace App\Notify;

use App\Models\Notification;
use App\Models\User;
use App\Models\JoinRequest;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Support\Facades\Log;

class SendJoinRequestNotification implements ShouldQueue
{
    public function handle(JoinRequestNotification $event)
    {
        try {
            $joinRequest = $event->joinRequest;
            
            // Đảm bảo các quan hệ được tải
            if (!$joinRequest->relationLoaded('user')) {
                $joinRequest->load('user');
            }
            if (!$joinRequest->relationLoaded('club')) {
                $joinRequest->load('club');
            }
            if (!$joinRequest->relationLoaded('event')) {
                $joinRequest->load('event');
            }

            $user = $joinRequest->user;
            $club = $joinRequest->club;
            $eventObj = $joinRequest->event;

            // Tạo thông báo cho người dùng
            $notification = new Notification();
            $notification->notifiable_id = $user->id;
            
            // Xác định loại thông báo và nội dung dựa trên trạng thái
            $notificationData = [
                'notification_type' => 'join_request_' . $joinRequest->status,
                'title' => $this->getNotificationTitle($joinRequest),
                'content' => $this->getNotificationContent($joinRequest),
                'target_id' => $joinRequest->type === 'club' ? $club->id : $eventObj->id,
                'target_type' => $joinRequest->type,
                'status' => $joinRequest->status,
                'club_name' => $club ? $club->name : null,
                'event_name' => $eventObj ? $eventObj->name : null,
                'response_message' => $joinRequest->response_message,
                'created_at' => now()->toDateTimeString()
            ];

            $notification->data = $notificationData;
            $notification->save();

            Log::info('Join request notification created', [
                'join_request_id' => $joinRequest->id,
                'user_id' => $user->id,
                'status' => $joinRequest->status,
                'type' => $joinRequest->type
            ]);
        } catch (\Exception $e) {
            Log::error('Error creating join request notification', [
                'error' => $e->getMessage(),
                'join_request_id' => $joinRequest->id ?? null
            ]);
            throw $e;
        }
    }

    private function getNotificationTitle($joinRequest)
    {
        $type = $joinRequest->type === 'club' ? 'CLB' : 'sự kiện';
        
        return match ($joinRequest->status) {
            'approved' => "Chấp nhận tham gia {$type}",
            'rejected' => "Từ chối tham gia {$type}",
            'invite' => "Lời mời tham gia {$type}",
            default => "Yêu cầu tham gia {$type}"
        };
    }

    private function getNotificationContent($joinRequest)
    {
        $targetName = $joinRequest->type === 'club' 
            ? $joinRequest->club->name 
            : $joinRequest->event->name;
        
        return match ($joinRequest->status) {
            'approved' => "Yêu cầu tham gia {$targetName} của bạn đã được chấp nhận.",
            'rejected' => "Yêu cầu tham gia {$targetName} của bạn đã bị từ chối." . 
                        ($joinRequest->response_message ? " Lý do: {$joinRequest->response_message}" : ""),
            'invite' => "Bạn đã được mời tham gia {$targetName}.",
            default => "Bạn có yêu cầu tham gia {$targetName} đang chờ duyệt."
        };
    }
} 
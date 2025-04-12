<?php

namespace App\Notify;

use App\Notify\BlogCreated;
use App\Notify\NewBlogNotification;
use App\Models\User;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Support\Facades\DB;

class SendBlogCreatedNotification implements ShouldQueue
{
    public function handle(BlogCreated $event)
    {
        $clubId = $event->blog->club_id;
        
        // Lấy danh sách người dùng là thành viên của câu lạc bộ
        $clubMembers = DB::table('join_requests')
            ->where('club_id', $clubId)
            ->where('status', 'accepted')
            ->pluck('user_id')
            ->toArray();
            
        // Thêm người tạo câu lạc bộ vào danh sách
        $clubOwner = DB::table('clubs')
            ->where('id', $clubId)
            ->value('user_id');
            
        if ($clubOwner) {
            $clubMembers[] = $clubOwner;
        }
            
        // Loại bỏ các ID trùng lặp
        $clubMembers = array_unique($clubMembers);
        
        // Lấy thông tin người dùng
        $users = User::whereIn('id', $clubMembers)->get();

        // Use transaction to ensure atomicity
        DB::transaction(function () use ($users, $event) {
            foreach ($users as $user) {
                // Check if notification already exists
                $exists = DB::table('notifications')
                    ->where('notifiable_id', $user->id)
                    ->whereRaw("JSON_EXTRACT(data, '$.blog_id') = ?", [$event->blog->id])
                    ->whereRaw("JSON_EXTRACT(data, '$.notification_type') = ?", ['new_blog'])
                    ->exists();

                if (!$exists) {
                    $user->notify(new NewBlogNotification($event->blog));
                }
            }
        });
    }
} 
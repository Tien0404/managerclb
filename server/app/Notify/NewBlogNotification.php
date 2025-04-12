<?php

namespace App\Notify;

use App\Models\Blog;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification as IlluminateNotification;

class NewBlogNotification extends IlluminateNotification implements ShouldQueue
{
    use Queueable;

    protected $blog;

    public function __construct(Blog $blog)
    {
        $this->blog = $blog;
    }

    public function via($notifiable)
    {
        return ['database']; // Đã xóa kênh 'mail'
    }

    public function toMail($notifiable)
    {
        return (new MailMessage)
            ->subject('New Blog Post')
            ->line('A new blog post has been published: ' . $this->blog->title)
            ->line('Author: ' . $this->blog->user->username)
            ->line('Description: ' . $this->blog->description)
            ->action('Read Blog', url('/blogs/' . $this->blog->id))
            ->line('Thank you for using our application!');
    }

    public function toArray($notifiable)
    {
        // Đảm bảo club được tải
        if (!$this->blog->relationLoaded('club')) {
            $this->blog->load('club');
        }

        return [
            'blog_id' => $this->blog->id,
            'blog_title' => $this->blog->title,
            // 'author_name' => $this->blog->user->username,
            'description' => $this->blog->description,
            'club_id' => $this->blog->club_id,
            'club_name' => $this->blog->club->name ?? 'Unknown Club',
            'notification_type' => 'new_blog'
        ];
    }

    public function toDatabase($notifiable)
    {
        return $this->toArray($notifiable);
    }
} 
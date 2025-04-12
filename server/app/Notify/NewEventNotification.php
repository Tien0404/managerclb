<?php

namespace App\Notify;

use App\Models\Event;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification as IlluminateNotification;

class NewEventNotification extends IlluminateNotification implements ShouldQueue
{
    use Queueable;

    protected $event;

    public function __construct(Event $event)
    {
        $this->event = $event;
    }

    public function via($notifiable)
    {
        return ['database']; // Đã xóa kênh 'mail'
    }

    public function toMail($notifiable)
    {
        return (new MailMessage)
            ->subject('New Event Created')
            ->line('A new event has been created: ' . $this->event->name)
            ->line('Start Date: ' . $this->event->start_date)
            ->line('Location: ' . $this->event->location)
            ->action('View Event', url('/events/' . $this->event->id))
            ->line('Thank you for using our application!');
    }

    public function toArray($notifiable)
    {
        // Đảm bảo club được tải
        if (!$this->event->relationLoaded('club')) {
            $this->event->load('club');
        }

        return [
            'event_id' => $this->event->id,
            'event_name' => $this->event->name,
            'start_date' => $this->event->start_date,
            'location' => $this->event->location,
            'club_id' => $this->event->club_id,
            'club_name' => $this->event->club->name ?? 'Unknown Club',
            'notification_type' => 'new_event'
        ];
    }

    public function toDatabase($notifiable)
    {
        return $this->toArray($notifiable);
    }
} 
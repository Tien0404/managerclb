<?php

// Class aliases for backward compatibility
if (!class_exists('App\Events\BlogCreated')) {
    class_alias('App\Notify\BlogCreated', 'App\Events\BlogCreated');
}

if (!class_exists('App\Events\EventCreated')) {
    class_alias('App\Notify\EventCreated', 'App\Events\EventCreated');
}

if (!class_exists('App\Listeners\SendBlogCreatedNotification')) {
    class_alias('App\Notify\SendBlogCreatedNotification', 'App\Listeners\SendBlogCreatedNotification');
}

if (!class_exists('App\Listeners\SendEventCreatedNotification')) {
    class_alias('App\Notify\SendEventCreatedNotification', 'App\Listeners\SendEventCreatedNotification');
}

if (!class_exists('App\Notifications\NewBlogNotification')) {
    class_alias('App\Notify\NewBlogNotification', 'App\Notifications\NewBlogNotification');
}

if (!class_exists('App\Notifications\NewEventNotification')) {
    class_alias('App\Notify\NewEventNotification', 'App\Notifications\NewEventNotification');
} 
<?php

namespace App\Services;

use App\Models\Notification;

class NotificationService
{
    public function createNotification(
        int $userId,
        string $type,
        string $title,
        string $body,
        array $data = []
    ): Notification {
        return Notification::create([
            'user_id' => $userId,
            'type' => $type,
            'title' => $title,
            'body' => $body,
            'data' => $data,
            'read_at' => null,
        ]);
    }

    public function getUnreadCount(int $userId): int
    {
        return Notification::where('user_id', $userId)
            ->whereNull('read_at')
            ->count();
    }

    public function markAsRead(string $notificationId): bool
    {
        return (bool) Notification::where('id', $notificationId)
            ->update(['read_at' => now()]);
    }

    public function markAllAsRead(int $userId): int
    {
        return Notification::where('user_id', $userId)
            ->whereNull('read_at')
            ->update(['read_at' => now()]);
    }

    public function getDailyNotificationCount(int $userId, string $type): int
    {
        return Notification::where('user_id', $userId)
            ->where('type', $type)
            ->whereDate('created_at', now()->toDateString())
            ->count();
    }
}

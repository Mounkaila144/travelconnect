<?php

namespace App\Listeners;

use App\Events\QuestionCreated;
use App\Models\User;
use App\Services\FCMService;
use App\Services\NotificationService;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class NotifyNearbyLocalSupporters
{
    private const MAX_DAILY_NOTIFICATIONS = 5;

    public function __construct(
        private readonly FCMService $fcmService,
        private readonly NotificationService $notificationService
    ) {}

    public function handle(QuestionCreated $event): void
    {
        try {
            $this->process($event);
        } catch (\Exception $e) {
            Log::error('NotifyNearbyLocalSupporters failed', [
                'question_id' => $event->question->id,
                'error' => $e->getMessage(),
            ]);
        }
    }

    private function process(QuestionCreated $event): void
    {
        $question = $event->question;

        if ($question->latitude === null || $question->longitude === null) {
            return;
        }

        $localSupporters = $this->findNearbyLocalSupporters(
            (float) $question->latitude,
            (float) $question->longitude
        );

        Log::info('Found nearby Local Supporters', [
            'question_id' => $question->id,
            'count' => $localSupporters->count(),
        ]);

        foreach ($localSupporters as $supporter) {
            // Skip question author
            if ($supporter->id === $question->user_id) {
                continue;
            }

            // Check notification preferences
            $settings = $supporter->notification_settings ?? [];
            if (isset($settings['nearby_questions']) && $settings['nearby_questions'] === false) {
                Log::info('User disabled nearby_questions notifications', ['user_id' => $supporter->id]);
                continue;
            }

            // Check daily notification limit
            $dailyCount = $this->notificationService->getDailyNotificationCount(
                $supporter->id,
                'nearby_question'
            );

            if ($dailyCount >= self::MAX_DAILY_NOTIFICATIONS) {
                Log::info('User hit daily notification limit', [
                    'user_id' => $supporter->id,
                    'count' => $dailyCount,
                ]);
                continue;
            }

            $locationName = $question->location_name ?? $question->city ?? 'votre zone';
            $title = sprintf('Nouvelle question près de %s', $locationName);
            $body = $this->truncate($question->title, 100);

            $data = [
                'type' => 'nearby_question',
                'question_id' => (string) $question->id,
            ];

            // Always create DB notification
            $this->notificationService->createNotification(
                userId: $supporter->id,
                type: 'nearby_question',
                title: $title,
                body: $body,
                data: $data
            );

            // Try sending push notification if FCM token available
            if ($supporter->fcm_token) {
                $this->fcmService->sendNotification(
                    $supporter->fcm_token,
                    ['title' => $title, 'body' => $body],
                    $data
                );
            }

            Log::info('Nearby question notification created', [
                'question_id' => $question->id,
                'supporter_id' => $supporter->id,
                'daily_count' => $dailyCount + 1,
            ]);
        }
    }

    private function findNearbyLocalSupporters(float $latitude, float $longitude)
    {
        return User::where('user_type', 'local_supporter')
            ->whereNotNull('notification_zone_lat')
            ->whereNotNull('notification_zone_lng')
            ->whereNotNull('notification_zone_radius')
            ->whereRaw(
                "ST_Distance_Sphere(
                    POINT(notification_zone_lng, notification_zone_lat),
                    POINT(?, ?)
                ) <= notification_zone_radius * 1000",
                [$longitude, $latitude]
            )
            ->get();
    }

    private function truncate(string $text, int $length): string
    {
        return strlen($text) > $length
            ? substr($text, 0, $length) . '...'
            : $text;
    }
}

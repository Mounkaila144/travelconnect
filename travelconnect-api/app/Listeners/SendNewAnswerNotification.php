<?php

namespace App\Listeners;

use App\Events\AnswerCreated;
use App\Services\FCMService;
use App\Services\NotificationService;
use Illuminate\Support\Facades\Log;

class SendNewAnswerNotification
{
    public function __construct(
        private readonly FCMService $fcmService,
        private readonly NotificationService $notificationService
    ) {}

    public function handle(AnswerCreated $event): void
    {
        try {
            $this->process($event);
        } catch (\Exception $e) {
            Log::error('SendNewAnswerNotification failed', [
                'answer_id' => $event->answer->id,
                'error' => $e->getMessage(),
            ]);
        }
    }

    private function process(AnswerCreated $event): void
    {
        $answer = $event->answer;
        $question = $event->question;
        $questionAuthor = $question->user;
        $answerAuthor = $answer->user;

        // Don't notify if user answers their own question
        if ($questionAuthor->id === $answerAuthor->id) {
            Log::info('Skipping self-answer notification', [
                'question_id' => $question->id,
                'user_id' => $questionAuthor->id,
            ]);
            return;
        }

        // Check notification preferences
        $settings = $questionAuthor->notification_settings ?? [];
        if (isset($settings['new_answers']) && $settings['new_answers'] === false) {
            Log::info('User disabled new answer notifications', [
                'user_id' => $questionAuthor->id,
            ]);
            return;
        }

        // Build notification payload
        $title = 'Nouvelle réponse';
        $body = sprintf(
            '%s a répondu à "%s"',
            $answerAuthor->name,
            $this->truncate($question->title, 50)
        );

        $data = [
            'type' => 'new_answer',
            'question_id' => (string) $question->id,
            'answer_id' => (string) $answer->id,
        ];

        // Always create DB notification
        $this->notificationService->createNotification(
            userId: $questionAuthor->id,
            type: 'new_answer',
            title: $title,
            body: $body,
            data: $data
        );

        // Try sending push notification if FCM token available
        if ($questionAuthor->fcm_token) {
            $this->fcmService->sendNotification(
                fcmToken: $questionAuthor->fcm_token,
                notification: ['title' => $title, 'body' => $body],
                data: $data
            );
        }

        Log::info('New answer notification created', [
            'question_id' => $question->id,
            'answer_id' => $answer->id,
            'recipient_id' => $questionAuthor->id,
            'push_sent' => (bool) $questionAuthor->fcm_token,
        ]);
    }

    private function truncate(string $text, int $length): string
    {
        return strlen($text) > $length
            ? substr($text, 0, $length) . '...'
            : $text;
    }
}

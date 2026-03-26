<?php

namespace App\Services;

use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;
use Kreait\Firebase\Messaging\AndroidConfig;
use Kreait\Firebase\Messaging\ApnsConfig;
use Illuminate\Support\Facades\Log;

class FCMService
{
    private $messaging = null;
    private bool $available = true;

    private function messaging()
    {
        if ($this->messaging === null && $this->available) {
            try {
                $credentials = config('firebase.credentials');
                $absolutePath = base_path($credentials);
                if (!$credentials || !file_exists($absolutePath)) {
                    Log::warning('Firebase credentials file not found, FCM disabled', [
                        'path' => $absolutePath,
                    ]);
                    $this->available = false;
                    return null;
                }
                $factory = (new Factory)->withServiceAccount($absolutePath);
                $this->messaging = $factory->createMessaging();
            } catch (\Exception $e) {
                Log::warning('Firebase initialization failed, FCM disabled', [
                    'error' => $e->getMessage(),
                ]);
                $this->available = false;
                return null;
            }
        }
        return $this->messaging;
    }

    /**
     * Send push notification to device
     */
    public function sendNotification(
        string $fcmToken,
        array $notification,
        array $data = []
    ): bool {
        try {
            if (!$this->messaging()) {
                return false;
            }

            $message = CloudMessage::withTarget('token', $fcmToken)
                ->withNotification(Notification::create(
                    $notification['title'],
                    $notification['body']
                ))
                ->withData($data)
                ->withAndroidConfig(
                    AndroidConfig::fromArray([
                        'priority' => 'high',
                        'notification' => [
                            'channel_id' => 'travelconnect_notifications',
                            'sound' => 'default',
                        ],
                    ])
                )
                ->withApnsConfig(
                    ApnsConfig::fromArray([
                        'payload' => [
                            'aps' => [
                                'alert' => [
                                    'title' => $notification['title'],
                                    'body' => $notification['body'],
                                ],
                                'sound' => 'default',
                                'badge' => 1,
                                'content-available' => 1,
                            ],
                        ],
                    ])
                );

            $this->messaging()->send($message);

            Log::info('FCM notification sent', [
                'token' => substr($fcmToken, 0, 10) . '...',
                'title' => $notification['title'],
            ]);

            return true;
        } catch (\Kreait\Firebase\Exception\Messaging\InvalidArgument $e) {
            Log::error('Invalid FCM token', [
                'token' => substr($fcmToken, 0, 10) . '...',
                'error' => $e->getMessage(),
            ]);
            return false;
        } catch (\Kreait\Firebase\Exception\Messaging\NotFound $e) {
            Log::error('FCM token not found', [
                'token' => substr($fcmToken, 0, 10) . '...',
                'error' => $e->getMessage(),
            ]);
            return false;
        } catch (\Exception $e) {
            Log::error('FCM notification failed', [
                'error' => $e->getMessage(),
            ]);
            return false;
        }
    }

    /**
     * Send notification to multiple devices
     */
    public function sendMulticast(
        array $fcmTokens,
        array $notification,
        array $data = []
    ): array {
        $results = [];

        foreach ($fcmTokens as $token) {
            $results[$token] = $this->sendNotification($token, $notification, $data);
        }

        return $results;
    }
}

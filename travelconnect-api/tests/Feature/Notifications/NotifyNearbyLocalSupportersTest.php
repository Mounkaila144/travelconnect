<?php

namespace Tests\Feature\Notifications;

use App\Events\QuestionCreated;
use App\Listeners\NotifyNearbyLocalSupporters;
use App\Models\Notification;
use App\Models\Question;
use App\Models\User;
use App\Services\FCMService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Mockery;
use Tests\TestCase;

class NotifyNearbyLocalSupportersTest extends TestCase
{
    use RefreshDatabase;

    private function createMockFCMService(bool $expectSend = true, int $times = 1): FCMService
    {
        $mock = Mockery::mock(FCMService::class);

        if ($expectSend) {
            $mock->shouldReceive('sendNotification')
                ->times($times)
                ->andReturn(true);
        } else {
            $mock->shouldNotReceive('sendNotification');
        }

        $this->app->instance(FCMService::class, $mock);

        return $mock;
    }

    public function test_local_supporter_receives_notification_for_question_in_zone(): void
    {
        $supporter = User::factory()->create([
            'user_type' => 'local_supporter',
            'fcm_token' => 'test_fcm_token',
            'notification_zone_lat' => 35.6762,
            'notification_zone_lng' => 139.6503,
            'notification_zone_radius' => 10,
            'notification_settings' => ['nearby_questions' => true],
        ]);

        $author = User::factory()->create();

        $question = Question::factory()->create([
            'user_id' => $author->id,
            'title' => 'Best sushi near Shibuya?',
            'location_name' => 'Shibuya, Tokyo',
            'latitude' => 35.68,
            'longitude' => 139.65,
        ]);

        $this->createMockFCMService(true);

        $event = new QuestionCreated($question);
        $listener = app(NotifyNearbyLocalSupporters::class);
        $listener->handle($event);

        $this->assertDatabaseHas('notifications', [
            'user_id' => $supporter->id,
            'type' => 'nearby_question',
        ]);
    }

    public function test_notification_contains_location_and_title(): void
    {
        $supporter = User::factory()->create([
            'user_type' => 'local_supporter',
            'fcm_token' => 'test_token',
            'notification_zone_lat' => 35.6762,
            'notification_zone_lng' => 139.6503,
            'notification_zone_radius' => 10,
        ]);

        $author = User::factory()->create();

        $question = Question::factory()->create([
            'user_id' => $author->id,
            'title' => 'Meilleur sushi à Osaka?',
            'location_name' => 'Shibuya, Tokyo',
            'latitude' => 35.68,
            'longitude' => 139.65,
        ]);

        $fcmMock = Mockery::mock(FCMService::class);
        $fcmMock->shouldReceive('sendNotification')
            ->once()
            ->with(
                'test_token',
                Mockery::on(function ($notification) {
                    return str_contains($notification['title'], 'Shibuya, Tokyo')
                        && str_contains($notification['body'], 'Meilleur sushi à Osaka?');
                }),
                Mockery::on(function ($data) use ($question) {
                    return $data['type'] === 'nearby_question'
                        && $data['question_id'] === (string) $question->id;
                })
            )
            ->andReturn(true);
        $this->app->instance(FCMService::class, $fcmMock);

        $event = new QuestionCreated($question);
        $listener = app(NotifyNearbyLocalSupporters::class);
        $listener->handle($event);
    }

    public function test_traveler_does_not_receive_notification(): void
    {
        User::factory()->create([
            'user_type' => 'traveler',
            'fcm_token' => 'test_token',
            'notification_zone_lat' => 35.6762,
            'notification_zone_lng' => 139.6503,
            'notification_zone_radius' => 10,
        ]);

        $author = User::factory()->create();

        $question = Question::factory()->create([
            'user_id' => $author->id,
            'latitude' => 35.68,
            'longitude' => 139.65,
        ]);

        $this->createMockFCMService(false);

        $event = new QuestionCreated($question);
        $listener = app(NotifyNearbyLocalSupporters::class);
        $listener->handle($event);
    }

    public function test_user_outside_zone_does_not_receive_notification(): void
    {
        User::factory()->create([
            'user_type' => 'local_supporter',
            'fcm_token' => 'test_token',
            'notification_zone_lat' => 35.6762,
            'notification_zone_lng' => 139.6503,
            'notification_zone_radius' => 5,
        ]);

        $author = User::factory()->create();

        // Question 50km away
        $question = Question::factory()->create([
            'user_id' => $author->id,
            'latitude' => 36.0,
            'longitude' => 140.0,
        ]);

        $this->createMockFCMService(false);

        $event = new QuestionCreated($question);
        $listener = app(NotifyNearbyLocalSupporters::class);
        $listener->handle($event);
    }

    public function test_user_with_disabled_nearby_questions_does_not_receive_notification(): void
    {
        User::factory()->create([
            'user_type' => 'local_supporter',
            'fcm_token' => 'test_token',
            'notification_zone_lat' => 35.6762,
            'notification_zone_lng' => 139.6503,
            'notification_zone_radius' => 10,
            'notification_settings' => ['nearby_questions' => false],
        ]);

        $author = User::factory()->create();

        $question = Question::factory()->create([
            'user_id' => $author->id,
            'latitude' => 35.68,
            'longitude' => 139.65,
        ]);

        $this->createMockFCMService(false);

        $event = new QuestionCreated($question);
        $listener = app(NotifyNearbyLocalSupporters::class);
        $listener->handle($event);
    }

    public function test_daily_limit_prevents_more_than_5_notifications(): void
    {
        $supporter = User::factory()->create([
            'user_type' => 'local_supporter',
            'fcm_token' => 'test_token',
            'notification_zone_lat' => 35.6762,
            'notification_zone_lng' => 139.6503,
            'notification_zone_radius' => 10,
        ]);

        // Create 5 notifications for today
        for ($i = 0; $i < 5; $i++) {
            Notification::factory()->nearbyQuestion()->create([
                'user_id' => $supporter->id,
                'created_at' => now(),
            ]);
        }

        $author = User::factory()->create();

        $question = Question::factory()->create([
            'user_id' => $author->id,
            'latitude' => 35.68,
            'longitude' => 139.65,
        ]);

        $this->createMockFCMService(false);

        $event = new QuestionCreated($question);
        $listener = app(NotifyNearbyLocalSupporters::class);
        $listener->handle($event);

        $this->assertEquals(5, Notification::where('user_id', $supporter->id)->count());
    }

    public function test_question_author_does_not_receive_notification(): void
    {
        $supporter = User::factory()->create([
            'user_type' => 'local_supporter',
            'fcm_token' => 'test_token',
            'notification_zone_lat' => 35.6762,
            'notification_zone_lng' => 139.6503,
            'notification_zone_radius' => 10,
        ]);

        $question = Question::factory()->create([
            'user_id' => $supporter->id,
            'latitude' => 35.68,
            'longitude' => 139.65,
        ]);

        $this->createMockFCMService(false);

        $event = new QuestionCreated($question);
        $listener = app(NotifyNearbyLocalSupporters::class);
        $listener->handle($event);
    }

    public function test_notification_zone_endpoint_updates_user(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)->putJson('/api/user/notification-zone', [
            'latitude' => 35.6762,
            'longitude' => 139.6503,
            'radius_km' => 10,
        ]);

        $response->assertStatus(204);

        $user->refresh();
        $this->assertEquals(35.6762, (float) $user->notification_zone_lat);
        $this->assertEquals(139.6503, (float) $user->notification_zone_lng);
        $this->assertEquals(10, $user->notification_zone_radius);
    }

    public function test_notification_zone_validates_input(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)->putJson('/api/user/notification-zone', [
            'latitude' => 95,
            'longitude' => 200,
            'radius_km' => 100,
        ]);

        $response->assertStatus(422);
    }
}

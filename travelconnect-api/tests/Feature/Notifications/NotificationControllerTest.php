<?php

namespace Tests\Feature\Notifications;

use App\Models\Notification;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class NotificationControllerTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_list_their_notifications(): void
    {
        $user = User::factory()->create();
        $otherUser = User::factory()->create();

        Notification::factory()->create([
            'user_id' => $user->id,
            'created_at' => now()->subHours(1),
        ]);

        Notification::factory()->create([
            'user_id' => $user->id,
            'created_at' => now()->subHours(2),
        ]);

        Notification::factory()->create([
            'user_id' => $otherUser->id,
        ]);

        $response = $this->actingAs($user)->getJson('/api/notifications');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'data' => [
                    '*' => ['id', 'type', 'title', 'body', 'data', 'read_at', 'created_at', 'time_ago'],
                ],
                'meta',
                'unread_count',
            ])
            ->assertJsonCount(2, 'data');
    }

    public function test_notifications_ordered_by_created_at_desc(): void
    {
        $user = User::factory()->create();

        $old = Notification::factory()->create([
            'user_id' => $user->id,
            'created_at' => now()->subHours(2),
        ]);

        $new = Notification::factory()->create([
            'user_id' => $user->id,
            'created_at' => now()->subHours(1),
        ]);

        $response = $this->actingAs($user)->getJson('/api/notifications');

        $notifications = $response->json('data');
        $this->assertEquals($new->id, $notifications[0]['id']);
        $this->assertEquals($old->id, $notifications[1]['id']);
    }

    public function test_notifications_include_unread_count(): void
    {
        $user = User::factory()->create();

        Notification::factory()->count(3)->create([
            'user_id' => $user->id,
            'read_at' => null,
        ]);

        Notification::factory()->count(2)->read()->create([
            'user_id' => $user->id,
        ]);

        $response = $this->actingAs($user)->getJson('/api/notifications');

        $response->assertJsonPath('unread_count', 3);
    }

    public function test_user_can_mark_notification_as_read(): void
    {
        $user = User::factory()->create();

        $notification = Notification::factory()->create([
            'user_id' => $user->id,
            'read_at' => null,
        ]);

        $response = $this->actingAs($user)
            ->postJson("/api/notifications/{$notification->id}/read");

        $response->assertStatus(204);

        $notification->refresh();
        $this->assertNotNull($notification->read_at);
    }

    public function test_cannot_mark_other_users_notification_as_read(): void
    {
        $user = User::factory()->create();
        $otherUser = User::factory()->create();

        $notification = Notification::factory()->create([
            'user_id' => $otherUser->id,
        ]);

        $response = $this->actingAs($user)
            ->postJson("/api/notifications/{$notification->id}/read");

        $response->assertStatus(404);
    }

    public function test_user_can_mark_all_notifications_as_read(): void
    {
        $user = User::factory()->create();

        Notification::factory()->count(5)->create([
            'user_id' => $user->id,
            'read_at' => null,
        ]);

        $response = $this->actingAs($user)
            ->postJson('/api/notifications/read-all');

        $response->assertStatus(200)
            ->assertJson(['marked_count' => 5]);

        $this->assertEquals(0, Notification::where('user_id', $user->id)
            ->whereNull('read_at')
            ->count());
    }

    public function test_get_unread_count(): void
    {
        $user = User::factory()->create();

        Notification::factory()->count(3)->create([
            'user_id' => $user->id,
            'read_at' => null,
        ]);

        $response = $this->actingAs($user)->getJson('/api/notifications/unread-count');

        $response->assertStatus(200)
            ->assertJson(['unread_count' => 3]);
    }

    public function test_pagination_works(): void
    {
        $user = User::factory()->create();

        Notification::factory()->count(25)->create([
            'user_id' => $user->id,
        ]);

        $response = $this->actingAs($user)->getJson('/api/notifications?page=1');

        $response->assertStatus(200);
        $this->assertCount(20, $response->json('data'));
        $this->assertEquals(25, $response->json('meta.total'));
    }

    public function test_unauthenticated_cannot_list_notifications(): void
    {
        $response = $this->getJson('/api/notifications');

        $response->assertStatus(401);
    }

    public function test_banned_user_cannot_list_notifications(): void
    {
        $user = User::factory()->banned()->create();

        $response = $this->actingAs($user)->getJson('/api/notifications');

        $response->assertStatus(403);
    }
}

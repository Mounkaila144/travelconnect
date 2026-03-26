<?php

namespace Tests\Feature\Notifications;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class NotificationSettingsTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_update_notification_settings(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)->putJson('/api/user/notification-settings', [
            'new_answers' => false,
        ]);

        $response->assertOk()
            ->assertJson([
                'new_answers' => false,
                'nearby_questions' => true,
            ]);

        $this->assertDatabaseHas('users', [
            'id' => $user->id,
        ]);

        $user->refresh();
        $this->assertFalse($user->notification_settings['new_answers']);
    }

    public function test_user_can_update_multiple_settings(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)->putJson('/api/user/notification-settings', [
            'new_answers' => false,
            'nearby_questions' => false,
        ]);

        $response->assertOk()
            ->assertJson([
                'new_answers' => false,
                'nearby_questions' => false,
            ]);
    }

    public function test_settings_are_merged_not_replaced(): void
    {
        $user = User::factory()->create([
            'notification_settings' => [
                'new_answers' => true,
                'nearby_questions' => true,
            ],
        ]);

        $this->actingAs($user)->putJson('/api/user/notification-settings', [
            'new_answers' => false,
        ]);

        $user->refresh();
        $this->assertFalse($user->notification_settings['new_answers']);
        $this->assertTrue($user->notification_settings['nearby_questions']);
    }

    public function test_settings_validates_boolean_values(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)->putJson('/api/user/notification-settings', [
            'new_answers' => 'not_a_boolean',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors('new_answers');
    }

    public function test_unauthenticated_user_cannot_update_settings(): void
    {
        $response = $this->putJson('/api/user/notification-settings', [
            'new_answers' => false,
        ]);

        $response->assertStatus(401);
    }

    public function test_banned_user_cannot_update_settings(): void
    {
        $user = User::factory()->banned()->create();

        $response = $this->actingAs($user)->putJson('/api/user/notification-settings', [
            'new_answers' => false,
        ]);

        $response->assertStatus(403);
    }

    public function test_default_settings_when_null(): void
    {
        $user = User::factory()->create([
            'notification_settings' => null,
        ]);

        $response = $this->actingAs($user)->putJson('/api/user/notification-settings', [
            'new_answers' => false,
        ]);

        $response->assertOk()
            ->assertJson([
                'new_answers' => false,
                'nearby_questions' => true,
            ]);
    }
}

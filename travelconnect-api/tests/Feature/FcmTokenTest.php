<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class FcmTokenTest extends TestCase
{
    use RefreshDatabase;

    public function test_authenticated_user_can_register_fcm_token(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)->postJson('/api/user/fcm-token', [
            'fcm_token' => 'test_fcm_token_12345',
        ]);

        $response->assertStatus(204);

        $this->assertDatabaseHas('users', [
            'id' => $user->id,
            'fcm_token' => 'test_fcm_token_12345',
        ]);
    }

    public function test_fcm_token_is_updated_on_subsequent_registration(): void
    {
        $user = User::factory()->create([
            'fcm_token' => 'old_token',
        ]);

        $this->actingAs($user)->postJson('/api/user/fcm-token', [
            'fcm_token' => 'new_token',
        ]);

        $this->assertDatabaseHas('users', [
            'id' => $user->id,
            'fcm_token' => 'new_token',
        ]);
    }

    public function test_fcm_token_is_required(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)->postJson('/api/user/fcm-token', []);

        $response->assertStatus(422)
            ->assertJsonValidationErrors('fcm_token');
    }

    public function test_fcm_token_must_be_string(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)->postJson('/api/user/fcm-token', [
            'fcm_token' => 12345,
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors('fcm_token');
    }

    public function test_fcm_token_max_length(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)->postJson('/api/user/fcm-token', [
            'fcm_token' => str_repeat('a', 501),
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors('fcm_token');
    }

    public function test_unauthenticated_user_cannot_register_token(): void
    {
        $response = $this->postJson('/api/user/fcm-token', [
            'fcm_token' => 'test_token',
        ]);

        $response->assertStatus(401);
    }

    public function test_banned_user_cannot_register_fcm_token(): void
    {
        $user = User::factory()->banned()->create();

        $response = $this->actingAs($user)->postJson('/api/user/fcm-token', [
            'fcm_token' => 'test_token',
        ]);

        $response->assertStatus(403);
    }

    public function test_fcm_token_is_stored_in_database(): void
    {
        $user = User::factory()->create();
        $token = 'firebase_cloud_messaging_token_abc123';

        $this->actingAs($user)->postJson('/api/user/fcm-token', [
            'fcm_token' => $token,
        ]);

        $user->refresh();
        $this->assertEquals($token, $user->fcm_token);
    }
}

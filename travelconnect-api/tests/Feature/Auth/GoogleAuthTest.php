<?php

namespace Tests\Feature\Auth;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Http;
use Tests\TestCase;

class GoogleAuthTest extends TestCase
{
    use RefreshDatabase;

    private function fakeGoogleTokenInfo(array $overrides = []): void
    {
        Http::fake([
            'oauth2.googleapis.com/tokeninfo*' => Http::response(array_merge([
                'sub' => 'google-user-123',
                'email' => 'newuser@gmail.com',
                'name' => 'Test User',
                'picture' => 'https://lh3.googleusercontent.com/avatar.jpg',
                'aud' => config('services.google.client_id'),
                'exp' => now()->addHour()->timestamp,
            ], $overrides), 200),
        ]);
    }

    public function test_successful_google_authentication_creates_new_user(): void
    {
        $this->fakeGoogleTokenInfo();

        $response = $this->postJson('/api/auth/google', [
            'id_token' => 'valid-google-token',
        ]);

        $response->assertStatus(200)
            ->assertJsonStructure([
                'user' => ['id', 'email', 'name', 'avatar_url', 'user_type', 'trust_score', 'is_new'],
                'token',
                'is_new_user',
            ])
            ->assertJson([
                'user' => [
                    'email' => 'newuser@gmail.com',
                    'name' => 'Test User',
                ],
                'is_new_user' => true,
            ]);

        $this->assertDatabaseHas('users', [
            'email' => 'newuser@gmail.com',
            'provider' => 'google',
            'provider_id' => 'google-user-123',
        ]);
    }

    public function test_existing_user_can_authenticate_with_google(): void
    {
        $user = User::factory()->create([
            'provider' => 'google',
            'provider_id' => 'google-user-123',
            'email' => 'existing@gmail.com',
        ]);

        $this->fakeGoogleTokenInfo([
            'sub' => 'google-user-123',
            'email' => 'existing@gmail.com',
        ]);

        $response = $this->postJson('/api/auth/google', [
            'id_token' => 'valid-google-token',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'user' => [
                    'id' => $user->id,
                    'email' => 'existing@gmail.com',
                ],
                'is_new_user' => false,
            ]);

        $this->assertDatabaseCount('users', 1);
    }

    public function test_invalid_google_token_returns_401(): void
    {
        Http::fake([
            'oauth2.googleapis.com/tokeninfo*' => Http::response(
                ['error_description' => 'Invalid Value'],
                400
            ),
        ]);

        $response = $this->postJson('/api/auth/google', [
            'id_token' => 'invalid-token',
        ]);

        $response->assertStatus(401)
            ->assertJson([
                'error' => [
                    'code' => 'INVALID_TOKEN',
                ],
            ]);
    }

    public function test_banned_user_cannot_authenticate(): void
    {
        User::factory()->banned()->create([
            'provider' => 'google',
            'provider_id' => 'banned-user-123',
            'email' => 'banned@gmail.com',
        ]);

        $this->fakeGoogleTokenInfo([
            'sub' => 'banned-user-123',
            'email' => 'banned@gmail.com',
        ]);

        $response = $this->postJson('/api/auth/google', [
            'id_token' => 'valid-google-token',
        ]);

        $response->assertStatus(403)
            ->assertJson([
                'error' => [
                    'code' => 'USER_BANNED',
                ],
            ]);
    }

    public function test_email_conflict_returns_422(): void
    {
        User::factory()->apple()->create([
            'email' => 'conflict@gmail.com',
            'provider_id' => 'apple-user-456',
        ]);

        $this->fakeGoogleTokenInfo([
            'sub' => 'google-user-789',
            'email' => 'conflict@gmail.com',
        ]);

        $response = $this->postJson('/api/auth/google', [
            'id_token' => 'valid-google-token',
        ]);

        $response->assertStatus(422)
            ->assertJson([
                'error' => [
                    'code' => 'EMAIL_CONFLICT',
                ],
            ]);
    }

    public function test_missing_id_token_returns_422(): void
    {
        $response = $this->postJson('/api/auth/google', []);

        $response->assertStatus(422);
    }
}

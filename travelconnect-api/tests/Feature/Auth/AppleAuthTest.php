<?php

namespace Tests\Feature\Auth;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Socialite\Facades\Socialite;
use Laravel\Socialite\Two\User as SocialiteUser;
use Tests\TestCase;

class AppleAuthTest extends TestCase
{
    use RefreshDatabase;

    private function mockSocialiteAppleUser(array $overrides = []): void
    {
        $defaults = [
            'id' => '000123.abc456def.7890',
            'email' => 'user@example.com',
        ];

        $data = array_merge($defaults, $overrides);

        $socialiteUser = \Mockery::mock(SocialiteUser::class);
        $socialiteUser->shouldReceive('getId')->andReturn($data['id']);
        $socialiteUser->shouldReceive('getEmail')->andReturn($data['email']);

        $driver = \Mockery::mock();
        $driver->shouldReceive('stateless')->andReturnSelf();
        $driver->shouldReceive('userFromToken')->andReturn($socialiteUser);

        Socialite::shouldReceive('driver')->with('apple')->andReturn($driver);
    }

    private function mockSocialiteAppleFailure(): void
    {
        $driver = \Mockery::mock();
        $driver->shouldReceive('stateless')->andReturnSelf();
        $driver->shouldReceive('userFromToken')->andThrow(new \Exception('Invalid token'));

        Socialite::shouldReceive('driver')->with('apple')->andReturn($driver);
    }

    public function test_successful_apple_authentication_creates_new_user_with_full_name(): void
    {
        $this->mockSocialiteAppleUser();

        $response = $this->postJson('/api/auth/apple', [
            'identity_token' => 'valid-apple-identity-token',
            'authorization_code' => 'valid-apple-auth-code',
            'full_name' => [
                'given_name' => 'John',
                'family_name' => 'Doe',
            ],
        ]);

        $response->assertStatus(200)
            ->assertJsonStructure([
                'user' => ['id', 'email', 'name', 'avatar_url', 'user_type', 'trust_score', 'is_new'],
                'token',
                'is_new_user',
            ])
            ->assertJson([
                'user' => [
                    'email' => 'user@example.com',
                    'name' => 'John Doe',
                    'avatar_url' => null,
                ],
                'is_new_user' => true,
            ]);

        $this->assertDatabaseHas('users', [
            'email' => 'user@example.com',
            'name' => 'John Doe',
            'provider' => 'apple',
            'provider_id' => '000123.abc456def.7890',
        ]);
    }

    public function test_successful_apple_authentication_without_name_uses_default(): void
    {
        $this->mockSocialiteAppleUser();

        $response = $this->postJson('/api/auth/apple', [
            'identity_token' => 'valid-apple-identity-token',
            'authorization_code' => 'valid-apple-auth-code',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'user' => [
                    'name' => 'Utilisateur',
                ],
                'is_new_user' => true,
            ]);

        $this->assertDatabaseHas('users', [
            'name' => 'Utilisateur',
            'provider' => 'apple',
        ]);
    }

    public function test_hide_my_email_relay_address_is_stored_correctly(): void
    {
        $this->mockSocialiteAppleUser([
            'email' => 'abc123xyz@privaterelay.appleid.com',
        ]);

        $response = $this->postJson('/api/auth/apple', [
            'identity_token' => 'valid-token',
            'authorization_code' => 'valid-code',
            'full_name' => [
                'given_name' => 'Test',
                'family_name' => 'User',
            ],
        ]);

        $response->assertStatus(200);

        $this->assertDatabaseHas('users', [
            'email' => 'abc123xyz@privaterelay.appleid.com',
            'provider' => 'apple',
        ]);
    }

    public function test_existing_apple_user_can_authenticate(): void
    {
        $user = User::factory()->apple()->create([
            'provider_id' => '000123.abc456def.7890',
            'email' => 'existing@example.com',
        ]);

        $this->mockSocialiteAppleUser([
            'id' => '000123.abc456def.7890',
            'email' => 'existing@example.com',
        ]);

        $response = $this->postJson('/api/auth/apple', [
            'identity_token' => 'valid-token',
            'authorization_code' => 'valid-code',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'user' => [
                    'id' => $user->id,
                    'email' => 'existing@example.com',
                ],
                'is_new_user' => false,
            ]);

        $this->assertDatabaseCount('users', 1);
    }

    public function test_invalid_apple_token_returns_401(): void
    {
        $this->mockSocialiteAppleFailure();

        $response = $this->postJson('/api/auth/apple', [
            'identity_token' => 'invalid-token',
            'authorization_code' => 'valid-code',
        ]);

        $response->assertStatus(401)
            ->assertJson([
                'error' => [
                    'code' => 'INVALID_APPLE_TOKEN',
                ],
            ]);
    }

    public function test_banned_user_cannot_authenticate(): void
    {
        User::factory()->apple()->banned()->create([
            'provider_id' => 'banned-apple-user',
            'email' => 'banned@example.com',
        ]);

        $this->mockSocialiteAppleUser([
            'id' => 'banned-apple-user',
            'email' => 'banned@example.com',
        ]);

        $response = $this->postJson('/api/auth/apple', [
            'identity_token' => 'valid-token',
            'authorization_code' => 'valid-code',
        ]);

        $response->assertStatus(403)
            ->assertJson([
                'error' => [
                    'code' => 'USER_BANNED',
                ],
            ]);
    }

    public function test_email_conflict_with_different_provider_returns_422(): void
    {
        User::factory()->create([
            'provider' => 'google',
            'provider_id' => 'google-user-123',
            'email' => 'conflict@example.com',
        ]);

        $this->mockSocialiteAppleUser([
            'id' => 'apple-user-456',
            'email' => 'conflict@example.com',
        ]);

        $response = $this->postJson('/api/auth/apple', [
            'identity_token' => 'valid-token',
            'authorization_code' => 'valid-code',
        ]);

        $response->assertStatus(422)
            ->assertJson([
                'error' => [
                    'code' => 'EMAIL_CONFLICT',
                ],
            ]);
    }

    public function test_missing_identity_token_returns_422(): void
    {
        $response = $this->postJson('/api/auth/apple', [
            'authorization_code' => 'valid-code',
        ]);

        $response->assertStatus(422);
    }

    public function test_missing_authorization_code_returns_422(): void
    {
        $response = $this->postJson('/api/auth/apple', [
            'identity_token' => 'valid-token',
        ]);

        $response->assertStatus(422);
    }

    public function test_name_update_on_subsequent_login_when_previously_default(): void
    {
        User::factory()->apple()->create([
            'provider_id' => '000123.abc456def.7890',
            'email' => 'user@example.com',
            'name' => 'Utilisateur',
        ]);

        $this->mockSocialiteAppleUser();

        $response = $this->postJson('/api/auth/apple', [
            'identity_token' => 'valid-token',
            'authorization_code' => 'valid-code',
            'full_name' => [
                'given_name' => 'Jane',
                'family_name' => 'Smith',
            ],
        ]);

        $response->assertStatus(200);

        $this->assertDatabaseHas('users', [
            'provider_id' => '000123.abc456def.7890',
            'name' => 'Jane Smith',
        ]);
    }
}

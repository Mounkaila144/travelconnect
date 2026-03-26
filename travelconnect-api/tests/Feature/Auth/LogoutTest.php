<?php

namespace Tests\Feature\Auth;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class LogoutTest extends TestCase
{
    use RefreshDatabase;

    public function test_authenticated_user_can_logout(): void
    {
        $user = User::factory()->create();
        $token = $user->createToken('mobile-app');

        $response = $this->withToken($token->plainTextToken)
            ->postJson('/api/auth/logout');

        $response->assertStatus(204);

        $this->assertDatabaseMissing('personal_access_tokens', [
            'id' => $token->accessToken->id,
        ]);
    }

    public function test_token_deleted_from_database_after_logout(): void
    {
        $user = User::factory()->create();
        $token = $user->createToken('mobile-app');

        $this->assertDatabaseHas('personal_access_tokens', [
            'id' => $token->accessToken->id,
        ]);

        $this->withToken($token->plainTextToken)
            ->postJson('/api/auth/logout')
            ->assertStatus(204);

        $this->assertDatabaseMissing('personal_access_tokens', [
            'id' => $token->accessToken->id,
        ]);
    }

    public function test_unauthenticated_user_cannot_logout(): void
    {
        $response = $this->postJson('/api/auth/logout');

        $response->assertStatus(401);
    }

    public function test_logout_returns_204_no_content(): void
    {
        $user = User::factory()->create();
        $token = $user->createToken('mobile-app');

        $response = $this->withToken($token->plainTextToken)
            ->postJson('/api/auth/logout');

        $response->assertStatus(204);
        $response->assertNoContent();
    }

    public function test_logout_all_deletes_all_user_tokens(): void
    {
        $user = User::factory()->create();

        $token1 = $user->createToken('device-1');
        $token2 = $user->createToken('device-2');
        $token3 = $user->createToken('device-3');

        $this->withToken($token1->plainTextToken)
            ->postJson('/api/auth/logout-all')
            ->assertStatus(204);

        $this->assertDatabaseMissing('personal_access_tokens', [
            'tokenable_id' => $user->id,
        ]);
    }

    public function test_logout_only_deletes_current_token(): void
    {
        $user = User::factory()->create();

        $token1 = $user->createToken('device-1');
        $token2 = $user->createToken('device-2');

        $this->withToken($token1->plainTextToken)
            ->postJson('/api/auth/logout')
            ->assertStatus(204);

        $this->assertDatabaseMissing('personal_access_tokens', [
            'id' => $token1->accessToken->id,
        ]);

        $this->assertDatabaseHas('personal_access_tokens', [
            'id' => $token2->accessToken->id,
        ]);
    }

    public function test_logout_all_does_not_delete_other_users_tokens(): void
    {
        $user1 = User::factory()->create();
        $user2 = User::factory()->create();

        $token1 = $user1->createToken('mobile-app');
        $token2 = $user2->createToken('mobile-app');

        $this->withToken($token1->plainTextToken)
            ->postJson('/api/auth/logout-all')
            ->assertStatus(204);

        $this->assertDatabaseMissing('personal_access_tokens', [
            'tokenable_id' => $user1->id,
        ]);

        $this->assertDatabaseHas('personal_access_tokens', [
            'id' => $token2->accessToken->id,
        ]);
    }
}

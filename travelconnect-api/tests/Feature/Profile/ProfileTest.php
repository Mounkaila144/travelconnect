<?php

namespace Tests\Feature\Profile;

use App\Models\User;
use App\Services\StorageService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class ProfileTest extends TestCase
{
    use RefreshDatabase;

    public function test_authenticated_user_can_get_profile(): void
    {
        $user = User::factory()->create([
            'name' => 'Test User',
            'bio' => 'Test bio',
            'country_code' => 'JP',
            'user_type' => 'traveler',
            'trust_score' => 0.00,
        ]);

        $response = $this->actingAs($user)->getJson('/api/user/profile');

        $response->assertStatus(200)
            ->assertJson([
                'data' => [
                    'id' => $user->id,
                    'name' => 'Test User',
                    'bio' => 'Test bio',
                    'country_code' => 'JP',
                    'user_type' => 'traveler',
                    'trust_score' => 0.00,
                    'is_new' => true,
                    'questions_count' => 0,
                    'answers_count' => 0,
                ],
            ]);
    }

    public function test_authenticated_user_can_update_profile(): void
    {
        $user = User::factory()->create(['is_new' => true]);

        $response = $this->actingAs($user)->putJson('/api/user/profile', [
            'name' => 'Updated Name',
            'bio' => 'Updated bio',
            'country_code' => 'FR',
            'user_type' => 'local_supporter',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'data' => [
                    'name' => 'Updated Name',
                    'bio' => 'Updated bio',
                    'country_code' => 'FR',
                    'user_type' => 'local_supporter',
                    'is_new' => false,
                ],
            ]);

        $this->assertDatabaseHas('users', [
            'id' => $user->id,
            'name' => 'Updated Name',
            'bio' => 'Updated bio',
            'country_code' => 'FR',
            'user_type' => 'local_supporter',
            'is_new' => false,
        ]);
    }

    public function test_is_new_flag_set_to_false_after_first_update(): void
    {
        $user = User::factory()->create(['is_new' => true]);

        $this->assertTrue($user->is_new);

        $response = $this->actingAs($user)->putJson('/api/user/profile', [
            'name' => 'New Name',
            'country_code' => 'JP',
            'user_type' => 'traveler',
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('data.is_new', false);

        $this->assertDatabaseHas('users', [
            'id' => $user->id,
            'is_new' => false,
        ]);
    }

    public function test_profile_update_validates_name_required(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)->putJson('/api/user/profile', [
            'bio' => 'Some bio',
            'country_code' => 'JP',
            'user_type' => 'traveler',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['name']);
    }

    public function test_profile_update_validates_name_min_length(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)->putJson('/api/user/profile', [
            'name' => 'A',
            'country_code' => 'JP',
            'user_type' => 'traveler',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['name']);
    }

    public function test_profile_update_validates_bio_max_length(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)->putJson('/api/user/profile', [
            'name' => 'Test User',
            'bio' => str_repeat('a', 151),
            'country_code' => 'JP',
            'user_type' => 'traveler',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['bio']);
    }

    public function test_profile_update_validates_country_code(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)->putJson('/api/user/profile', [
            'name' => 'Test User',
            'country_code' => 'XX',
            'user_type' => 'traveler',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['country_code']);
    }

    public function test_profile_update_validates_user_type(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)->putJson('/api/user/profile', [
            'name' => 'Test User',
            'country_code' => 'JP',
            'user_type' => 'invalid_type',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['user_type']);
    }

    public function test_user_type_can_be_changed(): void
    {
        $user = User::factory()->create(['user_type' => 'traveler']);

        $response = $this->actingAs($user)->putJson('/api/user/profile', [
            'name' => 'Test User',
            'country_code' => 'JP',
            'user_type' => 'local_supporter',
        ]);

        $response->assertStatus(200);
        $this->assertDatabaseHas('users', [
            'id' => $user->id,
            'user_type' => 'local_supporter',
        ]);

        $response = $this->actingAs($user->fresh())->putJson('/api/user/profile', [
            'name' => 'Test User',
            'country_code' => 'JP',
            'user_type' => 'traveler',
        ]);

        $response->assertStatus(200);
        $this->assertDatabaseHas('users', [
            'id' => $user->id,
            'user_type' => 'traveler',
        ]);
    }

    public function test_avatar_upload_stores_image(): void
    {
        $user = User::factory()->create(['avatar_url' => null]);
        $expectedUrl = 'https://travelconnect-avatars.s3.gra.cloud.ovh.net/avatars/1_123456.jpg';

        $mock = $this->mock(StorageService::class);
        $mock->shouldReceive('uploadAvatar')
            ->once()
            ->andReturn($expectedUrl);

        $file = UploadedFile::fake()->image('avatar.jpg', 1000, 1000);

        $response = $this->actingAs($user)->postJson('/api/user/avatar', [
            'avatar' => $file,
        ]);

        $response->assertStatus(200)
            ->assertJson(['avatar_url' => $expectedUrl]);
    }

    public function test_avatar_upload_replaces_old_avatar(): void
    {
        $user = User::factory()->create([
            'avatar_url' => 'https://travelconnect-avatars.s3.gra.cloud.ovh.net/avatars/old.jpg',
        ]);
        $newUrl = 'https://travelconnect-avatars.s3.gra.cloud.ovh.net/avatars/new.jpg';

        $mock = $this->mock(StorageService::class);
        $mock->shouldReceive('uploadAvatar')
            ->once()
            ->andReturn($newUrl);

        $file = UploadedFile::fake()->image('avatar.jpg', 800, 800);

        $response = $this->actingAs($user)->postJson('/api/user/avatar', [
            'avatar' => $file,
        ]);

        $response->assertStatus(200)
            ->assertJson(['avatar_url' => $newUrl]);
    }

    public function test_avatar_upload_validates_file_required(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)->postJson('/api/user/avatar', []);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['avatar']);
    }

    public function test_avatar_upload_validates_file_type(): void
    {
        $user = User::factory()->create();
        $file = UploadedFile::fake()->create('document.pdf', 100, 'application/pdf');

        $response = $this->actingAs($user)->postJson('/api/user/avatar', [
            'avatar' => $file,
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['avatar']);
    }

    public function test_avatar_upload_validates_file_size(): void
    {
        $user = User::factory()->create();
        $file = UploadedFile::fake()->image('avatar.jpg')->size(6000);

        $response = $this->actingAs($user)->postJson('/api/user/avatar', [
            'avatar' => $file,
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['avatar']);
    }

    public function test_unauthenticated_user_cannot_access_profile(): void
    {
        $response = $this->getJson('/api/user/profile');

        $response->assertStatus(401);
    }

    public function test_unauthenticated_user_cannot_update_profile(): void
    {
        $response = $this->putJson('/api/user/profile', [
            'name' => 'Test',
            'country_code' => 'JP',
            'user_type' => 'traveler',
        ]);

        $response->assertStatus(401);
    }

    public function test_banned_user_cannot_access_profile(): void
    {
        $user = User::factory()->banned()->create();

        $response = $this->actingAs($user)->getJson('/api/user/profile');

        $response->assertStatus(403)
            ->assertJsonPath('error.code', 'USER_BANNED');
    }

    public function test_profile_bio_can_be_null(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)->putJson('/api/user/profile', [
            'name' => 'Test User',
            'bio' => null,
            'country_code' => 'JP',
            'user_type' => 'traveler',
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('data.bio', null);
    }
}

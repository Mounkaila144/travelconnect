<?php

namespace Tests\Feature\Questions;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Tests\TestCase;

class CreateQuestionTest extends TestCase
{
    use RefreshDatabase;

    private User $user;

    protected function setUp(): void
    {
        parent::setUp();
        $this->user = User::factory()->create();
    }

    private function fakeGeocodingSuccess(): void
    {
        Http::fake([
            'maps.googleapis.com/*' => Http::response([
                'results' => [
                    [
                        'formatted_address' => 'Shibuya, Tokyo, Japan',
                        'address_components' => [
                            ['types' => ['locality'], 'long_name' => 'Tokyo'],
                        ],
                    ],
                ],
            ]),
        ]);
    }

    public function test_creates_question_successfully(): void
    {
        $this->fakeGeocodingSuccess();

        $response = $this->actingAs($this->user)->postJson('/api/questions', [
            'title' => 'Meilleur ramen près de Shibuya ?',
            'description' => 'Je cherche un bon restaurant de ramen',
            'latitude' => 35.6595,
            'longitude' => 139.7004,
        ]);

        $response->assertCreated()
            ->assertJsonStructure([
                'data' => [
                    'id',
                    'title',
                    'description',
                    'latitude',
                    'longitude',
                    'location_name',
                    'city',
                    'answers_count',
                    'created_at',
                    'user',
                ],
            ])
            ->assertJsonPath('data.title', 'Meilleur ramen près de Shibuya ?')
            ->assertJsonPath('data.location_name', 'Shibuya, Tokyo, Japan')
            ->assertJsonPath('data.city', 'Tokyo')
            ->assertJsonPath('data.user.id', $this->user->id);

        $this->assertDatabaseHas('questions', [
            'title' => 'Meilleur ramen près de Shibuya ?',
            'user_id' => $this->user->id,
        ]);
    }

    public function test_creates_question_without_description(): void
    {
        $this->fakeGeocodingSuccess();

        $response = $this->actingAs($this->user)->postJson('/api/questions', [
            'title' => 'Où manger ?',
            'latitude' => 35.6595,
            'longitude' => 139.7004,
        ]);

        $response->assertCreated()
            ->assertJsonPath('data.description', null);
    }

    public function test_validation_fails_when_title_missing(): void
    {
        $response = $this->actingAs($this->user)->postJson('/api/questions', [
            'description' => 'Test description',
            'latitude' => 35.6595,
            'longitude' => 139.7004,
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['title']);
    }

    public function test_validation_fails_when_title_too_long(): void
    {
        $response = $this->actingAs($this->user)->postJson('/api/questions', [
            'title' => str_repeat('a', 101),
            'latitude' => 35.6595,
            'longitude' => 139.7004,
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['title']);
    }

    public function test_validation_fails_when_description_too_long(): void
    {
        $response = $this->actingAs($this->user)->postJson('/api/questions', [
            'title' => 'Valid title',
            'description' => str_repeat('a', 501),
            'latitude' => 35.6595,
            'longitude' => 139.7004,
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['description']);
    }

    public function test_validation_fails_when_latitude_invalid(): void
    {
        $response = $this->actingAs($this->user)->postJson('/api/questions', [
            'title' => 'Test Question',
            'latitude' => 200,
            'longitude' => 139.7004,
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['latitude']);
    }

    public function test_validation_fails_when_longitude_invalid(): void
    {
        $response = $this->actingAs($this->user)->postJson('/api/questions', [
            'title' => 'Test Question',
            'latitude' => 35.6595,
            'longitude' => 200,
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['longitude']);
    }

    public function test_validation_fails_when_coordinates_missing(): void
    {
        $response = $this->actingAs($this->user)->postJson('/api/questions', [
            'title' => 'Test Question',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['latitude', 'longitude']);
    }

    public function test_unauthorized_user_cannot_create_question(): void
    {
        $response = $this->postJson('/api/questions', [
            'title' => 'Test Question',
            'latitude' => 35.6595,
            'longitude' => 139.7004,
        ]);

        $response->assertUnauthorized();
    }

    public function test_banned_user_cannot_create_question(): void
    {
        $bannedUser = User::factory()->banned()->create();

        $response = $this->actingAs($bannedUser)->postJson('/api/questions', [
            'title' => 'Test Question',
            'latitude' => 35.6595,
            'longitude' => 139.7004,
        ]);

        $response->assertForbidden();
    }

    public function test_location_name_populated_from_geocoding(): void
    {
        $this->fakeGeocodingSuccess();

        $response = $this->actingAs($this->user)->postJson('/api/questions', [
            'title' => 'Test geocoding',
            'latitude' => 35.6595,
            'longitude' => 139.7004,
        ]);

        $response->assertCreated()
            ->assertJsonPath('data.location_name', 'Shibuya, Tokyo, Japan')
            ->assertJsonPath('data.city', 'Tokyo');

        Http::assertSent(function ($request) {
            return str_contains($request->url(), 'maps.googleapis.com');
        });
    }

    public function test_geocoding_fallback_on_api_failure(): void
    {
        Cache::flush();

        Http::fake([
            'maps.googleapis.com/*' => Http::response([], 500),
        ]);

        $response = $this->actingAs($this->user)->postJson('/api/questions', [
            'title' => 'Test fallback',
            'latitude' => 34.0522,
            'longitude' => 135.7681,
        ]);

        $response->assertCreated()
            ->assertJsonPath('data.location_name', '34.0522, 135.7681');
    }
}

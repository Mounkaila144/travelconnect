<?php

namespace Tests\Feature\Questions;

use App\Models\Question;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

class GetNearbyQuestionsTest extends TestCase
{
    use RefreshDatabase;

    private User $user;

    protected function setUp(): void
    {
        parent::setUp();
        $this->user = User::factory()->create();
    }

    public function test_returns_questions_within_radius(): void
    {
        // Near Tokyo center (35.6762, 139.6503)
        Question::factory()->at(35.6762, 139.6503)->create();

        // Far from Tokyo (~50km away)
        Question::factory()->at(36.0, 140.0)->create();

        $response = $this->actingAs($this->user)
            ->getJson('/api/questions?lat=35.6762&lng=139.6503&radius=10');

        $response->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonStructure([
                'data' => [
                    '*' => [
                        'id',
                        'title',
                        'description',
                        'latitude',
                        'longitude',
                        'location_name',
                        'city',
                        'answers_count',
                        'has_answers',
                        'has_unread_answers',
                        'created_at',
                        'user',
                    ],
                ],
                'meta' => [
                    'current_page',
                    'last_page',
                    'per_page',
                    'total',
                ],
            ]);
    }

    public function test_returns_empty_array_when_no_questions_in_area(): void
    {
        $response = $this->actingAs($this->user)
            ->getJson('/api/questions?lat=35.6762&lng=139.6503&radius=1');

        $response->assertOk()
            ->assertJsonCount(0, 'data');
    }

    public function test_paginates_results_correctly(): void
    {
        // Create 25 questions at same location
        for ($i = 0; $i < 25; $i++) {
            Question::factory()->at(35.6762, 139.6503)->create();
        }

        $response = $this->actingAs($this->user)
            ->getJson('/api/questions?lat=35.6762&lng=139.6503&radius=10&page=1');

        $response->assertOk()
            ->assertJsonCount(20, 'data')
            ->assertJsonPath('meta.current_page', 1)
            ->assertJsonPath('meta.last_page', 2)
            ->assertJsonPath('meta.per_page', 20);
    }

    public function test_limits_maximum_to_100_questions(): void
    {
        // Create 110 questions
        for ($i = 0; $i < 110; $i++) {
            Question::factory()->at(35.6762, 139.6503)->create();
        }

        // Page 6 should return empty (max 5 pages * 20 per page = 100)
        $response = $this->actingAs($this->user)
            ->getJson('/api/questions?lat=35.6762&lng=139.6503&radius=10&page=6');

        $response->assertOk()
            ->assertJsonCount(0, 'data');
    }

    public function test_includes_user_relationship(): void
    {
        $author = User::factory()->create(['name' => 'John Doe']);

        Question::factory()->at(35.6762, 139.6503)->create([
            'user_id' => $author->id,
        ]);

        $response = $this->actingAs($this->user)
            ->getJson('/api/questions?lat=35.6762&lng=139.6503&radius=10');

        $response->assertOk()
            ->assertJsonPath('data.0.user.name', 'John Doe');
    }

    public function test_answers_count_is_accurate(): void
    {
        Question::factory()->at(35.6762, 139.6503)->withAnswers(5)->create();

        $response = $this->actingAs($this->user)
            ->getJson('/api/questions?lat=35.6762&lng=139.6503&radius=10');

        $response->assertOk()
            ->assertJsonPath('data.0.answers_count', 5)
            ->assertJsonPath('data.0.has_answers', true);
    }

    public function test_questions_without_answers_show_correct_flags(): void
    {
        Question::factory()->at(35.6762, 139.6503)->create([
            'answers_count' => 0,
        ]);

        $response = $this->actingAs($this->user)
            ->getJson('/api/questions?lat=35.6762&lng=139.6503&radius=10');

        $response->assertOk()
            ->assertJsonPath('data.0.answers_count', 0)
            ->assertJsonPath('data.0.has_answers', false);
    }

    public function test_excludes_deleted_questions(): void
    {
        Question::factory()->at(35.6762, 139.6503)->create();
        Question::factory()->at(35.6762, 139.6503)->deleted()->create();

        $response = $this->actingAs($this->user)
            ->getJson('/api/questions?lat=35.6762&lng=139.6503&radius=10');

        $response->assertOk()
            ->assertJsonCount(1, 'data');
    }

    public function test_default_radius_is_10km(): void
    {
        // Question at center
        Question::factory()->at(35.6762, 139.6503)->create();

        // Question ~15km away
        Question::factory()->at(35.8000, 139.6503)->create();

        $response = $this->actingAs($this->user)
            ->getJson('/api/questions?lat=35.6762&lng=139.6503');

        $response->assertOk()
            ->assertJsonCount(1, 'data');
    }

    public function test_validates_lat_required(): void
    {
        $response = $this->actingAs($this->user)
            ->getJson('/api/questions?lng=139.6503');

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['lat']);
    }

    public function test_validates_lng_required(): void
    {
        $response = $this->actingAs($this->user)
            ->getJson('/api/questions?lat=35.6762');

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['lng']);
    }

    public function test_validates_lat_range(): void
    {
        $response = $this->actingAs($this->user)
            ->getJson('/api/questions?lat=91&lng=139.6503');

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['lat']);
    }

    public function test_validates_lng_range(): void
    {
        $response = $this->actingAs($this->user)
            ->getJson('/api/questions?lat=35.6762&lng=181');

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['lng']);
    }

    public function test_validates_radius_range(): void
    {
        $response = $this->actingAs($this->user)
            ->getJson('/api/questions?lat=35.6762&lng=139.6503&radius=51');

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['radius']);
    }

    public function test_unauthenticated_user_cannot_access(): void
    {
        $response = $this->getJson('/api/questions?lat=35.6762&lng=139.6503');

        $response->assertStatus(401);
    }

    public function test_banned_user_cannot_access(): void
    {
        $bannedUser = User::factory()->banned()->create();

        $response = $this->actingAs($bannedUser)
            ->getJson('/api/questions?lat=35.6762&lng=139.6503');

        $response->assertStatus(403)
            ->assertJsonPath('error.code', 'USER_BANNED');
    }

    public function test_orders_by_newest_first(): void
    {
        $older = Question::factory()->at(35.6762, 139.6503)->create([
            'title' => 'Older question',
            'created_at' => now()->subDays(2),
        ]);

        $newer = Question::factory()->at(35.6762, 139.6503)->create([
            'title' => 'Newer question',
            'created_at' => now()->subDay(),
        ]);

        $response = $this->actingAs($this->user)
            ->getJson('/api/questions?lat=35.6762&lng=139.6503&radius=10');

        $response->assertOk()
            ->assertJsonPath('data.0.title', 'Newer question')
            ->assertJsonPath('data.1.title', 'Older question');
    }

    public function test_includes_distance_meters(): void
    {
        Question::factory()->at(35.6762, 139.6503)->create();

        $response = $this->actingAs($this->user)
            ->getJson('/api/questions?lat=35.6762&lng=139.6503&radius=10');

        $response->assertOk();

        $data = $response->json('data.0');
        $this->assertArrayHasKey('distance_meters', $data);
    }
}

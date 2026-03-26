<?php

namespace Tests\Feature\Questions;

use App\Models\Question;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class QuestionsFeedTest extends TestCase
{
    use RefreshDatabase;

    public function test_feed_returns_questions_sorted_by_recent(): void
    {
        $user = User::factory()->create();

        $oldQuestion = Question::factory()->create([
            'title' => 'Old Question',
            'created_at' => now()->subDays(2),
        ]);

        $newQuestion = Question::factory()->create([
            'title' => 'New Question',
            'created_at' => now()->subHours(1),
        ]);

        $response = $this->actingAs($user)->getJson('/api/questions?sort=recent');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'data' => [
                    '*' => ['id', 'title', 'location_name', 'city', 'answers_count', 'created_at', 'user'],
                ],
            ]);

        $questions = $response->json('data');
        $this->assertEquals($newQuestion->id, $questions[0]['id']);
        $this->assertEquals($oldQuestion->id, $questions[1]['id']);
    }

    public function test_feed_returns_questions_sorted_by_popular(): void
    {
        $user = User::factory()->create();

        $lessPopular = Question::factory()->create([
            'answers_count' => 1,
            'created_at' => now()->subHours(1),
        ]);

        $morePopular = Question::factory()->create([
            'answers_count' => 10,
            'created_at' => now()->subHours(2),
        ]);

        $response = $this->actingAs($user)->getJson('/api/questions?sort=popular');

        $response->assertStatus(200);

        $questions = $response->json('data');
        $this->assertEquals($morePopular->id, $questions[0]['id']);
        $this->assertEquals($lessPopular->id, $questions[1]['id']);
    }

    public function test_feed_filters_by_city(): void
    {
        $user = User::factory()->create();

        Question::factory()->create(['city' => 'Tokyo']);
        Question::factory()->create(['city' => 'Tokyo']);
        Question::factory()->create(['city' => 'Kyoto']);

        $response = $this->actingAs($user)->getJson('/api/questions?sort=recent&city=Tokyo');

        $response->assertStatus(200);

        $questions = $response->json('data');
        $this->assertCount(2, $questions);

        foreach ($questions as $question) {
            $this->assertEquals('Tokyo', $question['city']);
        }
    }

    public function test_feed_pagination_works(): void
    {
        $user = User::factory()->create();

        Question::factory()->count(25)->create();

        $response = $this->actingAs($user)->getJson('/api/questions?sort=recent&page=1');

        $response->assertStatus(200);
        $this->assertCount(20, $response->json('data'));

        $meta = $response->json('meta');
        $this->assertEquals(1, $meta['current_page']);
        $this->assertEquals(25, $meta['total']);
        $this->assertEquals(2, $meta['last_page']);

        $response2 = $this->actingAs($user)->getJson('/api/questions?sort=recent&page=2');
        $this->assertCount(5, $response2->json('data'));
    }

    public function test_feed_excludes_deleted_questions(): void
    {
        $user = User::factory()->create();

        Question::factory()->create(['is_deleted' => false]);
        Question::factory()->create(['is_deleted' => true]);

        $response = $this->actingAs($user)->getJson('/api/questions?sort=recent');

        $this->assertCount(1, $response->json('data'));
    }

    public function test_popular_cities_returns_cities_with_counts(): void
    {
        $user = User::factory()->create();

        Question::factory()->count(5)->create(['city' => 'Tokyo']);
        Question::factory()->count(3)->create(['city' => 'Kyoto']);
        Question::factory()->count(1)->create(['city' => 'Osaka']);

        $response = $this->actingAs($user)->getJson('/api/questions/cities');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'data' => [
                    '*' => ['city', 'questions_count'],
                ],
            ]);

        $cities = $response->json('data');
        $this->assertEquals('Tokyo', $cities[0]['city']);
        $this->assertEquals(5, $cities[0]['questions_count']);
        $this->assertEquals('Kyoto', $cities[1]['city']);
    }

    public function test_feed_validates_sort_parameter(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)->getJson('/api/questions?sort=invalid');

        $response->assertStatus(422);
    }
}

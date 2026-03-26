<?php

namespace Tests\Feature\Answers;

use App\Models\Answer;
use App\Models\Question;
use App\Models\Rating;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

class ListAnswersTest extends TestCase
{
    use RefreshDatabase;

    public function test_answers_are_sorted_by_rating_then_date(): void
    {
        $user = User::factory()->create();
        $question = Question::factory()->create();

        $lowRated = Answer::factory()->create([
            'question_id' => $question->id,
            'average_rating' => 3.5,
            'created_at' => now()->subHours(2),
        ]);

        $highRated = Answer::factory()->create([
            'question_id' => $question->id,
            'average_rating' => 4.5,
            'created_at' => now()->subHours(1),
        ]);

        $unrated = Answer::factory()->create([
            'question_id' => $question->id,
            'average_rating' => 0.0,
            'created_at' => now(),
        ]);

        $response = $this->actingAs($user)->getJson("/api/questions/{$question->id}");

        $response->assertOk();
        $answerIds = collect($response->json('data.answers'))->pluck('id')->toArray();

        // Highest rating first (4.5), then lower (3.5), then unrated (0.0)
        $this->assertEquals([$highRated->id, $lowRated->id, $unrated->id], $answerIds);
    }

    public function test_answers_with_same_rating_sorted_by_date_desc(): void
    {
        $user = User::factory()->create();
        $question = Question::factory()->create();

        $older = Answer::factory()->create([
            'question_id' => $question->id,
            'average_rating' => 4.0,
            'created_at' => now()->subHours(2),
        ]);

        $newer = Answer::factory()->create([
            'question_id' => $question->id,
            'average_rating' => 4.0,
            'created_at' => now()->subHours(1),
        ]);

        $response = $this->actingAs($user)->getJson("/api/questions/{$question->id}");

        $answerIds = collect($response->json('data.answers'))->pluck('id')->toArray();

        // Same rating, newer first
        $this->assertEquals([$newer->id, $older->id], $answerIds);
    }

    public function test_user_rating_is_included_when_user_has_rated(): void
    {
        $user = User::factory()->create();
        $question = Question::factory()->create();
        $answer = Answer::factory()->create(['question_id' => $question->id]);

        Rating::factory()->create([
            'answer_id' => $answer->id,
            'user_id' => $user->id,
            'score' => 4,
        ]);

        $response = $this->actingAs($user)->getJson("/api/questions/{$question->id}");

        $response->assertOk();
        $response->assertJsonPath('data.answers.0.user_rating', 4);
    }

    public function test_user_rating_is_null_when_user_has_not_rated(): void
    {
        $user = User::factory()->create();
        $question = Question::factory()->create();
        Answer::factory()->create(['question_id' => $question->id]);

        $response = $this->actingAs($user)->getJson("/api/questions/{$question->id}");

        $response->assertOk();
        $response->assertJsonPath('data.answers.0.user_rating', null);
    }

    public function test_user_rating_only_shows_current_user_rating(): void
    {
        $user = User::factory()->create();
        $otherUser = User::factory()->create();
        $question = Question::factory()->create();
        $answer = Answer::factory()->create(['question_id' => $question->id]);

        // Other user rated, not current user
        Rating::factory()->create([
            'answer_id' => $answer->id,
            'user_id' => $otherUser->id,
            'score' => 5,
        ]);

        $response = $this->actingAs($user)->getJson("/api/questions/{$question->id}");

        $response->assertOk();
        $response->assertJsonPath('data.answers.0.user_rating', null);
    }

    public function test_deleted_answers_are_excluded(): void
    {
        $user = User::factory()->create();
        $question = Question::factory()->create();

        Answer::factory()->create([
            'question_id' => $question->id,
            'is_deleted' => false,
        ]);

        Answer::factory()->deleted()->create([
            'question_id' => $question->id,
        ]);

        $response = $this->actingAs($user)->getJson("/api/questions/{$question->id}");

        $response->assertOk();
        $response->assertJsonCount(1, 'data.answers');
    }

    public function test_answer_includes_user_data(): void
    {
        $author = User::factory()->create([
            'name' => 'Sato Kenji',
            'user_type' => 'local_supporter',
            'trust_score' => 4.8,
        ]);

        $question = Question::factory()->create();
        Answer::factory()->create([
            'question_id' => $question->id,
            'user_id' => $author->id,
        ]);

        $viewer = User::factory()->create();
        $response = $this->actingAs($viewer)->getJson("/api/questions/{$question->id}");

        $response->assertOk();
        $answerUser = $response->json('data.answers.0.user');
        $this->assertEquals('Sato Kenji', $answerUser['name']);
        $this->assertEquals('local_supporter', $answerUser['user_type']);
        $this->assertEquals(4.8, $answerUser['trust_score']);
    }

    public function test_answer_resource_contains_all_fields(): void
    {
        $user = User::factory()->create();
        $question = Question::factory()->create();
        Answer::factory()->rated(4.5, 10)->create([
            'question_id' => $question->id,
            'content' => 'Je recommande Ichiran Ramen',
        ]);

        $response = $this->actingAs($user)->getJson("/api/questions/{$question->id}");

        $response->assertOk();
        $answer = $response->json('data.answers.0');
        $this->assertArrayHasKey('id', $answer);
        $this->assertArrayHasKey('content', $answer);
        $this->assertArrayHasKey('average_rating', $answer);
        $this->assertArrayHasKey('ratings_count', $answer);
        $this->assertArrayHasKey('created_at', $answer);
        $this->assertArrayHasKey('user', $answer);
        $this->assertArrayHasKey('user_rating', $answer);
        $this->assertEquals('Je recommande Ichiran Ramen', $answer['content']);
        $this->assertEquals(4.5, $answer['average_rating']);
        $this->assertEquals(10, $answer['ratings_count']);
    }

    public function test_eager_loading_prevents_n_plus_1(): void
    {
        $user = User::factory()->create();
        $question = Question::factory()->create();
        Answer::factory()->count(10)->create(['question_id' => $question->id]);

        DB::enableQueryLog();
        $this->actingAs($user)->getJson("/api/questions/{$question->id}");
        $queries = DB::getQueryLog();

        // Should be efficient: question + answers + users + ratings + user update
        // Certainly less than 10 queries for 10 answers
        $this->assertLessThan(10, count($queries));
    }

    public function test_question_with_no_answers_returns_empty_array(): void
    {
        $user = User::factory()->create();
        $question = Question::factory()->create();

        $response = $this->actingAs($user)->getJson("/api/questions/{$question->id}");

        $response->assertOk();
        $response->assertJsonCount(0, 'data.answers');
    }

    public function test_unauthenticated_user_cannot_view_question_detail(): void
    {
        $question = Question::factory()->create();

        $response = $this->getJson("/api/questions/{$question->id}");

        $response->assertUnauthorized();
    }
}

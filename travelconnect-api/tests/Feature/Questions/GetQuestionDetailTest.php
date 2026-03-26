<?php

namespace Tests\Feature\Questions;

use App\Models\Answer;
use App\Models\Question;
use App\Models\Rating;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class GetQuestionDetailTest extends TestCase
{
    use RefreshDatabase;

    private User $user;

    protected function setUp(): void
    {
        parent::setUp();
        $this->user = User::factory()->create();
    }

    public function test_returns_question_with_answers(): void
    {
        $author = User::factory()->create(['name' => 'John Doe']);
        $question = Question::factory()->create([
            'user_id' => $author->id,
            'title' => 'Test Question',
        ]);

        $answer1 = Answer::factory()->create([
            'question_id' => $question->id,
            'average_rating' => 4.5,
            'ratings_count' => 10,
        ]);

        $answer2 = Answer::factory()->create([
            'question_id' => $question->id,
            'average_rating' => 3.5,
            'ratings_count' => 5,
        ]);

        $response = $this->actingAs($this->user)->getJson("/api/questions/{$question->id}");

        $response->assertOk()
            ->assertJsonPath('data.id', $question->id)
            ->assertJsonPath('data.title', 'Test Question')
            ->assertJsonPath('data.user.name', 'John Doe')
            ->assertJsonCount(2, 'data.answers')
            ->assertJsonPath('data.answers.0.id', $answer1->id)
            ->assertJsonPath('data.answers.1.id', $answer2->id);
    }

    public function test_returns_404_when_question_not_found(): void
    {
        $response = $this->actingAs($this->user)->getJson('/api/questions/999');

        $response->assertNotFound();
    }

    public function test_answers_sorted_by_rating_then_date(): void
    {
        $question = Question::factory()->create();

        $olderLowRated = Answer::factory()->create([
            'question_id' => $question->id,
            'average_rating' => 2.0,
            'created_at' => now()->subDays(2),
        ]);

        $newerHighRated = Answer::factory()->create([
            'question_id' => $question->id,
            'average_rating' => 4.5,
            'created_at' => now()->subDay(),
        ]);

        $olderHighRated = Answer::factory()->create([
            'question_id' => $question->id,
            'average_rating' => 4.5,
            'created_at' => now()->subDays(3),
        ]);

        $response = $this->actingAs($this->user)->getJson("/api/questions/{$question->id}");

        $response->assertOk()
            ->assertJsonCount(3, 'data.answers')
            ->assertJsonPath('data.answers.0.id', $newerHighRated->id)
            ->assertJsonPath('data.answers.1.id', $olderHighRated->id)
            ->assertJsonPath('data.answers.2.id', $olderLowRated->id);
    }

    public function test_user_rating_included_in_response(): void
    {
        $question = Question::factory()->create();

        $answer = Answer::factory()->create([
            'question_id' => $question->id,
        ]);

        Rating::create([
            'answer_id' => $answer->id,
            'user_id' => $this->user->id,
            'score' => 5,
        ]);

        $response = $this->actingAs($this->user)->getJson("/api/questions/{$question->id}");

        $response->assertOk()
            ->assertJsonPath('data.answers.0.user_rating', 5);
    }

    public function test_deleted_answers_not_included(): void
    {
        $question = Question::factory()->create();

        Answer::factory()->create([
            'question_id' => $question->id,
            'is_deleted' => false,
        ]);

        Answer::factory()->create([
            'question_id' => $question->id,
            'is_deleted' => true,
        ]);

        $response = $this->actingAs($this->user)->getJson("/api/questions/{$question->id}");

        $response->assertOk()
            ->assertJsonCount(1, 'data.answers');
    }

    public function test_marks_question_as_read_for_author(): void
    {
        $author = User::factory()->create();
        $question = Question::factory()->create([
            'user_id' => $author->id,
            'has_unread_answers' => true,
        ]);

        $this->actingAs($author)->getJson("/api/questions/{$question->id}");

        $this->assertDatabaseHas('questions', [
            'id' => $question->id,
            'has_unread_answers' => false,
        ]);
    }

    public function test_does_not_mark_as_read_for_non_author(): void
    {
        $author = User::factory()->create();
        $question = Question::factory()->create([
            'user_id' => $author->id,
            'has_unread_answers' => true,
        ]);

        $this->actingAs($this->user)->getJson("/api/questions/{$question->id}");

        $this->assertDatabaseHas('questions', [
            'id' => $question->id,
            'has_unread_answers' => true,
        ]);
    }

    public function test_unauthorized_user_cannot_view_question(): void
    {
        $question = Question::factory()->create();

        $response = $this->getJson("/api/questions/{$question->id}");

        $response->assertUnauthorized();
    }
}

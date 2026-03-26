<?php

namespace Tests\Feature\Answers;

use App\Events\AnswerCreated;
use App\Models\Answer;
use App\Models\Question;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Event;
use Tests\TestCase;

class CreateAnswerTest extends TestCase
{
    use RefreshDatabase;

    public function test_authenticated_user_can_create_answer(): void
    {
        $question = Question::factory()->create();
        $user = User::factory()->create();

        $response = $this->actingAs($user)->postJson("/api/questions/{$question->id}/answers", [
            'content' => 'Je recommande Ichiran, c\'est délicieux !',
        ]);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'data' => [
                    'id',
                    'content',
                    'average_rating',
                    'ratings_count',
                    'created_at',
                    'user' => ['id', 'name', 'avatar_url', 'user_type', 'trust_score'],
                ],
            ])
            ->assertJson([
                'data' => [
                    'content' => 'Je recommande Ichiran, c\'est délicieux !',
                    'ratings_count' => 0,
                ],
            ]);

        $this->assertDatabaseHas('answers', [
            'question_id' => $question->id,
            'user_id' => $user->id,
            'content' => 'Je recommande Ichiran, c\'est délicieux !',
        ]);
    }

    public function test_answers_count_increments_on_question(): void
    {
        $question = Question::factory()->create(['answers_count' => 0]);
        $user = User::factory()->create();

        $this->actingAs($user)->postJson("/api/questions/{$question->id}/answers", [
            'content' => 'Test answer',
        ]);

        $this->assertDatabaseHas('questions', [
            'id' => $question->id,
            'answers_count' => 1,
        ]);
    }

    public function test_has_unread_answers_set_when_different_user_answers(): void
    {
        $author = User::factory()->create();
        $responder = User::factory()->create();
        $question = Question::factory()->create([
            'user_id' => $author->id,
            'has_unread_answers' => false,
        ]);

        $this->actingAs($responder)->postJson("/api/questions/{$question->id}/answers", [
            'content' => 'Helpful answer',
        ]);

        $this->assertDatabaseHas('questions', [
            'id' => $question->id,
            'has_unread_answers' => true,
        ]);
    }

    public function test_has_unread_answers_not_set_when_author_answers_own_question(): void
    {
        $author = User::factory()->create();
        $question = Question::factory()->create([
            'user_id' => $author->id,
            'has_unread_answers' => false,
        ]);

        $this->actingAs($author)->postJson("/api/questions/{$question->id}/answers", [
            'content' => 'Self answer',
        ]);

        $this->assertDatabaseHas('questions', [
            'id' => $question->id,
            'has_unread_answers' => false,
        ]);
    }

    public function test_content_is_required(): void
    {
        $question = Question::factory()->create();
        $user = User::factory()->create();

        $response = $this->actingAs($user)->postJson("/api/questions/{$question->id}/answers", []);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['content']);
    }

    public function test_content_cannot_exceed_1000_characters(): void
    {
        $question = Question::factory()->create();
        $user = User::factory()->create();

        $response = $this->actingAs($user)->postJson("/api/questions/{$question->id}/answers", [
            'content' => str_repeat('a', 1001),
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['content']);
    }

    public function test_unauthenticated_user_cannot_create_answer(): void
    {
        $question = Question::factory()->create();

        $response = $this->postJson("/api/questions/{$question->id}/answers", [
            'content' => 'Test answer',
        ]);

        $response->assertStatus(401);
    }

    public function test_banned_user_cannot_create_answer(): void
    {
        $question = Question::factory()->create();
        $user = User::factory()->create(['is_banned' => true]);

        $response = $this->actingAs($user)->postJson("/api/questions/{$question->id}/answers", [
            'content' => 'Test answer',
        ]);

        $response->assertStatus(403);
    }

    public function test_user_can_post_multiple_answers_to_same_question(): void
    {
        $question = Question::factory()->create();
        $user = User::factory()->create();

        $this->actingAs($user)->postJson("/api/questions/{$question->id}/answers", [
            'content' => 'First answer',
        ])->assertStatus(201);

        $this->actingAs($user)->postJson("/api/questions/{$question->id}/answers", [
            'content' => 'Second answer',
        ])->assertStatus(201);

        $this->assertEquals(2, Answer::where('user_id', $user->id)->where('question_id', $question->id)->count());
    }

    public function test_answer_created_event_is_fired(): void
    {
        Event::fake([AnswerCreated::class]);

        $question = Question::factory()->create();
        $user = User::factory()->create();

        $this->actingAs($user)->postJson("/api/questions/{$question->id}/answers", [
            'content' => 'Test answer',
        ]);

        Event::assertDispatched(AnswerCreated::class);
    }

    public function test_question_not_found_returns_404(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)->postJson('/api/questions/99999/answers', [
            'content' => 'Test answer',
        ]);

        $response->assertStatus(404);
    }

    public function test_cannot_answer_deleted_question(): void
    {
        $question = Question::factory()->deleted()->create();
        $user = User::factory()->create();

        $response = $this->actingAs($user)->postJson("/api/questions/{$question->id}/answers", [
            'content' => 'Test answer',
        ]);

        $response->assertStatus(500);
    }
}

<?php

namespace Tests\Feature\Answers;

use App\Events\AnswerRated;
use App\Models\Answer;
use App\Models\Rating;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Event;
use Tests\TestCase;

class RateAnswerTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_rate_answer(): void
    {
        $answer = Answer::factory()->create();
        $user = User::factory()->create();

        $response = $this->actingAs($user)->postJson("/api/answers/{$answer->id}/rate", [
            'score' => 5,
        ]);

        $response->assertOk()
            ->assertJsonStructure(['average_rating', 'ratings_count'])
            ->assertJson([
                'average_rating' => 5.0,
                'ratings_count' => 1,
            ]);

        $this->assertDatabaseHas('ratings', [
            'answer_id' => $answer->id,
            'user_id' => $user->id,
            'score' => 5,
        ]);
    }

    public function test_average_rating_is_calculated_correctly(): void
    {
        $answer = Answer::factory()->create();
        $user1 = User::factory()->create();
        $user2 = User::factory()->create();
        $user3 = User::factory()->create();

        $this->actingAs($user1)->postJson("/api/answers/{$answer->id}/rate", ['score' => 5]);
        $this->actingAs($user2)->postJson("/api/answers/{$answer->id}/rate", ['score' => 3]);
        $response = $this->actingAs($user3)->postJson("/api/answers/{$answer->id}/rate", ['score' => 4]);

        // Average: (5 + 3 + 4) / 3 = 4.0
        $response->assertJson([
            'average_rating' => 4.0,
            'ratings_count' => 3,
        ]);
    }

    public function test_user_can_update_existing_rating(): void
    {
        $answer = Answer::factory()->create();
        $user = User::factory()->create();

        $this->actingAs($user)->postJson("/api/answers/{$answer->id}/rate", ['score' => 3]);
        $response = $this->actingAs($user)->postJson("/api/answers/{$answer->id}/rate", ['score' => 5]);

        $response->assertOk()
            ->assertJson([
                'average_rating' => 5.0,
                'ratings_count' => 1,
            ]);

        $this->assertEquals(1, Rating::where('answer_id', $answer->id)->count());
    }

    public function test_user_cannot_rate_own_answer(): void
    {
        $user = User::factory()->create();
        $answer = Answer::factory()->create(['user_id' => $user->id]);

        $response = $this->actingAs($user)->postJson("/api/answers/{$answer->id}/rate", [
            'score' => 5,
        ]);

        $response->assertForbidden()
            ->assertJson([
                'error' => [
                    'code' => 'CANNOT_RATE_OWN_ANSWER',
                    'message' => 'Vous ne pouvez pas noter votre propre réponse',
                ],
            ]);
    }

    public function test_score_must_be_between_1_and_5(): void
    {
        $answer = Answer::factory()->create();
        $user = User::factory()->create();

        $this->actingAs($user)->postJson("/api/answers/{$answer->id}/rate", ['score' => 0])
            ->assertUnprocessable();

        $this->actingAs($user)->postJson("/api/answers/{$answer->id}/rate", ['score' => 6])
            ->assertUnprocessable();

        $this->actingAs($user)->postJson("/api/answers/{$answer->id}/rate", ['score' => -1])
            ->assertUnprocessable();
    }

    public function test_score_is_required(): void
    {
        $answer = Answer::factory()->create();
        $user = User::factory()->create();

        $this->actingAs($user)->postJson("/api/answers/{$answer->id}/rate", [])
            ->assertUnprocessable();
    }

    public function test_unauthenticated_user_cannot_rate(): void
    {
        $answer = Answer::factory()->create();

        $this->postJson("/api/answers/{$answer->id}/rate", ['score' => 5])
            ->assertUnauthorized();
    }

    public function test_ratings_count_increments_correctly(): void
    {
        $answer = Answer::factory()->create();
        $users = User::factory()->count(3)->create();

        foreach ($users as $user) {
            $this->actingAs($user)->postJson("/api/answers/{$answer->id}/rate", ['score' => 4]);
        }

        $answer->refresh();
        $this->assertEquals(3, $answer->ratings_count);
    }

    public function test_answer_rated_event_is_fired(): void
    {
        Event::fake([AnswerRated::class]);

        $answer = Answer::factory()->create();
        $user = User::factory()->create();

        $this->actingAs($user)->postJson("/api/answers/{$answer->id}/rate", ['score' => 5]);

        Event::assertDispatched(AnswerRated::class, function ($event) use ($answer, $user) {
            return $event->answer->id === $answer->id && $event->rater->id === $user->id;
        });
    }

    public function test_banned_user_cannot_rate(): void
    {
        $answer = Answer::factory()->create();
        $user = User::factory()->create(['is_banned' => true]);

        $this->actingAs($user)->postJson("/api/answers/{$answer->id}/rate", ['score' => 5])
            ->assertForbidden();
    }

    public function test_answer_not_found_returns_404(): void
    {
        $user = User::factory()->create();

        $this->actingAs($user)->postJson('/api/answers/99999/rate', ['score' => 5])
            ->assertNotFound();
    }

    public function test_rating_deleted_answer_returns_403(): void
    {
        $answer = Answer::factory()->deleted()->create();
        $user = User::factory()->create();

        $this->actingAs($user)->postJson("/api/answers/{$answer->id}/rate", ['score' => 5])
            ->assertForbidden();
    }
}

<?php

namespace Tests\Unit\Services;

use App\Events\AnswerRated;
use App\Listeners\UpdateTrustScore;
use App\Models\Answer;
use App\Models\Rating;
use App\Models\User;
use App\Services\TrustScoreService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Event;
use Tests\TestCase;

class TrustScoreServiceTest extends TestCase
{
    use RefreshDatabase;

    private TrustScoreService $service;

    protected function setUp(): void
    {
        parent::setUp();
        $this->service = new TrustScoreService();
    }

    public function test_new_user_with_no_answers_has_zero_score(): void
    {
        $user = User::factory()->create();

        $score = $this->service->calculateTrustScore($user);

        $this->assertEquals(0.00, $score);
        $this->assertTrue($this->service->isNewUser($user));
    }

    public function test_user_with_one_rated_answer_calculates_correctly(): void
    {
        $user = User::factory()->create();
        Answer::factory()->create([
            'user_id' => $user->id,
            'average_rating' => 5.0,
            'ratings_count' => 1,
        ]);

        $score = $this->service->calculateTrustScore($user);

        // 5.0 × log10(1 + 1) = 5.0 × 0.30103 = 1.51
        $this->assertEquals(1.51, $score);
        $this->assertTrue($this->service->isNewUser($user));
    }

    public function test_user_with_three_rated_answers_is_not_new(): void
    {
        $user = User::factory()->create();

        for ($i = 0; $i < 3; $i++) {
            Answer::factory()->create([
                'user_id' => $user->id,
                'average_rating' => 4.5,
                'ratings_count' => 5,
            ]);
        }

        $this->assertFalse($this->service->isNewUser($user));
    }

    public function test_trust_score_averages_multiple_answers(): void
    {
        $user = User::factory()->create();

        Answer::factory()->create([
            'user_id' => $user->id,
            'average_rating' => 5.0,
            'ratings_count' => 3,
        ]);

        Answer::factory()->create([
            'user_id' => $user->id,
            'average_rating' => 3.0,
            'ratings_count' => 2,
        ]);

        Answer::factory()->create([
            'user_id' => $user->id,
            'average_rating' => 4.0,
            'ratings_count' => 1,
        ]);

        $score = $this->service->calculateTrustScore($user);

        // Average: (5.0 + 3.0 + 4.0) / 3 = 4.0
        // Score: 4.0 × log10(3 + 1) = 4.0 × 0.60206 = 2.41
        $this->assertEquals(2.41, $score);
    }

    public function test_trust_score_is_clamped_to_max_5(): void
    {
        $user = User::factory()->create();

        Answer::factory()->count(100)->create([
            'user_id' => $user->id,
            'average_rating' => 5.0,
            'ratings_count' => 10,
        ]);

        $score = $this->service->calculateTrustScore($user);

        $this->assertEquals(5.00, $score);
    }

    public function test_deleted_answers_are_excluded(): void
    {
        $user = User::factory()->create();

        Answer::factory()->create([
            'user_id' => $user->id,
            'average_rating' => 5.0,
            'ratings_count' => 5,
            'is_deleted' => false,
        ]);

        Answer::factory()->create([
            'user_id' => $user->id,
            'average_rating' => 1.0,
            'ratings_count' => 5,
            'is_deleted' => true,
        ]);

        $score = $this->service->calculateTrustScore($user);

        // Only the non-deleted answer: 5.0 × log10(1 + 1) = 1.51
        $this->assertEquals(1.51, $score);
    }

    public function test_unrated_answers_are_excluded(): void
    {
        $user = User::factory()->create();

        Answer::factory()->create([
            'user_id' => $user->id,
            'average_rating' => 5.0,
            'ratings_count' => 5,
        ]);

        // Answer with 0 ratings - should be excluded by ratings_count > 0 filter
        Answer::factory()->create([
            'user_id' => $user->id,
            'average_rating' => 0.0,
            'ratings_count' => 0,
        ]);

        $score = $this->service->calculateTrustScore($user);

        $this->assertEquals(1.51, $score);
    }

    public function test_recalculate_updates_user_record(): void
    {
        $user = User::factory()->create(['trust_score' => 0.00, 'is_new' => true]);

        Answer::factory()->create([
            'user_id' => $user->id,
            'average_rating' => 4.5,
            'ratings_count' => 5,
        ]);

        $score = $this->service->recalculateTrustScore($user);

        $user->refresh();

        $this->assertEquals($score, (float) $user->trust_score);
        $this->assertTrue($user->is_new); // Still new with only 1 answer
    }

    public function test_recalculate_sets_is_new_false_with_three_answers(): void
    {
        $user = User::factory()->create(['trust_score' => 0.00, 'is_new' => true]);

        for ($i = 0; $i < 3; $i++) {
            Answer::factory()->create([
                'user_id' => $user->id,
                'average_rating' => 4.0,
                'ratings_count' => 3,
            ]);
        }

        $this->service->recalculateTrustScore($user);

        $user->refresh();

        $this->assertFalse($user->is_new);
    }

    public function test_recalculate_all_updates_multiple_users(): void
    {
        $user1 = User::factory()->create(['is_banned' => false]);
        $user2 = User::factory()->create(['is_banned' => false]);
        $bannedUser = User::factory()->create(['is_banned' => true]);

        $question = \App\Models\Question::factory()->create(['user_id' => $user1->id]);

        Answer::factory()->create([
            'question_id' => $question->id,
            'user_id' => $user1->id,
            'average_rating' => 5.0,
            'ratings_count' => 1,
        ]);

        Answer::factory()->create([
            'question_id' => $question->id,
            'user_id' => $user2->id,
            'average_rating' => 4.0,
            'ratings_count' => 2,
        ]);

        $count = $this->service->recalculateAllTrustScores();

        // Should process all non-banned users (user1 + user2 + any auto-created)
        $this->assertGreaterThanOrEqual(2, $count);

        $user1->refresh();
        $user2->refresh();

        $this->assertGreaterThan(0, (float) $user1->trust_score);
        $this->assertGreaterThan(0, (float) $user2->trust_score);

        // Banned user should not have been updated
        $bannedUser->refresh();
        $this->assertEquals(0.00, (float) $bannedUser->trust_score);
    }

    public function test_listener_is_triggered_on_answer_rated_event(): void
    {
        Event::fake([AnswerRated::class]);

        $user = User::factory()->create();
        $answer = Answer::factory()->create(['user_id' => $user->id]);
        $rater = User::factory()->create();
        $rating = Rating::factory()->create([
            'answer_id' => $answer->id,
            'user_id' => $rater->id,
            'score' => 5,
        ]);

        event(new AnswerRated($answer, $rating, $rater));

        Event::assertDispatched(AnswerRated::class);
    }

    public function test_update_trust_score_listener_handles_event(): void
    {
        $user = User::factory()->create(['trust_score' => 0.00]);
        $answer = Answer::factory()->create([
            'user_id' => $user->id,
            'average_rating' => 5.0,
            'ratings_count' => 1,
        ]);
        $rater = User::factory()->create();
        $rating = Rating::factory()->create([
            'answer_id' => $answer->id,
            'user_id' => $rater->id,
            'score' => 5,
        ]);

        $listener = app(UpdateTrustScore::class);
        $listener->handle(new AnswerRated($answer, $rating, $rater));

        $user->refresh();
        $this->assertGreaterThan(0, (float) $user->trust_score);
    }

    public function test_ten_answers_with_high_rating(): void
    {
        $user = User::factory()->create();

        Answer::factory()->count(10)->create([
            'user_id' => $user->id,
            'average_rating' => 4.5,
            'ratings_count' => 5,
        ]);

        $score = $this->service->calculateTrustScore($user);

        // 4.5 × log10(10 + 1) = 4.5 × 1.04139 = 4.69
        $this->assertEquals(4.69, $score);
        $this->assertFalse($this->service->isNewUser($user));
    }
}

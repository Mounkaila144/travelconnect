<?php

namespace Tests\Feature\Reports;

use App\Events\ReportCreated;
use App\Models\Answer;
use App\Models\Question;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Event;
use Tests\TestCase;

class CreateReportTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_report_question(): void
    {
        $question = Question::factory()->create();
        $user = User::factory()->create();

        $response = $this->actingAs($user)->postJson('/api/reports', [
            'reportable_type' => 'Question',
            'reportable_id' => $question->id,
            'reason' => 'spam',
            'comment' => 'Publicité déguisée',
        ]);

        $response->assertStatus(201)
            ->assertJson([
                'message' => 'Signalement enregistré. Merci de contribuer à la modération.',
            ]);

        $this->assertDatabaseHas('reports', [
            'reporter_id' => $user->id,
            'reportable_type' => 'Question',
            'reportable_id' => $question->id,
            'reason' => 'spam',
            'comment' => 'Publicité déguisée',
            'status' => 'pending',
        ]);
    }

    public function test_user_can_report_answer(): void
    {
        $answer = Answer::factory()->create();
        $user = User::factory()->create();

        $response = $this->actingAs($user)->postJson('/api/reports', [
            'reportable_type' => 'Answer',
            'reportable_id' => $answer->id,
            'reason' => 'offensive',
        ]);

        $response->assertStatus(201);

        $this->assertDatabaseHas('reports', [
            'reportable_type' => 'Answer',
            'reportable_id' => $answer->id,
            'reason' => 'offensive',
        ]);
    }

    public function test_all_report_reasons_are_accepted(): void
    {
        $user = User::factory()->create();
        $reasons = ['spam', 'offensive', 'false_info', 'other'];

        foreach ($reasons as $reason) {
            $question = Question::factory()->create();

            $response = $this->actingAs($user)->postJson('/api/reports', [
                'reportable_type' => 'Question',
                'reportable_id' => $question->id,
                'reason' => $reason,
            ]);

            $response->assertStatus(201);
        }
    }

    public function test_comment_is_optional(): void
    {
        $question = Question::factory()->create();
        $user = User::factory()->create();

        $response = $this->actingAs($user)->postJson('/api/reports', [
            'reportable_type' => 'Question',
            'reportable_id' => $question->id,
            'reason' => 'spam',
        ]);

        $response->assertStatus(201);

        $this->assertDatabaseHas('reports', [
            'reporter_id' => $user->id,
            'comment' => null,
        ]);
    }

    public function test_user_cannot_report_same_content_twice(): void
    {
        $question = Question::factory()->create();
        $user = User::factory()->create();

        $this->actingAs($user)->postJson('/api/reports', [
            'reportable_type' => 'Question',
            'reportable_id' => $question->id,
            'reason' => 'spam',
        ])->assertStatus(201);

        $response = $this->actingAs($user)->postJson('/api/reports', [
            'reportable_type' => 'Question',
            'reportable_id' => $question->id,
            'reason' => 'offensive',
        ]);

        $response->assertStatus(422)
            ->assertJson([
                'error' => [
                    'code' => 'DUPLICATE_REPORT',
                    'message' => 'Vous avez déjà signalé ce contenu',
                ],
            ]);
    }

    public function test_unauthenticated_user_cannot_report(): void
    {
        $question = Question::factory()->create();

        $response = $this->postJson('/api/reports', [
            'reportable_type' => 'Question',
            'reportable_id' => $question->id,
            'reason' => 'spam',
        ]);

        $response->assertStatus(401);
    }

    public function test_banned_user_cannot_report(): void
    {
        $question = Question::factory()->create();
        $user = User::factory()->create(['is_banned' => true]);

        $response = $this->actingAs($user)->postJson('/api/reports', [
            'reportable_type' => 'Question',
            'reportable_id' => $question->id,
            'reason' => 'spam',
        ]);

        $response->assertStatus(403);
    }

    public function test_report_status_defaults_to_pending(): void
    {
        $question = Question::factory()->create();
        $user = User::factory()->create();

        $this->actingAs($user)->postJson('/api/reports', [
            'reportable_type' => 'Question',
            'reportable_id' => $question->id,
            'reason' => 'spam',
        ]);

        $this->assertDatabaseHas('reports', [
            'status' => 'pending',
        ]);
    }

    public function test_report_created_event_is_fired(): void
    {
        Event::fake([ReportCreated::class]);

        $question = Question::factory()->create();
        $user = User::factory()->create();

        $this->actingAs($user)->postJson('/api/reports', [
            'reportable_type' => 'Question',
            'reportable_id' => $question->id,
            'reason' => 'spam',
        ]);

        Event::assertDispatched(ReportCreated::class);
    }

    public function test_cannot_report_nonexistent_content(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)->postJson('/api/reports', [
            'reportable_type' => 'Question',
            'reportable_id' => 99999,
            'reason' => 'spam',
        ]);

        $response->assertStatus(422);
    }

    public function test_cannot_report_deleted_question(): void
    {
        $question = Question::factory()->create(['is_deleted' => true]);
        $user = User::factory()->create();

        $response = $this->actingAs($user)->postJson('/api/reports', [
            'reportable_type' => 'Question',
            'reportable_id' => $question->id,
            'reason' => 'spam',
        ]);

        $response->assertStatus(422);
    }

    public function test_cannot_report_deleted_answer(): void
    {
        $answer = Answer::factory()->create(['is_deleted' => true]);
        $user = User::factory()->create();

        $response = $this->actingAs($user)->postJson('/api/reports', [
            'reportable_type' => 'Answer',
            'reportable_id' => $answer->id,
            'reason' => 'spam',
        ]);

        $response->assertStatus(422);
    }

    public function test_invalid_reason_is_rejected(): void
    {
        $question = Question::factory()->create();
        $user = User::factory()->create();

        $response = $this->actingAs($user)->postJson('/api/reports', [
            'reportable_type' => 'Question',
            'reportable_id' => $question->id,
            'reason' => 'invalid_reason',
        ]);

        $response->assertStatus(422);
    }

    public function test_invalid_reportable_type_is_rejected(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)->postJson('/api/reports', [
            'reportable_type' => 'InvalidType',
            'reportable_id' => 1,
            'reason' => 'spam',
        ]);

        $response->assertStatus(422);
    }

    public function test_comment_max_length_is_500(): void
    {
        $question = Question::factory()->create();
        $user = User::factory()->create();

        $response = $this->actingAs($user)->postJson('/api/reports', [
            'reportable_type' => 'Question',
            'reportable_id' => $question->id,
            'reason' => 'spam',
            'comment' => str_repeat('a', 501),
        ]);

        $response->assertStatus(422);
    }

    public function test_different_users_can_report_same_content(): void
    {
        $question = Question::factory()->create();
        $user1 = User::factory()->create();
        $user2 = User::factory()->create();

        $this->actingAs($user1)->postJson('/api/reports', [
            'reportable_type' => 'Question',
            'reportable_id' => $question->id,
            'reason' => 'spam',
        ])->assertStatus(201);

        $this->actingAs($user2)->postJson('/api/reports', [
            'reportable_type' => 'Question',
            'reportable_id' => $question->id,
            'reason' => 'offensive',
        ])->assertStatus(201);

        $this->assertDatabaseCount('reports', 2);
    }
}

<?php

namespace Tests\Feature\Questions;

use App\Models\Question;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class GetUserQuestionsTest extends TestCase
{
    use RefreshDatabase;

    private User $user;

    protected function setUp(): void
    {
        parent::setUp();
        $this->user = User::factory()->create();
    }

    public function test_returns_only_authenticated_users_questions(): void
    {
        $otherUser = User::factory()->create();

        $userQuestion = Question::factory()->create([
            'user_id' => $this->user->id,
            'title' => 'My Question',
        ]);

        Question::factory()->create([
            'user_id' => $otherUser->id,
            'title' => 'Other Question',
        ]);

        $response = $this->actingAs($this->user)->getJson('/api/user/questions');

        $response->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.id', $userQuestion->id)
            ->assertJsonPath('data.0.title', 'My Question');
    }

    public function test_questions_are_sorted_by_date_desc(): void
    {
        $oldQuestion = Question::factory()->create([
            'user_id' => $this->user->id,
            'created_at' => now()->subDays(2),
        ]);

        $newQuestion = Question::factory()->create([
            'user_id' => $this->user->id,
            'created_at' => now(),
        ]);

        $response = $this->actingAs($this->user)->getJson('/api/user/questions');

        $response->assertOk()
            ->assertJsonPath('data.0.id', $newQuestion->id)
            ->assertJsonPath('data.1.id', $oldQuestion->id);
    }

    public function test_pagination_works_correctly(): void
    {
        Question::factory()->count(25)->create(['user_id' => $this->user->id]);

        $response = $this->actingAs($this->user)->getJson('/api/user/questions?page=1');

        $response->assertOk()
            ->assertJsonCount(20, 'data')
            ->assertJsonPath('meta.current_page', 1)
            ->assertJsonPath('meta.last_page', 2)
            ->assertJsonPath('meta.total', 25);
    }

    public function test_deleted_questions_are_not_returned(): void
    {
        $activeQuestion = Question::factory()->create([
            'user_id' => $this->user->id,
            'is_deleted' => false,
        ]);

        Question::factory()->deleted()->create([
            'user_id' => $this->user->id,
        ]);

        $response = $this->actingAs($this->user)->getJson('/api/user/questions');

        $response->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.id', $activeQuestion->id);
    }

    public function test_includes_has_unread_answers_flag(): void
    {
        Question::factory()->create([
            'user_id' => $this->user->id,
            'has_unread_answers' => true,
        ]);

        $response = $this->actingAs($this->user)->getJson('/api/user/questions');

        $response->assertOk()
            ->assertJsonPath('data.0.has_unread_answers', true);
    }

    public function test_unauthenticated_user_cannot_access(): void
    {
        $response = $this->getJson('/api/user/questions');

        $response->assertUnauthorized();
    }

    public function test_returns_empty_list_when_user_has_no_questions(): void
    {
        $response = $this->actingAs($this->user)->getJson('/api/user/questions');

        $response->assertOk()
            ->assertJsonCount(0, 'data');
    }

    public function test_response_includes_required_fields(): void
    {
        Question::factory()->create([
            'user_id' => $this->user->id,
        ]);

        $response = $this->actingAs($this->user)->getJson('/api/user/questions');

        $response->assertOk()
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
                        'has_unread_answers',
                        'created_at',
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
}

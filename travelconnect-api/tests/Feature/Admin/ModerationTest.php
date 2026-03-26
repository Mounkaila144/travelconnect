<?php

namespace Tests\Feature\Admin;

use App\Models\Admin;
use App\Models\Answer;
use App\Models\Question;
use App\Models\Report;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ModerationTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_can_view_pending_reports(): void
    {
        $admin = Admin::factory()->create();
        $user = User::factory()->create();
        $question = Question::factory()->create();

        Report::factory()->create([
            'reporter_id' => $user->id,
            'reportable_type' => Question::class,
            'reportable_id' => $question->id,
            'status' => 'pending',
        ]);

        $response = $this->actingAs($admin, 'admin')
            ->get('/admin/reports');

        $response->assertStatus(200);
        $response->assertViewIs('admin.reports.index');
        $response->assertViewHas('reports');
    }

    public function test_admin_can_view_report_details(): void
    {
        $admin = Admin::factory()->create();
        $question = Question::factory()->create();
        $report = Report::factory()->create([
            'reportable_type' => Question::class,
            'reportable_id' => $question->id,
        ]);

        $response = $this->actingAs($admin, 'admin')
            ->get("/admin/reports/{$report->id}");

        $response->assertStatus(200);
        $response->assertViewIs('admin.reports.show');
        $response->assertViewHas('report');
    }

    public function test_admin_can_approve_report(): void
    {
        $admin = Admin::factory()->create();
        $report = Report::factory()->create(['status' => 'pending']);

        $response = $this->actingAs($admin, 'admin')
            ->post("/admin/reports/{$report->id}/approve", [
                'admin_note' => 'Content is acceptable',
            ]);

        $response->assertRedirect('/admin/reports');
        $response->assertSessionHas('success');

        $this->assertDatabaseHas('reports', [
            'id' => $report->id,
            'status' => 'approved',
            'processed_by' => $admin->id,
        ]);

        $this->assertDatabaseHas('moderation_actions', [
            'admin_id' => $admin->id,
            'report_id' => $report->id,
            'action' => 'approved',
        ]);
    }

    public function test_admin_can_delete_reported_content(): void
    {
        $admin = Admin::factory()->create();
        $question = Question::factory()->create(['is_deleted' => false]);
        $report = Report::factory()->create([
            'reportable_type' => Question::class,
            'reportable_id' => $question->id,
        ]);

        $response = $this->actingAs($admin, 'admin')
            ->post("/admin/reports/{$report->id}/delete-content", [
                'admin_note' => 'Spam content',
            ]);

        $response->assertRedirect('/admin/reports');

        $this->assertDatabaseHas('questions', [
            'id' => $question->id,
            'is_deleted' => true,
        ]);

        $this->assertDatabaseHas('reports', [
            'id' => $report->id,
            'status' => 'rejected',
        ]);
    }

    public function test_admin_can_ban_user(): void
    {
        $admin = Admin::factory()->create();
        $user = User::factory()->create(['is_banned' => false]);
        $question = Question::factory()->create(['user_id' => $user->id]);
        $report = Report::factory()->create([
            'reportable_type' => Question::class,
            'reportable_id' => $question->id,
        ]);

        $user->createToken('test-token');

        $response = $this->actingAs($admin, 'admin')
            ->post("/admin/reports/{$report->id}/ban-user", [
                'admin_note' => 'Repeated violations',
                'is_permanent' => true,
            ]);

        $response->assertRedirect('/admin/reports');

        $this->assertDatabaseHas('users', [
            'id' => $user->id,
            'is_banned' => true,
        ]);

        $this->assertEquals(0, $user->tokens()->count());

        $this->assertDatabaseHas('moderation_actions', [
            'action' => 'banned',
        ]);
    }

    public function test_deleting_question_also_deletes_answers(): void
    {
        $admin = Admin::factory()->create();
        $question = Question::factory()->create();
        $answer = Answer::factory()->create(['question_id' => $question->id]);
        $report = Report::factory()->create([
            'reportable_type' => Question::class,
            'reportable_id' => $question->id,
        ]);

        $this->actingAs($admin, 'admin')
            ->post("/admin/reports/{$report->id}/delete-content", [
                'admin_note' => 'Inappropriate content',
            ]);

        $this->assertDatabaseHas('questions', [
            'id' => $question->id,
            'is_deleted' => true,
        ]);

        $this->assertDatabaseHas('answers', [
            'id' => $answer->id,
            'is_deleted' => true,
        ]);
    }

    public function test_admin_note_is_required_for_delete_action(): void
    {
        $admin = Admin::factory()->create();
        $report = Report::factory()->create();

        $response = $this->actingAs($admin, 'admin')
            ->post("/admin/reports/{$report->id}/delete-content", [
                'admin_note' => '',
            ]);

        $response->assertSessionHasErrors('admin_note');
    }

    public function test_admin_can_view_moderation_history(): void
    {
        $admin = Admin::factory()->create();

        $response = $this->actingAs($admin, 'admin')
            ->get('/admin/reports/history');

        $response->assertStatus(200);
        $response->assertViewIs('admin.reports.history');
    }
}

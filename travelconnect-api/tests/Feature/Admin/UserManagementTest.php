<?php

namespace Tests\Feature\Admin;

use App\Models\Admin;
use App\Models\Question;
use App\Models\User;
use App\Models\UserBan;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class UserManagementTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_can_view_users_list(): void
    {
        $admin = Admin::factory()->create();
        User::factory()->count(5)->create();

        $response = $this->actingAs($admin, 'admin')
            ->get('/admin/users');

        $response->assertStatus(200);
        $response->assertViewIs('admin.users.index');
        $response->assertViewHas('users');
    }

    public function test_admin_can_search_users_by_name(): void
    {
        $admin = Admin::factory()->create();
        User::factory()->create(['name' => 'John Doe']);
        User::factory()->create(['name' => 'Jane Smith']);

        $response = $this->actingAs($admin, 'admin')
            ->get('/admin/users?search=John');

        $response->assertStatus(200);
        $response->assertSee('John Doe');
        $response->assertDontSee('Jane Smith');
    }

    public function test_admin_can_search_users_by_email(): void
    {
        $admin = Admin::factory()->create();
        User::factory()->create(['email' => 'john@example.com']);
        User::factory()->create(['email' => 'jane@example.com']);

        $response = $this->actingAs($admin, 'admin')
            ->get('/admin/users?search=john@');

        $response->assertStatus(200);
        $response->assertSee('john@example.com');
        $response->assertDontSee('jane@example.com');
    }

    public function test_admin_can_view_user_profile(): void
    {
        $admin = Admin::factory()->create();
        $user = User::factory()->create();
        Question::factory()->count(3)->create(['user_id' => $user->id]);

        $response = $this->actingAs($admin, 'admin')
            ->get("/admin/users/{$user->id}");

        $response->assertStatus(200);
        $response->assertViewIs('admin.users.show');
        $response->assertViewHas('user');
        $response->assertViewHas('statistics');
        $response->assertSee($user->email);
    }

    public function test_admin_can_ban_user_permanently(): void
    {
        $admin = Admin::factory()->create();
        $user = User::factory()->create(['is_banned' => false]);
        $user->createToken('test-token');

        $response = $this->actingAs($admin, 'admin')
            ->post("/admin/users/{$user->id}/ban", [
                'reason' => 'Repeated violations',
                'is_permanent' => true,
            ]);

        $response->assertRedirect();
        $response->assertSessionHas('success');

        $this->assertDatabaseHas('users', [
            'id' => $user->id,
            'is_banned' => true,
        ]);

        $this->assertDatabaseHas('user_bans', [
            'user_id' => $user->id,
            'is_permanent' => true,
            'banned_by' => $admin->id,
        ]);

        $this->assertDatabaseHas('admin_user_actions', [
            'user_id' => $user->id,
            'action' => 'banned',
        ]);

        $this->assertEquals(0, $user->tokens()->count());
    }

    public function test_admin_can_ban_user_temporarily(): void
    {
        $admin = Admin::factory()->create();
        $user = User::factory()->create();

        $response = $this->actingAs($admin, 'admin')
            ->post("/admin/users/{$user->id}/ban", [
                'reason' => 'Temporary suspension',
                'is_permanent' => false,
                'ban_duration_days' => 7,
            ]);

        $response->assertRedirect();

        $ban = UserBan::where('user_id', $user->id)->first();
        $this->assertNotNull($ban);
        $this->assertFalse($ban->is_permanent);
        $this->assertEquals(7, $ban->duration_days);
        $this->assertNotNull($ban->expires_at);
    }

    public function test_admin_can_unban_user(): void
    {
        $admin = Admin::factory()->create();
        $user = User::factory()->create(['is_banned' => true]);
        UserBan::create([
            'user_id' => $user->id,
            'banned_by' => $admin->id,
            'reason' => 'Test ban',
            'is_permanent' => true,
            'banned_at' => now(),
        ]);

        $response = $this->actingAs($admin, 'admin')
            ->post("/admin/users/{$user->id}/unban", [
                'reason' => 'Appeal accepted',
            ]);

        $response->assertRedirect();

        $this->assertDatabaseHas('users', [
            'id' => $user->id,
            'is_banned' => false,
        ]);

        $this->assertDatabaseHas('admin_user_actions', [
            'user_id' => $user->id,
            'action' => 'unbanned',
        ]);

        $ban = $user->bans()->first();
        $this->assertNotNull($ban->unbanned_at);
        $this->assertEquals($admin->id, $ban->unbanned_by);
    }

    public function test_admin_can_remove_local_supporter_badge(): void
    {
        $admin = Admin::factory()->create();
        $user = User::factory()->create(['user_type' => 'local_supporter']);

        $response = $this->actingAs($admin, 'admin')
            ->post("/admin/users/{$user->id}/remove-badge", [
                'reason' => 'Badge misuse',
            ]);

        $response->assertRedirect();

        $this->assertDatabaseHas('users', [
            'id' => $user->id,
            'user_type' => 'traveler',
        ]);

        $this->assertDatabaseHas('admin_user_actions', [
            'user_id' => $user->id,
            'action' => 'badge_removed',
        ]);
    }

    public function test_banned_user_cannot_access_api(): void
    {
        $admin = Admin::factory()->create();
        $user = User::factory()->create(['is_banned' => true]);
        UserBan::create([
            'user_id' => $user->id,
            'banned_by' => $admin->id,
            'reason' => 'Test',
            'is_permanent' => true,
            'banned_at' => now(),
        ]);

        $response = $this->actingAs($user)->getJson('/api/user/profile');

        $response->assertStatus(403);
        $response->assertJson([
            'error' => [
                'code' => 'USER_BANNED',
            ],
        ]);
    }

    public function test_expired_temporary_ban_is_automatically_removed(): void
    {
        $admin = Admin::factory()->create();
        $user = User::factory()->create(['is_banned' => true]);
        UserBan::create([
            'user_id' => $user->id,
            'banned_by' => $admin->id,
            'reason' => 'Temporary',
            'is_permanent' => false,
            'duration_days' => 7,
            'banned_at' => now()->subDays(8),
            'expires_at' => now()->subDay(),
        ]);

        $this->artisan('users:unban-expired');

        $user->refresh();
        $this->assertFalse($user->is_banned);

        $ban = $user->bans()->first();
        $this->assertNotNull($ban->unbanned_at);
    }
}

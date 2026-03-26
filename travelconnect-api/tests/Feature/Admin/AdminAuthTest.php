<?php

namespace Tests\Feature\Admin;

use App\Models\Admin;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class AdminAuthTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_login_page_is_accessible(): void
    {
        $response = $this->get('/admin/login');

        $response->assertStatus(200);
        $response->assertViewIs('admin.login');
        $response->assertSee('email');
        $response->assertSee('password');
    }

    public function test_admin_can_login_with_valid_credentials(): void
    {
        $admin = Admin::create([
            'email' => 'admin@test.com',
            'password' => Hash::make('password123'),
            'name' => 'Test Admin',
        ]);

        $response = $this->post('/admin/login', [
            'email' => 'admin@test.com',
            'password' => 'password123',
        ]);

        $response->assertRedirect('/admin/dashboard');
        $this->assertAuthenticatedAs($admin, 'admin');

        $admin->refresh();
        $this->assertNotNull($admin->last_login_at);
    }

    public function test_admin_cannot_login_with_invalid_credentials(): void
    {
        Admin::create([
            'email' => 'admin@test.com',
            'password' => Hash::make('password123'),
            'name' => 'Test Admin',
        ]);

        $response = $this->post('/admin/login', [
            'email' => 'admin@test.com',
            'password' => 'wrongpassword',
        ]);

        $response->assertRedirect();
        $response->assertSessionHasErrors('email');
        $this->assertGuest('admin');
    }

    public function test_unauthenticated_admin_cannot_access_dashboard(): void
    {
        $response = $this->get('/admin/dashboard');

        $response->assertRedirect('/admin/login');
    }

    public function test_admin_can_logout(): void
    {
        $admin = Admin::create([
            'email' => 'admin@test.com',
            'password' => Hash::make('password123'),
            'name' => 'Test Admin',
        ]);

        $this->actingAs($admin, 'admin');

        $response = $this->post('/admin/logout');

        $response->assertRedirect('/admin/login');
        $this->assertGuest('admin');
    }

    public function test_dashboard_displays_statistics(): void
    {
        $admin = Admin::factory()->create();

        $response = $this->actingAs($admin, 'admin')->get('/admin/dashboard');

        $response->assertStatus(200);
        $response->assertViewIs('admin.dashboard');
        $response->assertViewHas('statistics');
        $response->assertSee('Utilisateurs');
        $response->assertSee('Questions');
    }

    public function test_admin_session_expires_after_8_hours(): void
    {
        $admin = Admin::create([
            'email' => 'admin@test.com',
            'password' => Hash::make('password123'),
            'name' => 'Test Admin',
        ]);

        // Login first
        $this->actingAs($admin, 'admin');

        // Set last_activity_time to 9 hours ago
        session(['last_activity_time' => time() - 32400]);

        $response = $this->get('/admin/dashboard');

        $response->assertRedirect('/admin/login');
    }
}

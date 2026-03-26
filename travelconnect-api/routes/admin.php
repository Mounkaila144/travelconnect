<?php

use App\Http\Controllers\Admin\AdminAuthController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\ModerationController;
use App\Http\Controllers\Admin\UserController;
use Illuminate\Support\Facades\Route;

// Public admin routes (no authentication required)
Route::get('/', function () {
    return redirect()->route('admin.login');
});

Route::get('/login', [AdminAuthController::class, 'showLogin'])->name('admin.login');
Route::post('/login', [AdminAuthController::class, 'login'])->name('admin.login.post');

// Protected admin routes (authentication required)
Route::middleware('admin')->group(function () {
    Route::get('/dashboard', [DashboardController::class, 'index'])->name('admin.dashboard');
    Route::post('/logout', [AdminAuthController::class, 'logout'])->name('admin.logout');

    // Moderation routes (Story 5.2)
    Route::get('/reports', [ModerationController::class, 'index'])->name('admin.reports.index');
    Route::get('/reports/history', [ModerationController::class, 'history'])->name('admin.reports.history');
    Route::get('/reports/{id}', [ModerationController::class, 'show'])->name('admin.reports.show');
    Route::post('/reports/{id}/approve', [ModerationController::class, 'approve'])->name('admin.reports.approve');
    Route::post('/reports/{id}/delete-content', [ModerationController::class, 'deleteContent'])->name('admin.reports.delete-content');
    Route::post('/reports/{id}/ban-user', [ModerationController::class, 'banUser'])->name('admin.reports.ban-user');

    // User management routes (Story 5.3)
    Route::get('/users', [UserController::class, 'index'])->name('admin.users.index');
    Route::get('/users/{id}', [UserController::class, 'show'])->name('admin.users.show');
    Route::post('/users/{id}/ban', [UserController::class, 'ban'])->name('admin.users.ban');
    Route::post('/users/{id}/unban', [UserController::class, 'unban'])->name('admin.users.unban');
    Route::post('/users/{id}/remove-badge', [UserController::class, 'removeBadge'])->name('admin.users.remove-badge');
});

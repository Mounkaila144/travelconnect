<?php

use App\Http\Controllers\Api\AnswerController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\HealthController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\ProfileController;
use App\Http\Controllers\Api\QuestionController;
use App\Http\Controllers\Api\ReportController;
use App\Http\Controllers\Api\UserQuestionsController;
use App\Http\Middleware\EnsureUserNotBanned;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/health', [HealthController::class, 'check']);

Route::post('/auth/google', [AuthController::class, 'google']);
Route::post('/auth/apple', [AuthController::class, 'apple']);

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::post('/auth/logout-all', [AuthController::class, 'logoutAll']);
});

Route::middleware(['auth:sanctum', EnsureUserNotBanned::class])->group(function () {
    Route::get('/user/profile', [ProfileController::class, 'show']);
    Route::put('/user/profile', [ProfileController::class, 'update']);
    Route::post('/user/avatar', [ProfileController::class, 'uploadAvatar']);
    Route::post('/user/fcm-token', [ProfileController::class, 'registerFcmToken']);
    Route::put('/user/notification-settings', [ProfileController::class, 'updateNotificationSettings']);
    Route::put('/user/notification-zone', [ProfileController::class, 'setNotificationZone']);

    Route::get('/user/questions', [UserQuestionsController::class, 'index']);

    Route::get('/questions', [QuestionController::class, 'index'])
        ->middleware('throttle:60,1');

    Route::get('/questions/cities', [QuestionController::class, 'getPopularCities'])
        ->middleware('throttle:60,1');

    Route::get('/questions/{id}', [QuestionController::class, 'show'])
        ->middleware('throttle:60,1');

    Route::post('/questions', [QuestionController::class, 'store'])
        ->middleware('throttle:10,60');

    Route::post('/questions/{question}/answers', [AnswerController::class, 'store'])
        ->middleware('throttle:10,60');

    Route::post('/answers/{answer}/rate', [AnswerController::class, 'rate'])
        ->middleware('throttle:60,1');

    Route::post('/reports', [ReportController::class, 'store'])
        ->middleware('throttle:10,60');

    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::get('/notifications/unread-count', [NotificationController::class, 'getUnreadCount']);
    Route::post('/notifications/{id}/read', [NotificationController::class, 'markAsRead']);
    Route::post('/notifications/read-all', [NotificationController::class, 'markAllAsRead']);
});

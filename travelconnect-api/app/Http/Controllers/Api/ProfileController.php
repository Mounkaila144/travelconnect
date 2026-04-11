<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\RegisterFcmTokenRequest;
use App\Http\Requests\SetNotificationZoneRequest;
use App\Http\Requests\UpdateNotificationSettingsRequest;
use App\Http\Requests\UpdateProfileRequest;
use App\Http\Requests\UploadAvatarRequest;
use App\Http\Resources\UserResource;
use App\Services\ProfileService;
use App\Services\StorageService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class ProfileController extends Controller
{
    public function __construct(
        private readonly ProfileService $profileService,
        private readonly StorageService $storageService,
    ) {}

    public function show(): JsonResponse
    {
        return response()->json([
            'data' => new UserResource(auth()->user()),
        ]);
    }

    public function update(UpdateProfileRequest $request): JsonResponse
    {
        $user = $this->profileService->updateProfile(
            auth()->user(),
            $request->validated()
        );

        return response()->json([
            'data' => new UserResource($user),
        ]);
    }

    public function uploadAvatar(UploadAvatarRequest $request): JsonResponse
    {
        try {
            $avatarUrl = $this->storageService->uploadAvatar(
                $request->file('avatar'),
                auth()->user()
            );

            return response()->json([
                'avatar_url' => $avatarUrl,
            ]);
        } catch (\RuntimeException $e) {
            return response()->json([
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    public function registerFcmToken(RegisterFcmTokenRequest $request): Response
    {
        $request->user()->update([
            'fcm_token' => $request->validated('fcm_token'),
        ]);

        return response()->noContent();
    }

    public function updateNotificationSettings(UpdateNotificationSettingsRequest $request): JsonResponse
    {
        $user = $request->user();
        $current = $user->notification_settings ?? [
            'new_answers' => true,
            'nearby_questions' => true,
        ];

        $updated = array_merge($current, $request->validated());
        $user->update(['notification_settings' => $updated]);

        return response()->json($updated);
    }

    public function deleteAccount(): JsonResponse
    {
        $user = auth()->user();

        try {
            DB::transaction(function () use ($user) {
                // Soft-delete user's answers
                $user->answers()->update(['is_deleted' => true]);

                // Soft-delete user's questions
                $user->questions()->update(['is_deleted' => true]);

                // Delete notifications
                DB::table('notifications')->where('user_id', $user->id)->delete();

                // Delete ratings made by this user
                DB::table('ratings')->where('user_id', $user->id)->delete();

                // Revoke all tokens
                $user->tokens()->delete();

                // Delete the user
                $user->delete();
            });

            Log::info('User account deleted', ['user_id' => $user->id]);

            return response()->json(['message' => 'Account deleted successfully']);
        } catch (\Throwable $e) {
            Log::error('Account deletion failed', [
                'user_id' => $user->id,
                'error' => $e->getMessage(),
            ]);

            return response()->json(['message' => 'Account deletion failed'], 500);
        }
    }

    public function setNotificationZone(SetNotificationZoneRequest $request): Response
    {
        $request->user()->update([
            'notification_zone_lat' => $request->validated('latitude'),
            'notification_zone_lng' => $request->validated('longitude'),
            'notification_zone_radius' => $request->validated('radius_km'),
        ]);

        return response()->noContent();
    }
}

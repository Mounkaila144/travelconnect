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

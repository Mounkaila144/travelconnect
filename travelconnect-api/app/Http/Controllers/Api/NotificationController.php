<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\NotificationResource;
use App\Models\Notification;
use App\Services\NotificationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class NotificationController extends Controller
{
    public function __construct(
        private readonly NotificationService $notificationService
    ) {}

    public function index(Request $request): AnonymousResourceCollection
    {
        $user = $request->user();

        $notifications = Notification::where('user_id', $user->id)
            ->orderByDesc('created_at')
            ->paginate(20);

        $unreadCount = $this->notificationService->getUnreadCount($user->id);

        return NotificationResource::collection($notifications)
            ->additional([
                'unread_count' => $unreadCount,
            ]);
    }

    public function markAsRead(string $id, Request $request): JsonResponse
    {
        $notification = Notification::where('id', $id)
            ->where('user_id', $request->user()->id)
            ->first();

        if (!$notification) {
            return response()->json([
                'error' => [
                    'code' => 'NOT_FOUND',
                    'message' => 'Notification non trouvée',
                ],
            ], 404);
        }

        $this->notificationService->markAsRead($id);

        return response()->json(null, 204);
    }

    public function markAllAsRead(Request $request): JsonResponse
    {
        $markedCount = $this->notificationService->markAllAsRead($request->user()->id);

        return response()->json([
            'marked_count' => $markedCount,
        ]);
    }

    public function getUnreadCount(Request $request): JsonResponse
    {
        $unreadCount = $this->notificationService->getUnreadCount($request->user()->id);

        return response()->json([
            'unread_count' => $unreadCount,
        ]);
    }
}

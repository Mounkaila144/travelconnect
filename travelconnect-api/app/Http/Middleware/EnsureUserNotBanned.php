<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserNotBanned
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if ($user?->is_banned) {
            $ban = $user->activeBan;

            $message = 'Votre compte a été suspendu';

            if ($ban) {
                if ($ban->is_permanent) {
                    $message .= ' de manière permanente';
                } elseif ($ban->expires_at) {
                    $message .= ' jusqu\'au ' . $ban->expires_at->format('d/m/Y à H:i');
                }

                $message .= '. Raison: ' . $ban->reason;
            }

            return response()->json([
                'error' => [
                    'code' => 'USER_BANNED',
                    'message' => $message,
                    'ban_details' => [
                        'is_permanent' => $ban?->is_permanent ?? true,
                        'expires_at' => $ban?->expires_at?->toIso8601String(),
                        'reason' => $ban?->reason,
                    ],
                    'timestamp' => now()->toIso8601String(),
                ],
            ], 403);
        }

        return $next($request);
    }
}

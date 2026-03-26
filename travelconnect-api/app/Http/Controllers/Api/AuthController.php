<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\AppleAuthRequest;
use App\Http\Requests\GoogleAuthRequest;
use App\Services\AuthService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Log;

class AuthController extends Controller
{
    public function __construct(
        private readonly AuthService $authService
    ) {}

    public function google(GoogleAuthRequest $request): JsonResponse
    {
        try {
            $result = $this->authService->authenticateWithGoogle(
                $request->validated('id_token')
            );

            return $this->successResponse($result);
        } catch (\InvalidArgumentException $e) {
            return $this->errorResponse($e);
        }
    }

    public function apple(AppleAuthRequest $request): JsonResponse
    {
        try {
            $result = $this->authService->authenticateWithApple(
                identityToken: $request->validated('identity_token'),
                authorizationCode: $request->validated('authorization_code'),
                fullName: $request->validated('full_name'),
            );

            return $this->successResponse($result);
        } catch (\InvalidArgumentException $e) {
            return $this->errorResponse($e);
        }
    }

    public function logout(Request $request): Response
    {
        $this->authService->logout($request->user());

        return response()->noContent();
    }

    public function logoutAll(Request $request): Response
    {
        $this->authService->logoutAll($request->user());

        return response()->noContent();
    }

    private function successResponse(array $result): JsonResponse
    {
        return response()->json([
            'user' => [
                'id' => $result['user']->id,
                'email' => $result['user']->email,
                'name' => $result['user']->name,
                'avatar_url' => $result['user']->avatar_url,
                'user_type' => $result['user']->user_type,
                'trust_score' => (float) $result['user']->trust_score,
                'is_new' => (bool) $result['user']->is_new,
            ],
            'token' => $result['token'],
            'is_new_user' => $result['is_new_user'],
        ]);
    }

    private function errorResponse(\InvalidArgumentException $e): JsonResponse
    {
        $errorMap = [
            'Invalid Google token' => ['code' => 'INVALID_TOKEN', 'status' => 401],
            'Invalid token audience' => ['code' => 'TOKEN_AUDIENCE_MISMATCH', 'status' => 401],
            'Invalid Apple identity token' => ['code' => 'INVALID_APPLE_TOKEN', 'status' => 401],
            'Apple token signature verification failed' => ['code' => 'TOKEN_SIGNATURE_INVALID', 'status' => 401],
            'Un compte existe déjà avec cet email via un autre fournisseur' => ['code' => 'EMAIL_CONFLICT', 'status' => 422],
            'Ce compte a été suspendu' => ['code' => 'USER_BANNED', 'status' => 403],
        ];

        $error = $errorMap[$e->getMessage()] ?? ['code' => 'AUTH_ERROR', 'status' => 401];

        Log::warning('Authentication failed', [
            'error_code' => $error['code'],
            'message' => $e->getMessage(),
        ]);

        return response()->json([
            'error' => [
                'code' => $error['code'],
                'message' => $e->getMessage(),
                'timestamp' => now()->toIso8601String(),
            ],
        ], $error['status']);
    }
}

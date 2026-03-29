<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Laravel\Socialite\Facades\Socialite;

class AuthService
{
    public function authenticateWithGoogle(string $idToken): array
    {
        // Try as ID token first (mobile flow)
        $response = Http::get('https://oauth2.googleapis.com/tokeninfo', [
            'id_token' => $idToken,
        ]);

        if ($response->successful()) {
            $googleUser = $response->json();

            if ($googleUser['aud'] !== config('services.google.client_id')) {
                throw new \InvalidArgumentException('Invalid token audience');
            }

            return $this->findOrCreateUser(
                provider: 'google',
                providerId: $googleUser['sub'],
                email: $googleUser['email'],
                name: $googleUser['name'] ?? 'Utilisateur',
                avatarUrl: $googleUser['picture'] ?? null
            );
        }

        // Fallback: try as access token (web flow)
        $response = Http::withToken($idToken)
            ->get('https://www.googleapis.com/oauth2/v3/userinfo');

        if ($response->failed()) {
            throw new \InvalidArgumentException('Invalid Google token');
        }

        $googleUser = $response->json();

        return $this->findOrCreateUser(
            provider: 'google',
            providerId: $googleUser['sub'],
            email: $googleUser['email'],
            name: $googleUser['name'] ?? 'Utilisateur',
            avatarUrl: $googleUser['picture'] ?? null
        );
    }

    public function authenticateWithApple(
        string $identityToken,
        string $authorizationCode,
        ?array $fullName = null
    ): array {
        try {
            $appleUser = Socialite::driver('apple')
                ->stateless()
                ->userFromToken($identityToken);
        } catch (\Exception $e) {
            Log::warning('Apple token validation failed', [
                'error' => $e->getMessage(),
            ]);
            throw new \InvalidArgumentException('Invalid Apple identity token');
        }

        $name = $this->resolveAppleName($fullName);

        $result = $this->findOrCreateUser(
            provider: 'apple',
            providerId: $appleUser->getId(),
            email: $appleUser->getEmail(),
            name: $name,
            avatarUrl: null,
        );

        // Apple only provides name on first auth — update if provided on subsequent logins
        if (!$result['is_new_user'] && $fullName) {
            $resolvedName = $this->resolveAppleName($fullName);
            if ($resolvedName !== 'Utilisateur' && $result['user']->name === 'Utilisateur') {
                $result['user']->update(['name' => $resolvedName]);
            }
        }

        return $result;
    }

    private function resolveAppleName(?array $fullName): string
    {
        if (!$fullName) {
            return 'Utilisateur';
        }

        $givenName = $fullName['given_name'] ?? '';
        $familyName = $fullName['family_name'] ?? '';
        $name = trim("{$givenName} {$familyName}");

        return empty($name) ? 'Utilisateur' : $name;
    }

    public function logout(User $user): void
    {
        $token = $user->currentAccessToken();

        if ($token) {
            $token->delete();

            Log::info('User logged out', [
                'user_id' => $user->id,
                'token_name' => $token->name,
            ]);
        }
    }

    public function logoutAll(User $user): void
    {
        $user->tokens()->delete();

        Log::info('User logged out from all devices', [
            'user_id' => $user->id,
        ]);
    }

    private function findOrCreateUser(
        string $provider,
        string $providerId,
        ?string $email,
        string $name,
        ?string $avatarUrl
    ): array {
        $isNewUser = false;

        $user = User::where('provider', $provider)
            ->where('provider_id', $providerId)
            ->first();

        if (!$user) {
            if ($email) {
                $existingUser = User::where('email', $email)->first();
                if ($existingUser) {
                    throw new \InvalidArgumentException(
                        'Un compte existe déjà avec cet email via un autre fournisseur'
                    );
                }
            }

            $user = User::create([
                'email' => $email,
                'name' => $name,
                'avatar_url' => $avatarUrl,
                'provider' => $provider,
                'provider_id' => $providerId,
                'user_type' => 'traveler',
            ]);

            $isNewUser = true;
        }

        if ($user->is_banned) {
            throw new \InvalidArgumentException('Ce compte a été suspendu');
        }

        $token = $user->createToken('mobile-app');

        return [
            'user' => $user,
            'token' => $token->plainTextToken,
            'is_new_user' => $isNewUser,
        ];
    }
}

<?php

namespace App\Services;

use App\Events\ProfileUpdated;
use App\Models\User;

class ProfileService
{
    public function updateProfile(User $user, array $data): User
    {
        $user->update([
            'name' => $data['name'],
            'bio' => $data['bio'] ?? null,
            'country_code' => $data['country_code'],
            'user_type' => $data['user_type'],
            'is_new' => false,
        ]);

        event(new ProfileUpdated($user));

        return $user->fresh();
    }
}

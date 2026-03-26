<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'email' => $this->email,
            'name' => $this->name,
            'avatar_url' => $this->avatar_url,
            'bio' => $this->bio,
            'country_code' => $this->country_code,
            'user_type' => $this->user_type,
            'trust_score' => round((float) $this->trust_score, 2),
            'is_new' => (bool) $this->is_new,
            'questions_count' => $this->questions_count ?? 0,
            'answers_count' => $this->answers_count ?? 0,
        ];
    }
}

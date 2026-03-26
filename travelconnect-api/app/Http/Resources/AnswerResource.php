<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AnswerResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'content' => $this->content,
            'average_rating' => (float) $this->average_rating,
            'ratings_count' => $this->ratings_count,
            'created_at' => $this->created_at->toIso8601String(),
            'user' => new UserResource($this->whenLoaded('user')),
            'user_rating' => $this->whenLoaded('ratings', fn () => $this->ratings->first()?->score),
        ];
    }
}

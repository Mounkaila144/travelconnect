<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class QuestionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'description' => $this->description,
            'latitude' => (float) $this->latitude,
            'longitude' => (float) $this->longitude,
            'location_name' => $this->location_name,
            'city' => $this->city,
            'answers_count' => $this->answers_count,
            'has_answers' => $this->has_answers,
            'has_unread_answers' => $this->has_unread_answers,
            'distance_meters' => $this->when(
                isset($this->distance_meters),
                fn () => round((float) $this->distance_meters, 2)
            ),
            'created_at' => $this->created_at->toIso8601String(),
            'user' => new UserResource($this->whenLoaded('user')),
            'answers' => AnswerResource::collection($this->whenLoaded('answers')),
        ];
    }
}

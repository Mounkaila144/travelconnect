<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class NotificationResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'type' => $this->type,
            'title' => $this->title,
            'body' => $this->body,
            'data' => $this->data,
            'read_at' => $this->read_at?->toIso8601String(),
            'created_at' => $this->created_at->toIso8601String(),
            'time_ago' => $this->getTimeAgo(),
        ];
    }

    private function getTimeAgo(): string
    {
        $diff = now()->diffInSeconds($this->created_at);

        if ($diff < 60) {
            return 'à l\'instant';
        } elseif ($diff < 3600) {
            $minutes = (int) floor($diff / 60);
            return "il y a {$minutes} min";
        } elseif ($diff < 86400) {
            $hours = (int) floor($diff / 3600);
            return "il y a {$hours} h";
        } elseif ($diff < 2592000) {
            $days = (int) floor($diff / 86400);
            return "il y a {$days} j";
        } else {
            return $this->created_at->format('d M');
        }
    }
}

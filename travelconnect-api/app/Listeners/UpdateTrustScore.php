<?php

namespace App\Listeners;

use App\Events\AnswerRated;
use App\Services\TrustScoreService;
use Illuminate\Support\Facades\Log;

class UpdateTrustScore
{
    public function __construct(
        private readonly TrustScoreService $trustScoreService
    ) {}

    public function handle(AnswerRated $event): void
    {
        try {
            $answerAuthor = $event->answer->user;

            $this->trustScoreService->recalculateTrustScore($answerAuthor);

            Log::info("Trust score updated for user {$answerAuthor->id} after rating on answer {$event->answer->id}");
        } catch (\Exception $e) {
            Log::error("Failed to update trust score for user {$event->answer->user_id}: {$e->getMessage()}");
        }
    }
}

<?php

namespace App\Services;

use App\Models\Answer;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class TrustScoreService
{
    /**
     * Recalculate and persist trust score for a user.
     */
    public function recalculateTrustScore(User $user): float
    {
        try {
            DB::beginTransaction();

            $trustScore = $this->calculateTrustScore($user);

            $user->update([
                'trust_score' => $trustScore,
                'is_new' => $this->isNewUser($user),
            ]);

            DB::commit();

            return $trustScore;
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error("Failed to recalculate trust score for user {$user->id}: {$e->getMessage()}");
            throw $e;
        }
    }

    /**
     * Calculate trust score: average_rating × log10(rated_answers_count + 1)
     */
    public function calculateTrustScore(User $user): float
    {
        $answers = Answer::where('user_id', $user->id)
            ->where('is_deleted', false)
            ->whereNotNull('average_rating')
            ->where('ratings_count', '>', 0)
            ->get();

        if ($answers->isEmpty()) {
            return 0.00;
        }

        $averageRating = $answers->avg('average_rating');
        $ratedAnswersCount = $answers->count();

        $trustScore = $averageRating * log10($ratedAnswersCount + 1);

        return round(min(max($trustScore, 0), 5), 2);
    }

    /**
     * A user is "new" if they have fewer than 3 rated answers.
     */
    public function isNewUser(User $user): bool
    {
        $ratedAnswersCount = Answer::where('user_id', $user->id)
            ->where('is_deleted', false)
            ->where('ratings_count', '>', 0)
            ->count();

        return $ratedAnswersCount < 3;
    }

    /**
     * Recalculate trust scores for all non-banned users.
     */
    public function recalculateAllTrustScores(): int
    {
        $users = User::where('is_banned', false)->get();
        $count = 0;

        foreach ($users as $user) {
            try {
                $this->recalculateTrustScore($user);
                $count++;
            } catch (\Exception $e) {
                Log::error("Failed to recalculate for user {$user->id}: {$e->getMessage()}");
            }
        }

        return $count;
    }
}

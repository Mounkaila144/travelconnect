<?php

namespace App\Services;

use App\Events\AnswerRated;
use App\Models\Answer;
use App\Models\Rating;
use App\Models\User;
use Illuminate\Support\Facades\DB;

class RatingService
{
    public function rateAnswer(Answer $answer, User $user, int $score): array
    {
        if ($answer->user_id === $user->id) {
            throw new \InvalidArgumentException('Vous ne pouvez pas noter votre propre réponse');
        }

        if ($answer->is_deleted) {
            throw new \InvalidArgumentException("Cette réponse n'existe plus");
        }

        return DB::transaction(function () use ($answer, $user, $score) {
            $rating = Rating::updateOrCreate(
                [
                    'answer_id' => $answer->id,
                    'user_id' => $user->id,
                ],
                [
                    'score' => $score,
                ]
            );

            $this->recalculateAverageRating($answer);

            $answer->refresh();

            event(new AnswerRated($answer, $rating, $user));

            return [
                'average_rating' => round((float) $answer->average_rating, 1),
                'ratings_count' => $answer->ratings_count,
            ];
        });
    }

    private function recalculateAverageRating(Answer $answer): void
    {
        $stats = Rating::where('answer_id', $answer->id)
            ->selectRaw('AVG(score) as average, COUNT(*) as count')
            ->first();

        $answer->update([
            'average_rating' => $stats->count > 0 ? round($stats->average, 1) : null,
            'ratings_count' => $stats->count,
        ]);
    }
}

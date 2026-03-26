<?php

namespace App\Services;

use App\Events\AnswerCreated;
use App\Models\Answer;
use App\Models\Question;
use App\Models\User;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;

class AnswerService
{
    /**
     * Create a new answer for a question.
     */
    public function createAnswer(Question $question, User $user, array $data): Answer
    {
        if ($question->is_deleted) {
            throw new \InvalidArgumentException('Cette question n\'existe plus');
        }

        return DB::transaction(function () use ($question, $user, $data) {
            $answer = Answer::create([
                'question_id' => $question->id,
                'user_id' => $user->id,
                'content' => $data['content'],
            ]);

            $question->increment('answers_count');

            if ($question->user_id !== $user->id) {
                $question->update(['has_unread_answers' => true]);
            }

            $answer->load('user');

            event(new AnswerCreated($answer, $question));

            // Invalidate nearby questions cache so map markers update
            $this->invalidateNearbyCache(
                (float) $question->latitude,
                (float) $question->longitude
            );

            return $answer;
        });
    }

    private function invalidateNearbyCache(float $lat, float $lng): void
    {
        for ($latOffset = -0.1; $latOffset <= 0.1; $latOffset += 0.05) {
            for ($lngOffset = -0.1; $lngOffset <= 0.1; $lngOffset += 0.05) {
                $cacheKey = sprintf(
                    'questions:nearby:%.4f:%.4f',
                    $lat + $latOffset,
                    $lng + $lngOffset
                );
                for ($page = 1; $page <= 5; $page++) {
                    Cache::forget("{$cacheKey}:10:{$page}");
                }
            }
        }
    }
}

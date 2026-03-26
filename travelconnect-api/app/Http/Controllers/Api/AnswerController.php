<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\CreateAnswerRequest;
use App\Http\Requests\RateAnswerRequest;
use App\Http\Resources\AnswerResource;
use App\Models\Answer;
use App\Models\Question;
use App\Services\AnswerService;
use App\Services\RatingService;
use Illuminate\Http\JsonResponse;

class AnswerController extends Controller
{
    public function __construct(
        private readonly AnswerService $answerService,
        private readonly RatingService $ratingService,
    ) {}

    public function store(CreateAnswerRequest $request, int $questionId): JsonResponse
    {
        $question = Question::findOrFail($questionId);

        $answer = $this->answerService->createAnswer(
            question: $question,
            user: $request->user(),
            data: $request->validated()
        );

        return response()->json([
            'data' => new AnswerResource($answer),
        ], 201);
    }

    public function rate(RateAnswerRequest $request, int $answerId): JsonResponse
    {
        $answer = Answer::findOrFail($answerId);

        try {
            $result = $this->ratingService->rateAnswer(
                answer: $answer,
                user: $request->user(),
                score: $request->validated()['score']
            );

            return response()->json($result);
        } catch (\InvalidArgumentException $e) {
            return response()->json([
                'error' => [
                    'code' => 'CANNOT_RATE_OWN_ANSWER',
                    'message' => $e->getMessage(),
                ],
            ], 403);
        }
    }
}

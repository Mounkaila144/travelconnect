<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\QuestionResource;
use App\Services\QuestionService;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class UserQuestionsController extends Controller
{
    public function __construct(
        private readonly QuestionService $questionService
    ) {}

    public function index(Request $request): AnonymousResourceCollection
    {
        $questions = $this->questionService->getUserQuestions(
            user: $request->user(),
            page: $request->integer('page', 1)
        );

        return QuestionResource::collection($questions);
    }
}

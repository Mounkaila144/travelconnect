<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\CreateQuestionRequest;
use App\Http\Resources\QuestionResource;
use App\Services\QuestionService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Support\Facades\Cache;

class QuestionController extends Controller
{
    public function __construct(
        private readonly QuestionService $questionService
    ) {}

    public function index(Request $request): AnonymousResourceCollection
    {
        $request->validate([
            'lat' => 'nullable|required_with:lng|numeric|between:-90,90',
            'lng' => 'nullable|required_with:lat|numeric|between:-180,180',
            'radius' => 'nullable|integer|min:1|max:50',
            'sort' => 'nullable|in:recent,popular',
            'city' => 'nullable|string|max:100',
            'page' => 'nullable|integer|min:1',
        ]);

        if ($request->filled('lat') && $request->filled('lng')) {
            $questions = $this->questionService->getNearbyQuestions(
                latitude: (float) $request->input('lat'),
                longitude: (float) $request->input('lng'),
                radiusKm: (int) $request->input('radius', 10),
            );
        } else {
            $questions = $this->questionService->getFeedQuestions(
                sort: $request->input('sort', 'recent'),
                city: $request->input('city'),
                page: (int) $request->input('page', 1),
            );
        }

        return QuestionResource::collection($questions);
    }

    public function show(int $id): JsonResponse
    {
        $question = $this->questionService->getQuestionWithAnswers(
            $id,
            request()->user()
        );

        return response()->json([
            'data' => new QuestionResource($question),
        ]);
    }

    public function store(CreateQuestionRequest $request): JsonResponse
    {
        $question = $this->questionService->createQuestion(
            $request->user(),
            $request->validated()
        );

        return (new QuestionResource($question))
            ->response()
            ->setStatusCode(201);
    }

    public function getPopularCities(): JsonResponse
    {
        $cities = Cache::remember('popular_cities', 3600, function () {
            return $this->questionService->getPopularCities(20);
        });

        return response()->json(['data' => $cities]);
    }
}

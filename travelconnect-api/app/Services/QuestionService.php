<?php

namespace App\Services;

use App\Events\QuestionCreated;
use App\Models\Question;
use App\Models\User;
use App\Repositories\QuestionRepository;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;

class QuestionService
{
    public function __construct(
        private readonly QuestionRepository $questionRepository,
        private readonly GeocodingService $geocodingService,
    ) {}

    public function getQuestionWithAnswers(int $id, User $currentUser): Question
    {
        $question = Question::with([
            'user',
            'answers' => function ($query) use ($currentUser) {
                $query->where('is_deleted', false)
                    ->with(['user', 'ratings' => function ($q) use ($currentUser) {
                        $q->where('user_id', $currentUser->id);
                    }])
                    ->orderByDesc('average_rating')
                    ->orderByDesc('created_at');
            },
        ])->findOrFail($id);

        if ($question->user_id === $currentUser->id && $question->has_unread_answers) {
            $question->update(['has_unread_answers' => false]);
        }

        return $question;
    }

    public function createQuestion(User $user, array $data): Question
    {
        $locationData = $this->geocodingService->reverseGeocode(
            $data['latitude'],
            $data['longitude']
        );

        $question = $user->questions()->create([
            'title' => $data['title'],
            'description' => $data['description'] ?? null,
            'latitude' => $data['latitude'],
            'longitude' => $data['longitude'],
            'location' => DB::raw(
                "POINT({$data['longitude']}, {$data['latitude']})"
            ),
            'location_name' => $locationData['formatted_address'],
            'city' => $locationData['city'],
        ]);

        event(new QuestionCreated($question));

        $this->invalidateNearbyQuestionsCache(
            $data['latitude'],
            $data['longitude']
        );

        return $question->load('user');
    }

    private function invalidateNearbyQuestionsCache(float $lat, float $lng): void
    {
        for ($latOffset = -0.1; $latOffset <= 0.1; $latOffset += 0.05) {
            for ($lngOffset = -0.1; $lngOffset <= 0.1; $lngOffset += 0.05) {
                $cacheKey = sprintf(
                    'questions:nearby:%.4f:%.4f',
                    $lat + $latOffset,
                    $lng + $lngOffset
                );
                // Forget all pages for this area
                for ($page = 1; $page <= 5; $page++) {
                    Cache::forget("{$cacheKey}:10:{$page}");
                }
            }
        }
    }

    public function getFeedQuestions(
        string $sort = 'recent',
        ?string $city = null,
        int $page = 1,
        int $perPage = 20
    ): LengthAwarePaginator {
        return $this->questionRepository->findForFeed(
            sort: $sort,
            city: $city,
            perPage: $perPage,
        );
    }

    public function getPopularCities(int $limit = 20): array
    {
        return $this->questionRepository->getPopularCities($limit);
    }

    public function getUserQuestions(User $user, int $page = 1): LengthAwarePaginator
    {
        return Question::select([
                'id', 'user_id', 'title', 'description',
                'latitude', 'longitude', 'location_name', 'city',
                'answers_count', 'has_unread_answers', 'is_deleted',
                'created_at', 'updated_at',
            ])
            ->where('user_id', $user->id)
            ->where('is_deleted', false)
            ->with('user')
            ->orderByDesc('created_at')
            ->paginate(20, ['*'], 'page', $page);
    }

    public function getNearbyQuestions(
        float $latitude,
        float $longitude,
        int $radiusKm = 10,
        int $perPage = 20
    ): LengthAwarePaginator {
        $page = request()->input('page', 1);

        $cacheKey = sprintf(
            'questions:nearby:%.4f:%.4f:%d:%d',
            $latitude,
            $longitude,
            $radiusKm,
            $page
        );

        return Cache::remember($cacheKey, now()->addMinutes(5), function () use ($latitude, $longitude, $radiusKm, $perPage) {
            return $this->questionRepository->findNearby(
                latitude: $latitude,
                longitude: $longitude,
                radiusKm: $radiusKm,
                perPage: $perPage,
            );
        });
    }
}

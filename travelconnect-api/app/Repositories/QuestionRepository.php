<?php

namespace App\Repositories;

use App\Models\Question;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

class QuestionRepository
{
    public function __construct(
        private readonly Question $model
    ) {}

    public function findNearby(
        float $latitude,
        float $longitude,
        int $radiusKm,
        int $perPage = 20,
        int $maxPage = 5
    ): LengthAwarePaginator {
        $radiusMeters = $radiusKm * 1000;

        $paginator = $this->model
            ->select([
                'id', 'user_id', 'title', 'description',
                'latitude', 'longitude', 'location_name', 'city',
                'answers_count', 'has_unread_answers', 'is_deleted',
                'created_at', 'updated_at',
                DB::raw("ST_Distance_Sphere(
                    location,
                    ST_SRID(POINT(?, ?), 4326)
                ) as distance_meters")
            ])
            ->addBinding([$longitude, $latitude], 'select')
            ->whereRaw("ST_Distance_Sphere(
                location,
                ST_SRID(POINT(?, ?), 4326)
            ) <= ?", [$longitude, $latitude, $radiusMeters])
            ->where('is_deleted', false)
            ->with(['user:id,name,avatar_url,user_type,trust_score'])
            ->orderByDesc('created_at')
            ->paginate($perPage);

        // Enforce max page limit (5 pages = 100 questions max)
        $currentPage = $paginator->currentPage();
        if ($currentPage > $maxPage) {
            return new \Illuminate\Pagination\LengthAwarePaginator(
                collect([]),
                $paginator->total(),
                $perPage,
                $currentPage
            );
        }

        return $paginator;
    }

    public function findForFeed(
        string $sort = 'recent',
        ?string $city = null,
        int $perPage = 20
    ): LengthAwarePaginator {
        $query = $this->model
            ->select([
                'id', 'user_id', 'title', 'description',
                'latitude', 'longitude', 'location_name', 'city',
                'answers_count', 'has_unread_answers', 'is_deleted',
                'created_at', 'updated_at',
            ])
            ->where('is_deleted', false)
            ->with(['user:id,name,avatar_url,user_type,trust_score']);

        if ($city) {
            $query->where('city', $city);
        }

        if ($sort === 'popular') {
            $query->orderByDesc('answers_count')
                  ->orderByDesc('created_at');
        } else {
            $query->orderByDesc('created_at');
        }

        return $query->paginate($perPage);
    }

    public function getPopularCities(int $limit = 20): array
    {
        return $this->model
            ->select('city', DB::raw('COUNT(*) as questions_count'))
            ->where('is_deleted', false)
            ->whereNotNull('city')
            ->where('city', '!=', '')
            ->groupBy('city')
            ->orderByDesc('questions_count')
            ->limit($limit)
            ->get()
            ->toArray();
    }
}

<?php

namespace Database\Factories;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\DB;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Question>
 */
class QuestionFactory extends Factory
{
    public function definition(): array
    {
        $latitude = fake()->latitude(35.5, 35.8);
        $longitude = fake()->longitude(139.5, 139.8);

        return [
            'user_id' => User::factory(),
            'title' => fake()->sentence(6),
            'description' => fake()->text(200),
            'latitude' => $latitude,
            'longitude' => $longitude,
            'location' => DB::raw("ST_SRID(POINT({$longitude}, {$latitude}), 4326)"),
            'location_name' => fake()->city() . ', Tokyo',
            'city' => 'Tokyo',
            'answers_count' => 0,
            'has_unread_answers' => false,
            'is_deleted' => false,
        ];
    }

    public function withAnswers(int $count = 3): static
    {
        return $this->state(fn (array $attributes) => [
            'answers_count' => $count,
        ]);
    }

    public function deleted(): static
    {
        return $this->state(fn (array $attributes) => [
            'is_deleted' => true,
        ]);
    }

    public function at(float $latitude, float $longitude): static
    {
        return $this->state(fn (array $attributes) => [
            'latitude' => $latitude,
            'longitude' => $longitude,
            'location' => DB::raw("ST_SRID(POINT({$longitude}, {$latitude}), 4326)"),
        ]);
    }
}

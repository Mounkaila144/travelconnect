<?php

namespace Database\Factories;

use App\Models\Question;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Answer>
 */
class AnswerFactory extends Factory
{
    public function definition(): array
    {
        return [
            'question_id' => Question::factory(),
            'user_id' => User::factory(),
            'content' => fake()->text(300),
            'average_rating' => 0.0,
            'ratings_count' => 0,
            'is_deleted' => false,
        ];
    }

    public function deleted(): static
    {
        return $this->state(fn (array $attributes) => [
            'is_deleted' => true,
        ]);
    }

    public function rated(float $avgRating = 4.0, int $count = 5): static
    {
        return $this->state(fn (array $attributes) => [
            'average_rating' => $avgRating,
            'ratings_count' => $count,
        ]);
    }
}

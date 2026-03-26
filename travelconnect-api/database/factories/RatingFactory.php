<?php

namespace Database\Factories;

use App\Models\Answer;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Rating>
 */
class RatingFactory extends Factory
{
    public function definition(): array
    {
        return [
            'answer_id' => Answer::factory(),
            'user_id' => User::factory(),
            'score' => fake()->numberBetween(1, 5),
        ];
    }
}

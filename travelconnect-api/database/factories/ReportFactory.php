<?php

namespace Database\Factories;

use App\Models\Question;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class ReportFactory extends Factory
{
    public function definition(): array
    {
        return [
            'reporter_id' => User::factory(),
            'reportable_type' => Question::class,
            'reportable_id' => Question::factory(),
            'reason' => fake()->randomElement(['spam', 'offensive', 'false_info', 'other']),
            'comment' => fake()->optional()->sentence(),
            'status' => 'pending',
        ];
    }
}

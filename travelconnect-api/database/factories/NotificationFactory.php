<?php

namespace Database\Factories;

use App\Models\Notification;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class NotificationFactory extends Factory
{
    protected $model = Notification::class;

    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'type' => 'new_answer',
            'title' => 'Nouvelle réponse',
            'body' => $this->faker->sentence(),
            'data' => [
                'type' => 'new_answer',
                'question_id' => (string) $this->faker->randomNumber(),
            ],
            'read_at' => null,
        ];
    }

    public function read(): static
    {
        return $this->state(fn () => [
            'read_at' => now(),
        ]);
    }

    public function nearbyQuestion(): static
    {
        return $this->state(fn () => [
            'type' => 'nearby_question',
            'title' => 'Nouvelle question près de Tokyo',
            'data' => [
                'type' => 'nearby_question',
                'question_id' => (string) $this->faker->randomNumber(),
            ],
        ]);
    }
}

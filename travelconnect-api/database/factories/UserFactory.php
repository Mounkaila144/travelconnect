<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\User>
 */
class UserFactory extends Factory
{
    public function definition(): array
    {
        return [
            'name' => fake()->name(),
            'email' => fake()->unique()->safeEmail(),
            'provider' => 'google',
            'provider_id' => fake()->unique()->uuid(),
            'avatar_url' => fake()->imageUrl(),
            'bio' => fake()->text(100),
            'country_code' => 'JP',
            'user_type' => 'traveler',
            'trust_score' => 0.00,
            'is_new' => true,
            'is_banned' => false,
        ];
    }

    public function banned(): static
    {
        return $this->state(fn (array $attributes) => [
            'is_banned' => true,
        ]);
    }

    public function apple(): static
    {
        return $this->state(fn (array $attributes) => [
            'provider' => 'apple',
        ]);
    }
}

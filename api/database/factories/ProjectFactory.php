<?php

namespace Database\Factories;

use App\Enums\EProjectState;
use App\Models\Customer;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Project>
 */
class ProjectFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $startDate = $this->faker->dateTimeBetween('-6 months', '+1 month');

        return [
            'name' => $this->faker->catchPhrase(),
            'description' => $this->faker->paragraph(),
            'state' => $this->faker->randomElement(EProjectState::values()),
            'is_public' => $this->faker->boolean(50),
            'start_date' => $startDate,
            'end_date' => $this->faker->optional(0.8)->dateTimeBetween($startDate, '+6 months'),
            'budget' => $this->faker->optional()->numberBetween(100000, 10000000),
            'estimated_hours' => $this->faker->optional()->numberBetween(10, 1000),
            'customer_id' => Customer::inRandomOrder()->first()->id ?? Customer::factory(),
        ];
    }
}

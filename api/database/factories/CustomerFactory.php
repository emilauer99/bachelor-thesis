<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Customer>
 */
class CustomerFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        // Generate a fake image and store it in the 'public' disk under the 'customers' folder
        $image = UploadedFile::fake()->image(fake()->company() . '.jpg');
        $path = Storage::putFile('customers', $image);
        return [
            'name' => $this->faker->company(),
            'image_path' => $path,
        ];
    }
}

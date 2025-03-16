<?php

namespace Database\Seeders;

use App\Enums\ERole;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        User::factory()->create([
            'email' => 'admin@pmt.at',
            'password' => Hash::make('12345678'),
            'role' => ERole::ADMIN
        ]);
        User::factory()->create([
            'email' => 'employee@pmt.at',
            'password' => Hash::make('12345678'),
            'role' => ERole::EMPLOYEE
        ]);

        $this->call([
            CustomerSeeder::class,
            ProjectSeeder::class,
        ]);
    }
}

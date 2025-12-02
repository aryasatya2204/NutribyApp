<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // Urutan ini sangat penting!
        $this->call([
            RecipeSeeder::class,
            AllergySeeder::class,
            GrowthStandardSeeder::class,
        ]);
        
        // Buat user untuk testing
        User::firstOrCreate(
            ['email' => 'test@example.com'],
            ['name' => 'Test User', 'password' => Hash::make('password')]
        );
    }
}
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
            IngredientSeeder::class,      // 1. Buat "kamus" bahan dulu
            RecipeSeeder::class,          // 2. Buat resep menggunakan bahan yang ada
            AllergySeeder::class,         // 3. Buat data alergi menggunakan bahan yang ada
            GrowthStandardSeeder::class,
        ]);
        
        // Buat user untuk testing
        User::firstOrCreate(
            ['email' => 'test@example.com'],
            ['name' => 'Test User', 'password' => Hash::make('password')]
        );
    }
}
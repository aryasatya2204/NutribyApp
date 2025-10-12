<?php

namespace Database\Seeders;

// Tambahkan ini di atas
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
        // HAPUS ATAU KOMENTARI KODE BAWAAN SEPERTI DI BAWAH INI:
        // \App\Models\User::factory(10)->create();
        
        // \App\Models\User::factory()->create([
        //     'name' => 'Test User',
        //     'email' => 'test@example.com',
        // ]);

        // GANTI DENGAN KODE SEDERHANA INI:
        // Membuat satu user 'test' untuk development, hanya dengan kolom yang kita punya.
        User::create([
            'name' => 'Test User',
            'email' => 'test@example.com',
            'password' => Hash::make('password'), // Ganti 'password' dengan password yang Anda inginkan
        ]);

        // Panggil seeder kita yang lain
        $this->call([
            GrowthStandardSeeder::class,
            // Anda bisa menambahkan RecipeSeeder, IngredientSeeder, dll. di sini
        ]);
    }
}
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Ingredient;
use Illuminate\Support\Facades\DB;

class IngredientSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('ingredients')->delete();

        $ingredients = [
            'Beras Putih', 'Hati Ayam', 'Wortel', 'Minyak Kelapa', 'Ikan Kembung', 
            'Tomat', 'Bawang Putih', 'Daging Sapi', 'Brokoli', 'Susu UHT', 'Tahu Putih',
            'Telur Ayam', 'Kentang', 'Bayam', 'Udang', 'Kacang Hijau', 'Santan',
            'Pisang Ambon', 'Alpukat', 'Keju'
        ];

        foreach ($ingredients as $ingredient) {
            Ingredient::create(['name' => $ingredient]);
        }
    }
}
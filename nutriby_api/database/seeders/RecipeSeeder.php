<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Recipe;
use App\Models\Ingredient;
use Illuminate\Support\Facades\DB;

class RecipeSeeder extends Seeder
{
    public function run(): void
    {
        // Menggunakan transaction untuk performa yang lebih baik
        DB::transaction(function () {
            DB::table('recipe_ingredient')->delete();
            DB::table('recipes')->delete();

            // --- Kumpulan Resep (Total 22) ---
            $this->createRecipe('Bubur Hati Ayam Wortel', 6, 8, 'puree', 7000, 130, 12, 5, ['Beras Putih' => '20g', 'Hati Ayam' => '25g', 'Wortel' => '10g', 'Minyak Zaitun' => '1 sdt']);
            $this->createRecipe('Tim Ikan Kembung Tomat', 8, 12, 'mashed', 9000, 150, 11, 7, ['Beras Putih' => '30g', 'Ikan Kembung' => '30g', 'Tomat' => '10g', 'Bawang Putih' => '1 siung']);
            $this->createRecipe('Nasi Lembek Daging Sapi Brokoli', 9, 18, 'soft_chunks', 15000, 180, 15, 8, ['Beras Putih' => '40g', 'Daging Sapi' => '30g', 'Brokoli' => '15g', 'Keju' => '1 sdm']);
            $this->createRecipe('Puree Kentang Bayam & Telur', 7, 10, 'puree', 6000, 140, 8, 6, ['Kentang' => '50g', 'Bayam' => '10g', 'Telur Ayam' => '1/2 butir', 'Susu UHT' => '30ml']);
            $this->createRecipe('Bubur Sumsum Kacang Hijau', 6, null, 'puree', 5000, 160, 5, 7, ['Kacang Hijau' => '20g', 'Santan' => '50ml']);
            $this->createRecipe('Risotto Tahu Udang', 10, 24, 'soft_chunks', 12000, 170, 13, 6, ['Beras Putih' => '40g', 'Tahu Putih' => '20g', 'Udang' => '25g', 'Keju' => '1 sdm']);
            $this->createRecipe('Pancake Pisang Sederhana', 9, null, 'finger_food', 4000, 110, 4, 4, ['Pisang Ambon' => '1/2 buah', 'Telur Ayam' => '1/2 butir']);
            $this->createRecipe('Puding Alpukat Santan', 7, null, 'puree', 8000, 190, 3, 15, ['Alpukat' => '50g', 'Santan' => '40ml']);
            $this->createRecipe('Bola Nasi Ikan Isi Keju', 12, null, 'finger_food', 11000, 160, 10, 6, ['Beras Putih' => '50g', 'Ikan Kembung' => '20g', 'Keju' => '10g', 'Wortel' => '5g']);
            $this->createRecipe('Omelet Sayur Mini', 10, 24, 'finger_food', 7000, 130, 9, 8, ['Telur Ayam' => '1 butir', 'Wortel' => '5g', 'Bayam' => '5g', 'Keju' => '1 sdt']);
            $this->createRecipe('Sup Jagung Manis & Daging Ayam', 8, null, 'mashed', 8500, 145, 10, 5, ['Jagung Manis' => '30g', 'Daging Ayam' => '25g', 'Wortel' => '10g']);
            $this->createRecipe('Bubur Salmon & Brokoli', 7, 10, 'puree', 18000, 200, 14, 11, ['Beras Putih' => '20g', 'Ikan Salmon' => '30g', 'Brokoli' => '15g']);
            $this->createRecipe('Nasi Tim Tempe Hati Ayam', 9, 18, 'soft_chunks', 6500, 165, 13, 6, ['Beras Putih' => '35g', 'Tempe' => '20g', 'Hati Ayam' => '20g']);
            $this->createRecipe('Ubi Jalar Kukus Lumat', 6, null, 'puree', 3000, 90, 2, 1, ['Ubi Jalar' => '80g']);
            $this->createRecipe('Stick Kentang & Keju Panggang', 10, null, 'finger_food', 5500, 120, 5, 7, ['Kentang' => '60g', 'Keju' => '15g', 'Minyak Zaitun' => '1/2 sdt']);
            $this->createRecipe('Bubur Kacang Merah & Daging Sapi', 8, 12, 'mashed', 14000, 190, 16, 9, ['Kacang Merah' => '25g', 'Daging Sapi' => '25g', 'Beras Putih' => '20g']);
            $this->createRecipe('Mashed Potato & Salmon', 8, null, 'mashed', 17000, 210, 13, 12, ['Kentang' => '60g', 'Ikan Salmon' => '25g', 'Susu UHT' => '20ml']);
            $this->createRecipe('Nasi Goreng Bayi (Tanpa Garam)', 12, null, 'soft_chunks', 9500, 175, 11, 8, ['Beras Putih' => '40g', 'Telur Ayam' => '1/2 butir', 'Daging Ayam' => '20g', 'Bawang Putih' => '1/2 siung']);
            $this->createRecipe('Sup Krim Tomat & Roti Tawar', 9, null, 'mashed', 6000, 115, 4, 5, ['Tomat' => '1 buah', 'Roti Tawar' => '1/2 lembar', 'Susu UHT' => '50ml']);
            $this->createRecipe('Tumis Cumi & Jagung Manis', 11, 24, 'soft_chunks', 13000, 160, 12, 7, ['Cumi' => '30g', 'Jagung Manis' => '20g', 'Bawang Putih' => '1/2 siung']);
            $this->createRecipe('Bubur Edamame & Ayam', 7, 10, 'puree', 9000, 155, 14, 6, ['Edamame' => '30g', 'Daging Ayam' => '25g', 'Beras Putih' => '15g']);
            $this->createRecipe('Perkedel Tahu & Wortel', 10, null, 'finger_food', 4500, 100, 8, 5, ['Tahu Putih' => '40g', 'Wortel' => '10g', 'Telur Ayam' => '1/4 butir']);
        });
    }

    private function createRecipe($title, $minAge, $maxAge, $texture, $cost, $cal, $prot, $fat, $ingredientsData)
    {
        $recipe = Recipe::create([
            'title' => $title, 'description' => 'Menu lezat dan bergizi untuk si kecil.', 'instructions' => 'Campurkan semua bahan dan masak hingga matang dan empuk. Sesuaikan tekstur dengan kemampuan bayi.',
            'min_age_months' => $minAge, 'max_age_months' => $maxAge, 'texture' => $texture, 'estimated_cost' => $cost,
            'calories' => $cal, 'protein_grams' => $prot, 'fat_grams' => $fat, 'serving_size' => '1-2 porsi'
        ]);

        foreach ($ingredientsData as $name => $quantity) {
            $ingredient = Ingredient::where('name', $name)->first();
            if ($ingredient) {
                $recipe->ingredients()->attach($ingredient->id, ['quantity' => $quantity]);
            }
        }
    }
}
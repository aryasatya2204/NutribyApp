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
        DB::table('recipe_ingredient')->delete();
        DB::table('recipes')->delete();

        $this->createRecipe(
            'Bubur Hati Ayam Wortel', 6, 8, 'puree', 7000, 130, 12, 5,
            ['Beras Putih' => '20g', 'Hati Ayam' => '25g', 'Wortel' => '10g', 'Minyak Kelapa' => '1 sdt']
        );

        $this->createRecipe(
            'Tim Ikan Kembung Tomat', 8, 12, 'mashed', 9000, 150, 11, 7,
            ['Beras Putih' => '30g', 'Ikan Kembung' => '30g', 'Tomat' => '10g', 'Bawang Putih' => '1 siung']
        );
        
        $this->createRecipe(
            'Nasi Lembek Daging Sapi Brokoli', 9, 18, 'soft_chunks', 15000, 180, 15, 8,
            ['Beras Putih' => '40g', 'Daging Sapi' => '30g', 'Brokoli' => '15g', 'Keju' => '1 sdm']
        );

        $this->createRecipe(
            'Puree Kentang Bayam & Telur', 7, 10, 'puree', 6000, 140, 8, 6,
            ['Kentang' => '50g', 'Bayam' => '10g', 'Telur Ayam' => '1/2 butir', 'Susu UHT' => '30ml']
        );

        $this->createRecipe(
            'Bubur Sumsum Kacang Hijau', 6, null, 'puree', 5000, 160, 5, 7,
            ['Kacang Hijau' => '20g', 'Santan' => '50ml']
        );

        $this->createRecipe(
            'Risotto Tahu Udang', 10, 24, 'soft_chunks', 12000, 170, 13, 6,
            ['Beras Putih' => '40g', 'Tahu Putih' => '20g', 'Udang' => '25g', 'Keju' => '1 sdm']
        );

        $this->createRecipe(
            'Pancake Pisang Sederhana', 9, null, 'finger_food', 4000, 110, 4, 4,
            ['Pisang Ambon' => '1/2 buah', 'Telur Ayam' => '1/2 butir']
        );
        
        $this->createRecipe(
            'Puding Alpukat Santan', 7, null, 'puree', 8000, 190, 3, 15,
            ['Alpukat' => '50g', 'Santan' => '40ml']
        );

        $this->createRecipe(
            'Bola Nasi Ikan Isi Keju', 12, null, 'finger_food', 11000, 160, 10, 6,
            ['Beras Putih' => '50g', 'Ikan Kembung' => '20g', 'Keju' => '10g', 'Wortel' => '5g']
        );
        
        $this->createRecipe(
            'Omelet Sayur Mini', 10, 24, 'finger_food', 7000, 130, 9, 8,
            ['Telur Ayam' => '1 butir', 'Wortel' => '5g', 'Bayam' => '5g', 'Keju' => '1 sdt']
        );
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
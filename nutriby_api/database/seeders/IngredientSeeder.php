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
            // Karbohidrat
            ['name' => 'Beras Putih', 'image_url' => 'https://i.ibb.co/68000Gq/beras-putih.png'],
            ['name' => 'Kentang', 'image_url' => 'https://i.ibb.co/3kW04bC/kentang.png'],
            ['name' => 'Ubi Jalar', 'image_url' => 'https://i.ibb.co/KXs60YV/ubi-jalar.png'],
            ['name' => 'Jagung Manis', 'image_url' => 'https://i.ibb.co/RHYfD3t/jagung-manis.png'],
            ['name' => 'Roti Tawar', 'image_url' => 'https://i.ibb.co/wMq1v0v/roti-tawar.png'],
            // Protein Hewani
            ['name' => 'Daging Sapi', 'image_url' => 'https://i.ibb.co/tZ5G1hJ/daging-sapi.png'],
            ['name' => 'Hati Ayam', 'image_url' => 'https://i.ibb.co/p3wczv0/hati-ayam.png'],
            ['name' => 'Ikan Salmon', 'image_url' => 'https://i.ibb.co/4M4f2yG/ikan-salmon.png'],
            ['name' => 'Ikan Kembung', 'image_url' => 'https://i.ibb.co/c1mY5Np/ikan-kembung.png'],
            ['name' => 'Udang', 'image_url' => 'https://i.ibb.co/C0kph0D/udang.png'],
            ['name' => 'Cumi', 'image_url' => 'https://i.ibb.co/1GSxJ4b/cumi.png'],
            ['name' => 'Telur Ayam', 'image_url' => 'https://i.ibb.co/tHq0B0y/telur-ayam.png'],
            ['name' => 'Daging Ayam', 'image_url' => 'https://i.ibb.co/C9x811J/daging-ayam.png'],
            // Protein Nabati
            ['name' => 'Tahu Putih', 'image_url' => 'https://i.ibb.co/2v13yqH/tahu-putih.png'],
            ['name' => 'Tempe', 'image_url' => 'https://i.ibb.co/1q2R3W3/tempe.png'],
            ['name' => 'Kacang Hijau', 'image_url' => 'https://i.ibb.co/tqH8gWW/kacang-hijau.png'],
            ['name' => 'Kacang Merah', 'image_url' => 'https://i.ibb.co/bWc9r1s/kacang-merah.png'],
            ['name' => 'Kacang Tanah', 'image_url' => 'https://i.ibb.co/L5w2XN7/kacang-tanah.png'],
            ['name' => 'Edamame', 'image_url' => 'https://i.ibb.co/K2KHzfQ/edamame.png'],
            // Sayuran & Buah
            ['name' => 'Wortel', 'image_url' => 'https://i.ibb.co/Gvx0GVB/wortel.png'],
            ['name' => 'Brokoli', 'image_url' => 'https://i.ibb.co/Xz90v1K/brokoli.png'],
            ['name' => 'Bayam', 'image_url' => 'https://i.ibb.co/JqjT2W9/bayam.png'],
            ['name' => 'Tomat', 'image_url' => 'https://i.ibb.co/wJg8wM5/tomat.png'],
            ['name' => 'Alpukat', 'image_url' => 'https://i.ibb.co/fny2NnS/alpukat.png'],
            ['name' => 'Pisang Ambon', 'image_url' => 'https://i.ibb.co/6y4T0S3/pisang.png'],
            // Lemak & Lainnya
            ['name' => 'Santan', 'image_url' => 'https://i.ibb.co/7gMgvF6/santan.png'],
            ['name' => 'Keju', 'image_url' => 'https://i.ibb.co/4PnMmGz/keju.png'],
            ['name' => 'Susu UHT', 'image_url' => 'https://i.ibb.co/sK6m6d8/susu-uht.png'],
            ['name' => 'Minyak Zaitun', 'image_url' => 'https://i.ibb.co/5cQf1YB/minyak-zaitun.png'],
            ['name' => 'Bawang Putih', 'image_url' => 'https://i.ibb.co/X7wsHq3/bawang-putih.png']
        ];

        foreach ($ingredients as $ingredient) {
            Ingredient::create([
                'name' => $ingredient['name'],
                'image_url' => $ingredient['image_url']
            ]);
        }
    }
}
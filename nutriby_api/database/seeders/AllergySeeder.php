<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Allergy;
use App\Models\Ingredient;
use Illuminate\Support\Facades\DB;

class AllergySeeder extends Seeder
{
    public function run(): void
    {
        DB::transaction(function () {
            DB::table('allergy_ingredient')->delete();
            DB::table('allergies')->delete();

            $this->createAllergy(
                'Alergi Telur',
                'Ruam kulit, gatal-gatal, bengkak...',
                'Hindari semua produk yang mengandung telur.',
                ['Telur Ayam'],
                null // Tidak perlu gambar grup, karena hanya 1 bahan
            );

            $this->createAllergy(
                'Alergi Seafood (Crustacea)',
                'Gatal di mulut, biduran, pembengkakan...',
                'Hindari udang, kepiting, lobster, dan seafood bercangkang lainnya.',
                ['Udang', 'Cumi'],
                'https://i.ibb.co/gv3Ym1s/seafood.png' // Gambar grup
            );

            $this->createAllergy(
                'Alergi Kacang-kacangan',
                'Reaksi bisa sangat berat dan cepat (anafilaksis)...',
                'Hindari semua jenis kacang dan produk yang mungkin terkontaminasi.',
                ['Kacang Tanah', 'Kacang Merah'],
                'https://i.ibb.co/6X3S27L/kacang-kacangan.png' // Gambar grup
            );
            
            $this->createAllergy(
                'Alergi Susu Sapi',
                'Masalah pencernaan (diare, muntah), ruam kulit...',
                'Hindari susu sapi dan produk turunannya.',
                ['Susu UHT', 'Keju'],
                'https://i.ibb.co/8Yn4xPB/dairy.png' // Gambar grup
            );
            
             $this->createAllergy(
                'Alergi Kedelai',
                'Gatal-gatal, eksim, sakit perut, atau diare...',
                'Hindari produk turunan kedelai seperti tahu, tempe, edamame.',
                ['Tahu Putih', 'Tempe', 'Edamame'],
                'https://i.ibb.co/N1pXJv9/kedelai.png' // Gambar grup
            );
        });
    }

    private function createAllergy(string $name, string $symptoms, string $prevention, array $ingredientNames, ?string $groupImageUrl): void
    {
        $allergy = Allergy::create([
            'name' => $name,
            'symptoms' => $symptoms,
            'handling_and_prevention' => $prevention,
            'image_url' => $groupImageUrl // Menyimpan URL gambar grup
        ]);

        $ingredientIds = Ingredient::whereIn('name', $ingredientNames)->pluck('id');

        if ($ingredientIds->isNotEmpty()) {
            $allergy->ingredients()->attach($ingredientIds);
        }
    }
}
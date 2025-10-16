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
        DB::table('allergies')->delete();

        $telur = Ingredient::where('name', 'Telur Ayam')->first();
        $udang = Ingredient::where('name', 'Udang')->first();
        $susu = Ingredient::where('name', 'Susu UHT')->first();
        $kacang = Ingredient::where('name', 'Kacang Hijau')->first();

        Allergy::create([
            'ingredient_id' => $telur?->id,
            'name' => 'Alergi Telur',
            'symptoms' => 'Ruam kulit atau gatal-gatal, bengkak di sekitar mulut, gangguan pencernaan seperti muntah atau diare, hingga reaksi anafilaksis pada kasus berat.',
            'handling_and_prevention' => 'Hindari semua produk yang mengandung telur. Perhatikan label makanan dengan cermat. Konsultasikan dengan dokter untuk diagnosis dan penanganan yang tepat. Pengenalan telur dapat dimulai sejak usia 6 bulan secara bertahap.'
        ]);

        Allergy::create([
            'ingredient_id' => $udang?->id,
            'name' => 'Alergi Seafood (Udang)',
            'symptoms' => 'Gatal di mulut, ruam kulit (biduran), pembengkakan pada wajah, bibir, atau lidah, sakit perut, dan kesulitan bernapas.',
            'handling_and_prevention' => 'Hindari udang dan jenis seafood bercangkang lainnya. Selalu informasikan riwayat alergi saat makan di luar. Siapkan obat anti-alergi sesuai anjuran dokter.'
        ]);

        Allergy::create([
            'ingredient_id' => $susu?->id,
            'name' => 'Alergi Susu Sapi',
            'symptoms' => 'Masalah pencernaan (diare, muntah, sembelit), ruam kulit (eksim), hingga gejala pernapasan seperti mengi. Jangan samakan dengan intoleransi laktosa.',
            'handling_and_prevention' => 'Hindari susu sapi dan produk turunannya seperti keju dan yogurt. Gunakan formula hipoalergenik atau alternatif susu lain sesuai rekomendasi dokter anak.'
        ]);

        Allergy::create([
            'ingredient_id' => $kacang?->id,
            'name' => 'Alergi Kacang',
            'symptoms' => 'Reaksi bisa sangat berat dan cepat, termasuk anafilaksis. Gejala ringan meliputi gatal-gatal, ruam, dan sakit perut.',
            'handling_and_prevention' => 'Hindari semua jenis kacang dan produk yang mungkin terkontaminasi kacang. Baca label makanan dengan sangat teliti. Bawa selalu epinefrin auto-injector jika diresepkan oleh dokter.'
        ]);
    }
}
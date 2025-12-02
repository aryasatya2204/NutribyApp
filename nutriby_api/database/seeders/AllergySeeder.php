<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Allergy;
use App\Models\Ingredient;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;

class AllergySeeder extends Seeder
{
    public function run(): void
    {
        $csvFile = database_path('data/allergies.csv');

        if (!File::exists($csvFile)) {
            $this->command->error("File tidak ditemukan: $csvFile");
            return;
        }

        DB::transaction(function () use ($csvFile) {
            // Gunakan separator titik koma (;)
            if (($handle = fopen($csvFile, "r")) !== FALSE) {
                $header = null;

                while (($data = fgetcsv($handle, 2000, ";")) !== FALSE) {
                    if (isset($data[0])) $data[0] = preg_replace('/[\x00-\x1F\x80-\xFF]/', '', $data[0]);

                    if (!$header) {
                        foreach ($data as $cell) {
                            if (stripos($cell, 'Nama Alergi') !== false) {
                                // PENTING: Trim header
                                $header = array_map('trim', $data);
                                break;
                            }
                        }
                        continue;
                    }

                    if (count($data) < count($header)) {
                        $data = array_pad($data, count($header), null);
                    }
                    $row = array_combine($header, $data);

                    if (empty($row['Nama Alergi'])) continue;

                    // Ambil Image URL dengan aman
                    $imgUrl = $row['Image URL'] ?? null;
                    if (!$imgUrl) {
                        foreach ($row as $key => $val) {
                            if (stripos($key, 'Image') !== false) {
                                $imgUrl = $val;
                                break;
                            }
                        }
                    }

                    $allergy = Allergy::create([
                        'name'                      => $row['Nama Alergi'],
                        'symptoms'                  => $row['Gejala Utama'] ?? '',
                        'handling_and_prevention'   => $row['Penanganan Medis'] ?? '',
                        'image_url'                 => $imgUrl,
                    ]);

                    if (!empty($row['Bahan Pemicu (Trigger Ingredients)'])) {
                        $this->processTriggerIngredients($allergy, $row['Bahan Pemicu (Trigger Ingredients)']);
                    }
                }
                fclose($handle);
            }
        });

        $this->command->info('AllergySeeder berhasil dijalankan!');
    }

    private function processTriggerIngredients($allergy, $rawString)
    {
        $items = explode(',', $rawString);
        foreach ($items as $item) {
            $itemName = trim($item);
            if (empty($itemName)) continue;
            $standardName = ucwords(strtolower($itemName));
            
            $ingredient = Ingredient::firstOrCreate(
                ['name' => $standardName],
                ['category' => 'Alergen']
            );
            $allergy->ingredients()->syncWithoutDetaching([$ingredient->id]);
        }
    }
}
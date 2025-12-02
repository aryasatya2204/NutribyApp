<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Recipe;
use App\Models\Ingredient;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;

class RecipeSeeder extends Seeder
{
    public function run(): void
    {
        $csvFile = database_path('data/recipes.csv');

        if (!File::exists($csvFile)) {
            $this->command->error("File tidak ditemukan: $csvFile");
            return;
        }

        DB::transaction(function () use ($csvFile) {
            // Gunakan separator titik koma (;)
            if (($handle = fopen($csvFile, "r")) !== FALSE) {
                $header = null;

                while (($data = fgetcsv($handle, 2000, ";")) !== FALSE) {
                    
                    // 1. Bersihkan BOM (Byte Order Mark)
                    if (isset($data[0])) $data[0] = preg_replace('/[\x00-\x1F\x80-\xFF]/', '', $data[0]);

                    // 2. Deteksi Header Fleksibel
                    if (!$header) {
                        foreach ($data as $cell) {
                            if (stripos($cell, 'Nama Menu') !== false) {
                                // PENTING: Bersihkan setiap sel header dari spasi/enter tersembunyi
                                $header = array_map('trim', $data); 
                                break;
                            }
                        }
                        continue;
                    }

                    // Mapping Data
                    if (count($data) < count($header)) {
                        $data = array_pad($data, count($header), null);
                    }
                    
                    // Gabungkan header bersih dengan data
                    $row = array_combine($header, $data);

                    if (empty($row['Nama Menu'])) continue;

                    // 3. Debugging: Cek apakah Image URL terbaca?
                    // Jika null terus, berarti header di CSV tidak match dengan teks 'Image URL'
                    $imgUrl = $row['Image URL'] ?? null;
                    if (!$imgUrl) {
                        // Coba cari manual jika key-nya agak beda
                        foreach ($row as $key => $val) {
                            if (stripos($key, 'Image') !== false) {
                                $imgUrl = $val;
                                break;
                            }
                        }
                    }

                    // Buat Data Resep
                    $recipe = Recipe::create([
                        'title'          => $row['Nama Menu'],
                        'description'    => $row['Deskripsi'] ?? 'Menu lezat dan bergizi.',
                        'instructions'   => $row['Cara Masak'] ?? '',
                        'min_age_months' => $this->parseNumber($row['Usia Min']),
                        'max_age_months' => $this->parseNumber($row['Usia Max']),
                        'texture'        => $this->mapTexture($row['Tekstur']), 
                        'estimated_cost' => $this->parseCurrency($row['Est. Harga']),
                        'calories'       => $this->parseNumber($row['Kalori (kkal)']),
                        'protein_grams'  => $this->parseNumber($row['Protein (g)']),
                        'fat_grams'      => $this->parseNumber($row['Lemak (g)']),
                        'iron_total_mg'  => $this->parseNumber($row['Zat Besi (mg)'] ?? 0),
                        'zinc_total_mg'  => $this->parseNumber($row['Seng (mg)'] ?? 0),
                        'nutrition_focus'=> $this->mapNutritionFocus($row['Tag Makanan'] ?? null),
                        'image_url'      => $imgUrl, // Gunakan hasil deteksi yang lebih kuat
                        'serving_size'   => '1 porsi',
                    ]);

                    // Proses Bahan
                    if (!empty($row['Bahan-Bahan'])) {
                        $this->processIngredients($recipe, $row['Bahan-Bahan']);
                    }
                }
                fclose($handle);
            }
        });
        
        $this->command->info('RecipeSeeder berhasil dijalankan!');
    }

    private function mapNutritionFocus($rawTag)
    {
        $tag = strtolower(trim($rawTag));
        if (str_contains($tag, 'peninggi')) return 'height_booster';
        if (str_contains($tag, 'berat')) return 'weight_booster';
        if (str_contains($tag, 'imun') || str_contains($tag, 'daya tahan')) return 'immune_booster';
        return 'general';
    }

    private function mapTexture($rawTexture)
    {
        $t = strtolower(trim($rawTexture));
        if (str_contains($t, 'halus')) return 'puree';        
        if (str_contains($t, 'saring')) return 'mashed';      
        if (str_contains($t, 'kasar')) return 'mashed';       
        if (str_contains($t, 'cincang')) return 'minced';     
        if (str_contains($t, 'jari')) return 'finger_food';   
        if (str_contains($t, 'lembek')) return 'soft_chunks'; 
        if (str_contains($t, 'tim')) return 'soft_chunks';    
        if (str_contains($t, 'keluarga')) return 'family_food'; 
        return 'puree'; 
    }

    private function processIngredients($recipe, $rawString)
    {
        $lines = preg_split('/(\r\n|\n|\r| - )/', $rawString);
        foreach ($lines as $line) {
            $line = trim($line);
            if (empty($line) || $line == '-') continue;
            $line = ltrim($line, '- ');

            $regex = '/^([\d\.\,\/]+\s*(?:gram|gr|g|kg|ml|l|liter|sdt|sdm|tsp|tbsp|buah|siung|butir|lembar|batang|ikat|potong|biji|ons|cangkir|gelas|mangkok|piring|botol|bungkus|kotak|kaleng|pack|slice|ruas|sachet|sendok\s+makan|sendok\s+teh)?)\s+(.+)$/i';
            $quantity = 'secukupnya';
            $ingredientName = $line;

            if (preg_match($regex, $line, $matches)) {
                $quantity = trim($matches[1]);
                $ingredientName = trim($matches[2]);
            }
            $standardName = ucwords(strtolower($ingredientName));
            $standardName = preg_replace('/\s*\(.*?\)\s*/', '', $standardName);
            $standardName = trim($standardName);

            $ingredient = Ingredient::firstOrCreate(
                ['name' => $standardName],
                ['category' => 'Umum']
            );
            $recipe->ingredients()->attach($ingredient->id, ['quantity' => $quantity]);
        }
    }

    private function parseCurrency($value) {
        return (int) preg_replace('/[^0-9]/', '', $value);
    }

    private function parseNumber($value) {
        if (empty($value) || $value === '-') return null;
        return (float) str_replace(',', '.', $value);
    }
}
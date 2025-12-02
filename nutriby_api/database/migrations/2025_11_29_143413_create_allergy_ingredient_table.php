<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('allergy_ingredient', function (Blueprint $table) {
            $table->id();
            
            // Relasi ke tabel allergies
            // Menggunakan constrained() agar otomatis mencari tabel 'allergies' & id
            // onDelete('cascade') artinya jika Alergi dihapus, data di sini ikut hilang
            $table->foreignId('allergy_id')
                  ->constrained('allergies')
                  ->onDelete('cascade');

            // Relasi ke tabel ingredients
            // onDelete('cascade') artinya jika Bahan dihapus, data di sini ikut hilang
            $table->foreignId('ingredient_id')
                  ->constrained('ingredients')
                  ->onDelete('cascade');

            // Mencegah duplikasi data (agar 1 alergi tidak memiliki 2 bahan yang sama persis)
            $table->unique(['allergy_id', 'ingredient_id']);

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('allergy_ingredient');
    }
};
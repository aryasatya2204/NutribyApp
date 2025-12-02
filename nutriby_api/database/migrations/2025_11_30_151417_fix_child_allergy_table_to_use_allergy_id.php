<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     * 
     * TUJUAN: Mengubah child_allergy dari ingredient_id menjadi allergy_id
     * Sehingga anak menyimpan grup alergi (contoh: "Alergi Telur") 
     * bukan bahan mentah (contoh: "Telur Ayam", "Telur Bebek")
     */
    public function up(): void
    {
        // Drop tabel lama dan buat ulang
        Schema::dropIfExists('child_allergy');
        
        Schema::create('child_allergy', function (Blueprint $table) {
            $table->id();
            
            // Relasi ke child
            $table->foreignId('child_id')
                  ->constrained('children')
                  ->onDelete('cascade');
            
            // ✅ FIXED: Sekarang pakai allergy_id (bukan ingredient_id)
            $table->foreignId('allergy_id')
                  ->constrained('allergies')
                  ->onDelete('cascade');
            
            // Prevent duplicate entries
            $table->unique(['child_id', 'allergy_id']);
            
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('child_allergy');
        
        // Kembalikan struktur lama jika rollback
        Schema::create('child_allergy', function (Blueprint $table) {
            $table->id();
            $table->foreignId('child_id')->constrained()->onDelete('cascade');
            $table->foreignId('ingredient_id')->constrained()->onDelete('cascade');
        });
    }
};
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
        // 1. Update tabel child_growth_histories (Menyimpan data Z-Score mentah)
        Schema::table('child_growth_histories', function (Blueprint $table) {
            $table->decimal('z_score_wfa', 8, 2)->nullable()->after('height')
                  ->comment('Z-Score Weight for Age (Berat/Umur)');
            $table->decimal('z_score_hfa', 8, 2)->nullable()->after('z_score_wfa')
                  ->comment('Z-Score Height for Age (Tinggi/Umur - Indikator Stunting)');
            $table->decimal('z_score_wfh', 8, 2)->nullable()->after('z_score_hfa')
                  ->comment('Z-Score Weight for Height (Berat/Tinggi - Indikator Kurus)');
        });

        // 2. Update tabel ingredients (Menambah Mikronutrisi penting untuk Stunting)
        Schema::table('ingredients', function (Blueprint $table) {
            $table->string('unit', 20)->default('gram')->after('name'); 
            
            $table->decimal('iron_mg', 8, 2)->default(0)->after('description')
                  ->comment('Kandungan Zat Besi (mg) per 100g/unit');
            $table->decimal('zinc_mg', 8, 2)->default(0)->after('iron_mg')
                  ->comment('Kandungan Seng (mg) per 100g/unit');
                  
            $table->boolean('is_allergen_high_risk')->default(false)->after('zinc_mg');
        });

        // 3. Update tabel recipes (Menambah Klasifikasi Fungsi Resep)
        Schema::table('recipes', function (Blueprint $table) {
            $table->enum('nutrition_focus', ['general', 'weight_booster', 'height_booster', 'immune_booster'])
                  ->default('general')
                  ->after('texture');
            
            $table->decimal('iron_total_mg', 8, 2)->default(0)->after('fat_grams');
            $table->decimal('zinc_total_mg', 8, 2)->default(0)->after('iron_total_mg');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('child_growth_histories', function (Blueprint $table) {
            $table->dropColumn(['z_score_wfa', 'z_score_hfa', 'z_score_wfh']);
        });

        Schema::table('ingredients', function (Blueprint $table) {
            $table->dropColumn(['unit', 'iron_mg', 'zinc_mg', 'is_allergen_high_risk']);
        });

        Schema::table('recipes', function (Blueprint $table) {
            $table->dropColumn(['nutrition_focus', 'iron_total_mg', 'zinc_total_mg']);
        });
    }
};
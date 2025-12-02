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
        Schema::create('weekly_plan_details', function (Blueprint $table) {
            $table->id();
            $table->foreignId('weekly_plan_id')->constrained()->onDelete('cascade');
            $table->foreignId('recipe_id')->constrained();
            $table->unsignedTinyInteger('day_of_week'); // 1=Senin, 2=Selasa, ..., 7=Minggu
            $table->enum('meal_type', ['pagi', 'siang', 'sore']);
            $table->json('custom_ingredients_json')->nullable();
            
            // ✅ TAMBAHKAN INI:
            $table->timestamps(); // Menambahkan created_at dan updated_at
            
            $table->unique(['weekly_plan_id', 'day_of_week', 'meal_type']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('weekly_plan_details');
    }
};
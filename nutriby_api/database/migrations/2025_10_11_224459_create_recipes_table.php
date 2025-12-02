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
        Schema::create('recipes', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->text('description');
            $table->text('instructions');
            $table->string('image_url')->nullable();
            $table->unsignedTinyInteger('min_age_months');
            $table->enum('texture', ['puree', 'mashed', 'soft_chunks', 'finger_food', 'family_food']);
            $table->unsignedInteger('estimated_cost');
            $table->string('serving_size');
            $table->unsignedInteger('calories')->nullable();
            $table->unsignedInteger('protein_grams')->nullable();
            $table->unsignedInteger('fat_grams')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('recipes');
    }
};

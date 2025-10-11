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
        Schema::create('growth_standards', function (Blueprint $table) {
            $table->id();
            $table->enum('gender', ['male', 'female']);
            $table->unsignedTinyInteger('age_in_months');
            $table->enum('metric', ['wfa', 'hfa']); // Weight-for-Age, Height-for-Age
            $table->decimal('sd3_neg', 5, 2);
            $table->decimal('sd2_neg', 5, 2);
            $table->decimal('sd1_neg', 5, 2);
            $table->decimal('median', 5, 2);
            $table->decimal('sd1_pos', 5, 2);
            $table->decimal('sd2_pos', 5, 2);
            $table->decimal('sd3_pos', 5, 2);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('growth_standards');
    }
};

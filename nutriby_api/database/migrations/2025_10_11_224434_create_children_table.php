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
        Schema::create('children', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('name');
            $table->date('birth_date');
            $table->enum('gender', ['male', 'female']);
            $table->decimal('current_weight', 5, 2); // dalam kg
            $table->decimal('current_height', 5, 2); // dalam cm
            $table->unsignedInteger('parent_monthly_income');
            $table->string('nutritional_status_wfa')->nullable(); // Berat/Umur
            $table->string('nutritional_status_hfa')->nullable(); // Tinggi/Umur (Stunting)
            $table->text('nutritional_status_notes')->nullable();
            $table->unsignedInteger('recommended_budget')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('children');
    }
};

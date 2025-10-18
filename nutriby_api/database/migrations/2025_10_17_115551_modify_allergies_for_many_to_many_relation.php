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
        Schema::table('allergies', function (Blueprint $table) {
            // 1. Hapus foreign key constraint terlebih dahulu
            $table->dropForeign(['ingredient_id']);
            // 2. Hapus kolomnya
            $table->dropColumn('ingredient_id');
            // 3. Tambahkan kolom untuk gambar grup alergi (sesuai permintaan #6)
            $table->string('image_url')->nullable()->after('handling_and_prevention');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('many_relation', function (Blueprint $table) {
            //
        });
    }
};

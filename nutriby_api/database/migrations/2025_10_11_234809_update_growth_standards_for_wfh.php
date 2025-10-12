<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('growth_standards', function (Blueprint $table) {
            // 1. Buat kolom 'age_in_months' menjadi nullable
            $table->unsignedTinyInteger('age_in_months')->nullable()->change();

            // 2. Tambahkan kolom baru untuk data WFH
            $table->decimal('reference_height_cm', 5, 2)->nullable()->after('age_in_months');

            // 3. Ubah kolom 'metric' untuk memasukkan 'wfh'
            $table->enum('metric', ['wfa', 'hfa', 'wfh'])->change();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('growth_standards', function (Blueprint $table) {
            // Lakukan kebalikan dari proses 'up'
            $table->enum('metric', ['wfa', 'hfa'])->change();
            $table->dropColumn('reference_height_cm');
            $table->unsignedTinyInteger('age_in_months')->nullable(false)->change();
        });
    }
};
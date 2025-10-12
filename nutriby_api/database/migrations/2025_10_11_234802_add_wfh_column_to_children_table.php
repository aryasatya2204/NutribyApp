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
        // Menggunakan Schema::table() untuk memodifikasi tabel yang sudah ada
        Schema::table('children', function (Blueprint $table) {
            // Menambahkan kolom baru setelah kolom 'nutritional_status_hfa'
            $table->string('nutritional_status_wfh')->nullable()->after('nutritional_status_hfa');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('children', function (Blueprint $table) {
            // Menghapus kolom jika migration di-rollback
            $table->dropColumn('nutritional_status_wfh');
        });
    }
};
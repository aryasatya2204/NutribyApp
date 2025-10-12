<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('children', function (Blueprint $table) {
            $table->dropColumn('recommended_budget'); // Hapus kolom lama
            $table->unsignedInteger('budget_min')->nullable()->after('nutritional_status_notes');
            $table->unsignedInteger('budget_max')->nullable()->after('budget_min');
        });
    }

    public function down()
    {
        Schema::table('children', function (Blueprint $table) {
            $table->unsignedInteger('recommended_budget')->nullable();
            $table->dropColumn(['budget_min', 'budget_max']);
        });
    }
};

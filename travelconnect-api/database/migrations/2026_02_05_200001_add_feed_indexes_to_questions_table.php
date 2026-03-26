<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('questions', function (Blueprint $table) {
            $table->index('city', 'idx_city');
            $table->index(['city', 'created_at'], 'idx_city_created_at');
            $table->index(['answers_count', 'created_at'], 'idx_answers_count_created_at');
        });
    }

    public function down(): void
    {
        Schema::table('questions', function (Blueprint $table) {
            $table->dropIndex('idx_city');
            $table->dropIndex('idx_city_created_at');
            $table->dropIndex('idx_answers_count_created_at');
        });
    }
};

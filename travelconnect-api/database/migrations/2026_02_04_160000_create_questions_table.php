<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('questions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('title', 100);
            $table->text('description')->nullable();
            $table->decimal('latitude', 10, 8);
            $table->decimal('longitude', 11, 8);
            $table->string('location_name')->nullable();
            $table->string('city')->nullable();
            $table->unsignedInteger('answers_count')->default(0);
            $table->boolean('has_unread_answers')->default(false);
            $table->boolean('is_deleted')->default(false);
            $table->timestamps();
        });

        // Add spatial POINT column and spatial index
        DB::statement('ALTER TABLE questions ADD location POINT NOT NULL SRID 4326 AFTER longitude');
        DB::statement('CREATE SPATIAL INDEX idx_location ON questions (location)');
    }

    public function down(): void
    {
        Schema::dropIfExists('questions');
    }
};

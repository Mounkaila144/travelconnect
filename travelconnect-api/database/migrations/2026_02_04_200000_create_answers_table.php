<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('answers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('question_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->text('content');
            $table->decimal('average_rating', 2, 1)->default(0.0);
            $table->unsignedInteger('ratings_count')->default(0);
            $table->boolean('is_deleted')->default(false);
            $table->timestamps();

            $table->index(['question_id', 'is_deleted', 'average_rating']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('answers');
    }
};

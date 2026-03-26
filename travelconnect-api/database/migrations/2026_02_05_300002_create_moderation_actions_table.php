<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('moderation_actions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('admin_id')->constrained('admins')->cascadeOnDelete();
            $table->foreignId('report_id')->constrained('reports')->cascadeOnDelete();
            $table->enum('action', ['approved', 'deleted', 'banned']);
            $table->text('note')->nullable();
            $table->timestamp('created_at');

            $table->index('admin_id');
            $table->index('report_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('moderation_actions');
    }
};

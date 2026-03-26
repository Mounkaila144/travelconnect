<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->decimal('notification_zone_lat', 10, 8)->nullable()->after('notification_settings');
            $table->decimal('notification_zone_lng', 11, 8)->nullable()->after('notification_zone_lat');
            $table->unsignedInteger('notification_zone_radius')->nullable()->after('notification_zone_lng');

            $table->index(['notification_zone_lat', 'notification_zone_lng'], 'idx_notification_zone');
            $table->index(['user_type', 'fcm_token'], 'idx_user_type_fcm');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropIndex('idx_notification_zone');
            $table->dropIndex('idx_user_type_fcm');
            $table->dropColumn(['notification_zone_lat', 'notification_zone_lng', 'notification_zone_radius']);
        });
    }
};

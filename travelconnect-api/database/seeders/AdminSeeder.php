<?php

namespace Database\Seeders;

use App\Models\Admin;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class AdminSeeder extends Seeder
{
    public function run(): void
    {
        Admin::create([
            'email' => env('ADMIN_EMAIL', 'admin@travelconnect.app'),
            'password' => Hash::make(env('ADMIN_PASSWORD', 'ChangeMe123!')),
            'name' => 'Administrateur Principal',
        ]);

        if (app()->environment('local')) {
            Admin::create([
                'email' => 'test@admin.local',
                'password' => Hash::make('password'),
                'name' => 'Test Admin',
            ]);
        }
    }
}

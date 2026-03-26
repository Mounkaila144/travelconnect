<?php

require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

$user = \App\Models\User::first();
if ($user) {
    $token = $user->createToken('test-debug');
    echo "User: {$user->name} (ID: {$user->id})\n";
    echo "Token: {$token->plainTextToken}\n";
} else {
    echo "No users found in database\n";
}

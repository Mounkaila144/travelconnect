<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/privacy', function () {
    return view('privacy');
})->name('privacy');

Route::get('/support', function () {
    return view('support');
})->name('support');

Route::get('/terms', function () {
    return view('terms');
})->name('terms');

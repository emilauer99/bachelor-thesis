<?php

use App\Http\Controllers\UserController;
use Illuminate\Support\Facades\Route;

// public routes
Route::post('login', [UserController::class, 'login']);

// authenticated routes
Route::middleware(['auth:sanctum'])->group(function () {
    Route::post('logout', [UserController::class, 'logout']);
});

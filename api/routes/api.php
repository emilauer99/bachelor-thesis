<?php

use App\Http\Controllers\CustomerController;
use App\Http\Controllers\UserController;
use Illuminate\Support\Facades\Route;

// public routes
Route::post('login', [UserController::class, 'login']);

// authenticated routes
Route::middleware(['auth:sanctum'])->group(function () {
    Route::post('logout', [UserController::class, 'logout']);

    Route::middleware(['role:admin'])->group(function () {
        Route::apiResource('customers', CustomerController::class)->only(['index', 'store']);
    });
});

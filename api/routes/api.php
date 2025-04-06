<?php

use App\Http\Controllers\CustomerController;
use App\Http\Controllers\ProjectController;
use App\Http\Controllers\UserController;
use Illuminate\Support\Facades\Route;

// public routes
Route::post('login', [UserController::class, 'login']);

// authenticated routes
Route::middleware(['auth:sanctum'])->group(function () {
    Route::post('logout', [UserController::class, 'logout']);
    Route::get('/user', [UserController::class, 'show']);

    Route::get('projects', [ProjectController::class, 'index']);
    Route::get('projects/{id}', [ProjectController::class, 'show']);

    Route::middleware(['role:admin'])->group(function () {
        Route::apiResource('customers', CustomerController::class)->only(['index', 'store', 'delete']);
        Route::apiResource('projects', ProjectController::class)->except(['index', 'show']);
    });
});

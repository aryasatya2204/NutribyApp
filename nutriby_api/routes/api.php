<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ChildController;
use App\Http\Controllers\Api\RecipeController;   
use App\Http\Controllers\Api\AllergyController;
use App\Http\Controllers\Api\WeeklyPlanController;
use App\Http\Controllers\Api\IngredientController;

// Public routes for authentication
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Protected routes (requires authentication)
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);

    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    // --- Rute untuk Manajemen Data Anak ---
    Route::post('/children', [ChildController::class, 'store']); // Membuat data anak baru
    Route::get('/children', [ChildController::class, 'index']); // Mendapatkan daftar anak user
    Route::get('/children/{child}', [ChildController::class, 'show']); // Mendapatkan detail satu anak
    Route::put('/children/{child}', [ChildController::class, 'update']); // Memperbarui data anak

    Route::patch('/children/{child}', [ChildController::class, 'update']);
    
    Route::get('/recipes/search', [RecipeController::class, 'search']);
    Route::get('/recipes', [RecipeController::class, 'index']);
    Route::get('/recipes/{recipe}', [RecipeController::class, 'show']);
    Route::get('/ingredients', [IngredientController::class, 'index']);
    Route::get('/allergies/search', [AllergyController::class, 'search']);
    Route::get('/allergies', [AllergyController::class, 'index']);
    Route::get('/allergies/{allergy}', [AllergyController::class, 'show']);
    Route::get('/ingredients', [IngredientController::class, 'index']);

    Route::post('/children/{child}/weekly-plan/generate', [WeeklyPlanController::class, 'generate']);
});

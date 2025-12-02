<?php

/**
 * @file api.php
 * @description API route definitions for the NutriBy application.
 * Defines public and authenticated API endpoints.
 */

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ChildController;
use App\Http\Controllers\Api\RecipeController;
use App\Http\Controllers\Api\AllergyController;
use App\Http\Controllers\Api\WeeklyPlanController;
use App\Http\Controllers\Api\IngredientController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

// =========================================================================
// Public Routes (Tidak memerlukan login)
// =========================================================================

/**
 * @route POST /api/register
 * @description Registers a new user account.
 * @controller AuthController@register
 */
Route::post('/register', [AuthController::class, 'register']);

/**
 * @route POST /api/login
 * @description Authenticates a user and returns an API token.
 * @controller AuthController@login
 */
Route::post('/login', [AuthController::class, 'login']);


// =========================================================================
// Protected Routes (Memerlukan autentikasi via Sanctum Bearer Token)
// =========================================================================
Route::middleware('auth:sanctum')->group(function () {

    // --- Authentication ---

    /**
     * @route POST /api/logout
     * @description Logs out the current user by revoking the current token.
     * @controller AuthController@logout
     */
    Route::post('/logout', [AuthController::class, 'logout']);

    /**
     * @route GET /api/user
     * @description Retrieves the authenticated user's details.
     */
    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    // --- Child Management ---

    /**
     * @route GET /api/children
     * @description Get a list of the authenticated user's children.
     * @controller ChildController@index
     */
    Route::get('/children', [ChildController::class, 'index']);

    /**
     * @route POST /api/children
     * @description Store a new child record for the authenticated user.
     * @controller ChildController@store
     */
    Route::post('/children', [ChildController::class, 'store']);

    /**
     * @route GET /api/children/{child}
     * @description Show details of a specific child owned by the user.
     * @controller ChildController@show
     */
    Route::get('/children/{child}', [ChildController::class, 'show'])->where('child', '[0-9]+'); // Pastikan {child} adalah angka

    /**
     * @route PUT /api/children/{child}
     * @description Update core data (measurements, income) and preferences (allergies, favorites) of a child.
     * @controller ChildController@update
     */
    Route::put('/children/{child}', [ChildController::class, 'update'])->where('child', '[0-9]+');

    /**
     * @route PATCH /api/children/{child}
     * @description Alias for PUT, updates core data and preferences of a child.
     * @controller ChildController@update
     * @note PUT/PATCH seringkali digunakan secara bergantian untuk update resource.
     */
    Route::patch('/children/{child}', [ChildController::class, 'update'])->where('child', '[0-9]+');


    // --- Recipes ---

    /**
     * @route GET /api/recipes
     * @description Get a paginated list of all recipes.
     * @controller RecipeController@index
     */
    Route::get('/recipes', [RecipeController::class, 'index']);

    /**
     * @route GET /api/recipes/search
     * @description Search recipes by title or ingredient name (keyword-based).
     * @controller RecipeController@search
     */
    Route::get('/recipes/search', [RecipeController::class, 'search']);

    /**
     * @route GET /api/recipes/filter
     * @description Filter recipes based on criteria like main ingredient, max cost, allergies, etc.
     * @controller RecipeController@filter
     * @important Ini adalah endpoint baru untuk fitur pencarian harian.
     */
    Route::get('/recipes/filter', [RecipeController::class, 'filter']);

    /**
     * @route GET /api/recipes/{recipe}
     * @description Show details of a specific recipe.
     * @controller RecipeController@show
     */
    Route::get('/recipes/{recipe}', [RecipeController::class, 'show'])->where('recipe', '[0-9]+'); // Pastikan {recipe} adalah angka


    // --- Supporting Data (Ingredients, Allergies) ---

    /**
     * @route GET /api/ingredients
     * @description Get a list of all ingredients (used for selections).
     * @controller IngredientController@index
     */
    Route::get('/ingredients', [IngredientController::class, 'index']);

    /**
     * @route GET /api/allergies
     * @description Get a list of all allergy facts.
     * @controller AllergyController@index
     */
    Route::get('/allergies', [AllergyController::class, 'index']);

    /**
     * @route GET /api/allergies/search
     * @description Search allergy facts by name, symptom, or related ingredient.
     * @controller AllergyController@search
     */
    Route::get('/allergies/search', [AllergyController::class, 'search']);

    /**
     * @route GET /api/allergies/{allergy}
     * @description Show details of a specific allergy fact.
     * @controller AllergyController@show
     */
    Route::get('/allergies/{allergy}', [AllergyController::class, 'show'])->where('allergy', '[0-9]+'); // Pastikan {allergy} adalah angka


    // --- Core Features ---

    /**
     * @route GET /api/children/{child}/weekly-plan/active
     * @description Get the active weekly plan for a specific child.
     * @controller WeeklyPlanController@getActive
     */
    Route::get('/children/{child}/weekly-plan/active', [WeeklyPlanController::class, 'getActive'])->where('child', '[0-9]+');

    /**
     * @route POST /api/children/{child}/weekly-plan/generate
     * @description Generate a new weekly meal plan for a specific child.
     * @controller WeeklyPlanController@generate
     */
    Route::post('/children/{child}/weekly-plan/generate', [WeeklyPlanController::class, 'generate'])->where('child', '[0-9]+');

    /**
     * @route POST /api/children/{child}/weekly-plan/generate
     * @description Generate a new weekly meal plan for a specific child.
     * @controller WeeklyPlanController@generate
     */
    Route::post('/children/{child}/weekly-plan/generate', [WeeklyPlanController::class, 'generate'])->where('child', '[0-9]+');
}); // End of auth:sanctum group
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Recipe;
use Illuminate\Http\Request;

class RecipeController extends Controller
{
    /**
     * Display a paginated listing of the recipes.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function index()
    {
        // Mengambil resep dengan paginasi (10 per halaman) untuk efisiensi
        // 'with('ingredients')' adalah Eager Loading untuk performa.
        // Ini mengambil resep sekaligus bahan-bahannya dalam 2 query, bukan N+1 query.
        $recipes = Recipe::with('ingredients')->paginate(10);
        
        return response()->json($recipes);
    }

    /**
     * Display the specified recipe including its ingredients.
     *
     * @param  \App\Models\Recipe  $recipe
     * @return \Illuminate\Http\JsonResponse
     */
    public function show(Recipe $recipe)
    {
        // Laravel's Route Model Binding secara otomatis menemukan resep berdasarkan ID.
        // Kita hanya perlu me-load relasi ingredients-nya.
        return response()->json($recipe->load('ingredients'));
    }
}
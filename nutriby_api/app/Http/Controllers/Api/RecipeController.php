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
    
    /**
     * Search for recipes based on a query string.
     * The search is performed on both the recipe title and its ingredients.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
     public function search(Request $request)
    {
        // 1. Validasi input: pastikan ada query pencarian 'q'
        $request->validate([
            'q' => 'required|string|min:3',
        ]);

        $query = $request->input('q');

        // 2. Lakukan query pencarian gabungan
        $recipes = Recipe::query()
            // Kriteria 1: Cari resep yang judulnya (title) mengandung kata kunci
            ->where('title', 'LIKE', "%{$query}%")
            
            // Kriteria 2: ATAU cari resep yang memiliki bahan (ingredients) dengan nama yang mengandung kata kunci
            ->orWhereHas('ingredients', function ($ingredientQuery) use ($query) {
                $ingredientQuery->where('name', 'LIKE', "%{$query}%");
            })
            
            // Eager load bahan-bahannya untuk ditampilkan di hasil pencarian
            ->with('ingredients')
            
            // Batasi hasil dan berikan paginasi
            ->paginate(10);

        // 3. Kembalikan hasil dalam format JSON
        return response()->json($recipes);
    }
}
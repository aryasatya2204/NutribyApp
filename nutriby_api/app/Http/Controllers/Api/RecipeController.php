<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Recipe;
use Illuminate\Http\Request;
use Illuminate\Database\Eloquent\Builder; 

class RecipeController extends Controller
{
    /**
     * Display a paginated listing of the recipes.
     * Eager loads ingredients for efficiency.
     *
     * @param \Illuminate\Http\Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function index(Request $request)
    {
        $recipes = Recipe::with('ingredients')->paginate(10); 
        return response()->json($recipes);
    }

    /**
     * Display the specified recipe including its ingredients.
     * Uses Route Model Binding.
     *
     * @param  \App\Models\Recipe  $recipe
     * @return \Illuminate\Http\JsonResponse
     */
    public function show(Recipe $recipe)
    {
        return response()->json($recipe->load('ingredients'));
    }

    /**
     * Search for recipes based on a query string (keyword).
     * Searches in recipe title and ingredient names. Returns paginated results.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
     public function search(Request $request)
    {
        // Validasi: Membutuhkan parameter 'q' dengan minimal 3 karakter
        $request->validate([
            'q' => 'required|string|min:3',
        ]);

        $query = $request->input('q');

        $recipes = Recipe::query()
            ->where('title', 'LIKE', "%{$query}%") 
            ->orWhereHas('ingredients', function (Builder $ingredientQuery) use ($query) {
                $ingredientQuery->where('name', 'LIKE', "%{$query}%"); 
            })
            ->with('ingredients') 
            ->paginate(10); 

        return response()->json($recipes);
    }


    /**
     * Filter recipes based on multiple criteria provided as query parameters.
     * Supports filtering by main ingredient, maximum cost per serving, and allergies.
     * Returns simple paginated results suitable for infinite scrolling.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     *
     * @queryParam main_ingredient_id integer optional The ID of the main ingredient to include. Example: 5
     * @queryParam max_cost integer optional The maximum estimated cost per serving. Example: 15000
     * @queryParam allergy_ids array optional An array of ingredient IDs to exclude. Example: [1, 4]
     * @queryParam age_months integer optional The child's age in months for age filtering. Example: 12
     */
    public function filter(Request $request)
    {
        // 1. Validasi Input (opsional tapi sangat direkomendasikan)
        $validated = $request->validate([
            'main_ingredient_id' => 'nullable|integer|exists:ingredients,id',
            'max_cost' => 'nullable|integer|min:0',
            'allergy_ids' => 'nullable|array',
            'allergy_ids.*' => 'integer|exists:ingredients,id',
            'age_months' => 'nullable|integer|min:6|max:24', // Contoh validasi usia
        ]);

        // 2. Memulai Query Builder
        $query = Recipe::query()->with('ingredients'); // Selalu eager load ingredients

        // 3. Menerapkan Filter secara Kondisional

        // Filter: Hanya resep yang mengandung 'main_ingredient_id'
        if ($request->filled('main_ingredient_id')) {
            $query->whereHas('ingredients', function (Builder $ingredientQuery) use ($request) {
                $ingredientQuery->where('ingredients.id', $request->input('main_ingredient_id'));
            });
        }

        // Filter: Hanya resep dengan biaya <= 'max_cost'
        if ($request->filled('max_cost')) {
            $query->where('estimated_cost', '<=', $request->input('max_cost'));
        }

        // Filter: Kecualikan resep yang mengandung bahan dari 'allergy_ids'
        if ($request->filled('allergy_ids') && is_array($request->input('allergy_ids'))) {
             // Pastikan allergy_ids adalah array sebelum digunakan
             $allergyIds = $request->input('allergy_ids');
             // Hanya terapkan filter jika array tidak kosong
             if (!empty($allergyIds)) {
                $query->whereDoesntHave('ingredients', function (Builder $ingredientQuery) use ($allergyIds) {
                    $ingredientQuery->whereIn('ingredients.id', $allergyIds);
                });
             }
        }


        // Filter: Hanya resep yang sesuai dengan 'age_months' (jika ada)
        if ($request->filled('age_months')) {
            $age = $request->input('age_months');
            $query->where('min_age_months', '<=', $age)
                  ->where(function (Builder $q) use ($age) {
                      $q->whereNull('max_age_months')
                        ->orWhere('max_age_months', '>=', $age);
                  });
        }

        // 4. Eksekusi Query dengan Simple Pagination
        // simplePaginate lebih efisien untuk kasus "load more" / infinite scroll
        $recipes = $query->orderBy('title') // Urutkan berdasarkan judul
                         ->simplePaginate(15); // Ambil 15 resep per halaman

        // 5. Kembalikan Hasil
        return response()->json($recipes);
    }
}
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Ingredient;
use Illuminate\Http\Request;

class IngredientController extends Controller
{
    /**
     * Display a listing of the ingredients with optional filtering.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function index(Request $request)
{
    $query = Ingredient::query();

    // ✅ Filter by category
    if ($request->filled('category')) {
        $query->where('category', $request->input('category'));
    }

    // ✅ Filter ingredient yang clean (exclude yang ada takaran)
    if ($request->filled('clean') && $request->input('clean') === 'true') {
        $query->where(function($q) {
            $q->where('name', 'NOT LIKE', '%Sdm%')
              ->where('name', 'NOT LIKE', '%Sdt%')
              ->where('name', 'NOT LIKE', '%Gr%')
              ->where('name', 'NOT LIKE', '%Ml%')
              ->where('name', 'NOT LIKE', '%Cm%')
              ->where('name', 'NOT LIKE', '%/%')
              ->where('name', 'NOT LIKE', '%Secukupnya%')
              ->where('name', 'NOT LIKE', '%Potong%')
              ->where('name', 'NOT LIKE', '%Iris%')
              ->where('name', 'NOT LIKE', '%Cincang%')
              ->where('name', 'NOT LIKE', '%Parut%')
              ->where('name', 'NOT LIKE', '%Kupas%')
              ->where('name', 'NOT LIKE', '%Rebus%')
              ->where('name', 'NOT LIKE', '%Kukus%')
              ->where('name', 'NOT LIKE', '%Halus%')
              ->where('name', 'NOT LIKE', '%Dadu%')
              ->where('name', 'NOT LIKE', '%--%')
              ->where('name', 'NOT LIKE', '%Ekor%')
              ->where('name', 'NOT LIKE', '%Kuntum%')
              ->where('name', 'NOT LIKE', '%Genggam%')
              ->where('name', 'NOT LIKE', '%Jari%')
              ->where('name', 'NOT LIKE', '%Kecil%')
              ->where('name', 'NOT LIKE', '%Besar%')
              ->where('name', 'NOT LIKE', '%Sedang%');
        });
    }

    $ingredients = $query->orderBy('name', 'asc')->get();
    return response()->json($ingredients);
}
}
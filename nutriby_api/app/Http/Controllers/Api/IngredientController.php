<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Ingredient;
use Illuminate\Http\Request;

class IngredientController extends Controller
{
    /**
     * Display a listing of all ingredients.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function index()
    {
        // Mengambil semua bahan, hanya kolom id dan nama untuk efisiensi.
        $ingredients = Ingredient::query()->select('id', 'name')->get();
        return response()->json($ingredients);
    }
}
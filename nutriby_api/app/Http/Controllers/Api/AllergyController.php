<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Allergy;
use Illuminate\Http\Request;

class AllergyController extends Controller
{
    /**
     * Display a listing of the allergies.
     */
    public function index()
    {
        $allergies = Allergy::with('ingredients')->get();
        return response()->json($allergies);
    }

    /**
     * Display the specified allergy.
     */
    public function show(Allergy $allergy)
    {
        return response()->json($allergy->load('ingredients'));
    }

    /**
     * Search for allergies based on ingredient name, allergy name, or symptoms.
     */
    public function search(Request $request)
    {
        $request->validate(['q' => 'required|string|min:2']);
        $query = $request->input('q');

        $allergies = Allergy::with('ingredients') // Ganti ke relasi baru 'ingredients'
            ->where(function ($mainQuery) use ($query) {
                // Grup 1: Cari di kolom 'name' ATAU 'symptoms' pada tabel allergies
                $mainQuery->where('name', 'LIKE', "%{$query}%")
                    ->orWhere('symptoms', 'LIKE', "%{$query}%");
            })
            // ATAU Grup 2: Cari di relasi ingredients yang nama bahannya cocok
            ->orWhereHas('ingredients', function ($ingredientQuery) use ($query) {
                $ingredientQuery->where('name', 'LIKE', "%{$query}%");
            })
            ->get();

        return response()->json($allergies);
    }
}

<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Allergy;
use Illuminate\Http\Request;

class AllergyController extends Controller
{
    /**
     * Display a listing of the allergies.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function index()
    {
        // Mengambil semua data alergi.
        // Kita juga melakukan Eager Loading pada 'ingredient' untuk menampilkan info bahan terkait.
        $allergies = Allergy::with('ingredient')->get();
        
        return response()->json($allergies);
    }

    /**
     * Display the specified allergy.
     *
     * @param  \App\Models\Allergy  $allergy
     * @return \Illuminate\Http\JsonResponse
     */
    public function show(Allergy $allergy)
    {
        // Mengembalikan detail satu alergi, termasuk info bahan terkait.
        return response()->json($allergy->load('ingredient'));
    }
}
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Child;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use App\Services\NutritionalStatusService;
use App\Services\BudgetRecommendationService;
use Illuminate\Support\Facades\DB;

class ChildController extends Controller
{
    // Dependency injection for our services
    protected $nutritionalStatusService;
    protected $budgetRecommendationService;

    public function __construct(NutritionalStatusService $nutritionalStatusService, BudgetRecommendationService $budgetRecommendationService)
    {
        $this->nutritionalStatusService = $nutritionalStatusService;
        $this->budgetRecommendationService = $budgetRecommendationService;
    }

    /**
     * Display a listing of the authenticated user's children.
     */
    public function index(Request $request)
    {
        $children = $request->user()->children()->with(['allergies', 'favoriteIngredients', 'growthHistories'])->get();
        return response()->json($children);
    }

    /**
     * Store a newly created child in storage.
     */
    public function update(Request $request, Child $child)
    {
        // Validasi ownership
        if ($child->user_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Unauthorized'
            ], 403);
        }

        // Validasi input
        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'birth_date' => 'sometimes|date',
            'gender' => 'sometimes|in:male,female',
            'current_weight' => 'sometimes|numeric|min:0',
            'current_height' => 'sometimes|numeric|min:0',
            'parent_monthly_income' => 'sometimes|integer|min:0',
            
            // ✅ FIXED: Sekarang pakai allergy_ids (array of allergy IDs)
            'allergy_ids' => 'sometimes|array',
            'allergy_ids.*' => 'integer|exists:allergies,id',
            
            // ✅ TETAP: Favorite tetap pakai ingredient_ids
            'favorite_ids' => 'sometimes|array',
            'favorite_ids.*' => 'integer|exists:ingredients,id',
        ]);

        // Update core data
        $child->update($validated);

        // ✅ FIXED: Sync allergies (grup alergi)
        if ($request->has('allergy_ids')) {
            $child->allergies()->sync($request->allergy_ids);
        }

        // ✅ TETAP: Sync favorite ingredients
        if ($request->has('favorite_ids')) {
            $child->favoriteIngredients()->sync($request->favorite_ids);
        }

        // Load relasi untuk response
        $child->load(['allergies.ingredients', 'favoriteIngredients']);

        return response()->json([
            'message' => 'Child updated successfully',
            'child' => $child
        ]);
    }

    /**
     * Store a new child
     * 
     * ✅ FIXED: Sekarang menerima allergy_ids
     */
   public function store(Request $request)
{
    $validated = $request->validate([
        'name' => 'required|string|max:255',
        'birth_date' => 'required|date',
        'gender' => 'required|in:male,female',
        'current_weight' => 'required|numeric|min:0',
        'current_height' => 'required|numeric|min:0',
        'parent_monthly_income' => 'required|min:0', // ✅ FIX: Hapus type 'integer'
        
        'allergy_ids' => 'sometimes|array',
        'allergy_ids.*' => 'integer|exists:allergies,id',
        
        'favorite_ids' => 'sometimes|array',
        'favorite_ids.*' => 'integer|exists:ingredients,id',
    ]);

    // ✅ FIX: Clean dan cast parent_monthly_income ke integer
    $cleanedData = [
        'name' => $validated['name'],
        'birth_date' => $validated['birth_date'],
        'gender' => $validated['gender'],
        'current_weight' => (float) $validated['current_weight'],
        'current_height' => (float) $validated['current_height'],
        'parent_monthly_income' => (int) filter_var(
            $validated['parent_monthly_income'], 
            FILTER_SANITIZE_NUMBER_INT
        ),
    ];

    // Create child dengan data yang sudah bersih
    $child = $request->user()->children()->create($cleanedData);

    // Attach allergies
    if ($request->has('allergy_ids')) {
        $child->allergies()->attach($request->allergy_ids);
    }

    // Attach favorites
    if ($request->has('favorite_ids')) {
        $child->favoriteIngredients()->attach($request->favorite_ids);
    }

    // Process nutritional status & budget
    $this->processChildData($child);

    // Load relasi
    $child->load(['allergies.ingredients', 'favoriteIngredients', 'growthHistories']);

    return response()->json($child, 201);
}

    /**
     * Show child details
     * 
     * ✅ UPDATED: Load allergies dengan ingredients-nya
     */
    public function show(Child $child)
    {
        // Validasi ownership
        if ($child->user_id !== Auth::id()) {
            return response()->json([
                'message' => 'Unauthorized'
            ], 403);
        }

        // Load semua relasi yang dibutuhkan
        $child->load([
            'allergies.ingredients', // Load grup alergi + bahan pemicu
            'favoriteIngredients',
            'growthHistories'
        ]);

        return response()->json($child);
    }

    /**
     * A private helper method to run our services and update the child model.
     * This avoids code duplication between store() and update().
     */
    private function processChildData(Child $child)
    {
        // Step A: Calculate nutritional status
        $statusResult = $this->nutritionalStatusService->calculate($child);
        $child->nutritional_status_hfa = $statusResult['status_hfa'];
        $child->nutritional_status_wfa = $statusResult['status_wfa'];
        $child->nutritional_status_wfh = $statusResult['status_wfh'];
        $child->nutritional_status_notes = $statusResult['notes'];

        // Step B: Recommend budget based on the new status
        $budgetRange = $this->budgetRecommendationService->recommend($child);
        $child->budget_min = $budgetRange['min'];
        $child->budget_max = $budgetRange['max'];

        // Step C: Save all the processed data to the database
        $child->save();

        // Step D: Record this moment in the child's growth history
        $child->growthHistories()->create([
            'record_date' => now(),
            'weight' => $child->current_weight,
            'height' => $child->current_height,
            'nutritional_status_hfa' => $child->nutritional_status_hfa,
            'z_score_wfa' => $statusResult['z_score_wfa_value'] ?? null,
            'z_score_hfa' => $statusResult['z_score_hfa_value'] ?? null,
            'z_score_wfh' => $statusResult['z_score_wfh_value'] ?? null,
            'recommended_budget_at_the_time' => $child->budget_max,
        ]);
    }
}

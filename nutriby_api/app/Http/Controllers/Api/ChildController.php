<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Child;
use Illuminate\Http\Request;
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
        $children = $request->user()->children;
        return response()->json($children);
    }

    /**
     * Store a newly created child in storage.
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'birth_date' => 'required|date',
            'gender' => 'required|in:male,female',
            'current_weight' => 'required|numeric|min:1',
            'current_height' => 'required|numeric|min:20',
            'parent_monthly_income' => 'required|integer|min:0',

            // Validasi untuk input alergi dan kesukaan
            'allergy_ids' => 'sometimes|array',
            'allergy_ids.*' => 'integer|exists:ingredients,id',
            'favorite_ids' => 'sometimes|array',
            'favorite_ids.*' => 'integer|exists:ingredients,id',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        // Gunakan DB Transaction untuk memastikan semua data berhasil disimpan
        $child = DB::transaction(function () use ($request) {
            // 1. Buat data anak seperti biasa
            $child = $request->user()->children()->create($request->except(['allergy_ids', 'favorite_ids']));

            // 2. Simpan relasi alergi jika ada
            if ($request->has('allergy_ids')) {
                $child->allergies()->attach($request->allergy_ids);
            }

            // 3. Simpan relasi makanan kesukaan jika ada
            if ($request->has('favorite_ids')) {
                $child->favoriteIngredients()->attach($request->favorite_ids);
            }

            return $child;
        });

        // 4. Jalankan engine cerdas kita setelah semuanya tersimpan
        $this->processChildData($child);

        // Muat ulang relasi agar tampil di response
        $child->load(['allergies', 'favoriteIngredients']);

        return response()->json($child, 201);
    }

    /**
     * Display the specified child.
     */
    public function show(Request $request, Child $child)
    {
        // Authorization: ensure the user can only see their own child's data.
        if ($request->user()->id !== $child->user_id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }
        return response()->json($child);
    }

    /**
     * Update the specified child in storage.
     */
    public function update(Request $request, Child $child)
    {
        // Authorization check
        if ($request->user()->id !== $child->user_id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $validator = Validator::make($request->all(), [
            // User cannot edit name and birth date for data integrity.
            'current_weight' => 'required|numeric|min:1',
            'current_height' => 'required|numeric|min:20',
            'parent_monthly_income' => 'required|integer|min:0',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        // 1. Update the child's core data.
        $child->update($validator->validated());

        // 2. Re-run our intelligent engines with the new data.
        $this->processChildData($child);

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
            'recommended_budget_at_the_time' => $child->budget_max,
        ]);
    }
}

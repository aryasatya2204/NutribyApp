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
        $children = $request->user()->children()->with(['allergies', 'favoriteIngredients'])->get();
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
        // 1. Otorisasi: Pastikan user hanya bisa update data anaknya sendiri
        if ($request->user()->id !== $child->user_id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        // 2. Validasi Fleksibel: Gunakan 'sometimes' agar field tidak wajib ada semua
        $validator = Validator::make($request->all(), [
            // Validasi data inti (jika dikirim)
            'current_weight' => 'sometimes|required|numeric|min:1',
            'current_height' => 'sometimes|required|numeric|min:20',
            'parent_monthly_income' => 'sometimes|required|integer|min:0',

            // Validasi data preferensi (jika dikirim)
            'allergy_ids' => 'sometimes|array',
            'allergy_ids.*' => 'integer|exists:ingredients,id',
            'favorite_ids' => 'sometimes|array',
            'favorite_ids.*' => 'integer|exists:ingredients,id',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        // Gunakan transaction untuk keamanan data
        DB::transaction(function () use ($request, $child) {
            // 3. Update Data Inti (jika ada dalam request)
            if ($request->has(['current_weight', 'current_height', 'parent_monthly_income'])) {
                $child->update($request->only(['current_weight', 'current_height', 'parent_monthly_income']));
                // Jalankan ulang service cerdas jika data inti berubah
                $this->processChildData($child);
            }

            // 4. Update Alergi (jika ada dalam request)
            if ($request->has('allergy_ids')) {
                // 'sync' akan menghapus yang lama dan menambah yang baru. Sempurna untuk update.
                $child->allergies()->sync($request->allergy_ids);
            }

            // 5. Update Makanan Kesukaan (jika ada dalam request)
            if ($request->has('favorite_ids')) {
                $child->favoriteIngredients()->sync($request->favorite_ids);
            }
        });

        // 6. Kembalikan data anak yang sudah ter-update, termasuk relasi terbarunya
        return response()->json($child->load(['allergies', 'favoriteIngredients']));
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

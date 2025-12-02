<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Child;
use App\Services\WeeklyPlanService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class WeeklyPlanController extends Controller
{
    protected $weeklyPlanService;

    public function __construct(WeeklyPlanService $weeklyPlanService)
    {
        $this->weeklyPlanService = $weeklyPlanService;
    }

    /**
     * Get the active weekly plan for a child.
     * 
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\Child  $child
     * @return \Illuminate\Http\JsonResponse
     */
    public function getActive(Request $request, Child $child)
    {
        // 1. Authorization: Ensure the logged-in user owns this child record.
        if ($request->user()->id !== $child->user_id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        // 2. Find the most recent active weekly plan
        $activePlan = $child->weeklyPlans()
            ->where('is_active', true)
            ->where('end_date', '>=', now()->toDateString()) // Plan masih berlaku
            ->latest('created_at')
            ->first();

        // 3. If no active plan found, return 404
        if (!$activePlan) {
            return response()->json(['message' => 'No active weekly plan found'], 404);
        }

        // 4. Return the active plan with all details and ingredients
        return response()->json($activePlan->load('details.recipe.ingredients'), 200);
    }

    /**
     * Generate and store a new weekly plan for a child.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\Child  $child
     * @return \Illuminate\Http\JsonResponse
     */
    public function generate(Request $request, Child $child)
    {
        // 1. Authorization: Ensure the logged-in user owns this child record.
        if ($request->user()->id !== $child->user_id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        // 2. Validation (optional): Allow user to send an adjusted budget.
        $validated = $request->validate([
            'budget' => 'sometimes|integer|min:0',
        ]);

        try {
            // 3. Call the Engine: Let the service do the heavy lifting of selecting recipes.
            $recipes = $this->weeklyPlanService->generateForChild($child, $validated);

            if ($recipes->count() < 21) {
                return response()->json(['message' => 'Tidak cukup resep yang sesuai untuk membuat rencana satu minggu penuh.'], 422);
            }

            // 4. Store the Plan: Use a database transaction for data integrity.
            $plan = DB::transaction(function () use ($child, $recipes) {
                // ✅ TAMBAHAN: Nonaktifkan semua plan lama
                $child->weeklyPlans()->update(['is_active' => false]);
                
                $recipes = $recipes->values(); 
                
                $weeklyPlan = $child->weeklyPlans()->create([
                    'name' => 'Rencana Minggu ' . now()->weekOfYear . ', ' . now()->year,
                    'start_date' => now()->startOfWeek(),
                    'end_date' => now()->endOfWeek(),
                    'is_active' => true, // ✅ Set plan baru sebagai aktif
                ]);

                $recipeIndex = 0;
                
                for ($day = 1; $day <= 7; $day++) {
                    foreach (['pagi', 'siang', 'sore'] as $meal) {
                        if (isset($recipes[$recipeIndex])) {
                            $recipe = $recipes[$recipeIndex];
                            
                            $weeklyPlan->details()->create([
                                'recipe_id' => $recipe->id,
                                'day_of_week' => $day,
                                'meal_type' => $meal,
                            ]);
                            
                            $recipeIndex++;
                        }
                    }
                }
                
                return $weeklyPlan;
            });

            // 5. Return the Result: Send the newly created plan back to the app.
            return response()->json($plan->load('details.recipe.ingredients'), 201);

        } catch (\Exception $e) {
            Log::error('Failed to generate weekly plan: ' . $e->getMessage());
            return response()->json(['message' => 'Terjadi kesalahan pada server saat membuat rencana.'], 500);
        }
    }
}
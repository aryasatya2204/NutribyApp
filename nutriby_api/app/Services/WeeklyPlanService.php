<?php

namespace App\Services;

use App\Models\Child;
use App\Models\Recipe;
use Illuminate\Support\Collection;

/**
 * Service class for generating a dynamic 7-day MPASI weekly plan.
 *
 * This engine filters and prioritizes recipes based on a child's specific
 * nutritional needs, allergies, preferences, and the parent's budget.
 */
class WeeklyPlanService
{
    private const MEALS_PER_WEEK = 21;

    /**
     * The main method to generate a weekly plan for a specific child.
     *
     * @param Child $child The child for whom the plan is generated.
     * @param array $options Optional adjustments (e.g., 'budget').
     * @return Collection A collection of 21 selected Recipe models.
     */
    public function generateForChild(Child $child, array $options = []): Collection
    {
        // 1. Determine Parameters
        $ageInMonths = $child->birth_date->diffInMonths(now());

        // ✅ FIX: Ambil allergy ingredient IDs dengan benar
        $allergyIngredientIds = $child->getAllergenIngredientIds();

        // ✅ FIX: Deklarasi variabel favoriteIngredientIds yang hilang
        $favoriteIngredientIds = $child->favoriteIngredients()->pluck('ingredients.id');
        $favoriteIngredientIdsArray = $favoriteIngredientIds->toArray();

        $nutritionalStatus = $child->nutritional_status_hfa ?? '';

        // ✅ FIX: Gunakan budgetMax jika tidak ada recommended_budget
        $monthlyBudget = $options['budget'] ?? $child->budget_max ?? 0;
        $dailyBudget = $monthlyBudget > 0 ? $monthlyBudget / 4.2 / 7 : 999999;

        // 2. Build the Base Query (Filtering)
        $eligibleRecipes = Recipe::query()
            // Rule: Must be appropriate for the child's age.
            ->where('min_age_months', '<=', $ageInMonths)
            ->where(function ($query) use ($ageInMonths) {
                $query->whereNull('max_age_months')
                    ->orWhere('max_age_months', '>=', $ageInMonths);
            })

            // Rule: Must be within the daily budget.
            ->where('estimated_cost', '<=', $dailyBudget)

            // Rule: Must NOT contain any ingredients the child is allergic to.
            ->whereDoesntHave('ingredients', function ($query) use ($allergyIngredientIds) {
                if (!empty($allergyIngredientIds)) {
                    $query->whereIn('ingredients.id', $allergyIngredientIds);
                }
            })
            ->with('ingredients') // Eager load ingredients for scoring
            ->get();

        // Handle case where not enough recipes are found
        if ($eligibleRecipes->count() < self::MEALS_PER_WEEK) {
            return $eligibleRecipes->shuffle()->take(self::MEALS_PER_WEEK);
        }

        // 3. Score Each Recipe (Prioritization)
        $scoredRecipes = $eligibleRecipes->map(function ($recipe) use ($nutritionalStatus, $favoriteIngredientIdsArray) {
            $score = 0;

            // Priority: Boost recipes containing favorite ingredients.
            $favoriteCount = $recipe->ingredients->whereIn('id', $favoriteIngredientIdsArray)->count();
            $score += $favoriteCount * 5;

            // Priority: If stunting, boost recipes with high protein.
            if (str_contains($nutritionalStatus, 'Stunting')) {
                if ($recipe->nutrition_focus === 'height_booster') {
                    $score += 25;
                } elseif ($recipe->zinc_total_mg >= 2) {
                    $score += 20;
                } elseif ($recipe->protein_grams > 10) {
                    $score += 10;
                }
            }

            // Priority: If underweight, boost high-calorie recipes.
            if (str_contains($nutritionalStatus, 'Kurang') || str_contains($nutritionalStatus, 'Buruk')) {
                if ($recipe->nutrition_focus === 'weight_booster') {
                    $score += 25;
                } elseif ($recipe->calories > 150) {
                    $score += 12;
                }
            }

            $recipe->score = $score;
            return $recipe;
        });

        // 4. Select the Final 21 Recipes
        return $scoredRecipes->sortByDesc('score')
            ->take(40)
            ->shuffle()
            ->take(self::MEALS_PER_WEEK)
            ->values();
    }
}

<?php

namespace App\Services;

use App\Models\Child;
use App\Models\Recipe;
use Illuminate\Support\Collection;

/**
 * Advanced Budget Recommendation Service (Bottom-Up Approach).
 *
 * This engine analyzes the child's specific needs and the available recipes
 * to calculate an "ideal" nutritional budget, then adjusts it to be realistic
 * based on the parent's income, providing a final recommended range.
 */
class BudgetRecommendationService
{
    // --- Configuration Constants (easy to tweak business logic here) ---

    /** @var int The number of "best-fit" recipes to analyze for cost calculation. */
    private const IDEAL_RECIPE_POOL_SIZE = 30;

    /** @var float The minimum percentage of income considered for the budget floor. */
    private const MIN_INCOME_PERCENTAGE = 0.15; // 15%

    /** @var float The maximum percentage of income considered for the budget ceiling. */
    private const MAX_INCOME_PERCENTAGE = 0.30; // 30%

    /** @var array A fallback budget range if calculation is not possible. */
    private const DEFAULT_RANGE = ['min' => 250000, 'max' => 400000];

    /**
     * Recommend a monthly MPASI budget range for a specific child.
     * The output is now an array with 'min' and 'max' keys.
     *
     * @param Child $child
     * @return array
     */
    public function recommend(Child $child): array
    {
        // 1. Find the most nutritionally ideal recipes for this specific child.
        $idealRecipes = $this->getIdealRecipes($child);

        // Edge Case: If we don't have enough data, return a sensible default.
        if ($idealRecipes->count() < 10) {
            return self::DEFAULT_RANGE;
        }

        // 2. Calculate the "ideal" cost range based on these best-fit recipes.
        $idealCostRange = $this->calculateCostRange($idealRecipes);

        // 3. Perform a "reality check" and adjust the ideal range to the parent's income.
        $finalRange = $this->adjustRangeToIncome($idealCostRange, $child->parent_monthly_income);

        return $finalRange;
    }

    /**
     * Filters and scores all recipes to find the most suitable ones for the child.
     *
     * @param Child $child
     * @return Collection
     */
    private function getIdealRecipes(Child $child): Collection
    {
        $allergyIngredientIds = $child->allergies()->pluck('ingredients.id');
        $favoriteIngredientIds = $child->favoriteIngredients()->pluck('ingredients.id');

        // Filter recipes based on hard constraints (age, allergies).
        $eligibleRecipes = Recipe::query()
            ->where('min_age_months', '<=', $child->birth_date->diffInMonths(now()))
            ->where(function ($query) use ($child) {
                $ageInMonths = $child->birth_date->diffInMonths(now());
                $query->whereNull('max_age_months')
                    ->orWhere('max_age_months', '>=', $ageInMonths);
            })
            ->whereDoesntHave('ingredients', function ($query) use ($allergyIngredientIds) {
                $query->whereIn('id', $allergyIngredientIds);
            })
            ->with('ingredients')
            ->get();

        // Score the eligible recipes based on soft constraints (preferences, needs).
        return $eligibleRecipes->map(function ($recipe) use ($child, $favoriteIngredientIds) {
            $score = 0;
            if ($recipe->ingredients->whereIn('id', $favoriteIngredientIds)->isNotEmpty()) {
                $score += 10; // Priority for favorite foods
            }
            if (str_contains($child->nutritional_status_hfa, 'Stunting') && $recipe->protein_grams > 10) {
                $score += 15; // High priority for high-protein if stunted
            }
            if (str_contains($child->nutritional_status_wfh, 'Kurus') && $recipe->calories > 150) {
                $score += 12; // High priority for high-calorie if underweight
            }
            $recipe->score = $score;
            return $recipe;
        })
            ->sortByDesc('score')
            ->take(self::IDEAL_RECIPE_POOL_SIZE);
    }

    /**
     * Calculates a min/max monthly budget based on a collection of ideal recipes.
     *
     * @param Collection $idealRecipes
     * @return array
     */
    private function calculateCostRange(Collection $idealRecipes): array
    {
        // Sort the ideal recipes by cost to find the cheapest and most expensive ones.
        $sortedByCost = $idealRecipes->sortBy('estimated_cost')->values();
        $poolCount = $sortedByCost->count();

        // The 'min' budget is based on the average cost of the cheaper half of ideal recipes.
        $avgCostMin = $sortedByCost->take(floor($poolCount / 2))->avg('estimated_cost');

        // The 'max' budget is based on the average cost of the more expensive half.
        $avgCostMax = $sortedByCost->skip(floor($poolCount / 2))->avg('estimated_cost');

        // Extrapolate to a full month (3 meals a day for 30 days).
        $minBudget = $avgCostMin * 3 * 30;
        $maxBudget = $avgCostMax * 3 * 30;

        // Round to the nearest Rp 10,000 for a cleaner look.
        return [
            'min' => (int) round($minBudget / 10000) * 10000,
            'max' => (int) round($maxBudget / 10000) * 10000,
        ];
    }

    /**
     * Adjusts the calculated ideal budget to fit within a realistic percentage of parent's income.
     *
     * @param array $costRange The ideal ['min', 'max'] budget.
     * @param int $parentIncome The parent's monthly income.
     * @return array The final, realistic ['min', 'max'] budget.
     */
    private function adjustRangeToIncome(array $costRange, int $parentIncome): array
    {
        $incomeFloor = $parentIncome * self::MIN_INCOME_PERCENTAGE;
        $incomeCeiling = $parentIncome * self::MAX_INCOME_PERCENTAGE;

        // The final max budget is the LOWER of the ideal max OR the income ceiling.
        $finalMax = min($costRange['max'], $incomeCeiling);

        // The final min budget is the LOWER of the ideal min OR the final max (to prevent min > max).
        // It's also capped at the bottom by the income floor.
        $finalMin = max(min($costRange['min'], $finalMax), $incomeFloor);

        return [
            'min' => (int) round($finalMin / 10000) * 10000,
            'max' => (int) round($finalMax / 10000) * 10000,
        ];
    }
}

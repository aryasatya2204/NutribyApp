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
    private const MEALS_PER_WEEK = 21; // 7 days * 3 meals

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
        $allergyIngredientIds = $child->allergies()->pluck('ingredients.id');
        $favoriteIngredientIds = $child->favoriteIngredients()->pluck('ingredients.id');
        $nutritionalStatus = $child->nutritional_status_hfa;

        // Use adjusted budget from options, or the default recommended budget.
        // We divide by 4.2 weeks and 7 days to get a daily budget estimate.
        $monthlyBudget = $options['budget'] ?? $child->recommended_budget;
        $dailyBudget = $monthlyBudget / 4.2 / 7;

        // 2. Build the Base Query (Filtering)
        // Start by getting a pool of all potentially suitable recipes.
        $eligibleRecipes = Recipe::query()
            // Rule: Must be appropriate for the child's age.
            ->where('min_age_months', '<=', $ageInMonths)

            // Rule: Must be within the daily budget.
            ->where('estimated_cost', '<=', $dailyBudget)

            // Rule: Must NOT contain any ingredients the child is allergic to.
            ->whereDoesntHave('ingredients', function ($query) use ($allergyIngredientIds) {
                $query->whereIn('id', $allergyIngredientIds);
            })
            ->with('ingredients') // Eager load ingredients for scoring
            ->get();

        // Handle case where not enough recipes are found
        if ($eligibleRecipes->count() < self::MEALS_PER_WEEK) {
            // In a real app, you'd throw a custom exception here to give a nice error message.
            // For now, we return what we can find.
            return $eligibleRecipes->shuffle()->take(self::MEALS_PER_WEEK);
        }

        // 3. Score Each Recipe (Prioritization)
        // This is where the "AI-like" logic happens.
        $scoredRecipes = $eligibleRecipes->map(function ($recipe) use ($nutritionalStatus, $favoriteIngredientIds) {
            $score = 0;

            // Priority: Boost recipes containing favorite ingredients.
            $favoriteCount = $recipe->ingredients->whereIn('id', $favoriteIngredientIds)->count();
            $score += $favoriteCount * 5; // Add 5 points for each favorite ingredient

            // Priority: If stunting, boost recipes with high protein.
            if (str_contains($nutritionalStatus, 'Stunting') && $recipe->protein_grams > 10) {
                $score += 15; // High priority boost
            }
            
            // Priority: If underweight (kurus), boost high-calorie recipes.
            if (str_contains($nutritionalStatus, 'Kurang') && $recipe->calories > 150) {
                $score += 10;
            }

            $recipe->score = $score; // Attach the score to the recipe object
            return $recipe;
        });

        // 4. Select the Final 21 Recipes
        // Sort by score descending, take the top ~40 recipes for variety,
        // then randomly pick 21 from that top tier.
        return $scoredRecipes->sortByDesc('score')
            ->take(40) // Take a larger pool of high-scoring recipes
            ->shuffle() // Shuffle to ensure variety each week
            ->take(self::MEALS_PER_WEEK); // Select the final 21
    }
}
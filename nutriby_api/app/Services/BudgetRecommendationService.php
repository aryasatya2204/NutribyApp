<?php

namespace App\Services;

use App\Models\Child;

class BudgetRecommendationService
{
    // Constants for business logic, easy to change here.
    private const BASE_PERCENTAGE = 0.20; // 20% of income as a baseline
    private const STUNTING_ADJUSTMENT = 0.05; // Add 5% if child is stunted
    private const MAX_RECOMMENDATION = 1500000; // Max budget Rp 1.500.000

    /**
     * Recommend a monthly MPASI budget based on income and nutritional status.
     *
     * @param Child $child The child object with income and status data.
     * @return int The recommended budget in Rupiah.
     */
    public function recommend(Child $child): int
    {
        $income = $child->parent_monthly_income;
        $status = $child->nutritional_status_hfa;

        // 1. Start with the base percentage of parent's income.
        $recommendedBudget = $income * self::BASE_PERCENTAGE;

        // 2. Adjust the budget based on the child's nutritional status.
        // If the child is stunted, we recommend a slightly higher budget for better nutrition.
        if (str_contains($status, 'Stunting')) {
            $recommendedBudget += ($income * self::STUNTING_ADJUSTMENT);
        }

        // 3. Apply a ceiling to the recommendation to keep it realistic.
        if ($recommendedBudget > self::MAX_RECOMMENDATION) {
            $recommendedBudget = self::MAX_RECOMMENDATION;
        }

        // 4. Ensure budget is a round number (e.g., multiple of 1000).
        return (int) round($recommendedBudget / 1000) * 1000;
    }
}
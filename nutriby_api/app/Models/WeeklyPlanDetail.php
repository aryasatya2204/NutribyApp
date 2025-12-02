<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class WeeklyPlanDetail extends Model
{
    use HasFactory;

    protected $fillable = [
        'weekly_plan_id',
        'recipe_id',
        'day_of_week',
        'meal_type',
    ];

    /**
     * Get the weekly plan that owns this detail.
     */
    public function weeklyPlan()
    {
        return $this->belongsTo(WeeklyPlan::class);
    }

    /**
     * Get the recipe for this meal.
     */
    public function recipe()
    {
        return $this->belongsTo(Recipe::class);
    }
}
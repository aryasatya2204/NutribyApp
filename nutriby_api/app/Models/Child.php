<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Child extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'name',
        'birth_date',
        'gender',
        'current_weight',
        'current_height',
        'parent_monthly_income',
        'nutritional_status_wfa',
        'nutritional_status_hfa',
        'nutritional_status_wfh',
        'nutritional_status_notes',
        'recommended_budget',
        'budget_min', 
        'budget_max', 
    ];

    protected $casts = [
        'birth_date' => 'date',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function growthHistories()
    {
        return $this->hasMany(ChildGrowthHistory::class);
    }

    /**
     * ✅ FIXED: Sekarang relasi ke Allergy (bukan Ingredient)
     * Child memiliki grup alergi seperti "Alergi Telur", "Alergi Susu"
     */
    public function allergies()
    {
        return $this->belongsToMany(Allergy::class, 'child_allergy');
    }

    /**
     * ✅ TETAP: Favorit tetap pakai Ingredient karena lebih spesifik
     * Contoh: anak suka "Ayam Kampung" bukan grup "Daging"
     */
    public function favoriteIngredients()
    {
        return $this->belongsToMany(Ingredient::class, 'child_favorite_ingredient');
    }

    public function weeklyPlans()
    {
        return $this->hasMany(WeeklyPlan::class);
    }

    /**
     * HELPER METHOD: Get all ingredient IDs from child's allergies
     * Berguna untuk filtering resep
     */
    public function getAllergenIngredientIds()
    {
        return $this->allergies()
            ->with('ingredients')
            ->get()
            ->pluck('ingredients')
            ->flatten()
            ->pluck('id')
            ->unique()
            ->values()
            ->toArray();
    }
}
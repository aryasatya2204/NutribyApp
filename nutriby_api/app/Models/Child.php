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
        'nutritional_status_notes',
        'recommended_budget',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array
     */
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

    public function allergies()
    {
        return $this->belongsToMany(Ingredient::class, 'child_allergy');
    }

    public function favoriteIngredients()
    {
        return $this->belongsToMany(Ingredient::class, 'child_favorite_ingredient');
    }
}
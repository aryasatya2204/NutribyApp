<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Allergy extends Model
{
    use HasFactory;

    protected $fillable = [
        'ingredient_id',
        'type',
        'name',
        'symptoms',
        'handling_and_prevention',
        'image_url',
    ];

    /**
     * Get the ingredient that causes this allergy.
     */
    public function ingredients()
    {
        return $this->belongsToMany(Ingredient::class, 'allergy_ingredient');
    }
}

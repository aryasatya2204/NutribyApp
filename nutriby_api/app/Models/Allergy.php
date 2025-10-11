<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Allergy extends Model
{
    use HasFactory;

    protected $fillable = [
        'ingredient_id',
        'name',
        'symptoms',
        'handling_and_prevention',
    ];

    /**
     * Get the ingredient that causes this allergy.
     */
    public function ingredient()
    {
        return $this->belongsTo(Ingredient::class);
    }
}
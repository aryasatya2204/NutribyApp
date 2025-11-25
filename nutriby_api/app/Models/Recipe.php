<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Recipe extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'description',
        'instructions',
        'image_url',
        'min_age_months',
        'max_age_months',
        'texture',
        'estimated_cost',
        'serving_size',
        'calories',
        'protein_grams',
        'fat_grams',
        'nutrition_focus', 
        'iron_total_mg',  
        'zinc_total_mg',   
    ];

    public function ingredients()
    {
        // Menambahkan withPivot untuk mengambil kolom 'quantity' dari tabel pivot
        return $this->belongsToMany(Ingredient::class, 'recipe_ingredient')->withPivot('quantity');
    }
}
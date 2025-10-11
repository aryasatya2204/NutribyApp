<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Ingredient extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'category',
        'description',
        'image_url',
    ];

    public function recipes()
    {
        return $this->belongsToMany(Recipe::class, 'recipe_ingredient');
    }

    // Satu bahan bisa menjadi penyebab satu jenis alergi
    public function allergyInfo()
    {
        return $this->hasOne(Allergy::class);
    }
}
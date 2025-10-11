<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class GrowthStandard extends Model
{
    use HasFactory;
    
    /**
     * Indicates if the model should be timestamped.
     *
     * @var bool
     */
    public $timestamps = false; // Data ini statis, tidak perlu created_at/updated_at

    protected $fillable = [
        'gender',
        'age_in_months',
        'metric',
        'sd3_neg',
        'sd2_neg',
        'sd1_neg',
        'median',
        'sd1_pos',
        'sd2_pos',
        'sd3_pos',
    ];
}
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ChildGrowthHistory extends Model
{
    use HasFactory;

    protected $fillable = [
        'child_id',
        'record_date',
        'weight',
        'height',
        'nutritional_status_hfa',
        'recommended_budget_at_the_time',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array
     */
    protected $casts = [
        'record_date' => 'date',
    ];

    /**
     * Get the child that owns this growth history record.
     */
    public function child()
    {
        return $this->belongsTo(Child::class);
    }
}
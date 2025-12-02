<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class WeeklyPlan extends Model
{
    use HasFactory;

    protected $fillable = [
        'child_id',
        'name',
        'start_date',
        'end_date',
    ];

    protected $casts = [
        'start_date' => 'date',
        'end_date' => 'date',
    ];

    /**
     * Get the child that owns this weekly plan.
     */
    public function child()
    {
        return $this->belongsTo(Child::class);
    }

    /**
     * Get all the meal details for this weekly plan.
     */
    public function details()
    {
        return $this->hasMany(WeeklyPlanDetail::class);
    }
}
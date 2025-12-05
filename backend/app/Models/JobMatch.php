<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class JobMatch extends Model
{
    protected $fillable = [
        'user_id',
        'cv_id',
        'job_description',
        'job_title',
        'company_name',
        'match_score',
        'match_verdict',
        'matching_skills',
        'missing_skills',
        'improvement_suggestions',
        'strengths',
        'is_saved',
    ];

    protected $casts = [
        'matching_skills' => 'array',
        'missing_skills' => 'array',
        'improvement_suggestions' => 'array',
        'strengths' => 'array',
        'is_saved' => 'boolean',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function cv()
    {
        return $this->belongsTo(CV::class);
    }
}

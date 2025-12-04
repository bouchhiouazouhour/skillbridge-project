<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CVAnalysis extends Model
{
    protected $table = 'cv_analyses';

    protected $fillable = [
        'cv_id',
        'skills',
        'missing_sections',
        'suggestions',
        'score',
        'skills_score',
        'completeness_score',
        'ats_score',
    ];

    protected $casts = [
        'skills' => 'array',
        'missing_sections' => 'array',
        'suggestions' => 'array',
    ];

    public function cv()
    {
        return $this->belongsTo(CV::class);
    }
}

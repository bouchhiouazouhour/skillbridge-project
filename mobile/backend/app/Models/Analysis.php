<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Analysis extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'original_filename',
        'mime',
        'size',
        'sub_scores',
        'suggestions',
    ];

    protected $casts = [
        'sub_scores' => 'array',
        'suggestions' => 'array',
    ];
}

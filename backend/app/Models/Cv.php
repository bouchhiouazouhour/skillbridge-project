<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CV extends Model
{
    use HasFactory;

    protected $table = 'cvs';

    protected $fillable = [
        'user_id',
        'filename',
        'path',
        'status',
        'analysis_result',
    ];

    protected $casts = [
        'analysis_result' => 'array',
    ];

    /**
     * Relation avec User
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
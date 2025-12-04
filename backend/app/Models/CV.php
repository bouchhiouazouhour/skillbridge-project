<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CV extends Model
{
    protected $table = 'cvs';

    protected $fillable = [
        'user_id',
        'filename',
        'file_path',
        'original_name',
        'status',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function analysis()
    {
        return $this->hasOne(CVAnalysis::class);
    }
}

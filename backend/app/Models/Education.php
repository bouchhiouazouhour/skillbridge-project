<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Education extends Model
{
    protected $fillable = [
        'user_id','institution','degree','field','start_date','end_date','notes'
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}

<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Experience extends Model
{
    protected $fillable = [
        'user_id','title','company','location','start_date','end_date','is_current','description'
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}

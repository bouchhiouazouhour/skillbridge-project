<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Certification extends Model
{
    protected $fillable = [
        'user_id','title','issuer','date_obtained','expires_at','credential_id','credential_url'
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}

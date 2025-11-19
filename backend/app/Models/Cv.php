<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Cv extends Model
{
    protected $fillable = ['user_id', 'chemin_fichier', 'score'];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}

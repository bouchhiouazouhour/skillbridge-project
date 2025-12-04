<?php

namespace App\Http\Middleware;

use Illuminate\Auth\Middleware\RedirectIfAuthenticated as Middleware;

class RedirectIfAuthenticated extends Middleware
{
    /**
     * The route that users should be redirected to.
     *
     * @var string
     */
    protected $redirectTo = '/home';
}

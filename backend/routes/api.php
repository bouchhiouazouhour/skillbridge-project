<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\CVController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// Authentication routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:api')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    
    // CV Management routes
    Route::post('/cv/upload', [CVController::class, 'upload']);
    Route::post('/cv/analysis', [CVController::class, 'storeAnalysis']);
    Route::get('/cv/{id}/results', [CVController::class, 'getResults']);
    Route::get('/cv/{id}/score', [CVController::class, 'getScore']);
    Route::post('/cv/{id}/calculate-score', [CVController::class, 'calculateScore']);
    Route::get('/cv/{id}/suggestions', [CVController::class, 'getSuggestions']);
    Route::put('/cv/{id}/suggestions', [CVController::class, 'updateSuggestions']);
    Route::post('/cv/{id}/export', [CVController::class, 'exportPDF']);
});

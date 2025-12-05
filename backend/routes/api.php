<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\CVController;
use App\Http\Controllers\CVAnalysisController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// Health check
Route::get('/', function () {
    return response()->json(['message' => 'SkillBridge API is running', 'status' => 'ok']);
});

// NLP Service health check (public endpoint)
Route::get('/nlp-health', [CVAnalysisController::class, 'healthCheck']);

// Authentication routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:api')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/profile', [AuthController::class, 'profile']);
    
    // CV Analysis route - forwards to Python NLP service
    Route::post('/analyze-cv', [CVAnalysisController::class, 'analyze']);
    
    // CV Management routes
    Route::post('/cv/upload', [CVController::class, 'upload']);
    Route::get('/cv/history', [CVController::class, 'history']);
    Route::post('/cv/analysis', [CVController::class, 'storeAnalysis']);
    Route::get('/cv/{id}/results', [CVController::class, 'getResults']);
    Route::get('/cv/{id}/score', [CVController::class, 'getScore']);
    Route::post('/cv/{id}/calculate-score', [CVController::class, 'calculateScore']);
    Route::get('/cv/{id}/suggestions', [CVController::class, 'getSuggestions']);
    Route::put('/cv/{id}/suggestions', [CVController::class, 'updateSuggestions']);
    Route::post('/cv/{id}/export', [CVController::class, 'exportPDF']);
});

<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CvController;
use App\Http\Controllers\Api\ProfileController;
use App\Http\Controllers\Api\ExperiencesController;
use App\Http\Controllers\Api\EducationsController;
use App\Http\Controllers\Api\ProjectsController;
use App\Http\Controllers\Api\SkillsController;
use App\Http\Controllers\Api\CertificationsController;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', [AuthController::class, 'user']);

    Route::get('profile', [ProfileController::class, 'show']);
    Route::put('profile', [ProfileController::class, 'update']);

    // CV upload and analysis
    Route::post('cvs/upload', [CVController::class, 'upload']);
     Route::get('/cvs', [CVController::class, 'index']);
    Route::get('/cv/{id}', [CVController::class, 'show']);
    Route::get('/cv/{id}/download', [CVController::class, 'download']);
    // experiences
    Route::get('experiences', [ExperiencesController::class, 'index']);
    Route::post('experiences', [ExperiencesController::class, 'store']);
    Route::get('experiences/{id}', [ExperiencesController::class, 'show']);
    Route::put('experiences/{id}', [ExperiencesController::class, 'update']);
    Route::delete('experiences/{id}', [ExperiencesController::class, 'destroy']);
   //about
    Route::post('/about', [ProfileController::class, 'updateAbout']);

    // educations
    Route::apiResource('educations', EducationsController::class)->only(['index','store','show','update','destroy']);

    // projects
    Route::apiResource('projects', ProjectsController::class)->only(['index','store','show','update','destroy']);

    // skills
    Route::apiResource('skills', SkillsController::class)->only(['index','store','show','update','destroy']);

    // certifications
    Route::apiResource('certifications', CertificationsController::class)->only(['index','store','show','update','destroy']);

});
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('job_matches', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('cv_id')->constrained('cvs')->onDelete('cascade');
            $table->text('job_description');
            $table->string('job_title')->nullable();
            $table->string('company_name')->nullable();
            $table->integer('match_score')->default(0); // 0-100
            $table->string('match_verdict')->default('weak'); // strong, moderate, weak
            $table->json('matching_skills')->nullable();
            $table->json('missing_skills')->nullable();
            $table->json('improvement_suggestions')->nullable();
            $table->json('strengths')->nullable();
            $table->boolean('is_saved')->default(false);
            $table->timestamps();
            
            // Indexes
            $table->index('user_id');
            $table->index('cv_id');
            $table->index('match_score');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('job_matches');
    }
};

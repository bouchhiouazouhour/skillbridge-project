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
            $table->integer('match_score'); // 0-100
            $table->string('match_verdict'); // strong, moderate, weak
            $table->json('matching_skills');
            $table->json('missing_skills');
            $table->json('improvement_suggestions');
            $table->json('strengths');
            $table->boolean('is_saved')->default(false);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('job_matches');
    }
};

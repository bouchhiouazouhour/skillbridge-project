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
            $table->foreignId('cv_id')->constrained()->onDelete('cascade');
            $table->text('job_description');
            $table->integer('match_score'); // 0-100
            $table->string('match_verdict'); // strong/moderate/weak
            $table->json('matching_skills')->nullable();
            $table->json('missing_skills')->nullable();
            $table->json('improvement_suggestions')->nullable();
            $table->json('strengths')->nullable();
            $table->boolean('is_saved')->default(false);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('job_matches');
    }
};

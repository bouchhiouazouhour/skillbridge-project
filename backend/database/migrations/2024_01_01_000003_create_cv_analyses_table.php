<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('cv_analyses', function (Blueprint $table) {
            $table->id();
            $table->foreignId('cv_id')->constrained()->onDelete('cascade');
            $table->json('skills')->nullable();
            $table->json('missing_sections')->nullable();
            $table->json('suggestions')->nullable();
            $table->integer('score')->default(0);
            $table->integer('skills_score')->default(0);
            $table->integer('completeness_score')->default(0);
            $table->integer('ats_score')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('cv_analyses');
    }
};

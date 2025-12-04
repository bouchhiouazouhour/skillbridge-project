<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('cvs', function (Blueprint $table) {
            // Renommer chemin_fichier en path (optionnel si vous voulez garder chemin_fichier)
            // $table->renameColumn('chemin_fichier', 'path');
            
            // Ou ajouter les nouvelles colonnes
            $table->string('filename')->nullable()->after('user_id');
            $table->string('path')->nullable()->after('filename');
            $table->enum('status', ['pending', 'analyzed', 'optimized'])->default('pending')->after('score');
            $table->json('analysis_result')->nullable()->after('status');
        });
    }

    /**
     * Reverse the migrations. 
     */
    public function down(): void
    {
        Schema::table('cvs', function (Blueprint $table) {
            $table->dropColumn(['filename', 'path', 'status', 'analysis_result']);
        });
    }
};
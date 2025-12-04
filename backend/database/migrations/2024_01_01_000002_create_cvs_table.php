<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('cvs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('filename');
            $table->string('file_path');
            $table->string('original_name');
            $table->string('status')->default('pending'); // pending, processing, completed, failed
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('cvs');
    }
};

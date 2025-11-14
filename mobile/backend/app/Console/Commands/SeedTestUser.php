<?php

namespace App\Console\Commands;

use App\Models\User;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Hash;

class SeedTestUser extends Command
{
    protected $signature = 'dev:seed-test-user {--email=test@example.com} {--password=password}';
    protected $description = 'Create or update a test user for quick mobile login.';

    public function handle(): int
    {
        $email = $this->option('email');
        $password = $this->option('password');
        $user = User::query()->where('email', $email)->first();
        if (!$user) {
            $user = User::create([
                'name' => 'Test User',
                'email' => $email,
                'password' => Hash::make($password),
            ]);
            $this->info("Created test user: {$email}");
        } else {
            $user->update(['password' => Hash::make($password)]);
            $this->info("Updated password for test user: {$email}");
        }
        return self::SUCCESS;
    }
}

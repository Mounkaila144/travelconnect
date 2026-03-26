<?php

namespace App\Console\Commands;

use App\Models\UserBan;
use Illuminate\Console\Command;

class UnbanExpiredUsers extends Command
{
    protected $signature = 'users:unban-expired';
    protected $description = 'Automatically unban users with expired temporary bans';

    public function handle(): int
    {
        $expiredBans = UserBan::whereNotNull('expires_at')
            ->where('expires_at', '<=', now())
            ->whereNull('unbanned_at')
            ->get();

        $count = 0;

        foreach ($expiredBans as $ban) {
            $ban->user->update(['is_banned' => false]);

            $ban->update([
                'unbanned_at' => now(),
                'unban_reason' => 'Automatic unban - temporary ban expired',
            ]);

            $count++;
        }

        $this->info("Unbanned {$count} users with expired bans.");

        return Command::SUCCESS;
    }
}

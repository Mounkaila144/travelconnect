<?php

namespace App\Console\Commands;

use App\Services\TrustScoreService;
use Illuminate\Console\Command;

class RecalculateTrustScores extends Command
{
    protected $signature = 'trust-score:recalculate-all';
    protected $description = 'Recalculate trust scores for all users';

    public function __construct(
        private readonly TrustScoreService $trustScoreService
    ) {
        parent::__construct();
    }

    public function handle(): int
    {
        $this->info('Recalculating trust scores for all users...');

        $count = $this->trustScoreService->recalculateAllTrustScores();

        $this->info("Successfully recalculated trust scores for {$count} users.");

        return Command::SUCCESS;
    }
}

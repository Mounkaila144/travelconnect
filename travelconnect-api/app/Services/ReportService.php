<?php

namespace App\Services;

use App\Events\ReportCreated;
use App\Models\Report;
use App\Models\User;
use Illuminate\Support\Facades\DB;

class ReportService
{
    public function createReport(User $reporter, array $data): Report
    {
        $existingReport = Report::where('reporter_id', $reporter->id)
            ->where('reportable_type', $data['reportable_type'])
            ->where('reportable_id', $data['reportable_id'])
            ->first();

        if ($existingReport) {
            throw new \InvalidArgumentException('Vous avez déjà signalé ce contenu');
        }

        return DB::transaction(function () use ($reporter, $data) {
            $report = Report::create([
                'reporter_id' => $reporter->id,
                'reportable_type' => $data['reportable_type'],
                'reportable_id' => $data['reportable_id'],
                'reason' => $data['reason'],
                'comment' => $data['comment'] ?? null,
                'status' => 'pending',
            ]);

            event(new ReportCreated($report));

            return $report;
        });
    }
}

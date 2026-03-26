<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\ApproveReportRequest;
use App\Http\Requests\Admin\BanUserRequest;
use App\Http\Requests\Admin\DeleteContentRequest;
use App\Models\ModerationAction;
use App\Models\Report;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\View\View;

class ModerationController extends Controller
{
    public function index(): View
    {
        $reports = Report::where('status', 'pending')
            ->with([
                'reporter:id,name,avatar_url,trust_score',
                'reportable',
            ])
            ->orderByDesc('created_at')
            ->paginate(20);

        return view('admin.reports.index', compact('reports'));
    }

    public function show(int $id): View
    {
        $report = Report::with([
            'reporter:id,name,avatar_url,email,trust_score',
            'reportable.user:id,name,avatar_url,trust_score,is_banned',
        ])->findOrFail($id);

        if ($report->reportable_type === 'App\\Models\\Question') {
            $report->reportable->load(['answers.user']);
        } elseif ($report->reportable_type === 'App\\Models\\Answer') {
            $report->reportable->load(['question.user']);
        }

        return view('admin.reports.show', compact('report'));
    }

    public function approve(ApproveReportRequest $request, int $id): RedirectResponse
    {
        DB::transaction(function () use ($request, $id) {
            $report = Report::findOrFail($id);

            $report->update([
                'status' => 'approved',
                'admin_note' => $request->input('admin_note'),
                'processed_at' => now(),
                'processed_by' => Auth::guard('admin')->id(),
            ]);

            ModerationAction::create([
                'admin_id' => Auth::guard('admin')->id(),
                'report_id' => $report->id,
                'action' => 'approved',
                'note' => $request->input('admin_note'),
            ]);
        });

        return redirect()->route('admin.reports.index')
            ->with('success', 'Signalement approuvé avec succès.');
    }

    public function deleteContent(DeleteContentRequest $request, int $id): RedirectResponse
    {
        DB::transaction(function () use ($request, $id) {
            $report = Report::findOrFail($id);

            $report->reportable->update(['is_deleted' => true]);

            if ($report->reportable_type === 'App\\Models\\Question') {
                $report->reportable->answers()->update(['is_deleted' => true]);
            }

            $report->update([
                'status' => 'rejected',
                'admin_note' => $request->input('admin_note'),
                'processed_at' => now(),
                'processed_by' => Auth::guard('admin')->id(),
            ]);

            ModerationAction::create([
                'admin_id' => Auth::guard('admin')->id(),
                'report_id' => $report->id,
                'action' => 'deleted',
                'note' => $request->input('admin_note'),
            ]);
        });

        return redirect()->route('admin.reports.index')
            ->with('success', 'Contenu supprimé avec succès.');
    }

    public function banUser(BanUserRequest $request, int $id): RedirectResponse
    {
        DB::transaction(function () use ($request, $id) {
            $report = Report::findOrFail($id);
            $user = $report->reportable->user;

            $user->update(['is_banned' => true]);
            $user->tokens()->delete();

            $report->reportable->update(['is_deleted' => true]);

            $report->update([
                'status' => 'rejected',
                'admin_note' => $request->input('admin_note'),
                'processed_at' => now(),
                'processed_by' => Auth::guard('admin')->id(),
            ]);

            ModerationAction::create([
                'admin_id' => Auth::guard('admin')->id(),
                'report_id' => $report->id,
                'action' => 'banned',
                'note' => $request->input('admin_note'),
            ]);
        });

        return redirect()->route('admin.reports.index')
            ->with('success', 'Utilisateur banni avec succès.');
    }

    public function history(): View
    {
        $actions = ModerationAction::with([
            'admin:id,name',
            'report.reportable',
        ])
            ->orderByDesc('created_at')
            ->paginate(50);

        return view('admin.reports.history', compact('actions'));
    }
}

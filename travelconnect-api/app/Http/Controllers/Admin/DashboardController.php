<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Answer;
use App\Models\Question;
use App\Models\Report;
use App\Models\User;
use Illuminate\View\View;

class DashboardController extends Controller
{
    public function index(): View
    {
        $statistics = [
            'total_users' => User::count(),
            'total_questions' => Question::where('is_deleted', false)->count(),
            'total_answers' => Answer::where('is_deleted', false)->count(),
            'pending_reports' => Report::where('status', 'pending')->count(),
            'new_users_7d' => User::where('created_at', '>=', now()->subDays(7))->count(),
            'active_users_30d' => User::where(function ($query) {
                $query->whereHas('questions', function ($q) {
                    $q->where('created_at', '>=', now()->subDays(30));
                })->orWhereHas('answers', function ($q) {
                    $q->where('created_at', '>=', now()->subDays(30));
                });
            })->count(),
        ];

        return view('admin.dashboard', compact('statistics'));
    }
}

<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\BanUserAdminRequest;
use App\Http\Requests\Admin\RemoveBadgeRequest;
use App\Http\Requests\Admin\UnbanUserRequest;
use App\Models\AdminUserAction;
use App\Models\User;
use App\Models\UserBan;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\View\View;

class UserController extends Controller
{
    public function index(Request $request): View
    {
        $query = User::query();

        if ($search = $request->input('search')) {
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('email', 'like', "%{$search}%");
            });
        }

        if ($userType = $request->input('user_type')) {
            $query->where('user_type', $userType);
        }

        if ($request->has('is_banned')) {
            $query->where('is_banned', $request->boolean('is_banned'));
        }

        $users = $query->withCount(['questions', 'answers'])
            ->orderByDesc('created_at')
            ->paginate(20);

        return view('admin.users.index', compact('users'));
    }

    public function show(int $id): View
    {
        $user = User::with([
            'questions' => fn($q) => $q->latest()->take(10),
            'answers' => fn($q) => $q->with('question:id,title')->latest()->take(10),
            'bans' => fn($q) => $q->latest('banned_at'),
        ])
            ->withCount(['questions', 'answers'])
            ->findOrFail($id);

        $actions = AdminUserAction::where('user_id', $id)
            ->with('admin:id,name')
            ->latest('created_at')
            ->get();

        $statistics = [
            'questions_count' => $user->questions_count,
            'answers_count' => $user->answers_count,
            'avg_rating' => $user->answers()->avg('average_rating'),
            'account_age_days' => $user->created_at->diffInDays(now()),
        ];

        return view('admin.users.show', compact('user', 'actions', 'statistics'));
    }

    public function ban(BanUserAdminRequest $request, int $id): RedirectResponse
    {
        $user = User::findOrFail($id);

        DB::transaction(function () use ($request, $user) {
            $user->update(['is_banned' => true]);

            $expiresAt = null;
            if (!$request->boolean('is_permanent') && $request->filled('ban_duration_days')) {
                $expiresAt = now()->addDays($request->integer('ban_duration_days'));
            }

            UserBan::create([
                'user_id' => $user->id,
                'banned_by' => Auth::guard('admin')->id(),
                'reason' => $request->input('reason'),
                'is_permanent' => $request->boolean('is_permanent'),
                'duration_days' => $request->input('ban_duration_days'),
                'banned_at' => now(),
                'expires_at' => $expiresAt,
            ]);

            $user->tokens()->delete();

            AdminUserAction::create([
                'admin_id' => Auth::guard('admin')->id(),
                'user_id' => $user->id,
                'action' => 'banned',
                'reason' => $request->input('reason'),
                'metadata' => [
                    'is_permanent' => $request->boolean('is_permanent'),
                    'duration_days' => $request->input('ban_duration_days'),
                    'expires_at' => $expiresAt?->toIso8601String(),
                ],
            ]);
        });

        return redirect()->route('admin.users.show', $user->id)
            ->with('success', 'Utilisateur banni avec succès.');
    }

    public function unban(UnbanUserRequest $request, int $id): RedirectResponse
    {
        $user = User::findOrFail($id);

        DB::transaction(function () use ($request, $user) {
            $user->update(['is_banned' => false]);

            $activeBan = $user->bans()->whereNull('unbanned_at')->latest('banned_at')->first();
            if ($activeBan) {
                $activeBan->update([
                    'unbanned_at' => now(),
                    'unbanned_by' => Auth::guard('admin')->id(),
                    'unban_reason' => $request->input('reason'),
                ]);
            }

            AdminUserAction::create([
                'admin_id' => Auth::guard('admin')->id(),
                'user_id' => $user->id,
                'action' => 'unbanned',
                'reason' => $request->input('reason'),
            ]);
        });

        return redirect()->route('admin.users.show', $user->id)
            ->with('success', 'Utilisateur débanni avec succès.');
    }

    public function removeBadge(RemoveBadgeRequest $request, int $id): RedirectResponse
    {
        $user = User::findOrFail($id);

        if ($user->user_type !== 'local_supporter') {
            return back()->withErrors(['error' => 'Cet utilisateur n\'a pas de badge Local Supporter.']);
        }

        DB::transaction(function () use ($request, $user) {
            $oldType = $user->user_type;

            $user->update(['user_type' => 'traveler']);

            AdminUserAction::create([
                'admin_id' => Auth::guard('admin')->id(),
                'user_id' => $user->id,
                'action' => 'badge_removed',
                'reason' => $request->input('reason'),
                'metadata' => [
                    'old_type' => $oldType,
                    'new_type' => 'traveler',
                ],
            ]);
        });

        return redirect()->route('admin.users.show', $user->id)
            ->with('success', 'Badge Local Supporter retiré avec succès.');
    }
}

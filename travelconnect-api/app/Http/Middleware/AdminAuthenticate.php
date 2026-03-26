<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class AdminAuthenticate
{
    public function handle(Request $request, Closure $next): Response
    {
        if (!Auth::guard('admin')->check()) {
            return redirect()->route('admin.login')
                ->with('error', 'Veuillez vous connecter pour accéder à cette page.');
        }

        // Check session expiration (8 hours)
        $lastActivity = $request->session()->get('last_activity_time');
        if ($lastActivity && (time() - $lastActivity > 28800)) {
            Auth::guard('admin')->logout();
            $request->session()->invalidate();

            return redirect()->route('admin.login')
                ->with('error', 'Votre session a expiré. Veuillez vous reconnecter.');
        }

        $request->session()->put('last_activity_time', time());

        return $next($request);
    }
}

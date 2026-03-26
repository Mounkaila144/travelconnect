<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>@yield('title', 'Admin') - TravelConnect</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 min-h-screen">
    <!-- Navigation -->
    <nav class="bg-white shadow-sm" x-data="{ open: false }">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-between h-16">
                <div class="flex items-center">
                    <a href="{{ route('admin.dashboard') }}" class="text-xl font-bold text-blue-600">
                        TravelConnect Admin
                    </a>
                    <!-- Desktop navigation -->
                    <div class="hidden sm:flex sm:ml-8 sm:space-x-4">
                        <a href="{{ route('admin.dashboard') }}"
                           class="px-3 py-2 rounded-md text-sm font-medium {{ request()->routeIs('admin.dashboard') ? 'bg-blue-100 text-blue-700' : 'text-gray-600 hover:text-gray-900' }}">
                            Dashboard
                        </a>
                        @if(Route::has('admin.reports.index'))
                        <a href="{{ route('admin.reports.index') }}"
                           class="px-3 py-2 rounded-md text-sm font-medium {{ request()->routeIs('admin.reports.*') ? 'bg-blue-100 text-blue-700' : 'text-gray-600 hover:text-gray-900' }}">
                            Signalements
                        </a>
                        @endif
                        @if(Route::has('admin.users.index'))
                        <a href="{{ route('admin.users.index') }}"
                           class="px-3 py-2 rounded-md text-sm font-medium {{ request()->routeIs('admin.users.*') ? 'bg-blue-100 text-blue-700' : 'text-gray-600 hover:text-gray-900' }}">
                            Utilisateurs
                        </a>
                        @endif
                    </div>
                </div>
                <div class="flex items-center">
                    <span class="hidden sm:block text-sm text-gray-500 mr-4">
                        {{ Auth::guard('admin')->user()->name }}
                    </span>
                    <form method="POST" action="{{ route('admin.logout') }}">
                        @csrf
                        <button type="submit" class="text-sm text-red-600 hover:text-red-800 font-medium">
                            Déconnexion
                        </button>
                    </form>
                    <!-- Mobile menu button -->
                    <button onclick="document.getElementById('mobile-menu').classList.toggle('hidden')"
                            class="sm:hidden ml-4 p-2 rounded-md text-gray-400 hover:text-gray-500">
                        <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/>
                        </svg>
                    </button>
                </div>
            </div>
        </div>
        <!-- Mobile menu -->
        <div id="mobile-menu" class="hidden sm:hidden border-t border-gray-200">
            <div class="px-2 pt-2 pb-3 space-y-1">
                <a href="{{ route('admin.dashboard') }}"
                   class="block px-3 py-2 rounded-md text-base font-medium {{ request()->routeIs('admin.dashboard') ? 'bg-blue-100 text-blue-700' : 'text-gray-600' }}">
                    Dashboard
                </a>
                @if(Route::has('admin.reports.index'))
                <a href="{{ route('admin.reports.index') }}"
                   class="block px-3 py-2 rounded-md text-base font-medium {{ request()->routeIs('admin.reports.*') ? 'bg-blue-100 text-blue-700' : 'text-gray-600' }}">
                    Signalements
                </a>
                @endif
                @if(Route::has('admin.users.index'))
                <a href="{{ route('admin.users.index') }}"
                   class="block px-3 py-2 rounded-md text-base font-medium {{ request()->routeIs('admin.users.*') ? 'bg-blue-100 text-blue-700' : 'text-gray-600' }}">
                    Utilisateurs
                </a>
                @endif
                <div class="px-3 py-2 text-sm text-gray-500">
                    {{ Auth::guard('admin')->user()->name }}
                </div>
            </div>
        </div>
    </nav>

    <!-- Main content -->
    <main class="max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8">
        @if(session('success'))
            <div class="mb-4 p-4 bg-green-100 border border-green-400 text-green-700 rounded">
                {{ session('success') }}
            </div>
        @endif

        @if(session('error'))
            <div class="mb-4 p-4 bg-red-100 border border-red-400 text-red-700 rounded">
                {{ session('error') }}
            </div>
        @endif

        @yield('content')
    </main>

    <!-- Footer -->
    <footer class="bg-white border-t border-gray-200 mt-auto">
        <div class="max-w-7xl mx-auto py-4 px-4 sm:px-6 lg:px-8 text-center text-sm text-gray-500">
            TravelConnect Administration
        </div>
    </footer>
</body>
</html>

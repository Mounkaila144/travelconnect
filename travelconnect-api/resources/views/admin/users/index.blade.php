@extends('admin.layouts.app')

@section('title', 'Utilisateurs')

@section('content')
<div class="mb-6">
    <h1 class="text-2xl font-bold text-gray-900">Gestion des utilisateurs</h1>
</div>

<!-- Search & Filters -->
<div class="bg-white rounded-lg shadow-sm p-4 mb-4">
    <form method="GET" action="{{ route('admin.users.index') }}" class="flex flex-col sm:flex-row gap-3">
        <div class="flex-1">
            <input type="text" name="search" value="{{ request('search') }}"
                   placeholder="Rechercher par nom ou email..."
                   class="w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
        </div>
        <select name="user_type" class="px-3 py-2 border border-gray-300 rounded-md text-sm">
            <option value="">Tous les types</option>
            <option value="traveler" {{ request('user_type') === 'traveler' ? 'selected' : '' }}>Voyageur</option>
            <option value="local_supporter" {{ request('user_type') === 'local_supporter' ? 'selected' : '' }}>Local Supporter</option>
        </select>
        <button type="submit" class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 text-sm font-medium">
            Rechercher
        </button>
    </form>
</div>

@if($users->isEmpty())
    <div class="bg-white rounded-lg shadow-sm p-8 text-center">
        <p class="text-gray-500">Aucun utilisateur trouvé.</p>
    </div>
@else
    <div class="bg-white rounded-lg shadow-sm overflow-hidden">
        <!-- Desktop table -->
        <div class="hidden sm:block overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-50">
                    <tr>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Utilisateur</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Email</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Type</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Score</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Statut</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Inscription</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Action</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-200">
                    @foreach($users as $user)
                    <tr>
                        <td class="px-6 py-4">
                            <div class="flex items-center">
                                <div class="h-8 w-8 rounded-full bg-gray-200 flex-shrink-0 overflow-hidden">
                                    @if($user->avatar_url)
                                        <img src="{{ $user->avatar_url }}" alt="" class="h-8 w-8 rounded-full object-cover">
                                    @endif
                                </div>
                                <span class="ml-3 text-sm font-medium text-gray-900">{{ $user->name }}</span>
                            </div>
                        </td>
                        <td class="px-6 py-4 text-sm text-gray-600">{{ $user->email }}</td>
                        <td class="px-6 py-4 text-sm">
                            <span class="px-2 py-1 text-xs rounded-full {{ $user->user_type === 'local_supporter' ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800' }}">
                                {{ $user->user_type === 'local_supporter' ? 'Local Supporter' : 'Voyageur' }}
                            </span>
                        </td>
                        <td class="px-6 py-4 text-sm text-gray-600">{{ number_format($user->trust_score, 2) }}</td>
                        <td class="px-6 py-4 text-sm">
                            <span class="px-2 py-1 text-xs rounded-full {{ $user->is_banned ? 'bg-red-100 text-red-800' : 'bg-green-100 text-green-800' }}">
                                {{ $user->is_banned ? 'Banni' : 'Actif' }}
                            </span>
                        </td>
                        <td class="px-6 py-4 text-sm text-gray-500">{{ $user->created_at->format('d/m/Y') }}</td>
                        <td class="px-6 py-4">
                            <a href="{{ route('admin.users.show', $user->id) }}"
                               class="text-blue-600 hover:text-blue-800 text-sm font-medium">
                                Détails
                            </a>
                        </td>
                    </tr>
                    @endforeach
                </tbody>
            </table>
        </div>

        <!-- Mobile cards -->
        <div class="sm:hidden divide-y divide-gray-200">
            @foreach($users as $user)
            <a href="{{ route('admin.users.show', $user->id) }}" class="block p-4 hover:bg-gray-50">
                <div class="flex justify-between items-start">
                    <div class="flex items-center">
                        <div class="h-8 w-8 rounded-full bg-gray-200 flex-shrink-0 overflow-hidden">
                            @if($user->avatar_url)
                                <img src="{{ $user->avatar_url }}" alt="" class="h-8 w-8 rounded-full object-cover">
                            @endif
                        </div>
                        <div class="ml-3">
                            <p class="text-sm font-medium text-gray-900">{{ $user->name }}</p>
                            <p class="text-xs text-gray-500">{{ $user->email }}</p>
                        </div>
                    </div>
                    <span class="px-2 py-1 text-xs rounded-full {{ $user->is_banned ? 'bg-red-100 text-red-800' : 'bg-green-100 text-green-800' }}">
                        {{ $user->is_banned ? 'Banni' : 'Actif' }}
                    </span>
                </div>
            </a>
            @endforeach
        </div>
    </div>

    <div class="mt-4">
        {{ $users->withQueryString()->links() }}
    </div>
@endif
@endsection

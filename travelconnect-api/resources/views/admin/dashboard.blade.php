@extends('admin.layouts.app')

@section('title', 'Tableau de bord')

@section('content')
<div class="mb-6">
    <h1 class="text-2xl font-bold text-gray-900">Tableau de bord</h1>
    <p class="text-gray-500 mt-1">Bienvenue, {{ Auth::guard('admin')->user()->name }}</p>
</div>

<!-- Statistics Grid -->
<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 mb-8">
    <div class="bg-white rounded-lg shadow-sm p-6">
        <div class="text-sm font-medium text-gray-500">Utilisateurs</div>
        <div class="text-3xl font-bold text-gray-900 mt-2">{{ number_format($statistics['total_users']) }}</div>
    </div>

    <div class="bg-white rounded-lg shadow-sm p-6">
        <div class="text-sm font-medium text-gray-500">Questions</div>
        <div class="text-3xl font-bold text-gray-900 mt-2">{{ number_format($statistics['total_questions']) }}</div>
    </div>

    <div class="bg-white rounded-lg shadow-sm p-6">
        <div class="text-sm font-medium text-gray-500">Réponses</div>
        <div class="text-3xl font-bold text-gray-900 mt-2">{{ number_format($statistics['total_answers']) }}</div>
    </div>

    <div class="bg-white rounded-lg shadow-sm p-6 {{ $statistics['pending_reports'] > 0 ? 'border-l-4 border-orange-500' : '' }}">
        <div class="text-sm font-medium text-gray-500">Signalements en attente</div>
        <div class="text-3xl font-bold {{ $statistics['pending_reports'] > 0 ? 'text-orange-600' : 'text-gray-900' }} mt-2">
            {{ number_format($statistics['pending_reports']) }}
        </div>
    </div>

    <div class="bg-white rounded-lg shadow-sm p-6">
        <div class="text-sm font-medium text-gray-500">Nouveaux utilisateurs (7j)</div>
        <div class="text-3xl font-bold text-green-600 mt-2">{{ number_format($statistics['new_users_7d']) }}</div>
    </div>

    <div class="bg-white rounded-lg shadow-sm p-6">
        <div class="text-sm font-medium text-gray-500">Utilisateurs actifs (30j)</div>
        <div class="text-3xl font-bold text-blue-600 mt-2">{{ number_format($statistics['active_users_30d']) }}</div>
    </div>
</div>

<!-- Quick Actions -->
<div class="bg-white rounded-lg shadow-sm p-6">
    <h2 class="text-lg font-semibold text-gray-900 mb-4">Actions rapides</h2>
    <div class="flex flex-wrap gap-3">
        @if(Route::has('admin.reports.index'))
        <a href="{{ route('admin.reports.index') }}"
           class="inline-flex items-center px-4 py-2 bg-orange-100 text-orange-700 rounded-md hover:bg-orange-200 font-medium text-sm">
            Voir les signalements
        </a>
        @endif
        @if(Route::has('admin.users.index'))
        <a href="{{ route('admin.users.index') }}"
           class="inline-flex items-center px-4 py-2 bg-blue-100 text-blue-700 rounded-md hover:bg-blue-200 font-medium text-sm">
            Gérer les utilisateurs
        </a>
        @endif
    </div>
</div>
@endsection

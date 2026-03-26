@extends('admin.layouts.app')

@section('title', $user->name)

@section('content')
<!-- Breadcrumb -->
<nav class="mb-4 text-sm">
    <a href="{{ route('admin.users.index') }}" class="text-blue-600 hover:text-blue-800">Utilisateurs</a>
    <span class="text-gray-400 mx-2">/</span>
    <span class="text-gray-600">{{ $user->name }}</span>
</nav>

<div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
    <!-- User Profile -->
    <div class="lg:col-span-1 space-y-4">
        <div class="bg-white rounded-lg shadow-sm p-6">
            <div class="text-center mb-4">
                <div class="h-20 w-20 rounded-full bg-gray-200 mx-auto overflow-hidden">
                    @if($user->avatar_url)
                        <img src="{{ $user->avatar_url }}" alt="" class="h-20 w-20 rounded-full object-cover">
                    @endif
                </div>
                <h2 class="text-lg font-semibold text-gray-900 mt-3">{{ $user->name }}</h2>
                <p class="text-sm text-gray-500">{{ $user->email }}</p>
            </div>

            <div class="space-y-3">
                <div class="flex justify-between">
                    <span class="text-sm text-gray-500">Type</span>
                    <span class="px-2 py-1 text-xs rounded-full {{ $user->user_type === 'local_supporter' ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800' }}">
                        {{ $user->user_type === 'local_supporter' ? 'Local Supporter' : 'Voyageur' }}
                    </span>
                </div>
                <div class="flex justify-between">
                    <span class="text-sm text-gray-500">Score de confiance</span>
                    <span class="text-sm font-medium">{{ number_format($user->trust_score, 2) }}</span>
                </div>
                <div class="flex justify-between">
                    <span class="text-sm text-gray-500">Statut</span>
                    <span class="px-2 py-1 text-xs rounded-full {{ $user->is_banned ? 'bg-red-100 text-red-800' : 'bg-green-100 text-green-800' }}">
                        {{ $user->is_banned ? 'Banni' : 'Actif' }}
                    </span>
                </div>
                @if($user->bio)
                <div>
                    <span class="text-sm text-gray-500">Bio</span>
                    <p class="text-sm text-gray-700">{{ $user->bio }}</p>
                </div>
                @endif
                <div class="flex justify-between">
                    <span class="text-sm text-gray-500">Pays</span>
                    <span class="text-sm">{{ $user->country_code }}</span>
                </div>
                <div class="flex justify-between">
                    <span class="text-sm text-gray-500">Inscription</span>
                    <span class="text-sm">{{ $user->created_at->format('d/m/Y') }}</span>
                </div>
                <div class="flex justify-between">
                    <span class="text-sm text-gray-500">Compte</span>
                    <span class="text-sm">{{ $statistics['account_age_days'] }} jours</span>
                </div>
            </div>
        </div>

        <!-- Statistics -->
        <div class="bg-white rounded-lg shadow-sm p-6">
            <h3 class="text-sm font-semibold text-gray-900 mb-3">Statistiques</h3>
            <div class="grid grid-cols-2 gap-4">
                <div class="text-center p-3 bg-gray-50 rounded">
                    <div class="text-2xl font-bold text-gray-900">{{ $statistics['questions_count'] }}</div>
                    <div class="text-xs text-gray-500">Questions</div>
                </div>
                <div class="text-center p-3 bg-gray-50 rounded">
                    <div class="text-2xl font-bold text-gray-900">{{ $statistics['answers_count'] }}</div>
                    <div class="text-xs text-gray-500">Réponses</div>
                </div>
                <div class="text-center p-3 bg-gray-50 rounded col-span-2">
                    <div class="text-2xl font-bold text-gray-900">{{ $statistics['avg_rating'] ? number_format($statistics['avg_rating'], 1) : '-' }}</div>
                    <div class="text-xs text-gray-500">Note moyenne</div>
                </div>
            </div>
        </div>

        <!-- Actions -->
        <div class="bg-white rounded-lg shadow-sm p-6 space-y-3">
            <h3 class="text-sm font-semibold text-gray-900 mb-3">Actions</h3>

            @if(!$user->is_banned)
                <form method="POST" action="{{ route('admin.users.ban', $user->id) }}">
                    @csrf
                    <textarea name="reason" placeholder="Raison du bannissement (obligatoire)..." rows="2" required
                        class="w-full px-3 py-2 border border-gray-300 rounded-md text-sm mb-2"></textarea>
                    <div class="flex items-center mb-2">
                        <input type="hidden" name="is_permanent" value="1">
                    </div>
                    <button type="submit"
                        class="w-full bg-red-600 text-white py-2 px-4 rounded-md hover:bg-red-700 text-sm font-medium"
                        onclick="return confirm('Bannir cet utilisateur ?')">
                        Bannir l'utilisateur
                    </button>
                </form>
            @else
                <form method="POST" action="{{ route('admin.users.unban', $user->id) }}">
                    @csrf
                    <textarea name="reason" placeholder="Raison du débannissement (obligatoire)..." rows="2" required
                        class="w-full px-3 py-2 border border-gray-300 rounded-md text-sm mb-2"></textarea>
                    <button type="submit"
                        class="w-full bg-green-600 text-white py-2 px-4 rounded-md hover:bg-green-700 text-sm font-medium"
                        onclick="return confirm('Débannir cet utilisateur ?')">
                        Débannir l'utilisateur
                    </button>
                </form>
            @endif

            @if($user->user_type === 'local_supporter')
                <form method="POST" action="{{ route('admin.users.remove-badge', $user->id) }}">
                    @csrf
                    <textarea name="reason" placeholder="Raison du retrait (obligatoire)..." rows="2" required
                        class="w-full px-3 py-2 border border-gray-300 rounded-md text-sm mb-2"></textarea>
                    <button type="submit"
                        class="w-full bg-orange-600 text-white py-2 px-4 rounded-md hover:bg-orange-700 text-sm font-medium"
                        onclick="return confirm('Retirer le badge Local Supporter ?')">
                        Retirer badge Local Supporter
                    </button>
                </form>
            @endif
        </div>
    </div>

    <!-- Content & History -->
    <div class="lg:col-span-2 space-y-6">
        <!-- Recent Questions -->
        <div class="bg-white rounded-lg shadow-sm p-6">
            <h3 class="text-lg font-semibold text-gray-900 mb-4">Questions récentes</h3>
            @if($user->questions->isEmpty())
                <p class="text-sm text-gray-500">Aucune question posée.</p>
            @else
                <div class="space-y-3">
                    @foreach($user->questions as $question)
                    <div class="border border-gray-200 rounded-lg p-3 {{ $question->is_deleted ? 'opacity-50' : '' }}">
                        <div class="flex justify-between items-start">
                            <h4 class="text-sm font-medium text-gray-900">{{ $question->title }}</h4>
                            @if($question->is_deleted)
                                <span class="text-xs bg-red-100 text-red-800 px-2 py-1 rounded-full">Supprimée</span>
                            @endif
                        </div>
                        <p class="text-xs text-gray-500 mt-1">
                            {{ $question->location_name }} - {{ $question->created_at->format('d/m/Y') }}
                            - {{ $question->answers_count }} réponse(s)
                        </p>
                    </div>
                    @endforeach
                </div>
            @endif
        </div>

        <!-- Recent Answers -->
        <div class="bg-white rounded-lg shadow-sm p-6">
            <h3 class="text-lg font-semibold text-gray-900 mb-4">Réponses récentes</h3>
            @if($user->answers->isEmpty())
                <p class="text-sm text-gray-500">Aucune réponse donnée.</p>
            @else
                <div class="space-y-3">
                    @foreach($user->answers as $answer)
                    <div class="border border-gray-200 rounded-lg p-3 {{ $answer->is_deleted ? 'opacity-50' : '' }}">
                        <p class="text-sm text-gray-700">{{ Str::limit($answer->content, 150) }}</p>
                        <p class="text-xs text-gray-500 mt-1">
                            @if($answer->question)
                                Re: {{ Str::limit($answer->question->title, 40) }} -
                            @endif
                            {{ $answer->created_at->format('d/m/Y') }}
                            @if($answer->is_deleted)
                                <span class="text-red-600">(supprimée)</span>
                            @endif
                        </p>
                    </div>
                    @endforeach
                </div>
            @endif
        </div>

        <!-- Admin Actions History -->
        <div class="bg-white rounded-lg shadow-sm p-6">
            <h3 class="text-lg font-semibold text-gray-900 mb-4">Historique des actions admin</h3>
            @if($actions->isEmpty())
                <p class="text-sm text-gray-500">Aucune action enregistrée.</p>
            @else
                <div class="space-y-3">
                    @foreach($actions as $action)
                    <div class="flex justify-between items-start border-b border-gray-100 pb-3">
                        <div>
                            <span class="px-2 py-1 text-xs rounded-full
                                {{ $action->action === 'banned' ? 'bg-red-100 text-red-800' : '' }}
                                {{ $action->action === 'unbanned' ? 'bg-green-100 text-green-800' : '' }}
                                {{ $action->action === 'badge_removed' ? 'bg-orange-100 text-orange-800' : '' }}">
                                @switch($action->action)
                                    @case('banned') Banni @break
                                    @case('unbanned') Débanni @break
                                    @case('badge_removed') Badge retiré @break
                                @endswitch
                            </span>
                            <p class="text-sm text-gray-600 mt-1">{{ $action->reason }}</p>
                            <p class="text-xs text-gray-400 mt-1">
                                Par {{ $action->admin->name ?? 'Système' }}
                            </p>
                        </div>
                        <span class="text-xs text-gray-400">{{ $action->created_at->format('d/m/Y H:i') }}</span>
                    </div>
                    @endforeach
                </div>
            @endif
        </div>
    </div>
</div>
@endsection

@extends('admin.layouts.app')

@section('title', 'Signalement #' . $report->id)

@section('content')
<!-- Breadcrumb -->
<nav class="mb-4 text-sm">
    <a href="{{ route('admin.reports.index') }}" class="text-blue-600 hover:text-blue-800">Signalements</a>
    <span class="text-gray-400 mx-2">/</span>
    <span class="text-gray-600">#{{ $report->id }}</span>
</nav>

<div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
    <!-- Report Info -->
    <div class="lg:col-span-1 space-y-4">
        <div class="bg-white rounded-lg shadow-sm p-6">
            <h2 class="text-lg font-semibold text-gray-900 mb-4">Signalement #{{ $report->id }}</h2>

            <div class="space-y-3">
                <div>
                    <span class="text-sm text-gray-500">Raison</span>
                    <p class="font-medium">{{ $report->reason_label }}</p>
                </div>

                @if($report->comment)
                <div>
                    <span class="text-sm text-gray-500">Commentaire</span>
                    <p class="text-gray-700">{{ $report->comment }}</p>
                </div>
                @endif

                <div>
                    <span class="text-sm text-gray-500">Signalé par</span>
                    <p class="font-medium">{{ $report->reporter->name ?? 'Inconnu' }}</p>
                </div>

                <div>
                    <span class="text-sm text-gray-500">Date</span>
                    <p>{{ $report->created_at->format('d/m/Y à H:i') }}</p>
                </div>

                <div>
                    <span class="text-sm text-gray-500">Statut</span>
                    <p>
                        <span class="px-2 py-1 text-xs rounded-full
                            {{ $report->status === 'pending' ? 'bg-yellow-100 text-yellow-800' : '' }}
                            {{ $report->status === 'approved' ? 'bg-green-100 text-green-800' : '' }}
                            {{ $report->status === 'rejected' ? 'bg-red-100 text-red-800' : '' }}">
                            {{ $report->status_label }}
                        </span>
                    </p>
                </div>
            </div>
        </div>

        @if($report->status === 'pending')
        <!-- Action Forms -->
        <div class="bg-white rounded-lg shadow-sm p-6 space-y-4">
            <h3 class="text-lg font-semibold text-gray-900">Actions</h3>

            <!-- Approve -->
            <form method="POST" action="{{ route('admin.reports.approve', $report->id) }}">
                @csrf
                <textarea name="admin_note" placeholder="Note (optionnelle)..." rows="2"
                    class="w-full px-3 py-2 border border-gray-300 rounded-md text-sm mb-2"></textarea>
                <button type="submit"
                    class="w-full bg-green-600 text-white py-2 px-4 rounded-md hover:bg-green-700 text-sm font-medium"
                    onclick="return confirm('Approuver ce signalement ?')">
                    Approuver (ignorer)
                </button>
            </form>

            <hr>

            <!-- Delete Content -->
            <form method="POST" action="{{ route('admin.reports.delete-content', $report->id) }}">
                @csrf
                <textarea name="admin_note" placeholder="Raison de la suppression (obligatoire)..." rows="2" required
                    class="w-full px-3 py-2 border border-gray-300 rounded-md text-sm mb-2"></textarea>
                @error('admin_note')
                    <p class="text-red-600 text-xs mb-2">{{ $message }}</p>
                @enderror
                <button type="submit"
                    class="w-full bg-orange-600 text-white py-2 px-4 rounded-md hover:bg-orange-700 text-sm font-medium"
                    onclick="return confirm('Supprimer ce contenu ? Cette action est irréversible.')">
                    Supprimer le contenu
                </button>
            </form>

            <hr>

            <!-- Ban User -->
            <form method="POST" action="{{ route('admin.reports.ban-user', $report->id) }}">
                @csrf
                <textarea name="admin_note" placeholder="Raison du bannissement (obligatoire)..." rows="2" required
                    class="w-full px-3 py-2 border border-gray-300 rounded-md text-sm mb-2"></textarea>
                <div class="flex items-center mb-2">
                    <input type="hidden" name="is_permanent" value="1">
                </div>
                <button type="submit"
                    class="w-full bg-red-600 text-white py-2 px-4 rounded-md hover:bg-red-700 text-sm font-medium"
                    onclick="return confirm('Bannir cet utilisateur ? Ses tokens d\'accès seront révoqués.')">
                    Bannir l'utilisateur
                </button>
            </form>
        </div>
        @endif
    </div>

    <!-- Reported Content Context -->
    <div class="lg:col-span-2">
        <div class="bg-white rounded-lg shadow-sm p-6">
            <h2 class="text-lg font-semibold text-gray-900 mb-4">Contenu signalé</h2>

            @if($report->reportable)
                @if($report->reportable_type === 'App\Models\Question')
                    <!-- Question Report -->
                    <div class="border-2 border-red-200 bg-red-50 rounded-lg p-4 mb-4">
                        <div class="flex items-center mb-2">
                            <span class="text-xs bg-red-100 text-red-800 px-2 py-1 rounded-full mr-2">Question signalée</span>
                            @if($report->reportable->is_deleted)
                                <span class="text-xs bg-gray-100 text-gray-600 px-2 py-1 rounded-full">Supprimée</span>
                            @endif
                        </div>
                        <h3 class="font-semibold text-gray-900">{{ $report->reportable->title }}</h3>
                        <p class="text-gray-700 mt-2">{{ $report->reportable->description }}</p>
                        <div class="text-xs text-gray-400 mt-2">
                            Par {{ $report->reportable->user->name ?? 'Inconnu' }}
                            @if($report->reportable->user?->is_banned) <span class="text-red-600">(banni)</span> @endif
                            - {{ $report->reportable->created_at->format('d/m/Y H:i') }}
                        </div>
                    </div>

                    @if($report->reportable->answers->isNotEmpty())
                        <h3 class="font-medium text-gray-700 mb-2">Réponses ({{ $report->reportable->answers->count() }})</h3>
                        @foreach($report->reportable->answers as $answer)
                            <div class="border border-gray-200 rounded-lg p-3 mb-2 {{ $answer->is_deleted ? 'opacity-50' : '' }}">
                                <p class="text-sm text-gray-700">{{ $answer->content }}</p>
                                <div class="text-xs text-gray-400 mt-1">
                                    Par {{ $answer->user->name ?? 'Inconnu' }} - {{ $answer->created_at->format('d/m/Y H:i') }}
                                </div>
                            </div>
                        @endforeach
                    @endif

                @elseif($report->reportable_type === 'App\Models\Answer')
                    <!-- Answer Report -->
                    @if($report->reportable->question)
                        <div class="border border-gray-200 rounded-lg p-4 mb-4">
                            <span class="text-xs text-gray-500">Question parente</span>
                            <h3 class="font-semibold text-gray-900">{{ $report->reportable->question->title }}</h3>
                            <p class="text-gray-700 mt-1 text-sm">{{ $report->reportable->question->description }}</p>
                            <div class="text-xs text-gray-400 mt-1">
                                Par {{ $report->reportable->question->user->name ?? 'Inconnu' }}
                            </div>
                        </div>
                    @endif

                    <div class="border-2 border-red-200 bg-red-50 rounded-lg p-4">
                        <div class="flex items-center mb-2">
                            <span class="text-xs bg-red-100 text-red-800 px-2 py-1 rounded-full mr-2">Réponse signalée</span>
                            @if($report->reportable->is_deleted)
                                <span class="text-xs bg-gray-100 text-gray-600 px-2 py-1 rounded-full">Supprimée</span>
                            @endif
                        </div>
                        <p class="text-gray-700">{{ $report->reportable->content }}</p>
                        <div class="text-xs text-gray-400 mt-2">
                            Par {{ $report->reportable->user->name ?? 'Inconnu' }}
                            @if($report->reportable->user?->is_banned) <span class="text-red-600">(banni)</span> @endif
                            - {{ $report->reportable->created_at->format('d/m/Y H:i') }}
                        </div>
                    </div>
                @endif
            @else
                <p class="text-gray-500">Le contenu signalé n'est plus disponible.</p>
            @endif
        </div>
    </div>
</div>
@endsection

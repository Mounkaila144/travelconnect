@extends('admin.layouts.app')

@section('title', 'Signalements')

@section('content')
<div class="mb-6 flex justify-between items-center">
    <h1 class="text-2xl font-bold text-gray-900">Signalements en attente</h1>
    <a href="{{ route('admin.reports.history') }}" class="text-sm text-blue-600 hover:text-blue-800 font-medium">
        Voir l'historique
    </a>
</div>

@if($reports->isEmpty())
    <div class="bg-white rounded-lg shadow-sm p-8 text-center">
        <p class="text-gray-500">Aucun signalement en attente.</p>
    </div>
@else
    <div class="bg-white rounded-lg shadow-sm overflow-hidden">
        <!-- Desktop table -->
        <div class="hidden sm:block overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-50">
                    <tr>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">ID</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Type</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Contenu</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Raison</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Signalé par</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Date</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Action</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-200">
                    @foreach($reports as $report)
                    <tr>
                        <td class="px-6 py-4 text-sm text-gray-900">#{{ $report->id }}</td>
                        <td class="px-6 py-4 text-sm">
                            <span class="px-2 py-1 text-xs rounded-full {{ $report->reportable_type === 'App\Models\Question' ? 'bg-blue-100 text-blue-800' : 'bg-purple-100 text-purple-800' }}">
                                {{ $report->reportable_type === 'App\Models\Question' ? 'Question' : 'Réponse' }}
                            </span>
                        </td>
                        <td class="px-6 py-4 text-sm text-gray-600 max-w-xs truncate">
                            @if($report->reportable)
                                {{ Str::limit($report->reportable->title ?? $report->reportable->content ?? '-', 50) }}
                            @else
                                <span class="text-gray-400">Contenu supprimé</span>
                            @endif
                        </td>
                        <td class="px-6 py-4 text-sm">
                            <span class="px-2 py-1 text-xs rounded-full
                                @switch($report->reason)
                                    @case('spam') bg-yellow-100 text-yellow-800 @break
                                    @case('offensive') bg-red-100 text-red-800 @break
                                    @case('false_info') bg-orange-100 text-orange-800 @break
                                    @default bg-gray-100 text-gray-800
                                @endswitch">
                                {{ $report->reason_label }}
                            </span>
                        </td>
                        <td class="px-6 py-4 text-sm text-gray-600">
                            {{ $report->reporter->name ?? 'Inconnu' }}
                        </td>
                        <td class="px-6 py-4 text-sm text-gray-500">
                            {{ $report->created_at->format('d/m/Y H:i') }}
                        </td>
                        <td class="px-6 py-4">
                            <a href="{{ route('admin.reports.show', $report->id) }}"
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
            @foreach($reports as $report)
            <a href="{{ route('admin.reports.show', $report->id) }}" class="block p-4 hover:bg-gray-50">
                <div class="flex justify-between items-start mb-2">
                    <span class="text-sm font-medium text-gray-900">#{{ $report->id }}</span>
                    <span class="px-2 py-1 text-xs rounded-full
                        @switch($report->reason)
                            @case('spam') bg-yellow-100 text-yellow-800 @break
                            @case('offensive') bg-red-100 text-red-800 @break
                            @case('false_info') bg-orange-100 text-orange-800 @break
                            @default bg-gray-100 text-gray-800
                        @endswitch">
                        {{ $report->reason_label }}
                    </span>
                </div>
                <p class="text-sm text-gray-600 truncate">
                    {{ Str::limit($report->reportable->title ?? $report->reportable->content ?? '-', 60) }}
                </p>
                <p class="text-xs text-gray-400 mt-1">
                    Par {{ $report->reporter->name ?? 'Inconnu' }} - {{ $report->created_at->format('d/m/Y') }}
                </p>
            </a>
            @endforeach
        </div>
    </div>

    <div class="mt-4">
        {{ $reports->links() }}
    </div>
@endif
@endsection

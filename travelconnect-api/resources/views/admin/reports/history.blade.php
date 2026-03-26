@extends('admin.layouts.app')

@section('title', 'Historique de modération')

@section('content')
<div class="mb-6 flex justify-between items-center">
    <h1 class="text-2xl font-bold text-gray-900">Historique de modération</h1>
    <a href="{{ route('admin.reports.index') }}" class="text-sm text-blue-600 hover:text-blue-800 font-medium">
        Retour aux signalements
    </a>
</div>

@if($actions->isEmpty())
    <div class="bg-white rounded-lg shadow-sm p-8 text-center">
        <p class="text-gray-500">Aucune action de modération enregistrée.</p>
    </div>
@else
    <div class="bg-white rounded-lg shadow-sm overflow-hidden">
        <div class="hidden sm:block overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-50">
                    <tr>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Date</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Admin</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Signalement</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Action</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Note</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-200">
                    @foreach($actions as $action)
                    <tr>
                        <td class="px-6 py-4 text-sm text-gray-500">
                            {{ $action->created_at->format('d/m/Y H:i') }}
                        </td>
                        <td class="px-6 py-4 text-sm text-gray-900">
                            {{ $action->admin->name ?? 'N/A' }}
                        </td>
                        <td class="px-6 py-4 text-sm">
                            <a href="{{ route('admin.reports.show', $action->report_id) }}" class="text-blue-600 hover:text-blue-800">
                                #{{ $action->report_id }}
                            </a>
                        </td>
                        <td class="px-6 py-4 text-sm">
                            <span class="px-2 py-1 text-xs rounded-full
                                {{ $action->action === 'approved' ? 'bg-green-100 text-green-800' : '' }}
                                {{ $action->action === 'deleted' ? 'bg-orange-100 text-orange-800' : '' }}
                                {{ $action->action === 'banned' ? 'bg-red-100 text-red-800' : '' }}">
                                @switch($action->action)
                                    @case('approved') Approuvé @break
                                    @case('deleted') Supprimé @break
                                    @case('banned') Banni @break
                                @endswitch
                            </span>
                        </td>
                        <td class="px-6 py-4 text-sm text-gray-600 max-w-xs truncate">
                            {{ $action->note ?? '-' }}
                        </td>
                    </tr>
                    @endforeach
                </tbody>
            </table>
        </div>

        <!-- Mobile cards -->
        <div class="sm:hidden divide-y divide-gray-200">
            @foreach($actions as $action)
            <div class="p-4">
                <div class="flex justify-between items-start mb-2">
                    <span class="text-sm font-medium text-gray-900">{{ $action->admin->name ?? 'N/A' }}</span>
                    <span class="px-2 py-1 text-xs rounded-full
                        {{ $action->action === 'approved' ? 'bg-green-100 text-green-800' : '' }}
                        {{ $action->action === 'deleted' ? 'bg-orange-100 text-orange-800' : '' }}
                        {{ $action->action === 'banned' ? 'bg-red-100 text-red-800' : '' }}">
                        @switch($action->action)
                            @case('approved') Approuvé @break
                            @case('deleted') Supprimé @break
                            @case('banned') Banni @break
                        @endswitch
                    </span>
                </div>
                <p class="text-xs text-gray-500">Signalement #{{ $action->report_id }}</p>
                @if($action->note)
                    <p class="text-sm text-gray-600 mt-1">{{ Str::limit($action->note, 80) }}</p>
                @endif
                <p class="text-xs text-gray-400 mt-1">{{ $action->created_at->format('d/m/Y H:i') }}</p>
            </div>
            @endforeach
        </div>
    </div>

    <div class="mt-4">
        {{ $actions->links() }}
    </div>
@endif
@endsection

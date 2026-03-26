<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\CreateReportRequest;
use App\Services\ReportService;
use Illuminate\Http\JsonResponse;

class ReportController extends Controller
{
    public function __construct(
        private readonly ReportService $reportService
    ) {}

    public function store(CreateReportRequest $request): JsonResponse
    {
        try {
            $this->reportService->createReport(
                reporter: $request->user(),
                data: $request->validated()
            );

            return response()->json([
                'message' => 'Signalement enregistré. Merci de contribuer à la modération.',
            ], 201);
        } catch (\InvalidArgumentException $e) {
            return response()->json([
                'error' => [
                    'code' => 'DUPLICATE_REPORT',
                    'message' => $e->getMessage(),
                ],
            ], 422);
        }
    }
}

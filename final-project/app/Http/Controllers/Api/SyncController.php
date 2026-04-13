<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\DailyClosing;
use App\Models\SyncLog;
use App\Services\DailyClosingService;
use App\Services\SyncService;
use Illuminate\Http\Request;
use Exception;

class SyncController extends Controller
{
    private SyncService $syncService;
    private DailyClosingService $dailyClosingService;

    public function __construct(SyncService $syncService, DailyClosingService $dailyClosingService)
    {
        $this->syncService = $syncService;
        $this->dailyClosingService = $dailyClosingService;
    }

    /**
     * Get pending sync logs for the user.
     */
    public function pendingLogs(Request $request)
    {
        $limit = $request->query('limit', 100);
        $logs = SyncLog::where('user_id', $request->user()->id)
            ->where('is_synced', false)
            ->orderBy('id', 'asc')
            ->limit($limit)
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $logs
        ]);
    }

    /**
     * Mark logs as synced.
     */
    public function markSynced(Request $request)
    {
        $request->validate([
            'log_ids' => 'required|array',
            'log_ids.*' => 'integer'
        ]);

        $count = $this->syncService->markAsSynced($request->log_ids);

        return response()->json([
            'status' => 'success',
            'message' => "$count log berhasil ditandai sebagai sinkron",
            'data' => [
                'updated_count' => $count
            ]
        ]);
    }

    /**
     * Get summary for daily closing.
     */
    public function closingSummary(Request $request)
    {
        $request->validate([
            'date' => 'required|date'
        ]);

        $summary = $this->dailyClosingService->calculateSummary($request->date);

        return response()->json([
            'status' => 'success',
            'data' => $summary
        ]);
    }

    /**
     * Perform daily closing.
     */
    public function performClosing(Request $request)
    {
        $request->validate([
            'date' => 'required|date',
            'actual_cash' => 'required|numeric|min:0',
            'note' => 'nullable|string'
        ]);

        try {
            $closing = $this->dailyClosingService->performClosing(
                $request->user()->id,
                $request->date,
                $request->actual_cash,
                $request->note
            );

            return response()->json([
                'status' => 'success',
                'message' => 'Tutup buku harian berhasil dilakukan',
                'data' => $closing
            ], 201);
        } catch (Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 422);
        }
    }

    /**
     * Get history of daily closings.
     */
    public function closingHistory(Request $request)
    {
        $history = DailyClosing::where('user_id', $request->user()->id)
            ->orderBy('closing_date', 'desc')
            ->paginate(15);

        return response()->json([
            'status' => 'success',
            'data' => $history
        ]);
    }
}

<?php

namespace App\Services;

use App\Models\SyncLog;
use Carbon\Carbon;

class SyncService
{
    /**
     * Log a database change that needs to be synchronized later.
     * Often called from Model Observers or after successful transactions.
     *
     * @param int $userId The user who made the change
     * @param string $tableName "transactions", "products", etc.
     * @param string $action 'create', 'update', 'delete'
     * @param int $recordId The ID of the affected row
     * @return SyncLog
     */
    public function logChange(int $userId, string $tableName, string $action, int $recordId): SyncLog
    {
        return SyncLog::create([
            'user_id' => $userId,
            'table_name' => $tableName,
            'action' => $action,
            'record_id' => $recordId,
            'is_synced' => false,
            'synced_at' => null,
        ]);
    }

    /**
     * Mark a batch of sync logs as successfully synchronized.
     *
     * @param array $syncLogIds Array of SyncLog IDs that were successfully processed
     * @return int Number of records updated
     */
    public function markAsSynced(array $syncLogIds): int
    {
        if (empty($syncLogIds)) {
            return 0;
        }

        return SyncLog::whereIn('id', $syncLogIds)
            ->update([
                'is_synced' => true,
                'synced_at' => Carbon::now()
            ]);
    }

    /**
     * Get all pending sync logs.
     *
     * @param int $limit
     * @return \Illuminate\Database\Eloquent\Collection
     */
    public function getPendingLogs(int $limit = 100)
    {
        return SyncLog::where('is_synced', false)
            ->orderBy('id', 'asc')
            ->limit($limit)
            ->get();
    }
}

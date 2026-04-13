<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SyncLog extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'user_id',
        'table_name',
        'action',
        'record_id',
        'synced_at',
        'is_synced',
    ];

    protected function casts(): array
    {
        return [
            'synced_at' => 'datetime',
            'is_synced' => 'boolean',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}

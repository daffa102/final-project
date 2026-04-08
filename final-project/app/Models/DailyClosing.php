<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DailyClosing extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'user_id',
        'closing_date',
        'total_sales',
        'total_transactions',
        'total_items_sold',
        'cash_amount',
        'qris_amount',
        'transfer_amount',
        'net_profit',
    ];

    protected function casts(): array
    {
        return [
            'closing_date'    => 'date',
            'total_sales'     => 'decimal:2',
            'cash_amount'       => 'decimal:2',
            'qris_amount'       => 'decimal:2',
            'transfer_amount'   => 'decimal:2',
            'net_profit'        => 'decimal:2',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}

<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Income extends Model
{
    protected $fillable = [
        'user_id',
        'name',
        'amount',
        'income_date',
        'note',
    ];

    protected function casts(): array
    {
        return [
            'amount'      => 'decimal:2',
            'income_date' => 'date',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}

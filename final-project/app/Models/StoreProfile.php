<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class StoreProfile extends Model
{
    protected $fillable = [
        'user_id',
        'store_name',
        'phone_number',
        'address',
        'logo_url',
        'qris_url',
        'receipt_footer',
        'tax_number',
        'instagram',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}

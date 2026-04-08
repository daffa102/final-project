<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('daily_closings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->date('closing_date');
            $table->decimal('total_sales', 12, 2);
            $table->integer('total_transactions');
            $table->integer('total_items_sold');
            $table->decimal('cash_amount', 12, 2);
            $table->decimal('qris_amount', 12, 2);
            $table->decimal('transfer_amount', 12, 2);
            $table->decimal('net_profit', 12, 2);
            $table->timestamp('created_at')->useCurrent();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('daily_closings');
    }
};

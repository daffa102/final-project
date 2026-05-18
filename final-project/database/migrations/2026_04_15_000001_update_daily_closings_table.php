<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('daily_closings', function (Blueprint $table) {
            $table->decimal('actual_cash', 12, 2)->after('transfer_amount')->default(0);
            $table->decimal('difference', 12, 2)->after('actual_cash')->default(0);
            $table->text('note')->nullable()->after('difference');
        });
    }

    public function down(): void
    {
        Schema::table('daily_closings', function (Blueprint $table) {
            $table->dropColumn(['actual_cash', 'difference', 'note']);
        });
    }
};

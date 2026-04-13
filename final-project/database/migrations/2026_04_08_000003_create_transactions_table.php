<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('invoice_number', 20)->unique();
            $table->decimal('total_amount', 12, 2);
            $table->string('payment_method', 20)->comment('cash / qris / transfer');
            $table->decimal('amount_paid', 12, 2);
            $table->decimal('change_amount', 12, 2);
            $table->string('note', 255)->nullable();
            $table->string('status', 20)->default('completed')->comment('completed / cancelled');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('transactions');
    }
};

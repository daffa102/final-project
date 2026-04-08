<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('sync_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('table_name', 50);
            $table->string('action', 20)->comment('create / update / delete');
            $table->unsignedBigInteger('record_id');
            $table->timestamp('synced_at')->nullable();
            $table->boolean('is_synced')->default(false);
            $table->timestamp('created_at')->useCurrent();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('sync_logs');
    }
};

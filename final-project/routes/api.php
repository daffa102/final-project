<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\StockController;
use App\Http\Controllers\Api\TransactionController;
use App\Http\Controllers\Api\FinanceController;
use App\Http\Controllers\Api\SyncController;
use App\Http\Controllers\Api\ProfileController;

Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    
    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    // Categories
    Route::apiResource('categories', CategoryController::class);

    // Products
    Route::apiResource('products', ProductController::class);

    // Stocks
    Route::get('/stocks', [StockController::class, 'index']);
    Route::post('/stocks/adjust', [StockController::class, 'adjust']);

    // Transactions
    Route::get('/transactions', [TransactionController::class, 'index']);
    Route::get('/transactions/{id}', [TransactionController::class, 'show']);
    Route::post('/transactions', [TransactionController::class, 'store']);

    // Finance (Income & Expense)
    Route::get('/finance/incomes', [FinanceController::class, 'incomes']);
    Route::post('/finance/incomes', [FinanceController::class, 'storeIncome']);
    Route::get('/finance/expenses', [FinanceController::class, 'expenses']);
    Route::post('/finance/expenses', [FinanceController::class, 'storeExpense']);

    // Sync & Daily Closing
    Route::get('/sync/pending', [SyncController::class, 'pendingLogs']);
    Route::post('/sync/mark', [SyncController::class, 'markSynced']);
    Route::get('/closing/summary', [SyncController::class, 'closingSummary']);
    Route::post('/closing', [SyncController::class, 'performClosing']);
    Route::get('/closing/history', [SyncController::class, 'closingHistory']);

    // Profile (Store & Account)
    Route::get('/profile', [ProfileController::class, 'index']);
    Route::post('/profile/update-store', [ProfileController::class, 'updateStore']);
    Route::post('/profile/update-password', [ProfileController::class, 'updatePassword']);
});

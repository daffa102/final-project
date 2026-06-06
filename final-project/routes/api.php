<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\StockController;
use App\Http\Controllers\Api\TransactionController;
use App\Http\Controllers\Api\SubscriptionController;
use App\Http\Controllers\Api\FinanceController;
use App\Http\Controllers\Api\SyncController;
use App\Http\Controllers\Api\ProfileController;
use App\Http\Controllers\Api\StoreController;

Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);
Route::post('/subscriptions/pay', [SubscriptionController::class, 'pay']);
Route::get('/subscriptions/check/{order_id}', [SubscriptionController::class, 'checkStatus']);
Route::get('/subscriptions/qr/{order_id}', [SubscriptionController::class, 'proxyQr']);

// OTP & Forgot Password
Route::post('/auth/forgot-password/send-otp', [AuthController::class, 'sendOtp']);
Route::post('/auth/forgot-password/verify-otp', [AuthController::class, 'verifyOtp']);
Route::post('/auth/forgot-password/reset', [AuthController::class, 'resetPassword']);

Route::get('/test-db', function() {
    return response()->json(['count' => \App\Models\Product::count()]);
});

Route::get('/storage/{path}', function ($path) {
    $file = storage_path('app/public/' . $path);
    if (file_exists($file)) {
        return response()->file($file, [
            'Access-Control-Allow-Origin' => '*',
            'Access-Control-Allow-Methods' => 'GET',
            'Access-Control-Allow-Headers' => 'Content-Type, X-Auth-Token, Origin, Authorization'
        ]);
    }
    abort(404);
})->where('path', '.*');

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
    Route::post('/transactions/initiate-payment', [TransactionController::class, 'initiatePayment']); // MUST be before {id} wildcard
    Route::post('/transactions', [TransactionController::class, 'store']);
    Route::get('/transactions/{id}', [TransactionController::class, 'show']);
    Route::get('/transactions/{id}/print', [TransactionController::class, 'print']);

    // Finance (Income & Expense)
    Route::get('/finance/summary', [FinanceController::class, 'summary']);
    Route::get('/finance/incomes', [FinanceController::class, 'incomes']);
    Route::post('/finance/incomes', [FinanceController::class, 'storeIncome']);
    Route::get('/finance/expenses', [FinanceController::class, 'expenses']);
    Route::post('/finance/expenses', [FinanceController::class, 'storeExpense']);
    Route::get('/finance/export', [FinanceController::class, 'exportPdf']);
    Route::get('/finance/export/excel', [FinanceController::class, 'exportExcel']);
    Route::post('/finance/manual-transactions', [FinanceController::class, 'storeManualTransaction']);

    // Sync & Daily Closing
    Route::get('/sync/pending', [SyncController::class, 'pendingLogs']);
    Route::post('/sync/mark-synced', [SyncController::class, 'markSynced']);
    Route::get('/closing-summary', [SyncController::class, 'closingSummary']);
    Route::post('/closing', [SyncController::class, 'performClosing']);
    Route::post('/daily-closing', [SyncController::class, 'performClosing']);

    // Store Settings
    Route::get('/store', [StoreController::class, 'show']);
    Route::post('/store', [StoreController::class, 'update']);

    Route::get('/closing/history', [SyncController::class, 'closingHistory']);

    // Profile (Store & Account)
    Route::get('/profile', [ProfileController::class, 'index']);
    Route::post('/profile/update-store', [ProfileController::class, 'updateStore']);
    Route::post('/profile/update-password', [ProfileController::class, 'updatePassword']);
});

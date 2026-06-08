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
    // Cari invoice_number yang duplikat
    $duplicates = \Illuminate\Support\Facades\DB::table('transactions')
        ->select('invoice_number', \Illuminate\Support\Facades\DB::raw('COUNT(*) as count'))
        ->groupBy('invoice_number')
        ->having('count', '>', 1)
        ->get();

    $deletedTransactions = 0;
    $deletedIncomes = 0;

    foreach ($duplicates as $dup) {
        // Ambil semua ID transaksi dengan invoice_number tersebut, urutkan dari ID terkecil
        $transactions = \Illuminate\Support\Facades\DB::table('transactions')
            ->where('invoice_number', $dup->invoice_number)
            ->orderBy('id', 'asc')
            ->get();

        // Transaksi pertama adalah transaksi asli, sisanya dihapus
        $duplicateIds = $transactions->slice(1)->pluck('id')->toArray();

        if (!empty($duplicateIds)) {
            // Hapus items dari transaksi duplikat terlebih dahulu
            \Illuminate\Support\Facades\DB::table('transaction_items')->whereIn('transaction_id', $duplicateIds)->delete();
            // Hapus stock movements
            \Illuminate\Support\Facades\DB::table('stock_movements')->whereIn('transaction_id', $duplicateIds)->delete();
            // Hapus transaksi duplikat itu sendiri
            $deletedTransactions += \Illuminate\Support\Facades\DB::table('transactions')->whereIn('id', $duplicateIds)->delete();
        }

        // Hapus income duplikat
        $incomeName = "Penjualan: " . $dup->invoice_number;
        $incomes = \Illuminate\Support\Facades\DB::table('incomes')
            ->where('name', $incomeName)
            ->orderBy('id', 'asc')
            ->get();
        
        if ($incomes->count() > 1) {
            $duplicateIncomeIds = $incomes->slice(1)->pluck('id')->toArray();
            $deletedIncomes += \Illuminate\Support\Facades\DB::table('incomes')->whereIn('id', $duplicateIncomeIds)->delete();
        }
    }

    return response()->json([
        'status' => 'success',
        'message' => 'Pembersihan via test-db selesai',
        'details' => [
            'duplicate_invoices_found' => $duplicates->count(),
            'deleted_duplicate_transactions' => $deletedTransactions,
            'deleted_duplicate_incomes' => $deletedIncomes
        ]
    ]);
});

Route::get('/cleanup-duplicates', function() {
    $userId = 1; // Sesuaikan dengan user ID Anda, atau ambil semua jika ingin
    
    // Cari invoice_number yang duplikat
    $duplicates = \Illuminate\Support\Facades\DB::table('transactions')
        ->select('invoice_number', \Illuminate\Support\Facades\DB::raw('COUNT(*) as count'))
        ->groupBy('invoice_number')
        ->having('count', '>', 1)
        ->get();

    $deletedTransactions = 0;
    $deletedIncomes = 0;

    foreach ($duplicates as $dup) {
        // Ambil semua ID transaksi dengan invoice_number tersebut, urutkan dari ID terkecil
        $transactions = \Illuminate\Support\Facades\DB::table('transactions')
            ->where('invoice_number', $dup->invoice_number)
            ->orderBy('id', 'asc')
            ->get();

        // Transaksi pertama (indeks 0) adalah transaksi asli, sisanya adalah duplikat yang akan dihapus
        $original = $transactions[0];
        $duplicateIds = $transactions->slice(1)->pluck('id')->toArray();

        if (!empty($duplicateIds)) {
            // Hapus items dari transaksi duplikat terlebih dahulu (foreign key constraint)
            \Illuminate\Support\Facades\DB::table('transaction_items')->whereIn('transaction_id', $duplicateIds)->delete();
            // Hapus stock movements dari transaksi duplikat
            \Illuminate\Support\Facades\DB::table('stock_movements')->whereIn('transaction_id', $duplicateIds)->delete();
            // Hapus transaksi duplikat itu sendiri
            $deletedTransactions += \Illuminate\Support\Facades\DB::table('transactions')->whereIn('id', $duplicateIds)->delete();
        }

        // Hapus income duplikat yang memiliki nama sama dengan invoice_number duplikat
        // Misal: "Penjualan: INV-20260607-0001"
        $incomeName = "Penjualan: " . $dup->invoice_number;
        $incomes = \Illuminate\Support\Facades\DB::table('incomes')
            ->where('name', $incomeName)
            ->orderBy('id', 'asc')
            ->get();
        
        if ($incomes->count() > 1) {
            $duplicateIncomeIds = $incomes->slice(1)->pluck('id')->toArray();
            $deletedIncomes += \Illuminate\Support\Facades\DB::table('incomes')->whereIn('id', $duplicateIncomeIds)->delete();
        }
    }

    return response()->json([
        'status' => 'success',
        'message' => 'Pembersihan selesai',
        'details' => [
            'duplicate_invoices_found' => $duplicates->count(),
            'deleted_duplicate_transactions' => $deletedTransactions,
            'deleted_duplicate_incomes' => $deletedIncomes
        ]
    ]);
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
    Route::get('/transactions/check-status/{orderId}', [TransactionController::class, 'checkPaymentStatus']);
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

<?php

namespace App\Services;

use App\Models\DailyClosing;
use App\Models\Income;
use App\Models\Expense;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use Exception;

class DailyClosingService
{
    /**
     * Calculate the summary of incomes and expenses for a given date.
     *
     * @param string $date The date in Y-m-d format
     * @return array
     */
    public function calculateSummary(string $date, int $userId): array
    {
        $parsedDate = Carbon::parse($date)->format('Y-m-d');

        // Ambil data transaksi hari ini milik user ini saja
        $totalSales = DB::table('transactions')
            ->where('user_id', $userId)
            ->whereDate('created_at', $parsedDate)
            ->where('status', 'completed')
            ->sum('total_amount');

        $totalTrx = DB::table('transactions')
            ->where('user_id', $userId)
            ->whereDate('created_at', $parsedDate)
            ->where('status', 'completed')
            ->count();

        $totalItems = DB::table('transaction_items')
            ->join('transactions', 'transaction_items.transaction_id', '=', 'transactions.id')
            ->where('transactions.user_id', $userId)
            ->whereDate('transactions.created_at', $parsedDate)
            ->where('transactions.status', 'completed')
            ->sum('quantity');

        $cashAmount = DB::table('transactions')
            ->where('user_id', $userId)
            ->whereDate('created_at', $parsedDate)
            ->where('payment_method', 'cash')
            ->sum('total_amount');

        $qrisAmount = DB::table('transactions')
            ->where('user_id', $userId)
            ->whereDate('created_at', $parsedDate)
            ->where('payment_method', 'qris')
            ->sum('total_amount');

        $tfAmount = DB::table('transactions')
            ->where('user_id', $userId)
            ->whereDate('created_at', $parsedDate)
            ->where('payment_method', 'transfer')
            ->sum('total_amount');

        $profit = DB::table('transaction_items')
            ->join('transactions', 'transaction_items.transaction_id', '=', 'transactions.id')
            ->join('products', 'transaction_items.product_id', '=', 'products.id')
            ->where('transactions.user_id', $userId)
            ->whereDate('transactions.created_at', $parsedDate)
            ->where('transactions.status', 'completed')
            ->sum(DB::raw('(transaction_items.selling_price - products.buying_price) * transaction_items.quantity'));

        $bestSelling = DB::table('transaction_items')
            ->join('transactions', 'transaction_items.transaction_id', '=', 'transactions.id')
            ->where('transactions.user_id', $userId)
            ->whereDate('transactions.created_at', $parsedDate)
            ->where('transactions.status', 'completed')
            ->select('transaction_items.product_name', DB::raw('SUM(transaction_items.quantity) as total_qty'))
            ->groupBy('transaction_items.product_name')
            ->orderBy('total_qty', 'desc')
            ->limit(3)
            ->get();

        return [
            'date' => $parsedDate,
            'total_sales' => (float)$totalSales,
            'total_transactions' => (int)$totalTrx,
            'total_items_sold' => (int)$totalItems,
            'cash_amount' => (float)$cashAmount,
            'qris_amount' => (float)$qrisAmount,
            'transfer_amount' => (float)$tfAmount,
            'net_profit' => (float)$profit,
            'best_selling' => $bestSelling,
        ];
    }

    public function performClosing(int $userId, string $date, float $actualCash, ?string $note = null): DailyClosing
    {
        $parsedDate = Carbon::parse($date)->format('Y-m-d');

        $existingClosing = DailyClosing::where('user_id', $userId)
            ->where('closing_date', $parsedDate)
            ->first();
        if ($existingClosing) {
            throw new Exception("Tutup buku untuk tanggal {$parsedDate} sudah dilakukan sebelumnya.");
        }

        $summary = $this->calculateSummary($parsedDate, $userId);

        // difference = uang fisik - uang tunai yang diharapkan (hanya cash, bukan QRIS/transfer)
        $difference = $actualCash - $summary['cash_amount'];

        return DailyClosing::create([
            'user_id' => $userId,
            'closing_date' => $parsedDate,
            'total_sales' => $summary['total_sales'],
            'total_transactions' => $summary['total_transactions'],
            'total_items_sold' => $summary['total_items_sold'],
            'cash_amount' => $summary['cash_amount'],
            'qris_amount' => $summary['qris_amount'],
            'transfer_amount' => $summary['transfer_amount'],
            'actual_cash' => $actualCash,
            'difference' => $difference,
            'note' => $note,
            'net_profit' => $summary['net_profit'],
        ]);
    }
}

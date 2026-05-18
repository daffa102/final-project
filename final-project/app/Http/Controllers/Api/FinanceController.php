<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Expense;
use App\Models\Income;
use App\Services\FinanceService;
use Illuminate\Http\Request;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;
use Exception;

class FinanceController extends Controller
{
    private FinanceService $financeService;

    public function __construct(FinanceService $financeService)
    {
        $this->financeService = $financeService;
    }

    public function summary(Request $request)
    {
        $userId = $request->user()->id;
        $month = $request->query('month', now()->month);
        $year = $request->query('year', now()->year);

        $revenue = DB::table('transactions')
            ->where('user_id', $userId)
            ->whereYear('created_at', $year)
            ->whereMonth('created_at', $month)
            ->where('status', 'completed')
            ->sum('total_amount');

        $grossProfit = DB::table('transaction_items')
            ->join('transactions', 'transaction_items.transaction_id', '=', 'transactions.id')
            ->join('products', 'transaction_items.product_id', '=', 'products.id')
            ->where('transactions.user_id', $userId)
            ->whereYear('transactions.created_at', $year)
            ->whereMonth('transactions.created_at', $month)
            ->where('transactions.status', 'completed')
            ->sum(DB::raw('(transaction_items.selling_price - products.buying_price) * transaction_items.quantity'));

        $otherIncome = Income::where('user_id', $userId)
            ->whereYear('income_date', $year)
            ->whereMonth('income_date', $month)
            ->sum('amount');

        $expenses = Expense::where('user_id', $userId)
            ->whereYear('expense_date', $year)
            ->whereMonth('expense_date', $month)
            ->sum('amount');

        return response()->json([
            'status' => 'success',
            'data' => [
                'revenue' => (float)$revenue,
                'gross_profit' => (float)$grossProfit,
                'other_income' => (float)$otherIncome,
                'expenses' => (float)$expenses,
                'net_profit' => (float)($grossProfit + $otherIncome - $expenses),
            ]
        ]);
    }

    public function exportPdf(Request $request)
    {
        $userId = $request->user()->id;
        $month = $request->query('month', now()->month);
        $year = $request->query('year', now()->year);
        
        // Ambil data untuk laporan sesuai user yang login
        $revenue = DB::table('transactions')
            ->where('user_id', $userId)
            ->whereYear('created_at', $year)
            ->whereMonth('created_at', $month)
            ->where('status', 'completed')
            ->sum('total_amount');

        $grossProfit = DB::table('transaction_items')
            ->join('transactions', 'transaction_items.transaction_id', '=', 'transactions.id')
            ->join('products', 'transaction_items.product_id', '=', 'products.id')
            ->where('transactions.user_id', $userId)
            ->whereYear('transactions.created_at', $year)
            ->whereMonth('transactions.created_at', $month)
            ->where('transactions.status', 'completed')
            ->sum(DB::raw('(transaction_items.selling_price - products.buying_price) * transaction_items.quantity'));

        $otherIncome = Income::where('user_id', $userId)
            ->whereYear('income_date', $year)
            ->whereMonth('income_date', $month)
            ->sum('amount');

        $expenses = Expense::where('user_id', $userId)
            ->whereYear('expense_date', $year)
            ->whereMonth('expense_date', $month)
            ->sum('amount');

        $data = [
            'month' => Carbon::createFromDate($year, $month, 1)->format('F Y'),
            'revenue' => (float)$revenue,
            'gross_profit' => (float)$grossProfit,
            'other_income' => (float)$otherIncome,
            'expenses' => (float)$expenses,
            'net_profit' => (float)($grossProfit + $otherIncome - $expenses),
            'user' => $request->user()
        ];

        $pdf = \Barryvdh\DomPDF\Facade\Pdf::loadView('pdf.finance_report', $data);
        return $pdf->stream('laporan-keuangan-'.$month.'-'.$year.'.pdf');
    }

    public function incomes(Request $request)
    {
        $incomes = Income::where('user_id', $request->user()->id)
            ->orderBy('income_date', 'desc')
            ->paginate(20);

        return response()->json([
            'status' => 'success',
            'data' => $incomes
        ]);
    }

    public function storeIncome(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'amount' => 'required|numeric|min:0',
            'income_date' => 'required|date',
            'note' => 'nullable|string'
        ]);

        try {
            $income = $this->financeService->recordIncome(
                $request->user()->id,
                $request->name,
                $request->amount,
                $request->income_date,
                $request->note
            );

            return response()->json([
                'status' => 'success',
                'message' => 'Pemasukan berhasil dicatat',
                'data' => $income
            ], 201);
        } catch (Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 422);
        }
    }

    public function expenses(Request $request)
    {
        $expenses = Expense::where('user_id', $request->user()->id)
            ->orderBy('expense_date', 'desc')
            ->paginate(20);

        return response()->json([
            'status' => 'success',
            'data' => $expenses
        ]);
    }

    public function storeExpense(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'amount' => 'required|numeric|min:0',
            'category' => 'required|in:operational,salary,purchase,other',
            'expense_date' => 'required|date',
            'note' => 'nullable|string'
        ]);

        try {
            $expense = $this->financeService->recordExpense(
                $request->user()->id,
                $request->name,
                $request->amount,
                $request->category,
                $request->expense_date,
                $request->note
            );

            return response()->json([
                'status' => 'success',
                'message' => 'Pengeluaran berhasil dicatat',
                'data' => $expense
            ], 201);
        } catch (Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 422);
        }
    }
}

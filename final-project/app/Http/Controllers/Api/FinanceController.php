<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Expense;
use App\Models\Income;
use App\Services\FinanceService;
use Illuminate\Http\Request;
use Exception;

class FinanceController extends Controller
{
    private FinanceService $financeService;

    public function __construct(FinanceService $financeService)
    {
        $this->financeService = $financeService;
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

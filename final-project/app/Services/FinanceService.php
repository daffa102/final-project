<?php

namespace App\Services;

use App\Models\Expense;
use App\Models\Income;
use Carbon\Carbon;
use Exception;

class FinanceService
{
    /**
     * Record a new manual income (outside of regular transactions)
     *
     * @param int $userId
     * @param string $name E.g., "Modal Awal", "Suntikan Dana"
     * @param float $amount
     * @param string $date format: Y-m-d
     * @param string|null $note
     * @return Income
     * @throws Exception
     */
    public function recordIncome(int $userId, string $name, float $amount, string $date, ?string $note = null): Income
    {
        if ($amount <= 0) {
            throw new Exception("Nominal pemasukan harus lebih besar dari 0.");
        }

        return Income::create([
            'user_id' => $userId,
            'name' => $name,
            'amount' => $amount,
            'income_date' => Carbon::parse($date)->format('Y-m-d'),
            'note' => $note,
        ]);
    }

    /**
     * Record a new expense
     *
     * @param int $userId
     * @param string $name E.g., "Makan siang", "Bayar Listrik"
     * @param float $amount
     * @param string $category 'operational' / 'salary' / 'purchase' / 'other'
     * @param string $date format: Y-m-d
     * @param string|null $note
     * @return Expense
     * @throws Exception
     */
    public function recordExpense(int $userId, string $name, float $amount, string $category, string $date, ?string $note = null): Expense
    {
        if ($amount <= 0) {
            throw new Exception("Nominal pengeluaran harus lebih besar dari 0.");
        }

        $validCategories = ['operational', 'salary', 'purchase', 'other'];
        if (!in_array($category, $validCategories)) {
            throw new Exception("Kategori pengeluaran tidak valid.");
        }

        return Expense::create([
            'user_id' => $userId,
            'name' => $name,
            'amount' => $amount,
            'category' => $category,
            'expense_date' => Carbon::parse($date)->format('Y-m-d'),
            'note' => $note,
        ]);
    }
}

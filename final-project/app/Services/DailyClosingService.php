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
    public function calculateSummary(string $date): array
    {
        $parsedDate = Carbon::parse($date)->format('Y-m-d');

        $totalIncome = Income::whereDate('income_date', $parsedDate)->sum('amount');
        $totalExpense = Expense::whereDate('expense_date', $parsedDate)->sum('amount');
        
        $expectedCash = $totalIncome - $totalExpense;

        return [
            'date' => $parsedDate,
            'total_income' => $totalIncome,
            'total_expense' => $totalExpense,
            'expected_cash' => $expectedCash,
        ];
    }

    /**
     * Perform the end-of-day closing process.
     * Records the actual cash in drawer and calculates any differences.
     *
     * @param int $userId The ID of the manager/employee performing closing
     * @param string $date The date of closing
     * @param float $actualCash The physical money counted in the drawer
     * @param string|null $note Any comments (e.g. excuse for difference)
     * @return DailyClosing
     * @throws Exception
     */
    public function performClosing(int $userId, string $date, float $actualCash, ?string $note = null): DailyClosing
    {
        $parsedDate = Carbon::parse($date)->format('Y-m-d');

        // Prevent double closing for the same day
        $existingClosing = DailyClosing::where('closing_date', $parsedDate)->first();
        if ($existingClosing) {
            throw new Exception("Tutup buku untuk tanggal {$parsedDate} sudah dilakukan sebelumnya.");
        }

        $summary = $this->calculateSummary($parsedDate);
        $expectedCash = $summary['expected_cash'];
        
        $difference = $actualCash - $expectedCash;

        return DailyClosing::create([
            'user_id' => $userId,
            'closing_date' => $parsedDate,
            'total_income' => $summary['total_income'],
            'total_expense' => $summary['total_expense'],
            'expected_cash' => $expectedCash,
            'actual_cash' => $actualCash,
            'difference' => $difference,
            'note' => $note,
        ]);
    }
}

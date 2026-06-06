<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Expense;
use App\Models\Income;
use App\Models\User;
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

    private function getReportData(int $userId, int $month, int $year)
    {
        // 1. Penjualan Bersih
        $revenue = DB::table('transactions')
            ->where('user_id', $userId)
            ->whereYear('created_at', $year)
            ->whereMonth('created_at', $month)
            ->where('status', 'completed')
            ->sum('total_amount');

        // 2. HPP (Harga Pokok Penjualan)
        $hpp = DB::table('transaction_items')
            ->join('transactions', 'transaction_items.transaction_id', '=', 'transactions.id')
            ->join('products', 'transaction_items.product_id', '=', 'products.id')
            ->where('transactions.user_id', $userId)
            ->whereYear('transactions.created_at', $year)
            ->whereMonth('transactions.created_at', $month)
            ->where('transactions.status', 'completed')
            ->sum(DB::raw('products.buying_price * transaction_items.quantity'));

        $grossProfit = $revenue - $hpp;

        // 3. Persediaan Akhir
        $persediaanAkhir = DB::table('products')
            ->where('user_id', $userId)
            ->sum(DB::raw('stock * buying_price'));

        // 4. Pembelian (Estimasi dari penambahan stok)
        // Kita hitung pembelian sebagai barang masuk (type = 'in')
        $pembelian = DB::table('stock_movements')
            ->join('products', 'stock_movements.product_id', '=', 'products.id')
            ->where('stock_movements.user_id', $userId)
            ->whereYear('stock_movements.created_at', $year)
            ->whereMonth('stock_movements.created_at', $month)
            ->where('stock_movements.type', 'in')
            ->sum(DB::raw('stock_movements.quantity * products.buying_price'));

        // Jika data StockMovement tidak akurat, kita koreksi Persediaan Awal secara matematis:
        // HPP = Persediaan Awal + Pembelian - Persediaan Akhir
        // Persediaan Awal = HPP + Persediaan Akhir - Pembelian
        $persediaanAwal = $hpp + $persediaanAkhir - $pembelian;
        // Mencegah nilai negatif pada laporan jika data tidak sinkron
        if ($persediaanAwal < 0) {
            $pembelian = $pembelian + abs($persediaanAwal);
            $persediaanAwal = 0;
        }

        $barangUntukDijual = $persediaanAwal + $pembelian;

        // 5. Beban (Dikelompokkan berdasarkan nama)
        $expensesQuery = DB::table('expenses')
            ->where('user_id', $userId)
            ->whereYear('expense_date', $year)
            ->whereMonth('expense_date', $month);
            
        $totalBeban = $expensesQuery->sum('amount');
        $bebanList = $expensesQuery->select('name', DB::raw('SUM(amount) as total'))
                                   ->groupBy('name')
                                   ->get();

        $laba = $grossProfit - $totalBeban;

        // 6. Perubahan Modal
        // Penambahan Modal diambil dari Pemasukan Lainnya (Income)
        $penambahanModal = DB::table('incomes')
            ->where('user_id', $userId)
            ->whereYear('income_date', $year)
            ->whereMonth('income_date', $month)
            ->sum('amount');

        // Modal Awal: akumulasi laba bersih dari bulan-bulan sebelumnya
        $modalAwal = DB::table('transactions')
            ->where('user_id', $userId)
            ->where('status', 'completed')
            ->where(function($q) use ($year, $month) {
                $q->whereYear('created_at', '<', $year)
                  ->orWhere(function($q2) use ($year, $month) {
                      $q2->whereYear('created_at', $year)
                         ->whereMonth('created_at', '<', $month);
                  });
            })
            ->sum('total_amount');

        // Kurangi HPP historis untuk mendapatkan estimasi modal dari laba
        $hppHistoris = DB::table('transaction_items')
            ->join('transactions', 'transaction_items.transaction_id', '=', 'transactions.id')
            ->join('products', 'transaction_items.product_id', '=', 'products.id')
            ->where('transactions.user_id', $userId)
            ->where('transactions.status', 'completed')
            ->where(function($q) use ($year, $month) {
                $q->whereYear('transactions.created_at', '<', $year)
                  ->orWhere(function($q2) use ($year, $month) {
                      $q2->whereYear('transactions.created_at', $year)
                         ->whereMonth('transactions.created_at', '<', $month);
                  });
            })
            ->sum(DB::raw('products.buying_price * transaction_items.quantity'));

        $modalAwal = max(0, (float)($modalAwal - $hppHistoris));
        $modalAkhir = $modalAwal + $laba + $penambahanModal;

        return [
            'month' => Carbon::createFromDate($year, $month, 1)->format('F Y'),
            'penjualan_bersih' => (float)$revenue,
            'persediaan_awal' => (float)$persediaanAwal,
            'pembelian' => (float)$pembelian,
            'barang_untuk_dijual' => (float)$barangUntukDijual,
            'persediaan_akhir' => (float)$persediaanAkhir,
            'hpp' => (float)$hpp,
            'laba_kotor' => (float)$grossProfit,
            'beban_list' => $bebanList,
            'total_beban' => (float)$totalBeban,
            'laba' => (float)$laba,
            'modal_awal' => (float)$modalAwal,
            'penambahan_modal' => (float)$penambahanModal,
            'modal_akhir' => (float)$modalAkhir,
            'user' => User::find($userId)
        ];
    }

    public function exportPdf(Request $request)
    {
        $userId = $request->user()->id;
        $month = $request->query('month', now()->month);
        $year = $request->query('year', now()->year);
        
        $data = $this->getReportData($userId, $month, $year);

        $pdf = Pdf::loadView('pdf.finance_report', $data);
        return $pdf->stream('laporan-keuangan-'.$month.'-'.$year.'.pdf');
    }

    public function exportExcel(Request $request)
    {
        $userId = $request->user()->id;
        $month = (int) $request->query('month', now()->month);
        $year  = (int) $request->query('year', now()->year);

        $data = $this->getReportData($userId, $month, $year);

        $spreadsheet = new \PhpOffice\PhpSpreadsheet\Spreadsheet();
        $sheet = $spreadsheet->getActiveSheet();
        $sheet->setTitle('Laporan Keuangan');

        // ── Header ──────────────────────────────────────────────
        $sheet->setCellValue('A1', 'LAPORAN KEUANGAN');
        $sheet->setCellValue('A2', $data['month']);
        $sheet->setCellValue('A3', 'Toko: ' . ($data['user']->name ?? '-'));
        $sheet->mergeCells('A1:C1');
        $sheet->mergeCells('A2:C2');
        $sheet->mergeCells('A3:C3');

        $boldStyle = ['font' => ['bold' => true]];
        $sheet->getStyle('A1')->applyFromArray(['font' => ['bold' => true, 'size' => 14]]);
        $sheet->getStyle('A2:A3')->applyFromArray($boldStyle);

        // ── Laba Rugi ───────────────────────────────────────────
        $row = 5;
        $sheet->setCellValue("A$row", 'LAPORAN LABA RUGI');
        $sheet->getStyle("A$row")->applyFromArray($boldStyle);
        $row++;

        $items = [
            ['Penjualan Bersih',         $data['penjualan_bersih']],
            ['HPP',                      $data['hpp']],
            ['Laba Kotor',               $data['laba_kotor']],
            ['Total Beban',              $data['total_beban']],
            ['Laba Bersih',              $data['laba']],
        ];

        foreach ($items as [$label, $value]) {
            $sheet->setCellValue("A$row", $label);
            $sheet->setCellValue("B$row", $value);
            $sheet->getStyle("B$row")->getNumberFormat()
                ->setFormatCode('"Rp "#,##0');
            $row++;
        }

        // ── Beban Detail ────────────────────────────────────────
        $row++;
        $sheet->setCellValue("A$row", 'DETAIL BEBAN');
        $sheet->getStyle("A$row")->applyFromArray($boldStyle);
        $row++;

        foreach ($data['beban_list'] as $beban) {
            $sheet->setCellValue("A$row", $beban->name);
            $sheet->setCellValue("B$row", $beban->total);
            $sheet->getStyle("B$row")->getNumberFormat()
                ->setFormatCode('"Rp "#,##0');
            $row++;
        }

        // ── Perubahan Modal ─────────────────────────────────────
        $row++;
        $sheet->setCellValue("A$row", 'PERUBAHAN MODAL');
        $sheet->getStyle("A$row")->applyFromArray($boldStyle);
        $row++;

        $modalItems = [
            ['Modal Awal',          $data['modal_awal']],
            ['Penambahan Modal',    $data['penambahan_modal']],
            ['Modal Akhir',         $data['modal_akhir']],
        ];

        foreach ($modalItems as [$label, $value]) {
            $sheet->setCellValue("A$row", $label);
            $sheet->setCellValue("B$row", $value);
            $sheet->getStyle("B$row")->getNumberFormat()
                ->setFormatCode('"Rp "#,##0');
            $row++;
        }

        // ── Auto-size kolom ────────────────────────────────────
        $sheet->getColumnDimension('A')->setWidth(30);
        $sheet->getColumnDimension('B')->setWidth(20);

        // ── Output ─────────────────────────────────────────────
        $filename = 'laporan-keuangan-' . $month . '-' . $year . '.xlsx';
        $writer = new \PhpOffice\PhpSpreadsheet\Writer\Xlsx($spreadsheet);

        $tempPath = tempnam(sys_get_temp_dir(), 'excel_');
        $writer->save($tempPath);

        return response()->download($tempPath, $filename, [
            'Content-Type' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        ])->deleteFileAfterSend(true);
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
            'category' => 'required|string|in:operational,salary,purchase,other',
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

    /**
     * Store a manual transaction (income) from Flutter app.
     * Maps to POST /finance/manual-transactions
     */
    public function storeManualTransaction(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'amount' => 'required|numeric|min:0',
            'income_date' => 'nullable|date',
            'date' => 'nullable|date',
            'note' => 'nullable|string',
        ]);

        $date = $request->input('income_date') ?? $request->input('date') ?? now()->toDateString();

        try {
            $income = $this->financeService->recordIncome(
                $request->user()->id,
                $request->name,
                $request->amount,
                $date,
                $request->note
            );

            return response()->json([
                'status' => 'success',
                'message' => 'Transaksi manual berhasil dicatat',
                'data' => $income
            ], 201);
        } catch (Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 422);
        }
    }
}

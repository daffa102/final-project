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
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Style\Alignment;
use PhpOffice\PhpSpreadsheet\Style\Border;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;

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
        $month  = (int) $request->query('month', now()->month);
        $year   = (int) $request->query('year', now()->year);
        $data   = $this->getReportData($userId, $month, $year);

        $storeName = $data['user']->store_name ?? $data['user']->name ?? 'Nama Toko';
        $rupiah       = '"Rp "#,##0';
        $rupiahBracket= '"(Rp "#,##0")"';
        $boldStyle    = ['font' => ['bold' => true]];
        $boldCenter   = ['font' => ['bold' => true], 'alignment' => ['horizontal' => Alignment::HORIZONTAL_CENTER]];
        $DOUBLE       = Border::BORDER_DOUBLE;
        $THIN         = Border::BORDER_THIN;

        // ── Sheet 1: Laba Rugi ──────────────────────────────────
        $spreadsheet = new Spreadsheet();
        $s1 = $spreadsheet->getActiveSheet()->setTitle('Laba Rugi');

        $s1->mergeCells('A1:C1'); $s1->setCellValue('A1', strtoupper($storeName));
        $s1->mergeCells('A2:C2'); $s1->setCellValue('A2', 'Laporan Laba / Rugi');
        $s1->mergeCells('A3:C3'); $s1->setCellValue('A3', 'Per ' . $data['month']);
        $s1->getStyle('A1:C3')->applyFromArray($boldCenter);
        $s1->getStyle('A1')->getFont()->setSize(13);

        $r = 5;

        // Pendapatan
        $s1->setCellValue("A$r", 'Pendapatan:'); $s1->getStyle("A$r")->applyFromArray($boldStyle); $r++;
        $s1->setCellValue("A$r", '    Penjualan Bersih');
        $s1->setCellValue("C$r", $data['penjualan_bersih']); $s1->getStyle("C$r")->getNumberFormat()->setFormatCode($rupiah); $r++; $r++;

        // HPP
        $s1->setCellValue("A$r", 'Harga Pokok Penjualan (HPP):'); $s1->getStyle("A$r")->applyFromArray($boldStyle); $r++;
        foreach ([
            ['    Persediaan Awal',              $data['persediaan_awal']],
            ['    Pembelian',                    $data['pembelian']],
            ['    Barang tersedia untuk dijual', $data['barang_untuk_dijual']],
        ] as [$lbl, $val]) {
            $s1->setCellValue("A$r", $lbl); $s1->setCellValue("B$r", $val);
            $s1->getStyle("B$r")->getNumberFormat()->setFormatCode($rupiah); $r++;
        }
        $s1->getStyle("B$r")->getBorders()->getBottom()->setBorderStyle($THIN);
        $s1->setCellValue("A$r", '    Persediaan Akhir');
        $s1->setCellValue("B$r", $data['persediaan_akhir']); $s1->getStyle("B$r")->getNumberFormat()->setFormatCode($rupiahBracket); $r++;
        $s1->setCellValue("A$r", '    Total HPP'); $s1->getStyle("A$r")->applyFromArray($boldStyle);
        $s1->setCellValue("C$r", $data['hpp']); $s1->getStyle("C$r")->getNumberFormat()->setFormatCode($rupiahBracket);
        $s1->getStyle("C$r")->getBorders()->getBottom()->setBorderStyle($THIN); $r++; $r++;

        // Laba Kotor
        $s1->setCellValue("A$r", 'Laba Kotor'); $s1->getStyle("A$r")->applyFromArray($boldStyle);
        $s1->setCellValue("C$r", $data['laba_kotor']); $s1->getStyle("C$r")->getNumberFormat()->setFormatCode($rupiah);
        $s1->getStyle("C$r")->getBorders()->getBottom()->setBorderStyle($THIN); $r++; $r++;

        // Beban
        $s1->setCellValue("A$r", 'Beban Operasional:'); $s1->getStyle("A$r")->applyFromArray($boldStyle); $r++;
        foreach ($data['beban_list'] as $beban) {
            $s1->setCellValue("A$r", '    ' . $beban->name);
            $s1->setCellValue("B$r", (float)$beban->total); $s1->getStyle("B$r")->getNumberFormat()->setFormatCode($rupiah); $r++;
        }
        if ($data['beban_list']->isEmpty()) { $s1->setCellValue("A$r", '    (Tidak ada beban)'); $r++; }
        $s1->setCellValue("A$r", '    Total Beban Operasional'); $s1->getStyle("A$r")->applyFromArray($boldStyle);
        $s1->setCellValue("C$r", $data['total_beban']); $s1->getStyle("C$r")->getNumberFormat()->setFormatCode($rupiahBracket);
        $s1->getStyle("C$r")->getBorders()->getBottom()->setBorderStyle($THIN); $r++; $r++;

        // Laba Bersih
        $s1->setCellValue("A$r", 'Laba Bersih'); $s1->getStyle("A$r")->applyFromArray($boldStyle);
        $s1->setCellValue("C$r", $data['laba']); $s1->getStyle("C$r")->getNumberFormat()->setFormatCode($rupiah);
        $s1->getStyle("C$r")->getBorders()->getBottom()->setBorderStyle($DOUBLE);
        $s1->getStyle("A$r:C$r")->applyFromArray($boldStyle);

        $s1->getColumnDimension('A')->setWidth(38);
        $s1->getColumnDimension('B')->setWidth(22);
        $s1->getColumnDimension('C')->setWidth(22);

        // ── Sheet 2: Perubahan Modal ────────────────────────────
        $s2 = $spreadsheet->createSheet()->setTitle('Perubahan Modal');
        $s2->mergeCells('A1:C1'); $s2->setCellValue('A1', strtoupper($storeName));
        $s2->mergeCells('A2:C2'); $s2->setCellValue('A2', 'Laporan Perubahan Modal');
        $s2->mergeCells('A3:C3'); $s2->setCellValue('A3', 'Per ' . $data['month']);
        $s2->getStyle('A1:C3')->applyFromArray($boldCenter);
        $s2->getStyle('A1')->getFont()->setSize(13);

        $r2 = 5;
        $s2->setCellValue("A$r2", 'Modal Awal');
        $s2->setCellValue("C$r2", $data['modal_awal']); $s2->getStyle("C$r2")->getNumberFormat()->setFormatCode($rupiah); $r2++;
        $s2->setCellValue("A$r2", 'Penambahan Modal:'); $s2->getStyle("A$r2")->applyFromArray($boldStyle); $r2++;
        $s2->setCellValue("A$r2", '    Laba Bersih');
        $s2->setCellValue("B$r2", $data['laba']); $s2->getStyle("B$r2")->getNumberFormat()->setFormatCode($rupiah); $r2++;
        $s2->getStyle("B$r2")->getBorders()->getBottom()->setBorderStyle($THIN);
        $s2->setCellValue("A$r2", '    Tambahan Modal (Pemasukan Lain)');
        $s2->setCellValue("B$r2", $data['penambahan_modal']); $s2->getStyle("B$r2")->getNumberFormat()->setFormatCode($rupiah); $r2++;
        $s2->setCellValue("A$r2", '    Total Penambahan'); $s2->getStyle("A$r2")->applyFromArray($boldStyle);
        $s2->setCellValue("C$r2", $data['laba'] + $data['penambahan_modal']);
        $s2->getStyle("C$r2")->getNumberFormat()->setFormatCode($rupiah);
        $s2->getStyle("C$r2")->getBorders()->getBottom()->setBorderStyle($THIN); $r2 += 2;
        $s2->setCellValue("A$r2", 'Modal Akhir'); $s2->getStyle("A$r2")->applyFromArray($boldStyle);
        $s2->setCellValue("C$r2", $data['modal_akhir']); $s2->getStyle("C$r2")->getNumberFormat()->setFormatCode($rupiah);
        $s2->getStyle("C$r2")->getBorders()->getBottom()->setBorderStyle($DOUBLE);
        $s2->getStyle("A$r2:C$r2")->applyFromArray($boldStyle);

        $s2->getColumnDimension('A')->setWidth(38);
        $s2->getColumnDimension('B')->setWidth(22);
        $s2->getColumnDimension('C')->setWidth(22);

        // ── Output ─────────────────────────────────────────────
        $spreadsheet->setActiveSheetIndex(0);
        $filename = 'laporan-keuangan-' . $month . '-' . $year . '.xlsx';
        $writer   = new Xlsx($spreadsheet);
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

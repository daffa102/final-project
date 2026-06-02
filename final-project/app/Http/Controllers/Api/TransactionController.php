<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use App\Services\TransactionService;
use Illuminate\Http\Request;
use Barryvdh\DomPDF\Facade\Pdf;
use Exception;

class TransactionController extends Controller
{
    private TransactionService $transactionService;

    public function __construct(TransactionService $transactionService)
    {
        $this->transactionService = $transactionService;
    }

    public function index(Request $request)
    {
        $transactions = Transaction::where('user_id', $request->user()->id)
            ->orderBy('id', 'desc')
            ->paginate(15);

        return response()->json([
            'status' => 'success',
            'data' => $transactions
        ]);
    }

    public function show(int $id, Request $request)
    {
        $transaction = Transaction::where('user_id', $request->user()->id)
            ->with('items')
            ->findOrFail($id);

        return response()->json([
            'status' => 'success',
            'data' => $transaction
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'items' => 'required|array|min:1',
            'items.*.product_id' => 'required|integer',
            'items.*.quantity' => 'required|integer|min:1',
            'payment_method' => 'required|string',
            'amount_paid' => 'required|numeric|min:0',
            'note' => 'nullable|string'
        ]);

        try {
            $transaction = $this->transactionService->processCheckout(
                $request->user()->id,
                $request->items,
                $request->payment_method,
                $request->amount_paid,
                $request->note
            );

            return response()->json([
                'status' => 'success',
                'message' => 'Transaksi berhasil diproses',
                'data' => $transaction->load('items')
            ], 201);

        } catch (Exception $e) {
            \Illuminate\Support\Facades\Log::error('Checkout Error (store): ' . $e->getMessage(), [
                'exception' => $e,
                'request' => $request->all()
            ]);
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 422);
        }
    }

    public function initiatePayment(Request $request)
    {
        $request->validate([
            'items' => 'required|array|min:1',
            'payment_method' => 'required|string',
        ]);

        try {
            $paymentData = $this->transactionService->initiateMidtransPayment(
                $request->user()->id,
                $request->items,
                $request->payment_method
            );

            return response()->json([
                'status' => 'success',
                'data' => $paymentData
            ]);
        } catch (Exception $e) {
            \Illuminate\Support\Facades\Log::error('Checkout Error (initiatePayment): ' . $e->getMessage(), [
                'exception' => $e,
                'request' => $request->all()
            ]);
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 422);
        }
    }

    public function print(int $id, Request $request)
    {
        $transaction = Transaction::where('user_id', $request->user()->id)
            ->with(['items.product', 'user'])
            ->findOrFail($id);
            
        $store = \App\Models\StoreProfile::where('user_id', $request->user()->id)->first();

        $pdf = Pdf::loadView('pdf.receipt', compact('transaction', 'store'));
        
        // Atur ukuran struk thermal (58mm atau 80mm)
        // 58mm ~ 164pt, 80mm ~ 226pt
        $pdf->setPaper([0, 0, 226, 500], 'portrait'); 

        return $pdf->stream('struk-'.$transaction->invoice_number.'.pdf');
    }
}

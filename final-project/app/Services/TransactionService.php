<?php

namespace App\Services;

use App\Models\Product;
use App\Models\Transaction;
use App\Models\TransactionItem;
use App\Models\StockMovement;
use App\Models\Income;
use Illuminate\Support\Facades\DB;
use Exception;

class TransactionService
{
    /**
     * Process a checkout transaction.
     * 
     * @param int $userId The ID of the user performing the transaction (cashier)
     * @param array $items Array of items: [['product_id' => 1, 'quantity' => 2], ...]
     * @param string $paymentMethod cash / qris / transfer
     * @param float $amountPaid The amount paid by the customer
     * @param string|null $note Optional transaction note
     * @return Transaction
     * @throws Exception
     */
    public function processCheckout(int $userId, array $items, string $paymentMethod, float $amountPaid, ?string $note = null): Transaction
    {
        if (empty($items)) {
            throw new Exception("Keranjang belanja tidak boleh kosong.");
        }

        return DB::transaction(function () use ($userId, $items, $paymentMethod, $amountPaid, $note) {
            $totalAmount = 0;
            $processedItems = [];

            // 1. Process items, check stock, calculate total amount
            $totalProfit = 0;
            foreach ($items as $item) {
                $product = Product::where('id', $item['product_id'])->lockForUpdate()->first();

                if (!$product) {
                    throw new Exception("Produk dengan ID {$item['product_id']} tidak ditemukan.");
                }

                if ($product->stock < $item['quantity']) {
                    throw new Exception("Stok tidak mencukupi untuk produk '{$product->name}'. Sisa stok: {$product->stock}");
                }

                // Use selling_price (the correct column name)
                $unitPrice = $item['selling_price'] ?? $product->selling_price;
                $subtotal  = $unitPrice * $item['quantity'];
                $totalAmount += $subtotal;
                
                // Calculate Profit
                $totalProfit += ($unitPrice - $product->buying_price) * $item['quantity'];

                $processedItems[] = [
                    'product_id'    => $product->id,
                    'product_name'  => $product->name,
                    'quantity'      => $item['quantity'],
                    'selling_price' => $unitPrice,
                    'subtotal'      => $subtotal,
                    'product_model' => $product
                ];
            }

            // 2. Validate payment
            if ($amountPaid < $totalAmount) {
                throw new Exception("Uang bayar (Rp" . number_format($amountPaid, 0, ',', '.') . ") kurang dari total belanja (Rp" . number_format($totalAmount, 0, ',', '.') . ").");
            }

            $changeAmount = $amountPaid - $totalAmount;

            // 3. Create Transaction
            $transaction = Transaction::create([
                'user_id' => $userId,
                'invoice_number' => $this->generateInvoiceNumber(),
                'total_amount' => $totalAmount,
                'profit' => $totalProfit, // Save profit!
                'payment_method' => $paymentMethod,
                'amount_paid' => $amountPaid,
                'change_amount' => $changeAmount,
                'note' => $note,
                'status' => 'completed',
            ]);

            // 4. Save Transaction Items, Reduce Stock, Log Stock Movements
            foreach ($processedItems as $pItem) {
                $product = $pItem['product_model'];
                
                // Create Transaction Item
                TransactionItem::create([
                    'transaction_id' => $transaction->id,
                    'product_id' => $pItem['product_id'],
                    'product_name' => $pItem['product_name'],
                    'quantity' => $pItem['quantity'],
                    'selling_price' => $pItem['selling_price'],
                    'subtotal' => $pItem['subtotal'],
                ]);

                // Reduce Product Stock
                $product->stock -= $pItem['quantity'];
                $product->save();

                // Log Stock Movement
                StockMovement::create([
                    'product_id' => $pItem['product_id'],
                    'user_id' => $userId,
                    'transaction_id' => $transaction->id,
                    'type' => 'out', // Sales are outgoing
                    'quantity' => $pItem['quantity'],
                    'note' => "Penjualan via Kasir: {$transaction->invoice_number}",
                ]);
            }

            // 5. Record Income automatically
            Income::create([
                'user_id' => $userId,
                'name' => "Penjualan: {$transaction->invoice_number}",
                'amount' => $totalAmount,
                'income_date' => date('Y-m-d'),
                'note' => "Metode: $paymentMethod",
            ]);

            return $transaction;
        });
    }

    /**
     * Generate unique invoice number.
     * Format: INV-YYYYMMDD-XXXX
     */
    private function generateInvoiceNumber(): string
    {
        $date = date('Ymd');
        $prefix = "INV-$date-";
        
        $lastTransaction = Transaction::where('invoice_number', 'LIKE', "$prefix%")->orderBy('id', 'desc')->first();

        if (!$lastTransaction) {
            return $prefix . '0001';
        }

        $lastNumber = intval(substr($lastTransaction->invoice_number, -4));
        $newNumber = str_pad((string)($lastNumber + 1), 4, '0', STR_PAD_LEFT);

        return $prefix . $newNumber;
    }

    /**
     * Initiate Midtrans payment for POS transaction
     */
    public function initiateMidtransPayment(int $userId, array $items, string $paymentMethod): array
    {
        $serverKey = env('MIDTRANS_SERVER_KEY');
        $isProduction = env('MIDTRANS_IS_PRODUCTION', false);
        $baseUrl = $isProduction 
            ? 'https://api.midtrans.com/v2/charge' 
            : 'https://api.sandbox.midtrans.com/v2/charge';

        $totalAmount = 0;
        foreach ($items as $item) {
            $product = Product::find($item['product_id']);
            if ($product) {
                $unitPrice = $item['selling_price'] ?? $product->selling_price;
                $totalAmount += $unitPrice * $item['quantity'];
            }
        }

        $orderId = 'TRX-' . time() . '-' . rand(100, 999);
        
        $payload = [
            'transaction_details' => [
                'order_id' => $orderId,
                'gross_amount' => (int)$totalAmount,
            ],
            'customer_details' => [
                'first_name' => 'Customer',
                'last_name' => 'POS',
            ],
        ];

        // Mapping payment method
        if ($paymentMethod === 'qris') {
            $payload['payment_type'] = 'qris';
        } elseif (str_contains($paymentMethod, '_va')) {
            $bank = explode('_', $paymentMethod)[0];
            $payload['payment_type'] = 'bank_transfer';
            $payload['bank_transfer'] = ['bank' => $bank];
        } elseif (in_array($paymentMethod, ['gopay', 'shopeepay'])) {
            $payload['payment_type'] = $paymentMethod;
        } else {
            $payload['payment_type'] = 'gopay'; // Default to gopay for e-wallets in sandbox
        }

        try {
            $response = \Illuminate\Support\Facades\Http::withBasicAuth($serverKey, '')->post($baseUrl, $payload);
            $resData = $response->json();

            if (!$response->successful()) {
                throw new Exception($resData['status_message'] ?? 'Midtrans Error');
            }

            return [
                'order_id' => $orderId,
                'gross_amount' => $totalAmount,
                'snap_token' => $resData['token'] ?? null, // If using Snap
                'redirect_url' => $resData['redirect_url'] ?? (collect($resData['actions'] ?? [])->where('name', 'deeplink-redirect')->first()['url'] ?? null),
                'qr_url' => collect($resData['actions'] ?? [])->where('name', 'generate-qr-code')->first()['url'] ?? null,
                'va_number' => $resData['va_numbers'][0]['va_number'] ?? null,
                'payment_type' => $payload['payment_type'],
            ];
        } catch (Exception $e) {
            throw new Exception("Midtrans Integration Error: " . $e->getMessage());
        }
    }
}

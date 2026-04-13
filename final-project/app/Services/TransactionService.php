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
            foreach ($items as $item) {
                // Lock the product row for update to prevent race conditions
                $product = Product::where('id', $item['product_id'])->lockForUpdate()->first();

                if (!$product) {
                    throw new Exception("Produk dengan ID {$item['product_id']} tidak ditemukan.");
                }

                if ($product->stock < $item['quantity']) {
                    throw new Exception("Stok tidak mencukupi untuk item {$product->name}. Sisa stok: {$product->stock}");
                }

                $subtotal = $product->price * $item['quantity'];
                $totalAmount += $subtotal;

                $processedItems[] = [
                    'product_id' => $product->id,
                    'product_name' => $product->name,
                    'quantity' => $item['quantity'],
                    'selling_price' => $product->price,
                    'subtotal' => $subtotal,
                    'product_model' => $product // keep instance for stock reduction
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
}

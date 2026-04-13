<?php

namespace App\Services;

use App\Models\Product;
use App\Models\StockMovement;
use Illuminate\Support\Facades\DB;
use Exception;

class StockService
{
    /**
     * Add stock to a product. (Restock)
     *
     * @param Product $product
     * @param int $quantity
     * @param int $userId
     * @param string|null $note
     * @return StockMovement
     */
    public function addStock(Product $product, int $quantity, int $userId, ?string $note = null): StockMovement
    {
        if ($quantity <= 0) {
            throw new Exception("Jumlah stok yang ditambahkan harus lebih besar dari 0.");
        }

        return DB::transaction(function () use ($product, $quantity, $userId, $note) {
            // Update product stock
            $product->stock += $quantity;
            $product->save();

            // Log movement
            return StockMovement::create([
                'product_id' => $product->id,
                'user_id' => $userId,
                'transaction_id' => null,
                'type' => 'in',
                'quantity' => $quantity,
                'note' => $note ?? 'Penambahan stok ke gudang/toko.',
            ]);
        });
    }

    /**
     * Adjust stock for non-sales reasons (e.g. damaged, lost, manual count correction)
     *
     * @param Product $product
     * @param int $quantity The amount to reduce (positive number)
     * @param int $userId
     * @param string $type The specific adjustment type (usually 'out' or 'adjustment')
     * @param string|null $note Reason for adjustment
     * @return StockMovement
     */
    public function adjustStock(Product $product, int $quantity, int $userId, string $type = 'adjustment', ?string $note = null): StockMovement
    {
        if ($quantity <= 0) {
            throw new Exception("Jumlah stok untuk penyesuaian harus lebih besar dari 0.");
        }

        return DB::transaction(function () use ($product, $quantity, $userId, $type, $note) {
            // We assume adjustments generally reduce stock relative to system count.
            // If it's a positive adjustment (found items), we should use `addStock` instead.
            
            if ($product->stock < $quantity) {
                throw new Exception("Penyesuaian gagal. Stok (sisa {$product->stock}) tidak cukup untuk dikurangi {$quantity}.");
            }

            // Update product stock
            $product->stock -= $quantity;
            $product->save();

            // Log movement
            return StockMovement::create([
                'product_id' => $product->id,
                'user_id' => $userId,
                'transaction_id' => null,
                'type' => $type,
                'quantity' => $quantity,
                'note' => $note ?? 'Penyesuaian stok manual.',
            ]);
        });
    }
}

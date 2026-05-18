<?php

namespace App\Services;

use App\Models\Product;
use App\Models\StockMovement;
use Illuminate\Support\Facades\DB;
use Exception;

class InventoryService
{
    /**
     * Add stock to a product (Stock In)
     * 
     * @param int $userId The user performing the action
     * @param int $productId
     * @param int $quantity
     * @param string|null $note Reason for adding stock (e.g., "Restock from Supplier")
     * @return Product
     */
    public function addStock(int $userId, int $productId, int $quantity, ?string $note = null): Product
    {
        if ($quantity <= 0) {
            throw new Exception("Jumlah stok masuk harus lebih dari 0.");
        }

        return DB::transaction(function () use ($userId, $productId, $quantity, $note) {
            $product = Product::findOrFail($productId);

            // Update Stock
            $product->stock += $quantity;
            $product->save();

            // Log Movement
            StockMovement::create([
                'product_id' => $product->id,
                'user_id' => $userId,
                'type' => 'in', // Incoming stock
                'quantity' => $quantity,
                'note' => $note ?? "Penambahan stok manual",
            ]);

            return $product;
        });
    }

    /**
     * Check for products with low stock (Point 11 & 18)
     */
    public function getLowStockProducts()
    {
        return Product::whereRaw('stock <= min_stock')->get();
    }
}

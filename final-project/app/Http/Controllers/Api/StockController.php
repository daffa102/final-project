<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Models\StockMovement;
use App\Services\StockService;
use Illuminate\Http\Request;
use Exception;

class StockController extends Controller
{
    private StockService $stockService;

    public function __construct(StockService $stockService)
    {
        $this->stockService = $stockService;
    }

    public function index(Request $request)
    {
        $movements = StockMovement::where('user_id', $request->user()->id)
            ->with('product:id,name,sku')
            ->orderBy('id', 'desc')
            ->paginate(20);

        return response()->json([
            'status' => 'success',
            'data' => $movements
        ]);
    }

    public function adjust(Request $request)
    {
        $request->validate([
            'product_id' => 'required|exists:products,id',
            'type' => 'required|in:in,out,adjustment',
            'quantity' => 'required|integer|min:1',
            'note' => 'nullable|string|max:255'
        ]);

        $product = Product::where('user_id', $request->user()->id)->findOrFail($request->product_id);

        try {
            $movement = null;
            if ($request->type === 'in') {
                $movement = $this->stockService->addStock(
                    $product, 
                    $request->quantity, 
                    $request->user()->id, 
                    $request->note
                );
            } else {
                $movement = $this->stockService->adjustStock(
                    $product, 
                    $request->quantity, 
                    $request->user()->id, 
                    $request->type, 
                    $request->note
                );
            }

            return response()->json([
                'status' => 'success',
                'message' => 'Stok berhasil disesuaikan',
                'data' => $movement
            ]);

        } catch (Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 422);
        }
    }
}

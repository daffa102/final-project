<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ProductController extends Controller
{
    public function index(Request $request)
    {
        $query = Product::where('user_id', $request->user()->id)->with('category');

        if ($request->has('search')) {
            $query->where('name', 'like', '%' . $request->search . '%')
                  ->orWhere('sku', 'like', '%' . $request->search . '%');
        }

        $products = $query->paginate(15);
        
        return response()->json([
            'status' => 'success',
            'data' => $products
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:150',
            'category_id' => 'nullable|exists:categories,id',
            'sku' => 'nullable|string|max:50',
            'selling_price' => 'required|numeric|min:0',
            'buying_price' => 'required|numeric|min:0',
            'stock' => 'required|integer|min:0',
            'min_stock' => 'required|integer|min:0',
            'is_active' => 'boolean',
            'image_url' => 'nullable|image|max:2048' // Assuming file upload
        ]);

        $imagePath = null;
        if ($request->hasFile('image_url')) {
            $imagePath = $request->file('image_url')->store('products', 'public');
        }

        $product = Product::create([
            'user_id' => $request->user()->id,
            'category_id' => $request->category_id,
            'name' => $request->name,
            'sku' => $request->sku,
            'selling_price' => $request->selling_price,
            'buying_price' => $request->buying_price,
            'stock' => $request->stock,
            'min_stock' => $request->min_stock,
            'is_active' => $request->is_active ?? true,
            'image_url' => $imagePath ? url('storage/'.$imagePath) : null,
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Produk berhasil ditambahkan',
            'data' => $product
        ], 201);
    }

    public function show($id, Request $request)
    {
        $product = Product::where('user_id', $request->user()->id)->with('category')->findOrFail($id);
        
        return response()->json([
            'status' => 'success',
            'data' => $product
        ]);
    }

    public function update(Request $request, $id)
    {
        $product = Product::where('user_id', $request->user()->id)->findOrFail($id);

        $request->validate([
            'name' => 'required|string|max:150',
            'category_id' => 'nullable|exists:categories,id',
            'sku' => 'nullable|string|max:50',
            'selling_price' => 'required|numeric|min:0',
            'buying_price' => 'required|numeric|min:0',
            'min_stock' => 'required|integer|min:0',
            'is_active' => 'boolean',
            'image_url' => 'nullable|image|max:2048'
        ]);

        $imagePath = $product->image_url;
        if ($request->hasFile('image_url')) {
            $path = $request->file('image_url')->store('products', 'public');
            $imagePath = url('storage/'.$path);
        }

        $product->update([
            'category_id' => $request->category_id,
            'name' => $request->name,
            'sku' => $request->sku,
            'selling_price' => $request->selling_price,
            'buying_price' => $request->buying_price,
            'min_stock' => $request->min_stock,
            'is_active' => $request->is_active ?? $product->is_active,
            'image_url' => $imagePath,
            // stock is managed via StockService, not direct update
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Produk berhasil diperbarui',
            'data' => $product
        ]);
    }

    public function destroy($id, Request $request)
    {
        $product = Product::where('user_id', $request->user()->id)->findOrFail($id);
        $product->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Produk berhasil dihapus'
        ]);
    }
}

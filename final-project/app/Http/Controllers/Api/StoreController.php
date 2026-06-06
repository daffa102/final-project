<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\StoreProfile;
use Illuminate\Http\Request;

class StoreController extends Controller
{
    public function show(Request $request)
    {
        try {
            $profile = StoreProfile::where('user_id', $request->user()->id)->first();
            
            if (!$profile) {
                $profile = StoreProfile::create([
                    'user_id'    => $request->user()->id,
                    'store_name' => 'Toko Saya',
                ]);
            }

            return response()->json([
                'status' => 'success',
                'data'   => $profile
            ]);
        } catch (\Exception $e) {
            \Illuminate\Support\Facades\Log::error('StoreController@show error: ' . $e->getMessage());
            return response()->json([
                'status'  => 'error',
                'message' => 'Gagal memuat profil toko: ' . $e->getMessage()
            ], 500);
        }
    }

    public function update(Request $request)
    {
        $request->validate([
            'store_name' => 'required|string|max:255',
            'phone_number' => 'nullable|string',
            'address' => 'nullable|string',
            'receipt_footer' => 'nullable|string',
        ]);

        $data = $request->only(['store_name', 'phone_number', 'address', 'receipt_footer', 'instagram']);

        // Handle Logo Upload
        if ($request->has('logo_bytes') && $request->has('logo_name')) {
            $bytes = $request->logo_bytes;
            $name = $request->logo_name;
            $filename = time() . '_' . $name;
            $path = 'logos/' . $filename;
            
            // If bytes is an array (from JSON), convert to string
            if (is_array($bytes)) {
                $bytes = pack('C*', ...$bytes);
            }

            \Illuminate\Support\Facades\Storage::disk('public')->put($path, $bytes);
            $data['logo_url'] = 'storage/' . $path;
        }

        // Handle QRIS Upload
        if ($request->has('qris_bytes') && $request->has('qris_name')) {
            $bytes = $request->qris_bytes;
            $name = $request->qris_name;
            $filename = time() . '_' . $name;
            $path = 'qris/' . $filename;
            
            // If bytes is an array (from JSON), convert to string
            if (is_array($bytes)) {
                $bytes = pack('C*', ...$bytes);
            }

            \Illuminate\Support\Facades\Storage::disk('public')->put($path, $bytes);
            $data['qris_url'] = 'storage/' . $path;
        }

        $profile = StoreProfile::updateOrCreate(
            ['user_id' => $request->user()->id],
            $data
        );

        return response()->json([
            'status' => 'success',
            'message' => 'Profil toko berhasil diperbarui',
            'data' => $profile
        ]);
    }
}

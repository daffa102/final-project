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
            'store_name'     => 'required|string|max:255',
            'phone_number'   => 'nullable|string',
            'address'        => 'nullable|string',
            'receipt_footer' => 'nullable|string',
        ]);

        $data = $request->only(['store_name', 'phone_number', 'address', 'receipt_footer', 'instagram']);

        // Handle Logo Upload (multipart file)
        if ($request->hasFile('logo')) {
            $file     = $request->file('logo');
            $filename = time() . '_' . $file->getClientOriginalName();
            $path     = 'logos/' . $filename;
            \Illuminate\Support\Facades\Storage::disk('public')->put($path, file_get_contents($file->getRealPath()));
            $data['logo_url'] = 'storage/' . $path;
        } elseif ($request->has('logo_bytes') && $request->has('logo_name')) {
            // Legacy raw-bytes fallback
            $bytes    = $request->logo_bytes;
            $filename = time() . '_' . $request->logo_name;
            $path     = 'logos/' . $filename;
            if (is_array($bytes)) {
                $bytes = pack('C*', ...$bytes);
            }
            \Illuminate\Support\Facades\Storage::disk('public')->put($path, $bytes);
            $data['logo_url'] = 'storage/' . $path;
        }

        // Handle QRIS Upload (multipart file)
        if ($request->hasFile('qris')) {
            $file     = $request->file('qris');
            $filename = time() . '_' . $file->getClientOriginalName();
            $path     = 'qris/' . $filename;
            \Illuminate\Support\Facades\Storage::disk('public')->put($path, file_get_contents($file->getRealPath()));
            $data['qris_url'] = 'storage/' . $path;
        } elseif ($request->has('qris_bytes') && $request->has('qris_name')) {
            // Legacy raw-bytes fallback
            $bytes    = $request->qris_bytes;
            $filename = time() . '_' . $request->qris_name;
            $path     = 'qris/' . $filename;
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
            'status'  => 'success',
            'message' => 'Profil toko berhasil diperbarui',
            'data'    => $profile
        ]);
    }
}

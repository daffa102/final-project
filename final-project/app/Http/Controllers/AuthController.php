<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $user = User::where('email', $request->email)->first();

        if (! $user) {
            return response()->json([
                'message' => 'Maaf, akun tidak terdaftar.'
            ], 404);
        }

        if (! Hash::check($request->password, $user->password)) {
            return response()->json([
                'message' => 'Kata sandi yang Anda masukkan salah.'
            ], 401);
        }

        $user->last_login_at = now();
        $user->save();

        // Revoke all tokens or use fine-grained. For now, simply issue a new token.
        $token = $user->createToken('auth-token')->plainTextToken;

        return response()->json([
            'access_token' => $token,
            'token_type' => 'Bearer',
            'user' => $user
        ]);
    }

    public function logout(Request $request)
    {
        $user = $request->user();

        // Menggunakan query builder pada relasi tokens untuk menghapus token saat ini.
        // Cara ini lebih 'linter-friendly' daripada memanggil delete() langsung pada objek token.
        $user->tokens()->where('id', $user->currentAccessToken()->id)->delete();

        return response()->json([
            'message' => 'Berhasil logout'
        ]);
    }

    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'phone' => 'required|string|max:20',
            'password' => 'required|string|min:8|confirmed',
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'phone' => $request->phone,
            'password' => Hash::make($request->password),
            'last_login_at' => now(),
        ]);

        $token = $user->createToken('auth-token')->plainTextToken;

        return response()->json([
            'access_token' => $token,
            'token_type' => 'Bearer',
            'user' => $user
        ], 201);
    }

    public function sendOtp(Request $request)
    {
        $request->validate([
            'identifier' => 'required|email', // email admin
            'method'     => 'required',        // whatsapp
            'phone'      => 'required',        // nomor wa yang diinput user
        ]);

        $user = User::where('email', $request->identifier)->first();

        if (!$user) {
            return response()->json(['message' => 'Maaf, email yang Anda masukkan tidak terdaftar.'], 404);
        }

        // Bersihkan nomor WA yang diinput (hapus non-angka, ubah 08 → 628)
        $inputPhone = preg_replace('/[^0-9]/', '', $request->phone);
        if (str_starts_with($inputPhone, '0')) {
            $inputPhone = '62' . substr($inputPhone, 1);
        }

        // Bersihkan nomor WA yang tersimpan di database
        $storedPhone = preg_replace('/[^0-9]/', '', $user->phone ?? '');
        if (str_starts_with($storedPhone, '0')) {
            $storedPhone = '62' . substr($storedPhone, 1);
        }

        // Verifikasi nomor WA cocok dengan yang tersimpan
        if (empty($storedPhone) || $inputPhone !== $storedPhone) {
            return response()->json([
                'message' => 'Nomor WhatsApp tidak sesuai dengan akun. Hubungi Admin.'
            ], 422);
        }

        // Generate 6 digit OTP dan simpan ke Cache (berlaku 10 menit)
        $otp = rand(100000, 999999);
        \Illuminate\Support\Facades\Cache::put('otp_' . $user->email, $otp, now()->addMinutes(10));

        $message = "Kode OTP Kash Anda adalah: *{$otp}*. JANGAN BERIKAN KODE INI KEPADA SIAPAPUN. Berlaku 10 menit.";

        // Kirim via Fonnte (token dari .env)
        $fonnteToken = config('app.fonnte_token', env('FONNTE_TOKEN'));

        try {
            $response = \Illuminate\Support\Facades\Http::withHeaders([
                'Authorization' => $fonnteToken
            ])->post('https://api.fonnte.com/send', [
                'target'  => $inputPhone,
                'message' => $message,
            ]);

            \Illuminate\Support\Facades\Log::info("FONNTE RESPONSE: " . $response->body());
        } catch (\Exception $e) {
            \Illuminate\Support\Facades\Log::error("GAGAL KIRIM WA: " . $e->getMessage());
        }

        return response()->json([
            'status'  => 'success',
            'message' => 'Kode OTP telah dikirim ke WhatsApp ' . $inputPhone,
        ]);
    }

    public function verifyOtp(Request $request)
    {
        $request->validate([
            'identifier' => 'required',
            'otp' => 'required'
        ]);

        $cachedOtp = \Illuminate\Support\Facades\Cache::get('otp_' . $request->identifier);

        if ($cachedOtp && $cachedOtp == $request->otp) {
            return response()->json(['message' => 'OTP Valid.']);
        }

        return response()->json(['message' => 'Kode OTP salah atau kedaluwarsa.'], 400);
    }

    public function resetPassword(Request $request)
    {
        $request->validate([
            'identifier' => 'required',
            'otp' => 'required',
            'password' => 'required|min:8|confirmed'
        ]);

        $cachedOtp = \Illuminate\Support\Facades\Cache::get('otp_' . $request->identifier);

        if (!$cachedOtp || $cachedOtp != $request->otp) {
            return response()->json(['message' => 'Sesi reset tidak valid.'], 400);
        }

        $user = User::where('email', $request->identifier)->first();
        if ($user) {
            $user->password = Hash::make($request->password);
            $user->save();
            
            \Illuminate\Support\Facades\Cache::forget('otp_' . $request->identifier);
            
            return response()->json(['message' => 'Kata sandi berhasil diperbarui.']);
        }

        return response()->json(['message' => 'User tidak ditemukan.'], 404);
    }
}

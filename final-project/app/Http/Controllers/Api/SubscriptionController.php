<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use Carbon\Carbon;

class SubscriptionController extends Controller
{
    /**
     * Charge via Core API
     */
    public function pay(Request $request)
    {
        $serverKey = env('MIDTRANS_SERVER_KEY');
        $isProduction = env('MIDTRANS_IS_PRODUCTION', false);
        $baseUrl = $isProduction 
            ? 'https://api.midtrans.com/v2/charge' 
            : 'https://api.sandbox.midtrans.com/v2/charge';

        $orderId = 'SUB-' . time() . '-' . rand(100, 999);
        $amount = (int) $request->input('amount', 50000);
        $paymentMethod = $request->input('payment_type');

        $payload = [
            'transaction_details' => [
                'order_id' => $orderId,
                'gross_amount' => $amount,
            ],
            'customer_details' => [
                'first_name' => 'Kash',
                'last_name' => 'Customer',
                'email' => 'customer@kash.id',
                'phone' => '081234567890',
            ],
        ];

        if (str_contains($paymentMethod, '_va')) {
            $bank = explode('_', $paymentMethod)[0];
            $payload['payment_type'] = 'bank_transfer';
            $payload['bank_transfer'] = ['bank' => $bank];
            
            if ($bank === 'mandiri') {
                $payload['payment_type'] = 'echannel';
                $payload['echannel'] = [
                    'bill_info1' => 'Subscription',
                    'bill_info2' => 'Kash Premium'
                ];
            }
            if ($bank === 'permata') {
                $payload['payment_type'] = 'permata';
            }
        } elseif ($paymentMethod === 'gopay') {
            $payload['payment_type'] = 'gopay';
            $payload['gopay'] = ['enable_callback' => true];
        } elseif ($paymentMethod === 'shopeepay') {
            $payload['payment_type'] = 'shopeepay';
            $payload['shopeepay'] = ['callback_url' => url('/')];
        } elseif ($paymentMethod === 'dana') {
            $payload['payment_type'] = 'gopay';
            $payload['gopay'] = ['enable_callback' => true];
        } elseif ($paymentMethod === 'qris') {
            $payload['payment_type'] = 'qris';
        }

        try {
            $response = Http::withBasicAuth($serverKey, '')->post($baseUrl, $payload);
            $resData = $response->json();

            if (!$response->successful()) {
                Log::error("Midtrans Charge Failed for $orderId:", $resData);
                return response()->json(['status' => 'error', 'message' => $resData['status_message'] ?? 'Midtrans Error'], 400);
            }

            return response()->json([
                'status' => 'success',
                'data' => [
                    'order_id' => $orderId,
                    'payment_type' => $paymentMethod,
                    'gross_amount' => $amount,
                    'va_number' => $resData['va_numbers'][0]['va_number'] ?? ($resData['permata_va_number'] ?? null),
                    'bill_key' => $resData['bill_key'] ?? null,
                    'biller_code' => $resData['biller_code'] ?? null,
                    'qr_url' => url("/api/subscriptions/qr/$orderId"),
                    'redirect_url' => collect($resData['actions'] ?? [])->where('name', 'deeplink-redirect')->first()['url'] 
                                   ?? (collect($resData['actions'] ?? [])->where('name', 'generate-qr-code')->isEmpty() 
                                       ? ($resData['actions'][0]['url'] ?? null) 
                                       : null),
                    'status_code' => $resData['status_code'],
                    'transaction_status' => $resData['transaction_status'],
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    public function checkStatus(Request $request, string $orderId)
    {
        $serverKey = env('MIDTRANS_SERVER_KEY');
        $isProduction = env('MIDTRANS_IS_PRODUCTION', false);
        $baseUrl = $isProduction 
            ? "https://api.midtrans.com/v2/$orderId/status" 
            : "https://api.sandbox.midtrans.com/v2/$orderId/status";

        try {
            $response = Http::withBasicAuth($serverKey, '')->get($baseUrl);
            $resData = $response->json();
            $status = $resData['transaction_status'] ?? 'pending';

            // Update user subscription if status is success
            if (in_array($status, ['settlement', 'capture'])) {
                $user = $request->user();
                if ($user) {
                    $currentExpiry = $user->subscription_until ? Carbon::parse($user->subscription_until) : Carbon::now();
                    
                    // If already expired, start from now. If not, add to existing.
                    if ($currentExpiry->isPast()) {
                        $currentExpiry = Carbon::now();
                    }
                    
                    $user->subscription_until = $currentExpiry->addDays(30);
                    $user->save();
                }
            }
            
            return response()->json([
                'transaction_status' => $status,
                'order_id' => $orderId,
                'subscription_until' => $user->subscription_until ?? null,
                'raw_response' => $resData
            ]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    public function proxyQr(string $orderId)
    {
        $serverKey = env('MIDTRANS_SERVER_KEY');
        $isProduction = env('MIDTRANS_IS_PRODUCTION', false);
        $baseUrl = $isProduction 
            ? "https://api.midtrans.com/v2/$orderId/status" 
            : "https://api.sandbox.midtrans.com/v2/$orderId/status";

        try {
            $statusResponse = Http::withBasicAuth($serverKey, '')->get($baseUrl);
            $resData = $statusResponse->json();
            
            $qrUrl = null;
            foreach ($resData['actions'] ?? [] as $action) {
                if (str_contains(strtolower($action['name']), 'qr')) {
                    $qrUrl = $action['url'];
                    break;
                }
            }

            if (!$qrUrl && isset($resData['transaction_id'])) {
                $txId = $resData['transaction_id'];
                $type = $resData['payment_type'] ?? 'gopay';
                $qrUrl = $isProduction 
                    ? "https://api.midtrans.com/v2/$type/$txId/qr-code"
                    : "https://api.sandbox.midtrans.com/v2/$type/$txId/qr-code";
            }

            if (!$qrUrl) abort(404, 'QR Code not found');

            $imageResponse = Http::withBasicAuth($serverKey, '')->get($qrUrl);
            return response($imageResponse->body(), 200)->header('Content-Type', 'image/png');
        } catch (\Exception $e) {
            abort(500, $e->getMessage());
        }
    }
}

<?php

// Simulation of calling the pay method in SubscriptionController
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';

use Illuminate\Support\Facades\Http;

$serverKey = "YOUR_SERVER_KEY"; // Using your provided key
$baseUrl = 'https://app.sandbox.midtrans.com/snap/v1/transactions';

echo "Testing Midtrans Connection...\n";

$payload = [
    'transaction_details' => [
        'order_id' => 'TEST-' . time(),
        'gross_amount' => 10000,
    ],
];

try {
    $response = Http::withBasicAuth($serverKey, '')
        ->post($baseUrl, $payload);

    if ($response->successful()) {
        echo "SUCCESS! Snap URL: " . $response->json('redirect_url') . "\n";
    } else {
        echo "FAILED! Error: " . $response->body() . "\n";
    }
} catch (\Exception $e) {
    echo "EXCEPTION! Message: " . $e->getMessage() . "\n";
}

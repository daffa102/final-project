<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Struk Pembayaran</title>
    <style>
        body {
            font-family: 'Courier', monospace;
            font-size: 10px;
            margin: 0;
            padding: 5px;
            color: #000;
        }
        .header {
            text-align: center;
            margin-bottom: 10px;
        }
        .header h2 {
            margin: 0;
            font-size: 14px;
        }
        .info {
            margin-bottom: 10px;
            border-bottom: 1px dashed #000;
            padding-bottom: 5px;
        }
        .items-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 10px;
        }
        .items-table th {
            text-align: left;
            border-bottom: 1px solid #000;
        }
        .items-table td {
            vertical-align: top;
            padding: 2px 0;
        }
        .total-section {
            border-top: 1px dashed #000;
            padding-top: 5px;
        }
        .row {
            display: flex;
            justify-content: space-between;
        }
        .footer {
            text-align: center;
            margin-top: 15px;
            font-size: 8px;
        }
        .text-right {
            text-align: right;
        }
    </style>
</head>
<body>
    <div class="header">
        <h2>{{ $store->store_name ?? 'UMKM POS' }}</h2>
        <div>{{ $store->address ?? ($transaction->user->name ?? 'Toko Saya') }}</div>
        @if($store->phone_number) <div>WA: {{ $store->phone_number }}</div> @endif
        <div style="font-size: 8px;">{{ now()->format('d/m/Y H:i') }}</div>
    </div>

    <div class="info">
        <div>No: {{ $transaction->invoice_number }}</div>
        <div>Kasir: {{ $transaction->user->name }}</div>
    </div>

    <table class="items-table">
        <thead>
            <tr>
                <th width="50%">Item</th>
                <th width="20%">Qty</th>
                <th width="30%" class="text-right">Total</th>
            </tr>
        </thead>
        <tbody>
            @foreach($transaction->items as $item)
            <tr>
                <td>{{ $item->product->name }}</td>
                <td>{{ $item->quantity }}</td>
                <td class="text-right">{{ number_format($item->subtotal, 0, ',', '.') }}</td>
            </tr>
            @endforeach
        </tbody>
    </table>

    <div class="total-section">
        <table width="100%">
            <tr>
                <td><strong>TOTAL</strong></td>
                <td class="text-right"><strong>{{ number_format($transaction->total_amount, 0, ',', '.') }}</strong></td>
            </tr>
            <tr>
                <td>Bayar</td>
                <td class="text-right">{{ number_format($transaction->amount_paid, 0, ',', '.') }}</td>
            </tr>
            <tr>
                <td>Kembali</td>
                <td class="text-right">{{ number_format($transaction->amount_paid - $transaction->total_amount, 0, ',', '.') }}</td>
            </tr>
        </table>
    </div>

    <div class="footer">
        --- {{ $store->receipt_footer ?? 'TERIMA KASIH' }} ---
        <br>Barang yang sudah dibeli tidak dapat ditukar/dikembalikan
    </div>
</body>
</html>

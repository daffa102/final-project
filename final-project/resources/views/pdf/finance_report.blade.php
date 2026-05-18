<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Laporan Keuangan</title>
    <style>
        body { font-family: sans-serif; font-size: 12px; }
        .header { text-align: center; margin-bottom: 30px; }
        .table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        .table th, .table td { border: 1px solid #ddd; padding: 12px; text-align: left; }
        .table th { background-color: #f2f2f2; }
        .total { font-weight: bold; font-size: 14px; background-color: #eee !important; }
        .footer { margin-top: 50px; text-align: right; }
    </style>
</head>
<body>
    <div class="header">
        <h1>LAPORAN LABA RUGI</h1>
        <h3>{{ $month }}</h3>
        <p>{{ $user->name ?? 'Toko POS' }}</p>
    </div>

    <table class="table">
        <thead>
            <tr>
                <th>Deskripsi</th>
                <th style="text-align: right;">Jumlah (Rp)</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>Pendapatan Penjualan</td>
                <td style="text-align: right;">{{ number_format($revenue, 0, ',', '.') }}</td>
            </tr>
            <tr>
                <td>Laba Kotor Penjualan</td>
                <td style="text-align: right;">{{ number_format($gross_profit, 0, ',', '.') }}</td>
            </tr>
            <tr>
                <td>Pemasukan Lainnya</td>
                <td style="text-align: right;">{{ number_format($other_income, 0, ',', '.') }}</td>
            </tr>
            <tr>
                <td>Total Pengeluaran / Biaya</td>
                <td style="text-align: right; color: red;">({{ number_format($expenses, 0, ',', '.') }})</td>
            </tr>
            <tr class="total">
                <td>ESTIMASI LABA BERSIH</td>
                @if ($net_profit >= 0)
                    <td style="text-align: right; color: #4CAF50;">
                @else
                    <td style="text-align: right; color: #F44336;">
                @endif
                    {{ number_format($net_profit, 0, ',', '.') }}
                </td>
            </tr>
        </tbody>
    </table>

    <div class="footer">
        Dicetak pada: {{ now()->format('d/m/Y H:i') }}
    </div>
</body>
</html>

<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Laporan Keuangan</title>
    <style>
        body { font-family: sans-serif; font-size: 13px; line-height: 1.6; }
        .header { text-align: center; margin-bottom: 20px; }
        .header h2, .header h3, .header p { margin: 2px; }
        .table { width: 100%; border-collapse: collapse; margin-bottom: 40px; border: 1px solid #000; }
        .table td { padding: 4px 8px; vertical-align: top; }
        .table .indent-1 { padding-left: 20px; }
        .table .indent-2 { padding-left: 40px; }
        .table .border-top { border-top: 1px solid #000; }
        .table .border-bottom { border-bottom: 1px solid #000; }
        .table .bold { font-weight: bold; }
        .table .right { text-align: right; }
        .table .center { text-align: center; }
        .title-row { font-weight: bold; background-color: #f8f8f8; }
        .footer { margin-top: 30px; text-align: center; font-size: 11px; }
    </style>
</head>
<body>
    <div class="header">
        <h2 style="text-transform: uppercase;">Laporan Laba / Rugi</h2>
        <h3>{{ $user->store_name ?? $user->name ?? 'Perusahaan Amanah' }}</h3>
        <p>Periode {{ $month }}</p>
    </div>

    <table class="table">
        <tbody>
            <!-- Penjualan Bersih -->
            <tr>
                <td>Penjualan bersih</td>
                <td></td>
                <td class="right">Rp {{ number_format($penjualan_bersih, 0, ',', '.') }}</td>
            </tr>
            
            <!-- HPP Section -->
            <tr>
                <td class="indent-1">Persediaan Awal</td>
                <td class="right">Rp {{ number_format($persediaan_awal, 0, ',', '.') }}</td>
                <td></td>
            </tr>
            <tr>
                <td class="indent-1">Pembelian</td>
                <td class="right border-bottom">Rp {{ number_format($pembelian, 0, ',', '.') }}</td>
                <td></td>
            </tr>
            <tr>
                <td class="indent-1">Barang untuk dijual</td>
                <td class="right">Rp {{ number_format($barang_untuk_dijual, 0, ',', '.') }}</td>
                <td></td>
            </tr>
            <tr>
                <td class="indent-1">Persediaan akhir</td>
                <td class="right border-bottom">(Rp {{ number_format($persediaan_akhir, 0, ',', '.') }})</td>
                <td></td>
            </tr>
            <tr>
                <td class="bold">HPP</td>
                <td></td>
                <td class="right border-bottom">(Rp {{ number_format($hpp, 0, ',', '.') }})</td>
            </tr>
            
            <!-- Laba Kotor -->
            <tr>
                <td class="bold">Laba kotor</td>
                <td></td>
                <td class="right">Rp {{ number_format($laba_kotor, 0, ',', '.') }}</td>
            </tr>

            <!-- Beban -->
            <tr>
                <td class="bold" colspan="3">Beban</td>
            </tr>
            @foreach($beban_list as $beban)
            <tr>
                <td class="indent-1">{{ $beban->name }}</td>
                <td class="right">Rp {{ number_format($beban->total, 0, ',', '.') }}</td>
                <td></td>
            </tr>
            @endforeach
            
            <tr>
                <td class="bold">Total beban</td>
                <td class="right border-top border-bottom"></td>
                <td class="right border-bottom">(Rp {{ number_format($total_beban, 0, ',', '.') }})</td>
            </tr>

            <!-- Laba Bersih -->
            <tr>
                <td class="bold">LABA</td>
                <td></td>
                <td class="right bold">Rp {{ number_format($laba, 0, ',', '.') }}</td>
            </tr>
        </tbody>
    </table>

    <div style="page-break-before: always;"></div>

    <div class="header" style="margin-top: 40px;">
        <h2 style="text-transform: uppercase;">Laporan Perubahan Modal</h2>
        <h3>{{ $user->store_name ?? $user->name ?? 'Perusahaan Amanah' }}</h3>
        <p style="text-transform: uppercase;">{{ $month }}</p>
    </div>

    <table class="table">
        <tbody>
            <tr>
                <td>Modal Awal</td>
                <td></td>
                <td class="right">Rp {{ number_format($modal_awal, 0, ',', '.') }}</td>
            </tr>
            <tr>
                <td>LABA</td>
                <td class="right">Rp {{ number_format($laba, 0, ',', '.') }}</td>
                <td></td>
            </tr>
            <tr>
                <td>Penambahan modal</td>
                <td class="right border-bottom">Rp {{ number_format($penambahan_modal, 0, ',', '.') }}</td>
                <td></td>
            </tr>
            <tr>
                <td></td>
                <td></td>
                <td class="right border-bottom">Rp {{ number_format($laba + $penambahan_modal, 0, ',', '.') }}</td>
            </tr>
            <tr>
                <td class="bold">Modal akhir</td>
                <td></td>
                <td class="right bold">Rp {{ number_format($modal_akhir, 0, ',', '.') }}</td>
            </tr>
        </tbody>
    </table>

    <div class="footer">
        Dicetak pada: {{ now()->format('d M Y H:i') }}
    </div>
</body>
</html>

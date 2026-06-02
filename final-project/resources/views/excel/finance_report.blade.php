<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
</head>
<body>
    <table>
        <tr>
            <td colspan="3" style="text-align: center; font-weight: bold; font-size: 14px;">LAPORAN LABA / RUGI</td>
        </tr>
        <tr>
            <td colspan="3" style="text-align: center; font-weight: bold;">{{ $user->store_name ?? $user->name ?? 'Perusahaan Amanah' }}</td>
        </tr>
        <tr>
            <td colspan="3" style="text-align: center;">Periode {{ $month }}</td>
        </tr>
        <tr><td colspan="3"></td></tr>

        <!-- Penjualan Bersih -->
        <tr>
            <td>Penjualan bersih</td>
            <td></td>
            <td>{{ $penjualan_bersih }}</td>
        </tr>
        
        <!-- HPP Section -->
        <tr>
            <td>    Persediaan Awal</td>
            <td>{{ $persediaan_awal }}</td>
            <td></td>
        </tr>
        <tr>
            <td>    Pembelian</td>
            <td>{{ $pembelian }}</td>
            <td></td>
        </tr>
        <tr>
            <td>    Barang untuk dijual</td>
            <td>{{ $barang_untuk_dijual }}</td>
            <td></td>
        </tr>
        <tr>
            <td>    Persediaan akhir</td>
            <td>-{{ $persediaan_akhir }}</td>
            <td></td>
        </tr>
        <tr>
            <td style="font-weight: bold;">HPP</td>
            <td></td>
            <td>-{{ $hpp }}</td>
        </tr>
        
        <!-- Laba Kotor -->
        <tr>
            <td style="font-weight: bold;">Laba kotor</td>
            <td></td>
            <td>{{ $laba_kotor }}</td>
        </tr>

        <tr><td colspan="3"></td></tr>

        <!-- Beban -->
        <tr>
            <td style="font-weight: bold;" colspan="3">Beban</td>
        </tr>
        @foreach($beban_list as $beban)
        <tr>
            <td>    {{ $beban->name }}</td>
            <td>{{ $beban->total }}</td>
            <td></td>
        </tr>
        @endforeach
        
        <tr>
            <td style="font-weight: bold;">Total beban</td>
            <td></td>
            <td>-{{ $total_beban }}</td>
        </tr>

        <tr><td colspan="3"></td></tr>

        <!-- Laba Bersih -->
        <tr>
            <td style="font-weight: bold;">LABA</td>
            <td></td>
            <td style="font-weight: bold;">{{ $laba }}</td>
        </tr>
        
        <tr><td colspan="3"></td></tr>
        <tr><td colspan="3"></td></tr>

        <tr>
            <td colspan="3" style="text-align: center; font-weight: bold; font-size: 14px;">LAPORAN PERUBAHAN MODAL</td>
        </tr>
        <tr>
            <td colspan="3" style="text-align: center; font-weight: bold;">{{ $user->store_name ?? $user->name ?? 'Perusahaan Amanah' }}</td>
        </tr>
        <tr>
            <td colspan="3" style="text-align: center;">{{ strtoupper($month) }}</td>
        </tr>
        <tr><td colspan="3"></td></tr>

        <tr>
            <td>Modal Awal</td>
            <td></td>
            <td>{{ $modal_awal }}</td>
        </tr>
        <tr>
            <td>LABA</td>
            <td>{{ $laba }}</td>
            <td></td>
        </tr>
        <tr>
            <td>Penambahan modal</td>
            <td>{{ $penambahan_modal }}</td>
            <td></td>
        </tr>
        <tr>
            <td></td>
            <td></td>
            <td>{{ $laba + $penambahan_modal }}</td>
        </tr>
        <tr>
            <td style="font-weight: bold;">Modal akhir</td>
            <td></td>
            <td style="font-weight: bold;">{{ $modal_akhir }}</td>
        </tr>

    </table>
</body>
</html>

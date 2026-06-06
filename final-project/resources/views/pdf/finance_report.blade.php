<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Laporan Keuangan</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Times New Roman', Times, serif;
            font-size: 12px;
            color: #000;
            padding: 40px 50px;
            line-height: 1.5;
        }

        /* ── HEADER ─────────────────────────────────── */
        .header {
            text-align: center;
            margin-bottom: 28px;
        }
        .header .store-name {
            font-size: 15px;
            font-weight: bold;
            text-transform: uppercase;
        }
        .header .report-title {
            font-size: 13px;
            font-weight: bold;
        }
        .header .period {
            font-size: 13px;
            font-weight: bold;
        }

        /* ── LAPORAN TABLE ───────────────────────────── */
        .report {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 32px;
        }
        .report td {
            padding: 3px 4px;
            vertical-align: bottom;
        }
        /* Kolom: label (40%), kolom nilai item (30%), kolom total (30%) */
        .col-label  { width: 45%; }
        .col-item   { width: 27%; text-align: right; }
        .col-total  { width: 28%; text-align: right; }

        .indent     { padding-left: 28px !important; }
        .indent2    { padding-left: 52px !important; }

        .bold       { font-weight: bold; }
        .italic     { font-style: italic; }
        .center     { text-align: center; }

        /* Garis bawah tunggal */
        .border-bottom-single td { border-bottom: 1px solid #000; }

        /* Garis bawah ganda (untuk laba bersih) */
        .double-line td { 
            border-bottom: 3px double #000;
            padding-bottom: 2px;
        }

        /* Baris separator kosong */
        .spacer td { padding-top: 8px; }

        /* Baris section header */
        .section-header td {
            font-weight: bold;
            padding-top: 10px;
        }

        /* ── FOOTER ──────────────────────────────────── */
        .footer {
            margin-top: 40px;
            font-size: 10px;
            color: #555;
            text-align: right;
        }
    </style>
</head>
<body>

    {{-- ═══════════════════════════════════════════════ --}}
    {{-- HEADER                                         --}}
    {{-- ═══════════════════════════════════════════════ --}}
    <div class="header">
        <div class="store-name">{{ $user->store_name ?? $user->name ?? 'Nama Toko' }}</div>
        <div class="report-title">Laporan Laba / Rugi</div>
        <div class="period">Per {{ $month }}</div>
    </div>

    {{-- ═══════════════════════════════════════════════ --}}
    {{-- LAPORAN LABA RUGI                              --}}
    {{-- ═══════════════════════════════════════════════ --}}
    <table class="report">
        <col class="col-label">
        <col class="col-item">
        <col class="col-total">
        <tbody>

            {{-- ── PENDAPATAN ── --}}
            <tr class="section-header">
                <td>Pendapatan:</td>
                <td></td>
                <td></td>
            </tr>
            <tr>
                <td class="indent">Penjualan bersih</td>
                <td></td>
                <td>Rp {{ number_format($penjualan_bersih, 0, ',', '.') }}</td>
            </tr>

            {{-- ── HPP ── --}}
            <tr class="spacer section-header">
                <td>Harga Pokok Penjualan (HPP):</td>
                <td></td>
                <td></td>
            </tr>
            <tr>
                <td class="indent">Persediaan Awal</td>
                <td>Rp {{ number_format($persediaan_awal, 0, ',', '.') }}</td>
                <td></td>
            </tr>
            <tr>
                <td class="indent">Pembelian</td>
                <td>Rp {{ number_format($pembelian, 0, ',', '.') }}</td>
                <td></td>
            </tr>
            <tr>
                <td class="indent">Barang tersedia untuk dijual</td>
                <td>Rp {{ number_format($barang_untuk_dijual, 0, ',', '.') }}</td>
                <td></td>
            </tr>
            <tr class="border-bottom-single">
                <td class="indent">Persediaan Akhir</td>
                <td>(Rp {{ number_format($persediaan_akhir, 0, ',', '.') }})</td>
                <td></td>
            </tr>
            <tr>
                <td class="indent bold">Total HPP</td>
                <td></td>
                <td>(Rp {{ number_format($hpp, 0, ',', '.') }})</td>
            </tr>

            {{-- ── LABA KOTOR ── --}}
            <tr class="spacer border-bottom-single">
                <td class="bold">Laba Kotor</td>
                <td></td>
                <td>Rp {{ number_format($laba_kotor, 0, ',', '.') }}</td>
            </tr>

            {{-- ── BEBAN OPERASIONAL ── --}}
            <tr class="spacer section-header">
                <td>Beban Operasional:</td>
                <td></td>
                <td></td>
            </tr>

            @foreach($beban_list as $beban)
            <tr>
                <td class="indent">{{ $beban->name }}</td>
                <td>Rp {{ number_format($beban->total, 0, ',', '.') }}</td>
                <td></td>
            </tr>
            @endforeach

            @if($beban_list->isEmpty())
            <tr>
                <td class="indent italic" style="color:#888">Tidak ada beban tercatat</td>
                <td></td>
                <td></td>
            </tr>
            @endif

            <tr class="border-bottom-single">
                <td class="indent bold">Total Beban Operasional</td>
                <td></td>
                <td>(Rp {{ number_format($total_beban, 0, ',', '.') }})</td>
            </tr>

            {{-- ── LABA BERSIH ── --}}
            <tr class="spacer">
                <td></td><td></td><td></td>
            </tr>
            <tr class="double-line">
                <td class="bold">Laba Bersih</td>
                <td></td>
                <td class="bold">Rp {{ number_format($laba, 0, ',', '.') }}</td>
            </tr>

        </tbody>
    </table>

    {{-- ═══════════════════════════════════════════════ --}}
    {{-- LAPORAN PERUBAHAN MODAL (halaman baru)         --}}
    {{-- ═══════════════════════════════════════════════ --}}
    <div style="page-break-before: always; padding-top: 40px;">

        <div class="header">
            <div class="store-name">{{ $user->store_name ?? $user->name ?? 'Nama Toko' }}</div>
            <div class="report-title">Laporan Perubahan Modal</div>
            <div class="period">Per {{ $month }}</div>
        </div>

        <table class="report">
            <col class="col-label">
            <col class="col-item">
            <col class="col-total">
            <tbody>
                <tr>
                    <td>Modal Awal</td>
                    <td></td>
                    <td>Rp {{ number_format($modal_awal, 0, ',', '.') }}</td>
                </tr>
                <tr class="section-header">
                    <td>Penambahan Modal:</td>
                    <td></td>
                    <td></td>
                </tr>
                <tr>
                    <td class="indent">Laba Bersih</td>
                    <td>Rp {{ number_format($laba, 0, ',', '.') }}</td>
                    <td></td>
                </tr>
                <tr class="border-bottom-single">
                    <td class="indent">Tambahan Modal (Pemasukan Lain)</td>
                    <td>Rp {{ number_format($penambahan_modal, 0, ',', '.') }}</td>
                    <td></td>
                </tr>
                <tr>
                    <td class="indent bold">Total Penambahan</td>
                    <td></td>
                    <td>Rp {{ number_format($laba + $penambahan_modal, 0, ',', '.') }}</td>
                </tr>
                <tr class="spacer">
                    <td></td><td></td><td></td>
                </tr>
                <tr class="double-line">
                    <td class="bold">Modal Akhir</td>
                    <td></td>
                    <td class="bold">Rp {{ number_format($modal_akhir, 0, ',', '.') }}</td>
                </tr>
            </tbody>
        </table>

    </div>

    <div class="footer">
        Dicetak pada: {{ now()->setTimezone('Asia/Jakarta')->format('d M Y, H:i') }} WIB
    </div>

</body>
</html>

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/closing_provider.dart';

class DailyClosingScreen extends StatefulWidget {
  const DailyClosingScreen({super.key});

  @override
  State<DailyClosingScreen> createState() => _DailyClosingScreenState();
}

class _DailyClosingScreenState extends State<DailyClosingScreen> {
  final NumberFormat currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
  final TextEditingController _actualCashController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClosingProvider>().fetchExpectedCash();
    });
  }

  void _handleSubmit() async {
    final provider = context.read<ClosingProvider>();
    final notes = _notesController.text;
    provider.setNotes(notes);

    final success = await provider.submitDailyClosing(1); // Kasir Aktif

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Tutup Kasir Berhasil! Sistem direstart ke mode awal.'),
        backgroundColor: Colors.green,
      ));
      Navigator.pop(context); // Kembali ke POS Main Layar
    } else if (mounted) {
      showDialog(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Ops!'),
          content: Text(provider.error ?? 'Gagal menghubungi server pusat'),
          actions: [
             TextButton(onPressed: () => Navigator.pop(c), child: const Text('OK'))
          ],
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Daily Closing / Tutup Kasir', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Consumer<ClosingProvider>(
            builder: (context, provider, child) {
              final theme = Theme.of(context);
              final isDark = theme.brightness == Brightness.dark;
              
              if (provider.isLoading && provider.expectedCash == 0) {
                 return const CircularProgressIndicator();
              }

              final isSurplus = provider.difference >= 0;

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: SizedBox(
                    width: 400,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(Icons.account_balance_wallet, size: 64, color: Colors.blueGrey),
                        const SizedBox(height: 16),
                        const Text(
                          'Rekonsiliasi Shift',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const Divider(height: 48),

                        // Detail Akumulasi
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Column(
                            children: [
                              _buildSummaryRow('Total Penjualan', provider.totalSales, isDark, isBold: true),
                              const Divider(),
                              _buildSummaryRow('Tunai (Expected)', provider.expectedCash, isDark),
                              _buildSummaryRow('QRIS', provider.qrisAmount, isDark),
                              _buildSummaryRow('Transfer', provider.transferAmount, isDark),
                              const Divider(),
                              _buildSummaryRow('Total Transaksi', provider.totalTrx.toDouble(), isDark, isCurrency: false),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Input Uang Laci Faktual
                        TextField(
                          controller: _actualCashController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                          decoration: InputDecoration(
                            labelText: 'Uang Fisik di Laci (Tunai)',
                            labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                            prefixText: 'Rp ',
                            filled: true,
                            fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.blueGrey.shade50,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                          ),
                          onChanged: (val) {
                            final double parsed = double.tryParse(val.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
                            provider.setActualCash(parsed);
                          },
                        ),
                        const SizedBox(height: 24),

                        // Kesimpulan Selisih
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSurplus ? Colors.green.shade50 : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isSurplus ? Colors.green : Colors.red)
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Selisih:', style: TextStyle(fontSize: 16, color: isSurplus ? Colors.green : Colors.red)),
                              Text(
                                currencyFormat.format(provider.difference),
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isSurplus ? Colors.green : Colors.red)
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Optional Catatan
                        TextField(
                          controller: _notesController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Catatan Penutup (Opsional)',
                            border: OutlineInputBorder(),
                            hintText: 'Misal: Beli pulsa, uang kertas hilang 1000'
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Tombol Submit
                        SizedBox(
                          height: 50,
                          child: ElevatedButton.icon(
                            icon: provider.isLoading 
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                                : const Icon(Icons.cloud_upload),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                            ),
                            label: const Text('SUBMIT TUTUP KASIR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            onPressed: provider.isLoading ? null : _handleSubmit,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, bool isDark, {bool isBold = false, bool isCurrency = true}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14.sp)),
          Text(
            isCurrency ? currencyFormat.format(value) : value.toInt().toString(),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 16.sp,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

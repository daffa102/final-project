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
  final NumberFormat currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClosingProvider>().fetchExpectedCash();
    });
  }

  void _showSubmitDialog() {
    final provider = context.read<ClosingProvider>();
    final actualCashController = TextEditingController(text: provider.expectedCash.toStringAsFixed(0));
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E2532),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Text('Konfirmasi Tutup Toko', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: actualCashController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Uang Fisik di Laci (Tunai)',
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(12.r)),
                  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFBEF364)), borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: notesController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Catatan (Opsional)',
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(12.r)),
                  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFBEF364)), borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBEF364),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r))
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);
                final double parsed = double.tryParse(actualCashController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
                provider.setActualCash(parsed);
                provider.setNotes(notesController.text);
                
                final success = await provider.submitDailyClosing(1); // Kasir Aktif

                if (!mounted) return;

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Tutup Kasir Berhasil! Sistem direstart ke mode awal.'),
                    backgroundColor: Colors.green,
                  ));
                  Navigator.pop(context); // Kembali ke POS Main Layar
                } else {
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
              },
              child: const Text('Submit', style: TextStyle(color: Color(0xFF111727), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111727) : const Color(0xFFF9FBFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
        title: Text(
          'Tutup Kasir',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Icon(Icons.account_circle_outlined, color: isDark ? Colors.white : Colors.black87, size: 32),
          ),
        ],
      ),
      body: Consumer<ClosingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.expectedCash == 0 && provider.totalSales == 0) {
             return const Center(child: CircularProgressIndicator(color: Color(0xFFBEF364)));
          }

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Income Card
                Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFFBEF364) : const Color(0xFF4D7B1C),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Pendapatan',
                        style: TextStyle(
                          color: isDark ? const Color(0xFF111727).withValues(alpha: 0.7) : Colors.white70,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        currencyFormat.format(provider.totalSales),
                        style: TextStyle(
                          color: isDark ? const Color(0xFF111727) : Colors.white,
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF4D7B1C) : const Color(0xFF3F6117),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          '${provider.totalTrx} Transaksi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // Lists
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildSection(
                          title: 'Metode Pembayaran',
                          isDark: isDark,
                          items: [
                            _buildRow('Tunai', currencyFormat.format(provider.expectedCash), isDark: isDark, isCurrency: true),
                            _buildRow('Qris', currencyFormat.format(provider.qrisAmount), isDark: isDark, isCurrency: true),
                            _buildRow('Transfer', currencyFormat.format(provider.transferAmount), isDark: isDark, isCurrency: true),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        _buildSection(
                          title: 'Produk Terlaris Hari Ini',
                          isDark: isDark,
                          items: provider.bestSelling.isEmpty
                              ? [
                                  Padding(
                                    padding: EdgeInsets.all(16.w),
                                    child: Center(
                                      child: Text(
                                        'Belum ada data penjualan',
                                        style: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.6) : Colors.black45, fontSize: 13.sp),
                                      ),
                                    ),
                                  )
                                ]
                              : provider.bestSelling.map((p) {
                                  return _buildRow(p['product_name'], '${p['total_qty']} pcs', isDark: isDark);
                                }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),

                // Button
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  height: 60.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4D7B1C), // Deep green to match light mode primary
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    onPressed: _showSubmitDialog,
                    child: Text(
                      'Proses Tutup Kasir',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({required String title, required bool isDark, required List<Widget> items}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF232A3B) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(
              title,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildRow(String title, String value, {bool isCurrency = false, required bool isDark}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black54,
              fontSize: 14.sp,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isDark ? const Color(0xFFBEF364) : const Color(0xFF4D7B1C),
              fontSize: 14.sp,
              fontWeight: isCurrency ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

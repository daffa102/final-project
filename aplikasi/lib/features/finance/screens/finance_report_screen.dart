import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart' as dio;
import 'package:printing/printing.dart';
import '../../pos/providers/pos_provider.dart';
import '../providers/finance_provider.dart';
import '../../../core/utils/file_downloader.dart';

class FinanceReportScreen extends StatefulWidget {
  const FinanceReportScreen({super.key});

  @override
  State<FinanceReportScreen> createState() => _FinanceReportScreenState();
}

class _FinanceReportScreenState extends State<FinanceReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FinanceProvider>().fetchFinanceSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    final summary = finance.summary;
    String fmt(dynamic val) => currencyFormat.format(double.tryParse(val?.toString() ?? '0') ?? 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Laba Rugi', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.table_view_rounded, color: Colors.green),
            tooltip: 'Ekspor Excel',
            onPressed: () => _exportExcel(context),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
            tooltip: 'Ekspor PDF',
            onPressed: () => _exportPdf(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => finance.fetchFinanceSummary(),
          )
        ],
      ),
      body: finance.isLoading 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: () => finance.fetchFinanceSummary(),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bulan Ini', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.grey)),
                  SizedBox(height: 16.h),
                  
                  // Primary Summary Card
                  _buildSummaryCard(
                    'Laba Bersih', 
                    fmt(summary['net_profit']), 
                    Colors.indigo,
                    Icons.account_balance_rounded,
                    isMain: true
                  ),
                  SizedBox(height: 20.h),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Pendapatan', 
                          fmt(summary['revenue']), 
                          Colors.green,
                          Icons.trending_up
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildSummaryCard(
                          'Pengeluaran', 
                          fmt(summary['expenses']), 
                          Colors.red,
                          Icons.trending_down
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  
                  SizedBox(height: 24.h),
                  
                  const Text('Perbandingan Kas', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 16.h),
                  Container(
                    height: 200.h,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 0,
                              centerSpaceRadius: 40.r,
                              sections: [
                                PieChartSectionData(
                                  color: Colors.green,
                                  value: summary['revenue'] == 0 ? 1 : (summary['revenue'] as num).toDouble(),
                                  title: '',
                                  radius: 20.r,
                                ),
                                PieChartSectionData(
                                  color: Colors.red,
                                  value: summary['expenses'] == 0 ? 0.1 : (summary['expenses'] as num).toDouble(),
                                  title: '',
                                  radius: 20.r,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLegendItem(Colors.green, 'Kas Masuk'),
                              SizedBox(height: 8.h),
                              _buildLegendItem(Colors.red, 'Kas Keluar'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  
                  const Text('Detail Keuangan', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 12.h),
                  _buildDetailRow('Laba Kotor (Produk)', fmt(summary['gross_profit'])),
                  _buildDetailRow('Pemasukan Lainnya', fmt(summary['other_income'])),
                  const Divider(),
                  _buildDetailRow('Total Pengeluaran', fmt(summary['expenses']), isNegative: true),
                  SizedBox(height: 20.h),
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.amber.shade200)
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.amber),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'Laba Bersih dihitung dari: (Laba Kotor Produk + Pemasukan Lain) - Total Pengeluaran.',
                            style: TextStyle(fontSize: 12.sp, color: Colors.amber.shade900),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
    );
  }

  Future<void> _exportPdf(BuildContext context) async {
    final posProvider = context.read<PosProvider>();
    final apiService = posProvider.apiService;
    final now = DateTime.now();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    scaffoldMessenger.showSnackBar(
      const SnackBar(content: Text('Menyiapkan dokumen PDF...'), behavior: SnackBarBehavior.floating),
    );

    try {
      final response = await apiService.client.get(
        '/finance/export',
        queryParameters: {
          'month': now.month,
          'year': now.year,
        },
        options: dio.Options(responseType: dio.ResponseType.bytes),
      );

      await Printing.layoutPdf(
        onLayout: (_) => response.data,
        name: 'Laporan-Laba-Rugi-${now.year}-${now.month}.pdf',
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Gagal memuat PDF: $e'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _exportExcel(BuildContext context) async {
    final posProvider = context.read<PosProvider>();
    final apiService = posProvider.apiService;
    final now = DateTime.now();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    scaffoldMessenger.showSnackBar(
      const SnackBar(content: Text('Menyiapkan dokumen Excel...'), behavior: SnackBarBehavior.floating),
    );

    try {
      final response = await apiService.client.get(
        '/finance/export/excel',
        queryParameters: {
          'month': now.month,
          'year': now.year,
        },
        options: dio.Options(responseType: dio.ResponseType.bytes),
      );

      final bytes = response.data as List<int>;
      final fileName = 'Laporan-Laba-Rugi-${now.year}-${now.month}.xlsx';
      
      await downloadFile(
        bytes,
        fileName,
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Gagal memuat Excel: $e'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 12.r, height: 12.r, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        SizedBox(width: 8.w),
        Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700)),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color, IconData icon, {bool isMain = false}) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: isMain ? color : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))
        ],
        border: isMain ? null : Border.all(color: Colors.grey.shade100)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: isMain ? Colors.white.withValues(alpha: 0.7) : color, size: 24.r),
          SizedBox(height: 12.h),
          Text(title, style: TextStyle(color: isMain ? Colors.white.withValues(alpha: 0.8) : Colors.grey, fontSize: 13.sp)),
          SizedBox(height: 4.h),
          Text(value, style: TextStyle(color: isMain ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: isMain ? 22.sp : 16.sp)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isNegative = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(
            isNegative ? '- $value' : value, 
            style: TextStyle(fontWeight: FontWeight.w600, color: isNegative ? Colors.red : Colors.black87)
          ),
        ],
      ),
    );
  }
}

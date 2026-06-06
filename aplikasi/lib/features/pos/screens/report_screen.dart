import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart' as dio;
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import '../providers/pos_provider.dart';
import '../../../core/api/api_service.dart';
import '../../closing/screens/daily_closing_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../../core/utils/file_downloader.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String _selectedTab = 'Bulanan';
  DateTime _selectedDate = DateTime.now();
  final NumberFormat currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  final Map<int, String> indonesianMonths = {
    1: 'Januari', 2: 'Februari', 3: 'Maret', 4: 'April', 5: 'Mei', 6: 'Juni',
    7: 'Juli', 8: 'Agustus', 9: 'September', 10: 'Oktober', 11: 'November', 12: 'Desember'
  };

  String _getPeriodText() {
    if (_selectedTab == 'Harian') {
      return '${_selectedDate.day} ${indonesianMonths[_selectedDate.month]} ${_selectedDate.year}';
    } else if (_selectedTab == 'Bulanan') {
      return '${indonesianMonths[_selectedDate.month]} ${_selectedDate.year}';
    } else {
      return '${_selectedDate.year}';
    }
  }

  bool _isSamePeriod(DateTime dt) {
    if (_selectedTab == 'Harian') {
      return dt.year == _selectedDate.year &&
             dt.month == _selectedDate.month &&
             dt.day == _selectedDate.day;
    } else if (_selectedTab == 'Bulanan') {
      return dt.year == _selectedDate.year &&
             dt.month == _selectedDate.month;
    } else {
      return dt.year == _selectedDate.year;
    }
  }

  void _navigatePeriod(int direction) {
    setState(() {
      if (_selectedTab == 'Harian') {
        _selectedDate = _selectedDate.add(Duration(days: direction));
      } else if (_selectedTab == 'Bulanan') {
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + direction, 1);
      } else {
        _selectedDate = DateTime(_selectedDate.year + direction, 1, 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pos = context.watch<PosProvider>();

    // Current period calculations
    final filteredTransactions = pos.transactions.where((t) {
      final dateStr = t['created_at'];
      if (dateStr == null) return false;
      final dt = DateTime.tryParse(dateStr);
      if (dt == null) return false;
      return _isSamePeriod(dt);
    }).toList();

    final filteredManual = pos.manualTransactions.where((t) {
      final dateStr = t['created_at'];
      if (dateStr == null) return false;
      final dt = DateTime.tryParse(dateStr);
      if (dt == null) return false;
      return _isSamePeriod(dt);
    }).toList();

    double totalRevenue = filteredTransactions.fold(0.0, (sum, trx) => sum + (double.tryParse(trx['total_amount']?.toString() ?? '0') ?? 0));
    double totalGrossProfit = filteredTransactions.fold(0.0, (sum, trx) => sum + (double.tryParse(trx['profit']?.toString() ?? '0') ?? 0));
    double cogs = totalRevenue - totalGrossProfit;

    double otherIncome = filteredManual
        .where((t) => t['type'] == 'income')
        .fold(0.0, (sum, t) => sum + (double.tryParse(t['amount']?.toString() ?? '0') ?? 0));

    double otherExpenses = filteredManual
        .where((t) => t['type'] == 'expense')
        .fold(0.0, (sum, t) => sum + (double.tryParse(t['amount']?.toString() ?? '0') ?? 0));

    double totalIncome = totalRevenue + otherIncome;
    double totalExpense = cogs + otherExpenses;
    double netProfit = totalIncome - totalExpense;

    // Previous period calculations
    DateTime prevDate;
    if (_selectedTab == 'Harian') {
      prevDate = _selectedDate.subtract(const Duration(days: 1));
    } else if (_selectedTab == 'Bulanan') {
      prevDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
    } else {
      prevDate = DateTime(_selectedDate.year - 1, 1, 1);
    }

    bool isSamePrevPeriod(DateTime dt) {
      if (_selectedTab == 'Harian') {
        return dt.year == prevDate.year && dt.month == prevDate.month && dt.day == prevDate.day;
      } else if (_selectedTab == 'Bulanan') {
        return dt.year == prevDate.year && dt.month == prevDate.month;
      } else {
        return dt.year == prevDate.year;
      }
    }

    final prevTransactions = pos.transactions.where((t) {
      final dateStr = t['created_at'];
      if (dateStr == null) return false;
      final dt = DateTime.tryParse(dateStr);
      if (dt == null) return false;
      return isSamePrevPeriod(dt);
    }).toList();

    final prevManual = pos.manualTransactions.where((t) {
      final dateStr = t['created_at'];
      if (dateStr == null) return false;
      final dt = DateTime.tryParse(dateStr);
      if (dt == null) return false;
      return isSamePrevPeriod(dt);
    }).toList();

    double prevRevenue = prevTransactions.fold(0.0, (sum, trx) => sum + (double.tryParse(trx['total_amount']?.toString() ?? '0') ?? 0));
    double prevGrossProfit = prevTransactions.fold(0.0, (sum, trx) => sum + (double.tryParse(trx['profit']?.toString() ?? '0') ?? 0));
    double prevCogs = prevRevenue - prevGrossProfit;

    double prevOtherIncome = prevManual
        .where((t) => t['type'] == 'income')
        .fold(0.0, (sum, t) => sum + (double.tryParse(t['amount']?.toString() ?? '0') ?? 0));

    double prevOtherExpenses = prevManual
        .where((t) => t['type'] == 'expense')
        .fold(0.0, (sum, t) => sum + (double.tryParse(t['amount']?.toString() ?? '0') ?? 0));

    double prevTotalIncome = prevRevenue + prevOtherIncome;
    double prevTotalExpense = prevCogs + prevOtherExpenses;
    double prevNetProfit = prevTotalIncome - prevTotalExpense;

    String percentageChangeText = '';
    if (prevNetProfit == 0) {
      percentageChangeText = '0% dari periode lalu';
    } else {
      double percent = ((netProfit - prevNetProfit) / prevNetProfit.abs()) * 100;
      String prefix = percent >= 0 ? '+' : '';
      String periodLabel = _selectedTab == 'Harian' ? 'kemarin' : (_selectedTab == 'Bulanan' ? 'bulan lalu' : 'tahun lalu');
      percentageChangeText = '$prefix${percent.toStringAsFixed(0)}% dari $periodLabel';
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111727) : const Color(0xFFF9FBFC),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'Laporan Laba\nRugi',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        height: 1.2,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyClosingScreen())),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E2938) : const Color(0xFFF4FCE3),
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.transparent),
                              ),
                              child: Text(
                                'Tutup kasir',
                                style: TextStyle(
                                  color: isDark ? const Color(0xFFBEF364) : const Color(0xFF4D7B1C),
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                            child: Container(
                              width: 36.w,
                              height: 36.w,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E2938) : Colors.white,
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
                              ),
                              child: Icon(Icons.person_outline, color: isDark ? Colors.white : Colors.black87, size: 20.r),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      // PDF / Excel buttons
                      Row(
                        children: [
                          _buildExportButton('PDF', isDark),
                          SizedBox(width: 8.w),
                          _buildExportButton('Excel', isDark),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tabs
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              child: Row(
                children: [
                  _buildTab('Harian', isDark),
                  SizedBox(width: 8.w),
                  _buildTab('Bulanan', isDark),
                  SizedBox(width: 8.w),
                  _buildTab('Tahunan', isDark),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                child: Column(
                  children: [
                    // Period Navigator
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E2938) : Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: isDark ? null : Border.all(color: Colors.black.withValues(alpha: 0.05)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => _navigatePeriod(-1),
                            child: Icon(Icons.chevron_left, color: isDark ? Colors.white54 : Colors.black54),
                          ),
                          Text(
                            _getPeriodText(),
                            style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 14.sp),
                          ),
                          GestureDetector(
                            onTap: () => _navigatePeriod(1),
                            child: Icon(Icons.chevron_right, color: isDark ? Colors.white54 : Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Main Laba Bersih Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.r),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFFBEF364) : const Color(0xFF4D7B1C),
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedTab == 'Harian' 
                                ? 'Laba bersih hari ini' 
                                : (_selectedTab == 'Bulanan' ? 'Laba bersih bulan ini' : 'Laba bersih tahun ini'),
                            style: TextStyle(color: isDark ? const Color(0xFF111727).withValues(alpha: 0.7) : Colors.white70, fontSize: 13.sp),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            currencyFormat.format(netProfit),
                            style: TextStyle(color: isDark ? const Color(0xFF111727) : Colors.white, fontSize: 28.sp, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                          ),
                          SizedBox(height: 12.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF4D7B1C) : const Color(0xFF3F6117),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              percentageChangeText,
                              style: TextStyle(color: isDark ? const Color(0xFFBEF364) : const Color(0xFFBEF364), fontSize: 11.sp, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Pendapatan / Beban split
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(16.r),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E2938) : const Color(0xFFF4FCE3),
                              borderRadius: BorderRadius.circular(16.r),
                              border: isDark ? null : Border.all(color: Colors.transparent),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Pendapatan', style: TextStyle(color: isDark ? Colors.white54 : const Color(0xFF4D7B1C), fontSize: 12.sp)),
                                SizedBox(height: 4.h),
                                Text(currencyFormat.format(totalIncome), style: TextStyle(color: isDark ? const Color(0xFFBEF364) : const Color(0xFF4D7B1C), fontSize: 15.sp, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(16.r),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E2938) : const Color(0xFFFFF7ED),
                              borderRadius: BorderRadius.circular(16.r),
                              border: isDark ? null : Border.all(color: Colors.transparent),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Beban', style: TextStyle(color: isDark ? Colors.white54 : const Color(0xFFC2410C), fontSize: 12.sp)),
                                SizedBox(height: 4.h),
                                Text(currencyFormat.format(totalExpense), style: TextStyle(color: isDark ? const Color(0xFFF97316) : const Color(0xFFC2410C), fontSize: 15.sp, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Rincian Beban
                    Container(
                      padding: EdgeInsets.all(20.r),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E2938) : Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: isDark ? null : Border.all(color: Colors.black.withValues(alpha: 0.05)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Rincian beban', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 15.sp)),
                              GestureDetector(
                                onTap: () => _showAddTransactionSheet(context, pos, isDark),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFFBEF364) : const Color(0xFF4D7B1C),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text('+ Tambah', style: TextStyle(color: isDark ? const Color(0xFF111727) : Colors.white, fontWeight: FontWeight.bold, fontSize: 12.sp)),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          if (cogs > 0)
                            _buildDetailRow('Harga pokok', '- ${currencyFormat.format(cogs)}', isDark ? const Color(0xFFF97316) : const Color(0xFFC2410C), isDark),
                          ...filteredManual.where((t) => t['type'] == 'expense').map((t) {
                            final double amt = double.tryParse(t['amount']?.toString() ?? '0') ?? 0;
                            return _buildDetailRow(t['category'] ?? 'Lainnya', '- ${currencyFormat.format(amt)}', isDark ? const Color(0xFFF97316) : const Color(0xFFC2410C), isDark);
                          }),
                          if (cogs == 0 && filteredManual.where((t) => t['type'] == 'expense').isEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              child: Text('Tidak ada rincian beban', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 13.sp)),
                            ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            child: Divider(color: isDark ? Colors.white10 : Colors.black12, height: 1),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Laba bersih', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 14.sp)),
                              Text(currencyFormat.format(netProfit), style: TextStyle(color: isDark ? const Color(0xFFBEF364) : const Color(0xFF4D7B1C), fontWeight: FontWeight.bold, fontSize: 14.sp)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 100.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton(String label, bool isDark) {
    return GestureDetector(
      onTap: () async {
        final api = ApiService();
        final now = DateTime.now();
        final scaffoldMessenger = ScaffoldMessenger.of(context);

        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Menyiapkan dokumen $label...'), behavior: SnackBarBehavior.floating),
        );

        if (label == 'PDF') {
          try {
            final response = await api.client.get(
              '/finance/export',
              queryParameters: {'month': now.month, 'year': now.year},
              options: dio.Options(
                responseType: dio.ResponseType.bytes,
                receiveTimeout: const Duration(seconds: 60),
              ),
            );

            if (!context.mounted) return;
            await Printing.layoutPdf(
              onLayout: (_) => response.data,
              name: 'Laporan-Laba-Rugi-${now.year}-${now.month}.pdf',
            );
            scaffoldMessenger.hideCurrentSnackBar();
          } on dio.DioException catch (e) {
            final msg = e.response?.statusCode == 500
                ? 'Server error saat generate PDF. Cek log server.'
                : 'Gagal export PDF: ${e.message}';
            scaffoldMessenger.showSnackBar(
              SnackBar(content: Text(msg), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
            );
          } catch (e) {
            scaffoldMessenger.showSnackBar(
              SnackBar(content: Text('Gagal export PDF: $e'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
            );
          }
        } else if (label == 'Excel') {
          try {
            final response = await api.client.get(
              '/finance/export/excel',
              queryParameters: {'month': now.month, 'year': now.year},
              options: dio.Options(
                responseType: dio.ResponseType.bytes,
                receiveTimeout: const Duration(seconds: 60),
              ),
            );

            final bytes = response.data as List<int>;
            final fileName = 'Laporan-Laba-Rugi-${now.year}-${now.month}.xlsx';
            if (!context.mounted) return;
            await downloadFile(bytes, fileName, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
            scaffoldMessenger.hideCurrentSnackBar();
          } on dio.DioException catch (e) {
            final msg = e.response?.statusCode == 500
                ? 'Server error saat generate Excel. Cek log server.'
                : 'Gagal export Excel: ${e.message}';
            scaffoldMessenger.showSnackBar(
              SnackBar(content: Text(msg), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
            );
          } catch (e) {
            scaffoldMessenger.showSnackBar(
              SnackBar(content: Text('Gagal export Excel: $e'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
            );
          }
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          border: Border.all(color: isDark ? Colors.white24 : Colors.black26),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isDark ? const Color(0xFFBEF364) : const Color(0xFF4D7B1C),
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String label, bool isDark) {
    bool isSelected = _selectedTab == label;
    final activeBgColor = isDark ? const Color(0xFFBEF364) : const Color(0xFF4D7B1C);
    final activeTextColor = isDark ? const Color(0xFF111727) : Colors.white;
    final inactiveBgColor = isDark ? const Color(0xFF1E2938) : const Color(0xFFF3F4F6);
    final inactiveTextColor = isDark ? Colors.white54 : Colors.black54;

    return GestureDetector(
      onTap: () => setState(() => _selectedTab = label),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? activeBgColor : inactiveBgColor,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? activeTextColor : inactiveTextColor,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color valueColor, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 13.sp)),
          Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.w600, fontSize: 13.sp)),
        ],
      ),
    );
  }

  void _showAddTransactionSheet(BuildContext context, PosProvider pos, bool isDark) {
    String type = 'expense';
    final categoryController = TextEditingController();
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, MediaQuery.of(context).viewInsets.bottom + 20.h),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF111727) : Colors.white, 
              borderRadius: BorderRadius.vertical(top: Radius.circular(30.r))
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.black12, borderRadius: BorderRadius.circular(2)))),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : Colors.black87, size: 20),
                      ),
                      Text('Tambah Transaksi', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 18.sp, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  
                  // Type Dropdown
                  Text('Tipe', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14.sp, fontWeight: FontWeight.w500)),
                  SizedBox(height: 4.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E2938) : const Color(0xFFF3F4F6), 
                      borderRadius: BorderRadius.circular(10.r), 
                      border: Border.all(color: isDark ? const Color(0xFF364152) : Colors.black.withValues(alpha: 0.05))
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: type,
                        dropdownColor: isDark ? const Color(0xFF1E2938) : Colors.white,
                        icon: Icon(Icons.keyboard_arrow_down, color: isDark ? const Color(0xFFF9FBFC) : Colors.black54),
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: 'income', child: Text('Pemasukan')),
                          DropdownMenuItem(value: 'expense', child: Text('Pengeluaran / Beban')),
                        ],
                        onChanged: (v) => setState(() => type = v!),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  _buildLabelledField('Kategori', categoryController, 'Misal: Listrik, Air, Gaji, Sewa', isDark),
                  SizedBox(height: 16.h),
                  _buildLabelledField('Nominal (Rp)', amountController, '0', isDark, isNum: true),
                  SizedBox(height: 16.h),
                  _buildLabelledField('Catatan', noteController, 'Tambahkan detail jika perlu', isDark),
                  SizedBox(height: 32.h),

                  // Submit Button
                  GestureDetector(
                    onTap: () async {
                      final category = categoryController.text.trim();
                      final amount = double.tryParse(amountController.text) ?? 0.0;
                      final note = noteController.text.trim();

                      if (category.isEmpty || amount <= 0) return;
                      
                      await pos.addManualTransaction(
                        type: type,
                        category: category,
                        amount: amount,
                        note: note.isNotEmpty ? note : null,
                      );

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Transaksi berhasil ditambahkan!')),
                        );
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(color: isDark ? const Color(0xFFBEF364) : const Color(0xFF4D7B1C), borderRadius: BorderRadius.circular(23.r)),
                      child: Text('Simpan', textAlign: TextAlign.center, style: TextStyle(color: isDark ? const Color(0xFF111727) : Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabelledField(String label, TextEditingController controller, String hint, bool isDark, {bool isNum = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14.sp, fontWeight: FontWeight.w500)),
        SizedBox(height: 4.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2938) : const Color(0xFFF3F4F6), 
            borderRadius: BorderRadius.circular(8.r), 
            border: Border.all(color: isDark ? const Color(0xFF364152) : Colors.black.withValues(alpha: 0.05))
          ),
          child: TextField(
            controller: controller,
            keyboardType: isNum ? TextInputType.number : TextInputType.text,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              hintText: hint, 
              hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black26), 
              border: InputBorder.none
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../pos/providers/pos_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/navigation/navigation_provider.dart';
import '../../closing/screens/daily_closing_screen.dart';
import '../../profile/screens/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedPeriod = 'Daily';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PosProvider>().syncMasterData();
    });
  }

  List<Map<String, dynamic>> _filterTransactions(List<Map<String, dynamic>> transactions) {
    final now = DateTime.now();
    return transactions.where((trx) {
      final date = DateTime.parse(trx['created_at']);
      if (_selectedPeriod == 'Daily') {
        return date.year == now.year && date.month == now.month && date.day == now.day;
      } else if (_selectedPeriod == 'Weekly') {
        final weekAgo = now.subtract(const Duration(days: 7));
        return date.isAfter(weekAgo);
      } else {
        return date.year == now.year && date.month == now.month;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final pos = context.watch<PosProvider>();
    final auth = context.watch<AuthProvider>();
    final filteredTrx = _filterTransactions(pos.transactions);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final lowStockProducts = pos.products.where((p) => p.stock < (p.minStock)).toList();
    final NumberFormat currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    double totalIncome = filteredTrx.fold(0.0, (sum, trx) => sum + (double.tryParse(trx['total_amount'].toString()) ?? 0));
    double totalProfit = filteredTrx.fold(0.0, (sum, trx) => sum + (double.tryParse(trx['profit']?.toString() ?? '0') ?? 0));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => pos.syncMasterData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hallo ${auth.userName}',
                            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 16.sp, fontFamily: 'Poppins'),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            'Selamat Datang Kembali',
                            style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 18.sp, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyClosingScreen())),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E2938) : const Color(0xFFF4FCE3),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.transparent),
                            ),
                            child: Text(
                              'Tutup kasir',
                              style: TextStyle(
                                color: isDark ? const Color(0xFFBEF364) : const Color(0xFF4D7B1C),
                                fontSize: 13.sp,
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
                  ],
                ),

                SizedBox(height: 24.h),

                // Main Stats Card
                Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFFBEF364) : const Color(0xFF4D7B1C),
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Pendapatan ($_selectedPeriod)',
                        style: TextStyle(color: isDark ? const Color(0xFF111727).withValues(alpha: 0.7) : Colors.white70, fontSize: 14.sp, fontFamily: 'Roboto'),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        currencyFormat.format(totalIncome),
                        style: TextStyle(color: isDark ? const Color(0xFF111727) : Colors.white, fontSize: 28.sp, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        children: [
                          _buildMiniStat('Profit', currencyFormat.format(totalProfit), isDark),
                          SizedBox(width: 24.w),
                          _buildMiniStat('Transaksi', filteredTrx.length.toString(), isDark),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // Period Selector
                Row(
                  children: [
                    _buildPeriodTab('Daily', isDark),
                    SizedBox(width: 8.w),
                    _buildPeriodTab('Weekly', isDark),
                    SizedBox(width: 8.w),
                    _buildPeriodTab('Monthly', isDark),
                  ],
                ),

                SizedBox(height: 24.h),

                // Sales Statistics (Donut Chart)
                Text(
                  'Statistik Penjualan',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 16.sp, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                ),
                SizedBox(height: 16.h),
                Container(
                  height: 300.h,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2938) : Colors.white,
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(color: isDark ? const Color(0xFF364152) : Colors.black.withValues(alpha: 0.05)),
                    boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 40.r,
                                  sections: _generatePieSections(filteredTrx, isDark),
                                  pieTouchData: PieTouchData(enabled: true),
                                ),
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              flex: 2,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _buildChartLegend(filteredTrx, isDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // Revenue Bar Chart
                Text(
                  'Tren Penjualan (7 Hari Terakhir)',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 16.sp, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                ),
                SizedBox(height: 16.h),
                Container(
                  height: 200.h,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2938) : Colors.white,
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(color: isDark ? const Color(0xFF364152) : Colors.black.withValues(alpha: 0.05)),
                  ),
                  child: BarChart(
                    BarChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (val, meta) {
                              final date = DateTime.now().subtract(Duration(days: 6 - val.toInt()));
                              return Text(DateFormat('dd/MM').format(date), style: TextStyle(fontSize: 10.sp, color: isDark ? Colors.white54 : Colors.black54));
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: _generateBarGroups(pos.transactions, isDark),
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                // Low Stock Warning
                if (lowStockProducts.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Stok Menipis',
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 16.sp, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                      ),
                      Text(
                        '${lowStockProducts.length} Produk',
                        style: TextStyle(color: Colors.redAccent, fontSize: 12.sp, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  ...lowStockProducts.take(3).map((p) => _buildLowStockItem(p.name, p.stock.toString(), isDark)),
                  SizedBox(height: 24.h),
                ],

                // Recent Transactions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transaksi Terakhir',
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 16.sp, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                    ),
                    TextButton(
                      onPressed: () => context.read<NavigationProvider>().setIndex(3),
                      child: Text('Lihat Semua', style: TextStyle(color: const Color(0xFFBEF364), fontSize: 12.sp)),
                    ),
                  ],
                ),
                ...filteredTrx.reversed.take(5).map((trx) => _buildRecentTrx(
                  trx['invoice_number'] ?? 'TRX',
                  currencyFormat.format(double.tryParse(trx['total_amount'].toString()) ?? 0),
                  DateFormat('HH:mm').format(DateTime.parse(trx['created_at'])),
                  isDark
                )),
                SizedBox(height: 100.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: isDark ? const Color(0xFF111727).withValues(alpha: 0.7) : Colors.white70, fontSize: 12.sp)),
        Text(value, style: TextStyle(color: isDark ? const Color(0xFF111727) : Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPeriodTab(String period, bool isDark) {
    bool isSelected = _selectedPeriod == period;
    final activeBgColor = isDark ? const Color(0xFFBEF364) : const Color(0xFF4D7B1C);
    final activeTextColor = isDark ? const Color(0xFF111727) : Colors.white;
    final inactiveBgColor = isDark ? const Color(0xFF1E2938) : const Color(0xFFF3F4F6);
    final inactiveTextColor = isDark ? Colors.white54 : Colors.black54;

    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = period),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? activeBgColor : inactiveBgColor,
          borderRadius: BorderRadius.circular(99.r),
          boxShadow: isSelected || isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]
        ),
        child: Text(
          period,
          style: TextStyle(
            color: isSelected ? activeTextColor : inactiveTextColor,
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _generatePieSections(List<Map<String, dynamic>> transactions, bool isDark) {
    Map<String, double> data = {};
    double total = 0;
    
    if (transactions.isEmpty) {
      return [];
    } else {
      for (var trx in transactions) {
        final method = trx['payment_method']?.toString() ?? 'Lainnya';
        final amount = double.tryParse(trx['total_amount'].toString()) ?? 0;
        data[method] = (data[method] ?? 0) + amount;
        total += amount;
      }
    }

    return data.entries.map((e) {
      final color = _getMethodColor(e.key);
      final percentage = total > 0 ? (e.value / total * 100).toStringAsFixed(1) : '0';
      return PieChartSectionData(
        color: color,
        value: e.value,
        title: '$percentage%',
        radius: 80.r,
        showTitle: true,
        titleStyle: TextStyle(
          fontSize: 12.sp, 
          fontWeight: FontWeight.bold, 
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black26, blurRadius: 2)],
        ),
      );
    }).toList();
  }

  List<Widget> _buildChartLegend(List<Map<String, dynamic>> transactions, bool isDark) {
    Map<String, double> data = {};
    if (transactions.isEmpty) {
      return [
        Center(child: Text('Belum ada data transaksi', style: TextStyle(fontSize: 12.sp, color: isDark ? Colors.white24 : Colors.black26)))
      ];
    } else {
      for (var trx in transactions) {
        final method = trx['payment_method']?.toString() ?? 'Lainnya';
        final amount = double.tryParse(trx['total_amount'].toString()) ?? 0;
        data[method] = (data[method] ?? 0) + amount;
      }
    }

    return data.entries.map((e) {
      final color = _getLegendColor(e.key);
      return Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: Row(
          children: [
            Container(width: 12.w, height: 12.w, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                e.key,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 12.sp, fontFamily: 'Roboto'),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildLowStockItem(String name, String stock, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2938) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.2)),
        boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w500)),
          Text('Sisa: $stock', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRecentTrx(String id, String amount, String time, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2938) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: isDark ? const Color(0xFF364152) : Colors.black.withValues(alpha: 0.05)),
        boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(id, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
              Text(time, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12.sp)),
            ],
          ),
          Text(amount, style: const TextStyle(color: Color(0xFFBEF364), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  List<BarChartGroupData> _generateBarGroups(List<Map<String, dynamic>> transactions, bool isDark) {
    Map<int, double> dailyData = {};
    final now = DateTime.now();
    
    // Initialize 7 days
    for (int i = 0; i < 7; i++) {
      dailyData[i] = 0;
    }

    for (var trx in transactions) {
      final date = DateTime.parse(trx['created_at']);
      final diff = now.difference(date).inDays;
      if (diff >= 0 && diff < 7) {
        dailyData[6 - diff] = (dailyData[6 - diff] ?? 0) + (double.tryParse(trx['total_amount'].toString()) ?? 0);
      }
    }

    return dailyData.entries.map((e) {
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: e.value,
            gradient: LinearGradient(
              colors: [const Color(0xFFBEF364), const Color(0xFFBEF364).withValues(alpha: 0.6)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 20.w,
            borderRadius: BorderRadius.circular(6.r),
            // backDrawRodData: BackgroundBarRodData(
            //   show: true,
            //   toY: dailyData.values.isEmpty ? 0 : dailyData.values.reduce((a, b) => a > b ? a : b),
            //   color: isDark ? const Color(0xFF364152).withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.02),
            // ),
          )
        ],
      );
    }).toList();
  }

  Color _getMethodColor(String method) {
    switch (method.toLowerCase()) {
      case 'cash':     return const Color(0xFFBEF364);  // lime green - Cash
      case 'qris':     return const Color(0xFF3B82F6);  // blue - QRIS
      case 'transfer': return const Color(0xFFF97316);  // orange - Bank Transfer
      case 'wallet':   return const Color(0xFFA855F7);  // purple - E-Wallet
      default:         return const Color(0xFF94A3B8);  // slate - Lainnya
    }
  }

  Color _getLegendColor(String method) => _getMethodColor(method);
}

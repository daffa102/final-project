import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../pos/providers/pos_provider.dart';
import 'receipt_viewer_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'Day';

  @override
  Widget build(BuildContext context) {
    final posProvider = context.watch<PosProvider>();
    final allTransactions = posProvider.transactions;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    // 1. Filter Transactions based on Selection
    final filteredTransactions = _filterTransactions(allTransactions, _selectedFilter);
    final groupedTransactions = _groupTransactionsByDate(filteredTransactions);
    final dates = groupedTransactions.keys.toList();

    // 2. Calculate Summary
    double totalIncome = filteredTransactions.fold(0.0, (sum, item) => sum + (double.tryParse(item['total_amount'].toString()) ?? 0));
    double totalProfit = filteredTransactions.fold(0.0, (sum, item) => sum + (double.tryParse(item['profit']?.toString() ?? '0') ?? 0));
    
    // Calculate Margin Percentage (Mocked logic if cost not fully synced, or actual if profit exists)
    String marginPercent = "+${totalIncome > 0 ? ((totalProfit / totalIncome) * 100).toStringAsFixed(1) : '0'}%";

    final bgColor = isDark ? const Color(0xFF111727) : theme.scaffoldBackgroundColor;
    final textColor = isDark ? const Color(0xFFF9FBFC) : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(textColor, isDark),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => posProvider.fetchTransactions(),
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  children: [
                    _buildFilters(isDark),
                    SizedBox(height: 16.h),
                    _buildSummaryCard(totalIncome, currencyFormat),
                    SizedBox(height: 16.h),
                    _buildMarginChart(allTransactions, isDark, marginPercent),
                    SizedBox(height: 16.h),
                    if (filteredTransactions.isEmpty)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 100.h),
                          child: Text('No transactions for this period', style: TextStyle(color: textColor.withValues(alpha: 0.5), fontSize: 16.sp)),
                        ),
                      )
                    else
                      ...dates.map((date) => Padding(
                        padding: EdgeInsets.only(bottom: 24.h),
                        child: _buildTransactionGroup(date, groupedTransactions[date]!, currencyFormat, isDark, textColor),
                      )),
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

  List<Map<String, dynamic>> _filterTransactions(List<Map<String, dynamic>> transactions, String filter) {
    final now = DateTime.now();
    return transactions.where((trx) {
      final dateStr = trx['created_at'];
      if (dateStr == null) return false;
      final date = DateTime.parse(dateStr);

      if (filter == 'Day') {
        return date.year == now.year && date.month == now.month && date.day == now.day;
      } else if (filter == 'Month') {
        return date.year == now.year && date.month == now.month;
      } else if (filter == 'Year') {
        return date.year == now.year;
      }
      return true;
    }).toList();
  }

  Map<String, List<Map<String, dynamic>>> _groupTransactionsByDate(List<Map<String, dynamic>> transactions) {
    final Map<String, List<Map<String, dynamic>>> groups = {};
    for (var trx in transactions) {
      final dateStr = trx['created_at'];
      if (dateStr == null) continue;
      final date = DateTime.parse(dateStr);
      final key = DateFormat('EEEE, d MMM yyyy').format(date);
      if (!groups.containsKey(key)) {
        groups[key] = [];
      }
      groups[key]!.add(trx);
    }
    return groups;
  }

  Widget _buildAppBar(Color textColor, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Transaction History',
            style: TextStyle(
              color: textColor,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
            ),
          ),
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2938) : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.more_vert, color: textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(bool isDark) {
    return Row(
      children: [
        _buildFilterChip('Day', isDark),
        SizedBox(width: 10.w),
        _buildFilterChip('Month', isDark),
        SizedBox(width: 10.w),
        _buildFilterChip('Year', isDark),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isDark) {
    bool isActive = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFBEF364) : (isDark ? const Color(0xFF1E2938) : Colors.white),
          borderRadius: BorderRadius.circular(30.r),
          boxShadow: isActive || isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]
        ),
        child: Row(
          children: [
            Icon(
              Icons.circle,
              size: 10.w,
              color: isActive ? const Color(0xFF111727) : (isDark ? const Color(0xFFBEF364).withValues(alpha: 0.5) : Colors.black26),
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                color: isActive ? const Color(0xFF111727) : (isDark ? Colors.white70 : Colors.black87),
                fontSize: 14.sp,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(double totalIncome, NumberFormat format) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: const Color(0xFFBEF364),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFBEF364).withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL TRANSACTION',
            style: TextStyle(
              color: const Color(0xFF1D1B20).withValues(alpha: 0.6),
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            format.format(totalIncome),
            style: TextStyle(
              color: const Color(0xFF1D1B20),
              fontSize: 32.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarginChart(List<Map<String, dynamic>> allTrx, bool isDark, String marginPercent) {
    // Generate Data Points for the last 7 items (Days/Months/Years)
    final dataPoints = _generateChartData(allTrx, _selectedFilter);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2938) : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Margin Trend',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFBEF364).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  marginPercent,
                  style: TextStyle(
                    color: const Color(0xFFBEF364),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          SizedBox(
            height: 120.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: dataPoints.map((val) => _buildBar(val, val == dataPoints.last, isDark)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  List<double> _generateChartData(List<Map<String, dynamic>> transactions, String filter) {
    // Simple logic: return 7 data points
    // If Day: Profit of last 7 days
    // If Month: Profit of last 6 months
    // If Year: Profit of last 5 years
    
    final List<double> values = [];
    final now = DateTime.now();

    if (filter == 'Day') {
      for (int i = 6; i >= 0; i--) {
        final d = now.subtract(Duration(days: i));
        final dayProfit = transactions.where((t) {
          final dt = DateTime.parse(t['created_at']);
          return dt.year == d.year && dt.month == d.month && dt.day == d.day;
        }).fold(0.0, (sum, t) => sum + (double.tryParse(t['profit']?.toString() ?? '0') ?? 0));
        values.add(dayProfit);
      }
    } else if (filter == 'Month') {
      for (int i = 5; i >= 0; i--) {
        final d = DateTime(now.year, now.month - i, 1);
        final monthProfit = transactions.where((t) {
          final dt = DateTime.parse(t['created_at']);
          return dt.year == d.year && dt.month == d.month;
        }).fold(0.0, (sum, t) => sum + (double.tryParse(t['profit']?.toString() ?? '0') ?? 0));
        values.add(monthProfit);
      }
    } else {
      for (int i = 4; i >= 0; i--) {
        final d = DateTime(now.year - i, 1, 1);
        final yearProfit = transactions.where((t) {
          final dt = DateTime.parse(t['created_at']);
          return dt.year == d.year;
        }).fold(0.0, (sum, t) => sum + (double.tryParse(t['profit']?.toString() ?? '0') ?? 0));
        values.add(yearProfit);
      }
    }

    // Normalize values to max height 100.h
    double maxVal = values.fold(1.0, (m, v) => v > m ? v : m);
    return values.map((v) => (v / maxVal) * 100).toList();
  }

  Widget _buildBar(double height, bool isActive, bool isDark) {
    return Container(
      width: 32.w,
      height: (height < 10 ? 10 : height).h,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFBEF364) : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
        borderRadius: BorderRadius.circular(8.r),
      ),
    );
  }

  Widget _buildTransactionGroup(String date, List<Map<String, dynamic>> items, NumberFormat format, bool isDark, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8.w, bottom: 12.h),
          child: Text(
            date,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.5),
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2938) : Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
          ),
          child: Column(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final dateObj = DateTime.parse(item['created_at']);
              final time = DateFormat('HH:mm').format(dateObj);
              final amount = double.tryParse(item['total_amount'].toString()) ?? 0;
              
              return InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReceiptViewerScreen(transaction: item))),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  decoration: BoxDecoration(
                    border: index == items.length - 1 ? null : Border(bottom: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['invoice_number'] ?? 'Transaction',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '$time • ${item['payment_method']}',
                            style: TextStyle(
                              color: textColor.withValues(alpha: 0.4),
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        format.format(amount),
                        style: TextStyle(
                          color: const Color(0xFFBEF364),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

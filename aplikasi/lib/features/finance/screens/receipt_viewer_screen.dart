import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart' as dio;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../../pos/providers/pos_provider.dart';

class ReceiptViewerScreen extends StatefulWidget {
  final Map<String, dynamic> transaction;

  const ReceiptViewerScreen({super.key, required this.transaction});

  @override
  State<ReceiptViewerScreen> createState() => _ReceiptViewerScreenState();
}

class _ReceiptViewerScreenState extends State<ReceiptViewerScreen> {
  Map<String, dynamic>? _fullTrx;
  Map<String, dynamic>? _store;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final pos = context.read<PosProvider>();
    final full = await pos.getTransactionDetail(widget.transaction['id']);
    
    // Fetch store data
    try {
      final response = await pos.apiService.client.get('/store');
      if (response.statusCode == 200) {
        _store = response.data['data'];
      }
    } catch (e) {
      debugPrint('Error fetching store: $e');
    }

    if (mounted) {
      setState(() {
        _fullTrx = full;
        _isLoading = false;
      });
    }
  }

  Future<void> _printReceipt() async {
    final pos = context.read<PosProvider>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Menyiapkan Printer...'), behavior: SnackBarBehavior.floating));
    
    try {
      final response = await pos.apiService.client.get(
        '/transactions/${widget.transaction['id']}/print',
        options: dio.Options(responseType: dio.ResponseType.bytes),
      );
      
      await Printing.layoutPdf(
        onLayout: (_) => response.data,
        name: 'Struk-${widget.transaction['invoice_number']}.pdf',
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Gagal mencetak: $e'), behavior: SnackBarBehavior.floating));
    }
  }

  void _shareReceipt() {
    if (_fullTrx == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sedang memuat data transaksi...'), behavior: SnackBarBehavior.floating)
      );
      return;
    }
    
    final items = _fullTrx!['items'] as List? ?? [];
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    
    String itemText = '';
    for (var item in items) {
      final name = item['product_name'] ?? item['product']?['name'] ?? 'Produk';
      final qty = item['quantity'] ?? 0;
      final sub = item['subtotal'] ?? 0;
      itemText += "$name x$qty - ${currencyFormat.format(sub)}\n";
    }

    final shareText = """
📜 STRUK TRANSAKSI - ${_store?['store_name'] ?? 'Kash POS'}
---------------------------------
No. Invoice: ${_fullTrx!['invoice_number']}
Waktu: ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(_fullTrx!['created_at']))}
Metode: ${_fullTrx!['payment_method']}

DAFTAR BELANJA:
$itemText
---------------------------------
TOTAL: ${currencyFormat.format(double.tryParse(_fullTrx!['total_amount'].toString()) ?? 0)}
BAYAR: ${currencyFormat.format(double.tryParse(_fullTrx!['amount_paid'].toString()) ?? 0)}
KEMBALI: ${currencyFormat.format(double.tryParse(_fullTrx!['change_amount'].toString()) ?? 0)}

${_store?['receipt_footer'] ?? 'Terima kasih telah berbelanja!'}
    """;

    Share.share(shareText, subject: 'Struk Transaksi ${_fullTrx!['invoice_number']}');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111727) : const Color(0xFFF9FBFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : Colors.black87, size: 20.r),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detail Transaksi', 
          style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 18.sp, fontWeight: FontWeight.w700, fontFamily: 'Poppins')
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFBEF364)))
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
              child: Column(
                children: [
                  _buildReceiptCard(isDark, currencyFormat),
                  SizedBox(height: 32.h),
                  _buildActions(isDark),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
    );
  }

  Widget _buildReceiptCard(bool isDark, NumberFormat format) {
    if (_fullTrx == null) return const Center(child: Text('Data tidak ditemukan'));
    
    final items = _fullTrx!['items'] as List? ?? [];
    final date = DateTime.parse(_fullTrx!['created_at']);
    final dateStr = DateFormat('dd MMM yyyy, HH:mm').format(date);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2938) : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 30,
            offset: const Offset(0, 15),
          )
        ],
      ),
      child: Column(
        children: [
          // Receipt Header
          Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              children: [
                _buildStoreHeader(isDark),
                SizedBox(height: 32.h),
                Text(
                  'Transaksi Berhasil',
                  style: TextStyle(
                    color: isDark ? Colors.white.withValues(alpha: 0.6) : Colors.black54,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  format.format(double.tryParse(_fullTrx!['total_amount'].toString()) ?? 0),
                  style: TextStyle(
                    color: isDark ? const Color(0xFFBEF364) : const Color(0xFF1D1B20),
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          // Dashed Divider
          _buildDashedLine(isDark),

          // Transaction Details
          Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              children: [
                _buildDetailRow('No. Invoice', _fullTrx!['invoice_number'], isDark),
                _buildDetailRow('Waktu', dateStr, isDark),
                _buildDetailRow('Metode Pembayaran', _fullTrx!['payment_method'].toString().toUpperCase(), isDark),
                
                SizedBox(height: 32.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'ITEM BELANJA',
                    style: TextStyle(
                      color: isDark ? Colors.white.withValues(alpha: 0.3) : Colors.black26,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                ...items.map((item) => _buildItemRow(item, isDark, format)),
                
                SizedBox(height: 24.h),
                _buildDashedLine(isDark, padding: 0),
                SizedBox(height: 24.h),
                
                _buildDetailRow('Subtotal', format.format(double.tryParse(_fullTrx!['total_amount'].toString()) ?? 0), isDark, isBold: true),
                _buildDetailRow('Bayar', format.format(double.tryParse(_fullTrx!['amount_paid'].toString()) ?? 0), isDark),
                _buildDetailRow('Kembali', format.format(double.tryParse(_fullTrx!['change_amount'].toString()) ?? 0), isDark, isLast: true),
              ],
            ),
          ),

          // Receipt Footer / Barcode
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(32.r),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.01),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24.r)),
            ),
            child: Column(
              children: [
                _buildBarcode(isDark),
                SizedBox(height: 24.h),
                Text(
                  _store?['receipt_footer'] ?? 'Arigatou',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black38,
                    fontSize: 13.sp,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreHeader(bool isDark) {
    return Column(
      children: [
        Container(
          width: 60.r,
          height: 60.r,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF111727) : Colors.grey[100],
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: _store?['logo_url'] != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Image.network(
                    context.read<PosProvider>().apiService.resolveImageUrl(_store!['logo_url']),
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Icon(Icons.store, color: isDark ? Colors.white24 : Colors.black12),
                  ),
                )
              : Icon(Icons.store, color: isDark ? Colors.white24 : Colors.black12),
        ),
        SizedBox(height: 12.h),
        Text(
          _store?['store_name'] ?? 'Kash Store',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark, {bool isBold = false, bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black45, fontSize: 14.sp, fontWeight: FontWeight.w500)),
          Text(
            value, 
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87, 
              fontSize: 14.sp, 
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600
            )
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(dynamic item, bool isDark, NumberFormat format) {
    final name = item['product_name'] ?? item['product']?['name'] ?? 'Produk';
    final qty = int.tryParse(item['quantity'].toString()) ?? 0;
    final price = double.tryParse(item['selling_price'].toString()) ?? 0.0;
    final subtotal = double.tryParse(item['subtotal'].toString()) ?? 0.0;

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 15.sp, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4.h),
                Text(
                  '$qty x ${format.format(price)}',
                  style: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black38, fontSize: 13.sp, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Text(
            format.format(subtotal),
            style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 15.sp, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildDashedLine(bool isDark, {double padding = 24}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding.w),
      child: Row(
        children: List.generate(
          40,
          (index) => Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              height: 1.h,
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBarcode(bool isDark) {
    return Container(
      height: 48.h,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: List.generate(
          50,
          (index) => Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: (index % 4 == 0) ? 2.w : 1.w),
              width: (index % 4 == 0) ? 4.w : 1.w,
              color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            label: 'BAGIKAN',
            icon: Icons.share_rounded,
            color: isDark ? const Color(0xFF1E2938) : Colors.white,
            textColor: isDark ? Colors.white : const Color(0xFF1E2938),
            onTap: _shareReceipt,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _buildActionButton(
            label: 'CETAK STRUK',
            icon: Icons.local_printshop_rounded,
            color: const Color(0xFFBEF364),
            textColor: const Color(0xFF111727),
            onTap: _printReceipt,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({required String label, required IconData icon, required Color color, required Color textColor, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        height: 60.h,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 22.sp),
            SizedBox(width: 10.w),
            Text(
              label, 
              style: TextStyle(
                color: textColor, 
                fontWeight: FontWeight.w800, 
                fontSize: 14.sp, 
                letterSpacing: 1.1,
                fontFamily: 'Poppins'
              )
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:printing/printing.dart';
import 'package:dio/dio.dart' as dio;
import 'package:provider/provider.dart';
import '../../features/pos/providers/pos_provider.dart';
import '../../features/finance/screens/receipt_viewer_screen.dart';

void showPrintDialog(BuildContext context, Map<String, dynamic> trx) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E2938) : Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
    builder: (context) => Container(
      padding: EdgeInsets.all(24.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2.r)),
          ),
          SizedBox(height: 24.h),
          Text('Opsi Transaksi', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87, fontFamily: 'Poppins')),
          SizedBox(height: 8.h),
          Text(trx['invoice_number'] ?? '', style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
          SizedBox(height: 24.h),
          _buildActionTile(
            context,
            icon: Icons.picture_as_pdf_outlined,
            title: 'Lihat Struk (PDF)',
            subtitle: 'Buka struk digital langsung di aplikasi',
            color: Colors.redAccent,
            onTap: () => _handlePrint(context, trx, mode: 'view'),
          ),
          SizedBox(height: 12.h),
          _buildActionTile(
            context,
            icon: Icons.print_outlined,
            title: 'Cetak Langsung',
            subtitle: 'Hubungkan ke printer Bluetooth/USB',
            color: const Color(0xFFBEF364),
            onTap: () => _handlePrint(context, trx, mode: 'print'),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    ),
  );
}

Widget _buildActionTile(BuildContext context, {required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16.r),
    child: Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12.r)),
            child: Icon(icon, color: color, size: 24.r),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 15.sp, fontWeight: FontWeight.w600)),
                Text(subtitle, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12.sp)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: isDark ? Colors.white24 : Colors.black26, size: 20.r),
        ],
      ),
    ),
  );
}

Future<void> _handlePrint(BuildContext context, Map<String, dynamic> trx, {required String mode}) async {
  Navigator.pop(context);
  
  if (mode == 'view') {
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReceiptViewerScreen(transaction: trx),
        ),
      );
    }
    return;
  }

  final scaffoldMessenger = ScaffoldMessenger.of(context);
  scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Menyiapkan Printer...'), behavior: SnackBarBehavior.floating));
  
  try {
    final posProvider = context.read<PosProvider>();
    final response = await posProvider.apiService.client.get(
      '/transactions/${trx['id']}/print',
      options: dio.Options(responseType: dio.ResponseType.bytes),
    );

    await Printing.layoutPdf(
      onLayout: (_) => response.data,
      name: 'Struk-${trx['invoice_number']}.pdf',
    );
  } catch (e) {
    scaffoldMessenger.showSnackBar(SnackBar(content: Text('Gagal memproses struk: $e'), behavior: SnackBarBehavior.floating));
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/pos_provider.dart';
import '../../../main.dart';
import '../../../core/utils/print_utils.dart';
import '../../../core/widgets/midtrans_payment_screen.dart';

class CheckoutDialog extends StatefulWidget {
  const CheckoutDialog({super.key});

  @override
  State<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<CheckoutDialog> {
  final NumberFormat currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
  final TextEditingController _cashController = TextEditingController();
  
  double _change = 0;
  String _paymentMethod = 'cash'; 
  bool _showError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _cashController.text = '0';
  }

  void _calculateChange(double total) {
    double cash = double.tryParse(_cashController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    setState(() {
      _change = cash - total;
    });
  }

  void _handlePay(PosProvider pos) async {
    double cash = double.tryParse(_cashController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    
    if (_paymentMethod != 'cash') {
       cash = pos.cartTotal;
    }

    if (_paymentMethod == 'cash' && cash < pos.cartTotal) {
      setState(() {
        _showError = true;
        _errorMessage = 'Uang yang diterima kurang dari total!';
      });
      return;
    }

    setState(() {
      _showError = false;
      _errorMessage = '';
    });

    // Handle Midtrans for non-cash payments
    if (_paymentMethod != 'cash') {
      final paymentData = await pos.initiateMidtransPayment(paymentMethod: _paymentMethod);
      if (paymentData != null && paymentData['redirect_url'] != null) {
        if (!mounted) return;
        // Open Midtrans in In-App WebView
        final success = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => MidtransPaymentScreen(
              url: paymentData['redirect_url'],
              title: 'Pembayaran ${_paymentMethod.toUpperCase()}',
            ),
          ),
        );
        
        if (success != true) {
          // If cancelled or failed
          return;
        }
      } else {
        setState(() {
          _showError = true;
          _errorMessage = pos.error ?? 'Gagal menghubungi Midtrans';
        });
        return;
      }
    }

    // Process local checkout (finalizing)
    final checkoutSuccess = await pos.processCheckout(
      paymentMethod: _paymentMethod, 
      amountPaid: cash
    );

    if (checkoutSuccess && mounted) {
      final trx = pos.transactions.isNotEmpty ? pos.transactions.first : null;
      Navigator.pop(context);
      if (navigatorKey.currentContext != null) {
        _showSuccessFeedback(navigatorKey.currentContext!, trx);
      }
    } else if (mounted) {
      setState(() {
        _showError = true;
        _errorMessage = pos.error ?? 'Gagal memproses transaksi';
      });
    }
  }

  void _simulateFailure() {
    setState(() {
      _showError = true;
      _errorMessage = 'Pembayaran Gagal: Saldo Tidak Mencukupi. Silakan gunakan metode lain.';
    });
  }

  void _showSuccessFeedback(BuildContext safeContext, Map<String, dynamic>? trx) {
    ScaffoldMessenger.of(safeContext).showSnackBar(SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF111727)),
          SizedBox(width: 8.w),
          const Text('Transaction Success!', style: TextStyle(color: Color(0xFF111727), fontWeight: FontWeight.bold)),
        ],
      ),
      action: SnackBarAction(
        label: 'PRINT',
        textColor: const Color(0xFF365314),
        onPressed: () {
          ScaffoldMessenger.of(safeContext).hideCurrentSnackBar();
          if (trx != null) {
            showPrintDialog(safeContext, trx);
          }
        },
      ),
      backgroundColor: const Color(0xFFBEF364),
      duration: const Duration(seconds: 4),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final pos = context.watch<PosProvider>();
    final total = pos.cartTotal;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
      backgroundColor: const Color(0xFF111727),
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Checkout Confirmation', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              SizedBox(height: 24.h),
              
              // Total Highlight
              Container(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Column(
                  children: [
                    Text('Total Bill', style: TextStyle(fontSize: 14.sp, color: Colors.white60)),
                    SizedBox(height: 4.h),
                    Text(
                      currencyFormat.format(total), 
                      style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.w900, color: const Color(0xFFBEF364), letterSpacing: -1)
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              
              Text('Payment Method', style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w700)),
              SizedBox(height: 12.h),
              
              // 4 Method Grid (2x2)
              Column(
                children: [
                  Row(
                    children: [
                      _buildMethodOption(Icons.payments_rounded, 'Cash', 'cash'),
                      SizedBox(width: 10.w),
                      _buildMethodOption(Icons.qr_code_2_rounded, 'QRIS', 'qris'),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      _buildMethodOption(Icons.account_balance_rounded, 'Bank', 'transfer'),
                      SizedBox(width: 10.w),
                      _buildMethodOption(Icons.account_balance_wallet_rounded, 'Wallet', 'wallet'),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              if (_showError) ...[
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12.r), border: Border.all(color: Colors.redAccent.withValues(alpha: 0.2))),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                      SizedBox(width: 10.w),
                      Expanded(child: Text(_errorMessage, style: TextStyle(color: Colors.redAccent, fontSize: 12.sp, fontWeight: FontWeight.w600))),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
              ],

              // Dynamic Payment Areas
              if (_paymentMethod == 'cash') ...[
                _buildLabelledField('Cash Received', _cashController, 'Enter amount'),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Change', style: TextStyle(fontSize: 14.sp, color: Colors.white60, fontWeight: FontWeight.w600)),
                    Text(
                      currencyFormat.format(_change > 0 ? _change : 0),
                      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: _change >= 0 ? const Color(0xFFBEF364) : Colors.redAccent),
                    ),
                  ],
                ),
              ] else if (_paymentMethod == 'qris') ...[
                _buildQRISArea(),
              ] else if (_paymentMethod == 'transfer') ...[
                _buildDynamicPaymentArea(
                  icon: Icons.account_balance_rounded,
                  title: 'Select Bank',
                  description: 'Choose bank for manual transfer confirmation.',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMiniOption('BCA'),
                      _buildMiniOption('BNI'),
                      _buildMiniOption('MANDIRI'),
                    ],
                  ),
                ),
              ] else ...[
                _buildDynamicPaymentArea(
                  icon: Icons.account_balance_wallet_rounded,
                  title: 'E-Wallet',
                  description: 'Pay using your digital wallet apps.',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMiniOption('GOPAY'),
                      _buildMiniOption('OVO'),
                      _buildMiniOption('DANA'),
                    ],
                  ),
                ),
              ],

              SizedBox(height: 32.h),

              ElevatedButton(
                onPressed: pos.isLoading ? null : () => _handlePay(pos),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBEF364),
                  minimumSize: Size(double.infinity, 60.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  elevation: 0,
                ),
                child: pos.isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Color(0xFF111727), strokeWidth: 2))
                    : Text('CONFIRM PAYMENT', style: TextStyle(color: const Color(0xFF111727), fontSize: 16.sp, fontWeight: FontWeight.w800, letterSpacing: 1)),
              ),
              SizedBox(height: 12.h),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white38, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQRISArea() {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
            child: Icon(Icons.qr_code_2_rounded, size: 100.r, color: const Color(0xFF111727)),
          ),
          SizedBox(height: 16.h),
          Text('Scan QRIS Code', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 8.h),
          Text('Tunjukkan kode QR kepada pelanggan untuk dipindai.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13.sp, color: Colors.white54, height: 1.4)),
          SizedBox(height: 12.h),
          TextButton(
            onPressed: _simulateFailure,
            child: Text('Simulasikan Saldo Habis', style: TextStyle(color: Colors.redAccent.withValues(alpha: 0.7), fontSize: 11.sp, decoration: TextDecoration.underline)),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicPaymentArea({required IconData icon, required String title, required String description, Widget? child}) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40.r, color: const Color(0xFFBEF364)),
          SizedBox(height: 12.h),
          Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 4.h),
          Text(description, textAlign: TextAlign.center, style: TextStyle(fontSize: 12.sp, color: Colors.white54)),
          if (child != null) ...[
            SizedBox(height: 20.h),
            child,
          ],
        ],
      ),
    );
  }

  Widget _buildMiniOption(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10.r), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
      child: Text(label, style: TextStyle(color: Colors.white70, fontSize: 10.sp, fontWeight: FontWeight.w800)),
    );
  }

  Widget _buildLabelledField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 13.sp, fontWeight: FontWeight.w600)),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16.r), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18.sp),
            decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.white24), border: InputBorder.none, prefixText: 'Rp ', prefixStyle: const TextStyle(color: Color(0xFFBEF364), fontWeight: FontWeight.bold)),
            onChanged: (_) => _calculateChange(context.read<PosProvider>().cartTotal),
          ),
        ),
      ],
    );
  }

  Widget _buildMethodOption(IconData icon, String label, String value) {
    final isSelected = _paymentMethod == value;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _paymentMethod = value;
            _showError = false;
            if (value != 'cash') _change = 0;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFBEF364) : const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: isSelected ? const Color(0xFFBEF364) : Colors.white.withValues(alpha: 0.05)),
            boxShadow: isSelected ? [BoxShadow(color: const Color(0xFFBEF364).withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))] : null,
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? const Color(0xFF111727) : Colors.white38, size: 26.r),
              SizedBox(height: 6.h),
              Text(label, style: TextStyle(color: isSelected ? const Color(0xFF111727) : Colors.white60, fontSize: 12.sp, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

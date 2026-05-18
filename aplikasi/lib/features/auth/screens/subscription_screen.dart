import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'register_screen.dart';
import '../../pos/providers/pos_provider.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String? _selectedMethod;
  bool _isLoading = false;
  bool _isSuccess = false;
  Map<String, dynamic>? _paymentData;

  Future<void> _startNativeCheckout() async {
    final pos = context.read<PosProvider>();
    setState(() => _isLoading = true);

    try {
      final response = await pos.apiService.client.post('/subscriptions/pay', data: {
        'plan': 'premium',
        'amount': 50000,
        'payment_type': _selectedMethod,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _paymentData = response.data['data'];
        });
      } else {
        throw Exception(response.data['message'] ?? 'Gagal membuat transaksi');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _checkStatus() async {
    if (_paymentData == null) return;
    final pos = context.read<PosProvider>();
    setState(() => _isLoading = true);

    try {
      final orderId = _paymentData!['order_id'];
      final response = await pos.apiService.client.get('/subscriptions/check/$orderId');
      
      final status = response.data['transaction_status'];
      if (status == 'settlement' || status == 'capture') {
        setState(() {
          _isSuccess = true;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status: $status. Silakan selesaikan pembayaran.')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal cek status: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSuccess) return _buildSuccessScreen();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () {
            if (_paymentData != null) {
              setState(() => _paymentData = null);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          _paymentData == null ? 'Premium Subscription' : 'Detail Pembayaran',
          style: TextStyle(color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.w800, fontFamily: 'Poppins'),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _paymentData == null ? _buildMethodSelection() : _buildNativePaymentDetail(),
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildMethodSelection() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductSummary(),
          SizedBox(height: 32.h),
          Text('Pilih Metode Pembayaran', style: TextStyle(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.w800)),
          SizedBox(height: 16.h),
          _buildPaymentCategory('Virtual Account (Pengecekan Otomatis)', [
            _PaymentItem(id: 'bca_va', name: 'BCA Virtual Account', logo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5c/Bank_Central_Asia.svg/1200px-Bank_Central_Asia.svg.png'),
            _PaymentItem(id: 'mandiri_va', name: 'Mandiri Bill Payment', logo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ad/Bank_Mandiri_logo_2016.svg/1200px-Bank_Mandiri_logo_2016.svg.png'),
            _PaymentItem(id: 'bri_va', name: 'BRI Virtual Account', logo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/BRI_Logo.svg/1200px-BRI_Logo.svg.png'),
            _PaymentItem(id: 'bni_va', name: 'BNI Virtual Account', logo: 'https://upload.wikimedia.org/wikipedia/id/thumb/5/55/BNI_logo.svg/1200px-BNI_logo.svg.png'),
            _PaymentItem(id: 'permata_va', name: 'Permata Virtual Account', logo: 'https://upload.wikimedia.org/wikipedia/id/thumb/2/22/PermataBank_logo.svg/1200px-PermataBank_logo.svg.png'),
            _PaymentItem(id: 'cimb_va', name: 'CIMB Niaga VA', logo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f6/CIMB_Niaga_logo.svg/1200px-CIMB_Niaga_logo.svg.png'),
          ]),
          SizedBox(height: 24.h),
          _buildPaymentCategory('E-Wallet & QRIS', [
            _PaymentItem(id: 'gopay', name: 'GoPay / QRIS', logo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/86/Gopay_logo.svg/1200px-Gopay_logo.svg.png'),
            _PaymentItem(id: 'shopeepay', name: 'ShopeePay', logo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fe/ShopeePay.svg/1200px-ShopeePay.svg.png'),
            _PaymentItem(id: 'dana', name: 'DANA', logo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/72/Logo_dana_blue.svg/1200px-Logo_dana_blue.svg.png'),
          ]),
          SizedBox(height: 48.h),
          _buildBottomBar(),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  Widget _buildNativePaymentDetail() {
    final isMandiri = _paymentData!['biller_code'] != null;
    final isVAPayment = _paymentData!['va_number'] != null && !isMandiri;
    final isQRIS = _paymentData!['qr_url'] != null;

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.r),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))],
              border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
            ),
            child: Column(
              children: [
                Text('TOTAL TAGIHAN', style: TextStyle(color: Colors.black38, fontSize: 12.sp, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                SizedBox(height: 8.h),
                Text('Rp 50.000', style: TextStyle(color: const Color(0xFF1E293B), fontSize: 32.sp, fontWeight: FontWeight.w900)),
                SizedBox(height: 32.h),
                
                if (isMandiri) ...[
                  _buildCopyableField('Kode Perusahaan (Biller Code)', _paymentData!['biller_code'] ?? '-'),
                  SizedBox(height: 20.h),
                  _buildCopyableField('Nomor Bill (Bill Key)', _paymentData!['bill_key'] ?? '-'),
                ] else if (isVAPayment) ...[
                  _buildCopyableField('Nomor Virtual Account', _paymentData!['va_number']),
                ] else if (isQRIS) ...[
                  if (_paymentData!['redirect_url'] != null) ...[
                    Text('Klik tombol di bawah untuk simulasi', style: TextStyle(color: Colors.black54, fontSize: 14.sp, fontWeight: FontWeight.w600)),
                    SizedBox(height: 16.h),
                    ElevatedButton.icon(
                      onPressed: () => launchUrl(Uri.parse(_paymentData!['redirect_url'])),
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: const Text('BAYAR SEKARANG (DANA)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E293B),
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 54.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    const Divider(),
                    SizedBox(height: 16.h),
                  ],
                  Text('Atau Scan QRIS untuk Membayar', style: TextStyle(color: Colors.black54, fontSize: 14.sp, fontWeight: FontWeight.w600)),
                  SizedBox(height: 20.h),
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r), border: Border.all(color: Colors.black12)),
                    child: Image.network(_paymentData!['qr_url'], width: 220.w, height: 220.w, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.qr_code_2, size: 100)),
                  ),
                  SizedBox(height: 16.h),
                  Text('QR Code dapat dipindai dari galeri atau HP lain', style: TextStyle(color: Colors.black38, fontSize: 11.sp)),
                ],
                
                SizedBox(height: 32.h),
                _buildInstructionRow(Icons.timer_outlined, 'Batas waktu pembayaran 24 jam'),
                _buildInstructionRow(Icons.security_rounded, 'Transaksi aman via Midtrans'),
              ],
            ),
          ),
          SizedBox(height: 32.h),
          ElevatedButton(
            onPressed: _checkStatus,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBEF364),
              minimumSize: Size(double.infinity, 64.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              elevation: 0,
            ),
            child: Text('CEK STATUS PEMBAYARAN', style: TextStyle(color: const Color(0xFF1E293B), fontSize: 16.sp, fontWeight: FontWeight.w900, letterSpacing: 1)),
          ),
          SizedBox(height: 16.h),
          TextButton(
            onPressed: () => setState(() => _paymentData = null),
            child: Text('Ganti Metode Pembayaran', style: TextStyle(color: Colors.black45, fontSize: 14.sp, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyableField(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.black54, fontSize: 13.sp, fontWeight: FontWeight.w600)),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(color: const Color(0xFFF9FBFC), borderRadius: BorderRadius.circular(16.r), border: Border.all(color: Colors.black.withValues(alpha: 0.05))),
          child: Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(value, style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B), letterSpacing: 1.5)),
                ),
              ),
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Disalin!')));
                },
                child: Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(color: const Color(0xFFBEF364), borderRadius: BorderRadius.circular(10.r)),
                  child: Icon(Icons.copy_rounded, size: 20.sp, color: const Color(0xFF1E293B)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14.sp, color: Colors.black26),
          SizedBox(width: 8.w),
          Text(text, style: TextStyle(color: Colors.black45, fontSize: 12.sp, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildProductSummary() {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: const Color(0xFF1E293B).withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 8))]
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(color: const Color(0xFFBEF364).withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.flash_on, color: Color(0xFFBEF364)),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kash POS Premium', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w800)),
                Text('Akses semua fitur selamanya', style: TextStyle(color: Colors.white54, fontSize: 12.sp, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Text('Rp 50rb', style: TextStyle(color: const Color(0xFFBEF364), fontSize: 18.sp, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildPaymentCategory(String title, List<_PaymentItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w),
          child: Text(title, style: TextStyle(color: Colors.black54, fontSize: 12.sp, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
        ),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          ),
          child: Column(
            children: items.map((item) {
              final isSelected = _selectedMethod == item.id;
              final isLast = items.last == item;
              return InkWell(
                onTap: () => setState(() => _selectedMethod = item.id),
                borderRadius: BorderRadius.circular(16.r),
                child: Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFBEF364).withValues(alpha: 0.05) : null,
                    borderRadius: isLast ? BorderRadius.vertical(bottom: Radius.circular(16.r)) : (items.first == item ? BorderRadius.vertical(top: Radius.circular(16.r)) : null),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44.w,
                        height: 28.h,
                        padding: EdgeInsets.all(4.r),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6.r), border: Border.all(color: Colors.black12)),
                        child: Image.network(item.logo, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.payment, size: 16)),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(child: Text(item.name, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.black87))),
                      Icon(isSelected ? Icons.check_circle : Icons.radio_button_off, color: isSelected ? const Color(0xFF1E293B) : Colors.black12, size: 22.r),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return ElevatedButton(
      onPressed: _selectedMethod == null ? null : _startNativeCheckout,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1E293B),
        minimumSize: Size(double.infinity, 64.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        elevation: 0,
      ),
      child: Text('AKTIVASI SEKARANG', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(color: Colors.black26, child: const Center(child: CircularProgressIndicator(color: Color(0xFFBEF364))));
  }

  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(32.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(24.r),
                decoration: const BoxDecoration(color: Color(0xFFBEF364), shape: BoxShape.circle),
                child: Icon(Icons.check_rounded, color: const Color(0xFF1E293B), size: 64.r),
              ),
              SizedBox(height: 32.h),
              Text('Aktivasi Berhasil!', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900, color: const Color(0xFF1E293B))),
              SizedBox(height: 12.h),
              Text(
                'Selamat! Pembayaran Anda telah kami terima. Sekarang, silakan buat akun premium Anda untuk mulai menggunakan fitur lengkap Kash POS.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 14.sp, height: 1.5),
              ),
              SizedBox(height: 48.h),
              ElevatedButton(
                onPressed: () {
                  // Direct Navigation to Register Screen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  minimumSize: Size(double.infinity, 64.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                ),
                child: Text('BUAT AKUN PREMIUM SEKARANG', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
              SizedBox(height: 16.h),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Kembali', style: TextStyle(color: Colors.black45, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentItem {
  final String id;
  final String name;
  final String logo;
  _PaymentItem({required this.id, required this.name, required this.logo});
}

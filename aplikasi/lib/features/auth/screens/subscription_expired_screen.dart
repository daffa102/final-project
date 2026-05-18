import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import '../../../core/widgets/midtrans_payment_screen.dart';
import '../../../core/api/api_service.dart';

class SubscriptionExpiredScreen extends StatefulWidget {
  const SubscriptionExpiredScreen({super.key});

  @override
  State<SubscriptionExpiredScreen> createState() => _SubscriptionExpiredScreenState();
}

class _SubscriptionExpiredScreenState extends State<SubscriptionExpiredScreen> {
  bool _isLoading = false;

  Future<void> _renewSubscription() async {
    setState(() => _isLoading = true);
    
    try {
      final api = ApiService();
      // Use the existing subscription pay endpoint
      final response = await api.client.post('/subscriptions/pay', data: {
        'amount': 50000, // Monthly fee
        'payment_type': 'qris', // Default to QRIS for easiest renewal
      });

      if (response.statusCode == 200 && response.data['data']['redirect_url'] != null) {
        if (!mounted) return;
        
        final success = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => MidtransPaymentScreen(
              url: response.data['data']['redirect_url'],
              title: 'Perpanjang Langganan',
            ),
          ),
        );

        if (success == true) {
          // Refresh profile to get new expiry date
          if (mounted) {
            await context.read<AuthProvider>().getProfile();
            // AuthProvider.isSubscriptionActive will now be true
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/'); // Go to splash to re-evaluate
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memulai pembayaran: $e'))
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    
    return Scaffold(
      backgroundColor: const Color(0xFF111727),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(32.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.timer_off_outlined, color: Colors.redAccent, size: 80),
              SizedBox(height: 32.h),
              Text(
                'Masa Aktif Habis',
                style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),
              Text(
                'Halo ${auth.userName}, masa aktif akun Anda telah berakhir. Silakan lakukan pembayaran untuk melanjutkan akses ke Kash POS.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14.sp),
              ),
              SizedBox(height: 48.h),
              Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Paket Premium', style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                        Text('Berlaku 30 Hari', style: TextStyle(color: Colors.white54, fontSize: 12.sp)),
                      ],
                    ),
                    Text('Rp50.000', style: TextStyle(color: const Color(0xFFBEF364), fontSize: 18.sp, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
              SizedBox(height: 32.h),
              ElevatedButton(
                onPressed: _isLoading ? null : _renewSubscription,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBEF364),
                  minimumSize: Size(double.infinity, 56.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Color(0xFF111727))
                  : Text('BAYAR SEKARANG', style: TextStyle(color: const Color(0xFF111727), fontWeight: FontWeight.bold, fontSize: 16.sp)),
              ),
              SizedBox(height: 16.h),
              TextButton(
                onPressed: () {
                  auth.logout();
                  Navigator.pushAndRemoveUntil(
                    context, 
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false
                  );
                },
                child: const Text('Keluar Akun', style: TextStyle(color: Colors.white38)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

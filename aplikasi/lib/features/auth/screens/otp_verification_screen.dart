import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'reset_password_screen.dart';

import 'package:intl/intl.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String identifier;
  final String phoneNumber;
  final String method;

  const OtpVerificationScreen({
    super.key,
    required this.identifier,
    required this.phoneNumber,
    required this.method,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  String _getMaskedPhone(String phone) {
    if (phone.length < 8) return phone;
    // Format: +6281 XXXX pada HH:mm WIB
    String clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.startsWith('0')) clean = '62${clean.substring(1)}';
    
    String prefix = clean.substring(0, 4);
    String suffix = clean.substring(clean.length - 3);
    return '+$prefix-XXXX-$suffix';
  }

  void _handleVerify() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length < 6) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.verifyOtp(widget.identifier, otp);

    if (success && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(
            identifier: widget.identifier,
            otp: otp,
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'OTP Salah'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLoading = context.watch<AuthProvider>().isLoading;
    final currentTime = DateFormat('HH:mm').format(DateTime.now());

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.colorScheme.onSurface, size: 28.r),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              Text(
                'Masukkan Kode Verifikasi',
                style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface),
              ),
              SizedBox(height: 16.h),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 15.sp, color: theme.colorScheme.onSurface.withValues(alpha: 0.7), height: 1.5, fontFamily: 'Poppins'),
                  children: [
                    const TextSpan(text: 'Masukkan 6 digit kode verifikasi yang dikirimkan via '),
                    TextSpan(text: widget.method, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const TextSpan(text: ' di nomor '),
                    TextSpan(text: _getMaskedPhone(widget.phoneNumber), style: const TextStyle(fontWeight: FontWeight.bold)),
                    const TextSpan(text: ' pada '),
                    TextSpan(text: '$currentTime WIB', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              SizedBox(height: 48.h),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) => _buildOtpBox(index, theme, isDark)),
              ),
              
              SizedBox(height: 32.h),
              TextButton(
                onPressed: () {
                  // Tambahkan logika kirim ulang jika perlu
                },
                child: Text(
                  'Kirim Ulang',
                  style: TextStyle(
                    color: Colors.red.shade400,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              
              SizedBox(height: 40.h),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  minimumSize: Size(double.infinity, 56.h),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                onPressed: isLoading ? null : _handleVerify,
                child: isLoading
                    ? SizedBox(width: 24.r, height: 24.r, child: CircularProgressIndicator(color: isDark ? Colors.black : Colors.white, strokeWidth: 2))
                    : Text('Verifikasi', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index, ThemeData theme, bool isDark) {
    return Container(
      width: 50.w,
      height: 70.h,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2938) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: _controllers[index].text.isNotEmpty 
              ? theme.colorScheme.primary 
              : Colors.grey.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        onChanged: (val) {
          setState(() {}); // Untuk update border color
          if (val.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (val.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          if (val.length == 1 && index == 5) {
            _handleVerify();
          }
        },
      ),
    );
  }
}

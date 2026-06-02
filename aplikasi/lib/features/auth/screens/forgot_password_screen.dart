import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'otp_verification_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _adminEmailController = TextEditingController();
  final _waNumberController = TextEditingController();

  void _handleSendOtp() async {
    final auth = context.read<AuthProvider>();
    final adminEmail = _adminEmailController.text.trim();
    final waNumber = _waNumberController.text.trim();
    
    if (adminEmail.isEmpty || waNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan lengkapi Email Admin dan Nomor WA')),
      );
      return;
    }

    final success = await auth.sendOtp(adminEmail, 'whatsapp', phoneNumber: waNumber); 
    
    if (success && mounted) {
      // Pindah ke layar verifikasi OTP
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            identifier: adminEmail,
            phoneNumber: waNumber,
            method: 'WhatsApp',
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Gagal mengirim kode. Pastikan Email Admin terdaftar.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header (Back Button + Title) ──────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Text(
                    'Pemulihan Akun',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 32.h),
                    
                    Text(
                      'Gunakan email dari Admin dan nomor WA terdaftar untuk memulihkan akun Anda.',
                      style: TextStyle(fontSize: 14.sp, color: Colors.black54, fontFamily: 'Poppins'),
                    ),
                    SizedBox(height: 32.h),

                    Text(
                      'Email Akun (Dari Admin)',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _adminEmailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.black87),
                      decoration: _buildLightInputDecoration('admin@neopay.com', Icons.email_outlined),
                    ),
                    SizedBox(height: 24.h),

                    Text(
                      'Nomor WhatsApp Terdaftar',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _waNumberController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: Colors.black87),
                      decoration: _buildLightInputDecoration('0812XXXXXXXX', Icons.phone_android_outlined),
                    ),

                    SizedBox(height: 48.h),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E293B), // Dark Slate
                        minimumSize: Size(double.infinity, 58.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        elevation: 0,
                      ),
                      onPressed: isLoading ? null : _handleSendOtp,
                      child: isLoading
                          ? SizedBox(width: 24.r, height: 24.r, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                              'KIRIM KODE OTP',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins',
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildLightInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black26),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
      prefixIcon: Icon(icon, color: Colors.black45, size: 22.r),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFF1E293B), width: 1.5),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: SizedBox(
                height: 180.h,
                child: Lottie.network(
                  'https://lottie.host/d8864b72-9592-4848-b50f-e030297bfc27/YiFkp13PwX.json',
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, err, st) => Icon(Icons.lock_person_rounded, size: 80.r, color: theme.colorScheme.primary),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Pemulihan Akun',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface, fontFamily: 'Poppins'),
            ),
            SizedBox(height: 8.h),
            Text(
              'Gunakan email dari Admin dan nomor WA terdaftar',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
            ),
            SizedBox(height: 32.h),

            _buildInputLabel('Email Akun (Dari Admin)', theme),
            _buildTextField(
              controller: _adminEmailController,
              hint: 'admin@neopay.com',
              icon: Icons.admin_panel_settings_rounded,
              theme: theme,
              isDark: isDark,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20.h),

            _buildInputLabel('Nomor WhatsApp Terdaftar', theme),
            _buildTextField(
              controller: _waNumberController,
              hint: '0812XXXXXXXX',
              icon: Icons.phone_android_rounded,
              theme: theme,
              isDark: isDark,
              keyboardType: TextInputType.phone,
            ),

            SizedBox(height: 32.h),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: isDark ? Colors.black : Colors.white,
                padding: EdgeInsets.symmetric(vertical: 18.h),
                elevation: 8,
                shadowColor: theme.colorScheme.primary.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              ),
              onPressed: isLoading ? null : _handleSendOtp,
              child: isLoading
                  ? SizedBox(width: 24.r, height: 24.r, child: CircularProgressIndicator(color: isDark ? Colors.black : Colors.white, strokeWidth: 2))
                  : Text(
                      'KIRIM KODE OTP',
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, letterSpacing: 1),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
      child: Text(
        label,
        style: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          fontSize: 13.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required ThemeData theme,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2938) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16.sp),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
          prefixIcon: Icon(icon, color: theme.colorScheme.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
          contentPadding: EdgeInsets.all(18.r),
        ),
      ),
    );
  }
}

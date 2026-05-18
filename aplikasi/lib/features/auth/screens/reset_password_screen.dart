import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String identifier;
  final String otp;

  const ResetPasswordScreen({
    super.key,
    required this.identifier,
    required this.otp,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  void _handleReset() async {
    final password = _passwordController.text;
    if (password.length < 6) return;
    if (password != _confirmController.text) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.resetPassword(widget.identifier, widget.otp, password);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password Berhasil Diubah!')));
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Reset Password', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 32.h),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password Baru', border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r))),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: _confirmController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Konfirmasi Password Baru', border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r))),
            ),
            SizedBox(height: 40.h),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 56.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              ),
              onPressed: isLoading ? null : _handleReset,
              child: const Text(
                'SIMPAN PASSWORD BARU', 
                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/auth_provider.dart';
import '../../main_wrapper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;

  void _handleRegister() async {
    final provider = Provider.of<AuthProvider>(context, listen: false);
    
    if (_emailController.text.isEmpty || 
        _phoneController.text.isEmpty || 
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semua kolom harus diisi')));
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password tidak cocok')));
      return;
    }

    final success = await provider.register(
      name: 'Kash Premium User',
      adminEmail: _emailController.text.trim(),
      personalEmail: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text.trim(),
      secondPassword: _passwordController.text.trim(),
    );

    if (success && mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainWrapper()));
    } else if (mounted && provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.error!), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.r),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Create premium account', style: TextStyle(color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 32.h),
            
            _buildLabel('Email'),
            _buildTextField(
              controller: _emailController,
              hint: 'example@example.com',
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 24.h),
            
            _buildLabel('Nomor WhatsApp'),
            _buildTextField(
              controller: _phoneController,
              hint: 'Enter WhatsApp number',
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 24.h),
            
            _buildLabel('Password'),
            _buildTextField(
              controller: _passwordController,
              hint: 'Enter password',
              isObscure: !_isPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility, color: Colors.black26, size: 20.r),
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
            ),
            SizedBox(height: 24.h),
            
            _buildLabel('Confirm Password'),
            _buildTextField(
              controller: _confirmPasswordController,
              hint: 'Repeat password',
              isObscure: !_isConfirmVisible,
              suffixIcon: IconButton(
                icon: Icon(_isConfirmVisible ? Icons.visibility_off : Icons.visibility, color: Colors.black26, size: 20.r),
                onPressed: () => setState(() => _isConfirmVisible = !_isConfirmVisible),
              ),
            ),
            
            SizedBox(height: 48.h),
            
            ElevatedButton(
              onPressed: isLoading ? null : _handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E293B),
                minimumSize: Size(double.infinity, 56.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                elevation: 0,
              ),
              child: isLoading
                  ? SizedBox(height: 20.h, width: 20.h, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('Create account', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w600)),
            ),
            
            SizedBox(height: 32.h),
            Center(
              child: Text.rich(
                TextSpan(
                  text: 'By Kash, you agree to the ',
                  style: TextStyle(color: Colors.black45, fontSize: 12.sp),
                  children: [
                    TextSpan(text: 'Terms', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    const TextSpan(text: ' and '),
                    TextSpan(text: 'Privacy Policy', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: TextStyle(color: Colors.black, fontSize: 15.sp, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool isObscure = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.black, fontSize: 15.sp, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.black12, fontSize: 15.sp),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFF1E293B), width: 1.5),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

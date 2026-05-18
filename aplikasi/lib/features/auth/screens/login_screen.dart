import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../main_wrapper.dart';
import 'forgot_password_screen.dart';
import 'subscription_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  // ── State ────────────────────────────────────────────────────────────────
  bool _showForm = false; // False = Landing Mode, True = Form Mode

  // ── Auth fields ─────────────────────────────────────────────────────────
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // ── Animations ──────────────────────────────────────────────────────────
  late AnimationController _staggerCtrl;
  late Animation<double>  _logoFade;
  late Animation<Offset>  _logoSlide;
  late Animation<double>  _titleFade;
  late Animation<Offset>  _titleSlide;
  late Animation<double>  _btnFade;
  late Animation<Offset>  _btnSlide;

  @override
  void initState() {
    super.initState();
    _buildStaggerAnimations();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _staggerCtrl.forward();
    });
  }

  void _buildStaggerAnimations() {
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    const slide = Offset(0.0, 0.15);

    _logoFade  = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _staggerCtrl, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)));
    _logoSlide = Tween<Offset>(begin: slide, end: Offset.zero).animate(CurvedAnimation(
      parent: _staggerCtrl, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)));

    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _staggerCtrl, curve: const Interval(0.2, 0.6, curve: Curves.easeOut)));
    _titleSlide = Tween<Offset>(begin: slide, end: Offset.zero).animate(CurvedAnimation(
      parent: _staggerCtrl, curve: const Interval(0.2, 0.6, curve: Curves.easeOut)));

    _btnFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _staggerCtrl, curve: const Interval(0.6, 1.0, curve: Curves.easeOut)));
    _btnSlide = Tween<Offset>(begin: slide, end: Offset.zero).animate(CurvedAnimation(
      parent: _staggerCtrl, curve: const Interval(0.6, 1.0, curve: Curves.easeOut)));
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final provider = Provider.of<AuthProvider>(context, listen: false);
    final email    = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan password tidak boleh kosong')),
      );
      return;
    }

    final success = await provider.login(email, password);
    if (success && mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainWrapper()));
    } else if (mounted && provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error!), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFF111727),
      body: Stack(
        children: [
          // ── Background Layer (Pattern) ──────────────────────────────────
          Positioned.fill(
            child: SvgPicture.asset(
              'lib/assets/Content wrapper.svg',
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _showForm ? _buildLoginForm(isLoading) : _buildLandingMode(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 1: Landing Mode (Welcome + LOG IN Button) ─────────────────────
  Widget _buildLandingMode() {
    return Container(
      key: const ValueKey('landing'),
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Stagger(opacity: _logoFade, slide: _logoSlide, child: _buildLogoSmall()),
          SizedBox(height: 32.h),
          _Stagger(opacity: _titleFade, slide: _titleSlide, child: _buildWelcomeText()),
          SizedBox(height: 80.h),
          _Stagger(
            opacity: _btnFade,
            slide: _btnSlide,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () => setState(() => _showForm = true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBEF364),
                    minimumSize: Size(double.infinity, 56.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  ),
                  child: Text(
                    'LOG IN',
                    style: TextStyle(
                      color: const Color(0xFF111727),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                
                // Subscription Option for New Users
                Text(
                  'Belum punya akun?',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 14.sp,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 8.h),
                OutlinedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen())),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFBEF364), width: 1.5),
                    minimumSize: Size(double.infinity, 50.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  ),
                  child: Text(
                    'SILAHKAN SUBSCRIPTION - 50% / BLN',
                    style: TextStyle(
                      color: const Color(0xFFBEF364),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  '*Dapatkan akun otomatis setelah aktivasi',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 11.sp,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 2: Login Form (Matches the Light Mode Screenshot) ────────────────
  Widget _buildLoginForm(bool isLoading) {
    return Container(
      key: const ValueKey('form'),
      color: Colors.white, // Light Mode Background for Form
      width: double.infinity,
      height: double.infinity,
      child: SafeArea(
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
                      onPressed: () => setState(() => _showForm = false),
                    ),
                  ),
                  Text(
                    'Log into account',
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
                    
                    // Email Field
                    Text(
                      'Email',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.black87),
                      decoration: _buildLightInputDecoration('example@example.com'),
                    ),

                    SizedBox(height: 24.h),

                    // Password Field
                    Text(
                      'Password',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: Colors.black87),
                      decoration: _buildLightInputDecoration('Enter password').copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: Colors.black26,
                            size: 22.r,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                        child: Text(
                          'Lupa Password?',
                          style: TextStyle(
                            color: const Color(0xFF1E293B),
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 32.h),

                    // Log in Button (Dark Style)
                    ElevatedButton(
                      onPressed: isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E293B), // Dark Slate
                        minimumSize: Size(double.infinity, 58.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? SizedBox(height: 24.r, width: 24.r, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                              'Log in',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins',
                              ),
                            ),
                    ),

                    SizedBox(height: 100.h), // Spacer

                    // Footer (Terms & Privacy)
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'By Kash, you agree to the',
                            style: TextStyle(
                              color: Colors.black45,
                              fontSize: 13.sp,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          SizedBox(height: 4.h),
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.black45,
                                fontSize: 13.sp,
                                fontFamily: 'Poppins',
                              ),
                              children: const [
                                TextSpan(text: 'Terms', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87)),
                                TextSpan(text: ' and '),
                                TextSpan(text: 'Privacy Policy', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87)),
                                TextSpan(text: '.'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Elements ─────────────────────────────────────────────────────────────

  Widget _buildLogoSmall() {
    return Center(
      child: SvgPicture.asset(
        'lib/assets/Vector.svg',
        width: 64.r,
        height: 64.r,
      ),
    );
  }

  Widget _buildWelcomeText() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Welcome back 👋',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFFF9FBFC),
              fontSize: 26.sp,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Login ke akun Kash Anda untuk melanjutkan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFFF9FBFC).withValues(alpha: 0.5),
              fontSize: 14.sp,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildLightInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black26),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
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

class _Stagger extends StatelessWidget {
  const _Stagger({required this.opacity, required this.slide, required this.child});
  final Animation<double> opacity;
  final Animation<Offset> slide;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: opacity, child: SlideTransition(position: slide, child: child));
  }
}

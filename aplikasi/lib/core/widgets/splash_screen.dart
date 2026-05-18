import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/subscription_expired_screen.dart';
import '../../features/main_wrapper.dart';
import '../../core/navigation/page_transitions.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  // Animation for the final logo & text
  late Animation<double> _finalLogoScale;
  late Animation<double> _finalLogoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  // Asset phase tracker
  int _assetPhase = 0; // 0: FIRST(3), 1: FIRST(2), 2: FINAL LIGHT (Vector 1 + White BG)

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    // Final Logo Animation
    _finalLogoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.85, curve: Curves.easeOutBack),
      ),
    );

    _finalLogoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.75, curve: Curves.easeIn),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.75, 1.0, curve: Curves.easeIn),
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.75, 1.0, curve: Curves.easeOutQuart),
      ),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    // Fase 0: FIRST (3) - Logo masuk (Dark BG)
    if (mounted) setState(() => _assetPhase = 0);
    await Future.delayed(const Duration(milliseconds: 800));

    // Fase 1: FIRST (2) - Logo meledak (Dark BG)
    if (mounted) setState(() => _assetPhase = 1);
    await Future.delayed(const Duration(milliseconds: 800));

    // Fase 2: TRANSISI KE PUTIH (Vector 1 + White BG)
    if (mounted) {
      setState(() => _assetPhase = 2);
      _controller.forward();
    }

    try {
      // Run animations and session check in parallel
      await Future.wait([
        _controller.forward().then((_) => Future.delayed(const Duration(milliseconds: 800))),
        if (mounted) context.read<AuthProvider>().checkSession().timeout(const Duration(seconds: 3)),
      ]).timeout(const Duration(seconds: 6)); // Global safety timeout
    } catch (e) {
      debugPrint('Initialization error: $e');
    }

    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    
    Widget targetPage;
    if (authProvider.isAuthenticated) {
      if (authProvider.isSubscriptionActive) {
        targetPage = const MainWrapper();
      } else {
        targetPage = const SubscriptionExpiredScreen();
      }
    } else {
      targetPage = const LoginScreen();
    }

    Navigator.pushReplacement(context, slideUpRoute(targetPage));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Background color animates from dark to white in Phase 2
    final Color bgColor = _assetPhase == 2 ? const Color(0xFFF9FBFC) : const Color(0xFF111727);

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        color: bgColor,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _buildCurrentBody(),
        ),
      ),
    );
  }

  Widget _buildCurrentBody() {
    switch (_assetPhase) {
      case 0:
        return SvgPicture.asset(
          'lib/assets/FIRST (3).svg',
          key: const ValueKey('phase0'),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      case 1:
        return SvgPicture.asset(
          'lib/assets/FIRST (2).svg',
          key: const ValueKey('phase1'),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      case 2:
      default:
        return Center(
          key: const ValueKey('phase2'),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => Opacity(
                  opacity: _finalLogoOpacity.value,
                  child: Transform.scale(
                    scale: _finalLogoScale.value,
                    child: child,
                  ),
                ),
                child: SvgPicture.asset(
                  'lib/assets/Vector (1).svg', // DARK LOGO
                  width: 84.r,
                  height: 84.r,
                ),
              ),
              SizedBox(height: 24.h),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => FadeTransition(
                  opacity: _textOpacity,
                  child: SlideTransition(
                    position: _textSlide,
                    child: child,
                  ),
                ),
                child: _buildLogoText(isDark: true), // DARK TEXT
              ),
            ],
          ),
        );
    }
  }

  Widget _buildLogoText({bool isDark = false}) {
    final Color textColor = isDark ? const Color(0xFF111727) : Colors.white;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'KASH',
          style: TextStyle(
            color: textColor,
            fontSize: 32.sp,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w800,
            letterSpacing: 4,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          'Point of Sale',
          style: TextStyle(
            color: textColor.withValues(alpha: 0.6),
            fontSize: 12.sp,
            fontFamily: 'Poppins',
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

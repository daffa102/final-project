import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../core/navigation/page_transitions.dart';

/// Onboarding / Opening animation — plays once on first app launch.
/// Storyboard (matches OPENING.svg):
///   [0] Dark bg, KASH logo small → fades in & scales up gently
///   [1] Logo ZOOMS to fill entire screen (scale punch)
///   [2] Logo shrinks back, "Kash." text + tagline fades in
///   [3] Lottie circle spinner → navigate to LoginScreen (slide-up)
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  // ── Phase 0: Logo entrance (fade-in + gentle scale) ─────────────────────
  late AnimationController _phase0Ctrl;
  late Animation<double> _logoScale0;
  late Animation<double> _logoOpacity;

  // ── Phase 1: Logo ZOOM fills screen ─────────────────────────────────────
  late AnimationController _phase1Ctrl;
  late Animation<double> _logoZoom;

  // ── Phase 2: Pull back + text reveal ────────────────────────────────────
  late AnimationController _phase2Ctrl;
  late Animation<double> _logoShrink;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;

  // ── Phase tracker ────────────────────────────────────────────────────────
  int _phase = 0;

  @override
  void initState() {
    super.initState();
    _buildControllers();
    _startSequence();
  }

  void _buildControllers() {
    // Phase 0 – fade-in + gentle scale (1.2 s)
    _phase0Ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _logoScale0 = Tween<double>(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(parent: _phase0Ctrl, curve: Curves.easeOutBack));
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _phase0Ctrl,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOut)));

    // Phase 1 – zoom to full-screen (0.9 s)
    _phase1Ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _logoZoom = Tween<double>(begin: 1.0, end: 28.0).animate(
        CurvedAnimation(parent: _phase1Ctrl, curve: Curves.easeInExpo));

    // Phase 2 – pull back + text (1.0 s)
    _phase2Ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _logoShrink = Tween<double>(begin: 28.0, end: 1.15).animate(
        CurvedAnimation(parent: _phase2Ctrl, curve: Curves.easeOutCubic));
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _phase2Ctrl,
            curve: const Interval(0.4, 1.0, curve: Curves.easeOut)));
    _textSlide =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _phase2Ctrl,
                curve: const Interval(0.4, 1.0, curve: Curves.easeOut)));
  }

  Future<void> _startSequence() async {
    // ── Phase 0: logo enters ─────────────────────────────────────
    setState(() => _phase = 0);
    await _phase0Ctrl.forward();
    await Future.delayed(const Duration(milliseconds: 600));

    // ── Phase 1: zoom punch ──────────────────────────────────────
    setState(() => _phase = 1);
    await _phase1Ctrl.forward();

    // ── Phase 2: pull back + text ────────────────────────────────
    setState(() => _phase = 2);
    await _phase2Ctrl.forward();
    await Future.delayed(const Duration(milliseconds: 800));

    // ── Phase 3: spinner ─────────────────────────────────────────
    setState(() => _phase = 3);
    await Future.delayed(const Duration(milliseconds: 1800));

    // ── Mark first launch done & navigate ────────────────────────
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('firstLaunch', false);

    if (mounted) {
      Navigator.pushReplacement(context, slideUpRoute(const LoginScreen()));
    }
  }

  @override
  void dispose() {
    _phase0Ctrl.dispose();
    _phase1Ctrl.dispose();
    _phase2Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Background color flips to white in Phase 2 & 3
    final Color bgColor = (_phase >= 2) ? const Color(0xFFF9FBFC) : const Color(0xFF111727);

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        color: bgColor,
        child: AnimatedBuilder(
          animation: Listenable.merge([_phase0Ctrl, _phase1Ctrl, _phase2Ctrl]),
          builder: (context, _) => _buildCurrentPhase(),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildCurrentPhase() {
    switch (_phase) {
      case 0:
        return _buildPhase0();
      case 1:
        return _buildPhase1();
      case 2:
        return _buildPhase2();
      case 3:
        return _buildPhase3();
      default:
        return const SizedBox.shrink();
    }
  }

  // ── Phase 0: Dark bg, logo small, fades + scales in ─────────────────────
  Widget _buildPhase0() {
    return Center(
      child: Opacity(
        opacity: _logoOpacity.value,
        child: Transform.scale(
          scale: _logoScale0.value,
          child: _kashLogo(size: 88.r, isDark: false),
        ),
      ),
    );
  }

  // ── Phase 1: Logo zooms out to fill the screen ──────────────────────────
  Widget _buildPhase1() {
    return Center(
      child: Transform.scale(
        scale: _logoZoom.value,
        child: _kashLogo(size: 88.r, isDark: false),
      ),
    );
  }

  // ── Phase 2: Logo shrinks to medium + "Kash." text appears ──────────────
  Widget _buildPhase2() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo at medium scale (Now Dark)
          Transform.scale(
            scale: _logoShrink.value / 28.0 * 1.6 + 0.6,
            child: _kashLogo(size: 80.r, isDark: true),
          ),
          SizedBox(height: 36.h),
          // Brand name + tagline slide + fade in (Now Dark)
          SlideTransition(
            position: _textSlide,
            child: FadeTransition(
              opacity: _textFade,
              child: Column(
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Kash',
                          style: TextStyle(
                            color: const Color(0xFF111727),
                            fontSize: 38.sp,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        TextSpan(
                          text: '.',
                          style: TextStyle(
                            color: const Color(0xFFBEF364),
                            fontSize: 38.sp,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Your smart POS solution',
                    style: TextStyle(
                      color: const Color(0xFF111727).withValues(alpha: 0.5),
                      fontSize: 13.sp,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhase3() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Circle spinner
          Lottie.asset(
            'lib/assets/spinner.json',
            width: 64.r,
            height: 64.r,
            fit: BoxFit.contain,
            repeat: true,
          ),
          SizedBox(height: 28.h),
          Text(
            'KASH.',
            style: TextStyle(
              color: const Color(0xFF111727),
              fontSize: 18.sp,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              letterSpacing: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _kashLogo({required double size, bool isDark = false}) {
    // Vector (1) is the dark version, Vector is the white version
    final String assetPath = isDark ? 'lib/assets/Vector (1).svg' : 'lib/assets/Vector.svg';
    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}

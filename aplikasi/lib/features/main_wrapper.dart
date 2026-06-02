import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home/screens/dashboard_screen.dart';
import 'pos/screens/pos_screen.dart';
import 'pos/screens/product_management_screen.dart';
import 'finance/screens/history_screen.dart';
import 'pos/screens/report_screen.dart';
import '../core/navigation/navigation_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  late List<Widget> _screens;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _screens = [
      ReportScreen(),
      PosScreen(),
      DashboardScreen(),
      HistoryScreen(),
      ProductManagementScreen(),
    ];
    _pageController = PageController(initialPage: context.read<NavigationProvider>().selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int _previousIndex = 0;

  void _onItemTapped(int index) {
    if (index != context.read<NavigationProvider>().selectedIndex) {
      setState(() {
        _previousIndex = context.read<NavigationProvider>().selectedIndex;
      });
      context.read<NavigationProvider>().setIndex(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final nav = context.watch<NavigationProvider>();
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // ── Background Layer (Pattern appears after login) ─────────────
          const Positioned.fill(
            child: RepaintBoundary(
              child: _StaticBackground(),
            ),
          ),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (Widget child, Animation<double> animation) {
              final incomingIndex = (child.key as ValueKey<int>).value;
              final isPush = incomingIndex >= _previousIndex;
              
              final slideAnim = Tween<Offset>(
                begin: Offset(isPush ? 0.1 : -0.1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ));

              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: slideAnim,
                  child: RepaintBoundary(child: child),
                ),
              );
            },
            child: Container(
              key: ValueKey<int>(nav.selectedIndex),
              child: _screens[nav.selectedIndex],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomBar(nav.selectedIndex, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(int selectedIndex, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20.w, 
        right: 20.w, 
        bottom: MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom + 8.h : 24.h
      ),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 20.w),
        decoration: BoxDecoration(
          color: const Color(0xFF26272C),
          borderRadius: BorderRadius.circular(99.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [
             BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10))
          ]
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(0, Icons.assignment_outlined, selectedIndex), // Laporan
            _buildNavItem(1, Icons.payments_outlined, selectedIndex), // Kasir
            _buildNavItem(2, Icons.home_outlined, selectedIndex), // Home (Dashboard)
            _buildNavItem(3, Icons.history_rounded, selectedIndex), // History
            _buildNavItem(4, Icons.inventory_2_outlined, selectedIndex), // Stok
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, int selectedIndex) {
    bool isActive = selectedIndex == index;
    final activeColor = const Color(0xFFBEF364);
    final inactiveColor = Colors.white54;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Icon(
          icon,
          size: 26.r,
          color: isActive ? activeColor : inactiveColor,
        ),
      ),
    );
  }
}


class _StaticBackground extends StatefulWidget {
  const _StaticBackground();

  @override
  State<_StaticBackground> createState() => _StaticBackgroundState();
}

class _StaticBackgroundState extends State<_StaticBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return CustomPaint(
          painter: _BgPainter(_ctrl.value),
          child: Container(),
        );
      },
    );
  }
}

class _BgPainter extends CustomPainter {
  final double t;
  _BgPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF111727),
    );

    _drawOrb(canvas, size,
      x: 0.15 + 0.1 * math.sin(t * math.pi * 2),
      y: 0.25 + 0.08 * math.cos(t * math.pi * 2),
      radius: size.width * 0.45,
      color: const Color(0xFFBEF364).withValues(alpha: 0.07 + 0.03 * math.sin(t * math.pi)),
    );

    _drawOrb(canvas, size,
      x: 0.85 + 0.08 * math.cos(t * math.pi * 2 + 1),
      y: 0.6 + 0.1 * math.sin(t * math.pi * 2 + 1),
      radius: size.width * 0.38,
      color: const Color(0xFF3B82F6).withValues(alpha: 0.05 + 0.02 * math.cos(t * math.pi)),
    );

    _drawOrb(canvas, size,
      x: 0.5,
      y: 0.85 + 0.05 * math.sin(t * math.pi * 2 + 2),
      radius: size.width * 0.3,
      color: const Color(0xFFBEF364).withValues(alpha: 0.04 + 0.02 * math.cos(t * math.pi + 1)),
    );

    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;
    const spacing = 40.0;
    for (double x = spacing / 2; x < size.width; x += spacing) {
      for (double y = spacing / 2; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
      }
    }
  }

  void _drawOrb(Canvas canvas, Size size, {required double x, required double y, required double radius, required Color color}) {
    final cx = size.width * x;
    final cy = size.height * y;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius));
    canvas.drawCircle(Offset(cx, cy), radius, paint);
  }

  @override
  bool shouldRepaint(_BgPainter old) => old.t != t;
}

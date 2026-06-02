import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home/screens/dashboard_screen.dart';
import 'pos/screens/pos_screen.dart';
import 'pos/screens/product_management_screen.dart';
import 'pos/screens/report_screen.dart';
import 'finance/screens/history_screen.dart';
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
      ReportScreen(),            // 0 — Laporan Laba Rugi
      PosScreen(),               // 1 — Kasir
      DashboardScreen(),         // 2 — Home / Dashboard
      HistoryScreen(),           // 3 — History Transaksi
      ProductManagementScreen(), // 4 — Manajemen Produk
    ];
    _pageController = PageController(
      initialPage: context.read<NavigationProvider>().selectedIndex,
    );
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
            child: RepaintBoundary(child: _StaticBackground()),
          ),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (Widget child, Animation<double> animation) {
              final incomingIndex = (child.key as ValueKey<int>).value;
              final isPush = incomingIndex >= _previousIndex;

              final slideAnim =
                  Tween<Offset>(
                    begin: Offset(isPush ? 0.1 : -0.1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  );

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
            left: 20.w,
            right: 20.w,
            bottom: 10.h + MediaQuery.of(context).padding.bottom,
            child: SafeArea(
              child: _buildFloatingBottomBar(nav.selectedIndex, theme, isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingBottomBar(
    int selectedIndex,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E2938).withValues(alpha: 0.9)
            : Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(84.r),
        border: Border.all(
          color: isDark
              ? const Color(0xFF364152)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(0, Icons.assignment_outlined, Icons.assignment_rounded, selectedIndex),   // Laporan
          _buildNavItem(1, Icons.payments_outlined, Icons.payments_rounded, selectedIndex),       // Kasir
          _buildNavItem(2, Icons.home_outlined, Icons.home_rounded, selectedIndex),              // Home
          _buildNavItem(3, Icons.history_rounded, Icons.history_rounded, selectedIndex),          // History
          _buildNavItem(4, Icons.inventory_2_outlined, Icons.inventory_2_rounded, selectedIndex), // Produk
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    int selectedIndex,
  ) {
    bool isActive = selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFBEF364) : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Icon(
          isActive ? activeIcon : icon,
          color: isActive ? const Color(0xFF111727) : const Color(0xFF767676),
          size: 24.w,
        ),
      ),
    );
  }
}


class _StaticBackground extends StatelessWidget {
  const _StaticBackground();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}


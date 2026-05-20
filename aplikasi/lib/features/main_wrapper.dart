import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'auth/providers/auth_provider.dart';
import 'home/screens/dashboard_screen.dart';
import 'pos/screens/pos_screen.dart';
import 'pos/providers/pos_provider.dart';
import 'pos/screens/product_management_screen.dart';
import '../core/theme/theme_provider.dart';
import 'profile/screens/printer_settings_screen.dart';
import 'profile/screens/store_settings_screen.dart';
import 'finance/screens/history_screen.dart';
import '../core/navigation/navigation_provider.dart';
import 'closing/screens/daily_closing_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    _screens = const [
      HistoryScreen(),
      PosScreen(),
      DashboardScreen(),
      _NotificationScreen(),
      _DummyProfileScreen(),
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
          _buildNavItem(
            0,
            Icons.description_outlined,
            Icons.description_rounded,
            selectedIndex,
          ),
          _buildNavItem(
            1,
            Icons.account_balance_wallet_outlined,
            Icons.account_balance_wallet_rounded,
            selectedIndex,
          ),
          _buildNavItem(
            2,
            Icons.grid_view_outlined,
            Icons.grid_view_rounded,
            selectedIndex,
          ),
          _buildNavItem(
            3,
            Icons.notifications_outlined,
            Icons.notifications_rounded,
            selectedIndex,
          ),
          _buildNavItem(
            4,
            Icons.person_outline,
            Icons.person_rounded,
            selectedIndex,
          ),
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

class _NotificationScreen extends StatelessWidget {
  const _NotificationScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: Row(
                children: [
                  Text(
                    'Aktivitas',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () => context.read<NavigationProvider>().setIndex(0),
                    child: Text(
                      'Lihat Semua',
                      style: TextStyle(
                        color: const Color(0xFFBEF364),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.read<NavigationProvider>().setIndex(4),
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E2938) : Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                        boxShadow: isDark
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                ),
                              ],
                      ),
                      child: Icon(
                        Icons.person,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<PosProvider>(
                builder: (context, pos, child) {
                  final activities = pos.transactions.take(10).toList();
                  if (activities.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none_rounded,
                            size: 64.r,
                            color: isDark ? Colors.white10 : Colors.black12,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Belum ada aktivitas',
                            style: TextStyle(
                              color: isDark ? Colors.white24 : Colors.black26,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemCount: activities.length,
                    itemBuilder: (context, index) {
                      final trx = activities[index];
                      final amount =
                          NumberFormat.currency(
                            locale: 'id_ID',
                            symbol: 'Rp',
                            decimalDigits: 0,
                          ).format(
                            double.tryParse(trx['total_amount'].toString()) ??
                                0,
                          );
                      return Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E2938)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.black.withValues(alpha: 0.05),
                          ),
                          boxShadow: isDark
                              ? null
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                  ),
                                ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.r),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFBEF364,
                                ).withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.shopping_bag_outlined,
                                color: const Color(0xFFBEF364),
                                size: 20.r,
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Transaksi Berhasil',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${trx['invoice_number']} • $amount',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.black54,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              DateFormat(
                                'HH:mm',
                              ).format(DateTime.parse(trx['created_at'])),
                              style: TextStyle(
                                color: isDark ? Colors.white24 : Colors.black26,
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 100.h),
          ],
        ),
      ),
    );
  }
}

class _DummyProfileScreen extends StatelessWidget {
  const _DummyProfileScreen();

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profil',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Logout'),
                          content: const Text(
                            'Apakah Anda yakin ingin keluar?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                context.read<AuthProvider>().logout();
                              },
                              child: const Text(
                                'Logout',
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 32.h),
              Container(
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFBEF364), width: 2),
                ),
                child: CircleAvatar(
                  radius: 50.r,
                  backgroundColor: isDark
                      ? const Color(0xFF1E2938)
                      : Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 50.r,
                    color: const Color(0xFFBEF364),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                auth.userName,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                auth.userEmail,
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 32.h),
              _buildProfileOption(
                isDark,
                icon: Icons.dark_mode_outlined,
                title: 'Mode Gelap',
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  activeThumbColor: const Color(0xFFBEF364),
                  activeTrackColor: const Color(
                    0xFFBEF364,
                  ).withValues(alpha: 0.3),
                  onChanged: (value) => themeProvider.toggleTheme(),
                ),
              ),
              _buildProfileOption(
                isDark,
                icon: Icons.inventory_2_outlined,
                title: 'Manajemen Produk',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProductManagementScreen(),
                  ),
                ),
              ),
              _buildProfileOption(
                isDark,
                icon: Icons.store_outlined,
                title: 'Pengaturan Toko',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const StoreSettingsScreen(),
                  ),
                ),
              ),
              _buildProfileOption(
                isDark,
                icon: Icons.print_outlined,
                title: 'Pengaturan Printer',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PrinterSettingsScreen(),
                  ),
                ),
              ),
              _buildProfileOption(
                isDark,
                icon: Icons.storefront_outlined,
                title: 'Tutup Toko / Kasir',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DailyClosingScreen()),
                ),
              ),
              SizedBox(height: 100.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption(
    bool isDark, {
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2938) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark
              ? const Color(0xFF364152)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: const Color(0xFFBEF364).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: const Color(0xFFBEF364), size: 22.r),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing:
            trailing ??
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.white24 : Colors.black26,
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../pos/screens/product_management_screen.dart';
import '../../closing/screens/daily_closing_screen.dart';
import '../../finance/screens/expense_screen.dart';
import '../../finance/screens/income_screen.dart';
import '../../../core/theme/theme_provider.dart';
import 'printer_settings_screen.dart';
import 'store_settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : Colors.black87, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'Profil',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Logout'),
                          content: const Text('Apakah Anda yakin ingin keluar?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context); // tutup dialog
                                await context.read<AuthProvider>().logout();
                                if (context.mounted) {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                                    (route) => false, // hapus semua route sebelumnya
                                  );
                                }
                              },
                              child: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
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
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFBEF364), width: 2)),
                child: CircleAvatar(
                  radius: 50.r,
                  backgroundColor: isDark ? const Color(0xFF1E2938) : Colors.white,
                  child: Icon(Icons.person, size: 50.r, color: const Color(0xFFBEF364)),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                auth.userName,
                style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
              ),
              Text(
                auth.userEmail,
                style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 14.sp),
              ),
              SizedBox(height: 32.h),
              _buildProfileOption(
                isDark,
                icon: Icons.dark_mode_outlined,
                title: 'Mode Gelap',
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  activeThumbColor: const Color(0xFFBEF364),
                  activeTrackColor: const Color(0xFFBEF364).withValues(alpha: 0.3),
                  onChanged: (value) => themeProvider.toggleTheme(),
                ),
              ),
              _buildProfileOption(
                isDark,
                icon: Icons.inventory_2_outlined,
                title: 'Manajemen Produk',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductManagementScreen())),
              ),
              _buildProfileOption(
                isDark,
                icon: Icons.remove_circle_outline,
                title: 'Catat Pengeluaran',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpenseScreen())),
              ),
              _buildProfileOption(
                isDark,
                icon: Icons.add_circle_outline,
                title: 'Catat Pemasukan',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IncomeScreen())),
              ),
              _buildProfileOption(
                isDark,
                icon: Icons.store_outlined,
                title: 'Pengaturan Toko',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StoreSettingsScreen())),
              ),
              _buildProfileOption(
                isDark,
                icon: Icons.print_outlined,
                title: 'Pengaturan Printer',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrinterSettingsScreen())),
              ),
              _buildProfileOption(
                isDark,
                icon: Icons.storefront_outlined,
                title: 'Tutup Toko / Kasir',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyClosingScreen())),
              ),
              SizedBox(height: 100.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption(bool isDark, {required IconData icon, required String title, Widget? trailing, VoidCallback? onTap}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2938) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: isDark ? const Color(0xFF364152) : Colors.black.withValues(alpha: 0.05)),
        boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(color: const Color(0xFFBEF364).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10.r)),
          child: Icon(icon, color: const Color(0xFFBEF364), size: 22.r),
        ),
        title: Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w500)),
        trailing: trailing ?? Icon(Icons.chevron_right, color: isDark ? Colors.white24 : Colors.black26),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/pos_provider.dart';
import '../models/product.dart';
import 'cart_screen.dart';
import '../../closing/screens/daily_closing_screen.dart';
import '../../profile/screens/profile_screen.dart';


class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final NumberFormat currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PosProvider>().syncMasterData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111727) : const Color(0xFFF9FBFC),
      body: SafeArea(
        child: Consumer<PosProvider>(
          builder: (context, pos, child) {
            return Column(
              children: [
                // Custom Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kasir',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyClosingScreen())),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E2938) : const Color(0xFFEFFFCA),
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.transparent),
                              ),
                              child: Text(
                                'Tutup kasir',
                                style: TextStyle(
                                  color: isDark ? const Color(0xFFBEF364) : const Color(0xFF4D7B1C),
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                            child: Container(
                              width: 36.w,
                              height: 36.w,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E2938) : Colors.white,
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
                              ),
                              child: Icon(Icons.person_outline, color: isDark ? Colors.white : Colors.black87, size: 20.r),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Top Search Bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E2938) : Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: isDark ? null : Border.all(color: Colors.black.withValues(alpha: 0.05)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => pos.setSearchQuery(value),
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'Cari produk...',
                        hintStyle: TextStyle(fontSize: 14.sp, color: isDark ? Colors.white54 : Colors.black38, fontFamily: 'Poppins'),
                        border: InputBorder.none,
                        icon: Icon(Icons.circle_outlined, color: isDark ? Colors.white54 : Colors.black38, size: 20),
                      ),
                    ),
                  ),
                ),

                // Categories
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  child: Row(
                    children: [
                      _buildCategoryChip(pos, 0, 'Semua', isDark),
                      ...pos.categories.map((c) => _buildCategoryChip(pos, c.id, c.name, isDark)),
                    ],
                  ),
                ),

                // Product Grid
                Expanded(
                  child: pos.isLoading && pos.products.isEmpty
                      ? Center(child: CircularProgressIndicator(color: isDark ? const Color(0xFFBEF364) : const Color(0xFF4D7B1C)))
                      : RepaintBoundary(
                          child: GridView.builder(
                            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 220.h),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 0.72,
                              crossAxisSpacing: 12.w,
                              mainAxisSpacing: 12.h,
                            ),
                            itemCount: pos.products.length,
                            itemBuilder: (context, index) {
                              final product = pos.products[index];
                              return _buildProductCard(product, pos, isDark);
                            },
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Consumer<PosProvider>(
        builder: (context, pos, child) {
          if (pos.cart.isEmpty) return const SizedBox.shrink();

          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;

          return Padding(
            padding: EdgeInsets.only(
              bottom: 80.h,
              left: 20.w,
              right: 20.w,
            ),
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFFBEF364) : const Color(0xFF4D7B1C),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${pos.cart.length} item - ${currencyFormat.format(pos.cartTotal)}',
                            style: TextStyle(color: isDark ? const Color(0xFF111727).withValues(alpha: 0.8) : Colors.white70, fontSize: 13.sp, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Lihat keranjang',
                            style: TextStyle(color: isDark ? const Color(0xFF111727) : Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF111727) : Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        'Bayar',
                        style: TextStyle(color: isDark ? const Color(0xFFBEF364) : const Color(0xFF4D7B1C), fontSize: 14.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(PosProvider pos, int id, String title, bool isDark) {
    final isSelected = pos.selectedCategoryId == id;
    
    final activeBgColor = isDark ? const Color(0xFFBEF364) : const Color(0xFF4D7B1C);
    final activeTextColor = isDark ? const Color(0xFF111727) : Colors.white;
    
    final inactiveBgColor = isDark ? const Color(0xFF1E2938) : const Color(0xFFF3F4F6);
    final inactiveTextColor = isDark ? Colors.white54 : Colors.black54;

    return GestureDetector(
      onTap: () => pos.selectCategory(id),
      child: Container(
        margin: EdgeInsets.only(right: 10.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? activeBgColor : inactiveBgColor,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? activeTextColor : inactiveTextColor,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showQuantityDialog(BuildContext context, Product product, PosProvider pos, bool isDark) {
    int qty = 1;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2938) : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
          ),
          padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h + MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.black12, borderRadius: BorderRadius.circular(2.r)))),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Container(
                    width: 80.r,
                    height: 80.r,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF111727) : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: _buildProductImage(product, pos),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.name, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                        SizedBox(height: 4.h),
                        Text(currencyFormat.format(product.sellingPrice), style: TextStyle(fontSize: 16.sp, color: isDark ? const Color(0xFFBEF364) : const Color(0xFF4D7B1C), fontWeight: FontWeight.w600)),
                        SizedBox(height: 4.h),
                        Text('Stok: ${product.stock}', style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Jumlah Pembelian', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500, color: isDark ? Colors.white70 : Colors.black87)),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: isDark ? Colors.white24 : Colors.black12),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: qty > 1 ? () => setState(() => qty--) : null,
                          icon: Icon(Icons.remove, size: 18.r, color: qty > 1 ? (isDark ? const Color(0xFFBEF364) : const Color(0xFF4D7B1C)) : Colors.grey),
                        ),
                        Container(
                          width: 40.w,
                          alignment: Alignment.center,
                          child: Text('$qty', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                        ),
                        IconButton(
                          onPressed: () => setState(() => qty++),
                          icon: Icon(Icons.add, size: 18.r, color: isDark ? const Color(0xFFBEF364) : const Color(0xFF4D7B1C)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32.h),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFFBEF364) : const Color(0xFF4D7B1C),
                  foregroundColor: isDark ? const Color(0xFF111727) : Colors.white,
                  minimumSize: Size(double.infinity, 56.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  elevation: 0,
                ),
                onPressed: () {
                  pos.setQuantity(product, qty);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Color(0xFFBEF364), size: 18),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              'Berhasil menambah $qty ${product.name} ke keranjang',
                              style: TextStyle(fontSize: 13.sp),
                            ),
                          ),
                        ],
                      ),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: isDark ? const Color(0xFF1E2938) : Colors.black87,
                      margin: EdgeInsets.only(bottom: 250.h, left: 20.w, right: 20.w),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  );
                },
                child: Text('TAMBAH KE KERANJANG', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(Product product, PosProvider pos) {
    final String? path = product.imagePath;

    // Tampilkan placeholder jika tidak ada gambar
    if (path == null || path.isEmpty) {
      return Container(
        color: Colors.transparent,
        child: Icon(Icons.inventory_2_outlined, color: Colors.grey.withValues(alpha: 0.4), size: 32.r),
      );
    }
    
    if (kIsWeb && path.startsWith('blob:')) {
      return Image.network(path, fit: BoxFit.cover);
    }

    final url = pos.apiService.resolveImageUrl(path);
    return Image.network(
      url, 
      fit: BoxFit.cover,
      loadingBuilder: (ctx, child, progress) {
        if (progress == null) return child;
        return Center(child: SizedBox(width: 20.r, height: 20.r, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey.withValues(alpha: 0.4))));
      },
      errorBuilder: (ctx, err, stack) => Icon(Icons.broken_image_outlined, color: Colors.grey.withValues(alpha: 0.4), size: 32.r),
    );
  }

  Widget _buildProductCard(Product product, PosProvider pos, bool isDark) {
    bool lowStock = product.stock <= 5;
    return GestureDetector(
      onTap: () => _showQuantityDialog(context, product, pos, isDark),
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2938) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: isDark ? null : Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  width: double.infinity,
                  color: isDark ? const Color(0xFF2B3648) : const Color(0xFFF3F4F6),
                  child: _buildProductImage(product, pos),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 13.sp, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
            ),
            SizedBox(height: 2.h),
            Text(
              currencyFormat.format(product.sellingPrice),
              style: TextStyle(color: isDark ? const Color(0xFFBEF364) : const Color(0xFF4D7B1C), fontSize: 12.sp, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
            ),
            SizedBox(height: 2.h),
            Text(
              'Stok: ${product.stock}',
              style: TextStyle(color: lowStock ? Colors.orangeAccent : (isDark ? Colors.white54 : Colors.black54), fontSize: 11.sp, fontWeight: lowStock ? FontWeight.w600 : FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }
}

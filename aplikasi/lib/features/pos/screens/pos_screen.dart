import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/pos_provider.dart';
import '../models/product.dart';
import 'cart_screen.dart';
import '../../../core/navigation/navigation_provider.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final NumberFormat currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
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
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<PosProvider>(
          builder: (context, pos, child) {
            return Column(
              children: [
                // Custom Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kasir',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.read<NavigationProvider>().setIndex(4),
                        child: Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E2938) : Colors.white,
                            borderRadius: BorderRadius.circular(8.r),
                            boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]
                          ),
                          child: Icon(Icons.person, color: theme.colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                ),

                // Top Search Bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(15.r),
                      border: Border.all(color: isDark ? const Color(0xFF364152) : Colors.black.withValues(alpha: 0.1)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => pos.setSearchQuery(value),
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'Cari Produk...',
                        hintStyle: TextStyle(fontSize: 16.sp, color: isDark ? const Color(0xFF727272) : Colors.black38, fontFamily: 'Poppins'),
                        border: InputBorder.none,
                        suffixIcon: Icon(Icons.search, color: isDark ? const Color(0xFF364152) : Colors.black26, size: 24.w),
                      ),
                    ),
                  ),
                ),

                // Categories
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  child: Row(
                    children: [
                      _buildCategoryChip(pos, 0, 'Semua Produk', theme, isDark),
                      ...pos.categories.map((c) => _buildCategoryChip(pos, c.id, c.name, theme, isDark)),
                    ],
                  ),
                ),

                // Product Grid
                Expanded(
                  child: pos.isLoading && pos.products.isEmpty
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFFBEF364)))
                      : RepaintBoundary(
                          child: GridView.builder(
                            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 180.h),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 108 / 155,
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

          return Padding(
            padding: EdgeInsets.only(bottom: 80.h),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: const Color(0xFFBEF364),
                borderRadius: BorderRadius.circular(12.r),
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
                          '${pos.cart.length} Items',
                          style: TextStyle(color: const Color(0xFF1D1B20), fontSize: 16.sp, fontWeight: FontWeight.w500, fontFamily: 'Roboto'),
                        ),
                        Text(
                          currencyFormat.format(pos.cartTotal),
                          style: TextStyle(color: const Color(0xFF1D1B20), fontSize: 14.sp, fontWeight: FontWeight.w400, fontFamily: 'Roboto'),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF365314),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.shopping_cart_outlined, color: const Color(0xFFBEF364), size: 20.r),
                          SizedBox(width: 8.w),
                          Text(
                            'Keranjang',
                            style: TextStyle(color: const Color(0xFFBEF364), fontSize: 14.sp, fontWeight: FontWeight.w500, fontFamily: 'Roboto'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(PosProvider pos, int id, String title, ThemeData theme, bool isDark) {
    final isSelected = pos.selectedCategoryId == id;
    return GestureDetector(
      onTap: () => pos.selectCategory(id),
      child: Container(
        margin: EdgeInsets.only(right: 10.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFBEF364) : (isDark ? const Color(0xFF1E2938) : Colors.white),
          borderRadius: BorderRadius.circular(99.r),
          border: Border.all(color: isDark ? const Color(0xFF364152) : Colors.black.withValues(alpha: 0.1)),
          boxShadow: isSelected || isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]
        ),
        child: Row(
          children: [
            Icon(Icons.circle, size: 8.w, color: isSelected ? const Color(0xFF111727) : (isDark ? const Color(0xFFF9FBFC) : Colors.black38)),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? const Color(0xFF111727) : (isDark ? const Color(0xFFF9FBFC) : Colors.black87),
                fontSize: 16.sp,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuantityDialog(BuildContext context, Product product, PosProvider pos) {
    int qty = 1;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E2938) : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
          ),
          padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h + MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2.r)))),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Container(
                    width: 80.r,
                    height: 80.r,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF111727) : Colors.black.withValues(alpha: 0.05),
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
                        Text(product.name, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87)),
                        SizedBox(height: 4.h),
                        Text(currencyFormat.format(product.sellingPrice), style: TextStyle(fontSize: 16.sp, color: const Color(0xFFBEF364), fontWeight: FontWeight.w600)),
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
                  Text('Jumlah Pembelian', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500, color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54)),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: qty > 1 ? () => setState(() => qty--) : null,
                          icon: Icon(Icons.remove, size: 18.r, color: qty > 1 ? const Color(0xFFBEF364) : Colors.grey),
                        ),
                        Container(
                          width: 40.w,
                          alignment: Alignment.center,
                          child: Text('$qty', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87)),
                        ),
                        IconButton(
                          onPressed: () => setState(() => qty++),
                          icon: Icon(Icons.add, size: 18.r, color: const Color(0xFFBEF364)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32.h),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBEF364),
                  foregroundColor: const Color(0xFF111727),
                  minimumSize: Size(double.infinity, 56.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  elevation: 0,
                ),
                onPressed: () {
                  pos.setQuantity(product, qty);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Berhasil menambah $qty ${product.name} ke keranjang'),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: const Color(0xFF1E2938),
                      margin: EdgeInsets.only(bottom: 100.h, left: 20.w, right: 20.w),
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
    if (path == null || path.isEmpty) return Icon(Icons.fastfood_rounded, color: Colors.white.withValues(alpha: 0.05), size: 32.r);
    
    if (kIsWeb && path.startsWith('blob:')) {
      return Image.network(path, fit: BoxFit.cover);
    }

    final url = pos.apiService.resolveImageUrl(path);
    return Image.network(
      url, 
      fit: BoxFit.cover, 
      errorBuilder: (ctx, err, stack) => Icon(Icons.broken_image, color: Colors.white.withValues(alpha: 0.1))
    );
  }

  Widget _buildProductCard(Product product, PosProvider pos, bool isDark) {
    return GestureDetector(
      onTap: () => _showQuantityDialog(context, product, pos),
      child: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2938) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: isDark ? const Color(0xFF364152) : Colors.black.withValues(alpha: 0.05)),
          boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  width: double.infinity,
                  color: isDark ? const Color(0xFF111727) : Colors.black.withValues(alpha: 0.05),
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
              style: TextStyle(color: const Color(0xFFBEF364), fontSize: 12.sp, fontWeight: FontWeight.w500, fontFamily: 'Poppins'),
            ),
          ],
        ),
      ),
    );
  }
}

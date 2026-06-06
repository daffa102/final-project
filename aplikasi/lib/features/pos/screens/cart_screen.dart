import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../pos/providers/pos_provider.dart';
import '../../pos/models/product.dart';
import 'checkout_dialog.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    final pos = context.watch<PosProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Background color from design
    final bgColor = isDark ? const Color(0xFF111727) : theme.scaffoldBackgroundColor;
    final cardColor = isDark ? const Color(0xFF1E2938) : Colors.white;
    final textColor = isDark ? const Color(0xFFF9FBFC) : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back_ios, color: textColor, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Riport', // As requested in design
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18.sp,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFBEF364),
                      borderRadius: BorderRadius.circular(99.r),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 9.r,
                          height: 9.r,
                          decoration: const BoxDecoration(
                            color: Color(0xFF111727),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Label',
                          style: TextStyle(
                            color: const Color(0xFF111727),
                            fontSize: 16.sp,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Cart Items
            Expanded(
              child: pos.cart.isEmpty 
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 64.r, color: textColor.withValues(alpha: 0.2)),
                        SizedBox(height: 16.h),
                        Text('Your cart is empty', style: TextStyle(color: textColor.withValues(alpha: 0.5), fontSize: 14.sp)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    itemCount: pos.cart.length,
                    itemBuilder: (context, index) {
                      final item = pos.cart[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(18.r),
                          boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                        ),
                        child: Column(
                          children: [
                            // Top part: Image and Info
                            Padding(
                              padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 12.h, bottom: 6.h),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6.r),
                                    child: Container(
                                      width: 45.r,
                                      height: 45.r,
                                      color: const Color(0xFFD9D9D9),
                                      child: _buildProductImage(item.product, pos, isDark),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.product.name,
                                          style: TextStyle(color: textColor, fontSize: 18.sp, fontFamily: 'Poppins', fontWeight: FontWeight.w500),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 2.h),
                                        Text(
                                          '${currencyFormat.format(item.product.sellingPrice)} / pcs',
                                          style: TextStyle(color: textColor.withValues(alpha: 0.8), fontSize: 14.sp, fontFamily: 'Poppins', fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Bottom part: Qty and Total
                            Padding(
                              padding: EdgeInsets.only(left: 12.w, right: 12.w, bottom: 12.h),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      _buildOutlineBtn(Icons.remove, textColor, () => pos.decreaseQuantity(item.product)),
                                      InkWell(
                                        onTap: () => _showQtyDialog(context, pos, item.product, item.quantity, isDark),
                                        child: Container(
                                          width: 40.w,
                                          alignment: Alignment.center,
                                          child: Text(
                                            '${item.quantity}',
                                            style: TextStyle(color: textColor, fontSize: 18.sp, fontFamily: 'Roboto', fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ),
                                      _buildOutlineBtn(Icons.add, textColor, () => pos.addToCart(item.product)),
                                    ],
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text('Rp. ', style: TextStyle(color: textColor, fontSize: 18.sp, fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
                                      Text(
                                        currencyFormat.format(item.product.sellingPrice * item.quantity).replaceAll('Rp', '').trim(),
                                        style: TextStyle(color: textColor, fontSize: 18.sp, fontFamily: 'Poppins', fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
            ),
            
            // Summary & Checkout Bottom Section
            Padding(
              padding: EdgeInsets.all(18.w),
              child: Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Subtotal', style: TextStyle(fontSize: 16.sp, color: textColor, fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
                        Text(
                          currencyFormat.format(pos.cartTotal),
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: textColor, fontFamily: 'Poppins'),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Divider(color: textColor.withValues(alpha: 0.2), thickness: 1.5, height: 1),
                    SizedBox(height: 16.h),
                    SizedBox(
                      width: double.infinity,
                      height: 64.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFBEF364),
                          foregroundColor: const Color(0xFF111727),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                          elevation: 0,
                        ),
                        onPressed: pos.cart.isEmpty ? null : () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const CheckoutDialog(),
                          ).then((_) {
                             if (!context.mounted) return;
                             if(pos.cart.isEmpty && Navigator.canPop(context)) Navigator.pop(context);
                          });
                        },
                        child: Text(
                          'CHECKOUT', 
                          style: TextStyle(fontSize: 24.sp, fontFamily: 'Poppins', fontWeight: FontWeight.w600),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(Product product, PosProvider pos, bool isDark) {
    final String? path = product.imagePath;
    if (path == null || path.isEmpty) {
      return Icon(Icons.fastfood, color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05));
    }
    
    final url = pos.apiService.resolveImageUrl(path);
    return Image.network(
      url, 
      fit: BoxFit.cover,
      loadingBuilder: (ctx, child, progress) => progress == null ? child : const SizedBox.shrink(),
      errorBuilder: (ctx, err, stack) => Icon(Icons.broken_image, color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05)),
    );
  }

  Widget _buildOutlineBtn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(2.r),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 1.2),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Icon(icon, color: color, size: 16.r),
      ),
    );
  }

  void _showQtyDialog(BuildContext context, PosProvider pos, product, int currentQty, bool isDark) {
    final controller = TextEditingController(text: currentQty.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E2938) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Quantity', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            labelText: 'Item Quantity',
            labelStyle: TextStyle(color: isDark ? Colors.grey : Colors.black45),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: isDark ? const Color(0xFF364152) : Colors.black12), borderRadius: BorderRadius.circular(10.r)),
            focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFBEF364)), borderRadius: BorderRadius.circular(10.r)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFBEF364)),
            onPressed: () {
              final newQty = int.tryParse(controller.text) ?? currentQty;
              pos.setQuantity(product, newQty);
              Navigator.pop(context);
            },
            child: const Text('SAVE', style: TextStyle(color: Color(0xFF111727), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

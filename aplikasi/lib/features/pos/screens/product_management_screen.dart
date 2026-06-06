import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import '../providers/pos_provider.dart';
import '../models/product.dart';
import 'category_management_screen.dart';
import '../../closing/screens/daily_closing_screen.dart';
import '../../profile/screens/profile_screen.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final NumberFormat currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final TextEditingController _searchController = TextEditingController();

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
            final products = pos.products;
            
            // Calculate low stock products
            final lowStockProducts = products.where((p) => p.stock <= 5).toList();
            final lowStockCount = lowStockProducts.length;
            final lowStockNames = lowStockProducts.take(3).map((p) => p.name).join(', ') + (lowStockProducts.length > 3 ? ', ...' : '');

            return Column(
              children: [
                // Custom Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36.w,
                          height: 36.w,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E2938) : Colors.white,
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
                          ),
                          child: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black87, size: 16.r),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Manajemen Stok',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyClosingScreen())),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E2938) : const Color(0xFFEFFFCA),
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.transparent),
                              ),
                              child: Text(
                                'Tutup kasir',
                                style: TextStyle(
                                  color: isDark ? const Color(0xFFBEF364) : const Color(0xFF4D7B1C),
                                  fontSize: 12.sp,
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

                // Low Stock Alert
                if (lowStockCount > 0)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2A1605) : const Color(0xFFFFF3CD),
                        borderRadius: BorderRadius.circular(12.r),
                        border: const Border(
                          left: BorderSide(color: Color(0xFFF97316), width: 4),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$lowStockCount produk stok menipis',
                            style: TextStyle(color: const Color(0xFFF97316), fontSize: 13.sp, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            lowStockNames,
                            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 12.sp),
                          ),
                        ],
                      ),
                    ),
                  ),

                SizedBox(height: 16.h),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    children: [
                      Expanded(
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
                              icon: Icon(Icons.search, color: isDark ? Colors.white54 : Colors.black38, size: 20),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryManagementScreen())),
                        child: Container(
                          width: 48.w,
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E2938) : Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: isDark ? null : Border.all(color: Colors.black.withValues(alpha: 0.05)),
                          ),
                          child: Icon(Icons.category_outlined, color: isDark ? const Color(0xFFBEF364) : const Color(0xFF4D7B1C)),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      GestureDetector(
                        onTap: () => _showProductForm(context, context.read<PosProvider>(), isDark),
                        child: Container(
                          width: 48.w,
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFFBEF364) : const Color(0xFF4D7B1C),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(Icons.add, color: isDark ? const Color(0xFF111727) : Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // Product List
                Expanded(
                  child: products.isEmpty
                      ? Center(child: Text('Belum ada produk', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 14.sp)))
                      : ListView.builder(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            final isLowStock = product.stock <= 5;
                            String catName = 'Umum';
                            try {
                              catName = pos.categories.firstWhere((c) => c.id == product.categoryId).name;
                            } catch (_) {}

                            return GestureDetector(
                              onTap: () => _showProductOptions(context, pos, product, isDark),
                              child: Container(
                                margin: EdgeInsets.only(bottom: 12.h),
                                padding: EdgeInsets.all(12.r),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E2938) : Colors.white,
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: isLowStock ? Border.all(color: const Color(0xFFF97316), width: 1.5) : (isDark ? Border.all(color: Colors.white.withValues(alpha: 0.05)) : Border.all(color: Colors.black.withValues(alpha: 0.05))),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12.r),
                                      child: Container(
                                        width: 56.r, height: 56.r,
                                        color: isDark ? const Color(0xFF2B3648) : const Color(0xFFF3F4F6),
                                        child: _buildProductImage(product, pos),
                                      ),
                                    ),
                                    SizedBox(width: 16.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.name,
                                            style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 15.sp, fontFamily: 'Poppins'),
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            '$catName - ${currencyFormat.format(product.sellingPrice)}',
                                            style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12.sp),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${product.stock}',
                                          style: TextStyle(
                                            color: isLowStock ? const Color(0xFFF97316) : (isDark ? const Color(0xFFBEF364) : const Color(0xFF4D7B1C)),
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          isLowStock ? 'menipis!' : 'pcs',
                                          style: TextStyle(
                                            color: isLowStock ? const Color(0xFFF97316) : (isDark ? Colors.white54 : Colors.black54),
                                            fontSize: 12.sp,
                                            fontWeight: isLowStock ? FontWeight.w600 : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showProductOptions(BuildContext context, PosProvider pos, Product product, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E2938) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 8.h),
              Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.black12, borderRadius: BorderRadius.circular(2.r))),
              SizedBox(height: 16.h),
              ListTile(
                leading: Icon(Icons.edit, color: isDark ? const Color(0xFFBEF364) : const Color(0xFF4D7B1C)),
                title: Text('Edit Produk', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                onTap: () {
                  Navigator.pop(context);
                  _showProductForm(context, pos, isDark, product: product);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.redAccent),
                title: const Text('Hapus Produk', style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteDialog(context, pos, product, isDark);
                },
              ),
              SizedBox(height: 16.h),
            ],
          ),
        );
      }
    );
  }

  Widget _buildProductImage(Product product, PosProvider pos) {
    final String? path = product.imagePath;
    if (path == null || path.isEmpty) return const SizedBox.shrink();
    
    if (kIsWeb && path.startsWith('blob:')) {
      return Image.network(path, fit: BoxFit.cover);
    }

    final url = pos.apiService.resolveImageUrl(path);
    return Image.network(
      url, 
      fit: BoxFit.cover, 
      errorBuilder: (ctx, err, stack) => const SizedBox.shrink()
    );
  }

  void _showDeleteDialog(BuildContext context, PosProvider pos, Product product, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E2938) : Colors.white,
        title: Text('Delete Product', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        content: Text('Are you sure you want to delete "${product.name}"?', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: Colors.grey))),
          TextButton(onPressed: () async {
            final success = await pos.deleteProduct(product.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Product deleted!' : (pos.error ?? 'Error deleting product'))));
              Navigator.pop(context);
            }
          }, child: const Text('DELETE', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  void _showProductForm(BuildContext context, PosProvider pos, bool isDark, {Product? product}) {
    final isEdit = product != null;
    final nameController = TextEditingController(text: isEdit ? product.name : '');
    final sellPriceController = TextEditingController(text: isEdit ? product.sellingPrice.toString() : '');
    final buyPriceController = TextEditingController(text: isEdit ? product.buyingPrice.toString() : '');
    final stockNowController = TextEditingController(text: isEdit ? product.stock.toString() : '');
    final latestStockController = TextEditingController(text: isEdit ? '0' : '0');
    int? selectedCatId;
    if (isEdit) {
      selectedCatId = pos.categories.any((c) => c.id == product.categoryId) ? product.categoryId : (pos.categories.isNotEmpty ? pos.categories.first.id : null);
    } else {
      selectedCatId = pos.categories.isNotEmpty ? pos.categories.first.id : null;
    }
    String? currentImagePath = isEdit ? product.imagePath : null;
    XFile? currentImageFile;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, MediaQuery.of(context).viewInsets.bottom + 20.h),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF111727) : Colors.white, 
              borderRadius: BorderRadius.vertical(top: Radius.circular(30.r))
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.black12, borderRadius: BorderRadius.circular(2)))),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : Colors.black87, size: 20),
                      ),
                      Text(isEdit ? 'Edit Product' : 'Add Product', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 18.sp, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  
                  // Image Picker
                  GestureDetector(
                    onTap: () async {
                      final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
                      if (image != null) setState(() { currentImagePath = image.path; currentImageFile = image; });
                    },
                    child: Container(
                      height: 180.h,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E2938) : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(30.r),
                        border: Border.all(color: isDark ? const Color(0xFF364152) : Colors.black.withValues(alpha: 0.05)),
                      ),
                      child: currentImagePath != null
                          ? ClipRRect(borderRadius: BorderRadius.circular(30.r), child: _buildImagePreviewLocal(currentImagePath!, pos, isDark, localFile: currentImageFile))
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 79.w, height: 57.h, 
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E2938) : Colors.white, 
                                    borderRadius: BorderRadius.circular(12.r), 
                                    border: Border.all(color: isDark ? const Color(0xFF364152) : Colors.black.withValues(alpha: 0.05))
                                  ),
                                  child: Icon(Icons.image_outlined, color: isDark ? Colors.white24 : Colors.black26),
                                ),
                                SizedBox(height: 12.h),
                                Text('Upload Image', style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 12.sp, fontWeight: FontWeight.w500)),
                              ],
                            ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  _buildLabelledField('Product Name', nameController, 'Enter product name', isDark),
                  SizedBox(height: 16.h),

                  Row(
                    children: [
                      Expanded(child: _buildLabelledField('Selling Price', sellPriceController, '0', isDark, isNum: true)),
                      SizedBox(width: 10.w),
                      Expanded(child: _buildLabelledField('Purchase Price', buyPriceController, '0', isDark, isNum: true)),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  Row(
                    children: [
                      Expanded(child: _buildLabelledField('Stok Saat Ini', stockNowController, '0', isDark, isNum: true, readOnly: true)),
                      SizedBox(width: 10.w),
                      Expanded(child: _buildLabelledField(isEdit ? 'Tambah Stok' : 'Stok Awal', latestStockController, '0', isDark, isNum: true)),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Category Dropdown
                  Text('Categories', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14.sp, fontWeight: FontWeight.w500)),
                  SizedBox(height: 4.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E2938) : const Color(0xFFF3F4F6), 
                      borderRadius: BorderRadius.circular(10.r), 
                      border: Border.all(color: isDark ? const Color(0xFF364152) : Colors.black.withValues(alpha: 0.05))
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: selectedCatId,
                        dropdownColor: isDark ? const Color(0xFF1E2938) : Colors.white,
                        icon: Icon(Icons.keyboard_arrow_down, color: isDark ? const Color(0xFFF9FBFC) : Colors.black54),
                        isExpanded: true,
                        items: pos.categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, style: TextStyle(color: isDark ? Colors.white : Colors.black87)))).toList(),
                        onChanged: (v) => setState(() => selectedCatId = v),
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Submit Button
                  GestureDetector(
                    onTap: () async {
                      if (nameController.text.trim().isEmpty) return;
                      final imageBytes = currentImageFile != null ? await currentImageFile!.readAsBytes() : null;
                      final data = {
                        'name': nameController.text.trim(),
                        'category_id': selectedCatId ?? '',
                        'buying_price': double.tryParse(buyPriceController.text) ?? 0.0,
                        'selling_price': double.tryParse(sellPriceController.text) ?? 0.0,
                        'stock': (int.tryParse(stockNowController.text) ?? 0) + (int.tryParse(latestStockController.text) ?? 0),
                        'image_path': currentImagePath,
                        'image_bytes': imageBytes,
                        'image_name': currentImageFile?.name,
                      };
                      if (context.mounted) Navigator.pop(context);
                      if (isEdit) {
                        await pos.updateProduct(product.id, data);
                      } else {
                        await pos.addProduct(data);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(color: isDark ? const Color(0xFFBEF364) : const Color(0xFF4D7B1C), borderRadius: BorderRadius.circular(23.r)),
                      child: Text('Submit', textAlign: TextAlign.center, style: TextStyle(color: isDark ? const Color(0xFF111727) : Colors.white, fontSize: 24.sp, fontWeight: FontWeight.w600)),
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

  Widget _buildLabelledField(String label, TextEditingController controller, String hint, bool isDark, {bool isNum = false, bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14.sp, fontWeight: FontWeight.w500)),
        SizedBox(height: 4.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: readOnly
                ? (isDark ? const Color(0xFF151D2A) : const Color(0xFFE8E8E8))
                : (isDark ? const Color(0xFF1E2938) : const Color(0xFFF3F4F6)),
            borderRadius: BorderRadius.circular(8.r), 
            border: Border.all(color: isDark ? const Color(0xFF364152) : Colors.black.withValues(alpha: 0.05))
          ),
          child: TextField(
            controller: controller,
            keyboardType: isNum ? TextInputType.number : TextInputType.text,
            readOnly: readOnly,
            style: TextStyle(
              color: readOnly
                  ? (isDark ? Colors.white38 : Colors.black38)
                  : (isDark ? Colors.white : Colors.black87),
            ),
            decoration: InputDecoration(
              hintText: hint, 
              hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black26), 
              border: InputBorder.none,
              suffixIcon: readOnly ? Icon(Icons.lock_outline, size: 14.r, color: isDark ? Colors.white24 : Colors.black26) : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreviewLocal(String path, PosProvider pos, bool isDark, {XFile? localFile}) {
    // Priority 1: newly picked file — use XFile bytes (works on web & mobile)
    if (localFile != null) {
      if (kIsWeb) {
        // On web, XFile path is a blob URL
        return Image.network(localFile.path, fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) => Icon(Icons.broken_image, color: isDark ? Colors.white24 : Colors.black26));
      } else {
        // On mobile, use dart:io File
        return Image.file(File(localFile.path), fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) => Icon(Icons.broken_image, color: isDark ? Colors.white24 : Colors.black26));
      }
    }

    // Priority 2: existing server image path (from product data)
    if (path.startsWith('blob:')) {
      return Image.network(path, fit: BoxFit.cover);
    }
    final url = pos.apiService.resolveImageUrl(path);
    return Image.network(
      url, 
      fit: BoxFit.cover, 
      errorBuilder: (ctx, err, stack) => Icon(Icons.broken_image, color: isDark ? Colors.white24 : Colors.black26)
    );
  }
}

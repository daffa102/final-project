import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/pos_provider.dart';
import '../models/product.dart';
import 'category_management_screen.dart';

class ProductManagementScreen extends StatelessWidget {
  const ProductManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : Colors.black87, size: 20),
                      ),
                      Text(
                        'Riport',
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 18.sp, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                      ),
                      SizedBox(width: 12.w),
                      IconButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryManagementScreen())),
                        icon: Icon(Icons.category_outlined, color: const Color(0xFFBEF364), size: 20.r),
                        tooltip: 'Manage Categories',
                      ),
                    ],
                  ),
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E2938) : Colors.white, 
                      borderRadius: BorderRadius.circular(8.r),
                      boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]
                    ),
                    child: Icon(Icons.person, color: theme.colorScheme.primary),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Consumer<PosProvider>(
                builder: (context, pos, child) {
                  final products = pos.products;
                  if (products.isEmpty) {
                    return Center(child: Text('Belum ada produk', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)));
                  }
                  return ListView.builder(
                    padding: EdgeInsets.all(20.w),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 16.h),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E2938) : Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: isDark ? const Color(0xFF364152) : Colors.black.withValues(alpha: 0.05)),
                          boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(12.r),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10.r),
                            child: Container(
                              width: 56.r, height: 56.r,
                              color: isDark ? const Color(0xFF111727) : Colors.black.withValues(alpha: 0.02),
                              child: _buildProductImage(product, pos, isDark),
                            ),
                          ),
                          title: Text(product.name, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600, fontSize: 15.sp)),
                          subtitle: Text('Stock: ${product.stock} • ${currencyFormat.format(product.sellingPrice)}', 
                              style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 12.sp)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: Color(0xFFBEF364)),
                                onPressed: () => _showProductForm(context, pos, product: product),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () => _showDeleteDialog(context, pos, product, isDark),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductForm(context, context.read<PosProvider>()),
        backgroundColor: const Color(0xFFBEF364),
        icon: const Icon(Icons.add, color: Color(0xFF111727)),
        label: const Text('Add Product', style: TextStyle(color: Color(0xFF111727), fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildProductImage(Product product, PosProvider pos, bool isDark) {
    final String? path = product.imagePath;
    if (path == null || path.isEmpty) return Icon(Icons.fastfood, color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.1));
    
    if (kIsWeb && path.startsWith('blob:')) {
      return Image.network(path, fit: BoxFit.cover);
    }

    final url = pos.apiService.resolveImageUrl(path);
    return Image.network(
      url, 
      fit: BoxFit.cover, 
      errorBuilder: (ctx, err, stack) => Icon(Icons.broken_image, color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.1))
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

  void _showProductForm(BuildContext context, PosProvider pos, {Product? product}) {
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
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          
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
                        color: isDark ? const Color(0xFF1E2938) : Colors.black.withValues(alpha: 0.02),
                        borderRadius: BorderRadius.circular(30.r),
                        border: Border.all(color: isDark ? const Color(0xFF364152) : Colors.black.withValues(alpha: 0.05)),
                      ),
                      child: currentImagePath != null
                          ? ClipRRect(borderRadius: BorderRadius.circular(30.r), child: _buildImagePreview(currentImagePath!, pos, isDark))
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 79.w, height: 57.h, 
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E2938) : Colors.white, 
                                    borderRadius: BorderRadius.circular(12.r), 
                                    border: Border.all(color: isDark ? const Color(0xFF364152) : Colors.black12)
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
                      Expanded(child: _buildLabelledField('Stock now', stockNowController, '0', isDark, isNum: true)),
                      SizedBox(width: 10.w),
                      Expanded(child: _buildLabelledField('Latest Stock', latestStockController, '0', isDark, isNum: true)),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Category Dropdown
                  Text('Categories', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14.sp, fontWeight: FontWeight.w500)),
                  SizedBox(height: 4.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E2938) : Colors.black.withValues(alpha: 0.02), 
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
                      decoration: BoxDecoration(color: const Color(0xFFBEF364), borderRadius: BorderRadius.circular(23.r)),
                      child: Text('Submit', textAlign: TextAlign.center, style: TextStyle(color: const Color(0xFF111727), fontSize: 24.sp, fontWeight: FontWeight.w600)),
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

  Widget _buildLabelledField(String label, TextEditingController controller, String hint, bool isDark, {bool isNum = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14.sp, fontWeight: FontWeight.w500)),
        SizedBox(height: 4.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2938) : Colors.black.withValues(alpha: 0.02), 
            borderRadius: BorderRadius.circular(8.r), 
            border: Border.all(color: isDark ? const Color(0xFF364152) : Colors.black.withValues(alpha: 0.05))
          ),
          child: TextField(
            controller: controller,
            keyboardType: isNum ? TextInputType.number : TextInputType.text,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              hintText: hint, 
              hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black26), 
              border: InputBorder.none
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview(String path, PosProvider pos, bool isDark) {
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

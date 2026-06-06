import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/pos_provider.dart';

class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                        'Categories',
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 18.sp, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
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
                  return ListView.builder(
                    padding: EdgeInsets.all(20.w),
                    itemCount: pos.categories.length,
                    itemBuilder: (context, index) {
                      final cat = pos.categories[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E2938) : Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: isDark ? const Color(0xFF364152) : Colors.black.withValues(alpha: 0.05)),
                          boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]
                        ),
                        child: ListTile(
                          title: Text(cat.name, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit_outlined, color: isDark ? const Color(0xFFBEF364) : const Color(0xFF4D7B1C)),
                                onPressed: () => _showEditDialog(context, pos, cat.id, cat.name, isDark),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () => _showDeleteDialog(context, pos, cat.id, cat.name, isDark),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, context.read<PosProvider>(), isDark),
        backgroundColor: const Color(0xFFBEF364),
        child: const Icon(Icons.add, color: Color(0xFF111727)),
      ),
    );
  }

  void _showEditDialog(BuildContext context, PosProvider pos, int id, String currentName, bool isDark) {
    String name = currentName;
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E2938) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Edit Category', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
        content: TextField(
          autofocus: true,
          controller: controller,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            labelText: 'Category Name',
            labelStyle: TextStyle(color: isDark ? Colors.grey : Colors.black45),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: isDark ? const Color(0xFF364152) : Colors.black12), borderRadius: BorderRadius.circular(10.r)),
            focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFBEF364)), borderRadius: BorderRadius.circular(10.r)),
          ),
          onChanged: (v) => name = v,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFBEF364)),
            onPressed: () async {
              if (name.trim().isEmpty || name.trim() == currentName) { Navigator.pop(context); return; }
              Navigator.pop(context);
              await pos.updateCategory(id, name.trim());
            },
            child: const Text('SAVE', style: TextStyle(color: Color(0xFF111727), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, PosProvider pos, bool isDark) {
    String name = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E2938) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Add Category', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
        content: TextField(
          autofocus: true,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            labelText: 'Category Name',
            labelStyle: TextStyle(color: isDark ? Colors.grey : Colors.black45),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: isDark ? const Color(0xFF364152) : Colors.black12), borderRadius: BorderRadius.circular(10.r)),
            focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFBEF364)), borderRadius: BorderRadius.circular(10.r)),
          ),
          onChanged: (v) => name = v,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFBEF364)),
            onPressed: () async {
              if (name.trim().isEmpty) return;
              Navigator.pop(context);
              await pos.addCategory(name.trim());
            },
            child: const Text('SAVE', style: TextStyle(color: Color(0xFF111727), fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, PosProvider pos, int id, String name, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E2938) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Delete Category?', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
        content: Text('Delete category "$name"? Products connected will not be deleted.', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await pos.deleteCategory(id);
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}

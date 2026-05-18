import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/pos_provider.dart';
import '../models/product.dart';

class StockEntryScreen extends StatefulWidget {
  const StockEntryScreen({super.key});

  @override
  State<StockEntryScreen> createState() => _StockEntryScreenState();
}

class _StockEntryScreenState extends State<StockEntryScreen> {
  Product? _selectedProduct;
  final _qtyController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final pos = context.watch<PosProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Stok Masuk', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Pilih Produk', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12.h),
            
            // Product Selector
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Product>(
                  isExpanded: true,
                  hint: const Text('Cari Produk...'),
                  value: _selectedProduct,
                  items: pos.products.map((p) {
                    return DropdownMenuItem(
                      value: p,
                      child: Text('${p.name} (Sisa: ${p.stock})'),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedProduct = val),
                ),
              ),
            ),
            
            SizedBox(height: 24.h),
            const Text('Jumlah Stok Masuk', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12.h),
            TextField(
              controller: _qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Misal: 50',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.add_box_outlined),
              ),
            ),
            
            SizedBox(height: 24.h),
            const Text('Catatan (Opsional)', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12.h),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Contoh: Barang datang dari Supplier ABC',
                border: OutlineInputBorder(),
              ),
            ),
            
            const Spacer(),
            
            SizedBox(
              height: 56.h,
              child: ElevatedButton(
                onPressed: _selectedProduct == null || _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                ),
                child: _isSubmitting 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('SIMPAN STOK MASUK', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    if (_qtyController.text.isEmpty) return;
    
    setState(() => _isSubmitting = true);
    
    final pos = context.read<PosProvider>();
    final qty = int.tryParse(_qtyController.text) ?? 0;
    
    try {
      // Hit API adjust stock (Type: IN)
      final response = await pos.apiService.client.post('/stocks/adjust', data: {
        'product_id': _selectedProduct!.id,
        'type': 'in',
        'quantity': qty,
        'note': _noteController.text,
      });

      if (response.statusCode == 200 && mounted) {
        await pos.syncMasterData(); // Refresh product stock
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stok berhasil ditambahkan!'), backgroundColor: Colors.green)
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red)
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}

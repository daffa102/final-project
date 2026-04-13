import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/pos_provider.dart';
import '../models/product.dart';
import 'cart_screen.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final NumberFormat currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PosProvider>().syncMasterData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Katalog Menu', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: Colors.indigo),
            onPressed: () {
              context.read<PosProvider>().syncMasterData();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sinkronisasi dimulai...')));
            },
          ),
        ],
      ),
      body: Consumer<PosProvider>(
        builder: (context, pos, child) {
          if (pos.isLoading && pos.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Filter Kategori (Pil)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryTab(pos, 0, 'Semua Kategori'),
                      ...pos.categories.map((c) => _buildCategoryTab(pos, c.id, c.name)),
                    ],
                  ),
                ),
              ),
              
              // Grid Barang (Match Wireframe)
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // Memberi ruang aman untuk bottom bar
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: pos.products.length,
                  itemBuilder: (context, index) {
                    final product = pos.products[index];
                    return _buildProductCard(product, pos);
                  },
                ),
              ),
            ],
          );
        },
      ),
      // Tombol Keranjang Melayang di Bawah (Sticky Bottom Banner)
      bottomSheet: Consumer<PosProvider>(
        builder: (context, pos, child) {
          if (pos.cart.isEmpty) return const SizedBox.shrink();
          
          return GestureDetector(
            onTap: () {
               Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
            },
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shopping_bag, color: Colors.white),
                      const SizedBox(width: 8),
                      Text('${pos.cart.length} Item', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  Row(
                    children: [
                      Text(currencyFormat.format(pos.cartTotal), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, color: Colors.white),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryTab(PosProvider pos, int id, String title) {
    final isSelected = pos.selectedCategoryId == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.black87)),
        onSelected: (_) => pos.selectCategory(id),
        selectedColor: Colors.indigo,
        checkmarkColor: Colors.white,
      ),
    );
  }

  Widget _buildProductCard(Product product, PosProvider pos) {
    // Cek jumlah spesifik produk ini di keranjang
    final cartIndex = pos.cart.indexWhere((c) => c.product.id == product.id);
    final inCartQty = cartIndex >= 0 ? pos.cart[cartIndex].quantity : 0;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              color: Colors.grey.shade200,
              child: const Icon(Icons.image, size: 48, color: Colors.grey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(currencyFormat.format(product.sellingPrice), style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                
                // Jika sudah ada di keranjang, tampilkan tombol +/-
                inCartQty > 0 
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () => pos.decreaseQuantity(product),
                          child: Container(
                            decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(Icons.remove, color: Colors.red, size: 20),
                          ),
                        ),
                        Text('$inCartQty', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        InkWell(
                          onTap: () => pos.addToCart(product),
                          child: Container(
                            decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(Icons.add, color: Colors.green, size: 20),
                          ),
                        ),
                      ],
                    )
                  // Jika belum ada di keranjang, berikan tombol Add Full
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo.shade50,
                          foregroundColor: Colors.indigo,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => pos.addToCart(product),
                        child: const Text('TAMBAH'),
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:dio/dio.dart';
import '../../../core/api/api_service.dart';
import '../../../core/api/sync_service.dart';
import '../../../core/database/database_helper.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/cart_item.dart';

class PosProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  late final SyncService _syncService;

  PosProvider() {
     _syncService = SyncService(_apiService);
  }
  
  bool _isLoading = false;
  String? _error;
  
  List<Category> _categories = [];
  List<Product> _products = [];
  List<CartItem> _cart = [];
  
  int _selectedCategoryId = 0; // 0 = Semua

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Category> get categories => _categories;
  List<Product> get products => _selectedCategoryId == 0 
      ? _products 
      : _products.where((p) => p.categoryId == _selectedCategoryId).toList();
  List<CartItem> get cart => _cart;
  int get selectedCategoryId => _selectedCategoryId;

  double get cartTotal => _cart.fold(0, (sum, item) => sum + item.subtotal);

  // --- API Sync ---

  Future<void> syncMasterData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. PUSH: Dorong dulu transaksi nganggur yang tersimpan sejak offline (Jika bukan web)
      if (!kIsWeb) {
        final pushedCount = await _syncService.pushPendingTransactions();
        debugPrint('Berhasil sinkronisasi $pushedCount transaksi ke server');
      }

      // 2. PULL: Ambil data dari server
      final catResponse = await _apiService.client.get('/categories');
      final prodResponse = await _apiService.client.get('/products');
      
      if (catResponse.statusCode == 200 && prodResponse.statusCode == 200) {
        final List<dynamic> catData = catResponse.data['data'] ?? [];
        final List<dynamic> prodData = prodResponse.data['data'] ?? [];
        
        final catMaps = catData.map((e) {
          final cat = Category.fromJson(e);
          return cat.toMap();
        }).toList();

        final prodMaps = prodData.map((e) {
          final prod = Product.fromJson(e);
          return prod.toMap();
        }).toList();

        // Simpan ke SQLite untuk offline access ATAU simpan ke memory saja jika Web
        if (!kIsWeb) {
          if (catMaps.isNotEmpty) await DatabaseHelper.instance.upsertCategories(catMaps);
          if (prodMaps.isNotEmpty) await DatabaseHelper.instance.upsertProducts(prodMaps);
        } else {
          _categories = catMaps.map((e) => Category(id: e['id'], name: e['name'])).toList();
          _products = prodMaps.map((e) => Product.fromMap(e)).toList();
        }

      } else {
        _error = "Response tidak sukses dari server.";
      }
    } catch (e) {
      if (e is DioException) {
         _error = "Gagal sinkron. Coba cek koneksi. Menampilkan data offline.";
      } else {
         _error = e.toString();
      }
    }

    // Terlepas dari berhasil atau gagal narik API, load dari Local DB jika berjalan di mobile
    if (!kIsWeb) {
      await loadLocalData();
    }

    _isLoading = false;
    notifyListeners();
  }

  // --- Local Data Load ---

  Future<void> loadLocalData() async {
    final catMaps = await DatabaseHelper.instance.getCategories();
    final prodMaps = await DatabaseHelper.instance.getProducts();

    _categories = catMaps.map((e) => Category(id: e['id'], name: e['name'])).toList();
    _products = prodMaps.map((e) => Product.fromMap(e)).toList();
    
    notifyListeners();
  }

  void selectCategory(int id) {
    _selectedCategoryId = id;
    notifyListeners();
  }

  // --- Local Cart Logic ---

  void addToCart(Product product) {
    final index = _cart.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      if (_cart[index].quantity < product.stock) {
        _cart[index].quantity++;
      } else {
        _error = 'Stok tidak mencukupi';
      }
    } else {
      if (product.stock > 0) {
        _cart.add(CartItem(product: product));
      } else {
        _error = 'Stok kosong';
      }
    }
    notifyListeners();
  }

  void decreaseQuantity(Product product) {
    final index = _cart.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      if (_cart[index].quantity > 1) {
        _cart[index].quantity--;
      } else {
        _cart.removeAt(index);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  // --- Checkout Execution (Phase 4) ---
  
  Future<bool> processCheckout({required String paymentMethod, required double amountPaid}) async {
    if (_cart.isEmpty) return false;

    if (amountPaid < cartTotal) {
       _error = "Uang diterma kurang dari total belanja.";
       notifyListeners();
       return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Penomoran resi offline, aman anti-bentrok
      final invoiceNumber = 'INV-LCL-${DateTime.now().millisecondsSinceEpoch}';
      
      // Kalkulasi laba kotor
      double totalProfit = 0;
      for (var item in _cart) {
         totalProfit += (item.product.sellingPrice - item.product.buyingPrice) * item.quantity;
      }
      
      final transactionData = {
        'user_id': 1, // Offline Fallback ID pengguna
        'invoice_number': invoiceNumber,
        'payment_method': paymentMethod,
        'total_amount': cartTotal,
        'amount_paid': amountPaid,
        'change_amount': amountPaid - cartTotal,
        'profit': totalProfit,
        'status': 'completed',
        'created_at': DateTime.now().toIso8601String(),
      };

      final itemsData = _cart.map((item) => {
        'product_id': item.product.id,
        'product_name': item.product.name,
        'quantity': item.quantity,
        'selling_price': item.product.sellingPrice,
        'subtotal': item.subtotal,
      }).toList();

      final syncLogData = {
         'type': 'checkout',
         'payload': jsonEncode({
            'transaction': transactionData,
            'items': itemsData,
         }),
         'status': 'pending',
         'created_at': DateTime.now().toIso8601String(),
      };

      // Eksekusi atomik ke SQLIte Hp
      await DatabaseHelper.instance.executeLocalCheckout(
         transaction: transactionData,
         items: itemsData,
         syncLog: syncLogData,
      );

      // Reset Kasir dan Update Stok
      clearCart();
      await loadLocalData(); 
      
      _isLoading = false;
      notifyListeners();
      return true;

    } catch(e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

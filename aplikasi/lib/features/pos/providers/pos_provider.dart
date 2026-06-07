import 'dart:convert';
import 'package:flutter/foundation.dart' hide Category;
import 'package:dio/dio.dart' as dio;
import 'package:drift/drift.dart' as drift;
import '../../../core/api/api_service.dart';
import '../../../core/api/sync_service.dart';
import '../../../core/database/app_database.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/cart_item.dart';
import '../../../core/services/notification_service.dart';

class PosProvider with ChangeNotifier {
  final ApiService apiService = ApiService();
  final AppDatabase database;
  late final SyncService _syncService;

  PosProvider({required this.database}) {
     _syncService = SyncService(apiService, database);
  }
  
  bool _isLoading = false;
  String? _error;
  
  List<Category> _categories = [];
  List<Product> _products = [];
  final List<CartItem> _cart = [];
  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _manualTransactions = [];
  
  int _selectedCategoryId = 0; // 0 = Semua
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Category> get categories => _categories;
  
  List<Product> get products {
    List<Product> filtered = _selectedCategoryId == 0 
        ? _products 
        : _products.where((p) => p.categoryId == _selectedCategoryId).toList();
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) => 
        p.name.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    return filtered;
  }
  
  List<CartItem> get cart => _cart;
  List<Map<String, dynamic>> get transactions => _transactions;
  List<Map<String, dynamic>> get manualTransactions => _manualTransactions;
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
      final catResponse = await apiService.client.get('/categories');
      final prodResponse = await apiService.client.get('/products');
      
      if (catResponse.statusCode == 200 && prodResponse.statusCode == 200) {
        final List<dynamic> catData = catResponse.data['data'] is List ? catResponse.data['data'] : [];
        
        // Handle Laravel Pagination object for products
        List<dynamic> prodData = [];
        final dynamic pData = prodResponse.data['data'];
        if (pData is List) {
          prodData = pData;
        } else if (pData is Map && pData.containsKey('data')) {
          prodData = pData['data'];
        }
        
        final List<Category> cats = catData.map((e) => Category.fromJson(e)).toList();
        final List<Product> prods = prodData.map((e) => Product.fromJson(e)).toList();

        // Simpan ke SQLite untuk offline access ATAU simpan ke memory saja jika Web
        if (!kIsWeb) {
          // Batch upsert using Drift
          await database.batch((batch) {
            batch.insertAllOnConflictUpdate(database.categories, cats.map((c) => CategoriesCompanion.insert(
              id: drift.Value(c.id),
              name: c.name,
            )).toList());
            
            batch.insertAllOnConflictUpdate(database.products, prods.map((p) => ProductsCompanion.insert(
              id: drift.Value(p.id),
              categoryId: p.categoryId,
              name: p.name,
              buyingPrice: p.buyingPrice,
              sellingPrice: p.sellingPrice,
              stock: p.stock,
              minStock: drift.Value(p.minStock),
              imagePath: drift.Value(p.imagePath),
            )).toList());
          });
        } else {
          _categories = cats;
          _products = prods;
        }

      } else {
        _error = "Response tidak sukses dari server.";
      }
    } catch (e) {
      if (e is dio.DioException) {
         _error = "Gagal sinkron. Coba cek koneksi. Menampilkan data offline.";
      } else {
         _error = e.toString();
      }
    }

    // Terlepas dari berhasil atau gagal narik API, load dari Local DB jika berjalan di mobile
    if (!kIsWeb) {
      await loadLocalData();
      await fetchTransactions();
      await fetchManualTransactions();
    } else {
      // Di web: transactions juga diambil dari API
      await fetchTransactionsFromApi();
    }

    _isLoading = false;
    notifyListeners();
  }

  // --- Local Data Load ---

  Future<void> loadLocalData() async {
    final catRows = await database.select(database.categories).get();
    final prodRows = await database.select(database.products).get();

    _categories = catRows.map((e) => Category(id: e.id, name: e.name)).toList();
    _products = prodRows.map((e) => Product(
      id: e.id, 
      categoryId: e.categoryId, 
      name: e.name, 
      buyingPrice: e.buyingPrice, 
      sellingPrice: e.sellingPrice, 
      stock: e.stock,
      minStock: e.minStock,
      imagePath: e.imagePath,
    )).toList();
    
    notifyListeners();
  }

  void selectCategory(int id) {
    _selectedCategoryId = id;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // --- Local Cart Logic ---

  void addToCart(Product product) {
    final index = _cart.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      if (_cart[index].quantity < product.stock) {
        _cart[index] = _cart[index].copyWith(quantity: _cart[index].quantity + 1);
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

  void setQuantity(Product product, int quantity) {
    final index = _cart.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      if (quantity > 0) {
        if (quantity <= product.stock) {
          _cart[index] = _cart[index].copyWith(quantity: quantity);
        } else {
          _error = 'Stok tidak mencukupi (Tersedia: ${product.stock})';
        }
      } else {
        _cart.removeAt(index);
      }
    } else {
      if (quantity > 0) {
        if (quantity <= product.stock) {
          _cart.add(CartItem(product: product, quantity: quantity));
        } else {
          _error = 'Stok tidak mencukupi (Tersedia: ${product.stock})';
        }
      }
    }
    notifyListeners();
  }

  void decreaseQuantity(Product product) {
    final index = _cart.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      if (_cart[index].quantity > 1) {
        _cart[index] = _cart[index].copyWith(quantity: _cart[index].quantity - 1);
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
  
  Future<Map<String, dynamic>?> initiateMidtransPayment({required String paymentMethod}) async {
    if (_cart.isEmpty) return null;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final itemsPayload = _cart.map((item) => {
        'product_id': item.product.id,
        'quantity': item.quantity,
        'selling_price': item.product.sellingPrice,
      }).toList();

      final response = await apiService.client.post('/transactions/initiate-payment', data: {
        'items': itemsPayload,
        'payment_method': paymentMethod,
      });

      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return response.data['data'];
      } else {
        _error = response.data['message'] ?? 'Gagal memulai pembayaran';
      }
    } on dio.DioException catch (e) {
      final resData = e.response?.data;
      if (resData is Map && resData.containsKey('message')) {
        _error = resData['message'];
      } else if (resData is Map && resData.containsKey('errors')) {
        final errors = resData['errors'];
        if (errors is Map) {
          _error = errors.values.first is List ? errors.values.first[0] : errors.values.first.toString();
        } else {
          _error = errors.toString();
        }
      } else {
        _error = e.response?.statusMessage ?? e.message;
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<String> checkPaymentStatus(String orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await apiService.client.get('/transactions/check-status/$orderId');
      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return response.data['transaction_status'] ?? 'pending';
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return 'pending';
  }

  Future<bool> processCheckout({required String paymentMethod, required double amountPaid}) async {
    if (_cart.isEmpty) return false;

    if (amountPaid < cartTotal) {
       _error = "Uang diterima kurang dari total belanja.";
       notifyListeners();
       return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final invoiceNumber = 'INV-${DateTime.now().millisecondsSinceEpoch}';
      double totalProfit = 0;
      for (var item in _cart) {
         totalProfit += (item.product.sellingPrice - item.product.buyingPrice) * item.quantity;
      }

      if (kIsWeb) {
        // Mode Web: kirim transaksi langsung ke server via API
        final itemsPayload = _cart.map((item) => {
          'product_id': item.product.id,
          'quantity': item.quantity,
          'selling_price': item.product.sellingPrice,
          'subtotal': item.subtotal,
        }).toList();

        final response = await apiService.client.post('/transactions', data: {
          'invoice_number': invoiceNumber,
          'payment_method': paymentMethod,
          'total_amount': cartTotal,
          'amount_paid': amountPaid,
          'change_amount': amountPaid - cartTotal,
          'profit': totalProfit,
          'status': 'completed',
          'items': itemsPayload,
        });

        if (response.statusCode == 200 || response.statusCode == 201) {
          clearCart();
          _isLoading = false;
          notifyListeners();
          // Refresh data in background — don't let sync failures affect checkout success
          try {
            await syncMasterData();
          } catch (_) {}
          return true;
        } else {
          _error = response.data['message'] ?? 'Gagal memproses transaksi';
        }
      } else {
        // Mode Mobile: simpan ke Drift (Transaction)
        await database.transaction(() async {
          final trxId = await database.into(database.transactions).insert(TransactionsCompanion.insert(
            userId: 1,
            invoiceNumber: invoiceNumber,
            paymentMethod: paymentMethod,
            totalAmount: cartTotal,
            amountPaid: amountPaid,
            changeAmount: amountPaid - cartTotal,
            profit: totalProfit,
            status: 'completed',
            createdAt: DateTime.now().toIso8601String(),
          ));

          for (var item in _cart) {
            await database.into(database.transactionItems).insert(TransactionItemsCompanion.insert(
              transactionId: trxId,
              productId: item.product.id,
              productName: item.product.name,
              quantity: item.quantity,
              sellingPrice: item.product.sellingPrice,
              subtotal: item.subtotal,
            ));

            // Kurangi stok di Drift
            final newStock = item.product.stock - item.quantity;
            await (database.update(database.products)..where((t) => t.id.equals(item.product.id)))
                .write(ProductsCompanion(stock: drift.Value(newStock)));

            // Trigger Low Stock Notification if below threshold
            if (newStock <= item.product.minStock) {
              await NotificationService().showLowStockNotification(
                id: item.product.id,
                productName: item.product.name,
                currentStock: newStock,
              );
            }
          }

          // Antrian Sync
          await database.into(database.syncLogs).insert(SyncLogsCompanion.insert(
            type: 'checkout',
            payload: jsonEncode({
              'transaction': {
                'user_id': 1,
                'invoice_number': invoiceNumber,
                'payment_method': paymentMethod,
                'total_amount': cartTotal,
                'amount_paid': amountPaid,
                'change_amount': amountPaid - cartTotal,
                'profit': totalProfit,
                'status': 'completed',
                'created_at': DateTime.now().toIso8601String(),
              },
              'items': _cart.map((i) => {
                'product_id': i.product.id,
                'product_name': i.product.name,
                'quantity': i.quantity,
                'selling_price': i.product.sellingPrice,
                'subtotal': i.subtotal,
              }).toList(),
            }),
            status: 'pending',
            createdAt: DateTime.now().toIso8601String(),
          ));
        });

        clearCart();
        await loadLocalData();
        await fetchTransactions();
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on dio.DioException catch (e) {
      final resData = e.response?.data;
      if (resData is Map && resData.containsKey('message')) {
        _error = resData['message'];
      } else if (resData is Map && resData.containsKey('errors')) {
        final errors = resData['errors'];
        if (errors is Map) {
          _error = errors.values.first is List ? errors.values.first[0] : errors.values.first.toString();
        } else {
          _error = errors.toString();
        }
      } else {
        _error = e.response?.statusMessage ?? e.message;
      }
    } catch(e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> fetchTransactions() async {
    if (kIsWeb) {
      await fetchTransactionsFromApi();
      return;
    }
    final rows = await (database.select(database.transactions)..orderBy([(t) => drift.OrderingTerm.desc(t.createdAt)])).get();
    _transactions = rows.map((e) => {
      'id': e.id,
      'invoice_number': e.invoiceNumber,
      'payment_method': e.paymentMethod,
      'total_amount': e.totalAmount,
      'profit': e.profit,
      'created_at': e.createdAt,
    }).toList();
    notifyListeners();
  }

  Future<Map<String, dynamic>?> getTransactionDetail(int id) async {
    try {
      final response = await apiService.client.get('/transactions/$id');
      if (response.statusCode == 200) {
        return response.data['data'];
      }
    } catch (e) {
      debugPrint('Gagal ambil detail transaksi: $e');
    }
    return null;
  }

  Future<void> fetchTransactionsFromApi() async {
    try {
      final response = await apiService.client.get('/transactions');
      if (response.statusCode == 200 && response.data['data'] != null) {
        final data = response.data['data'];
        if (data is List) {
          _transactions = List<Map<String, dynamic>>.from(data);
        } else if (data is Map && data['data'] is List) {
          _transactions = List<Map<String, dynamic>>.from(data['data']);
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Gagal ambil transaksi dari API: $e');
    }
  }

  Future<void> fetchManualTransactions() async {
    if (kIsWeb) return;
    final rows = await (database.select(database.manualTransactions)..orderBy([(t) => drift.OrderingTerm.desc(t.createdAt)])).get();
    _manualTransactions = rows.map((e) => {
      'id': e.id,
      'type': e.type,
      'category': e.category,
      'amount': e.amount,
      'note': e.note,
      'created_at': e.createdAt,
    }).toList();
    notifyListeners();
  }

  Future<void> addManualTransaction({
    required String type,
    required String category,
    required double amount,
    String? note,
  }) async {
    if (kIsWeb) {
      // Mode Web: kirim ke API
      try {
        final response = await apiService.client.post('/finance/manual-transactions', data: {
          'type': type,
          'category': category,
          'amount': amount,
          'note': note ?? '',
          'created_at': DateTime.now().toIso8601String(),
        });
        if (response.statusCode == 200 || response.statusCode == 201) {
          // Tambah ke list lokal agar UI langsung update
          _manualTransactions.insert(0, {
            'type': type,
            'category': category,
            'amount': amount,
            'note': note,
            'created_at': DateTime.now().toIso8601String(),
          });
          notifyListeners();
        }
      } catch (e) {
        // Jika API belum ada, fallback: tambah ke memory saja agar UI tetap update
        _manualTransactions.insert(0, {
          'type': type,
          'category': category,
          'amount': amount,
          'note': note,
          'created_at': DateTime.now().toIso8601String(),
        });
        notifyListeners();
        debugPrint('addManualTransaction (web) fallback to memory: $e');
      }
      return;
    }
    // Mode Mobile: simpan ke Drift DB
    await database.into(database.manualTransactions).insert(ManualTransactionsCompanion.insert(
      type: type,
      category: category,
      amount: amount,
      note: drift.Value(note),
      createdAt: DateTime.now().toIso8601String(),
    ));
    await fetchManualTransactions();
  }

  Future<void> updateProductStock(Product product, int newStock) async {
    if (kIsWeb) {
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index >= 0) {
        _products[index] = product.copyWith(stock: newStock);
      }
    } else {
      await (database.update(database.products)..where((t) => t.id.equals(product.id)))
          .write(ProductsCompanion(stock: drift.Value(newStock)));
      await loadLocalData();
    }
    notifyListeners();
  }

  // ─── CRUD Produk ──────────────────────────────

  Future<bool> addProduct(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final catId = data['category_id'];
      final formData = dio.FormData.fromMap({
        'name':          data['name'] ?? '',
        if (catId != null && catId.toString().isNotEmpty) 'category_id': catId,
        'buying_price':  data['buying_price'] ?? 0,
        'selling_price': data['selling_price'] ?? 0,
        'stock':         data['stock'] ?? 0,
        'min_stock':     data['min_stock'] ?? 5,
        'is_active':     1,
      });

      if (data['image_bytes'] != null) {
        formData.files.add(MapEntry('image_url',
          dio.MultipartFile.fromBytes(data['image_bytes'], filename: data['image_name'] ?? 'product.jpg')));
      } else if (!kIsWeb && data['image_path'] != null && !data['image_path'].toString().startsWith('http') && !data['image_path'].toString().startsWith('storage')) {
        formData.files.add(MapEntry('image_url',
          await dio.MultipartFile.fromFile(data['image_path'], filename: 'product.jpg')));
      }

      final response = await apiService.client.post('/products', data: formData);

      if (response.statusCode == 201) {
        // Refresh product list from API response directly (avoid nested loading loop)
        final newProd = Product.fromJson(response.data['data']);
        _products.add(newProd);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.data['message'] ?? 'Gagal menambah produk';
      }
    } on dio.DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'];
        _error = errors != null && errors is Map
            ? (errors.values.first is List ? errors.values.first[0] : errors.values.first.toString())
            : e.response?.data['message'] ?? 'Validasi gagal';
      } else {
        _error = e.response?.data?['message'] ?? 'Gagal terhubung ke server (${e.message})';
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> updateProduct(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final catId = data['category_id'];
      final formData = dio.FormData.fromMap({
        '_method':       'PUT',
        'name':          data['name'] ?? '',
        if (catId != null && catId.toString().isNotEmpty) 'category_id': catId,
        'buying_price':  data['buying_price'] ?? 0,
        'selling_price': data['selling_price'] ?? 0,
        'stock':         data['stock'] ?? 0, // Added stock here!
        'min_stock':     data['min_stock'] ?? 5,
        'is_active':     1,
      });

      if (data['image_bytes'] != null) {
        formData.files.add(MapEntry('image_url',
          dio.MultipartFile.fromBytes(data['image_bytes'], filename: data['image_name'] ?? 'product.jpg')));
      } else if (!kIsWeb && data['image_path'] != null && !data['image_path'].toString().startsWith('http') && !data['image_path'].toString().startsWith('storage')) {
        formData.files.add(MapEntry('image_url',
          await dio.MultipartFile.fromFile(data['image_path'], filename: 'product.jpg')));
      }

      final response = await apiService.client.post('/products/$id', data: formData);

      if (response.statusCode == 200) {
        final updated = Product.fromJson(response.data['data']);
        final index = _products.indexWhere((p) => p.id == id);
        if (index >= 0) _products[index] = updated;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.data['message'] ?? 'Gagal memperbarui produk';
      }
    } on dio.DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'Gagal terhubung ke server';
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> deleteProduct(int id) async {
    try {
      final response = await apiService.client.delete('/products/$id');
      if (response.statusCode == 200) {
        _products.removeWhere((p) => p.id == id);
        notifyListeners();
        return true;
      }
    } on dio.DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'Gagal menghapus produk';
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    return false;
  }

  // ─── CRUD Kategori ───────────────────────────

  Future<bool> addCategory(String name) async {
    try {
      final response = await apiService.client.post('/categories', data: {'name': name});
      if (response.statusCode == 201) {
        final cat = Category(
          id:   response.data['data']['id'],
          name: response.data['data']['name'],
        );
        _categories.add(cat);
        notifyListeners();
        return true;
      }
    } on dio.DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'Gagal menambah kategori';
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    return false;
  }

  Future<bool> deleteCategory(int id) async {
    try {
      final response = await apiService.client.delete('/categories/$id');
      if (response.statusCode == 200) {
        _categories.removeWhere((c) => c.id == id);
        notifyListeners();
        return true;
      }
    } on dio.DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'Gagal menghapus kategori';
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    return false;
  }

  Future<bool> updateCategory(int id, String name) async {
    try {
      final response = await apiService.client.put('/categories/$id', data: {'name': name});
      if (response.statusCode == 200) {
        final index = _categories.indexWhere((c) => c.id == id);
        if (index >= 0) {
          _categories[index] = Category(id: id, name: name);
          notifyListeners();
        }
        return true;
      }
    } on dio.DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'Gagal mengubah kategori';
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    return false;
  }
}

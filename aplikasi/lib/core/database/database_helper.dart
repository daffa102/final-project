import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (kIsWeb) throw Exception("Dijalankan di web browser, mematikan fungsi SQLite lokal.");
    if (_database != null) return _database!;
    _database = await _initDB('pos_mobile.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';
    const nullableTextType = 'TEXT';
    
    // 1. Categories Table (Read-only on mobile, synced from server)
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY,
        name $textType,
        description $nullableTextType,
        created_at $textType
      )
    ''');

    // 2. Products Table (Read-only on mobile, synced from server)
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY,
        category_id $intType,
        name $textType,
        buying_price $realType,
        selling_price $realType,
        stock $intType,
        created_at $textType,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    // 3. Transactions Table
    await db.execute('''
      CREATE TABLE transactions (
        id $idType,
        user_id $intType,
        invoice_number $textType,
        payment_method $textType,
        total_amount $realType,
        amount_paid $realType,
        change_amount $realType,
        profit $realType,
        status $textType,
        note $nullableTextType,
        created_at $textType
      )
    ''');

    // 4. Transaction Items Table
    await db.execute('''
      CREATE TABLE transaction_items (
        id $idType,
        transaction_id $intType,
        product_id $intType,
        product_name $textType,
        quantity $intType,
        selling_price $realType,
        subtotal $realType,
        FOREIGN KEY (transaction_id) REFERENCES transactions (id),
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    // 5. Sync Logs Table (To track data that needs to be pushed to the server)
    await db.execute('''
      CREATE TABLE sync_logs (
        id $idType,
        type $textType,
        payload $textType,
        status $textType,
        created_at $textType
      )
    ''');
  }

  // --- Data Sync Methods (Phase 3) ---

  Future<void> upsertCategories(List<Map<String, dynamic>> categories) async {
    final db = await instance.database;
    Batch batch = db.batch();
    for (var cat in categories) {
      batch.insert(
        'categories', 
        cat,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> upsertProducts(List<Map<String, dynamic>> products) async {
    final db = await instance.database;
    Batch batch = db.batch();
    for (var prod in products) {
      batch.insert(
        'products', 
        prod,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await instance.database;
    return await db.query('categories');
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    final db = await instance.database;
    return await db.query('products');
  }

  // --- Checkout Execution (Phase 4) ---

  Future<void> executeLocalCheckout({
    required Map<String, dynamic> transaction,
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> syncLog,
  }) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      // 1. Catat ke tabel transaksi offline
      final trxId = await txn.insert('transactions', transaction);

      // 2. Catat detail barang & Kurangi stok offline
      for (var item in items) {
        item['transaction_id'] = trxId;
        await txn.insert('transaction_items', item);
        
        // Kurangi stok produk secara lokal
        await txn.rawUpdate(
          'UPDATE products SET stock = stock - ? WHERE id = ?',
          [item['quantity'], item['product_id']]
        );
      }

      // 3. Masukkan ke dalam antrian "Pending Sync"
      await txn.insert('sync_logs', syncLog);
    });
  }

  // --- Rekonsiliasi Tutup Kasir (Phase 6) ---
  Future<double> getExpectedCashForToday() async {
    final db = await instance.database;
    final String todayDate = DateTime.now().toIso8601String().substring(0, 10); // Format YYYY-MM-DD
    
    final result = await db.rawQuery('''
      SELECT SUM(total_amount) as total 
      FROM transactions 
      WHERE payment_method = 'cash' 
      AND created_at LIKE '$todayDate%'
    ''');
    
    if (result.isNotEmpty && result.first['total'] != null) {
      return double.tryParse(result.first['total'].toString()) ?? 0.0;
    }
    return 0.0;
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

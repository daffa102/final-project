import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import '../database/app_database.dart';
import '../../features/pos/models/category.dart';
import '../../features/pos/models/product.dart';
import 'api_service.dart';

class SyncService {
  final ApiService _apiService;
  final AppDatabase database;
  
  SyncService(this._apiService, this.database);

  Future<int> pushPendingTransactions() async {
    int syncedCount = 0;
    
    // Tarik semua log transaksi yang statusnya masih 'pending'
    final pendingLogs = await (database.select(database.syncLogs)..where((t) => t.status.equals('pending'))).get();

    if (pendingLogs.isEmpty) return 0;

    for (var log in pendingLogs) {
      if (log.type == 'checkout') {
         final payload = jsonDecode(log.payload);
         
         final trx = payload['transaction'];
         final items = payload['items'] as List;

         // Transformasi data agar persis DENGAN format request asli Backend Laravel
         final backendPayload = {
           'payment_method': trx['payment_method'],
           'amount_paid': trx['amount_paid'],
           'items': items.map((i) => {
             'product_id': i['product_id'],
             'quantity': i['quantity']
           }).toList(),
         };

         try {
           final response = await _apiService.client.post('/transactions', data: backendPayload);
           
           if ((response.statusCode == 200 || response.statusCode == 201) && response.data['success'] == true) {
              // Jika server menerima, matikan status 'pending' menjadi 'synced'
              await (database.update(database.syncLogs)..where((t) => t.id.equals(log.id)))
                  .write(const SyncLogsCompanion(status: drift.Value('synced')));

              // Update status transaksi utama juga
              await (database.update(database.transactions)..where((t) => t.invoiceNumber.equals(trx['invoice_number'])))
                  .write(const TransactionsCompanion(status: drift.Value('synced')));
              
              syncedCount++;
           }
         } catch (e) {
            continue; 
         }
      }
    }
    
    return syncedCount;
  }

  Future<void> pullMasterData() async {
    try {
      final catResponse = await _apiService.client.get('/categories');
      final prodResponse = await _apiService.client.get('/products');
      
      if (catResponse.statusCode == 200 && prodResponse.statusCode == 200) {
        final List<dynamic> catData = catResponse.data['data'] is List ? catResponse.data['data'] : [];
        
        List<dynamic> prodData = [];
        final dynamic pData = prodResponse.data['data'];
        if (pData is List) {
          prodData = pData;
        } else if (pData is Map && pData.containsKey('data')) {
          prodData = pData['data'];
        }
        
        final List<Category> cats = catData.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
        final List<Product> prods = prodData.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();

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
      }
    } catch (e) {
      rethrow;
    }
  }
}

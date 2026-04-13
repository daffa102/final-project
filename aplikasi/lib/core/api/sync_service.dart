import 'dart:convert';
import 'package:dio/dio.dart';
import '../database/database_helper.dart';
import 'api_service.dart';

class SyncService {
  final ApiService _apiService;
  
  SyncService(this._apiService);

  Future<int> pushPendingTransactions() async {
    final db = await DatabaseHelper.instance.database;
    int syncedCount = 0;
    
    // Tarik semua log transaksi yang statusnya masih 'pending'
    final pendingLogs = await db.query(
      'sync_logs',
      where: 'status = ?',
      whereArgs: ['pending'],
    );

    if (pendingLogs.isEmpty) return 0;

    for (var log in pendingLogs) {
      if (log['type'] == 'checkout') {
         final payloadStr = log['payload'] as String;
         final payload = jsonDecode(payloadStr);
         
         final trx = payload['transaction'];
         final items = payload['items'] as List;

         // Transformasi data agar persis DENGAN format request asli Backend Laravel
         final backendPayload = {
           'payment_method': trx['payment_method'],
           'cash_received': trx['amount_paid'],
           'items': items.map((i) => {
             'product_id': i['product_id'],
             'quantity': i['quantity']
           }).toList(),
         };

         try {
           final response = await _apiService.client.post('/transactions', data: backendPayload);
           
           if ((response.statusCode == 200 || response.statusCode == 201) && response.data['success'] == true) {
              // Jika server menerima, matikan status 'pending' menjadi 'synced'
              await db.update(
                 'sync_logs',
                 {'status': 'synced'},
                 where: 'id = ?',
                 whereArgs: [log['id']]
              );

              // Update status transaksi utama juga (Opsional namun bagus untuk historis)
              await db.update(
                 'transactions',
                 {'status': 'synced'},
                 where: 'invoice_number = ?',
                 whereArgs: [trx['invoice_number']]
              );
              
              syncedCount++;
           }
         } catch (e) {
            // Jika ada DioException atau Timeout, biarkan statysnya tetap 'pending' 
            // Loop berjalan terus untuk percobaan Sync berikutnya
            continue; 
         }
      }
    }
    
    return syncedCount; // Mengembalikan jumlah transaksi yang sukses terkirim
  }
}

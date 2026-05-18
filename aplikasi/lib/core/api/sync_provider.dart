import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/app_database.dart';
import 'api_service.dart';
import 'sync_service.dart';

class SyncProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AppDatabase database;
  late final SyncService _syncService;
  
  bool _isSyncing = false;
  String? _lastSyncStatus;
  Timer? _syncTimer;

  bool get isSyncing => _isSyncing;
  String? get lastSyncStatus => _lastSyncStatus;

  SyncProvider({required this.database}) {
    _syncService = SyncService(_apiService, database);
    startAutoSync(); // Start by default
  }

  void startAutoSync() async {
    _syncTimer?.cancel();
    
    final prefs = await SharedPreferences.getInstance();
    final frequency = prefs.getString('sync_frequency') ?? '1_hour';
    
    if (frequency == 'manual') return;

    Duration duration;
    switch (frequency) {
      case '1_hour': duration = const Duration(hours: 1); break;
      case '6_hours': duration = const Duration(hours: 6); break;
      case 'daily': duration = const Duration(days: 1); break;
      default: duration = const Duration(hours: 1);
    }

    _syncTimer = Timer.periodic(duration, (timer) {
      syncAll();
    });
    
    debugPrint('Auto-sync started with frequency: $frequency');
  }

  void stopAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  Future<void> syncAll() async {
    _isSyncing = true;
    _lastSyncStatus = 'Sinkronisasi dimulai...';
    notifyListeners();

    try {
      int count = await _syncService.pushPendingTransactions();
      await _syncService.pullMasterData(); // Also refresh products/categories
      _lastSyncStatus = 'Berhasil sinkronisasi. $count transaksi terkirim.';
    } catch (e) {
      _lastSyncStatus = 'Gagal sinkronisasi: $e';
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
}

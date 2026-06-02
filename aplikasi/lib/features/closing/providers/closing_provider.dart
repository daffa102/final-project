import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_service.dart';
import '../../../core/database/app_database.dart';

class ClosingProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AppDatabase database;

  ClosingProvider({required this.database});
  
  bool _isLoading = false;
  String? _error;
  
  double _expectedCash = 0.0;
  double _actualCash = 0.0;
  String _notes = '';
  double _qrisAmount = 0.0;
  double _transferAmount = 0.0;
  double _totalSales = 0.0;
  int _totalTrx = 0;
  List<Map<String, dynamic>> _bestSelling = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  double get expectedCash => _expectedCash;
  double get actualCash => _actualCash;
  double get difference => _actualCash - _expectedCash;
  double get qrisAmount => _qrisAmount;
  double get transferAmount => _transferAmount;
  double get totalSales => _totalSales;
  int get totalTrx => _totalTrx;
  List<Map<String, dynamic>> get bestSelling => _bestSelling;

  // 1. Hitung uang yang BERHARAP ada di laci (Expected Cash)
  Future<void> fetchExpectedCash() async {
    _isLoading = true;
    notifyListeners();

    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final response = await _apiService.client.get('/closing-summary', queryParameters: {'date': today});
      
      if (response.statusCode == 200 && response.data['data'] != null) {
        final data = response.data['data'];
        _expectedCash = (data['cash_amount'] ?? 0).toDouble();
        _qrisAmount = (data['qris_amount'] ?? 0).toDouble();
        _transferAmount = (data['transfer_amount'] ?? 0).toDouble();
        _totalSales = (data['total_sales'] ?? 0).toDouble();
        _totalTrx = (data['total_transactions'] ?? 0).toInt();
        final List<dynamic> bs = data['best_selling'] is List ? data['best_selling'] : [];
        _bestSelling = bs.map((item) => {
          'product_name': item['product_name']?.toString() ?? 'Produk',
          'total_qty': int.tryParse(item['total_qty']?.toString() ?? '0') ?? 0,
        }).toList();
      }
    } catch (e) {
      _error = "Gagal mengambil data pendapatan: $e";
    }

    _isLoading = false;
    notifyListeners();
  }

  // 2. Simpan input uang fisik kasir secara live (Actual Cash)
  void setActualCash(double amount) {
    _actualCash = amount;
    notifyListeners();
  }
  
  void setNotes(String notes) {
    _notes = notes;
  }

  // 3. Tembakkan ke Server Admin Web untuk dicatat (Daily Closing)
  Future<bool> submitDailyClosing(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final payload = {
        'user_id': userId,
        'expected_cash': _expectedCash,
        'actual_cash': _actualCash,
        'difference': difference,
        'notes': _notes,
        'note': _notes,
        'date': DateTime.now().toIso8601String().substring(0, 10), // YYYY-MM-DD
        'closing_date': DateTime.now().toIso8601String(),
      };

      // Tembak laporan ke Web Backend (Laravel)
      final response = await _apiService.client.post('/daily-closing', data: payload);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.data['message'] ?? 'Berhasil disimpan lokal, tetapi gagal melapor ke server utama.';
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'];
        if (errors != null && errors is Map) {
          _error = errors.values.first is List ? errors.values.first[0] : errors.values.first.toString();
        } else {
          _error = e.response?.data['message'] ?? 'Data tidak valid';
        }
      } else {
        _error = "Server tidak merespon: ${e.response?.data?['message'] ?? e.message}";
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_service.dart';
import '../../../core/database/database_helper.dart';

class ClosingProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  bool _isLoading = false;
  String? _error;
  
  double _expectedCash = 0.0;
  double _actualCash = 0.0;
  String _notes = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  double get expectedCash => _expectedCash;
  double get actualCash => _actualCash;
  double get difference => _actualCash - _expectedCash;

  // 1. Hitung uang yang BERHARAP ada di laci (Expected Cash)
  Future<void> fetchExpectedCash() async {
    _isLoading = true;
    notifyListeners();

    try {
      _expectedCash = await DatabaseHelper.instance.getExpectedCashForToday();
    } catch (e) {
      _error = "Gagal mengambil data pendapatan lokal: $e";
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
        'closing_date': DateTime.now().toIso8601String(),
      };

      // Tembak laporan ke Web Backend (Laravel)
      final response = await _apiService.client.post('/daily-closing', data: payload);

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data['success'] == true) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.data['message'] ?? 'Berhasil disimpan lokal, tetapi gagal melapor ke server utama.';
      }
    } on DioException catch (e) {
      _error = "Server tidak merespon: ${e.response?.data['message'] ?? e.message}";
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}

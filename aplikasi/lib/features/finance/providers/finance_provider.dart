import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_service.dart';

import '../../../core/database/app_database.dart';

class FinanceProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AppDatabase database;

  FinanceProvider({required this.database});

  bool _isLoading = false;
  String? _error;
  
  List<dynamic> _expenses = [];
  List<dynamic> _incomes = [];
  Map<String, dynamic> _summary = {
    'revenue': 0.0,
    'gross_profit': 0.0,
    'other_income': 0.0,
    'expenses': 0.0,
    'net_profit': 0.0,
  };

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<dynamic> get expenses => _expenses;
  List<dynamic> get incomes => _incomes;
  Map<String, dynamic> get summary => _summary;

  // Fetch Laba Rugi Summary (Point 14)
  Future<void> fetchFinanceSummary({int? month, int? year}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final response = await _apiService.client.get('/finance/summary', queryParameters: {
        'month': month ?? now.month,
        'year': year ?? now.year,
      });

      if (response.statusCode == 200) {
        _summary = response.data['data'];
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Fetch Expenses (Point 12)
  Future<void> fetchExpenses() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.client.get('/finance/expenses');
      if (response.statusCode == 200) {
        _expenses = response.data['data']['data'] ?? [];
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Store Expense (Point 12)
  Future<bool> addExpense({
    required String name,
    required double amount,
    required String category,
    required DateTime date,
    String? note,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.client.post('/finance/expenses', data: {
        'name': name,
        'amount': amount,
        'category': category,
        'expense_date': date.toIso8601String().substring(0, 10),
        'note': note,
      });

      if (response.statusCode == 201) {
        await fetchExpenses(); // Refresh list
        return true;
      }
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Gagal menyimpan pengeluaran';
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Fetch Incomes
  Future<void> fetchIncomes() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.client.get('/finance/incomes');
      if (response.statusCode == 200) {
        _incomes = response.data['data']['data'] ?? [];
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Store Income
  Future<bool> addIncome({
    required String name,
    required double amount,
    required DateTime date,
    String? note,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.client.post('/finance/incomes', data: {
        'name': name,
        'amount': amount,
        'income_date': date.toIso8601String().substring(0, 10),
        'note': note,
      });

      if (response.statusCode == 201) {
        await fetchIncomes();
        return true;
      }
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Gagal menyimpan pemasukan';
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}

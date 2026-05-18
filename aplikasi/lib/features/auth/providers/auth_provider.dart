import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  bool _isLoading = false;
  String? _error;
  String? _token;
  String? _userName;
  String? _userEmail;
  DateTime? _subscriptionUntil;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null;
  String get userName => _userName ?? 'Pengguna';
  String get userEmail => _userEmail ?? 'email@umkm.com';
  
  bool get isSubscriptionActive {
    if (_subscriptionUntil == null) return true; // Default to true if not set yet
    return _subscriptionUntil!.isAfter(DateTime.now());
  }

  Future<void> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _userName = prefs.getString('user_name');
    _userEmail = prefs.getString('user_email');
    final subStr = prefs.getString('subscription_until');
    if (subStr != null) {
      _subscriptionUntil = DateTime.tryParse(subStr);
    }
    
    if (_token != null) {
      _apiService.setupAuthInterceptor(_token!);
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.client.post('/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        _token = response.data['access_token'];
        _userName = response.data['user']['name'];
        _userEmail = response.data['user']['email'];
        final subStr = response.data['user']['subscription_until'];
        if (subStr != null) {
          _subscriptionUntil = DateTime.tryParse(subStr);
        }
        
        // Simpan ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setString('user_name', _userName!);
        await prefs.setString('user_email', _userEmail!);
        if (subStr != null) {
          await prefs.setString('subscription_until', subStr);
        }
        
        _apiService.setupAuthInterceptor(_token!);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.data['message'] ?? 'Login gagal.';
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
         _error = e.response?.data['message'] ?? 'Email atau password salah';
      } else {
        _error = 'Koneksi ke server gagal. Pastikan API berjalan.';
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> getProfile() async {
    try {
      final response = await _apiService.client.get('/user');
      if (response.statusCode == 200) {
        _userName = response.data['name'];
        _userEmail = response.data['email'];
        final subStr = response.data['subscription_until'];
        if (subStr != null) {
          _subscriptionUntil = DateTime.tryParse(subStr);
        }
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', _userName!);
        await prefs.setString('user_email', _userEmail!);
        if (subStr != null) {
          await prefs.setString('subscription_until', subStr);
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error refreshing profile: $e');
    }
  }

  // Update register with phone support
  Future<bool> register({
    required String name,
    required String adminEmail,
    required String personalEmail,
    required String phone,
    required String password,
    required String secondPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.client.post('/register', data: {
        'name': name,
        'email': adminEmail, // Now used as the primary email
        'phone': phone,
        'password': password,
        'password_confirmation': password, // Sync with backend's confirmed rule
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        _token = response.data['access_token'];
        _userName = response.data['user']['name'];
        _userEmail = response.data['user']['email'];
        final subStr = response.data['user']['subscription_until'];
        if (subStr != null) {
          _subscriptionUntil = DateTime.tryParse(subStr);
        }
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setString('user_name', _userName!);
        await prefs.setString('user_email', _userEmail!);
        if (subStr != null) {
          await prefs.setString('subscription_until', subStr);
        }
        
        _apiService.setupAuthInterceptor(_token!);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      // ...
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data['errors'] != null && data['errors'] is Map) {
          final errors = data['errors'] as Map;
          _error = errors.values.first[0].toString();
        } else if (data['message'] != null) {
          _error = data['message'];
        } else {
          _error = 'Registrasi gagal';
        }
      } else {
        _error = 'Koneksi ke server gagal. Pastikan API berjalan.';
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    _token = null;
    _userName = null;
    _userEmail = null;
    _apiService.clearAuth();
    notifyListeners();
  }

  // --- OTP & Password Recovery ---

  Future<bool> sendOtp(String identifier, String method, {String? phoneNumber}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.client.post('/auth/forgot-password/send-otp', data: {
        'identifier': identifier, // admin email
        'method': method, // 'whatsapp'
        'phone': phoneNumber, // target phone number
      });

      _isLoading = false;
      notifyListeners();
      return response.statusCode == 200;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        _error = e.response?.data['message'] ?? 'Gagal mengirim OTP.';
      } else {
        _error = 'Gagal mengirim OTP. Cek koneksi internet.';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Terjadi kesalahan sistem.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtp(String identifier, String otp) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.client.post('/auth/forgot-password/verify-otp', data: {
        'identifier': identifier,
        'otp': otp,
      });

      _isLoading = false;
      notifyListeners();
      return response.statusCode == 200;
    } catch (e) {
      _error = 'Kode OTP salah atau kedaluwarsa.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String identifier, String otp, String newPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.client.post('/auth/forgot-password/reset', data: {
        'identifier': identifier,
        'otp': otp,
        'password': newPassword,
        'password_confirmation': newPassword,
      });

      _isLoading = false;
      notifyListeners();
      return response.statusCode == 200;
    } catch (e) {
      _error = 'Gagal mereset password.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

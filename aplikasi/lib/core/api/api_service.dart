import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Gunakan 10.0.2.2 jika menggunakan Android Emulator, 
  // atau ganti dengan IP lokal laptop (misal: 192.168.1.xxx) jika via device fisik
  static const String baseUrl = kIsWeb ? 'http://127.0.0.1:8000/api' : 'http://192.168.1.4:8000/api'; 
  
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
      },
    ),
  );

  Dio get client => _dio;

  // Interceptor untuk menyisipkan Bearer Token otomatis pada request yang butuh auth
  void setupAuthInterceptor(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }
  
  void clearAuth() {
    _dio.options.headers.remove('Authorization');
  }
}

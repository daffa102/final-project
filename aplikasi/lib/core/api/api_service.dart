import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  // True singleton — all providers share one Dio instance
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  ApiService._internal();

  static const String _productionUrl = 'https://kash.dappa.my.id/api';
  static const String _productionBaseUrl = 'https://kash.dappa.my.id';

  static String get baseUrl {
    if (kIsWeb) {
      // Use Uri.base to get current page URL safely without dart:html
      final String host = Uri.base.host;
      // Jika running di localhost (development), arahkan ke server production
      if (host == 'localhost' || host == '127.0.0.1') {
        return _productionUrl;
      }
      return 'http://$host/api';
    }
    // Mobile app selalu pakai URL production
    return _productionUrl;
  }

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Accept': 'application/json',
        // Content-Type NOT set here — Dio sets it automatically per request type
        // (application/json for Map, multipart/form-data for FormData)
      },
    ),
  );

  Dio get client => _dio;

  /// Call this once after login/register to set the bearer token globally
  void setupAuthInterceptor(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuth() {
    _dio.options.headers.remove('Authorization');
  }

  bool get hasToken => _dio.options.headers.containsKey('Authorization');

  String resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    String cleanPath = path;

    // 1. If it's a full URL, extract the path part (ignore the host/scheme from API response
    //    because APP_URL on server might be http:// while we need https://)
    if (path.startsWith('http')) {
      final uri = Uri.tryParse(path);
      if (uri != null) {
        final storageIndex = uri.path.indexOf('/storage/');
        if (storageIndex >= 0) {
          cleanPath = uri.path.substring(storageIndex);
        } else {
          cleanPath = uri.path;
        }
      }
    }

    // 2. Normalize: remove any leading storage/ or /storage/ to start fresh
    if (cleanPath.startsWith('/storage/')) {
      cleanPath = cleanPath.replaceFirst('/storage/', '');
    } else if (cleanPath.startsWith('storage/')) {
      cleanPath = cleanPath.replaceFirst('storage/', '');
    }

    // 3. Ensure leading slash and /storage/ prefix
    if (cleanPath.startsWith('/')) {
      cleanPath = '/storage$cleanPath';
    } else {
      cleanPath = '/storage/$cleanPath';
    }

    // 4. Always use HTTPS base URL (not baseUrl which includes /api)
    final base = kIsWeb ? 'https://${Uri.base.host}' : _productionBaseUrl;
    return Uri.encodeFull('$base$cleanPath');
  }
}

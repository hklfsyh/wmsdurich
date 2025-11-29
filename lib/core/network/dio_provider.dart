import 'package:dio/dio.dart';
import 'package:dio/browser.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_durich/core/network/auth_interceptor.dart';
import 'package:wms_durich/core/services/storage_service.dart';

const String _baseUrl = 'http://localhost:8081';

final dioProvider = Provider<Dio>((ref) {
  final baseOptions = BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    contentType: 'application/json',
    headers: {
      'Accept': 'application/json',
    },
    validateStatus: (status) => status != null && status < 500,
  );

  final dio = Dio(baseOptions);

  // Aktifkan credentials untuk Flutter Web (CORS)
  if (kIsWeb) {
    dio.httpClientAdapter = BrowserHttpClientAdapter()..withCredentials = true;
  }

  // Tambahkan AuthInterceptor (otomatis nambah Bearer token)
  final storageService = ref.read(storageServiceProvider);
  dio.interceptors.add(AuthInterceptor(storageService));

  return dio;
});

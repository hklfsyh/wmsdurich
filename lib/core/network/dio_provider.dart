import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_durich/core/network/auth_interceptor.dart';
import 'package:wms_durich/core/services/storage_service.dart';

// Conditional import for web support
import 'dio_provider_stub.dart' if (dart.library.html) 'dio_provider_web.dart';

// Use 10.0.2.2 for Android emulator to access host machine's localhost
// Use localhost for web and iOS simulator
const String _baseUrl =
    kIsWeb ? 'http://localhost:8081' : 'http://10.0.2.2:8081';

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

  // Configure adapter for web if needed
  configureWebAdapter(dio);

  // Tambahkan AuthInterceptor (otomatis nambah Bearer token)
  final storageService = ref.read(storageServiceProvider);
  dio.interceptors.add(AuthInterceptor(storageService));

  return dio;
});

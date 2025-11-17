import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// URL dasar API GoLang Anda (GANTI dengan URL yang BENAR dari tim backend)
const String _baseUrl =
    'http://10.0.2.2:8080/api/v1'; // Contoh: 10.0.2.2 untuk Android Emulator

final dioProvider = Provider<Dio>((ref) {
  final options = BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    contentType: 'application/json',
  );

  final dio = Dio(options);

  // TODO: Di masa depan, tambahkan Interceptor untuk Token Otentikasi
  // dio.interceptors.add(AuthInterceptor(ref));

  return dio;
});

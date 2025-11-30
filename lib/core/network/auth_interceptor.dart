import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_durich/core/services/storage_service.dart';

class AuthInterceptor extends Interceptor {
  final StorageService _storageService;

  AuthInterceptor(this._storageService);

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Ambil token dari storage
    final accessToken = await _storageService.getAccessToken();

    // Jika token ada, tambahkan ke header Authorization
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    // TODO: Handle Token Expired (401) -> Auto Refresh Token di sini
    // Untuk sekarang, kita biarkan error diteruskan ke layer atas
    super.onError(err, handler);
  }
}

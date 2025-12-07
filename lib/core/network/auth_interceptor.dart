import 'package:dio/dio.dart';
import 'package:wms_durich/core/services/storage_service.dart';

class AuthInterceptor extends Interceptor {
  final StorageService _storageService;
  final Dio _dio;
  bool _isRefreshing = false;

  AuthInterceptor(this._storageService, this._dio);

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final accessToken = await _storageService.getAccessToken();

    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;

      try {
        final refreshToken = await _storageService.getRefreshToken();
        if (refreshToken == null || refreshToken.isEmpty) {
          await _storageService.clearAuthData();
          return handler.reject(err);
        }

        // Call refresh token endpoint
        final response = await _dio.post(
          '/v1/authentications/refresh-token',
          data: {'refresh_token': refreshToken},
          options: Options(
            headers: {'Authorization': null}, // Don't send old token
          ),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final newAccessToken = response.data['data']['access_token'];
          await _storageService.saveAccessToken(newAccessToken);

          // Retry original request with new token
          err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
          final retryResponse = await _dio.fetch(err.requestOptions);
          return handler.resolve(retryResponse);
        } else {
          await _storageService.clearAuthData();
          return handler.reject(err);
        }
      } catch (e) {
        await _storageService.clearAuthData();
        return handler.reject(err);
      } finally {
        _isRefreshing = false;
      }
    }

    super.onError(err, handler);
  }
}

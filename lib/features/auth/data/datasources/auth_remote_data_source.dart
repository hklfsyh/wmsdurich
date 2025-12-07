import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_durich/core/network/dio_provider.dart';
import 'package:wms_durich/features/auth/data/models/auth_response_model.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.read(dioProvider));
});

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(String email, String password);
  Future<void> logout(String refreshToken);
  Future<String> refreshToken(String refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<AuthResponseModel> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/v1/authentications/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final authResponse = AuthResponseModel.fromJson(response.data);
        return authResponse;
      } else {
        final message = response.data['message'] ?? 'Login failed';
        throw Exception(message);
      }
    } on DioException catch (e) {
      String errorMessage = 'Koneksi gagal';

      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;

        if (data is Map<String, dynamic>) {
          errorMessage = data['message']?.toString() ?? 'Login gagal';
        } else if (data is String) {
          errorMessage = data;
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Koneksi timeout';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Tidak dapat terhubung ke server. Pastikan backend berjalan di ${_dio.options.baseUrl}';
      }

      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Error parsing data: $e');
    }
  }

  @override
  Future<void> logout(String refreshToken) async {
    try {
      await _dio.post(
        '/v1/authentications/logout',
        data: {
          'refresh_token': refreshToken,
        },
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Logout failed');
    }
  }

  @override
  Future<String> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '/v1/authentications/refresh-token',
        data: {
          'refresh_token': refreshToken,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];
        final newAccessToken = data['access_token'] as String;
        return newAccessToken;
      } else {
        throw Exception('Refresh token failed');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Refresh token failed');
    }
  }
}

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_durich/core/network/dio_provider.dart';
import 'package:wms_durich/features/auth/data/models/auth_response_model.dart';
import 'package:wms_durich/features/auth/data/datasources/auth_mock_data_source.dart';

// USING MOCK DATA - API is down
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthMockDataSourceImpl();
  // return AuthRemoteDataSourceImpl(ref.read(dioProvider)); // Original API call
});

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(String email, String password);
  Future<void> logout(String refreshToken);
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
        return AuthResponseModel.fromJson(response.data);
      } else {
        throw Exception('Login failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Handle Dio Error Response based on GoLang struct
      // { "success": false, "message": "...", "code": ... }

      String errorMessage = 'Connection error';

      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;

        // If response is a Map, try to extract 'message'
        if (data is Map<String, dynamic>) {
          if (data['message'] != null) {
            errorMessage = data['message'].toString();
          }
        } else if (data is String) {
          // Sometimes raw string response
          errorMessage = data;
        }
      }

      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Data parsing error: $e');
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
      // Ignore logout errors usually, or log them
      throw Exception(e.response?.data['message'] ?? 'Logout failed');
    }
  }
}

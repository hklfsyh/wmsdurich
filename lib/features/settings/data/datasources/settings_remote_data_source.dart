import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_durich/core/network/dio_provider.dart';
import 'package:wms_durich/features/settings/data/models/password_request_models.dart';

final settingsRemoteDataSourceProvider = Provider<SettingsRemoteDataSource>((ref) {
  return SettingsRemoteDataSourceImpl(ref.read(dioProvider));
});

abstract class SettingsRemoteDataSource {
  Future<void> updatePassword(UpdatePasswordRequest request);
  Future<void> resetPassword(ResetPasswordRequest request);
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final Dio _dio;

  SettingsRemoteDataSourceImpl(this._dio);

  @override
  Future<void> updatePassword(UpdatePasswordRequest request) async {
    try {
      await _dio.put(
        '/v1/profile/password',
        data: request.toJson(),
      );
    } on DioException catch (e) {
      String errorMessage = 'Failed to update password';
      if (e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map<String, dynamic> && data['message'] != null) {
          errorMessage = data['message'].toString();
        } else if (data is String) {
          errorMessage = data;
        }
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<void> resetPassword(ResetPasswordRequest request) async {
    try {
      await _dio.post(
        '/v1/admin/users/reset-password',
        data: request.toJson(),
      );
    } on DioException catch (e) {
      String errorMessage = 'Failed to reset password';
      if (e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map<String, dynamic> && data['message'] != null) {
          errorMessage = data['message'].toString();
        } else if (data is String) {
          errorMessage = data;
        }
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}

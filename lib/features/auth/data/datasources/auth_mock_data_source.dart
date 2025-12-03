import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_durich/features/auth/data/models/auth_response_model.dart';
import 'package:wms_durich/features/auth/data/datasources/auth_remote_data_source.dart';

final authMockDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthMockDataSourceImpl();
});

class AuthMockDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<AuthResponseModel> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock successful login
    return AuthResponseModel(
      success: true,
      message: 'Login berhasil',
      code: 200,
      accessToken: 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken:
          'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      roles: ['admin', 'user'],
    );
  }

  @override
  Future<void> logout(String refreshToken) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    // Mock logout always succeeds
  }
}

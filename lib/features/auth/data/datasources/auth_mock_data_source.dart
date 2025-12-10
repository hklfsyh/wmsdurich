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

    // Determine roles based on email for testing
    List<String> roles;
    if (email.contains('admin')) {
      roles = ['admin'];
    } else if (email.contains('warehouse') || email.contains('wh')) {
      roles = ['warehouse'];
    } else if (email.contains('sales')) {
      roles = ['sales'];
    } else {
      // Default to warehouse role for any other email
      roles = ['warehouse'];
    }

    // Mock successful login
    return AuthResponseModel(
      success: true,
      message: 'Login berhasil',
      code: 200,
      accessToken: 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken:
          'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      roles: roles,
    );
  }

  @override
  Future<void> logout(String refreshToken) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    // Mock logout always succeeds
  }

  @override
  Future<String> refreshToken(String refreshToken) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    // Return mock new access token
    return 'mock_new_access_token_${DateTime.now().millisecondsSinceEpoch}';
  }
}

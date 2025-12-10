import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_durich/core/services/storage_service.dart';
import 'package:wms_durich/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:wms_durich/features/auth/domain/entities/user_entity.dart';
import 'package:wms_durich/features/auth/domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.read(authRemoteDataSourceProvider),
    storageService: ref.read(storageServiceProvider),
  );
});

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final StorageService storageService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.storageService,
  });

  @override
  Future<UserEntity> login(String email, String password) async {
    try {
      final response = await remoteDataSource.login(email, password);
      
      // Save to local storage
      await storageService.saveAuthData(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        roles: response.roles,
        locationId: response.currentLocationId,
      );

      return UserEntity(
        accessToken: response.accessToken,
        roles: response.roles,
        locationId: response.currentLocationId,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      final refreshToken = await storageService.getRefreshToken();
      if (refreshToken != null) {
        await remoteDataSource.logout(refreshToken);
      }
    } finally {
      // Always clear local storage even if API call fails
      await storageService.clearAuthData();
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final token = await storageService.getAccessToken();
    final roles = await storageService.getUserRoles();
    final locationId = await storageService.getLocationId();
    
    if (token != null && token.isNotEmpty) {
      return UserEntity(
        accessToken: token, 
        roles: roles,
        locationId: locationId,
      );
    }
    return null;
  }
}

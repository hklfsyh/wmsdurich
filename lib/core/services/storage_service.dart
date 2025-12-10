import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

class StorageService {
  final _storage = const FlutterSecureStorage();

  static const String _tokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userRolesKey = 'user_roles';
  static const String _locationIdKey = 'location_id';

  Future<void> saveAuthData({
    required String accessToken,
    required String refreshToken,
    required List<String> roles,
    String? locationId,
  }) async {
    await _storage.write(key: _tokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    await _storage.write(key: _userRolesKey, value: roles.join(','));
    
    if (locationId != null) {
      await _storage.write(key: _locationIdKey, value: locationId);
    } else {
      await _storage.delete(key: _locationIdKey);
    }
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> saveAccessToken(String accessToken) async {
    await _storage.write(key: _tokenKey, value: accessToken);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<List<String>> getUserRoles() async {
    final rolesString = await _storage.read(key: _userRolesKey);
    if (rolesString == null || rolesString.isEmpty) return [];
    return rolesString.split(',');
  }

  Future<String?> getLocationId() async {
    return await _storage.read(key: _locationIdKey);
  }

  Future<void> clearAuthData() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userRolesKey);
    await _storage.delete(key: _locationIdKey);
  }
  
  Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}

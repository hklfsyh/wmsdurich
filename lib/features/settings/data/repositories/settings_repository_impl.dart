import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_durich/features/settings/data/datasources/settings_remote_data_source.dart';
import 'package:wms_durich/features/settings/data/models/password_request_models.dart';
import 'package:wms_durich/features/settings/domain/repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(ref.read(settingsRemoteDataSourceProvider));
});

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource _dataSource;

  SettingsRepositoryImpl(this._dataSource);

  @override
  Future<void> updatePassword(String oldPassword, String newPassword) async {
    final request = UpdatePasswordRequest(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
    await _dataSource.updatePassword(request);
  }

  @override
  Future<void> resetPassword(String email, String newPassword) async {
    final request = ResetPasswordRequest(
      email: email,
      newPassword: newPassword,
    );
    await _dataSource.resetPassword(request);
  }
}

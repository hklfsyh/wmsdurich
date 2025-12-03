import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_durich/features/settings/data/models/password_request_models.dart';
import 'package:wms_durich/features/settings/data/datasources/settings_remote_data_source.dart';

final settingsMockDataSourceProvider =
    Provider<SettingsRemoteDataSource>((ref) {
  return SettingsMockDataSourceImpl();
});

class SettingsMockDataSourceImpl implements SettingsRemoteDataSource {
  @override
  Future<void> updatePassword(UpdatePasswordRequest request) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock successful password update
    // In real scenario, you might want to validate old password, etc.
  }

  @override
  Future<void> resetPassword(ResetPasswordRequest request) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock successful password reset
  }
}

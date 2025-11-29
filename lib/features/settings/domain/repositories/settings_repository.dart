abstract class SettingsRepository {
  Future<void> updatePassword(String oldPassword, String newPassword);
  Future<void> resetPassword(String email, String newPassword);
}

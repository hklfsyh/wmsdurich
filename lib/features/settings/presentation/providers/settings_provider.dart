import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_durich/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:wms_durich/features/settings/domain/repositories/settings_repository.dart';

class SettingsState {
  final bool isLoading;
  final String? error;
  final String? successMessage;

  SettingsState({
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  SettingsState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      error: error, 
      successMessage: successMessage,
    );
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(() {
  return SettingsNotifier();
});

class SettingsNotifier extends Notifier<SettingsState> {
  late final SettingsRepository _repository;

  @override
  SettingsState build() {
    _repository = ref.read(settingsRepositoryProvider);
    return SettingsState();
  }

  Future<void> updatePassword(String oldPassword, String newPassword) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      await _repository.updatePassword(oldPassword, newPassword);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Password successfully updated',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> resetPassword(String email, String newPassword) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      await _repository.resetPassword(email, newPassword);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'User password successfully reset',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
}

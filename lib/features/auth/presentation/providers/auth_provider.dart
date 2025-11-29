import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_durich/features/auth/domain/repositories/auth_repository.dart';
import 'package:wms_durich/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:wms_durich/features/auth/domain/entities/user_entity.dart';

// State class
class AuthState {
  final bool isLoading;
  final UserEntity? user;
  final String? error;

  AuthState({
    this.isLoading = false,
    this.user,
    this.error,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    bool? isLoading,
    UserEntity? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error, // Reset error if not provided
    );
  }
}

// Provider
final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

// Notifier
class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _repository;

  @override
  AuthState build() {
    // Initialize repository from ref
    _repository = ref.read(authRepositoryProvider);
    
    // Check login status immediately
    checkLoginStatus();
    
    return AuthState();
  }

  Future<void> checkLoginStatus() async {
    final user = await _repository.getCurrentUser();
    if (user != null) {
      state = state.copyWith(user: user);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repository.login(email, password);
      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.logout();
      state = AuthState(); // Reset state
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

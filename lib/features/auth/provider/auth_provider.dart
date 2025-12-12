import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../shared/models/user.dart';

// State class for Auth
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isLoggedIn;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isLoggedIn = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isLoggedIn,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error, // If passed as null, it clears the error. If omitted, keeps old. 
                    // Actually, for error usually we want to clear it if logic starts anew.
                    // Let's settle on: if argument represents new state.
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
  
  // Specific copyWith for error clearing logic
  AuthState copyWithState({
      User? user,
      bool? isLoading,
      String? error,
      bool? isLoggedIn,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final StorageService _storageService;

  AuthNotifier(this._authService, this._storageService) : super(const AuthState()) {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final user = await _storageService.getUser();
    final token = await _storageService.getToken();
    
    if (user != null && token != null) {
      state = AuthState(user: user, isLoggedIn: true);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final response = await _authService.login(email, password);
    
    if (response.success && response.data != null) {
      await _storageService.saveToken(response.data!.token);
      await _storageService.saveUser(response.data!.user);
      
      state = AuthState(
        user: response.data!.user,
        isLoading: false,
        isLoggedIn: true,
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: response.message ?? 'Login failed',
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _storageService.clearAuth();
    state = const AuthState();
  }
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return AuthNotifier(authService, storageService);
});

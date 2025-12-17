import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/user_profile.dart';
import 'auth_provider.dart'; // To access authServiceProvider

class ProfileState {
  final UserProfile? profile;
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  ProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final dynamic _authService; // Using dynamic because actual type is in core, but we can access methods. 
  // Better practice: Import AuthService properly.

  ProfileNotifier(this._authService) : super(const ProfileState());

  Future<void> fetchProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _authService.getProfile();
      if (response.success && response.data != null) {
        state = state.copyWith(
          isLoading: false,
          profile: response.data,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Failed to load profile',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error: $e',
      );
    }
  }

  Future<String?> updateProfile(UpdateProfileRequest request) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      final response = await _authService.updateProfile(request);
      if (response.success) {
        // Refresh profile after successful update
        await fetchProfile();
        state = state.copyWith(
          successMessage: response.message ?? 'Profile updated successfully',
        );
        return response.message ?? 'Profile updated successfully';
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Failed to update profile',
        );
        return null;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error: $e',
      );
      return null;
    }
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return ProfileNotifier(authService);
});

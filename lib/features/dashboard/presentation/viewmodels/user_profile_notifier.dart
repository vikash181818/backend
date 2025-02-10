// user_profile_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_dukans_user/core/config/services/user_profile_service.dart';
import 'package:online_dukans_user/provider/user_profile_provider.dart';
// import 'package:onlinedukans_user/core/config/services/user_profile_service.dart';
// import 'package:onlinedukans_user/providers/user_profile_provider.dart';

class UserProfileState {
  final bool isLoading;
  final UserProfile? profile;
  final String? error;

  UserProfileState({
    this.isLoading = false,
    this.profile,
    this.error,
  });

  UserProfileState copyWith({
    bool? isLoading,
    UserProfile? profile,
    String? error,
  }) {
    return UserProfileState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      error: error ?? this.error,
    );
  }
}

class UserProfileNotifier extends StateNotifier<UserProfileState> {
  final UserProfileService _service;

  UserProfileNotifier(this._service)
      : super(UserProfileState(isLoading: false));

  Future<void> loadUserProfile(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final profile = await _service.fetchUserProfile(userId);
      state = state.copyWith(isLoading: false, profile: profile);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// Provider for the notifier
final userProfileNotifierProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfileState>((ref) {
  final service = ref.watch(userProfileServiceProvider);
  return UserProfileNotifier(service);
});

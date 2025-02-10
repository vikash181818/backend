import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_dukans_user/core/config/services/secure_storage_service.dart';
import 'package:online_dukans_user/core/config/services/user_profile_service.dart';
import 'package:online_dukans_user/core/config/utils/token_manager.dart';
// import 'package:onlinedukans_user/core/config/services/secure_storage_service.dart';
// import 'package:onlinedukans_user/core/config/services/user_profile_service.dart';
// import 'package:onlinedukans_user/core/config/utils/token_manager.dart';

// Provide an instance of SecureStorageService
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

// Provide an instance of TokenManager
final tokenManagerProvider = Provider<TokenManager>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  return TokenManager(storage);
});

// Provide an instance of UserProfileService
final userProfileServiceProvider = Provider<UserProfileService>((ref) {
  final tokenManager = ref.watch(tokenManagerProvider);
  return UserProfileService(tokenManager);
});

// Create a FutureProvider for fetching the user profile by userId
final userProfileFutureProvider =
    FutureProvider.family<UserProfile, String>((ref, userId) async {
  final service = ref.watch(userProfileServiceProvider);
  return service.fetchUserProfile(userId);
});

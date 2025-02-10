import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_dukans_user/core/config/services/api_client.dart';
import 'package:online_dukans_user/core/config/services/secure_storage_service.dart';
import 'package:online_dukans_user/core/config/utils/token_manager.dart';
import 'package:online_dukans_user/features/auth/data/auth_remote_datasource.dart';
import 'package:online_dukans_user/features/auth/data/auth_repository_impl.dart';
import 'package:online_dukans_user/features/auth/presentation/viewmodels/auth_viewmodel.dart';

// Provide API client
final apiClientProvider = Provider((ref) => ApiClient());

// Provide secure storage service
final secureStorageProvider = Provider((ref) => SecureStorageService());

// Provide token manager
final tokenManagerProvider =
    Provider((ref) => TokenManager(ref.watch(secureStorageProvider)));

// Provide AuthRemoteDataSource
final authRemoteDataSourceProvider =
    Provider((ref) => AuthRemoteDataSource(ref.watch(apiClientProvider)));

// Provide AuthRepository
final authRepositoryProvider = Provider(
    (ref) => AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider)));

// Provide AuthViewModel
final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel(
    authRepository: ref.watch(authRepositoryProvider),
    tokenManager: ref.watch(tokenManagerProvider),
  );
});

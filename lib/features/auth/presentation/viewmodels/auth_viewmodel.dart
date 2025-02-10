import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_dukans_user/core/config/utils/token_manager.dart';
import 'package:online_dukans_user/features/auth/domain/auth_repository.dart';
import 'package:online_dukans_user/features/auth/domain/user_model.dart';
// import 'package:onlinedukans_user/core/config/utils/token_manager.dart';
// import 'package:onlinedukans_user/features/auth/domain/auth_repository.dart';
// import 'package:onlinedukans_user/features/auth/domain/user_model.dart';

class AuthState {
  final bool loading;
  final UserModel? user;
  final String? token;
  final String? error;

  AuthState({
    this.loading = false,
    this.user,
    this.token,
    this.error,
  });

  AuthState copyWith({
    bool? loading,
    UserModel? user,
    String? token,
    String? error,
  }) {
    return AuthState(
      loading: loading ?? this.loading,
      user: user ?? this.user,
      token: token ?? this.token,
      error: error,
    );
  }
}

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository authRepository;
  final TokenManager tokenManager;

  AuthViewModel({required this.authRepository, required this.tokenManager})
      : super(AuthState());

  Future<void> signup({
    required String firstname,
    required String lastname,
    required dynamic mobile,
    required String email,
    required dynamic referenceCode,
    required String password,
  }) async {
    try {
      state = state.copyWith(loading: true);
      final result = await authRepository.signup(
        firstname: firstname,
        lastname: lastname,
        mobile: mobile,
        email: email,
        referenceCode: referenceCode,
        password: password,
      );

      final token = result['token'];
      final userMap = result['user'];
      final user = UserModel.fromMap(userMap);

      // Save token and user locally
      await tokenManager.saveToken(token);
      await tokenManager.saveUser(user.toMap());

      state = AuthState(loading: false, user: user, token: token);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> login({
    required String login,
    required String password,
  }) async {
    try {
      state = state.copyWith(loading: true);
      final result =
          await authRepository.login(login: login, password: password);

      final token = result['token'];
      final userMap = result['user'];
      final user = UserModel.fromMap(userMap);

      // Save token and user locally
      await tokenManager.saveToken(token);
      await tokenManager.saveUser(user.toMap());

      state = AuthState(loading: false, user: user, token: token);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> loadSession() async {
    final savedToken = await tokenManager.getToken();
    final savedUser = await tokenManager.getUser();
    if (savedToken != null && savedUser != null) {
      final user = UserModel.fromMap(savedUser);
      state = AuthState(user: user, token: savedToken);
    }
  }

  Future<void> logout() async {
    await tokenManager.clear();
    state = AuthState();
  }
}

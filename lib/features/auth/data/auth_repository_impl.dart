// import 'package:onlinedukans_user/features/auth/domain/auth_repository.dart';

import 'package:online_dukans_user/features/auth/domain/auth_repository.dart';

import 'auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Map<String, dynamic>> signup({
    required String firstname,
    required String lastname,
    required mobile,
    required String email,
    required referenceCode,
    required String password,
  }) async {
    final data = {
      "firstname": firstname,
      "lastname": lastname,
      "mobile": mobile,
      "email": email,
      "referenceCode": referenceCode,
      "password": password,
    };
    return await remoteDataSource.signup(data);
  }

  @override
  Future<Map<String, dynamic>> login({
    required String login,
    required String password,
  }) async {
    final data = {
      "login": login,
      "password": password,
    };
    return await remoteDataSource.login(data);
  }
}

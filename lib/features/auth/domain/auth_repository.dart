
abstract class AuthRepository {
  Future<Map<String, dynamic>> signup({
    required String firstname,
    required String lastname,
    required dynamic mobile,
    required String email,
    required dynamic referenceCode,
    required String password,
  });

  Future<Map<String, dynamic>> login({
    required String login,
    required String password,
  });
}




import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthService {
  Future<Response> verifyEmail(String token) async {
    try {
      final url = Uri.parse('https://192.168.1.56:3000/verify-email?token=$token');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return Response(success: true, message: 'Email verified successfully!');
      } else {
        return Response(success: false, message: 'Invalid or expired token.');
      }
    } catch (error) {
      return Response(success: false, message: 'Error: $error');
    }
  }
}

class Response {
  final bool success;
  final String message;

  Response({required this.success, required this.message});
}

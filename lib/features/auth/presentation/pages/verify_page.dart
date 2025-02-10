import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VerificationPage extends StatelessWidget {
  final String token;

  const VerificationPage({super.key, required this.token});

  // Function to verify the email using the token
  Future<void> verifyEmail(BuildContext context) async {
    // Here you'd send the token to the backend to verify the user's email
    try {
      final response = await verifyEmailWithToken(token); // Call API to verify email
      if (response['success']) {
        context.go('/login');  // Redirect to login after successful verification
      } else {
        showErrorSnackBar(context, "Verification failed");
      }
    } catch (e) {
      showErrorSnackBar(context, "Error during verification");
    }
  }

  // Helper method to call the API for email verification
  Future<Map<String, dynamic>> verifyEmailWithToken(String token) async {
    // Call your backend verification API
    // Example:
    // final response = await http.get('yourbackend.com/verify-email?token=$token');
    return {'success': true}; // Simulate successful verification
  }

  // Show error message in a SnackBar
  void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Your Email")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => verifyEmail(context),
          child: const Text("Verify Email"),
        ),
      ),
    );
  }
}

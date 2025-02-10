import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
//import 'package:onlinedukans_user/core/config/common_widgets/custom_app_bar.dart';
import 'package:http/http.dart' as http;
import 'package:online_dukans_user/core/config/common_widgets/custom_app_bar.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://192.168.181.17:3000/api/user/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset successful.')),
        );
        // Navigate to login page after password reset
        context.go('/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to reset password.')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
          title: const Text(
            'Reset Password',
            style: TextStyle(color: Colors.white, fontSize: 18), // Correct title styling
          ),
          centerTitle: true, // Centers the title
          backgroundColor: Colors.red, // Set AppBar color to red
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.white, // Makes the back icon white
            onPressed: () {
              context.pop(); // Use GoRouter's pop method to go back
            },
          ),
          iconTheme: const IconThemeData(color: Colors.white), // Set back icon color to white
        ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Enter your email'),
            ),
            TextField(
              controller: _newPasswordController,
              decoration:
                  const InputDecoration(labelText: 'Enter new password'),
              obscureText: true,
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration:
                  const InputDecoration(labelText: 'Confirm new password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
           ElevatedButton(
  onPressed: _resetPassword,
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.red, // Set button color to red
  ),
  child: const Text(
    'Reset Password',
    style: TextStyle(color: Colors.white), // Set text color to white for contrast
  ),
)

          ],
        ),
      ),
    );
  }
}

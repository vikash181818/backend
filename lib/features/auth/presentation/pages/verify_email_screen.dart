import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:online_dukans_user/features/auth/presentation/widgets/auth_service.dart';

//import 'package:onlinedukans_user/features/auth/presentation/widgets/auth_service.dart';

class VerifyEmailPage extends ConsumerStatefulWidget {
  final String token;

  const VerifyEmailPage({super.key, required this.token});

  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends ConsumerState<VerifyEmailPage> {
  bool _isLoading = true;
  String? _message;

  @override
  void initState() {
    super.initState();
    _verifyEmail();
  }

  Future<void> _verifyEmail() async {
    final authService = ref.read(authServiceProvider);
    final response = await authService.verifyEmail(widget.token);

    setState(() {
      _isLoading = false;
      _message = response.message;
    });

    if (response.success) {
      // Navigate to login page after successful verification
      if (context.mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Verification'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  _message ?? 'Error during verification',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
    );
  }
}

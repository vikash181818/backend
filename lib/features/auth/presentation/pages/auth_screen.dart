import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:online_dukans_user/features/auth/presentation/widgets/auth_header.dart';
import 'package:online_dukans_user/provider/auth_providers.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _referenceCodeController = TextEditingController();

  bool _isLoginPage = true; // Flag to switch between login and signup

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    _firstnameController.dispose();
    _lastnameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _referenceCodeController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final authVM = ref.read(authViewModelProvider.notifier);
      await authVM.login(
        login: _loginController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return; // Ensure widget is still mounted

      final state = ref.read(authViewModelProvider);
      if (state.user != null && state.token != null) {
        if (context.mounted) {
          // Show login success snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login successful.")),
          );
          // Delay navigation to allow the snackbar to be visible
          Future.delayed(const Duration(seconds: 2), () {
            if (context.mounted) {
              context.go('/dashboard');
            }
          });
        }
      } else if (state.error != null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${state.error}")),
          );
        }
      }
    }
  }

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      final authVM = ref.read(authViewModelProvider.notifier);
      await authVM.signup(
        firstname: _firstnameController.text.trim(),
        lastname: _lastnameController.text.trim(),
        mobile: _mobileController.text.trim(),
        email: _emailController.text.trim(),
        referenceCode: _referenceCodeController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return; // Ensure widget is still mounted

      final state = ref.read(authViewModelProvider);

      if (state.error != null) {
        // If there's an error during signup, display it
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${state.error}")),
        );
      } else {
        // If signup is successful, prompt user to verify email
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "User created successfully. Please verify your email before login.",
            ),
          ),
        );
        // Switch back to the login page after successful signup
        setState(() {
          _isLoginPage = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authViewModelProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/bgimg6.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Form on top of the background image
          state.loading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 100),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        const SizedBox(height: 20),
                        if (_isLoginPage) ...[
                          const AuthHeader(),
                          TextFormField(
                            controller: _loginController,
                            decoration:
                                const InputDecoration(labelText: 'Email'),
                            validator: (value) =>
                                value!.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _passwordController,
                            decoration:
                                const InputDecoration(labelText: 'Password'),
                            obscureText: true,
                            validator: (value) =>
                                value!.isEmpty ? 'Required' : null,
                          ),
                        ] else ...[
                          const AuthHeader(),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _firstnameController,
                                  decoration: const InputDecoration(
                                      labelText: 'First Name'),
                                  validator: (value) =>
                                      value!.isEmpty ? 'Required' : null,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: _lastnameController,
                                  decoration: const InputDecoration(
                                      labelText: 'Last Name'),
                                  validator: (value) =>
                                      value!.isEmpty ? 'Required' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _mobileController,
                            decoration:
                                const InputDecoration(labelText: 'Mobile'),
                            validator: (value) =>
                                value!.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _emailController,
                            decoration:
                                const InputDecoration(labelText: 'Email'),
                            validator: (value) =>
                                value!.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _referenceCodeController,
                            decoration: const InputDecoration(
                                labelText: 'Reference Code'),
                            validator: (value) =>
                                value!.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _passwordController,
                            decoration:
                                const InputDecoration(labelText: 'Password'),
                            obscureText: true,
                            validator: (value) =>
                                value!.isEmpty ? 'Required' : null,
                          ),
                        ],
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _isLoginPage ? _login : _signup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                          ),
                          child: Text(
                            _isLoginPage ? 'Login' : 'Signup',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_isLoginPage)
                          TextButton(
                            onPressed: () => context.go('/forgot-password'),
                            child: const Text('Forgot Password?'),
                          ),
                        if (_isLoginPage)
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Column(
                              children: [
                                // TextButton(
                                //   onPressed: () {
                                //     // Handle "Need Help"
                                //   },
                                //   child: const Text(
                                //     'Need Help?',
                                //     style: TextStyle(color: Colors.red),
                                //   ),
                                // ),
                                // TextButton(
                                //   onPressed: () {
                                //     // Handle "Share with a friend"
                                //   },
                                //   child: const Text(
                                //     'Share with a Friend',
                                //     style: TextStyle(color: Colors.green),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
          // Grey Container at the bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              color: const Color.fromARGB(255, 169, 168, 168),
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLoginPage = !_isLoginPage;
                      });
                    },
                    child: Text(
                      _isLoginPage
                          ? 'Don\'t have an account? Signup'
                          : 'Already have an account? Login',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

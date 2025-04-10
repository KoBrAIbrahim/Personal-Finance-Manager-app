import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/signup_controller.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final signupState = ref.watch(signupControllerProvider);
    final isLoading = signupState.isLoading;

    ref.listen<AsyncValue<void>>(signupControllerProvider, (prev, next) {
      next.whenOrNull(
        data: (_) {
          context.go('/login');
        },
        error: (err, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(err.toString())),
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                color: Color(0xFF00B4D8),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            right: -120,
            child: Container(
              width: 250,
              height: 250,
              decoration: const BoxDecoration(
                color: Color(0xFF0077B6),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SingleChildScrollView(
                child: Card(
                  elevation: 8,
                  color: Colors.white.withOpacity(0.95),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Sign Up",
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0077B6)),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Create an account to get started!",
                          style: TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 30),

                        TextField(
                          controller: _usernameController,
                          decoration: const InputDecoration(labelText: "Username"),
                        ),
                        const SizedBox(height: 16),

                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: "Email"),
                        ),
                        const SizedBox(height: 16),

                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: "Password"),
                        ),
                        const SizedBox(height: 16),

                        TextField(
                          controller: _confirmController,
                          obscureText: true,
                          decoration:
                              const InputDecoration(labelText: "Confirm Password"),
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    final username =
                                        _usernameController.text.trim();
                                    final email = _emailController.text.trim();
                                    final password =
                                        _passwordController.text.trim();
                                    final confirm =
                                        _confirmController.text.trim();

                                    if (username.isEmpty ||
                                        email.isEmpty ||
                                        password.isEmpty ||
                                        confirm.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  "Please fill all fields")));
                                      return;
                                    }

                                    if (password != confirm) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  "Passwords do not match")));
                                      return;
                                    }

                                    ref
                                        .read(signupControllerProvider.notifier)
                                        .signup(
                                          username: username,
                                          email: email,
                                          password: password,
                                        );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0077B6),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator()
                                : const Text("Create Account",
                                    style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              context.go('/login');
                            },
                            child: const Text(
                              "Already have an account? Sign In",
                              style: TextStyle(color: Color(0xFF00B4D8)),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

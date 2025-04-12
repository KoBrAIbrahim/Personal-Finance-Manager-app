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
        data: (_) => context.go('/login'),
        error: (err, _) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(err.toString())));
        },
      );
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFF),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.3,
            decoration: const BoxDecoration(
              color: Color(0xFF0077B6),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(80)),
            ),
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                color: Color(0xFF0077B6),
                size: 40,
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0077B6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Create an account to get started!",
                        style: TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 24),

                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person_outline),
                          labelText: "Username",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email_outlined),
                          labelText: "Email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline),
                          labelText: "Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: _confirmController,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_person_outlined),
                          labelText: "Confirm Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              isLoading
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
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Please fill all fields",
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    if (password != confirm) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Passwords do not match",
                                          ),
                                        ),
                                      );
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
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child:
                              isLoading
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : const Text(
                                    "Create Account",
                                    style: TextStyle(color: Colors.white),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Center(
                        child: TextButton(
                          onPressed: () => context.go('/login'),
                          child: const Text(
                            "Already have an account? Sign In",
                            style: TextStyle(color: Color(0xFF0077B6)),
                          ),
                        ),
                      ),
                    ],
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

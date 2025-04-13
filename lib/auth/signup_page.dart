import 'package:app/auth/signup_model/custom_text_field.dart';
import 'package:app/auth/signup_model/signup_button.dart';
import 'package:app/auth/signup_model/signup_header.dart';
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

  void _validateAndSubmit() {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showSnack("Please fill all fields");
      return;
    }

    if (password != confirm) {
      _showSnack("Passwords do not match");
      return;
    }

    ref.read(signupControllerProvider.notifier).signup(
          username: username,
          email: email,
          password: password,
        );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final signupState = ref.watch(signupControllerProvider);
    final isLoading = signupState.isLoading;

    ref.listen<AsyncValue<void>>(signupControllerProvider, (prev, next) {
      next.whenOrNull(
        data: (_) => context.go('/login'),
        error: (err, _) => _showSnack(err.toString()),
      );
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFF),
      body: Column(
        children: [
          const SignUpHeader(),
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
                      CustomTextField(
                        controller: _usernameController,
                        label: "Username",
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _emailController,
                        label: "Email",
                        icon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _passwordController,
                        label: "Password",
                        icon: Icons.lock_outline,
                        obscure: true,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _confirmController,
                        label: "Confirm Password",
                        icon: Icons.lock_person_outlined,
                        obscure: true,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: SignUpButton(
                          isLoading: isLoading,
                          onPressed: _validateAndSubmit,
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

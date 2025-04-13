import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

void showResetPasswordDialog(BuildContext context) {
  final TextEditingController _emailResetController = TextEditingController();

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text("Reset Password"),
      content: TextField(
        controller: _emailResetController,
        decoration: const InputDecoration(labelText: "Enter your email"),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () async {
            final email = _emailResetController.text.trim();
            if (email.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please enter your email")),
              );
              return;
            }

            try {
              await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
              Navigator.of(ctx).pop();
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Email Sent"),
                  content: Text("Password reset link sent to $email."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            } catch (e) {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error: ${e.toString()}")),
              );
            }
          },
          child: const Text("Send Reset Link"),
        ),
      ],
    ),
  );
}

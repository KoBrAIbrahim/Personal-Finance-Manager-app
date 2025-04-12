import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class PrivacySettingsPage extends StatelessWidget {
  const PrivacySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FB),
      appBar: AppBar(
        title: const Text("Privacy"),
        backgroundColor: const Color(0xFF0077B6),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text("Delete Account"),
            subtitle: const Text("Permanently delete your account"),
            onTap: () => _confirmDeleteAccount(context),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text(
            "Are you sure you want to delete your account? This action is permanent."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _deleteAccount(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;

    if (user == null || email == null) return;

    try {
      final users = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      for (final doc in users.docs) {
        await doc.reference.delete();
      }

      final transactions = await FirebaseFirestore.instance
          .collection('transactions')
          .where('userEmail', isEqualTo: email)
          .get();

      for (final tx in transactions.docs) {
        await tx.reference.delete();
      }

      await user.delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account deleted successfully.")),
      );

      context.go('/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete account: ${e.toString()}")),
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../transaction_controller.dart';

class SubmitTransactionButton extends ConsumerWidget {
  const SubmitTransactionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionControllerProvider);
    final controller = ref.read(transactionControllerProvider.notifier);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: state.isSubmitting ? null : () => controller.submit(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0077B6),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: state.isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Add Transaction", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
